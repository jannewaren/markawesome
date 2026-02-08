# frozen_string_literal: true

require 'rspec'

RSpec.describe Markawesome::CardTransformer do
  describe '.transform' do
    context 'basic card' do
      it 'transforms simple card syntax' do
        input = <<~MARKDOWN
          ===
          This is a basic card with just content.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card>')
        expect(result).to include('This is a basic card with just content.')
        expect(result).to include('</wa-card>')
      end
    end

    context 'card with header' do
      it 'transforms card with heading to header slot' do
        input = <<~MARKDOWN
          ===
          # Card Title
          This is the card content.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card with-header>')
        expect(result).to include('<div slot="header">')
        expect(result).to include('Card Title')
        expect(result).to include('This is the card content.')
      end
    end

    context 'card with media' do
      it 'transforms card with image to media slot' do
        input = <<~MARKDOWN
          ===
          ![Alt text](image.jpg)
          # Card Title
          This is the card content.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card with-media with-header>')
        expect(result).to include('<img slot="media" src="image.jpg" alt="Alt text">')
        expect(result).to include('<div slot="header">')
      end
    end

    context 'card with footer' do
      it 'transforms card with trailing link to footer slot' do
        input = <<~MARKDOWN
          ===
          # Card Title
          This is the card content.
          [Learn More](https://example.com)
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card with-header with-footer>')
        expect(result).to include('<div slot="footer">')
        expect(result).to include('<wa-button href="https://example.com">Learn More</wa-button>')
      end
    end

    context 'card with appearance' do
      it 'transforms card with filled appearance' do
        input = <<~MARKDOWN
          ===filled
          # Card Title
          This is a filled card.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card appearance="filled" with-header>')
      end

      it 'defaults to outlined appearance when not specified' do
        input = <<~MARKDOWN
          ===
          # Card Title
          This is a default card.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card with-header>')
        expect(result).not_to include('appearance="outlined"')
      end

      it 'transforms card with accent appearance' do
        input = <<~MARKDOWN
          ===accent
          # Accent Card
          This is an accent card.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card appearance="accent" with-header>')
      end

      it 'transforms card with plain appearance' do
        input = <<~MARKDOWN
          ===plain
          # Plain Card
          This is a plain card.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card appearance="plain" with-header>')
      end

      it 'transforms card with filled-outlined appearance' do
        input = <<~MARKDOWN
          ===filled-outlined
          # Filled-Outlined Card
          This is a filled-outlined card.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card appearance="filled-outlined" with-header>')
      end
    end

    context 'card with orientation' do
      it 'transforms card with horizontal orientation' do
        input = <<~MARKDOWN
          ===horizontal
          ![Image](image.jpg)
          This is a horizontal card with side-by-side layout.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card orientation="horizontal" with-media>')
        expect(result).to include('<img slot="media" src="image.jpg" alt="Image">')
      end

      it 'defaults to vertical orientation when not specified' do
        input = <<~MARKDOWN
          ===
          # Vertical Card
          This is a vertical card (default).
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card with-header>')
        expect(result).not_to include('orientation="vertical"')
      end

      it 'transforms card with explicit vertical orientation' do
        input = <<~MARKDOWN
          ===vertical
          # Explicit Vertical
          This explicitly sets vertical orientation.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card with-header>')
        expect(result).not_to include('orientation="vertical"')
      end
    end

    context 'flexible attribute ordering' do
      it 'transforms card with appearance and orientation in any order' do
        input1 = <<~MARKDOWN
          ===filled horizontal
          ![Image](image.jpg)
          Filled horizontal card.
          ===
        MARKDOWN

        input2 = <<~MARKDOWN
          ===horizontal filled
          ![Image](image.jpg)
          Filled horizontal card.
          ===
        MARKDOWN

        result1 = described_class.transform(input1)
        result2 = described_class.transform(input2)

        expect(result1).to include('<wa-card appearance="filled" orientation="horizontal" with-media>')
        expect(result2).to include('<wa-card appearance="filled" orientation="horizontal" with-media>')
      end

      it 'applies rightmost-wins for duplicate attributes' do
        input = <<~MARKDOWN
          ===filled accent
          # Test Card
          The rightmost appearance (accent) should win.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card appearance="accent" with-header>')
        expect(result).not_to include('filled')
      end
    end

    context 'complete card' do
      it 'transforms card with all components' do
        input = <<~MARKDOWN
          ===filled
          ![Hero image](hero.jpg)
          # Complete Card
          This card has everything: media, header, content, and footer.
          [Get Started](https://example.com)
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card appearance="filled" with-media with-header with-footer>')
        expect(result).to include('<img slot="media" src="hero.jpg" alt="Hero image">')
        expect(result).to include('<div slot="header">')
        expect(result).to include('Complete Card')
        expect(result).to include('This card has everything')
        expect(result).to include('<div slot="footer">')
        expect(result).to include('<wa-button href="https://example.com">Get Started</wa-button>')
      end

      it 'transforms horizontal card with all attributes' do
        input = <<~MARKDOWN
          ===accent horizontal
          ![Hero](hero.jpg)
          # Horizontal Card
          This is a horizontal card with accent appearance.
          ===
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card appearance="accent" orientation="horizontal" with-media with-header>')
        expect(result).to include('<img slot="media" src="hero.jpg" alt="Hero">')
        expect(result).to include('<div slot="header">')
        expect(result).to include('Horizontal Card')
      end
    end

    context 'alternative syntax' do
      it 'transforms wa-card syntax with attributes' do
        input = <<~MARKDOWN
          :::wa-card filled horizontal
          ![Image](image.jpg)
          # Alternative Syntax
          This uses the alternative wa-card syntax.
          :::
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-card appearance="filled" orientation="horizontal" with-media with-header>')
      end
    end
  end
end
