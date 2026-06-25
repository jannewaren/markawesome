# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::CopyButtonTransformer do
  describe '.render_as_markdown' do
    it 'strips the wrapper and keeps the content intact' do
      md = "<<<\nvalue to copy\n<<<"
      expect(described_class.render_as_markdown(md)).to eq('value to copy')
    end

    it 'handles alternative :::wa-copy-button syntax' do
      md = ":::wa-copy-button\nsome value\n:::"
      expect(described_class.render_as_markdown(md)).to eq('some value')
    end

    it 'degrades to bare text even with a tooltip mode token' do
      md = "<<<tooltip:none\nvalue to copy\n<<<"
      expect(described_class.render_as_markdown(md)).to eq('value to copy')
    end
  end
end
