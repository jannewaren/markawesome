# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms icon syntax into wa-icon elements
  # Primary syntax: $$$icon-name or $$$icon-name[params]
  # Alternative syntax: :::wa-icon icon-name params?
  #
  # Examples:
  # $$$settings -> <wa-icon name="settings"></wa-icon>
  # $$$home -> <wa-icon name="home"></wa-icon>
  # $$$spinner[animation:spin] -> <wa-icon name="spinner" animation="spin"></wa-icon>
  # $$$brands/twitter -> <wa-icon name="twitter" family="brands"></wa-icon>
  #
  # Supported attributes:
  # - family: classic, brands, sharp, duotone, sharp-duotone
  # - variant: thin, light, regular, solid
  # - rotate: 90, 180, 270
  # - flip: x, y, both
  # - animation: beat, flip, bounce, shake, spin, spin-pulse, spin-reverse
  # - label: accessible label string (label:"text")
  class IconTransformer < BaseTransformer
    ICON_ATTRIBUTES = {
      family: %w[classic brands sharp duotone sharp-duotone],
      variant: %w[thin light regular solid],
      rotate: %w[90 180 270],
      flip: %w[x y both],
      animation: %w[beat flip bounce shake spin spin-pulse spin-reverse]
    }.freeze

    def self.transform(content)
      # Protect code blocks first
      protected_content, code_blocks = protect_code_blocks(content)

      # Apply extended inline syntax: $$$icon-name[params]
      result = protected_content.gsub(/\$\$\$([a-zA-Z0-9\-_]+)\[([^\]]*)\]/) do
        icon_name = ::Regexp.last_match(1)
        params_string = ::Regexp.last_match(2)
        build_icon_html(icon_name, params_string)
      end

      # Apply primary syntax transformation (simple, no params)
      result = result.gsub(/\$\$\$([a-zA-Z0-9\-_]+)(?![a-zA-Z0-9\-_\[]|\s+name\b)/) do
        icon_name = ::Regexp.last_match(1)
        build_icon_html(icon_name)
      end

      # Apply alternative syntax transformation with optional params
      result = result.gsub(/:::wa-icon\s+([a-zA-Z0-9\-_]+)([^\n]*)\n:::/m) do
        icon_name = ::Regexp.last_match(1)
        params_string = ::Regexp.last_match(2).strip
        build_icon_html(icon_name, params_string)
      end

      # Restore code blocks
      restore_code_blocks(result, code_blocks)
    end

    class << self
      private

      def build_icon_html(icon_name, params_string = nil)
        clean_name = icon_name.strip

        attrs = ["name=\"#{clean_name}\""]

        if params_string && !params_string.empty?
          parsed = parse_icon_params(params_string)

          attrs << "family=\"#{parsed[:family]}\"" if parsed[:family]
          attrs << "variant=\"#{parsed[:variant]}\"" if parsed[:variant]
          attrs << "rotate=\"#{parsed[:rotate]}\"" if parsed[:rotate]
          attrs << "flip=\"#{parsed[:flip]}\"" if parsed[:flip]
          attrs << "animation=\"#{parsed[:animation]}\"" if parsed[:animation]
          attrs << "label=\"#{parsed[:label]}\"" if parsed[:label]
        end

        "<wa-icon #{attrs.join(' ')}></wa-icon>"
      end

      # Parse key:value pairs and bare tokens from icon params
      def parse_icon_params(params_string)
        parsed = {}

        # Extract label:"..." or label:'...' first
        remaining = params_string.gsub(/label:"([^"]*)"/) do
          parsed[:label] = ::Regexp.last_match(1)
          ''
        end
        remaining = remaining.gsub(/label:'([^']*)'/) do
          parsed[:label] = ::Regexp.last_match(1)
          ''
        end

        # Parse key:value tokens
        remaining.strip.split(/\s+/).each do |token|
          if token.include?(':')
            key, value = token.split(':', 2)
            sym = key.to_sym
            if ICON_ATTRIBUTES.key?(sym) && ICON_ATTRIBUTES[sym].include?(value)
              parsed[sym] = value
            end
          else
            # Bare token - check against all attribute values
            ICON_ATTRIBUTES.each do |attr_name, allowed_values|
              if allowed_values.include?(token)
                parsed[attr_name] = token
                break
              end
            end
          end
        end

        parsed
      end

      def protect_code_blocks(content)
        code_blocks = {}
        counter = 0

        # Protect fenced code blocks
        protected = content.gsub(/```.*?```/m) do |match|
          placeholder = "<!--ICON_PROTECTED_CODE_BLOCK_#{counter}-->"
          code_blocks[placeholder] = match
          counter += 1
          placeholder
        end

        # Protect inline code
        protected = protected.gsub(/`[^`]+`/) do |match|
          placeholder = "<!--ICON_PROTECTED_INLINE_CODE_#{counter}-->"
          code_blocks[placeholder] = match
          counter += 1
          placeholder
        end

        [protected, code_blocks]
      end

      def restore_code_blocks(content, code_blocks)
        result = content
        code_blocks.each do |placeholder, original|
          result = result.gsub(placeholder, original)
        end
        result
      end
    end
  end
end
