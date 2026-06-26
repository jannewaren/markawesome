# frozen_string_literal: true

require 'digest'
require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms tooltip syntax into wa-tooltip elements attached to a focusable
  # anchor span via an auto-generated for/id pair. Declarative, zero-JS, and
  # static-site-safe — great for glossary terms and inline definitions.
  #
  # Inline syntax (primary): (((anchor term >>> tip text)))
  # Alternative block syntax: :::wa-tooltip params\nanchor\n>>>\ntip\n:::
  #
  # Params: space-separated tokens (order doesn't matter)
  # Placement: top (default), bottom, left, right, plus the eight aligned
  #   variants (top-start, top-end, right-start, …) — the full wa-tooltip surface
  # Distance: distance:N (e.g., distance:10) — offset away from the target
  # Skidding: skidding:N (e.g., skidding:12, skidding:-4) — offset along the target
  #
  # Tip content is plain text (HTML-escaped), with literal `\n` rendered as
  # <br> — the same surface as the popover's inline form. Tooltips hold brief
  # text, so there is no markdown body.
  class TooltipTransformer < BaseTransformer
    TOOLTIP_ATTRIBUTES = {
      placement: %w[top top-start top-end right right-start right-end
                    bottom bottom-start bottom-end left left-start left-end]
    }.freeze

    # Inline regex (single-line, no newlines allowed): capture 1 = params+anchor,
    # capture 2 = tip text.
    INLINE_REGEX = /\(\(\([ \t]*([^\r\n]*?)[ \t]*>>>[ \t]*([^\r\n]+?)[ \t]*\)\)\)/
    # Block alternative regex (multiline): capture 1 = params, 2 = anchor, 3 = tip.
    ALTERNATIVE_REGEX = /^:::wa-tooltip([^\n]*)$\n(.*?)\n^>>>$\n(.*?)\n^:::$/m

    def self.transform(content)
      # Tracks ID base usage within this transform call so repeated tooltips
      # (same anchor + tip) get disambiguated suffixes instead of colliding on
      # the page.
      seen_ids = Hash.new(0)

      inline_transform = {
        regex: INLINE_REGEX,
        block: proc do |_match, matchdata|
          combined = matchdata[1]
          tip_text = matchdata[2].strip

          params_string, anchor_text = parse_inline_anchor_and_params(combined)
          placement, distance, skidding = parse_parameters(params_string)

          tooltip_id = generate_tooltip_id(anchor_text, tip_text, seen_ids)

          build_tooltip_html(tooltip_id, anchor_text, tip_text,
                             { placement: placement, distance: distance, skidding: skidding })
        end
      }

      alternative_transform = {
        regex: ALTERNATIVE_REGEX,
        block: proc do |_match, matchdata|
          params_string = matchdata[1]
          anchor_text = matchdata[2].strip
          tip_text = matchdata[3].strip

          placement, distance, skidding = parse_parameters(params_string)

          tooltip_id = generate_tooltip_id(anchor_text, tip_text, seen_ids)

          build_tooltip_html(tooltip_id, anchor_text, tip_text,
                             { placement: placement, distance: distance, skidding: skidding })
        end
      }

      # Inline pattern first to avoid conflicts with the block pattern.
      apply_multiple_patterns(content, [inline_transform, alternative_transform])
    end

    def self.render_as_markdown(content, _options = {})
      inline_transform = {
        regex: INLINE_REGEX,
        block: proc do |_match, matchdata|
          combined = matchdata[1]
          tip_text = matchdata[2].strip
          _params, anchor_text = parse_inline_anchor_and_params(combined)
          "**#{anchor_text}** (#{tip_text})"
        end
      }

      alternative_transform = {
        regex: ALTERNATIVE_REGEX,
        block: proc do |_match, matchdata|
          anchor_text = matchdata[2].strip
          tip_text = matchdata[3].strip
          "**#{anchor_text}** (#{tip_text})"
        end
      }

      apply_multiple_patterns(content, [inline_transform, alternative_transform])
    end

    class << self
      private

      def parse_parameters(params_string)
        return ['top', nil, nil] if params_string.nil? || params_string.strip.empty?

        attributes = AttributeParser.parse(params_string, TOOLTIP_ATTRIBUTES)
        placement = attributes[:placement] || 'top'

        # Look for distance:N / skidding:N parameters (rightmost-wins; skidding may be negative)
        tokens = params_string.strip.split(/\s+/)
        distance_token = tokens.reverse.find { |token| token.match?(/^distance:\d+$/) }
        distance = distance_token&.sub('distance:', '')
        skidding_token = tokens.reverse.find { |token| token.match?(/^skidding:-?\d+$/) }
        skidding = skidding_token&.sub('skidding:', '')

        [placement, distance, skidding]
      end

      def generate_tooltip_id(anchor_text, tip_text, seen_ids)
        hash_input = "#{anchor_text}#{tip_text}"
        hash = Digest::MD5.hexdigest(hash_input)
        base = "tooltip-#{hash[0..7]}"
        occurrence = seen_ids[base] += 1
        occurrence == 1 ? base : "#{base}-#{occurrence}"
      end

      def parse_inline_anchor_and_params(combined_string)
        tokens = combined_string.strip.split(/\s+/)
        param_tokens = []
        anchor_tokens = []
        found_anchor = false

        tokens.each do |token|
          if !found_anchor && tooltip_param?(token)
            param_tokens << token
          else
            found_anchor = true
            anchor_tokens << token
          end
        end

        anchor_text = anchor_tokens.join(' ')

        # If no anchor text remains, treat entire string as the anchor (no params)
        if anchor_text.empty?
          ['', combined_string.strip]
        else
          [param_tokens.join(' '), anchor_text]
        end
      end

      def tooltip_param?(token)
        TOOLTIP_ATTRIBUTES.any? { |_attr, values| values.include?(token) } ||
          token.match?(/^distance:\d+$/) ||
          token.match?(/^skidding:-?\d+$/)
      end

      def build_tooltip_html(tooltip_id, anchor_text, tip_text, options)
        anchor_content = escape_html(anchor_text)
        tip_escaped = escape_html(tip_text).gsub('\n', '<br>')

        tooltip_attrs = ["for=\"#{tooltip_id}\""]
        tooltip_attrs << "placement=\"#{options[:placement]}\""
        tooltip_attrs << "distance=\"#{options[:distance]}\"" if options[:distance]
        tooltip_attrs << "skidding=\"#{options[:skidding]}\"" if options[:skidding]

        anchor = build_anchor(tooltip_id, anchor_content)

        "#{anchor}<wa-tooltip #{tooltip_attrs.join(' ')}>#{tip_escaped}</wa-tooltip>"
      end

      # Focusable span so keyboard/AT users get the tip (tooltips fire on focus
      # too). The dotted underline + help cursor mirror the link-style popover
      # trigger; the ma-tooltip-anchor class is a styling hook for consumers.
      def build_anchor(tooltip_id, anchor_content)
        style = 'text-decoration: underline dotted; cursor: help;'
        "<span id=\"#{tooltip_id}\" tabindex=\"0\" class=\"ma-tooltip-anchor\" " \
          "style=\"#{style}\">#{anchor_content}</span>"
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
