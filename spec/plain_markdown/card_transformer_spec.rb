# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::CardTransformer do
  describe '.render_as_markdown' do
    it 'drops the card wrapper and keeps media, header, body and footer' do
      md = <<~MD.strip
        ===
        ![Cover](cover.png)
        **Title line**
        Some body text.
        [Read more](https://example.com)
        ===
      MD
      result = described_class.render_as_markdown(md)
      expect(result).to include('![Cover](cover.png)')
      expect(result).to include('### Title line')
      expect(result).to include('Some body text.')
      expect(result).to include('[Read more](https://example.com)')
      expect(result).not_to include('===')
    end

    it 'handles alternative :::wa-card syntax' do
      md = ":::wa-card\nJust body\n:::"
      result = described_class.render_as_markdown(md)
      expect(result).to include('Just body')
      expect(result).not_to include(':::')
    end
  end
end
