# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::PopoverTransformer do
  describe '.transform' do
    context 'with primary syntax' do
      it 'transforms basic popover with trigger and content' do
        input = <<~MARKDOWN
          &&&
          Hover for info
          >>>
          This is the popover content.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("<wa-button id='popover-")
        expect(result).to include("variant='text'>Hover for info</wa-button>")
        expect(result).to include("<wa-popover for='popover-")
        expect(result).to include("placement='top'")
        expect(result).to include('<p>This is the popover content.</p>')
        expect(result).to include('</wa-popover>')
      end

      it 'supports placement parameter' do
        input = <<~MARKDOWN
          &&&bottom
          Click me
          >>>
          Bottom popover content.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("placement='bottom'")
      end

      it 'supports left placement' do
        input = <<~MARKDOWN
          &&&left
          Info
          >>>
          Left content.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("placement='left'")
      end

      it 'supports right placement' do
        input = <<~MARKDOWN
          &&&right
          Info
          >>>
          Right content.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("placement='right'")
      end

      it 'supports without-arrow flag' do
        input = <<~MARKDOWN
          &&&without-arrow
          Hover
          >>>
          No arrow here.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('without-arrow')
      end

      it 'supports distance parameter' do
        input = <<~MARKDOWN
          &&&distance:10
          Hover
          >>>
          Content with distance.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("distance='10'")
      end

      it 'supports combining placement and without-arrow' do
        input = <<~MARKDOWN
          &&&bottom without-arrow
          Hover
          >>>
          Content.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("placement='bottom'")
        expect(result).to include('without-arrow')
      end

      it 'supports combining all parameters' do
        input = <<~MARKDOWN
          &&&right without-arrow distance:15
          Hover
          >>>
          Content.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("placement='right'")
        expect(result).to include('without-arrow')
        expect(result).to include("distance='15'")
      end

      it 'defaults placement to top when not specified' do
        input = <<~MARKDOWN
          &&&
          Hover
          >>>
          Content.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("placement='top'")
      end

      it 'generates unique IDs for different popovers' do
        input = <<~MARKDOWN
          &&&
          First trigger
          >>>
          First content
          &&&

          &&&
          Second trigger
          >>>
          Second content
          &&&
        MARKDOWN

        result = described_class.transform(input)

        ids = result.scan(/id='(popover-[a-f0-9]+)'/).flatten
        expect(ids.length).to eq(2)
        expect(ids[0]).not_to eq(ids[1])
      end

      it 'generates consistent IDs for same content' do
        input1 = <<~MARKDOWN
          &&&
          Same trigger
          >>>
          Same content
          &&&
        MARKDOWN

        input2 = <<~MARKDOWN
          &&&
          Same trigger
          >>>
          Same content
          &&&
        MARKDOWN

        result1 = described_class.transform(input1)
        result2 = described_class.transform(input2)

        id1 = result1.match(/id='(popover-[a-f0-9]+)'/)[1]
        id2 = result2.match(/id='(popover-[a-f0-9]+)'/)[1]

        expect(id1).to eq(id2)
      end

      it 'preserves markdown formatting in content' do
        input = <<~MARKDOWN
          &&&
          Hover
          >>>
          This has **bold** and *italic* text with [a link](https://example.com).
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('<strong>bold</strong>')
        expect(result).to include('<em>italic</em>')
        expect(result).to include('<a href="https://example.com">a link</a>')
      end

      it 'escapes HTML in trigger text' do
        input = <<~MARKDOWN
          &&&
          Hover <script>alert('xss')</script>
          >>>
          Content
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('&lt;script&gt;')
        expect(result).to include('alert(&#39;xss&#39;)')
        expect(result).not_to match(/<script>alert/)
      end
    end

    context 'with alternative syntax' do
      it 'transforms basic popover' do
        input = <<~MARKDOWN
          :::wa-popover
          Hover for info
          >>>
          This is the popover content.
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("<wa-button id='popover-")
        expect(result).to include("variant='text'>Hover for info</wa-button>")
        expect(result).to include("<wa-popover for='popover-")
        expect(result).to include('<p>This is the popover content.</p>')
      end

      it 'supports placement parameter' do
        input = <<~MARKDOWN
          :::wa-popover bottom
          Click me
          >>>
          Bottom content.
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("placement='bottom'")
      end

      it 'supports without-arrow flag' do
        input = <<~MARKDOWN
          :::wa-popover without-arrow
          Hover
          >>>
          No arrow.
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include('without-arrow')
      end

      it 'supports distance parameter' do
        input = <<~MARKDOWN
          :::wa-popover distance:20
          Hover
          >>>
          Content.
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("distance='20'")
      end
    end

    context 'with mixed syntax in same content' do
      it 'transforms both primary and alternative syntax' do
        input = <<~MARKDOWN
          &&&
          First Popover
          >>>
          Primary syntax
          &&&

          :::wa-popover
          Second Popover
          >>>
          Alternative syntax
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("variant='text'>First Popover</wa-button>")
        expect(result).to include("variant='text'>Second Popover</wa-button>")
        expect(result).to include('<p>Primary syntax</p>')
        expect(result).to include('<p>Alternative syntax</p>')
      end
    end

    context 'with link trigger style' do
      it 'renders a link-styled button instead of wa-button' do
        input = <<~MARKDOWN
          &&&link
          Learn more
          >>>
          Additional details here.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("<button id='popover-")
        expect(result).to include('text-decoration: underline')
        expect(result).to include('cursor: pointer')
        expect(result).to include('>Learn more</button>')
        expect(result).not_to include('<wa-button')
      end

      it 'combines link with placement' do
        input = <<~MARKDOWN
          &&&bottom link
          More info
          >>>
          Popover below.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("<button id='popover-")
        expect(result).to include('text-decoration: underline')
        expect(result).to include("placement='bottom'")
        expect(result).not_to include('<wa-button')
      end

      it 'combines link with without-arrow and distance' do
        input = <<~MARKDOWN
          &&&link without-arrow distance:5
          Hover here
          >>>
          Content.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("<button id='popover-")
        expect(result).to include('text-decoration: underline')
        expect(result).to include('without-arrow')
        expect(result).to include("distance='5'")
      end

      it 'works with alternative syntax' do
        input = <<~MARKDOWN
          :::wa-popover link bottom
          Click for details
          >>>
          Details here.
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("<button id='popover-")
        expect(result).to include('text-decoration: underline')
        expect(result).to include("placement='bottom'")
        expect(result).not_to include('<wa-button')
      end
    end

    context 'with inline syntax' do
      it 'transforms basic inline popover' do
        result = described_class.transform('&&&Peppol >>> A standardized e-invoicing network&&&')

        expect(result).to include("<button id='popover-")
        expect(result).to include('text-decoration: underline')
        expect(result).to include('>Peppol</button>')
        expect(result).to include("<wa-popover for='popover-")
        expect(result).to include('A standardized e-invoicing network</wa-popover>')
        expect(result).not_to include('<wa-button')
      end

      it 'works within a sentence' do
        input = 'Send invoices via &&&Peppol >>> A standardized network&&& to your customers.'
        result = described_class.transform(input)

        expect(result).to start_with('Send invoices via <button')
        expect(result).to end_with('</wa-popover> to your customers.')
      end

      it 'supports placement parameter' do
        result = described_class.transform('&&&bottom Peppol >>> Description&&&')

        expect(result).to include("placement='bottom'")
        expect(result).to include('>Peppol</button>')
      end

      it 'supports without-arrow flag' do
        result = described_class.transform('&&&without-arrow Peppol >>> Description&&&')

        expect(result).to include('without-arrow')
        expect(result).to include('>Peppol</button>')
      end

      it 'supports distance parameter' do
        result = described_class.transform('&&&distance:10 Peppol >>> Description&&&')

        expect(result).to include("distance='10'")
        expect(result).to include('>Peppol</button>')
      end

      it 'supports combined parameters' do
        result = described_class.transform('&&&right without-arrow distance:5 API keys >>> Authenticate your requests&&&')

        expect(result).to include("placement='right'")
        expect(result).to include('without-arrow')
        expect(result).to include("distance='5'")
        expect(result).to include('>API keys</button>')
      end

      it 'handles multi-word trigger text' do
        result = described_class.transform('&&&API authentication >>> Details about auth&&&')

        expect(result).to include('>API authentication</button>')
      end

      it 'handles multiple inline popovers on one line' do
        input = 'Learn about &&&Peppol >>> Network&&& and &&&SFTP >>> File transfer&&&'
        result = described_class.transform(input)

        expect(result).to include('>Peppol</button>')
        expect(result).to include('>SFTP</button>')
        expect(result).to include('Network</wa-popover>')
        expect(result).to include('File transfer</wa-popover>')
      end

      it 'always renders link style trigger' do
        result = described_class.transform('&&&Trigger >>> Content&&&')

        expect(result).to include('<button')
        expect(result).to include('text-decoration: underline')
        expect(result).not_to include('<wa-button')
      end

      it 'escapes HTML in trigger text' do
        result = described_class.transform("&&&<script>alert('xss')</script> >>> Content&&&")

        expect(result).to include('&lt;script&gt;')
        expect(result).not_to match(/<script>alert/)
      end

      it 'escapes HTML in popover content' do
        result = described_class.transform('&&&Trigger >>> <b>bold</b> & "quotes"&&&')

        expect(result).to include('&lt;b&gt;bold&lt;/b&gt;')
        expect(result).to include('&amp;')
        expect(result).to include('&quot;quotes&quot;')
      end

      it 'does not match across newlines' do
        input = "&&&Trigger\n>>> Content&&&"
        result = described_class.transform(input)

        # Should not produce inline popover - the newline prevents inline match
        expect(result).not_to include('text-decoration: underline')
      end

      it 'generates consistent IDs for same trigger and content' do
        result1 = described_class.transform('&&&Term >>> Definition&&&')
        result2 = described_class.transform('&&&Term >>> Definition&&&')

        id1 = result1.match(/id='(popover-[a-f0-9]+)'/)[1]
        id2 = result2.match(/id='(popover-[a-f0-9]+)'/)[1]

        expect(id1).to eq(id2)
      end

      it 'links popover to trigger via matching for/id attributes' do
        result = described_class.transform('&&&Term >>> Definition&&&')

        id = result.match(/id='(popover-[a-f0-9]+)'/)[1]
        expect(result).to include("for='#{id}'")
      end

      it 'converts backslash-n in content to br tags' do
        result = described_class.transform('&&&Trigger >>> Line one\nLine two&&&')

        expect(result).to include('Line one<br>Line two')
      end

      it 'converts multiple backslash-n sequences to multiple br tags' do
        result = described_class.transform('&&&Trigger >>> NO: Org number\nSE: Org number\nDK: CVR&&&')

        expect(result).to include('NO: Org number<br>SE: Org number<br>DK: CVR')
      end

      it 'does not convert backslash-n in trigger text' do
        result = described_class.transform('&&&Trigger\ntext >>> Content&&&')

        # The \n in the trigger area should not be converted - and since inline
        # popovers don't match across real newlines, this shouldn't match at all
        # if it were a real newline. With literal \n in trigger, it stays as-is.
        expect(result).to include('>Trigger\\ntext</button>')
      end

      it 'defaults placement to top' do
        result = described_class.transform('&&&Trigger >>> Content&&&')

        expect(result).to include("placement='top'")
      end

      it 'outputs trigger and popover on same line without newlines' do
        result = described_class.transform('&&&Trigger >>> Content&&&')

        # The entire output should be a single line
        expect(result).not_to include("\n")
      end
    end

    context 'with mixed inline and block syntax' do
      it 'transforms both inline and block popovers in same content' do
        input = <<~MARKDOWN
          Read about &&&Peppol >>> E-invoicing network&&& in our docs.

          &&&
          Detailed info
          >>>
          This is a longer explanation with **markdown** support.
          &&&
        MARKDOWN

        result = described_class.transform(input)

        # Inline popover (link style)
        expect(result).to include('>Peppol</button>')
        expect(result).to include('E-invoicing network</wa-popover>')

        # Block popover (button style)
        expect(result).to include("variant='text'>Detailed info</wa-button>")
        expect(result).to include('<strong>markdown</strong>')
      end
    end

    context 'edge cases' do
      it 'handles popover with minimal content' do
        input = <<~MARKDOWN
          &&&
          OK
          >>>
          OK
          &&&
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to include("<wa-button id='popover-")
        expect(result).to include("variant='text'>OK</wa-button>")
        expect(result).to include('<wa-popover')
      end

      it 'does not transform incomplete syntax' do
        input = <<~MARKDOWN
          &&&
          Missing separator and end
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to eq(input)
      end

      it 'links popover to trigger via matching for/id attributes' do
        input = <<~MARKDOWN
          &&&
          Hover
          >>>
          Content
          &&&
        MARKDOWN

        result = described_class.transform(input)

        id = result.match(/id='(popover-[a-f0-9]+)'/)[1]
        expect(result).to include("for='#{id}'")
      end
    end
  end
end
