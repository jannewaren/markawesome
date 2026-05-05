# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::TagTransformer do
  describe '.render_as_markdown' do
    it 'renders a block tag as bold' do
      md = "@@@\nLabel\n@@@"
      expect(described_class.render_as_markdown(md)).to eq('**Label**')
    end

    it 'drops attribute tokens when rendering inline tag' do
      md = 'Check @@@ brand Beta @@@ out'
      expect(described_class.render_as_markdown(md)).to eq('Check **Beta** out')
    end

    it 'handles alternative :::wa-tag syntax' do
      md = ":::wa-tag\nLabel\n:::"
      expect(described_class.render_as_markdown(md)).to eq('**Label**')
    end
  end
end
