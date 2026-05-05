# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::DialogTransformer do
  describe '.render_as_markdown' do
    it 'renders dialog as italic trigger label followed by body' do
      md = "???\nOpen settings\n>>>\nSome dialog body.\n???"
      expected = "_Open settings:_\n\nSome dialog body."
      expect(described_class.render_as_markdown(md)).to eq(expected)
    end

    it 'handles alternative :::wa-dialog syntax' do
      md = ":::wa-dialog\nTrigger\n>>>\nBody\n:::"
      result = described_class.render_as_markdown(md)
      expect(result).to include('_Trigger:_')
      expect(result).to include('Body')
    end
  end
end
