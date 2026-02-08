# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms copy button syntax into wa-copy-button elements
  # Primary syntax: <<<params?\ncontent\n<<<
  # Alternative syntax: :::wa-copy-button params?\ncontent\n:::
  #
  # Params: space-separated tokens, any order (rightmost-wins for conflicts)
  # Placement: top, right, bottom, left
  # Duration: numeric value (feedback-duration in milliseconds)
  # Flags: disabled
  # Labels: copy-label="text", success-label="text", error-label="text"
  # From: from="element-id" (copy from another element)
  #
  # Usage:
  # <<<
  # This text will be copied to clipboard
  # <<<
  #
  # <<<disabled top 2000
  # Disabled copy button with top tooltip and 2s feedback
  # <<<
  #
  # <<<copy-label="Click to copy" success-label="Copied!"
  # Custom labels
  # <<<
  #
  # :::wa-copy-button right from="my-element"
  # Copy from element with ID "my-element"
  # :::
  class CopyButtonTransformer < BaseTransformer
    COPY_BUTTON_ATTRIBUTES = {
      placement: %w[top right bottom left],
      disabled: %w[disabled]
    }.freeze

    def self.transform(content)
      # Define both regex patterns - capture params as a single string
      primary_regex = /^<<<(.*?)\n(.*?)\n<<</m
      alternative_regex = /^:::wa-copy-button\s*(.*?)\n(.*?)\n:::/m

      # Define shared transformation logic
      transform_proc = proc do |params_string, copy_content|
        copy_content = copy_content.strip

        # Parse space-separated parameters
        attributes = AttributeParser.parse(params_string, COPY_BUTTON_ATTRIBUTES)

        # Extract quoted labels and from attribute
        attributes[:copy_label] = extract_quoted_attribute(params_string, 'copy-label')
        attributes[:success_label] = extract_quoted_attribute(params_string, 'success-label')
        attributes[:error_label] = extract_quoted_attribute(params_string, 'error-label')
        attributes[:from] = extract_quoted_attribute(params_string, 'from')

        # Extract numeric feedback-duration
        attributes[:feedback_duration] = ::Regexp.last_match(1) if params_string =~ /\b(\d+)\b/

        build_copy_button_html(copy_content, attributes)
      end

      # Apply both patterns
      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def build_copy_button_html(content, attributes)
        # Escape the content for the value attribute
        escaped_content = content.gsub('"', '&quot;').gsub("'", '&#39;')

        # Build HTML attributes
        attr_parts = []

        # Add value or from attribute
        attr_parts << if attributes[:from]
                        "from=\"#{attributes[:from]}\""
                      else
                        "value=\"#{escaped_content}\""
                      end

        # Add tooltip placement
        attr_parts << "tooltip-placement=\"#{attributes[:placement]}\"" if attributes[:placement]

        # Add custom labels
        attr_parts << "copy-label=\"#{attributes[:copy_label]}\"" if attributes[:copy_label]
        attr_parts << "success-label=\"#{attributes[:success_label]}\"" if attributes[:success_label]
        attr_parts << "error-label=\"#{attributes[:error_label]}\"" if attributes[:error_label]

        # Add feedback duration
        attr_parts << "feedback-duration=\"#{attributes[:feedback_duration]}\"" if attributes[:feedback_duration]

        # Add disabled flag
        attr_parts << 'disabled' if attributes[:disabled]

        attrs_string = attr_parts.join(' ')

        "<wa-copy-button #{attrs_string}></wa-copy-button>"
      end

      def extract_quoted_attribute(params_string, attr_name)
        # Match attr-name="value" or attr-name='value'
        return unless params_string =~ /#{Regexp.escape(attr_name)}=["']([^"']+)["']/

        ::Regexp.last_match(1)
      end
    end
  end
end
