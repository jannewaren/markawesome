# frozen_string_literal: true

require 'digest'
require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms popover syntax into wa-popover elements with trigger buttons
  # Primary syntax: &&&params\ntrigger text\n>>>\ncontent\n&&&
  # Alternative syntax: :::wa-popover params\ntrigger text\n>>>\ncontent\n:::
  # Inline syntax: &&&params? trigger text >>> popover content&&&
  #
  # Params: space-separated tokens (order doesn't matter)
  # Placement: top (default), bottom, left, right
  # Flags: without-arrow
  # Distance: distance:N (e.g., distance:10)
  class PopoverTransformer < BaseTransformer
    POPOVER_ATTRIBUTES = {
      placement: %w[top bottom left right],
      without_arrow: %w[without-arrow],
      trigger_style: %w[link]
    }.freeze

    def self.transform(content)
      # Inline regex (single-line, no newlines allowed)
      inline_regex = /&&&[ \t]*([^\r\n]*?)[ \t]*>>>[ \t]*([^\r\n]+?)[ \t]*&&&/

      # Block regexes (multiline)
      primary_regex = /^&&&([^\n]*)$\n(.*?)\n^>>>$\n(.*?)\n^&&&$/m
      alternative_regex = /^:::wa-popover([^\n]*)$\n(.*?)\n^>>>$\n(.*?)\n^:::$/m

      # Inline transformation (always link style, plain text content)
      inline_transform = {
        regex: inline_regex,
        block: proc do |_match, matchdata|
          combined = matchdata[1]
          popover_content = matchdata[2].strip

          params_string, trigger_text = parse_inline_trigger_and_params(combined)
          placement, without_arrow, distance, _link_style = parse_parameters(params_string)

          popover_id = generate_popover_id(trigger_text, popover_content)

          build_inline_popover_html(popover_id, trigger_text, popover_content,
                                    { placement: placement, without_arrow: without_arrow,
                                      distance: distance })
        end
      }

      # Block transformation (existing)
      transform_proc = proc do |params_string, trigger_text, popover_content|
        trigger_text = trigger_text.strip
        popover_content = popover_content.strip

        placement, without_arrow, distance, link_style = parse_parameters(params_string)

        popover_id = generate_popover_id(trigger_text, popover_content)

        content_html = markdown_to_html(popover_content)

        build_popover_html(popover_id, trigger_text, content_html,
                           { placement: placement, without_arrow: without_arrow,
                             distance: distance, link_style: link_style })
      end

      # Inline patterns first to avoid conflicts with block patterns
      patterns = [
        inline_transform,
        *dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      ]
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def parse_parameters(params_string)
        return ['top', false, nil, false] if params_string.nil? || params_string.strip.empty?

        attributes = AttributeParser.parse(params_string, POPOVER_ATTRIBUTES)
        placement = attributes[:placement] || 'top'
        without_arrow = attributes[:without_arrow] == 'without-arrow'
        link_style = attributes[:trigger_style] == 'link'

        # Look for distance:N parameter
        tokens = params_string.strip.split(/\s+/)
        distance_token = tokens.find { |token| token.match?(/^distance:\d+$/) }
        distance = distance_token&.sub('distance:', '')

        [placement, without_arrow, distance, link_style]
      end

      def generate_popover_id(trigger_text, content)
        hash_input = "#{trigger_text}#{content}"
        hash = Digest::MD5.hexdigest(hash_input)
        "popover-#{hash[0..7]}"
      end

      def parse_inline_trigger_and_params(combined_string)
        tokens = combined_string.strip.split(/\s+/)
        param_tokens = []
        trigger_tokens = []
        found_content = false

        tokens.each do |token|
          if !found_content && popover_param?(token)
            param_tokens << token
          else
            found_content = true
            trigger_tokens << token
          end
        end

        trigger_text = trigger_tokens.join(' ')

        # If no trigger text remains, treat entire string as trigger (no params)
        if trigger_text.empty?
          ['', combined_string.strip]
        else
          [param_tokens.join(' '), trigger_text]
        end
      end

      def popover_param?(token)
        POPOVER_ATTRIBUTES.any? { |_attr, values| values.include?(token) } ||
          token.match?(/^distance:\d+$/)
      end

      def build_inline_popover_html(popover_id, trigger_text, content_text, options)
        trigger_content = escape_html(trigger_text)
        content_escaped = escape_html(content_text)
        content_escaped = content_escaped.gsub('\n', '<br>')

        popover_attrs = ["for='#{popover_id}'"]
        popover_attrs << "placement='#{options[:placement]}'"
        popover_attrs << 'without-arrow' if options[:without_arrow]
        popover_attrs << "distance='#{options[:distance]}'" if options[:distance]

        trigger = build_trigger(popover_id, trigger_content, true)

        "#{trigger}<wa-popover #{popover_attrs.join(' ')}>#{content_escaped}</wa-popover>"
      end

      def build_popover_html(popover_id, trigger_text, content_html, options)
        # Escape trigger text for security
        trigger_content = escape_html(trigger_text)

        # Build popover attributes
        popover_attrs = ["for='#{popover_id}'"]
        popover_attrs << "placement='#{options[:placement]}'"
        popover_attrs << 'without-arrow' if options[:without_arrow]
        popover_attrs << "distance='#{options[:distance]}'" if options[:distance]

        trigger = build_trigger(popover_id, trigger_content, options[:link_style])

        html = []
        html << trigger
        html << "<wa-popover #{popover_attrs.join(' ')}>"
        html << content_html
        html << '</wa-popover>'
        html.join("\n")
      end

      def build_trigger(popover_id, trigger_content, link_style)
        if link_style
          link_style_attr = 'background: none; border: none; padding: 0; ' \
                            'color: inherit; text-decoration: underline; ' \
                            'text-decoration-style: dotted; ' \
                            'cursor: pointer; font: inherit;'
          "<button id='#{popover_id}' class='ma-popover-trigger' style='#{link_style_attr}'>#{trigger_content}</button>"
        else
          "<wa-button id='#{popover_id}' variant='text'>#{trigger_content}</wa-button>"
        end
      end

      def escape_html(text)
        text.gsub('&', '&amp;')
            .gsub('<', '&lt;')
            .gsub('>', '&gt;')
            .gsub('"', '&quot;')
            .gsub("'", '&#39;')
      end
    end
  end
end
