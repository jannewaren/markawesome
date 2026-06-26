# frozen_string_literal: true

require_relative 'base_transformer'

module Markawesome
  # Transforms declarative timestamp syntax into Web Awesome's two timestamp
  # components:
  #   <wa-format-date>   — an absolute, locale-formatted date ("June 26, 2026")
  #   <wa-relative-time> — a relative phrase ("3 days ago"), optionally ticking
  #
  # These are pure declarative wrappers over the browser's Intl.DateTimeFormat /
  # Intl.RelativeTimeFormat: the date value is baked into the markup at build
  # time, with no data fetching. Great for blog dates, changelog stamps, and
  # "last updated".
  #
  # Inline (primary):    [[[ <date> <tokens> ]]]
  # Block (alternative): :::wa-format-date <date> <tokens>  /  :::wa-relative-time …
  #                      followed by a closing ::: (empty body)
  #
  # Mode: absolute (<wa-format-date>) is the default; a bare `relative` token in
  # the inline form switches to <wa-relative-time>. The block selector name
  # chooses the mode directly.
  #
  # Static-site caveat: both components render generated text into shadow DOM
  # with no light-DOM fallback — with Web Awesome's JS disabled they show
  # nothing. This is identical to <wa-icon> and the other generated-content
  # components we already emit, so it is consistent with our model.
  class DateTransformer < BaseTransformer
    # Inline: content excludes `]`, non-greedy, multiple-per-line, single-line.
    INLINE_REGEX = /\[\[\[[ \t]*([^\]\r\n]+?)[ \t]*\]\]\]/
    # Block: selector name picks the mode; an empty body, closed by `:::`.
    ALTERNATIVE_REGEX = /^:::wa-(format-date|relative-time)[ \t]*([^\n]*)\n:::$/

    # A token is the date when it is an ISO 8601 date or datetime (datetimes use
    # the `T` separator — a space would break whitespace tokenization).
    DATE_TOKEN_REGEX =
      /\A\d{4}-\d{2}-\d{2}(?:T\d{2}:\d{2}(?::\d{2})?(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?)?\z/

    # style:/time: presets expand to Web Awesome's granular date/time attributes.
    STYLE_PRESETS = {
      'short' => { 'month' => 'numeric', 'day' => 'numeric', 'year' => '2-digit' },
      'medium' => { 'month' => 'short', 'day' => 'numeric', 'year' => 'numeric' },
      'long' => { 'month' => 'long', 'day' => 'numeric', 'year' => 'numeric' },
      'full' => { 'weekday' => 'long', 'month' => 'long', 'day' => 'numeric', 'year' => 'numeric' }
    }.freeze

    TIME_PRESETS = {
      'short' => { 'hour' => 'numeric', 'minute' => 'numeric' },
      'medium' => { 'hour' => 'numeric', 'minute' => 'numeric', 'second' => 'numeric' },
      'long' => { 'hour' => 'numeric', 'minute' => 'numeric', 'second' => 'numeric', 'time-zone-name' => 'short' },
      'full' => { 'hour' => 'numeric', 'minute' => 'numeric', 'second' => 'numeric', 'time-zone-name' => 'long' }
    }.freeze

    # Granular key:value tokens that pass through to the same-named WA attribute,
    # validated against an allowed enum (invalid values dropped).
    GRANULAR_ENUMS = {
      'weekday' => %w[narrow short long],
      'era' => %w[narrow short long],
      'year' => %w[numeric 2-digit],
      'month' => %w[numeric 2-digit narrow short long],
      'day' => %w[numeric 2-digit],
      'hour' => %w[numeric 2-digit],
      'minute' => %w[numeric 2-digit],
      'second' => %w[numeric 2-digit],
      'hour-format' => %w[auto 12 24],
      'time-zone-name' => %w[short long]
    }.freeze

    # Granular keys that count as an explicit date/time field — their presence
    # (or a style:/time: preset) suppresses the style:long default.
    CONTENT_FIELDS = %w[weekday era year month day hour minute second time-zone-name].freeze

    # Deterministic emission order (required for byte-for-byte parity).
    FORMAT_DATE_ORDER = %w[date weekday era year month day hour minute second
                           time-zone-name time-zone hour-format lang].freeze

    RELATIVE_FORMATS = %w[long short narrow].freeze
    RELATIVE_NUMERICS = %w[auto always].freeze

    def self.transform(content)
      patterns = [
        { regex: INLINE_REGEX, block: proc { |_m, md| render_tokens(md[1], nil) } },
        { regex: ALTERNATIVE_REGEX,
          block: proc { |_m, md| render_tokens(md[2], md[1] == 'relative-time' ? :relative : :absolute) } }
      ]
      apply_multiple_patterns(content, patterns)
    end

    # Plain-markdown degradation: there is no locale formatting in plain text,
    # so each timestamp degrades to its raw date string (empty when omitted).
    def self.render_as_markdown(content, _options = {})
      patterns = [
        { regex: INLINE_REGEX, block: proc { |_m, md| extract_date(md[1]) } },
        { regex: ALTERNATIVE_REGEX, block: proc { |_m, md| extract_date(md[2]) } }
      ]
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def render_tokens(token_string, mode_override)
        tokens = token_string.to_s.strip.split(/\s+/)
        date, tokens = split_date(tokens)
        mode = mode_override || (tokens.include?('relative') ? :relative : :absolute)

        mode == :relative ? build_relative_time(date, tokens) : build_format_date(date, tokens)
      end

      # Pull the first date/datetime token out, leaving the option tokens.
      def split_date(tokens)
        index = tokens.index { |token| token.match?(DATE_TOKEN_REGEX) }
        return [nil, tokens] unless index

        [tokens[index], tokens[0...index] + tokens[(index + 1)..]]
      end

      def extract_date(token_string)
        tokens = token_string.to_s.strip.split(/\s+/)
        tokens.find { |token| token.match?(DATE_TOKEN_REGEX) }.to_s
      end

      def build_format_date(date, tokens)
        attrs = {}
        apply_presets(tokens, attrs)
        apply_granular(tokens, attrs)
        # A bare date (no style/time/granular field) defaults to style:long.
        attrs.merge!(STYLE_PRESETS['long']) if (attrs.keys & CONTENT_FIELDS).empty?
        attrs['date'] = date if date

        parts = FORMAT_DATE_ORDER.filter_map do |key|
          "#{key}=\"#{escape_html(attrs[key])}\"" if attrs.key?(key)
        end
        build_element('wa-format-date', parts)
      end

      # Apply the rightmost valid style: and time: presets.
      def apply_presets(tokens, attrs)
        style = nil
        time = nil
        tokens.each do |token|
          if (m = token.match(/\Astyle:(.+)\z/)) && STYLE_PRESETS.key?(m[1])
            style = m[1]
          elsif (m = token.match(/\Atime:(.+)\z/)) && TIME_PRESETS.key?(m[1])
            time = m[1]
          end
        end
        attrs.merge!(STYLE_PRESETS[style]) if style
        attrs.merge!(TIME_PRESETS[time]) if time
      end

      # Apply granular enum keys (override presets) and free-string modifiers
      # (time-zone, lang/locale). Later tokens win.
      def apply_granular(tokens, attrs)
        tokens.each do |token|
          next unless (m = token.match(/\A([a-z-]+):(.+)\z/))

          key = m[1]
          value = m[2]
          if GRANULAR_ENUMS[key]&.include?(value)
            attrs[key] = value
          elsif key == 'time-zone'
            attrs['time-zone'] = value
          elsif %w[lang locale].include?(key)
            attrs['lang'] = value
          end
        end
      end

      def build_relative_time(date, tokens)
        opts = parse_relative_options(tokens)
        parts = []
        parts << "date=\"#{escape_html(date)}\"" if date
        parts << "format=\"#{opts[:format]}\"" if opts[:format] && opts[:format] != 'long'
        parts << "numeric=\"#{opts[:numeric]}\"" if opts[:numeric] && opts[:numeric] != 'auto'
        parts << 'sync' if opts[:sync]
        parts << "lang=\"#{escape_html(opts[:lang])}\"" if opts[:lang]
        build_element('wa-relative-time', parts)
      end

      def parse_relative_options(tokens)
        opts = { format: nil, numeric: nil, sync: false, lang: nil }
        tokens.each do |token|
          if token == 'sync'
            opts[:sync] = true
          elsif (m = token.match(/\Aformat:(.+)\z/)) && RELATIVE_FORMATS.include?(m[1])
            opts[:format] = m[1]
          elsif (m = token.match(/\Anumeric:(.+)\z/)) && RELATIVE_NUMERICS.include?(m[1])
            opts[:numeric] = m[1]
          elsif (m = token.match(/\A(?:lang|locale):(.+)\z/))
            opts[:lang] = m[1]
          end
        end
        opts
      end

      def build_element(tag, parts)
        return "<#{tag}></#{tag}>" if parts.empty?

        "<#{tag} #{parts.join(' ')}></#{tag}>"
      end

      def escape_html(text)
        text.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
            .gsub('"', '&quot;').gsub("'", '&#39;')
      end
    end
  end
end
