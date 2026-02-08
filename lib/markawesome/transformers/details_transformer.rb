# frozen_string_literal: true

require_relative 'base_transformer'

module Markawesome
  # Transforms summary/details syntax into wa-details elements
  # Primary syntax: ^^^appearance? icon-placement? disabled? open? name:value?\nsummary\n>>>\ndetails\n^^^
  # Alternative syntax: :::wa-details appearance? icon-placement? disabled? open? name:value?\nsummary\n>>>\ndetails\n:::
  # Appearances: outlined (default), filled, filled-outlined, plain
  # Icon placement: start, end (default)
  # Boolean flags: disabled, open
  # Name: name:group-id for accordion behavior
  class DetailsTransformer < BaseTransformer
    def self.transform(content)
      # Define both regex patterns - capture parameter string
      primary_regex = /^\^\^\^?(.*?)\n(.*?)\n^>>>\n(.*?)\n^\^\^\^?/m
      alternative_regex = /^:::wa-details\s*(.*?)\n(.*?)\n^>>>\n(.*?)\n:::/m

      # Define shared transformation logic
      transform_proc = proc do |params_string, summary_content, details_content|
        summary_content = summary_content.strip
        details_content = details_content.strip

        # Parse parameters from the params string
        appearance_param, icon_placement_param, disabled, open_state, name_value = parse_parameters(params_string)

        appearance_class = normalize_appearance(appearance_param)
        icon_placement = normalize_icon_placement(icon_placement_param)
        summary_html = markdown_to_html(summary_content)
        details_html = markdown_to_html(details_content)

        # Build attributes
        attributes = "appearance='#{appearance_class}' icon-placement='#{icon_placement}'"
        attributes += ' disabled' if disabled
        attributes += ' open' if open_state
        attributes += " name='#{name_value}'" if name_value

        "<wa-details #{attributes}>" \
          "<span slot='summary'>#{summary_html}</span>" \
          "#{details_html}</wa-details>"
      end

      # Apply both patterns
      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def parse_parameters(params_string)
        return [nil, nil, false, false, nil] if params_string.nil? || params_string.strip.empty?

        # Split by whitespace and extract known parameters
        tokens = params_string.strip.split(/\s+/)

        appearance_options = %w[outlined filled filled-outlined plain]
        placement_options = %w[start end]

        appearance_param = tokens.find { |token| appearance_options.include?(token) }
        icon_placement_param = tokens.find { |token| placement_options.include?(token) }
        disabled = tokens.include?('disabled')
        open_state = tokens.include?('open')

        # Extract name parameter (format: name:value)
        name_token = tokens.find { |token| token.start_with?('name:') }
        name_value = name_token&.sub(/^name:/, '')

        [appearance_param, icon_placement_param, disabled, open_state, name_value]
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

      def normalize_icon_placement(icon_placement_param)
        case icon_placement_param
        when 'start'
          'start'
        when 'end'
          'end'
        else
          'end'
        end
      end
    end
  end
end
