# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms card syntax into wa-card elements
  # Primary syntax: ===params?\ncontent\n===
  # Alternative syntax: :::wa-card params?\ncontent\n:::
  # Supported attributes:
  #   appearance: outlined (default), filled, filled-outlined, plain, accent
  #   orientation: vertical (default), horizontal
  # Card header: first **bold** line (not a heading) becomes the header slot
  class CardTransformer < BaseTransformer
    CARD_ATTRIBUTES = {
      appearance: %w[outlined filled filled-outlined plain accent],
      orientation: %w[vertical horizontal]
    }.freeze

    def self.transform(content)
      # Define both regex patterns - capture any params
      primary_regex = /^===([^\n]*)\n(.*?)\n===/m
      alternative_regex = /^:::wa-card\s*([^\n]*)\n(.*?)\n:::/m

      # Define shared transformation logic
      transform_proc = proc do |params_string, card_content|
        card_content = card_content.strip

        attributes = AttributeParser.parse(params_string, CARD_ATTRIBUTES)
        card_parts = parse_card_content(card_content)

        build_card_html(card_parts, attributes)
      end

      # Apply both patterns
      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def parse_card_content(content)
        parts = {
          media: nil,
          header: nil,
          content: content,
          footer: nil
        }

        # Extract first image as media
        if content.match(/^!\[([^\]]*)\]\(([^)]+)\)/)
          parts[:media] = {
            alt: ::Regexp.last_match(1),
            src: ::Regexp.last_match(2)
          }
          # Remove the image from content
          content = content.sub(/^!\[([^\]]*)\]\(([^)]+)\)\n?/, '')
        end

        # Extract first bold line as header
        if content.match(/^\*\*(.+)\*\*$/)
          parts[:header] = ::Regexp.last_match(1).strip
          # Remove the bold line from content
          content = content.sub(/^\*\*(.+)\*\*\n?/, '')
        end

        # Extract trailing buttons/links as footer
        # Look for links or buttons at the end of the content
        if content.match(/\n\[([^\]]+)\]\(([^)]+)\)\s*$/)
          parts[:footer] = {
            text: ::Regexp.last_match(1),
            href: ::Regexp.last_match(2)
          }
          # Remove the footer link from content
          content = content.sub(/\n\[([^\]]+)\]\(([^)]+)\)\s*$/, '')
        end

        # Update the main content after extractions
        parts[:content] = content.strip
        parts
      end

      def build_card_html(parts, attributes)
        # Extract appearance and orientation from attributes
        appearance = attributes[:appearance] || 'outlined'
        orientation = attributes[:orientation] || 'vertical'

        html_attrs = []
        html_attrs << "appearance=\"#{appearance}\"" if appearance != 'outlined'
        html_attrs << "orientation=\"#{orientation}\"" if orientation != 'vertical'

        # Add SSR attributes if slots are present
        html_attrs << 'with-media' if parts[:media]
        html_attrs << 'with-header' if parts[:header]
        html_attrs << 'with-footer' if parts[:footer]

        attr_string = html_attrs.empty? ? '' : " #{html_attrs.join(' ')}"

        html_parts = []

        # Media slot
        if parts[:media]
          html_parts << "<img slot=\"media\" src=\"#{parts[:media][:src]}\" alt=\"#{parts[:media][:alt]}\">"
        end

        # Header slot
        if parts[:header]
          header_html = markdown_to_html(parts[:header])
          html_parts << "<div slot=\"header\">#{header_html}</div>"
        end

        # Main content
        if parts[:content] && !parts[:content].empty?
          content_html = markdown_to_html(parts[:content])
          html_parts << content_html
        end

        # Footer slot
        if parts[:footer]
          html_parts << "<div slot=\"footer\"><wa-button href=\"#{parts[:footer][:href]}\">#{parts[:footer][:text]}</wa-button></div>"
        end

        "<wa-card#{attr_string}>#{html_parts.join}</wa-card>"
      end
    end
  end
end
