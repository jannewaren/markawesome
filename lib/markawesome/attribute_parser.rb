# frozen_string_literal: true

module Markawesome
  # Parses space-separated attributes from a parameter string
  # Supports multiple values per attribute with rightmost-wins semantics
  # Useful for flexible syntax like "pill pulse brand" where order doesn't matter
  class AttributeParser
    # Parse space-separated parameters into an attribute hash
    # @param params_string [String] Space-separated parameter string
    # @param attribute_schema [Hash] Schema defining attributes and allowed values
    #   Example: { variant: %w[brand success], pill: [true], attention: %w[pulse bounce] }
    # @return [Hash] Parsed attributes with resolved values
    def self.parse(params_string, attribute_schema)
      return {} if params_string.nil? || params_string.strip.empty?

      parsed = {}
      tokens = params_string.strip.split(/\s+/)

      tokens.each do |token|
        attribute_schema.each do |attr_name, allowed_values|
          next unless allowed_values.include?(token)

          # Rightmost-wins: latest value for this attribute wins
          parsed[attr_name] = token
          break # Move to next token once we've matched it
        end
        # Tokens that don't match any attribute are silently ignored
      end

      parsed
    end

    # Check if a token is valid for an attribute
    # @param token [String] The token to check
    # @param allowed_values [Array] Allowed values for the attribute
    # @return [Boolean] True if token is in allowed values
    def self.valid_token?(token, allowed_values)
      allowed_values.include?(token)
    end
  end
end
