# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::TagTransformer do
  describe '.transform' do
    context 'with basic tag syntax' do
      it 'transforms simple tag without variant' do
        input = "@@@\nBasic tag\n@@@"
        expected = '<wa-tag>Basic tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with brand variant' do
        input = "@@@brand\nVersion 2.0\n@@@"
        expected = '<wa-tag variant="brand">Version 2.0</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with success variant' do
        input = "@@@success\nCompleted\n@@@"
        expected = '<wa-tag variant="success">Completed</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with warning variant' do
        input = "@@@warning\nIn Progress\n@@@"
        expected = '<wa-tag variant="warning">In Progress</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with danger variant' do
        input = "@@@danger\nCritical\n@@@"
        expected = '<wa-tag variant="danger">Critical</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with neutral variant' do
        input = "@@@neutral\nDocumentation\n@@@"
        expected = '<wa-tag variant="neutral">Documentation</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with appearance attribute' do
      it 'transforms tag with accent appearance' do
        input = "@@@accent\nTag\n@@@"
        expected = '<wa-tag appearance="accent">Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with filled appearance' do
        input = "@@@filled\nTag\n@@@"
        expected = '<wa-tag appearance="filled">Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with outlined appearance' do
        input = "@@@outlined\nTag\n@@@"
        expected = '<wa-tag appearance="outlined">Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with filled-outlined appearance' do
        input = "@@@filled-outlined\nTag\n@@@"
        expected = '<wa-tag appearance="filled-outlined">Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with variant and appearance' do
        input = "@@@brand accent\nTag\n@@@"
        expected = '<wa-tag variant="brand" appearance="accent">Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with size attribute' do
      it 'transforms tag with small size' do
        input = "@@@small\nTag\n@@@"
        expected = '<wa-tag size="small">Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with medium size' do
        input = "@@@medium\nTag\n@@@"
        expected = '<wa-tag size="medium">Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with large size' do
        input = "@@@large\nTag\n@@@"
        expected = '<wa-tag size="large">Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with variant and size' do
        input = "@@@success large\nTag\n@@@"
        expected = '<wa-tag variant="success" size="large">Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with pill attribute' do
      it 'transforms tag with pill attribute' do
        input = "@@@pill\nTag\n@@@"
        expected = '<wa-tag pill>Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with variant and pill' do
        input = "@@@brand pill\nTag\n@@@"
        expected = '<wa-tag variant="brand" pill>Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with size and pill' do
        input = "@@@small pill\nTag\n@@@"
        expected = '<wa-tag size="small" pill>Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with with-remove attribute' do
      it 'transforms tag with with-remove attribute' do
        input = "@@@with-remove\nTag\n@@@"
        expected = '<wa-tag with-remove>Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with variant and with-remove' do
        input = "@@@danger with-remove\nTag\n@@@"
        expected = '<wa-tag variant="danger" with-remove>Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with size and with-remove' do
        input = "@@@large with-remove\nTag\n@@@"
        expected = '<wa-tag size="large" with-remove>Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with multiple attributes' do
      it 'transforms tag with variant, appearance, and size' do
        input = "@@@brand accent small\nTag\n@@@"
        expected = '<wa-tag variant="brand" appearance="accent" size="small">Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with all attributes' do
        input = "@@@success filled large pill with-remove\nTag\n@@@"
        expected = '<wa-tag variant="success" appearance="filled" size="large" pill with-remove>Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with attributes in different order' do
        input = "@@@pill large brand filled\nTag\n@@@"
        expected = '<wa-tag variant="brand" appearance="filled" size="large" pill>Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles rightmost-wins for duplicate attribute types' do
        input = "@@@small large\nTag\n@@@"
        expected = '<wa-tag size="large">Tag</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with icon support' do
      it 'transforms tag with icon (block syntax)' do
        input = "@@@brand icon:check\nApproved\n@@@"
        expected = '<wa-tag variant="brand"><wa-icon name="check"></wa-icon>Approved</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag with icon and multiple attributes' do
        input = "@@@success icon:circle-check large pill\nPassed\n@@@"
        expected = '<wa-tag variant="success" size="large" pill><wa-icon name="circle-check"></wa-icon>Passed</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms tag without icon (existing behavior preserved)' do
        input = "@@@brand\nVersion 2.0\n@@@"
        expected = '<wa-tag variant="brand">Version 2.0</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with icon' do
        input = 'Status: @@@ success icon:check Done @@@'
        expected = 'Status: <wa-tag variant="success"><wa-icon name="check"></wa-icon>Done</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with icon and pill' do
        input = 'Check @@@ brand icon:star pill Featured @@@ here'
        expected = 'Check <wa-tag variant="brand" pill><wa-icon name="star"></wa-icon>Featured</wa-tag> here'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles icon with hyphenated name' do
        input = "@@@danger icon:circle-xmark\nFailed\n@@@"
        expected = '<wa-tag variant="danger"><wa-icon name="circle-xmark"></wa-icon>Failed</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'icon has no slot attribute (content icon)' do
        input = "@@@icon:gear\nSettings\n@@@"
        result = described_class.transform(input)

        expect(result).to include('<wa-icon name="gear"></wa-icon>')
        expect(result).not_to include('slot=')
      end
    end

    context 'with markdown content' do
      it 'handles markdown formatting within tags' do
        input = "@@@success\n**Bold** text\n@@@"
        expected = '<wa-tag variant="success"><strong>Bold</strong> text</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles links within tags' do
        input = "@@@brand\n[Link](https://example.com)\n@@@"
        expected = '<wa-tag variant="brand"><a href="https://example.com">Link</a></wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'removes paragraph tags for simple text' do
        input = "@@@neutral\nSimple text\n@@@"
        expected = '<wa-tag variant="neutral">Simple text</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with multiple tags' do
      it 'transforms multiple tags in content' do
        input = <<~MARKDOWN
          @@@success
          Done
          @@@

          Some content here.

          @@@warning
          In Progress
          @@@
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-tag variant="success">Done</wa-tag>')
        expect(result).to include('<wa-tag variant="warning">In Progress</wa-tag>')
        expect(result).to include('Some content here.')
      end
    end

    context 'with invalid syntax' do
      it 'treats invalid tokens as content when no valid attributes present' do
        input = "@@@invalid\nText\n@@@"
        # "invalid" is not a recognized attribute, so it becomes part of content
        # But since it's on the params line (before newline), it's treated as a param token
        # that doesn't match anything, so only "Text" remains as content
        expected = '<wa-tag>Text</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'does not transform incomplete tag syntax' do
        input = "@@@success\nIncomplete tag"

        result = described_class.transform(input)
        expect(result).to eq(input) # Should remain unchanged
      end

      it 'does not transform inline @ symbols' do
        input = 'Contact us @@@example.com for help'

        result = described_class.transform(input)
        expect(result).to eq(input) # Should remain unchanged
      end

      it 'does not leave orphaned variant text when syntax is incomplete' do
        input = <<~MARKDOWN
          @@@brand
          Text content

          More paragraphs
        MARKDOWN

        result = described_class.transform(input)
        # Should not transform since there's no closing @@@
        expect(result).to eq(input)
        expect(result).not_to include('<wa-tag')
      end

      it 'does not leave orphaned variant with blank line after variant' do
        input = "@@@brand\n\nText\n@@@"
        expected = '<wa-tag variant="brand">Text</wa-tag>'

        result = described_class.transform(input)
        # This should still work - blank lines in content are OK
        expect(result).to eq(expected)
      end
    end

    context 'with whitespace handling' do
      it 'trims whitespace from tag content' do
        input = "@@@brand\n  Version 2.0  \n@@@"
        expected = '<wa-tag variant="brand">Version 2.0</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles multiline content' do
        input = "@@@neutral\nLine one\nLine two\n@@@"
        expected = '<wa-tag variant="neutral">Line one
