# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::NumberTickerTransformer do
  describe '.transform' do
    it 'transforms a currency ticker (exact)' do
      expect(described_class.transform('Raised [[[ 18452.75 currency:EUR ]]] so far')).to eq(
        'Raised <wa-number-ticker value="18452.75" type="currency" currency="EUR"></wa-number-ticker> so far'
      )
    end

    it 'transforms a bare number' do
      expect(described_class.transform('[[[1234]]]')).to eq('<wa-number-ticker value="1234"></wa-number-ticker>')
    end

    it 'transforms a start value and duration (exact)' do
      expect(described_class.transform('[[[ 12000 from:10000 duration:1500 ]]] users')).to eq(
        '<wa-number-ticker value="12000" start-value="10000" duration="1500"></wa-number-ticker> users'
      )
    end

    it 'emits every option in a fixed order regardless of input order' do
      input = '[[[ -3.5 lang:fi decimals:2 display:name currency:usd no-grouping eager ' \
              'easing:"cubic-bezier(0.1, 0.7, 1, 0.1)" delay:200 duration:900 from:-10 ]]]'
      expect(described_class.transform(input)).to eq(
        '<wa-number-ticker value="-3.5" start-value="-10" duration="900" delay="200" ' \
        'easing="cubic-bezier(0.1, 0.7, 1, 0.1)" eager type="currency" without-grouping currency="USD" ' \
        'currency-display="name" minimum-fraction-digits="2" maximum-fraction-digits="2" lang="fi"></wa-number-ticker>'
      )
    end

    context 'with percentages' do
      {
        '87%' => '0.87', '12.5%' => '0.125', '150%' => '1.5', '5%' => '0.05', '100%' => '1',
        '0%' => '0', '0.5%' => '0.005', '-12.5%' => '-0.125', '1234.5678%' => '12.345678', '007%' => '0.07'
      }.each do |input, value|
        it "shifts #{input} to #{value}" do
          expect(described_class.transform("[[[ #{input} ]]]"))
            .to eq("<wa-number-ticker value=\"#{value}\" type=\"percent\"></wa-number-ticker>")
        end
      end

      it 'keeps the value verbatim with a percent token' do
        expect(described_class.transform('[[[ 0.42 percent ]]]'))
          .to eq('<wa-number-ticker value="0.42" type="percent"></wa-number-ticker>')
      end

      it 'omits the decimal default type' do
        expect(described_class.transform('[[[ 87% decimal ]]]'))
          .to eq('<wa-number-ticker value="0.87"></wa-number-ticker>')
      end
    end

    it 'drops invalid option values' do
      input = '[[[ 5 currency:EURO display:wide from:abc duration:1.5 delay:-1 decimals:101 decimals:x ]]]'
      expect(described_class.transform(input)).to eq('<wa-number-ticker value="5"></wa-number-ticker>')
    end

    it 'accepts decimals:0 and locale:' do
      expect(described_class.transform('[[[ 5 decimals:0 locale:de ]]]')).to eq(
        '<wa-number-ticker value="5" minimum-fraction-digits="0" maximum-fraction-digits="0" lang="de">' \
        '</wa-number-ticker>'
      )
    end

    it 'escapes the easing value' do
      expect(described_class.transform('[[[ 5 easing:"a<b>&" ]]]')).to include('easing="a&lt;b&gt;&amp;"')
    end

    it 'leaves dates and non-numbers to the date transformer' do
      %w[2026-06-26 2026-06-26T10:00 relative countdown 12abc 1.2.3 1e5].each do |token|
        input = "[[[ #{token} ]]]"
        expect(described_class.transform(input)).to eq(input)
      end
    end

    it 'transforms several tickers on one line' do
      expect(described_class.transform('[[[1]]] and [[[2%]]]')).to eq(
        '<wa-number-ticker value="1"></wa-number-ticker> and ' \
        '<wa-number-ticker value="0.02" type="percent"></wa-number-ticker>'
      )
    end

    it 'supports the :::wa-number-ticker block' do
      expect(described_class.transform(":::wa-number-ticker 99 eager\n:::"))
        .to eq('<wa-number-ticker value="99" eager></wa-number-ticker>')
      expect(described_class.transform(":::wa-number-ticker 50%\n:::"))
        .to eq('<wa-number-ticker value="0.5" type="percent"></wa-number-ticker>')
    end

    it 'leaves a :::wa-number-ticker block without a number alone' do
      input = ":::wa-number-ticker eager\n:::"
      expect(described_class.transform(input)).to eq(input)
    end
  end
end
