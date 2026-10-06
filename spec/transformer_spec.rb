# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::Transformer do
  describe '.process' do
    it 'processes badge syntax' do
      input = "!!!\nNew\n!!!"
      result = described_class.process(input)
      expect(result).to include('<wa-badge>New</wa-badge>')
    end

    it 'processes button syntax' do
      input = "%%%\nClick Me\n%%%"
      result = described_class.process(input)
      expect(result).to include('<wa-button>Click Me</wa-button>')
    end

    it 'processes callout syntax' do
      input = ":::info\nImportant information\n:::"
      result = described_class.process(input)
      expect(result).to include('<wa-callout')
      expect(result).to include('Important information')
    end

    it 'processes card syntax' do
      input = "===\nCard content\n==="
      result = described_class.process(input)
      expect(result).to include('<wa-card')
    end

    it 'processes copy button syntax' do
      input = "<<<\nCopy this\n<<<"
      result = described_class.process(input)
      expect(result).to include('<wa-copy-button')
    end

    it 'processes details syntax' do
      input = "^^^\nSummary\n>>>\nDetails\n^^^"
      result = described_class.process(input)
      expect(result).to include('<wa-details')
    end

    it 'processes dialog syntax' do
      input = "???\nOpen\n>>>\nDialog content\n???"
      result = described_class.process(input)
      expect(result).to include('<wa-dialog')
    end

    it 'processes icon syntax' do
      input = '$$$home'
      result = described_class.process(input)
      expect(result).to include('<wa-icon name="home">')
    end

    it 'processes tag syntax' do
      input = "@@@\nTag\n@@@"
      result = described_class.process(input)
      expect(result).to include('<wa-tag>Tag</wa-tag>')
    end

    it 'processes a labeled divider' do
      expect(described_class.process('--- or ---')).to eq('<wa-divider>or</wa-divider>')
    end

    it 'processes a vertical divider inside a cluster layout' do
      input = "::::cluster\n%%%\nYes\n%%%\n--- vertical vs ---\n%%%\nNo\n%%%\n::::"
      result = described_class.process(input)
      expect(result).to eq(
        "<div class=\"wa-cluster\">\n<wa-button>Yes</wa-button>\n" \
        "<wa-divider orientation=\"vertical\">vs</wa-divider>\n<wa-button>No</wa-button>\n</div>"
      )
    end

    it 'processes a divider inside a card body without wrapping it in a paragraph' do
      result = described_class.process("===\nTop\n\n--- or ---\n\nBottom\n===")
      expect(result).to eq("<wa-card><p>Top</p>\n\n<wa-divider>or</wa-divider>\n\n<p>Bottom</p>\n</wa-card>")
    end

    it 'processes a stepper inside a callout' do
      result = described_class.process(":::info\n>>>>>>\n- Plan\n- Build\n>>>>>>\n:::")
      expect(result).to include(
        '<wa-stepper active="step-1"><wa-step name="step-1">Plan</wa-step>' \
        '<wa-step name="step-2">Build</wa-step></wa-stepper>'
      )
      expect(result).not_to include('<p><wa-stepper')
    end

    it 'leaves the >>> separators of other components intact around a stepper' do
      input = "^^^\nSummary\n>>>\n>>>>>>\n- One\n>>>>>>\n^^^"
      result = described_class.process(input)
      expect(result).to include('<wa-details')
      expect(result).to include('<wa-stepper active="step-1"><wa-step name="step-1">One</wa-step></wa-stepper>')
    end

    it 'does not transform divider or stepper syntax inside fenced code blocks' do
      input = "```\n--- or ---\n>>>>>>\n- A\n>>>>>>\n```"
      expect(described_class.process(input)).to eq(input)
    end

    it 'processes tabs syntax' do
      input = "++++++\n+++ Tab 1\nContent 1\n+++\n+++ Tab 2\nContent 2\n+++\n++++++"
      result = described_class.process(input)
      expect(result).to include('<wa-tab-group')
    end

    it 'processes comparison syntax' do
      input = "|||\n![Before](before.jpg)\n![After](after.jpg)\n|||"
      result = described_class.process(input)
      expect(result).to include('<wa-comparison')
    end

    it 'processes tooltip syntax' do
      input = '(((CSS >>> Cascading Style Sheets)))'
      result = described_class.process(input)
      expect(result).to include('<span id="tooltip-')
      expect(result).to include('class="ma-tooltip-anchor"')
      expect(result).to include('<wa-tooltip for="tooltip-')
      expect(result).to include('Cascading Style Sheets</wa-tooltip>')
    end

    context 'with image dialog option' do
      it 'transforms images to dialogs when enabled' do
        input = '![Test](test.png)'
        result = Markawesome::Transformer.process(input, image_dialog: true)
        expect(result).to include('<wa-dialog')
        expect(result).to include('light-dismiss')
        expect(result).to include('test.png')
      end

      it 'does not transform images when disabled' do
        input = '![Test](test.png)'
        result = Markawesome::Transformer.process(input)
        expect(result).to eq(input)
      end

      it 'uses configuration hash for image dialog' do
        input = '![Test](test.png)'
        config = { default_width: '80vw' }
        result = Markawesome::Transformer.process(input, image_dialog: config)
        expect(result).to include('<wa-dialog')
        expect(result).to include('--width: 80vw')
      end
    end

    it 'processes multiple component types in one document' do
      input = <<~MARKDOWN
        # Test Document

        !!!brand
        Badge
        !!!

        :::info
        This is a callout
        :::

        $$$settings
      MARKDOWN

      result = described_class.process(input)
      expect(result).to include('<wa-badge variant="brand">Badge</wa-badge>')
      expect(result).to include('<wa-callout')
      expect(result).to include('<wa-icon name="settings">')
    end
  end
end
