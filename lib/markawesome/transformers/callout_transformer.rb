# frozen_string_literal: true

require_relative 'base_transformer'

module Markawesome
  # Transforms callout syntax into wa-callout elements
  # Primary syntax: :::variant\ncontent\n:::
  # Alternative syntax: :::wa-callout variant\ncontent\n:::
  # Variants: info, success, neutral, warning, danger
  class CalloutTransformer < BaseTransformer
    def self.transform(content)
      # Define both regex patterns
      primary_regex = /^:::(info|success|neutral|warning|danger)\n(.*?)\n:::/m
      alternative_regex = /^:::wa-callout\s+(info|success|neutral|warning|danger)\n(.*?)\n:::/m

      # Define shared transformation logic
      transform_proc = proc do |variant, inner_content|
        attrs = callout_attributes(variant)

        element_tag = "wa-callout#{attrs[:additional_params]}"
        html_content = "#{attrs[:inner_prepend]}#{markdown_to_html(inner_content)}"

        "<#{element_tag}>#{html_content}</wa-callout>"
      end

      # Apply both patterns
      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def callout_attributes(variant)
        # Get icon from configuration if available
        config = Markawesome.configuration
        icons = config&.callout_icons || default_icons

        case variant
        when 'info'
          {
            additional_params: ' variant="brand"',
            inner_prepend: "<wa-icon slot=\"icon\" name=\"#{icons[:info]}\" variant=\"solid\"></wa-icon>"
          }
        when 'success'
          {
            additional_params: ' variant="success"',
            inner_prepend: "<wa-icon slot=\"icon\" name=\"#{icons[:success]}\" variant=\"solid\"></wa-icon>"
          }
        when 'neutral'
          {
            additional_params: ' variant="neutral"',
            inner_prepend: "<wa-icon slot=\"icon\" name=\"#{icons[:neutral]}\" variant=\"solid\"></wa-icon>"
          }
        when 'warning'
          {
            additional_params: ' variant="warning"',
            inner_prepend: "<wa-icon slot=\"icon\" name=\"#{icons[:warning]}\" variant=\"solid\"></wa-icon>"
          }
        when 'danger'
          {
            additional_params: ' variant="danger"',
            inner_prepend: "<wa-icon slot=\"icon\" name=\"#{icons[:danger]}\" variant=\"solid\"></wa-icon>"
          }
        else
          {
            additional_params: '',
            inner_prepend: ''
          }
        end
      end

      def default_icons
        {
          info: 'circle-info',
          success: 'circle-check',
          neutral: 'gear',
          warning: 'triangle-exclamation',
          danger: 'circle-exclamation'
        }
      end
    end
  end
end
