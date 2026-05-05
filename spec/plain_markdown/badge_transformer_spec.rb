# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::BadgeTransformer do
  describe '.render_as_markdown' do
    it 'renders a plain badge as bold' do
      md = "!!!\nNew\n!!!"
      expect(described_class.render_as_markdown(md)).to eq('**New**')
    end

    it 'renders a badge with a variant as bold (variant dropped)' do
      md = "!!!brand\nBeta\n!!!"
      expect(described_class.render_as_markdown(md)).to eq('**Beta**')
    end

    it 'handles alternative :::wa-badge syntax' do
      md = ":::wa-badge warning\nCaution\n:::"
      expect(described_class.render_as_markdown(md)).to eq('**Caution**')
    end
  end
end
