# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::IconTransformer do
  describe '.render_as_markdown' do
    it 'drops primary-syntax icons entirely' do
      md = 'Check $$$gear and $$$home-line.'
      expect(described_class.render_as_markdown(md)).to eq('Check  and .')
    end

    it 'preserves icon-like syntax inside fenced code blocks' do
      md = "```\n$$$keep-me\n```"
      expect(described_class.render_as_markdown(md)).to eq(md)
    end

    it 'drops :::wa-icon alternative syntax' do
      md = ":::wa-icon gear\n:::"
      expect(described_class.render_as_markdown(md).strip).to eq('')
    end

    it 'degrades a labeled block to its label text' do
      md = ":::wa-icon heart solid\nAdd to favorites\n:::"
      expect(described_class.render_as_markdown(md).strip).to eq('Add to favorites')
    end

    it 'still drops an unlabeled enriched block' do
      md = ":::wa-icon star spin\n:::"
      expect(described_class.render_as_markdown(md).strip).to eq('')
    end
  end
end
