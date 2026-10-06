# frozen_string_literal: true

require 'kramdown'
require_relative 'transformers'
require_relative 'code_block_protector'

module Markawesome
  # Main transformer that orchestrates all component transformers
  class Transformer
    def self.process(content, options = {})
      content, tokens = CodeBlockProtector.protect(content)

      # Divider and stepper run FIRST: their content is inline-only (a label,
      # a list of one-line steps), so emitting them before any container lets
      # them sit inside layouts, cards, callouts, tabs, accordion and dialog
      # bodies — e.g. `--- vertical vs ---` inside a `::::cluster`.
      content = DividerTransformer.transform(content)
      content = StepperTransformer.transform(content)

      content = LayoutTransformer.transform(content)
      content = PopoverTransformer.transform(content)
      content = TooltipTransformer.transform(content)
      content = DateTransformer.transform(content)
      content = BadgeTransformer.transform(content)
      content = ButtonTransformer.transform(content)
      content = CalloutTransformer.transform(content)
      content = CardTransformer.transform(content)
      content = CarouselTransformer.transform(content)
      content = ComparisonTransformer.transform(content)
      content = VideoTransformer.transform(content)
      content = CopyButtonTransformer.transform(content)
      content = DetailsTransformer.transform(content)

      # Apply image dialog transformer BEFORE dialog transformer if enabled
      if options[:image_dialog]
        config = options[:image_dialog].is_a?(Hash) ? options[:image_dialog] : {}
        content = ImageDialogTransformer.transform(content, config)
      end

      content = DialogTransformer.transform(content)
      content = IconTransformer.transform(content)
      content = TagTransformer.transform(content)
      content = TabsTransformer.transform(content)

      # Accordion runs last so item bodies may contain other already-transformed
      # components (same reason tabs runs near the end).
      content = AccordionTransformer.transform(content)

      # Tree runs after accordion; its body is a plain nested list (never a
      # markdown-converted body), so ordering relative to accordion is moot.
      content = TreeTransformer.transform(content)

      # Random-content runs LAST: its options routinely wrap already-transformed
      # components (callouts/badges/cards), and dialog/details/popover/tooltip
      # must consume their own `>>>` upstream before our `^>>>$` item split
      # runs. Consequence: a `......` block is the outermost container and cannot
      # be nested inside another container body (same constraint Tree documents).
      content = RandomContentTransformer.transform(content)

      CodeBlockProtector.restore(content, tokens)
    end
  end
end
