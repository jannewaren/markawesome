# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'
require_relative '../icon_slot_parser'

module Markawesome
  # Transforms button syntax into wa-button elements
  # Primary syntax: %%%attributes?\ncontent\n%%%
  # Alternative syntax: :::wa-button attributes?\ncontent\n:::
  #
  # Attributes:
  # - variant: brand, success, neutral, warning, danger
  # - appearance: accent, filled, outlined, filled-outlined, plain
  # - size: small, medium, large
  # - pill: pill (rounded edges)
  # - caret: caret (dropdown indicator)
  # - loading: loading (loading state)
  # - disabled: disabled (disabled state)
  #
  # Link buttons: %%%brand\n[Text](url)\n%%%
  # Regular buttons: %%%brand large pill\nText\n%%%
  class ButtonTransformer < BaseTransformer
    # Define the schema for button attributes
    BUTTON_ATTRIBUTES = {
      variant: %w[brand success neutral warning danger],
      appearance: %w[accent filled outlined filled-outlined plain],
      size: %w[small medium large],
      pill: %w[pill],
      caret: %w[caret],
      loading: %w[loading],
      disabled: %w[disabled]
    }.freeze

    ICON_SLOTS = { default: 'start', slots: %w[start end] }.freeze

    def self.transform(content)
      # Define both regex patterns - capture all space-separated parameters
      primary_regex = /^%%%([^\n]*)\n(.*?)\n%%%/m
      alternative_regex = /^:::wa-button\s*([^\n]*)\n(.*?)\n:::/m

      # Define shared transformation logic
      transform_proc = proc do |params_string, button_content|
        button_content = button_content.strip

        # Parse icon tokens first, then pass remaining to AttributeParser
        icon_result = IconSlotParser.parse(params_string, ICON_SLOTS)
        attributes = AttributeParser.parse(icon_result[:remaining], BUTTON_ATTRIBUTES)

        build_button_html(button_content, attributes, icon_result[:icons])
      end

      # Apply both patterns
      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def build_button_html(content, attributes, icons = {})
        # Build HTML attributes from parsed attributes
        html_attrs = []

        html_attrs << "variant=\"#{attributes[:variant]}\"" if attributes[:variant]
        html_attrs << "appearance=\"#{attributes[:appearance]}\"" if attributes[:appearance]
        html_attrs << "size=\"#{attributes[:size]}\"" if attributes[:size]
        html_attrs << 'pill' if attributes[:pill]
        html_attrs << 'with-caret' if attributes[:caret]
        html_attrs << 'loading' if attributes[:loading]
        html_attrs << 'disabled' if attributes[:disabled]

        attrs_string = html_attrs.empty? ? '' : " #{html_attrs.join(' ')}"
        icon_html = IconSlotParser.to_html(icons)

        # Check if content contains a markdown link
        link_match = content.match(/^\[([^\]]+)\]\(([^)]+)\)$/)

        if link_match
          # It's a link button
          link_text = link_match[1]
          link_url = link_match[2]

          # Process any markdown in the link text (bold, italic, etc.)
          button_html = markdown_to_html(link_text).strip
          button_html = button_html.gsub(%r{^<p>(.*)</p>$}m, '\1')

          # Fix whitespace issues like in badges
          button_html = button_html.gsub(%r{(</\w+>)\s+}, '\1&nbsp;')

          "<wa-button#{attrs_string} href=\"#{link_url}\">#{icon_html}#{button_html}</wa-button>"
        else
          # It's a regular button
          button_html = markdown_to_html(content).strip
          button_html = button_html.gsub(%r{^<p>(.*)</p>$}m, '\1')

          # Fix whitespace issues like in badges
          button_html = button_html.gsub(%r{(</\w+>)\s+}, '\1&nbsp;')

          "<wa-button#{attrs_string}>#{icon_html}#{button_html}</wa-button>"
        end
      end
    end
  end
end
