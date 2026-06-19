# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::IconAttributes do
  describe '.pairs' do
    it 'returns an empty array for an empty hash' do
      expect(described_class.pairs({})).to eq([])
    end

    it 'emits only the keys that are present' do
      expect(described_class.pairs(variant: 'solid')).to eq(['variant="solid"'])
    end

    it 'emits in the fixed family/variant/animation order regardless of insertion order' do
      attributes = { animation: 'spin', variant: 'solid', family: 'sharp' }
      expect(described_class.pairs(attributes)).to eq(
        ['family="sharp"', 'variant="solid"', 'animation="spin"']
      )
    end

    it 'ignores keys outside the schema vocabulary' do
      expect(described_class.pairs(size: 'large', family: 'duotone')).to eq(['family="duotone"'])
    end
  end

  describe 'SCHEMA' do
    it 'defines the family/variant/animation vocabularies' do
      expect(described_class::SCHEMA.keys).to eq(%i[family variant animation])
    end
  end
end
