# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::NumberTickerTransformer do
  describe '.render_as_markdown' do
    it 'degrades to the number as written' do
      expect(described_class.render_as_markdown('[[[ 87% ]]] satisfaction')).to eq('87% satisfaction')
      expect(described_class.render_as_markdown('[[[ 12000 from:10000 ]]] users')).to eq('12000 users')
    end

    it 'appends the currency code' do
      expect(described_class.render_as_markdown('Raised [[[ 18452.75 currency:eur ]]]')).to eq('Raised 18452.75 EUR')
    end

    it 'degrades the block form' do
      expect(described_class.render_as_markdown(":::wa-number-ticker 99 eager\n:::")).to eq('99')
    end

    it 'leaves dates for the date transformer in the full renderer' do
      expect(Markawesome::PlainMarkdownRenderer.process('[[[ 5% ]]] on [[[ 2026-06-26 ]]]')).to eq('5% on 2026-06-26')
    end
  end
end
