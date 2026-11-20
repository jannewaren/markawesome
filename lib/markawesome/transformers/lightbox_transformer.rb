# frozen_string_literal: true

require_relative 'base_transformer'
require_relative 'layout_transformer'

module Markawesome
  # Transforms a fenced list of Markdown images into a <wa-lightbox> gallery:
  # a grid of thumbnails that open a full-screen viewer.
  #
  # Primary syntax:
  #   ::::lightbox loop thumbnails min:10rem gap:s label:"Lisbon trip"
  #   ![Tram](tram.jpg "Tram 28 in Alfama")
  #   [![Bridge](bridge-thumb.jpg)](bridge-full.jpg "25 de Abril")
  #   [![Drone](drone-poster.jpg)](drone.mp4 "From above")
  #   ::::
  # Alternative syntax: :::wa-lightbox params? ...same body... :::
  #
  # Items (one per line):
  #   ![alt](src "caption")                  -> item src = thumbnail = src
  #   [![alt](thumb "t")](href "caption")    -> thumbnail = thumb, item src = href
  #   The caption is the link title, else the image title. An item src ending in
  #   a video extension (.mp4 .webm .mov .ogv .m4v, ignoring ?query/#hash) gets
  #   type="video". Blank lines are ignored; any other line is rendered as
  #   Markdown and kept in place (never silently dropped).
  #
  # Params:
  #   loop, thumbnails (-> with-thumbnails), no-nav (-> without-navigation),
  #   no-counter (-> without-counter), no-zoom (-> without-zoom), label:"…"
  #   square (default), landscape (4 / 3), portrait (3 / 4), natural (no crop)
  #   gap:, min:, align:, justify: — the ::::grid rules (the gallery is a wa-grid)
  #
  # Runs first in the pipeline (with divider/stepper) so its `::::` closer is
  # consumed before LayoutTransformer — a lightbox can sit inside a ::::grid,
  # a card or a tab — and so the optional ImageDialogTransformer never sees the
  # gallery's images (they are already <img> HTML).
  class LightboxTransformer < BaseTransformer
    # wa-lightbox-item `type` values: image is implicit (WA's default), video is
    # emitted for video sources.
    LIGHTBOX_ITEM_TYPES = %w[image video].freeze

    FLAGS = {
      'loop' => 'loop',
      'thumbnails' => 'with-thumbnails',
      'no-nav' => 'without-navigation',
      'no-counter' => 'without-counter',
      'no-zoom' => 'without-zoom'
    }.freeze

    # Emission order for boolean attributes (after class, style, label).
    FLAG_ORDER = %w[loop with-thumbnails without-navigation without-counter without-zoom].freeze

    THUMBNAIL_RADIUS = 'border-radius: var(--wa-border-radius-m)'
    THUMBNAIL_STYLES = {
      'square' => "width: 100%; aspect-ratio: 1; object-fit: cover; #{THUMBNAIL_RADIUS}",
      'landscape' => "width: 100%; aspect-ratio: 4 / 3; object-fit: cover; #{THUMBNAIL_RADIUS}",
      'portrait' => "width: 100%; aspect-ratio: 3 / 4; object-fit: cover; #{THUMBNAIL_RADIUS}",
      'natural' => "width: 100%; height: auto; #{THUMBNAIL_RADIUS}"
    }.freeze

    PRIMARY_REGEX = /^::::lightbox(?:[ \t]+([^\n]*))?\n(.*?)\n::::[ \t]*$/m
    ALTERNATIVE_REGEX = /^:::wa-lightbox(?:[ \t]+([^\n]*))?\n(.*?)\n:::[ \t]*$/m
    LABEL_REGEX = /label:(?:"([^"]*)"|'([^']*)')/
    IMAGE_REGEX = /\A!\[([^\]]*)\]\(([^)\s]+)(?:[ \t]+"([^"]*)")?\)\z/
    LINKED_IMAGE_REGEX =
      /\A\[!\[([^\]]*)\]\(([^)\s]+)(?:[ \t]+"([^"]*)")?\)\]\(([^)\s]+)(?:[ \t]+"([^"]*)")?\)\z/
    VIDEO_REGEX = /\.(?:mp4|webm|mov|ogv|m4v)(?:[?#].*)?\z/i

    def self.transform(content)
      transform_proc = proc do |params_string, body|
        build_lightbox(params_string.to_s, body)
      end

      patterns = dual_syntax_patterns(PRIMARY_REGEX, ALTERNATIVE_REGEX, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    # Plain-Markdown degrade: the image lines are already valid GFM, so keep the
    # body as written and drop the fence.
    def self.render_as_markdown(content, _options = {})
      transform_proc = proc { |_params_string, body| body.to_s }
      patterns = dual_syntax_patterns(PRIMARY_REGEX, ALTERNATIVE_REGEX, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def build_lightbox(params_string, body)
        label, params_string = extract_label(params_string)
        tokens = params_string.split
        classes, styles = LayoutTransformer.grid_attributes(params_string)
        shape = tokens.reverse.find { |token| THUMBNAIL_STYLES.include?(token) } || 'square'
        flags = tokens.filter_map { |token| FLAGS[token] }

        attr_parts = ["class=\"#{escape_html(classes.join(' '))}\""]
        attr_parts << "style=\"#{escape_html(styles.join('; '))}\"" unless styles.empty?
        attr_parts << "label=\"#{escape_html(label)}\"" unless label.empty?
        FLAG_ORDER.each { |flag| attr_parts << flag if flags.include?(flag) }

        "<wa-lightbox #{attr_parts.join(' ')}>#{build_children(body, shape)}</wa-lightbox>"
      end

      # Pull out label:"…" (or label:'…') before the bare tokens are read, so
      # words inside the label can't be taken as flags.
      def extract_label(params_string)
        match = LABEL_REGEX.match(params_string)
        return ['', params_string] unless match

        [(match[1] || match[2]).strip, params_string.sub(LABEL_REGEX, ' ')]
      end

      # Image lines become items; runs of other lines are rendered as Markdown
      # in place. Blank lines only separate those runs.
      def build_children(body, shape)
        children = []
        pending = []
        flush = lambda do
          text = pending.join("\n").strip
          children << markdown_to_html(text).strip unless text.empty?
          pending.clear
        end

        body.to_s.each_line do |line|
          item = parse_item(line.strip)
          if item
            flush.call
            children << build_item(item, shape)
          else
            pending << line.chomp
          end
        end
        flush.call
        children.join
      end

      def parse_item(line)
        if (match = LINKED_IMAGE_REGEX.match(line))
          { alt: match[1], thumb: match[2], src: match[4], caption: (match[5] || match[3]).to_s }
        elsif (match = IMAGE_REGEX.match(line))
          { alt: match[1], thumb: match[2], src: match[2], caption: match[3].to_s }
        end
      end

      def build_item(item, shape)
        item_parts = []
        item_parts << 'type="video"' if item[:src].match?(VIDEO_REGEX)
        item_parts << "src=\"#{escape_html(item[:src])}\""
        item_parts << "caption=\"#{escape_html(item[:caption])}\"" unless item[:caption].empty?

        img = "<img src=\"#{escape_html(item[:thumb])}\" alt=\"#{escape_html(item[:alt])}\" " \
              "loading=\"lazy\" style=\"#{THUMBNAIL_STYLES[shape]}\">"
        "<wa-lightbox-item #{item_parts.join(' ')}>#{img}</wa-lightbox-item>"
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
