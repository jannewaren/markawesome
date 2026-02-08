# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::CopyButtonTransformer do
  describe '.transform' do
    context 'with primary syntax' do
      it 'transforms simple copy button' do
        input = "<<<\nCopy this text\n<<<"
        expected = '<wa-copy-button value="Copy this text"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms copy button with longer content' do
        input = "<<<\nThis is a longer text that should be copied to clipboard\n<<<"
        expected = '<wa-copy-button value="This is a longer text that should be copied to clipboard"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with alternative syntax' do
      it 'transforms simple copy button' do
        input = ":::wa-copy-button\nCopy this text\n:::"
        expected = '<wa-copy-button value="Copy this text"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms copy button with longer content' do
        input = ":::wa-copy-button\nAnother text to copy\n:::"
        expected = '<wa-copy-button value="Another text to copy"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with markdown content' do
      it 'handles bold text in copy button content' do
        input = "<<<\n**Bold text** to copy\n<<<"
        expected = '<wa-copy-button value="**Bold text** to copy"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles italic text in copy button content' do
        input = "<<<\n*Italic text* to copy\n<<<"
        expected = '<wa-copy-button value="*Italic text* to copy"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles code in copy button content' do
        input = "<<<\nCopy this `code snippet`\n<<<"
        expected = '<wa-copy-button value="Copy this `code snippet`"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with special characters' do
      it 'escapes double quotes in value attribute' do
        input = "<<<\nText with \"quotes\"\n<<<"
        expected = '<wa-copy-button value="Text with &quot;quotes&quot;"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles content with various characters' do
        input = "<<<\nSpecial chars: @#$%^&*()\n<<<"
        expected = '<wa-copy-button value="Special chars: @#$%^&*()"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with multiline content' do
      it 'handles multiline content correctly' do
        input = "<<<\nLine 1\nLine 2\nLine 3\n<<<"
        result = described_class.transform(input)

        expect(result).to start_with('<wa-copy-button value="Line 1')
        expect(result).to include('Line 2')
        expect(result).to include('Line 3')
        expect(result).to end_with('"></wa-copy-button>')
      end
    end

    context 'with surrounding content' do
      it 'transforms copy button in text context' do
        input = "Here is some text\n\n<<<\nCopy me\n<<<\n\nAnd more text"
        expected = "Here is some text\n\n<wa-copy-button value=\"Copy me\"></wa-copy-button>\n\nAnd more text"

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms multiple copy buttons' do
        input = "<<<\nFirst copy\n<<<\n\n<<<\nSecond copy\n<<<"
        expected = "<wa-copy-button value=\"First copy\"></wa-copy-button>\n\n<wa-copy-button value=\"Second copy\"></wa-copy-button>"

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with edge cases' do
      it 'handles empty content' do
        input = "<<<\n\n<<<"
        expected = '<wa-copy-button value=""></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles whitespace-only content' do
        input = "<<<\n   \n<<<"
        expected = '<wa-copy-button value=""></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'does not transform incomplete syntax' do
        input = "<<<\nIncomplete"
        expected = "<<<\nIncomplete"

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'does not transform if closing delimiter is missing' do
        input = "<<<\nNo closing delimiter\n"
        expected = "<<<\nNo closing delimiter\n"

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with tooltip placement' do
      it 'supports top placement' do
        input = "<<<top\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="top"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports right placement' do
        input = "<<<right\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="right"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports bottom placement' do
        input = "<<<bottom\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="bottom"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports left placement' do
        input = "<<<left\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="left"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with custom labels' do
      it 'supports copy-label' do
        input = "<<<copy-label=\"Click to copy\"\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" copy-label="Click to copy"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports success-label' do
        input = "<<<success-label=\"Copied!\"\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" success-label="Copied!"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports error-label' do
        input = "<<<error-label=\"Error copying\"\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" error-label="Error copying"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports all three labels together' do
        input = "<<<copy-label=\"Click\" success-label=\"Done\" error-label=\"Failed\"\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" copy-label="Click" success-label="Done" error-label="Failed"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles labels with single quotes' do
        input = "<<<copy-label='Click to copy'\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" copy-label="Click to copy"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with feedback duration' do
      it 'supports custom feedback duration' do
        input = "<<<2000\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" feedback-duration="2000"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports short duration' do
        input = "<<<250\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" feedback-duration="250"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines duration with placement' do
        input = "<<<right 3000\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="right" feedback-duration="3000"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with disabled flag' do
      it 'supports disabled flag' do
        input = "<<<disabled\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" disabled></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines disabled with placement' do
        input = "<<<disabled bottom\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="bottom" disabled></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines disabled with all attributes' do
        input = "<<<disabled top 1500 copy-label=\"Click\"\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="top" copy-label="Click" feedback-duration="1500" disabled></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with from attribute' do
      it 'supports from attribute to copy from element' do
        input = "<<<from=\"my-element\"\nFallback text\n<<<"
        expected = '<wa-copy-button from="my-element"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports from with property accessor' do
        input = "<<<from=\"my-input.value\"\nFallback text\n<<<"
        expected = '<wa-copy-button from="my-input.value"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports from with attribute accessor' do
        input = "<<<from=\"my-link[href]\"\nFallback text\n<<<"
        expected = '<wa-copy-button from="my-link[href]"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines from with placement' do
        input = "<<<from=\"my-element\" right\nFallback text\n<<<"
        expected = '<wa-copy-button from="my-element" tooltip-placement="right"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with combined attributes' do
      it 'handles multiple attributes in any order' do
        input = "<<<top disabled 2000\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="top" feedback-duration="2000" disabled></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles placement, labels, and duration together' do
        input = "<<<bottom 1500 copy-label=\"Copy\" success-label=\"Success\"\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="bottom" copy-label="Copy" success-label="Success" feedback-duration="1500"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles all attributes together' do
        input = "<<<disabled right 3000 copy-label=\"Click\" success-label=\"Done\" error-label=\"Failed\"\nCopy this\n<<<"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="right" copy-label="Click" success-label="Done" error-label="Failed" feedback-duration="3000" disabled></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with alternative syntax and attributes' do
      it 'supports placement with alternative syntax' do
        input = ":::wa-copy-button left\nCopy this\n:::"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="left"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports labels with alternative syntax' do
        input = ":::wa-copy-button copy-label=\"Click to copy\"\nCopy this\n:::"
        expected = '<wa-copy-button value="Copy this" copy-label="Click to copy"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports disabled with alternative syntax' do
        input = ":::wa-copy-button disabled\nCopy this\n:::"
        expected = '<wa-copy-button value="Copy this" disabled></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports from with alternative syntax' do
        input = ":::wa-copy-button from=\"my-element\"\nFallback\n:::"
        expected = '<wa-copy-button from="my-element"></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'supports combined attributes with alternative syntax' do
        input = ":::wa-copy-button right disabled 2000\nCopy this\n:::"
        expected = '<wa-copy-button value="Copy this" tooltip-placement="right" feedback-duration="2000" disabled></wa-copy-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with attribute order independence' do
      it 'produces same result regardless of order (placement first)' do
        input1 = "<<<top disabled\nCopy this\n<<<"
        input2 = "<<<disabled top\nCopy this\n<<<"

        result1 = described_class.transform(input1)
        result2 = described_class.transform(input2)

        expect(result1).to eq(result2)
      end

      it 'produces same result regardless of order (complex)' do
        input1 = "<<<right 1000 disabled\nCopy this\n<<<"
        input2 = "<<<disabled 1000 right\nCopy this\n<<<"
        input3 = "<<<1000 right disabled\nCopy this\n<<<"

        result1 = described_class.transform(input1)
        result2 = described_class.transform(input2)
        result3 = described_class.transform(input3)

        expect(result1).to eq(result2)
        expect(result2).to eq(result3)
      end
    end
  end
end
