# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::TabsTransformer do
  describe '.render_as_markdown' do
    it 'flattens tabs into sequential h3 sections' do
      md = <<~MD.strip
        ++++++
        +++ Tab A
        Content A
        +++
        +++ Tab B
        Content B
        +++
        ++++++
      MD
      expected = "### Tab A\n\nContent A\n\n### Tab B\n\nContent B"
      expect(described_class.render_as_markdown(md)).to eq(expected)
    end

    it 'handles alternative :::wa-tab-group syntax' do
      md = <<~MD.strip
        :::wa-tab-group
        +++ One
        First
        +++
        +++ Two
        Second
        +++
        :::
      MD
      result = described_class.render_as_markdown(md)
      expect(result).to include('### One')
      expect(result).to include('### Two')
      expect(result).to include('First')
      expect(result).to include('Second')
    end
  end
end
