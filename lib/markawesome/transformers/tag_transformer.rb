# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'
require_relative '../icon_slot_parser'

module Markawesome
  # Transforms tag syntax into wa-tag elements
  # Primary syntax: @@@params?\ncontent\n@@@
  # Inline syntax: @@@ params? content @@@
  # Alternative syntax: :::wa-tag params?\ncontent\n:::
  #
  # Supported attributes:
  # - variant: brand, success, neutral, warning, danger
  # - appearance: accent, filled, outlined, filled-outlined
  # - size: small, medium, large
  # - pill: boolean (rounded edges)
  # - with-remove: boolean (removable tag with remove button)
  class TagTransformer < BaseTransformer
    # Component attributes configuration for AttributeParser
    COMPONENT_ATTRIBUTES = {
      variant: %w[brand success neutral warning danger],
      appearance: %w[accent filled outlined filled-outlined],
      size: %w[small medium large],
      pill: %w[pill],
      'with-remove': %w[with-remove]
    }.freeze

    ICON_SLOTS = { default: 'content', slots: %w[content] }.freeze

    def self.transform(content)
      # Define regex patterns
      # Block syntax (multiline with newlines) - supports both LF and CRLF
      # Capture optional parameters and content
      primary_regex = /^@@@([^\r\n]*?)\r?\n(.*?)\r?\n@@@/m
      alternative_regex = /^:::wa-tag\s*([^\r\n]*?)\r?\n(.*?)\r?\n:::/m

      # Inline syntax (same line with spaces)
      # Match the whole content between @@@ delimiters on a single line
      # Use horizontal whitespace only (\h = spaces/tabs, not newlines)
      inline_regex = /@@@\h*([^@\r\n]+?)\h*@@@/

      # Define shared transformation logic
      transform_proc = proc do |params, tag_content|
        tag_content = tag_content.strip

        build_tag_html(tag_content, params)
      end

      # Inline transformation - split params from content
      inline_transform_proc = proc do |full_content|
        full_content = full_content.strip
        tokens = full_content.split(/\s+/)
        params_tokens = []
        content_tokens = []

        # Separate attribute and icon tokens from content tokens
        tokens.each do |token|
          matched = COMPONENT_ATTRIBUTES.any? { |_attr, values| values.include?(token) }
          if matched || token.start_with?('icon:')
            params_tokens << token
          else
            content_tokens << token
          end
        end

        # Build params and content strings
        params = params_tokens.join(' ')
        tag_content = content_tokens.any? ? content_tokens.join(' ') : full_content

        build_tag_html(tag_content, params)
      end

      # Apply all patterns (inline first to avoid conflicts)
      patterns = [
        {
          regex: inline_regex,
          block: proc do |_match, matchdata|
            inline_transform_proc.call(matchdata[1])
          end
        },
        *dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      ]
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def build_tag_html(content, params)
        # Parse icon tokens first, then pass remaining to AttributeParser
        icon_result = IconSlotParser.parse(params, ICON_SLOTS)
        attributes = AttributeParser.parse(icon_result[:remaining], COMPONENT_ATTRIBUTES)

        # Build HTML attributes
        html_attrs = []
        html_attrs << "variant=\"#{attributes[:variant]}\"" if attributes[:variant]
        html_attrs << "appearance=\"#{attributes[:appearance]}\"" if attributes[:appearance]
        html_attrs << "size=\"#{attributes[:size]}\"" if attributes[:size]
        html_attrs << 'pill' if attributes[:pill]
        html_attrs << 'with-remove' if attributes[:'with-remove']

        attrs_string = html_attrs.empty? ? '' : " #{html_attrs.join(' ')}"
        icon_html = IconSlotParser.to_html(icon_result[:icons])

        tag_html = markdown_to_html(content).strip

        # Remove paragraph tags if the content is just text
        tag_html = tag_html.gsub(%r{^<p>(.*)</p>$}m, '\1')

        "<wa-tag#{attrs_string}>#{icon_html}#{tag_html}</wa-tag>"
      end
    end
  end
end
