# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms carousel syntax into wa-carousel elements
  # Primary syntax: ~~~~~~params\n~~~ slide1\ncontent\n~~~\n~~~ slide2\ncontent\n~~~\n~~~~~~
  # Alternative syntax: :::wa-carousel params\n~~~ slide1\ncontent\n~~~\n~~~ slide2\ncontent\n~~~\n:::
  # Params can include: numbers (slides-per-page, slides-per-move), keywords (loop, navigation, pagination,
  # autoplay, mouse-dragging, vertical), key-value pairs (autoplay-interval:value), and CSS properties
  # (scroll-hint:value, aspect-ratio:value, slide-gap:value)
  class CarouselTransformer < BaseTransformer
    COMPONENT_ATTRIBUTES = {
      loop: %w[loop],
      navigation: %w[navigation],
      pagination: %w[pagination],
      autoplay: %w[autoplay],
      'mouse-dragging': %w[mouse-dragging],
      vertical: %w[vertical]
    }.freeze

    def self.transform(content)
      # Define both regex patterns
      # Match: ~~~~~~params (optional)
      #        ~~~
      #        content (can be empty)
      #        ~~~
      #        (repeat slides)
      #        ~~~~~~
      primary_regex = /^~{6}([^\n]*)\n((?:~~~\n(?:.*?\n)?~~~\n?)+)~{6}/m
      alternative_regex = /^:::wa-carousel\s*([^\n]*)\n((?:~~~\n(?:.*?\n)?~~~\n?)+):::/m

      # Define shared transformation logic
      transform_proc = proc do |params, slides_block, _third_capture|
        parsed_params = parse_params(params)
        slides = extract_slides(slides_block)

        build_carousel_html(slides, parsed_params)
      end

      # Apply both patterns
      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def parse_params(params)
        return {} if params.nil? || params.strip.empty?

        result = {
          attributes: {},
          css_vars: {}
        }

        # Parse boolean flags using AttributeParser
        attributes = AttributeParser.parse(params, COMPONENT_ATTRIBUTES)

        # Convert boolean attributes to result format
        attributes.each_key do |key|
          if key == :vertical
            result[:attributes]['orientation'] = 'vertical'
          else
            result[:attributes][key.to_s] = true
          end
        end

        # Parse numeric and key:value tokens manually
        tokens = params.strip.split(/\s+/)
        numeric_count = 0

        tokens.each do |token|
          # Check for key:value pairs (attributes and CSS custom properties)
          if token.include?(':')
            key, value = token.split(':', 2)
            case key
            when 'autoplay-interval'
              result[:attributes]['autoplay-interval'] = value
            when 'scroll-hint'
              result[:css_vars]['--scroll-hint'] = value
            when 'aspect-ratio'
              # Support 'auto', 'none', or 'unset' to remove the default aspect ratio
              # This is useful for text content or variable-height slides
              result[:css_vars]['--aspect-ratio'] = value
            when 'slide-gap'
              result[:css_vars]['--slide-gap'] = value
            end
          # Check for numeric values
          elsif token.match?(/^\d+$/)
            numeric_count += 1
            if numeric_count == 1
              result[:attributes]['slides-per-page'] = token
            elsif numeric_count == 2
              result[:attributes]['slides-per-move'] = token
            end
          end
        end

        result
      end

      def extract_slides(slides_block)
        # Extract individual slides using ~~~ markers
        # Handle both content and empty slides
        slide_contents = slides_block.scan(/~~~\n(.*?)~~~(?:\n|$)/m)
        slide_contents.map { |match| match[0].strip }
      end

      def build_carousel_html(slides, parsed_params)
        attributes = build_attributes(parsed_params[:attributes] || {})
        style = build_style(parsed_params[:css_vars] || {})

        attr_string = attributes.empty? ? '' : " #{attributes.join(' ')}"
        style_string = style.empty? ? '' : " style=\"#{style}\""

        slide_items = slides.map do |slide_content|
          slide_html = markdown_to_html(slide_content)
          "<wa-carousel-item>#{slide_html}</wa-carousel-item>"
        end

        "<wa-carousel#{attr_string}#{style_string}>#{slide_items.join}</wa-carousel>"
      end

      def build_attributes(attrs)
        return [] if attrs.nil? || attrs.empty?

        attrs.map do |key, value|
          if value == true
            key
          else
            "#{key}=\"#{value}\""
          end
        end
      end

      def build_style(css_vars)
        return '' if css_vars.nil? || css_vars.empty?

        css_vars.map { |key, value| "#{key}: #{value}" }.join('; ')
      end
    end
  end
end
