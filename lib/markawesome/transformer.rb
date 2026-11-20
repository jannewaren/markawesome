# frozen_string_literal: true

require 'kramdown'
require_relative 'transformers'
require_relative 'code_block_protector'

module Markawesome
  # Main transformer that orchestrates all component transformers
  class Transformer
    # Runs before the optional ImageDialogTransformer. Order is load-bearing:
    #
    # - Divider, stepper and lightbox run FIRST. Divider/stepper content is
    #   inline-only (a label, one-line steps), and the lightbox's `::::` closer
    #   must be consumed before LayoutTransformer, so all three can sit inside
    #   layouts, cards, callouts, tabs, accordion and dialog bodies — e.g.
    #   `--- vertical vs ---` inside a `::::cluster`, a gallery in a `::::grid`.
    #   The lightbox emits <img> HTML, so ImageDialogTransformer never wraps
    #   gallery images in dialogs.
    # - Number ticker runs right before the date transformer: both use
    #   `[[[ … ]]]`, and a leading number (never an ISO date) claims it.
    BEFORE_IMAGE_DIALOG = [
      DividerTransformer, StepperTransformer, LightboxTransformer,
      LayoutTransformer, PopoverTransformer, TooltipTransformer,
      NumberTickerTransformer, DateTransformer,
      BadgeTransformer, ButtonTransformer, CalloutTransformer, CardTransformer,
      CarouselTransformer, ComparisonTransformer, VideoTransformer,
      CopyButtonTransformer, DetailsTransformer
    ].freeze

    # Runs after the optional ImageDialogTransformer (which must precede the
    # dialog transformer):
    #
    # - Accordion runs late so item bodies may contain other already-transformed
    #   components (same reason tabs runs near the end).
    # - Tree runs after accordion; its body is a plain nested list (never a
    #   markdown-converted body), so ordering relative to accordion is moot.
    # - Random-content runs LAST: its options routinely wrap already-transformed
    #   components (callouts/badges/cards), and dialog/details/popover/tooltip
    #   must consume their own `>>>` upstream before our `^>>>$` item split
    #   runs. Consequence: a `......` block is the outermost container and cannot
    #   be nested inside another container body (same constraint Tree documents).
    AFTER_IMAGE_DIALOG = [
      DialogTransformer, IconTransformer, TagTransformer, TabsTransformer,
      AccordionTransformer, TreeTransformer, RandomContentTransformer
    ].freeze

    def self.process(content, options = {})
      content, tokens = CodeBlockProtector.protect(content)

      content = BEFORE_IMAGE_DIALOG.reduce(content) { |acc, transformer| transformer.transform(acc) }

      if options[:image_dialog]
        config = options[:image_dialog].is_a?(Hash) ? options[:image_dialog] : {}
        content = ImageDialogTransformer.transform(content, config)
      end

      content = AFTER_IMAGE_DIALOG.reduce(content) { |acc, transformer| transformer.transform(acc) }

      CodeBlockProtector.restore(content, tokens)
    end
  end
end
