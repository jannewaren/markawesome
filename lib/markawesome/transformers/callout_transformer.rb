# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'
require_relative '../icon_slot_parser'
require_relative '../icon_attributes'

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
      size: %w[xs s m l xl small medium large],
      appearance: %w[accent filled outlined plain filled-outlined]
    }.freeze
    VARIANT_ALIASES = { 'info' => 'brand' }.freeze
    ICON_SLOTS = { default: 'icon', slots: %w[icon] }.freeze

    def self.transform(content)
      variant_pattern = VARIANTS.join('|')
      primary_regex = /^:::(#{variant_pattern})([^\n]*)\n(.*?)\n:::/m
      alternative_regex = /^:::wa-callout\s+(#{variant_pattern})([^\n]*)\n(.*?)\n:::/m

      transform_proc = proc do |variant, extra_params, inner_content|
        actual_variant = VARIANT_ALIASES.fetch(variant, variant)

        # Parse icon tokens first, then pass remaining to AttributeParser.
        # CALLOUT_ATTRIBUTES and IconAttributes::SCHEMA namespaces are disjoint, so the
        # same remaining-token string can be parsed against both independently.
        icon_result = IconSlotParser.parse(extra_params, ICON_SLOTS)
        extra_attrs = AttributeParser.parse(icon_result[:remaining], CALLOUT_ATTRIBUTES)
        icon_attrs  = AttributeParser.parse(icon_result[:remaining], IconAttributes::SCHEMA)
        icon_attrs[:variant] ||= 'solid' # preserve historical default

        attr_parts = ["variant=\"#{actual_variant}\""]
        attr_parts << "appearance=\"#{extra_attrs[:appearance]}\"" if extra_attrs[:appearance]
        attr_parts << "size=\"#{extra_attrs[:size]}\"" if extra_attrs[:size]

        icon_name = icon_result[:icons]['icon'] || icon_name_for(actual_variant)
        icon_html = callout_icon_html(icon_name, icon_attrs)
        html_content = "#{icon_html}#{markdown_to_html(inner_content)}"

        "<wa-callout #{attr_parts.join(' ')}>#{html_content}</wa-callout>"
      end

      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    GFM_ALERT_MAP = {
      'info' => 'NOTE',
      'brand' => 'NOTE',
      'success' => 'TIP',
      'neutral' => 'IMPORTANT',
      'warning' => 'WARNING',
      'danger' => 'CAUTION'
    }.freeze

    def self.render_as_markdown(content, _options = {})
      variant_pattern = VARIANTS.join('|')
      primary_regex = /^:::(#{variant_pattern})([^\n]*)\n(.*?)\n:::/m
      alternative_regex = /^:::wa-callout\s+(#{variant_pattern})([^\n]*)\n(.*?)\n:::/m

      transform_proc = proc do |variant, _extra_params, inner_content|
        alert = GFM_ALERT_MAP.fetch(variant, 'NOTE')
        body = inner_content.to_s.strip
        quoted = body.empty? ? '' : body.split("\n").map { |l| l.empty? ? '>' : "> #{l}" }.join("\n")
        body.empty? ? "> [!#{alert}]" : "> [!#{alert}]\n#{quoted}"
      end

      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def icon_name_for(variant)
        config = Markawesome.configuration
        icons = config&.callout_icons || default_icons
        icons[variant.to_sym]
      end

      def callout_icon_html(name, attributes)
        parts = ['slot="icon"', "name=\"#{name}\""]
        parts.concat(IconAttributes.pairs(attributes))
        "<wa-icon #{parts.join(' ')}></wa-icon>"
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
