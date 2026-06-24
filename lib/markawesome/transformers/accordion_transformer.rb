# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'
require_relative '../icon_slot_parser'

module Markawesome
  # Transforms accordion syntax into wa-accordion / wa-accordion-item elements
  # Primary syntax:
  #   //////appearance? mode? icon-placement? heading:N?
  #   /// [expanded] [disabled] [icon:name] Label text
  #   item body markdown
  #   ///
  #   //////
  # Alternative syntax: :::wa-accordion ...same items... :::
  #
  # Container attributes (bare, order-independent, rightmost-wins):
  #   - appearance: outlined (default), filled, filled-outlined, plain
  #   - mode: multiple (default), single, single-collapsible
  #   - icon-placement: start, end (default emitted only when given)
  #   - heading:N -> heading-level="N" where N is 1-6 or "none"
  # Item tokens (leading flags, then the rest of the line is the label):
  #   - expanded -> expanded; disabled -> disabled
  #   - icon:name -> <wa-icon slot="icon" name="name"></wa-icon> as first child
  #
  # wa-accordion is experimental in Web Awesome (added 3.7). expanded/disabled
  # and the mode/appearance/icon-placement attributes are all static-safe.
  class AccordionTransformer < BaseTransformer
    CONTAINER_ATTRIBUTES = {
      appearance: %w[outlined filled filled-outlined plain],
      mode: %w[multiple single single-collapsible],
      icon_placement: %w[start end]
    }.freeze

    ICON_SLOTS = {
      default: 'icon',
      slots: %w[icon],
      slot_map: { 'icon' => 'icon' }
    }.freeze

    ITEM_FLAGS = %w[expanded disabled].freeze

    PRIMARY_REGEX = %r{^/{6}([^\n]*)\n((?:/{3} [^\n]+\n.*?\n/{3}\n?)+)/{6}}m
    ALTERNATIVE_REGEX = %r{^:::wa-accordion\s*([^\n]*)\n((?:/{3} [^\n]+\n.*?\n/{3}\n?)+):::}m
    ITEM_REGEX = %r{^/{3} ([^\n]+)\n(.*?)\n/{3}}m

    def self.transform(content)
      transform_proc = proc do |params_string, items_block, _third|
        attributes = AttributeParser.parse(params_string.to_s.strip, CONTAINER_ATTRIBUTES)
        heading_level = extract_heading_level(params_string)

        attr_parts = ["appearance=\"#{normalize_appearance(attributes[:appearance])}\""]
        attr_parts << "mode=\"#{attributes[:mode]}\"" if attributes[:mode]
        attr_parts << "icon-placement=\"#{attributes[:icon_placement]}\"" if attributes[:icon_placement]
        attr_parts << "heading-level=\"#{heading_level}\"" if heading_level

        "<wa-accordion #{attr_parts.join(' ')}>#{build_items(items_block)}</wa-accordion>"
      end

      patterns = dual_syntax_patterns(PRIMARY_REGEX, ALTERNATIVE_REGEX, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    def self.render_as_markdown(content, _options = {})
      transform_proc = proc do |_params_string, items_block, _third|
        items_block.scan(ITEM_REGEX).map do |header, body|
          _flags, label = parse_item_flags_and_label(IconSlotParser.parse(header, ICON_SLOTS)[:remaining])
          "### #{label}\n\n#{body.strip}"
        end.join("\n\n")
      end

      patterns = dual_syntax_patterns(PRIMARY_REGEX, ALTERNATIVE_REGEX, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def build_items(items_block)
        items_block.scan(ITEM_REGEX).map do |header, body|
          icon_result = IconSlotParser.parse(header, ICON_SLOTS)
          flags, label = parse_item_flags_and_label(icon_result[:remaining])

          item_attrs = ["label=\"#{escape_html(label)}\""]
          item_attrs << 'expanded' if flags.include?('expanded')
          item_attrs << 'disabled' if flags.include?('disabled')

          icon_html = IconSlotParser.to_html(icon_result[:icons], ICON_SLOTS[:slot_map])
          body_html = markdown_to_html(body.strip)

          "<wa-accordion-item #{item_attrs.join(' ')}>#{icon_html}#{body_html}</wa-accordion-item>"
        end.join
      end

      # Consume leading expanded/disabled tokens; the remainder is the label.
      def parse_item_flags_and_label(remaining)
        tokens = remaining.to_s.strip.split(/\s+/)
        flags = []
        flags << tokens.shift while tokens.any? && ITEM_FLAGS.include?(tokens.first)
        [flags, tokens.join(' ')]
      end

      def extract_heading_level(params_string)
        return nil if params_string.nil? || params_string.strip.empty?

        token = params_string.strip.split(/\s+/).find { |t| t.start_with?('heading:') }
        return nil unless token

        value = token.sub(/^heading:/, '')
        return value if value == 'none' || value.match?(/\A[1-6]\z/)

        nil
      end

      def normalize_appearance(appearance_param)
        case appearance_param
        when 'filled'
          'filled'
        when 'filled-outlined'
          'filled-outlined'
        when 'plain'
          'plain'
        else
          'outlined'
        end
      end

      def escape_html(text)
        text.to_s
            .gsub('&', '&amp;')
            .gsub('<', '&lt;')
            .gsub('>', '&gt;')
            .gsub('"', '&quot;')
            .gsub("'", '&#39;')
      end
    end
  end
end
