# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms summary/details syntax into wa-details elements
  # Primary syntax: ^^^appearance? icon-placement? disabled? open? name:value?\nsummary\n>>>\ndetails\n^^^
  # Alternative syntax: :::wa-details appearance? icon-placement? disabled? open? name:value?\nsummary\n>>>\ndetails\n:::
  # Appearances: outlined (default), filled, filled-outlined, plain
  # Icon placement: start, end (default)
  # Boolean flags: disabled, open
  # Name: name:group-id for accordion behavior
  class DetailsTransformer < BaseTransformer
    COMPONENT_ATTRIBUTES = {
      appearance: %w[outlined filled filled-outlined plain],
      icon_placement: %w[start end],
      disabled: %w[disabled],
      open: %w[open]
    }.freeze

    def self.transform(content)
      # Define both regex patterns - capture parameter string
      primary_regex = /^\^\^\^?(.*?)\n(.*?)\n^>>>\n(.*?)\n^\^\^\^?/m
      alternative_regex = /^:::wa-details\s*(.*?)\n(.*?)\n^>>>\n(.*?)\n:::/m

      # Define shared transformation logic
      transform_proc = proc do |params_string, summary_content, details_content|
        summary_content = summary_content.strip
        details_content = details_content.strip

        # Parse parameters using AttributeParser
        attributes = AttributeParser.parse(params_string, COMPONENT_ATTRIBUTES)

        # Extract name parameter (format: name:value) - special handling
        name_value = extract_name_value(params_string)

        appearance_class = normalize_appearance(attributes[:appearance])
        icon_placement = attributes[:icon_placement] || 'end'
        summary_html = markdown_to_html(summary_content)
        details_html = markdown_to_html(details_content)

        # Build attributes
        attr_parts = ["appearance='#{appearance_class}'", "icon-placement='#{icon_placement}'"]
        attr_parts << 'disabled' if attributes[:disabled]
        attr_parts << 'open' if attributes[:open]
        attr_parts << "name='#{name_value}'" if name_value

        "<wa-details #{attr_parts.join(' ')}>" \
          "<span slot='summary'>#{summary_html}</span>" \
          "#{details_html}</wa-details>"
      end

      # Apply both patterns
      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def extract_name_value(params_string)
        return nil if params_string.nil? || params_string.strip.empty?

        # Extract name parameter (format: name:value)
        tokens = params_string.strip.split(/\s+/)
        name_token = tokens.find { |token| token.start_with?('name:') }
        name_token&.sub(/^name:/, '')
      end

      def normalize_appearance(appearance_param)
        case appearance_param
        when 'filled'
          'filled'
        when 'filled-outlined'
          'filled outlined'
        when 'plain'
          'plain'
        else
          'outlined'
        end
      end
    end
  end
end
