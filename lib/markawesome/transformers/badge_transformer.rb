# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms badge syntax into wa-badge elements
  # Primary syntax: !!!params?\ncontent\n!!!
  # Alternative syntax: :::wa-badge params?\ncontent\n:::
  #
  # Params: space-separated tokens, any order (rightmost-wins for conflicts)
  # Variants: brand, success, neutral, warning, danger
  # Appearance: accent, filled, outlined, filled-outlined
  # Attention: none, pulse, bounce
  # Flags: pill
  class BadgeTransformer < BaseTransformer
    BADGE_ATTRIBUTES = {
      variant: %w[brand success neutral warning danger],
      appearance: %w[accent filled outlined filled-outlined],
      attention: %w[none pulse bounce],
      pill: %w[pill]
    }.freeze

    def self.transform(content)
      # Define both regex patterns - capture params as a single string
      primary_regex = /^!!!(.*?)\n(.*?)\n!!!/m
      alternative_regex = /^:::wa-badge\s*(.*?)\n(.*?)\n:::/m

      # Define shared transformation logic
      transform_proc = proc do |params_string, badge_content|
        badge_content = badge_content.strip

        # Parse space-separated parameters
        attributes = AttributeParser.parse(params_string, BADGE_ATTRIBUTES)

        build_badge_html(badge_content, attributes)
      end

      # Apply both patterns
      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def build_badge_html(content, attributes)
        badge_html = markdown_to_html(content).strip

        # Remove paragraph tags if the content is just text
        badge_html = badge_html.gsub(%r{^<p>(.*)</p>$}m, '\1')

        # Fix whitespace issues in Web Awesome badges by ensuring proper spacing
        # Replace spaces after closing tags with non-breaking spaces to prevent CSS collapse
        badge_html = badge_html.gsub(%r{(</\w+>)\s+}, '\1&nbsp;')

        # Build HTML attributes
        attr_parts = []
        attr_parts << "variant=\"#{attributes[:variant]}\"" if attributes[:variant]
        attr_parts << "appearance=\"#{attributes[:appearance]}\"" if attributes[:appearance]
        attr_parts << "attention=\"#{attributes[:attention]}\"" if attributes[:attention]
        attr_parts << 'pill' if attributes[:pill]

        attrs_string = attr_parts.empty? ? '' : " #{attr_parts.join(' ')}"

        "<wa-badge#{attrs_string}>#{badge_html}</wa-badge>"
      end
    end
  end
end
