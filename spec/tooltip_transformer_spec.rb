# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::TooltipTransformer do
  describe '.transform' do
    context 'with inline syntax' do
      it 'transforms a basic inline tooltip' do
        result = described_class.transform('(((CSS >>> Cascading Style Sheets)))')

        expect(result).to include('<span id="tooltip-')
        expect(result).to include('tabindex="0"')
        expect(result).to include('class="ma-tooltip-anchor"')
        expect(result).to include('text-decoration: underline dotted; cursor: help;')
        expect(result).to include('>CSS</span>')
        expect(result).to include('<wa-tooltip for="tooltip-')
        expect(result).to include('placement="top"')
        expect(result).to include('Cascading Style Sheets</wa-tooltip>')
      end

      it 'works within a sentence' do
        input = 'Styling is handled by (((CSS >>> Cascading Style Sheets))) on the web.'
        result = described_class.transform(input)

        expect(result).to start_with('Styling is handled by <span')
        expect(result).to end_with('</wa-tooltip> on the web.')
      end

      it 'defaults placement to top' do
        result = described_class.transform('(((Term >>> Definition)))')

        expect(result).to include('placement="top"')
      end

      it 'supports bottom placement' do
        result = described_class.transform('(((bottom Term >>> Definition)))')

        expect(result).to include('placement="bottom"')
        expect(result).to include('>Term</span>')
      end

      it 'supports left placement' do
        result = described_class.transform('(((left Term >>> Definition)))')

        expect(result).to include('placement="left"')
      end

      it 'supports right placement' do
        result = described_class.transform('(((right Term >>> Definition)))')

        expect(result).to include('placement="right"')
      end

      it 'supports the distance parameter' do
        result = described_class.transform('(((distance:10 Term >>> Definition)))')

        expect(result).to include('distance="10"')
        expect(result).to include('>Term</span>')
      end

      it 'supports combined placement and distance parameters' do
        result = described_class.transform('(((bottom distance:15 API >>> Application Programming Interface)))')

        expect(result).to include('placement="bottom"')
        expect(result).to include('distance="15"')
        expect(result).to include('>API</span>')
      end

      it 'handles multi-word anchor text' do
        result = described_class.transform('(((API authentication >>> Verifying who is calling)))')

        expect(result).to include('>API authentication</span>')
      end

      it 'handles multiple inline tooltips on one line' do
        input = 'Learn about (((CSS >>> Cascading Style Sheets))) and (((HTML >>> HyperText Markup Language)))'
        result = described_class.transform(input)

        expect(result).to include('>CSS</span>')
        expect(result).to include('>HTML</span>')
        expect(result).to include('Cascading Style Sheets</wa-tooltip>')
        expect(result).to include('HyperText Markup Language</wa-tooltip>')
      end

      it 'escapes HTML in anchor text' do
        result = described_class.transform("(((<script>alert('xss')</script> >>> Definition)))")

        expect(result).to include('&lt;script&gt;')
        expect(result).not_to match(/<script>alert/)
      end

      it 'escapes HTML in tip text' do
        result = described_class.transform('(((Term >>> <b>bold</b> & "quotes")))')

        expect(result).to include('&lt;b&gt;bold&lt;/b&gt;')
        expect(result).to include('&amp;')
        expect(result).to include('&quot;quotes&quot;')
      end

      it 'converts backslash-n in tip to br tags' do
        result = described_class.transform('(((Term >>> Line one\nLine two)))')

        expect(result).to include('Line one<br>Line two')
      end

      it 'converts multiple backslash-n sequences to multiple br tags' do
        result = described_class.transform('(((Org numbers >>> NO: 9 digits\nSE: 10 digits\nDK: CVR)))')

        expect(result).to include('NO: 9 digits<br>SE: 10 digits<br>DK: CVR')
      end

      it 'does not convert backslash-n in anchor text' do
        result = described_class.transform('(((Term\nanchor >>> Definition)))')

        expect(result).to include('>Term\\nanchor</span>')
      end

      it 'does not match across newlines' do
        input = "(((Term\n>>> Definition)))"
        result = described_class.transform(input)

        expect(result).not_to include('ma-tooltip-anchor')
      end

      it 'outputs anchor and tooltip on the same line without newlines' do
        result = described_class.transform('(((Term >>> Definition)))')

        expect(result).not_to include("\n")
      end

      it 'links tooltip to anchor via matching for/id attributes' do
        result = described_class.transform('(((Term >>> Definition)))')

        id = result.match(/id="(tooltip-[a-f0-9]+)"/)[1]
        expect(result).to include("for=\"#{id}\"")
      end

      it 'generates consistent IDs for same anchor and tip' do
        result1 = described_class.transform('(((Term >>> Definition)))')
        result2 = described_class.transform('(((Term >>> Definition)))')

        id1 = result1.match(/id="(tooltip-[a-f0-9]+)"/)[1]
        id2 = result2.match(/id="(tooltip-[a-f0-9]+)"/)[1]

        expect(id1).to eq(id2)
      end

      it 'generates unique IDs for different tooltips' do
        input = 'See (((CSS >>> Cascading Style Sheets))) and (((HTML >>> HyperText Markup Language)))'
        result = described_class.transform(input)

        ids = result.scan(/id="(tooltip-[a-f0-9]+)"/).flatten
        expect(ids.length).to eq(2)
        expect(ids[0]).not_to eq(ids[1])
      end

      it 'disambiguates duplicate inline tooltips within the same document' do
        input = 'See (((Term >>> Definition))) and again (((Term >>> Definition))).'
        result = described_class.transform(input)

        ids = result.scan(/id="(tooltip-[a-f0-9-]+)"/).flatten
        expect(ids.length).to eq(2)
        expect(ids.uniq.length).to eq(2)
        expect(ids[1]).to end_with('-2')
        ids.each { |id| expect(result).to include("for=\"#{id}\"") }
      end

      it 'leaves incomplete inline syntax untouched' do
        input = '(((Term without separator)))'
        result = described_class.transform(input)

        expect(result).to eq(input)
      end
    end

    context 'with alternative block syntax' do
      it 'transforms a basic block tooltip' do
        input = <<~MARKDOWN
          :::wa-tooltip
          CSS
          >>>
          Cascading Style Sheets
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('<span id="tooltip-')
        expect(result).to include('class="ma-tooltip-anchor"')
        expect(result).to include('>CSS</span>')
        expect(result).to include('<wa-tooltip for="tooltip-')
        expect(result).to include('placement="top"')
        expect(result).to include('Cascading Style Sheets</wa-tooltip>')
      end

      it 'supports placement parameter' do
        input = <<~MARKDOWN
          :::wa-tooltip bottom
          Term
          >>>
          Definition
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('placement="bottom"')
      end

      it 'supports the distance parameter' do
        input = <<~MARKDOWN
          :::wa-tooltip distance:20
          Term
          >>>
          Definition
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('distance="20"')
      end

      it 'supports combined parameters' do
        input = <<~MARKDOWN
          :::wa-tooltip right distance:8
          Term
          >>>
          Definition
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('placement="right"')
        expect(result).to include('distance="8"')
      end

      it 'escapes HTML in anchor and tip' do
        input = <<~MARKDOWN
          :::wa-tooltip
          <b>Term</b>
          >>>
          A & B "quoted"
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('&lt;b&gt;Term&lt;/b&gt;')
        expect(result).to include('&amp;')
        expect(result).to include('&quot;quoted&quot;')
      end
    end

    context 'with mixed inline and block syntax' do
      it 'transforms both inline and block tooltips in the same content' do
        input = <<~MARKDOWN
          Read about (((CSS >>> Cascading Style Sheets))) inline.

          :::wa-tooltip bottom
          HTML
          >>>
          HyperText Markup Language
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('>CSS</span>')
        expect(result).to include('Cascading Style Sheets</wa-tooltip>')
        expect(result).to include('>HTML</span>')
        expect(result).to include('placement="bottom"')
        expect(result).to include('HyperText Markup Language</wa-tooltip>')
      end
    end

    context 'edge cases' do
      it 'does not transform incomplete block syntax' do
        input = <<~MARKDOWN
          :::wa-tooltip
          Missing separator and end
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to eq(input)
      end
    end
  end
end
