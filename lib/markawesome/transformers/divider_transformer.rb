# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'
require_relative '../icon_slot_parser'

module Markawesome
  # Transforms labeled-divider syntax into <wa-divider> elements with a label in
  # the default slot (Web Awesome 3.13.0+).
  #
  # Primary syntax (one line, mirrored dashes):
  #   --- or ---
  #   --- start Release notes ---
  #   --- end icon:star New ---
  #   --- icon:quote-left ---
  #   --- vertical vs ---
  # Alternative syntax (the body is the label, and may be empty):
  #   :::wa-divider start icon:star
  #   Release **notes**
  #   :::
  #
  # Leading tokens (consumed from the left until the first non-token word):
  #   - start, center, end      -> label-placement
  #   - horizontal, vertical    -> orientation
  #   - icon:name               -> <wa-icon name="name"> before the label
  # The rest of the line is the label, rendered as inline Markdown. To start a
  # label with one of those words, use the alternative syntax.
  #
  # A plain `---` (and `--- ---`) is left alone and stays an <hr>. So is a line
  # made only of `|`, `:`, `-` and whitespace (e.g. a pipe-less GFM table
  # separator such as `--- | ---`).
  class DividerTransformer < BaseTransformer
    DIVIDER_ATTRIBUTES = {
      orientation: %w[horizontal vertical],
      label_placement: %w[start center end]
    }.freeze

    # Content slot: emits <wa-icon name="..."> with no slot attribute.
    ICON_SLOTS = {
      default: 'content',
      slots: %w[content],
      slot_map: { 'content' => 'content' }
    }.freeze

    PRIMARY_REGEX = /^---[ \t]+(\S[^\n]*?)[ \t]+---[ \t]*$/
    ALTERNATIVE_REGEX = /^:::wa-divider[ \t]*([^\n]*)\n(?:(.*?)\n)?:::[ \t]*$/m
    TABLE_SEPARATOR_REGEX = /\A[|:\-\s]*\z/

    def self.transform(content)
      content = content.gsub(PRIMARY_REGEX) do |match|
        inner = Regexp.last_match(1)
        next match if inner.match?(TABLE_SEPARATOR_REGEX)

        lead, label = split_leading_tokens(inner)
        build_html(lead, label)
      end

      content.gsub(ALTERNATIVE_REGEX) do
        params_string = Regexp.last_match(1)
        body = Regexp.last_match(2).to_s
        build_html(params_string, body.strip)
      end
    end

    # Degrade to a thematic break followed by the label as its own paragraph
    # (icon dropped). The leading blank line stops `---` from turning a
    # preceding paragraph line into a setext heading.
    def self.render_as_markdown(content, _options = {})
      content = content.gsub(PRIMARY_REGEX) do |match|
        inner = Regexp.last_match(1)
        next match if inner.match?(TABLE_SEPARATOR_REGEX)

        _lead, label = split_leading_tokens(inner)
        markdown_break(label)
      end

      content.gsub(ALTERNATIVE_REGEX) do
        markdown_break(Regexp.last_match(2).to_s.strip)
      end
    end

    class << self
      private

      # Consume leading placement/orientation/icon tokens; the rest is the label.
      def split_leading_tokens(inner)
        tokens = inner.strip.split(/\s+/)
        lead = []
        lead << tokens.shift while tokens.any? && leading_token?(tokens.first)
        [lead.join(' '), tokens.join(' ')]
      end

      def leading_token?(token)
        token.start_with?('icon:') || DIVIDER_ATTRIBUTES.values.any? { |values| values.include?(token) }
      end

      def build_html(params_string, label)
        attributes = AttributeParser.parse(params_string, DIVIDER_ATTRIBUTES)
        icon_result = IconSlotParser.parse(params_string, ICON_SLOTS)

        attr_parts = []
        attr_parts << "orientation=\"#{attributes[:orientation]}\"" if attributes[:orientation]
        attr_parts << "label-placement=\"#{attributes[:label_placement]}\"" if attributes[:label_placement]
        attrs_string = attr_parts.empty? ? '' : " #{attr_parts.join(' ')}"

        icon_html = IconSlotParser.to_html(icon_result[:icons], ICON_SLOTS[:slot_map])
        label_html = render_inline(label)
        separator = !icon_html.empty? && !label_html.empty? ? ' ' : ''

        "<wa-divider#{attrs_string}>#{icon_html}#{separator}#{label_html}</wa-divider>"
      end

      # Inline Markdown: render, then drop the wrapping <p> (the badge idiom).
      def render_inline(text)
        return '' if text.empty?

        markdown_to_html(text).strip.sub(%r{\A<p>(.*)</p>\z}m, '\1')
      end

      def markdown_break(label)
        label.empty? ? "\n---" : "\n---\n\n#{label}\n"
      end
    end
  end
end
