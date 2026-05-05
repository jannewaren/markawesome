# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::CodeBlockProtector do
  describe '.protect / .restore' do
    it 'round-trips a single fenced code block' do
      content = "before\n```ruby\nputs :hi\n```\nafter"
      protected_content, tokens = described_class.protect(content)

      expect(protected_content).not_to include('puts :hi')
      expect(protected_content).to match(/<!--MARKAWESOME_PROTECTED_CODE_BLOCK_0-->/)

      restored = described_class.restore(protected_content, tokens)
      expect(restored).to eq(content)
    end

    it 'handles multiple code blocks independently' do
      content = "```\none\n```\n\n```\ntwo\n```"
      protected_content, tokens = described_class.protect(content)
      expect(tokens.size).to eq(2)
      restored = described_class.restore(protected_content, tokens)
      expect(restored).to eq(content)
    end

    it 'returns content unchanged when there are no code blocks' do
      content = "Just a paragraph."
      protected_content, tokens = described_class.protect(content)
      expect(protected_content).to eq(content)
      expect(tokens).to be_empty
    end
  end
end
