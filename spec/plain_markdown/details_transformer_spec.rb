# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::DetailsTransformer do
  describe '.render_as_markdown' do
    it 'renders as a native HTML <details> block' do
      md = "^^^\nSummary text\n>>>\nDetails body\n^^^"
      expected = "<details>\n<summary>Summary text</summary>\n\nDetails body\n</details>"
      expect(described_class.render_as_markdown(md)).to eq(expected)
    end

    it 'handles alternative :::wa-details syntax' do
      md = ":::wa-details\nSummary\n>>>\nBody\n:::"
      result = described_class.render_as_markdown(md)
      expect(result).to include('<summary>Summary</summary>')
      expect(result).to include('Body')
    end
  end
end
