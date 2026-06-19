# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'
require_relative '../icon_attributes'

module Markawesome
  # Transforms icon syntax into wa-icon elements
  # Primary syntax: $$$icon-name (name only, decorative)
  # Alternative syntax: :::wa-icon icon-name [family] [variant] [animation]\n[label]\n:::
  #
  # Examples:
  # $$$settings -> <wa-icon name="settings"></wa-icon>
  # $$$home -> <wa-icon name="home"></wa-icon>
  # $$$user-circle -> <wa-icon name="user-circle"></wa-icon>
  # :::wa-icon star spin\n::: -> <wa-icon name="star" animation="spin"></wa-icon>
  # :::wa-icon heart solid\nFavorite\n::: ->
  #   <wa-icon name="heart" variant="solid" label="Favorite"></wa-icon>
  class IconTransformer < BaseTransformer
    # First-line params + optional multi-line body. The closer is anchored to a line
    # start; the opener is intentionally not anchored so it still matches mid-prose.
    ALTERNATIVE_REGEX = /:::wa-icon[ \t]+([^\n]*?)[ \t]*\n(.*?)^:::/m
    def self.transform(content)
      # Protect code blocks first
      protected_content, code_blocks = protect_code_blocks(content)

      # Apply primary syntax transformation
      # Only block patterns that look like incomplete icon names:
      # $$$icon name (where 'icon name' could be intended as one identifier)
      result = protected_content.gsub(/\$\$\$([a-zA-Z0-9\-_]+)(?![a-zA-Z0-9\-_]|\s+name\b)/) do
        icon_name = ::Regexp.last_match(1)
        build_icon_html(icon_name)
      end

      # Apply alternative syntax transformation
      result = result.gsub(ALTERNATIVE_REGEX) do
        first_line = ::Regexp.last_match(1)
        raw_body   = ::Regexp.last_match(2)

        tokens     = first_line.strip.split(/\s+/)
        icon_name  = tokens.shift # first token is always the name
        attributes = AttributeParser.parse(tokens.join(' '), IconAttributes::SCHEMA)
        label      = normalize_label(raw_body)

        build_icon_html(icon_name, attributes, label)
      end

      # Restore code blocks
      restore_code_blocks(result, code_blocks)
    end

    def self.render_as_markdown(content, _options = {})
      protected_content, code_blocks = protect_code_blocks(content)

      # Drop primary-syntax icons entirely.
      result = protected_content.gsub(/\$\$\$([a-zA-Z0-9\-_]+)(?![a-zA-Z0-9\-_]|\s+name\b)/, '')

      # A labeled block degrades to its label text (collapsed, not HTML-escaped — it
      # re-enters a markdown stream); an unlabeled block degrades to ''.
      result = result.gsub(ALTERNATIVE_REGEX) do
        ::Regexp.last_match(2).to_s.strip.gsub(/\s+/, ' ')
      end

      restore_code_blocks(result, code_blocks)
    end

    class << self
      private

      def build_icon_html(icon_name, attributes = {}, label = nil)
        parts = ["name=\"#{icon_name.strip}\""]
        parts.concat(IconAttributes.pairs(attributes))
        parts << "label=\"#{label}\"" if label && !label.empty?
        "<wa-icon #{parts.join(' ')}></wa-icon>"
      end

      # Label is an attribute VALUE, not markup: strip, collapse whitespace, HTML-escape.
      # Deliberately NOT run through markdown_to_html (unlike button/callout bodies).
      def normalize_label(raw_body)
        text = raw_body.to_s.strip.gsub(/\s+/, ' ')
        text.empty? ? nil : escape_html(text)
      end

      # Same escape set as Dialog/Popover transformers.
      def escape_html(text)
        text.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
            .gsub('"', '&quot;').gsub("'", '&#39;')
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
