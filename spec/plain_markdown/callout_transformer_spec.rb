# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::CalloutTransformer do
  describe '.render_as_markdown' do
    it 'renders info as GFM NOTE alert' do
      md = ":::info\nThis is info\n:::"
      expect(described_class.render_as_markdown(md)).to eq("> [!NOTE]\n> This is info")
    end

    it 'renders brand as GFM NOTE alert' do
      md = ":::brand\nBrand notice\n:::"
      expect(described_class.render_as_markdown(md)).to eq("> [!NOTE]\n> Brand notice")
    end

    it 'renders success as GFM TIP alert' do
      md = ":::success\nAll good\n:::"
      expect(described_class.render_as_markdown(md)).to eq("> [!TIP]\n> All good")
    end

    it 'renders warning as GFM WARNING alert' do
      md = ":::warning\nBe careful\n:::"
      expect(described_class.render_as_markdown(md)).to eq("> [!WARNING]\n> Be careful")
    end

    it 'renders danger as GFM CAUTION alert' do
      md = ":::danger\nBad stuff\n:::"
      expect(described_class.render_as_markdown(md)).to eq("> [!CAUTION]\n> Bad stuff")
    end

    it 'renders neutral as GFM IMPORTANT alert' do
      md = ":::neutral\nConfig required\n:::"
      expect(described_class.render_as_markdown(md)).to eq("> [!IMPORTANT]\n> Config required")
    end

    it 'quotes multi-line content' do
      md = ":::info\nLine 1\nLine 2\n:::"
      expect(described_class.render_as_markdown(md)).to eq("> [!NOTE]\n> Line 1\n> Line 2")
    end

    it 'preserves blank lines between paragraphs as bare quote markers' do
      md = ":::info\nPara one\n\nPara two\n:::"
      expect(described_class.render_as_markdown(md)).to eq("> [!NOTE]\n> Para one\n>\n> Para two")
    end

    it 'ignores unknown variants' do
      md = ":::invalid\nnope\n:::"
      expect(described_class.render_as_markdown(md)).to eq(md)
    end

    it 'handles alternative :::wa-callout syntax' do
      md = ":::wa-callout warning\nBeware\n:::"
      expect(described_class.render_as_markdown(md)).to eq("> [!WARNING]\n> Beware")
    end
  end
end
