# frozen_string_literal: true

require 'digest'
require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms popover syntax into wa-popover elements with trigger buttons
  # Primary syntax: &&&params\ntrigger text\n>>>\ncontent\n&&&
  # Alternative syntax: :::wa-popover params\ntrigger text\n>>>\ncontent\n:::
  #
  # Params: space-separated tokens (order doesn't matter)
  # Placement: top (default), bottom, left, right
  # Flags: without-arrow
  # Distance: distance:N (e.g., distance:10)
  class PopoverTransformer < BaseTransformer
    POPOVER_ATTRIBUTES = {
      placement: %w[top bottom left right],
      without_arrow: %w[without-arrow]
    }.freeze

    def self.transform(content)
      primary_regex = /^&&&([^\n]*)$\n(.*?)\n^>>>$\n(.*?)\n^&&&$/m
      alternative_regex = /^:::wa-popover([^\n]*)$\n(.*?)\n^>>>$\n(.*?)\n^:::$/m

      transform_proc = proc do |params_string, trigger_text, popover_content|
        trigger_text = trigger_text.strip
        popover_content = popover_content.strip

        placement, without_arrow, distance = parse_parameters(params_string)

        popover_id = generate_popover_id(trigger_text, popover_content)

        content_html = markdown_to_html(popover_content)

        build_popover_html(popover_id, trigger_text, content_html,
                           placement, without_arrow, distance)
      end

      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def parse_parameters(params_string)
        return ['top', false, nil] if params_string.nil? || params_string.strip.empty?

        attributes = AttributeParser.parse(params_string, POPOVER_ATTRIBUTES)
        placement = attributes[:placement] || 'top'
        without_arrow = attributes[:without_arrow] == 'without-arrow'

        # Look for distance:N parameter
        tokens = params_string.strip.split(/\s+/)
        distance_token = tokens.find { |token| token.match?(/^distance:\d+$/) }
        distance = distance_token&.sub('distance:', '')

        [placement, without_arrow, distance]
      end

      def generate_popover_id(trigger_text, content)
        hash_input = "#{trigger_text}#{content}"
        hash = Digest::MD5.hexdigest(hash_input)
        "popover-#{hash[0..7]}"
      end

      def build_popover_html(popover_id, trigger_text, content_html,
                             placement, without_arrow, distance)
        # Escape trigger text for security
        trigger_content = escape_html(trigger_text)

        # Build popover attributes
        popover_attrs = ["for='#{popover_id}'"]
        popover_attrs << "placement='#{placement}'"
        popover_attrs << 'without-arrow' if without_arrow
        popover_attrs << "distance='#{distance}'" if distance

        html = []
        html << "<wa-button id='#{popover_id}' variant='text'>#{trigger_content}</wa-button>"
        html << "<wa-popover #{popover_attrs.join(' ')}>"
        html << content_html
        html << '</wa-popover>'
        html.join("\n")
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
