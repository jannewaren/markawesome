# frozen_string_literal: true

require_relative 'transformers'
require_relative 'code_block_protector'

module Markawesome
  # Renders Markawesome-flavored markdown into "clean" plain markdown by
  # degrading each Web Awesome component to its closest GFM equivalent.
  # Used to serve per-page `.md` endpoints and to generate llms.txt content
  # that LLM consumers can read without having to understand `<wa-*>` tags.
  #
  # Mirrors Markawesome::Transformer.process, but dispatches to each
  # transformer's `render_as_markdown` method instead of `transform`.
  class PlainMarkdownRenderer
    # Per-component overrides registered by host applications. Values are
    # procs with signature `proc { |content, options| ... }` that replace
    # the default rendering for that component.
    @overrides = {}

    class << self
      attr_reader :overrides

      # Register a per-component override. Consumers can call this from a
      # plugin during boot to override the default rendering for a single
      # component without forking the gem.
      #
      # @param component [Symbol] one of :accordion, :callout, :badge, :button,
      #   :card, :carousel, :comparison, :copy_button, :details, :dialog, :icon,
      #   :image_dialog, :layout, :popover, :tabs, :tag, :tooltip.
      # @yield [content, options] Proc that receives the full source content
      #   and the renderer options; returns the content with that component
      #   syntax replaced.
      def register_override(component, &block)
        raise ArgumentError, 'block required' unless block_given?

        @overrides[component.to_sym] = block
      end

      # Clear all registered overrides (useful in tests).
      def reset_overrides!
        @overrides = {}
      end
    end

    PIPELINE = %i[
      layout
      popover
      tooltip
      date
      badge
      button
      callout
      card
      carousel
      comparison
      video
      copy_button
      details
      image_dialog
      dialog
      icon
      tag
      tabs
      accordion
    ].freeze

    TRANSFORMER_MAP = {
      layout: LayoutTransformer,
      popover: PopoverTransformer,
      tooltip: TooltipTransformer,
      date: DateTransformer,
      badge: BadgeTransformer,
      button: ButtonTransformer,
      callout: CalloutTransformer,
      card: CardTransformer,
      carousel: CarouselTransformer,
      comparison: ComparisonTransformer,
      video: VideoTransformer,
      copy_button: CopyButtonTransformer,
      details: DetailsTransformer,
      image_dialog: ImageDialogTransformer,
      dialog: DialogTransformer,
      icon: IconTransformer,
      tag: TagTransformer,
      tabs: TabsTransformer,
      accordion: AccordionTransformer
    }.freeze

    def self.process(content, options = {})
      content, tokens = CodeBlockProtector.protect(content)

      PIPELINE.each do |component|
        if (override = overrides[component])
          content = override.call(content, options)
          next
        end

        transformer = TRANSFORMER_MAP.fetch(component)
        content = if component == :image_dialog
                    if options[:image_dialog]
                      config = options[:image_dialog].is_a?(Hash) ? options[:image_dialog] : {}
                      transformer.render_as_markdown(content, config)
                    else
                      content
                    end
                  else
                    transformer.render_as_markdown(content, options)
                  end
      end

      content = strip_kramdown_attributes(content)
      CodeBlockProtector.restore(content, tokens)
    end

    # Strip Kramdown attribute syntax like `{:.class}`, `{:#id}`, `{: .class}`,
    # `{: #id .class}`, etc. These are Kramdown-specific and not valid GFM.
    def self.strip_kramdown_attributes(content)
      content.gsub(/\s*\{:\s*[^}]*\}/, '')
    end
  end
end
