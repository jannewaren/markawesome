# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms video syntax into Web Awesome's two media components:
  #   <wa-video>          — a single embedded video with custom controls
  #   <wa-video-playlist> — a playlist wrapping multiple <wa-video> children
  #
  # Single video
  #   Primary:     ;;;tokens\n[Title](src)\n![Poster](poster)\n;;;
  #   Alternative: :::wa-video tokens\n…\n:::
  #
  # Playlist (a ;;;;;; container wrapping bare ;;; items, mirroring carousel)
  #   Primary:     ;;;;;;tokens\n;;;\n[Title](src)\n;;;\n…\n;;;;;;
  #   Alternative: :::wa-video-playlist tokens\n;;;\n…\n;;;\n:::
  #
  # Body: the first markdown link `[text](url)` supplies `title`/`src`; the first
  # markdown image `![alt](url)` supplies `poster`. A block with no link (no
  # `src`) is left untransformed.
  #
  # Tokens: `controls:none|standard|full` and `preload:auto|metadata|none`
  # (enum-validated, invalid values dropped) plus the boolean flags
  # `autoplay`, `autoplay-muted`, `autoplay-on-visible`, `loop`, `muted`.
  # Playlist children omit `controls` (the container forwards it to each child).
  class VideoTransformer < BaseTransformer
    # Boolean flags, matched as whole tokens so `autoplay-muted` never triggers
    # `autoplay`. Parsed via AttributeParser (rightmost-wins, order-independent).
    VIDEO_FLAGS = {
      autoplay: %w[autoplay],
      'autoplay-muted': %w[autoplay-muted],
      'autoplay-on-visible': %w[autoplay-on-visible],
      loop: %w[loop],
      muted: %w[muted]
    }.freeze

    # Deterministic emission order for the boolean flags.
    FLAG_ORDER = %w[autoplay autoplay-muted autoplay-on-visible loop muted].freeze

    CONTROLS_VALUES = %w[none standard full].freeze
    PRELOAD_VALUES = %w[auto metadata none].freeze

    # Playlist consumes its inner ;;; items first; the bare `;;;\n` item open
    # (no params) is load-bearing — it stops the closing `;;;;;;` from being
    # mis-read as another item (mirrors carousel's `~~~`/`~~~~~~` trick).
    PLAYLIST_PRIMARY = /^;{6}([^\n]*)\n((?:;;;\n(?:.*?\n)?;;;\n?)+);{6}/m
    PLAYLIST_ALT = /^:::wa-video-playlist\s*([^\n]*)\n(.*?)\n:::/m
    # `(?!;)` keeps the single open from matching a leftover `;;;;;;` fence.
    SINGLE_PRIMARY = /^;;;(?!;)([^\n]*)\n(.*?)\n^;;;$/m
    SINGLE_ALT = /^:::wa-video\s*([^\n]*)\n(.*?)\n:::/m
    ITEM_REGEX = /;;;\n(.*?);;;(?:\n|$)/m

    # First markdown link that is not the `![…]()` of an image (negative
    # lookbehind on `!`) → title + src.
    LINK_REGEX = /(?<!!)\[([^\]]+)\]\(([^)]+)\)/
    # First markdown image → poster.
    IMAGE_REGEX = /!\[([^\]]*)\]\(([^)]+)\)/

    def self.transform(content)
      patterns = [
        { regex: PLAYLIST_PRIMARY, block: proc { |_m, md| build_playlist(md[1], md[2]) } },
        { regex: PLAYLIST_ALT, block: proc { |_m, md| build_playlist(md[1], md[2]) } },
        { regex: SINGLE_PRIMARY, block: proc { |m, md| build_single(md[1], md[2]) || m } },
        { regex: SINGLE_ALT, block: proc { |m, md| build_single(md[1], md[2]) || m } }
      ]
      apply_multiple_patterns(content, patterns)
    end

    def self.render_as_markdown(content, _options = {})
      patterns = [
        { regex: PLAYLIST_PRIMARY, block: proc { |_m, md| render_playlist_markdown(md[2]) } },
        { regex: PLAYLIST_ALT, block: proc { |_m, md| render_playlist_markdown(md[2]) } },
        { regex: SINGLE_PRIMARY, block: proc { |m, md| render_single_markdown(md[2]) || m } },
        { regex: SINGLE_ALT, block: proc { |m, md| render_single_markdown(md[2]) || m } }
      ]
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def build_single(params, body)
        build_video(params, body, suppress_controls: false)
      end

      def build_playlist(params, body)
        controls = parse_tokens(params)[:controls]
        controls_attr = controls ? " controls=\"#{controls}\"" : ''
        children = extract_items(body).filter_map do |item_body|
          build_video('', item_body, suppress_controls: true)
        end
        "<wa-video-playlist#{controls_attr}>#{children.join}</wa-video-playlist>"
      end

      # Returns the <wa-video> HTML, or nil when the body has no link (no `src`),
      # signalling the caller to leave the block untransformed.
      def build_video(params, body, suppress_controls:)
        tokens = parse_tokens(params)
        title, src, poster = extract_link_and_image(body)
        return nil unless src

        parts = ["src=\"#{escape_html(src)}\""]
        parts << "poster=\"#{escape_html(poster)}\"" if poster
        parts << "title=\"#{escape_html(title)}\"" if title && !title.empty?
        parts << "controls=\"#{tokens[:controls]}\"" if tokens[:controls] && !suppress_controls
        parts << "preload=\"#{tokens[:preload]}\"" if tokens[:preload]
        FLAG_ORDER.each { |flag| parts << flag if tokens[:flags].include?(flag) }

        "<wa-video #{parts.join(' ')}></wa-video>"
      end

      def parse_tokens(params)
        result = { controls: nil, preload: nil, flags: [] }
        params.to_s.strip.split(/\s+/).each do |token|
          if (m = token.match(/\Acontrols:(.+)\z/)) && CONTROLS_VALUES.include?(m[1])
            result[:controls] = m[1]
          elsif (m = token.match(/\Apreload:(.+)\z/)) && PRELOAD_VALUES.include?(m[1])
            result[:preload] = m[1]
          end
        end
        result[:flags] = AttributeParser.parse(params, VIDEO_FLAGS).keys.map(&:to_s)
        result
      end

      def extract_items(body)
        body.scan(ITEM_REGEX).map { |match| match[0] }
      end

      def extract_link_and_image(body)
        link = body.match(LINK_REGEX)
        image = body.match(IMAGE_REGEX)
        [link && link[1], link && link[2], image && image[2]]
      end

      def render_single_markdown(body)
        title, src, = extract_link_and_image(body)
        return nil unless src

        "[#{title.to_s.empty? ? src : title}](#{src})"
      end

      def render_playlist_markdown(body)
        extract_items(body).filter_map do |item_body|
          title, src, = extract_link_and_image(item_body)
          next unless src

          "- [#{title.to_s.empty? ? src : title}](#{src})"
        end.join("\n")
      end

      def escape_html(text)
        text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
            .gsub('"', '&quot;').gsub("'", '&#39;')
      end
    end
  end
end
