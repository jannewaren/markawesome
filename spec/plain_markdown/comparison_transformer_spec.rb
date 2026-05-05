# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::ComparisonTransformer do
  describe '.render_as_markdown' do
    it 'renders before/after labels with plain images' do
      md = "|||\n![Old](old.png)\n![New](new.png)\n|||"
      result = described_class.render_as_markdown(md)
      expect(result).to eq("**Before:** ![Old](old.png)\n\n**After:** ![New](new.png)")
    end

    it 'handles alternative :::wa-comparison syntax' do
      md = ":::wa-comparison\n![A](a.png)\n![B](b.png)\n:::"
      result = described_class.render_as_markdown(md)
      expect(result).to include('**Before:** ![A](a.png)')
      expect(result).to include('**After:** ![B](b.png)')
    end

    it 'leaves original content untouched when not exactly two images' do
      md = "|||\n![Only](only.png)\n|||"
      expect(described_class.render_as_markdown(md)).to eq(md)
    end
  end
end
