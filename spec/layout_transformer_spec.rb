# frozen_string_literal: true

require 'rspec'

RSpec.describe Markawesome::LayoutTransformer do
  describe '.transform' do
    context 'grid layout' do
      it 'transforms basic grid syntax' do
        input = "::::grid\nContent here\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-grid">')
        expect(result).to include('Content here')
        expect(result).to include('</div>')
      end

      it 'transforms grid with gap' do
        input = "::::grid gap:l\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-grid wa-gap-l">')
      end

      it 'transforms grid with min column size' do
        input = "::::grid min:300px\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('class="wa-grid"')
        expect(result).to include('style="--min-column-size: 300px"')
      end

      it 'transforms grid with gap and min' do
        input = "::::grid gap:l min:300px\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('class="wa-grid wa-gap-l"')
        expect(result).to include('style="--min-column-size: 300px"')
      end

      it 'ignores min on non-grid layouts' do
        input = "::::stack min:300px\nContent\n::::"

        result = described_class.transform(input)
        expect(result).not_to include('--min-column-size')
      end
    end

    context 'stack layout' do
      it 'transforms basic stack syntax' do
        input = "::::stack\nContent here\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-stack">')
        expect(result).to include('Content here')
      end

      it 'transforms stack with gap' do
        input = "::::stack gap:m\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-stack wa-gap-m">')
      end
    end

    context 'cluster layout' do
      it 'transforms basic cluster syntax' do
        input = "::::cluster\nContent here\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-cluster">')
      end

      it 'transforms cluster with gap and justify' do
        input = "::::cluster gap:s justify:center\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-cluster wa-gap-s wa-justify-content-center">')
      end
    end

    context 'split layout' do
      it 'transforms basic split syntax' do
        input = "::::split\nContent here\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-split">')
      end

      it 'transforms split with row modifier' do
        input = "::::split row\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-split:row">')
      end

      it 'transforms split with column modifier' do
        input = "::::split column\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-split:column">')
      end

      it 'transforms split with modifier and gap' do
        input = "::::split row gap:l\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-split:row wa-gap-l">')
      end
    end

    context 'flank layout' do
      it 'transforms basic flank syntax' do
        input = "::::flank\nContent here\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-flank">')
      end

      it 'transforms flank with start modifier' do
        input = "::::flank start\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-flank:start">')
      end

      it 'transforms flank with end modifier' do
        input = "::::flank end\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-flank:end">')
      end

      it 'transforms flank with size attribute' do
        input = "::::flank size:200px\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('class="wa-flank"')
        expect(result).to include('style="--flank-size: 200px"')
      end

      it 'transforms flank with content percentage' do
        input = "::::flank content:60%\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('style="--content-percentage: 60%"')
      end

      it 'transforms flank with all attributes' do
        input = "::::flank start gap:m size:200px content:60%\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('class="wa-flank:start wa-gap-m"')
        expect(result).to include('--flank-size: 200px')
        expect(result).to include('--content-percentage: 60%')
      end

      it 'ignores size on non-flank layouts' do
        input = "::::grid size:200px\nContent\n::::"

        result = described_class.transform(input)
        expect(result).not_to include('--flank-size')
      end
    end

    context 'frame layout' do
      it 'transforms basic frame syntax' do
        input = "::::frame\nContent here\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-frame">')
      end

      it 'transforms frame with landscape modifier' do
        input = "::::frame landscape\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-frame:landscape">')
      end

      it 'transforms frame with portrait modifier' do
        input = "::::frame portrait\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-frame:portrait">')
      end

      it 'transforms frame with square modifier' do
        input = "::::frame square\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-frame:square">')
      end

      it 'transforms frame with radius' do
        input = "::::frame radius:pill\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('class="wa-frame wa-border-radius-pill"')
      end

      it 'transforms frame with modifier and radius' do
        input = "::::frame landscape radius:l\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('class="wa-frame:landscape wa-border-radius-l"')
      end

      it 'ignores radius on non-frame layouts' do
        input = "::::grid radius:pill\nContent\n::::"

        result = described_class.transform(input)
        expect(result).not_to include('wa-border-radius')
      end

      it 'ignores invalid radius values' do
        input = "::::frame radius:invalid\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('class="wa-frame"')
        expect(result).not_to include('wa-border-radius')
      end
    end

    context 'common attributes' do
      it 'supports align attribute' do
        input = "::::stack align:center\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('class="wa-stack wa-align-items-center"')
      end

      it 'supports justify attribute' do
        input = "::::cluster justify:space-between\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('class="wa-cluster wa-justify-content-space-between"')
      end

      it 'supports all valid gap sizes' do
        %w[0 3xs 2xs xs s m l xl 2xl 3xl].each do |size|
          input = "::::stack gap:#{size}\nContent\n::::"

          result = described_class.transform(input)
          expect(result).to include("wa-gap-#{size}")
        end
      end

      it 'ignores invalid gap values' do
        input = "::::stack gap:invalid\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('class="wa-stack"')
        expect(result).not_to include('wa-gap')
      end

      it 'ignores invalid align values' do
        input = "::::stack align:invalid\nContent\n::::"

        result = described_class.transform(input)
        expect(result).not_to include('wa-align-items')
      end

      it 'ignores invalid justify values' do
        input = "::::cluster justify:invalid\nContent\n::::"

        result = described_class.transform(input)
        expect(result).not_to include('wa-justify-content')
      end

      it 'combines multiple common attributes' do
        input = "::::stack gap:l align:center justify:center\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('wa-stack')
        expect(result).to include('wa-gap-l')
        expect(result).to include('wa-align-items-center')
        expect(result).to include('wa-justify-content-center')
      end
    end

    context 'alternative wa- syntax' do
      it 'transforms ::::wa-grid syntax' do
        input = "::::wa-grid gap:m\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-grid wa-gap-m">')
      end

      it 'transforms ::::wa-stack syntax' do
        input = "::::wa-stack\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-stack">')
      end

      it 'transforms ::::wa-split syntax with modifier' do
        input = "::::wa-split row gap:l\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-split:row wa-gap-l">')
      end

      it 'transforms ::::wa-frame syntax with all attributes' do
        input = "::::wa-frame landscape radius:m\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('class="wa-frame:landscape wa-border-radius-m"')
      end
    end

    context 'inner content preservation' do
      it 'preserves inner content without markdown conversion' do
        input = "::::grid gap:l\n:::callout brand\nHello world\n:::\n::::"

        result = described_class.transform(input)
        expect(result).to include(':::callout brand')
        expect(result).to include('Hello world')
        expect(result).to include(':::')
      end

      it 'preserves inner markdown syntax' do
        input = "::::stack\n# Heading\n\n**Bold text** and *italic*\n::::"

        result = described_class.transform(input)
        expect(result).to include('# Heading')
        expect(result).to include('**Bold text**')
      end
    end

    context 'multiple layouts in one document' do
      it 'transforms multiple layouts independently' do
        input = "::::grid gap:l\nGrid content\n::::\n\nSome text\n\n::::stack gap:m\nStack content\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-grid wa-gap-l">')
        expect(result).to include('Grid content')
        expect(result).to include('<div class="wa-stack wa-gap-m">')
        expect(result).to include('Stack content')
      end
    end

    context 'empty layout' do
      it 'transforms layout with empty content' do
        input = "::::grid\n\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-grid">')
        expect(result).to include('</div>')
      end
    end

    context 'unknown tokens' do
      it 'silently ignores unknown keyword tokens' do
        input = "::::grid unknown foo gap:l\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-grid wa-gap-l">')
        expect(result).not_to include('unknown')
        expect(result).not_to include('foo')
      end

      it 'silently ignores unknown key:value tokens' do
        input = "::::grid foo:bar gap:l\nContent\n::::"

        result = described_class.transform(input)
        expect(result).to include('<div class="wa-grid wa-gap-l">')
        expect(result).not_to include('foo')
      end
    end

    context 'CSS value sanitization' do
      it 'strips dangerous characters from CSS values' do
        input = "::::grid min:300px\"onload=alert(1)\nContent\n::::"

        result = described_class.transform(input)
        expect(result).not_to include('"onload')
        expect(result).to include('--min-column-size: 300pxonload=alert(1)')
      end

      it 'strips semicolons from CSS values' do
        input = "::::grid min:300px;background:red\nContent\n::::"

        result = described_class.transform(input)
        expect(result).not_to include(';background')
      end

      it 'strips angle brackets from CSS values' do
        input = "::::flank size:<script>alert(1)</script>\nContent\n::::"

        result = described_class.transform(input)
        expect(result).not_to include('<script>')
      end
    end

    context 'attribute ordering' do
      it 'accepts attributes in any order' do
        input1 = "::::grid gap:l min:300px\nContent\n::::"
        input2 = "::::grid min:300px gap:l\nContent\n::::"

        result1 = described_class.transform(input1)
        result2 = described_class.transform(input2)

        expect(result1).to include('wa-gap-l')
        expect(result1).to include('--min-column-size: 300px')
        expect(result2).to include('wa-gap-l')
        expect(result2).to include('--min-column-size: 300px')
      end

      it 'accepts keyword modifiers before or after key:value pairs' do
        input1 = "::::split row gap:l\nContent\n::::"
        input2 = "::::split gap:l row\nContent\n::::"

        result1 = described_class.transform(input1)
        result2 = described_class.transform(input2)

        expect(result1).to include('wa-split:row')
        expect(result1).to include('wa-gap-l')
        expect(result2).to include('wa-split:row')
        expect(result2).to include('wa-gap-l')
      end
    end
  end
end
