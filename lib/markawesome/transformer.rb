# frozen_string_literal: true

require 'kramdown'
require_relative 'transformers'

module Markawesome
  # Main transformer that orchestrates all component transformers
  class Transformer
    def self.process(content, options = {})
      content = LayoutTransformer.transform(content)
      content = BadgeTransformer.transform(content)
      content = ButtonTransformer.transform(content)
      content = CalloutTransformer.transform(content)
      content = CardTransformer.transform(content)
      content = CarouselTransformer.transform(content)
      content = ComparisonTransformer.transform(content)
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
      TabsTransformer.transform(content)
    end
  end
end
