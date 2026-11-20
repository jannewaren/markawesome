# frozen_string_literal: true

require_relative 'quoted_tokens'

module Markawesome
  # <wa-counter> option vocabulary and attribute builder, used by
  # DateTransformer's counter mode (`[[[ <date> countdown|countup … ]]]` and
  # `:::wa-counter`).
  #
  # Tokens (later tokens win):
  #   countdown/down, countup/up -> direction (down is the default, never emitted)
  #   largest:UNIT, smallest:UNIT -> largest-unit / smallest-unit (invalid dropped)
  #   format:short|narrow        -> format (long is the default, never emitted)
  #   no-labels                  -> without-labels
  #   delimiter:"…", label:"…"   -> delimiter / label
  #   lang:/locale:              -> lang
  #   finished:"…"               -> <span slot="finished">…</span>
  module CounterAttributes
    DIRECTIONS = %w[down up].freeze
    FORMATS = %w[long short narrow].freeze
    UNITS = %w[years months days hours minutes seconds].freeze

    # Deterministic emission order (required for byte-for-byte parity).
    ORDER = %w[date direction largest-unit smallest-unit format without-labels
               delimiter label lang].freeze

    module_function

    # @return [Array(Array<String>, String)] [attribute parts, inner HTML]
    def build(date, tokens)
      attrs, finished = parse(tokens)
      attrs['date'] = date if date

      parts = ORDER.filter_map do |key|
        next unless attrs.include?(key)

        attrs[key] == true ? key : "#{key}=\"#{escape_html(attrs[key])}\""
      end
      inner = finished ? "<span slot=\"finished\">#{escape_html(finished)}</span>" : ''
      [parts, inner]
    end

    # @return [Array(Hash, String|nil)] [attrs, finished text]
    def parse(tokens)
      attrs = {}
      finished = nil
      tokens.each do |token|
        case token
        when 'up', 'countup' then attrs['direction'] = 'up'
        when 'down', 'countdown' then attrs.delete('direction')
        when 'no-labels' then attrs['without-labels'] = true
        else
          next unless (m = token.match(/\A([a-z-]+):(.+)\z/))

          finished = apply_option(m[1], QuotedTokens.unquote(m[2]), attrs) || finished
        end
      end
      [attrs, finished]
    end

    # Applies one key:value option; returns the text for `finished`, else nil.
    def apply_option(key, value, attrs)
      case key
      when 'largest', 'smallest'
        attrs["#{key}-unit"] = value if UNITS.include?(value)
      when 'format'
        if FORMATS.include?(value)
          value == 'long' ? attrs.delete('format') : attrs['format'] = value
        end
      when 'delimiter', 'label' then attrs[key] = value
      when 'lang', 'locale' then attrs['lang'] = value
      when 'finished' then return value
      end
      nil
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
