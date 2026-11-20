# frozen_string_literal: true

require_relative 'base_transformer'

module Markawesome
  # Transforms a number in the `[[[ … ]]]` syntax into a <wa-number-ticker>,
  # which counts up to the value when it scrolls into view and formats it with
  # Intl.NumberFormat.
  #
  # Inline (primary):    [[[ <number> <tokens> ]]]
  #   Raised [[[ 18452.75 currency:EUR ]]] so far
  #   [[[ 87% ]]] satisfaction
  #   [[[ 12000 from:10000 duration:1500 ]]] users
  # Block (alternative): :::wa-number-ticker <number> <tokens>
  #                      followed by a closing ::: (empty body)
  #
  # The first token must be a number (-?digits, optional .digits, optional %).
  # An ISO date never matches, so dates still reach DateTransformer, which runs
  # right after this transformer.
  #
  # `87%` means type="percent" value="0.87": the decimal point is shifted two
  # places textually (no floats). A bare number plus a `percent` token is
  # type="percent" with the value as written.
  #
  # Tokens (later tokens win):
  #   currency:XXX     -> type="currency" currency="XXX" (3 letters, upcased)
  #   percent, decimal -> type
  #   display:VALUE    -> currency-display (symbol narrowSymbol code name)
  #   from:N           -> start-value
  #   duration:MS, delay:MS -> integers
  #   easing:VALUE     -> any CSS easing (quote it when it has spaces)
  #   eager            -> eager
  #   no-grouping      -> without-grouping
  #   decimals:N       -> minimum- and maximum-fraction-digits (0–100)
  #   lang:/locale:    -> lang
  #
  # Static-site caveat: the number renders into shadow DOM; without Web
  # Awesome's JS nothing shows — same as <wa-format-date>.
  class NumberTickerTransformer < BaseTransformer
    TICKER_TYPES = %w[currency decimal percent].freeze
    CURRENCY_DISPLAYS = %w[symbol narrowSymbol code name].freeze

    NUMBER = '-?\d+(?:\.\d+)?%?'
    INLINE_REGEX = /\[\[\[[ \t]*(#{NUMBER})(?:[ \t]+([^\]\r\n]*?))?[ \t]*\]\]\]/
    ALTERNATIVE_REGEX = /^:::wa-number-ticker[ \t]+(#{NUMBER})(?:[ \t]+([^\n]*?))?[ \t]*\n:::$/

    PLAIN_NUMBER_REGEX = /\A-?\d+(?:\.\d+)?\z/
    INTEGER_REGEX = /\A\d+\z/

    # Deterministic emission order (required for byte-for-byte parity).
    ORDER = %w[value start-value duration delay easing eager type without-grouping currency
               currency-display minimum-fraction-digits maximum-fraction-digits lang].freeze

    def self.transform(content)
      patterns = [INLINE_REGEX, ALTERNATIVE_REGEX].map do |regex|
        { regex: regex, block: proc { |_m, md| build_ticker(md[1], md[2]) } }
      end
      apply_multiple_patterns(content, patterns)
    end

    # Plain-Markdown degrade: the number as written, plus the currency code.
    def self.render_as_markdown(content, _options = {})
      patterns = [INLINE_REGEX, ALTERNATIVE_REGEX].map do |regex|
        { regex: regex, block: proc { |_m, md| plain_number(md[1], md[2]) } }
      end
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def build_ticker(number, token_string)
        attrs = {}
        if number.end_with?('%')
          attrs['value'] = shift_percent(number.chomp('%'))
          attrs['type'] = 'percent'
        else
          attrs['value'] = number
        end
        quoted_tokens(token_string).each { |token| apply_token(token, attrs) }
        attrs.delete('type') if attrs['type'] == 'decimal'

        parts = ORDER.filter_map do |key|
          next unless attrs.include?(key)

          attrs[key] == true ? key : "#{key}=\"#{escape_html(attrs[key])}\""
        end
        "<wa-number-ticker #{parts.join(' ')}></wa-number-ticker>"
      end

      def apply_token(token, attrs)
        case token
        when 'eager' then attrs['eager'] = true
        when 'no-grouping' then attrs['without-grouping'] = true
        when 'percent', 'decimal' then attrs['type'] = token
        else
          m = token.match(/\A([a-z-]+):(.+)\z/)
          apply_option(m[1], unquote(m[2]), attrs) if m
        end
      end

      def apply_option(key, value, attrs)
        case key
        when 'currency'
          if value.match?(/\A[A-Za-z]{3}\z/)
            attrs['currency'] = value.upcase
            attrs['type'] = 'currency'
          end
        when 'display' then attrs['currency-display'] = value if CURRENCY_DISPLAYS.include?(value)
        when 'from' then attrs['start-value'] = value if value.match?(PLAIN_NUMBER_REGEX)
        when 'duration', 'delay' then attrs[key] = value if value.match?(INTEGER_REGEX)
        when 'easing' then attrs['easing'] = value
        when 'decimals' then apply_decimals(value, attrs)
        when 'lang', 'locale' then attrs['lang'] = value
        end
      end

      def apply_decimals(value, attrs)
        return unless value.match?(INTEGER_REGEX) && value.to_i <= 100

        attrs['minimum-fraction-digits'] = attrs['maximum-fraction-digits'] = value.to_i.to_s
      end

      # Divide a decimal string by 100 by moving the point two places left,
      # textually: "87" -> "0.87", "12.5" -> "0.125", "150" -> "1.5", "5" -> "0.05".
      def shift_percent(number)
        negative = number.start_with?('-')
        int_part, frac_part = number.delete_prefix('-').split('.', 2)
        digits = "#{int_part}#{frac_part}"
        point = int_part.length - 2
        if point < 1
          digits = ('0' * (1 - point)) + digits
          point = 1
        end
        whole = digits[0...point].sub(/\A0+(?=\d)/, '')
        fraction = digits[point..].sub(/0+\z/, '')
        result = fraction.empty? ? whole : "#{whole}.#{fraction}"
        negative && result != '0' ? "-#{result}" : result
      end

      def plain_number(number, token_string)
        currency = nil
        quoted_tokens(token_string).each do |token|
          m = token.match(/\Acurrency:([A-Za-z]{3})\z/)
          currency = m[1].upcase if m
        end
        currency ? "#{number} #{currency}" : number
      end

      def escape_html(text)
        text.to_s
            .gsub('&', '&amp;')
            .gsub('<', '&lt;')
            .gsub('>', '&gt;')
            .gsub('"', '&quot;')
            .gsub("'", '&#39;')
      end
    end
  end
end
