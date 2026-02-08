# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms callout syntax into wa-callout elements
  # Primary syntax: :::variant [size] [appearance]\ncontent\n:::
  # Alternative syntax: :::wa-callout variant [size] [appearance]\ncontent\n:::
  # Variants: brand, info (alias for brand), success, neutral, warning, danger
  # Size: small, medium, large
  # Appearance: accent, filled, outlined, plain, filled-outlined
  class CalloutTransformer < BaseTransformer
    VARIANTS = %w[info brand success neutral warning danger].freeze
    CALLOUT_ATTRIBUTES = {
      size: %w[small medium large],
      appearance: %w[accent filled outlined plain filled-outlined]
    }.freeze
    VARIANT_ALIASES = { 'info' => 'brand' }.freeze

    def self.transform(content)
      variant_pattern = VARIANTS.join('|')
      primary_regex = /^:::(#{variant_pattern})([^\n]*)\n(.*?)\n:::/m
      alternative_regex = /^:::wa-callout\s+(#{variant_pattern})([^\n]*)\n(.*?)\n:::/m

      transform_proc = proc do |variant, extra_params, inner_content|
        actual_variant = VARIANT_ALIASES.fetch(variant, variant)
        extra_attrs = AttributeParser.parse(extra_params, CALLOUT_ATTRIBUTES)

        attr_parts = ["variant=\"#{actual_variant}\""]
        attr_parts << "appearance=\"#{extra_attrs[:appearance]}\"" if extra_attrs[:appearance]
        attr_parts << "size=\"#{extra_attrs[:size]}\"" if extra_attrs[:size]

        icon_html = icon_for(actual_variant)
        html_content = "#{icon_html}#{markdown_to_html(inner_content)}"

        "<wa-callout #{attr_parts.join(' ')}>#{html_content}</wa-callout>"
      end

      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def icon_for(variant)
        config = Markawesome.configuration
        icons = config&.callout_icons || default_icons
        icon_name = icons[variant.to_sym]
        "<wa-icon slot=\"icon\" name=\"#{icon_name}\" variant=\"solid\"></wa-icon>"
      end

      def default_icons
        {
          brand: 'circle-info',
          success: 'circle-check',
          neutral: 'gear',
          warning: 'triangle-exclamation',
          danger: 'circle-exclamation'
        }
      end
    end
  end
end
