# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms random-content syntax into Web Awesome's
  # <wa-random-content> element, which shows one or more of its direct element
  # children at random (optionally rotating them) and hides the rest — all in
  # WA's own runtime, so the author writes zero JavaScript. Ideal for a "little
  # bit dynamic" rotating tips / testimonials / featured-content block on an
  # otherwise static site.
  #
  # Primary syntax:
  #   ......mode:random items:2 animation:fade
  #   First option
  #   >>>
  #   Second option
  #   ......
  # Alternative syntax:
  #   :::wa-random-content <params>
  #   First option
  #   >>>
  #   Second option
  #   :::
  #
  # Each option (split on a `>>>` line) has its rendered Markdown wrapped in a
  # single <div> so WA sees exactly one selectable element child per option.
  #
  # Params (order-independent, on the opening fence line):
  #   - mode:      unique (WA default) | random | sequence — bare enum or mode:VALUE
  #   - animation: none | fade | fade-up | fade-down | fade-left | fade-right —
  #                bare enum or animation:VALUE
  #   - autoplay:  bare boolean flag
  #   - items:     a bare integer or items:N (how many children to show)
  #   - autoplay-interval:N (ms between rotations)
  # Unknown/invalid tokens are silently ignored. Deterministic emission order:
  # mode, items, animation, autoplay, autoplay-interval.
  #
  # The `>>>` separator is the SHARED glyph already used inside
  # details/dialog/popover/tooltip; it only acts as an item separator *inside* a
  # `......`/`:::wa-random-content` block. A line of exactly `>>>` or `......`
  # inside an option is therefore a separator/close-fence — options cannot
  # contain those literal lines (a hard constraint, like carousel's `~~~`).
  class RandomContentTransformer < BaseTransformer
    COMPONENT_ATTRIBUTES = {
      mode: %w[unique random sequence],
      animation: %w[none fade fade-up fade-down fade-left fade-right],
      autoplay: %w[autoplay]
    }.freeze

    # Dots MUST be escaped. The body is unstructured `(.*?)` under /m, so the
    # closing anchor makes an unclosed fence not match and lets multiple blocks
    # match left-to-right. Deliberately NO `\s*` after the alt fence (unlike
    # carousel): with an unstructured body a greedy `\s*` would swallow the
    # first newline and capture the first option line as params. `([^\n]*)`
    # only — a leading space on the alt form is stripped by the parser.
    PRIMARY_REGEX = /^\.{6}([^\n]*)\n(.*?)\n\.{6}/m
    ALTERNATIVE_REGEX = /^:::wa-random-content([^\n]*)\n(.*?)\n:::/m
    ITEM_SEPARATOR = /^>>>$/

    def self.transform(content)
      transform_proc = proc do |params, items_block|
        build_html(extract_items(items_block), parse_params(params))
      end

      patterns = dual_syntax_patterns(PRIMARY_REGEX, ALTERNATIVE_REGEX, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    # Degrade to the option bodies joined by blank lines (fences, params, and
    # `>>>` separators dropped), used for `.md` endpoints / llms.txt.
    def self.render_as_markdown(content, _options = {})
      transform_proc = proc do |_params, items_block|
        extract_items(items_block).reject(&:empty?).join("\n\n")
      end

      patterns = dual_syntax_patterns(PRIMARY_REGEX, ALTERNATIVE_REGEX, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def extract_items(items_block)
        items_block.split(ITEM_SEPARATOR).map(&:strip)
      end

      def parse_params(params)
        return {} if params.nil? || params.strip.empty?

        result = {}

        # Bare enum/boolean tokens via AttributeParser (rightmost-wins).
        attributes = AttributeParser.parse(params, COMPONENT_ATTRIBUTES)
        result['mode'] = attributes[:mode] if attributes[:mode]
        result['animation'] = attributes[:animation] if attributes[:animation]
        result['autoplay'] = true if attributes[:autoplay]

        # Manual pass for key:value and bare-integer tokens.
        params.strip.split(/\s+/).each { |token| merge_manual_token(result, token) }

        result
      end

      # Fold a single space-separated token into the parsed attribute hash:
      # `mode:`/`animation:` (enum-validated), `items:` / bare integer, and
      # `autoplay-interval:`. Anything else is ignored.
      def merge_manual_token(result, token)
        if token.include?(':')
          key, value = token.split(':', 2)
          case key
          when 'mode'
            result['mode'] = value if COMPONENT_ATTRIBUTES[:mode].include?(value)
          when 'animation'
            result['animation'] = value if COMPONENT_ATTRIBUTES[:animation].include?(value)
          when 'items'
            result['items'] = value
          when 'autoplay-interval'
            result['autoplay-interval'] = value
          end
        elsif token.match?(/^\d+$/)
          result['items'] = token
        end
      end

      def build_html(items, params)
        attr_string = build_attributes(params)

        # Empty options are dropped — an empty rotating option would show
        # nothing. Keep Kramdown's trailing "\n" inside each <div> (no strip).
        divs = items.reject(&:empty?).map { |item| "<div>#{markdown_to_html(item)}</div>" }.join

        "<wa-random-content#{attr_string}>#{divs}</wa-random-content>"
      end

      # Fixed emission order for byte-parity: mode, items, animation, autoplay,
      # autoplay-interval.
      def build_attributes(params)
        attrs = []
        attrs << "mode=\"#{params['mode']}\"" if params['mode']
        attrs << "items=\"#{params['items']}\"" if params['items']
        attrs << "animation=\"#{params['animation']}\"" if params['animation']
        attrs << 'autoplay' if params['autoplay']
        attrs << "autoplay-interval=\"#{params['autoplay-interval']}\"" if params['autoplay-interval']

        attrs.empty? ? '' : " #{attrs.join(' ')}"
      end
    end
  end
end
