# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::RandomContentTransformer do
  describe '.transform' do
    context 'with primary syntax' do
      it 'transforms a two-option block with no parameters' do
        input = <<~MARKDOWN.chomp
          ......
          First option
          >>>
          Second option
          ......
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to eq(
          '<wa-random-content>' \
          "<div><p>First option</p>\n</div>" \
          "<div><p>Second option</p>\n</div>" \
          '</wa-random-content>'
        )
      end

      it 'renders Markdown inside each option' do
        input = <<~MARKDOWN.chomp
          ......
          A **testimonial** or tip
          >>>
          Another *option*
          ......
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('<div><p>A <strong>testimonial</strong> or tip</p>')
        expect(result).to include('<div><p>Another <em>option</em></p>')
      end

      it 'handles a single option with no separator' do
        input = <<~MARKDOWN.chomp
          ......
          Just one option
          ......
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to eq("<wa-random-content><div><p>Just one option</p>\n</div></wa-random-content>")
      end

      it 'emits the full combined example exactly' do
        input = <<~MARKDOWN.chomp
          ......mode:random items:2 animation:fade
          A **testimonial** or tip
          >>>
          Another option
          ......
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to eq(
          '<wa-random-content mode="random" items="2" animation="fade">' \
          "<div><p>A <strong>testimonial</strong> or tip</p>\n</div>" \
          "<div><p>Another option</p>\n</div>" \
          '</wa-random-content>'
        )
      end

      it 'renders a multi-paragraph option as a single <div> with two paragraphs' do
        input = <<~MARKDOWN.chomp
          ......
          Para one

          Para two
          >>>
          Second
          ......
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("<div><p>Para one</p>\n\n<p>Para two</p>\n</div>")
        expect(result.scan('<div>').length).to eq(2)
      end
    end

    context 'with attribute forms' do
      it 'accepts a bare mode enum' do
        expect(described_class.transform("......random\nA\n......")).to include('<wa-random-content mode="random">')
      end

      it 'accepts a mode:VALUE colon form' do
        expect(described_class.transform("......mode:sequence\nA\n......"))
          .to include('<wa-random-content mode="sequence">')
      end

      it 'accepts a bare animation enum' do
        expect(described_class.transform("......fade-up\nA\n......")).to include('animation="fade-up"')
      end

      it 'accepts an animation:VALUE colon form' do
        expect(described_class.transform("......animation:fade\nA\n......")).to include('animation="fade"')
      end

      it 'accepts an items:N colon form' do
        expect(described_class.transform("......items:2\nA\n......")).to include('items="2"')
      end

      it 'accepts a bare integer as items' do
        expect(described_class.transform("......3\nA\n......")).to include('items="3"')
      end

      it 'accepts a bare autoplay flag' do
        expect(described_class.transform("......autoplay\nA\n......")).to include('<wa-random-content autoplay>')
      end

      it 'accepts an autoplay-interval:N colon form' do
        expect(described_class.transform("......autoplay-interval:3000\nA\n......"))
          .to include('autoplay-interval="3000"')
      end

      it 'emits attributes in the fixed order regardless of input order' do
        input = "......autoplay-interval:3000 fade autoplay items:2 sequence\nA\n>>>\nB\n......"

        result = described_class.transform(input)

        expect(result).to include(
          '<wa-random-content mode="sequence" items="2" animation="fade" autoplay autoplay-interval="3000">'
        )
      end

      it 'silently ignores an invalid enum value' do
        result = described_class.transform("......mode:bogus\nA\n>>>\nB\n......")

        expect(result).to start_with('<wa-random-content>')
        expect(result).not_to include('bogus')
      end
    end

    context 'edge cases' do
      it 'drops an empty option' do
        result = described_class.transform("......\nA\n>>>\n>>>\nB\n......")

        expect(result.scan('<div>').length).to eq(2)
        expect(result).to eq(
          "<wa-random-content><div><p>A</p>\n</div><div><p>B</p>\n</div></wa-random-content>"
        )
      end

      it 'transforms multiple blocks in one document' do
        input = <<~MARKDOWN.chomp
          ......
          A
          ......

          Some text.

          ......
          B
          ......
        MARKDOWN

        result = described_class.transform(input)

        expect(result.scan('<wa-random-content>').length).to eq(2)
        expect(result).to include('Some text.')
      end

      it 'leaves an unclosed fence untransformed' do
        input = "......\nA\n>>>\nB"

        result = described_class.transform(input)

        expect(result).not_to include('<wa-random-content')
        expect(result).to include('......')
      end

      it 'leaves a stray >>> outside a fence inert' do
        input = "Some text\n>>>\nMore text"

        expect(described_class.transform(input)).to eq(input)
      end
    end

    context 'with alternative syntax' do
      it 'transforms a :::wa-random-content block with no parameters' do
        input = <<~MARKDOWN.chomp
          :::wa-random-content
          A
          >>>
          B
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to eq(
          "<wa-random-content><div><p>A</p>\n</div><div><p>B</p>\n</div></wa-random-content>"
        )
      end

      it 'parses params on the alternative fence (leading space stripped)' do
        input = <<~MARKDOWN.chomp
          :::wa-random-content mode:sequence items:2
          A
          >>>
          B
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('<wa-random-content mode="sequence" items="2">')
      end
    end
  end

  describe 'integration via Markawesome::Transformer.process (pipeline ordering)' do
    it 'wraps an already-transformed callout inside the option <div>' do
      input = <<~MARKDOWN.chomp
        ......
        :::success
        Well done
        :::
        ......
      MARKDOWN

      result = Markawesome::Transformer.process(input)

      expect(result).to start_with('<wa-random-content><div><wa-callout variant="success">')
      expect(result).to end_with("</wa-callout>\n</div></wa-random-content>")
    end

    it 'lets a details block consume its own >>> before the option split' do
      input = <<~MARKDOWN.chomp
        ......
        ^^^
        Summary
        >>>
        Hidden body
        ^^^
        ......
      MARKDOWN

      result = Markawesome::Transformer.process(input)

      # A single option containing the whole <wa-details>, NOT split on the
      # details' internal >>>.
      expect(result.scan('<div>').length).to eq(1)
      expect(result).to include('<wa-details')
      expect(result).to include('Hidden body')
    end
  end
end
