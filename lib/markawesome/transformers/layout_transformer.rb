# frozen_string_literal: true

require_relative 'base_transformer'

module Markawesome
  # Transforms layout syntax into CSS layout utility containers
  # Primary syntax: ::::type params?\ncontent\n::::
  # Alternative syntax: ::::wa-type params?\ncontent\n::::
  # Supported types: grid, stack, cluster, split, flank, frame
  #
  # Common attributes (all layouts):
  #   gap:SIZE - wa-gap-{SIZE} class (0, 3xs, 2xs, xs, s, m, l, xl, 2xl, 3xl)
  #   align:VALUE - wa-align-items-{VALUE} class (start, end, center, stretch, baseline)
  #   justify:VALUE - wa-justify-content-{VALUE} class (start, end, center, space-between, space-around, space-evenly)
  #
  # Grid-specific: min:CSS_VALUE - sets --min-column-size style
  # Split-specific: row, column modifiers
  # Flank-specific: start, end modifiers; size:CSS_VALUE, content:PCT
  # Frame-specific: landscape, portrait, square modifiers; radius:SIZE
  class LayoutTransformer < BaseTransformer
    VALID_GAPS = %w[0 3xs 2xs xs s m l xl 2xl 3xl].freeze
    VALID_ALIGNS = %w[start end center stretch baseline].freeze
    VALID_JUSTIFIES = %w[start end center space-between space-around space-evenly].freeze
    VALID_RADII = %w[s m l pill circle square].freeze

    KEYWORD_MODIFIERS = {
      split: %w[row column],
      flank: %w[start end],
      frame: %w[landscape portrait square]
    }.freeze

    COMMON_KEY_CLASS_MAP = {
      'gap' => ->(v) { "wa-gap-#{v}" if VALID_GAPS.include?(v) },
      'align' => ->(v) { "wa-align-items-#{v}" if VALID_ALIGNS.include?(v) },
      'justify' => ->(v) { "wa-justify-content-#{v}" if VALID_JUSTIFIES.include?(v) }
    }.freeze

    def self.transform(content)
      primary_regex = /^::::(grid|stack|cluster|split|flank|frame)[ \t]*([^\n]*)\n(.*?)\n::::/m
      alternative_regex = /^::::wa-(grid|stack|cluster|split|flank|frame)[ \t]*([^\n]*)\n(.*?)\n::::/m

      transform_proc = proc do |type, params_string, inner_content|
        classes, styles = build_attributes(type, params_string)
        build_html(classes, styles, inner_content)
      end

      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def build_attributes(type, params_string)
        classes = ["wa-#{type}"]
        styles = []

        return [classes, styles] if params_string.nil? || params_string.strip.empty?

        tokens = params_string.strip.split(/\s+/)

        tokens.each do |token|
          process_token(type, token, classes, styles)
        end

        [classes, styles]
      end

      def process_token(type, token, classes, styles)
        if token.include?(':')
          process_key_value(type, token, classes, styles)
        else
          process_keyword(type, token, classes)
        end
      end

      def process_key_value(type, token, classes, styles)
        key, value = token.split(':', 2)
        return if value.nil? || value.empty?

        if COMMON_KEY_CLASS_MAP.key?(key)
          css_class = COMMON_KEY_CLASS_MAP[key].call(value)
          classes << css_class if css_class
        else
          process_type_specific_key_value(type, key, value, classes, styles)
        end
      end

      def process_type_specific_key_value(type, key, value, classes, styles)
        case key
        when 'min'
          styles << "--min-column-size: #{sanitize_css(value)}" if type == 'grid'
        when 'size'
          styles << "--flank-size: #{sanitize_css(value)}" if type == 'flank'
        when 'content'
          styles << "--content-percentage: #{sanitize_css(value)}" if type == 'flank'
        when 'radius'
          classes << "wa-border-radius-#{value}" if type == 'frame' && VALID_RADII.include?(value)
        end
      end

      def process_keyword(type, token, classes)
        modifiers = KEYWORD_MODIFIERS[type.to_sym]
        return unless modifiers&.include?(token)

        classes[0] = "wa-#{type}:#{token}"
      end

      def sanitize_css(value)
        value.gsub(/["'<>;]/, '')
      end

      def build_html(classes, styles, inner_content)
        attr_parts = ["class=\"#{classes.join(' ')}\""]
        attr_parts << "style=\"#{styles.join('; ')}\"" unless styles.empty?

        "<div #{attr_parts.join(' ')}>\n#{inner_content}\n</div>"
      end
    end
  end
end
