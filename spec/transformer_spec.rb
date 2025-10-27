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
