# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::LayoutTransformer do
  describe '.render_as_markdown' do
    it 'drops the grid wrapper and keeps inner content' do
      md = "::::grid\nA\n\nB\n::::"
      expect(described_class.render_as_markdown(md)).to eq("A\n\nB")
    end

    it 'drops stack wrapper' do
      md = "::::stack\nItem\n::::"
      expect(described_class.render_as_markdown(md)).to eq('Item')
    end

    it 'drops frame wrapper with params' do
      md = "::::frame landscape\n![x](x.png)\n::::"
      expect(described_class.render_as_markdown(md)).to eq('![x](x.png)')
    end

    it 'handles alternative ::::wa-grid syntax' do
      md = "::::wa-grid\nA\n::::"
      expect(described_class.render_as_markdown(md)).to eq('A')
    end
  end
end
