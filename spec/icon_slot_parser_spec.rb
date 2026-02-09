# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::IconSlotParser do
  let(:button_slots) { { default: 'start', slots: %w[start end] } }
  let(:callout_slots) { { default: 'icon', slots: %w[icon] } }
  let(:details_slots) { { default: nil, slots: %w[expand collapse] } }
  let(:tag_slots) { { default: 'content', slots: %w[content] } }

  describe '.parse' do
    context 'with single icon using default slot' do
      it 'parses icon:name to default slot' do
        result = described_class.parse('icon:gear', button_slots)

        expect(result[:icons]).to eq('start' => 'gear')
        expect(result[:remaining]).to eq('')
      end

      it 'parses icon with hyphenated name' do
        result = described_class.parse('icon:circle-check', callout_slots)

        expect(result[:icons]).to eq('icon' => 'circle-check')
        expect(result[:remaining]).to eq('')
      end
    end

    context 'with explicit slot' do
      it 'parses icon:slot:name' do
        result = described_class.parse('icon:end:arrow-right', button_slots)

        expect(result[:icons]).to eq('end' => 'arrow-right')
        expect(result[:remaining]).to eq('')
      end

      it 'parses icon:start:gear explicitly' do
        result = described_class.parse('icon:start:gear', button_slots)

        expect(result[:icons]).to eq('start' => 'gear')
        expect(result[:remaining]).to eq('')
      end
    end

    context 'with both slots' do
      it 'parses multiple icon tokens' do
        result = described_class.parse('icon:start:gear icon:end:arrow-right', button_slots)

        expect(result[:icons]).to eq('start' => 'gear', 'end' => 'arrow-right')
        expect(result[:remaining]).to eq('')
      end
    end

    context 'with remaining params' do
      it 'strips icon tokens and returns remaining string' do
        result = described_class.parse('success icon:gear large', button_slots)

        expect(result[:icons]).to eq('start' => 'gear')
        expect(result[:remaining]).to eq('success large')
      end

      it 'preserves all non-icon tokens' do
        result = described_class.parse('brand filled icon:end:chevron-down pill', button_slots)

        expect(result[:icons]).to eq('end' => 'chevron-down')
        expect(result[:remaining]).to eq('brand filled pill')
      end
    end

    context 'with rightmost-wins semantics' do
      it 'last icon for same slot wins' do
        result = described_class.parse('icon:gear icon:download', button_slots)

        expect(result[:icons]).to eq('start' => 'download')
      end

      it 'last explicit slot wins' do
        result = described_class.parse('icon:end:arrow-right icon:end:chevron-down', button_slots)

        expect(result[:icons]).to eq('end' => 'chevron-down')
      end
    end

    context 'with no icons' do
      it 'returns empty icons hash and full remaining string' do
        result = described_class.parse('success large', button_slots)

        expect(result[:icons]).to eq({})
        expect(result[:remaining]).to eq('success large')
      end
    end

    context 'with nil or empty input' do
      it 'handles nil input' do
        result = described_class.parse(nil, button_slots)

        expect(result[:icons]).to eq({})
        expect(result[:remaining]).to eq('')
      end

      it 'handles empty string input' do
        result = described_class.parse('', button_slots)

        expect(result[:icons]).to eq({})
        expect(result[:remaining]).to eq('')
      end

      it 'handles whitespace-only input' do
        result = described_class.parse('   ', button_slots)

        expect(result[:icons]).to eq({})
        expect(result[:remaining]).to eq('')
      end
    end

    context 'with invalid slot name' do
      it 'ignores icon with unknown slot' do
        result = described_class.parse('icon:invalid:gear', button_slots)

        expect(result[:icons]).to eq({})
        expect(result[:remaining]).to eq('')
      end
    end

    context 'with no default slot' do
      it 'ignores icon:name when no default slot configured' do
        result = described_class.parse('icon:plus', details_slots)

        expect(result[:icons]).to eq({})
        expect(result[:remaining]).to eq('')
      end

      it 'still parses explicit slots' do
        result = described_class.parse('icon:expand:plus icon:collapse:minus', details_slots)

        expect(result[:icons]).to eq('expand' => 'plus', 'collapse' => 'minus')
        expect(result[:remaining]).to eq('')
      end
    end

    context 'with empty icon name' do
      it 'ignores icon: with no name' do
        result = described_class.parse('icon:', button_slots)

        expect(result[:icons]).to eq({})
        expect(result[:remaining]).to eq('')
      end
    end
  end

  describe '.to_html' do
    it 'generates wa-icon elements with slot attribute' do
      icons = { 'start' => 'gear' }

      result = described_class.to_html(icons)

      expect(result).to eq('<wa-icon slot="start" name="gear"></wa-icon>')
    end

    it 'generates multiple wa-icon elements' do
      icons = { 'start' => 'gear', 'end' => 'arrow-right' }

      result = described_class.to_html(icons)

      expect(result).to include('<wa-icon slot="start" name="gear"></wa-icon>')
      expect(result).to include('<wa-icon slot="end" name="arrow-right"></wa-icon>')
    end

    it 'generates empty string for empty hash' do
      result = described_class.to_html({})

      expect(result).to eq('')
    end

    context 'with slot_map' do
      it 'remaps slot names' do
        icons = { 'expand' => 'plus', 'collapse' => 'minus' }
        slot_map = { 'expand' => 'expand-icon', 'collapse' => 'collapse-icon' }

        result = described_class.to_html(icons, slot_map)

        expect(result).to include('<wa-icon slot="expand-icon" name="plus"></wa-icon>')
        expect(result).to include('<wa-icon slot="collapse-icon" name="minus"></wa-icon>')
      end

      it 'falls back to original slot name when not in map' do
        icons = { 'start' => 'gear' }
        slot_map = { 'expand' => 'expand-icon' }

        result = described_class.to_html(icons, slot_map)

        expect(result).to eq('<wa-icon slot="start" name="gear"></wa-icon>')
      end
    end

    context 'with content slot' do
      it 'omits slot attribute for content slot' do
        icons = { 'content' => 'check' }

        result = described_class.to_html(icons)

        expect(result).to eq('<wa-icon name="check"></wa-icon>')
      end
    end

    it 'handles hyphenated icon names' do
      icons = { 'icon' => 'circle-check' }

      result = described_class.to_html(icons)

      expect(result).to eq('<wa-icon slot="icon" name="circle-check"></wa-icon>')
    end
  end
end
