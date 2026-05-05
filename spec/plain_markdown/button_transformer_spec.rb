# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::ButtonTransformer do
  describe '.render_as_markdown' do
    it 'renders a link-button as a plain link' do
      md = "%%%brand\n[Get started](https://example.com)\n%%%"
      expect(described_class.render_as_markdown(md)).to eq('[Get started](https://example.com)')
    end

    it 'renders a plain-text button as bold' do
      md = "%%%brand\nClick Me\n%%%"
      expect(described_class.render_as_markdown(md)).to eq('**Click Me**')
    end

    it 'handles alternative :::wa-button syntax' do
      md = ":::wa-button brand\n[Go](/go)\n:::"
      expect(described_class.render_as_markdown(md)).to eq('[Go](/go)')
    end
  end
end