Line two</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles CRLF (Windows) line endings' do
        input = "@@@brand\r\nVersion 2.0\r\n@@@"
        expected = '<wa-tag variant="brand">Version 2.0</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles multiline content with CRLF line endings' do
        input = "@@@danger\r\nLine one\r\nLine two\r\n@@@"
        expected = '<wa-tag variant="danger">Line one
Line two</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles mixed LF and CRLF line endings' do
        input = "@@@success\r\nCompleted\n@@@"
        expected = '<wa-tag variant="success">Completed</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with inline syntax' do
      it 'transforms inline tag without variant' do
        input = 'Some text @@@ Basic tag @@@ more text'
        expected = 'Some text <wa-tag>Basic tag</wa-tag> more text'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with brand variant' do
        input = 'Check out @@@ brand Version 2.0 @@@ for details'
        expected = 'Check out <wa-tag variant="brand">Version 2.0</wa-tag> for details'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with success variant' do
        input = 'Status: @@@ success Completed @@@'
        expected = 'Status: <wa-tag variant="success">Completed</wa-tag>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with warning variant' do
        input = 'Note @@@ warning In Progress @@@ today'
        expected = 'Note <wa-tag variant="warning">In Progress</wa-tag> today'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with danger variant' do
        input = 'Alert: @@@ danger Critical @@@ issue'
        expected = 'Alert: <wa-tag variant="danger">Critical</wa-tag> issue'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with neutral variant' do
        input = 'See @@@ neutral Documentation @@@ for more'
        expected = 'See <wa-tag variant="neutral">Documentation</wa-tag> for more'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with appearance' do
        input = 'Check @@@ accent Tag @@@ here'
        expected = 'Check <wa-tag appearance="accent">Tag</wa-tag> here'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with size' do
        input = 'Check @@@ small Tag @@@ here'
        expected = 'Check <wa-tag size="small">Tag</wa-tag> here'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with pill' do
        input = 'Check @@@ pill Tag @@@ here'
        expected = 'Check <wa-tag pill>Tag</wa-tag> here'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with with-remove' do
        input = 'Check @@@ with-remove Tag @@@ here'
        expected = 'Check <wa-tag with-remove>Tag</wa-tag> here'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms inline tag with multiple attributes' do
        input = 'Check @@@ brand accent small pill Tag @@@ here'
        expected = 'Check <wa-tag variant="brand" appearance="accent" size="small" pill>Tag</wa-tag> here'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'works in headings' do
        input = '## Feature @@@ brand v2.0 @@@ Released'
        expected = '## Feature <wa-tag variant="brand">v2.0</wa-tag> Released'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'works in multiple headings' do
        input = <<~MARKDOWN
          # Main Title @@@ success New @@@

          Some content here.

          ## Section @@@ warning Beta @@@ Overview
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('# Main Title <wa-tag variant="success">New</wa-tag>')
        expect(result).to include('## Section <wa-tag variant="warning">Beta</wa-tag> Overview')
      end

      it 'handles multiple inline tags in same line' do
        input = 'Status @@@ success Done @@@ and @@@ warning Pending @@@ items'
        expected = 'Status <wa-tag variant="success">Done</wa-tag> and <wa-tag variant="warning">Pending</wa-tag> items'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles inline tags with markdown content' do
        input = 'Check @@@ brand **Bold** text @@@ here'
        expected = 'Check <wa-tag variant="brand"><strong>Bold</strong> text</wa-tag> here'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'trims extra whitespace in inline tags' do
        input = 'Text @@@  brand   Version   @@@  end'
        expected = 'Text <wa-tag variant="brand">Version</wa-tag>  end'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'does not confuse inline with block syntax' do
        input = <<~MARKDOWN
          Inline @@@ success Tag @@@ here

          @@@warning
          Block tag
          @@@
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('Inline <wa-tag variant="success">Tag</wa-tag> here')
        expect(result).to include('<wa-tag variant="warning">Block tag</wa-tag>')
      end
    end
  end
end
