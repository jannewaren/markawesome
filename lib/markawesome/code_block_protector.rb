# frozen_string_literal: true

module Markawesome
  # Replaces fenced code blocks with opaque placeholders so that Markawesome's
  # component regexes (`:::`, `^^^`, `@@@`, etc.) cannot match syntax that
  # appears inside example code. Callers are responsible for restoring the
  # blocks after their transformations run.
  #
  # Usage:
  #   content, tokens = Markawesome::CodeBlockProtector.protect(content)
  #   content = some_transformer.transform(content)
  #   content = Markawesome::CodeBlockProtector.restore(content, tokens)
  #
  # The helper is stateless: each call allocates its own token map, so it is
  # safe to use concurrently or nested. The token format is a stable HTML
  # comment so that it survives markdown conversion intact.
  module CodeBlockProtector
    CODE_BLOCK_PATTERN = /```([a-zA-Z0-9.+#_-]+)?(\n.*?)```/m
    PLACEHOLDER_PREFIX = '<!--MARKAWESOME_PROTECTED_CODE_BLOCK_'
    PLACEHOLDER_SUFFIX = '-->'

    module_function

    # Replace every fenced code block with a placeholder.
    # @param content [String]
    # @return [Array(String, Hash)] Protected content and placeholder→block map.
    def protect(content)
      tokens = {}
      counter = 0

      protected_content = content.gsub(CODE_BLOCK_PATTERN) do |match|
        placeholder = "#{PLACEHOLDER_PREFIX}#{counter}#{PLACEHOLDER_SUFFIX}"
        tokens[placeholder] = match
        counter += 1
        placeholder
      end

      [protected_content, tokens]
    end

    # Restore placeholders created by {protect}.
    # @param content [String]
    # @param tokens [Hash]
    # @return [String]
    def restore(content, tokens)
      return content if tokens.nil? || tokens.empty?

      tokens.each do |placeholder, original|
        content = content.gsub(placeholder, original)
      end
      content
    end
  end
end
