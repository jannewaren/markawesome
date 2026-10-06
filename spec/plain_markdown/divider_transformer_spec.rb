# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::DividerTransformer do
  describe '.render_as_markdown' do
    it 'degrades to a thematic break followed by the label paragraph (exact)' do
      expect(described_class.render_as_markdown('--- or ---')).to eq("\n---\n\nor\n")
    end

    it 'drops placement, orientation and icon tokens but keeps label Markdown' do
      expect(described_class.render_as_markdown('--- start vertical icon:star **New** ---'))
        .to eq("\n---\n\n**New**\n")
    end

    it 'degrades an icon-only divider to a bare thematic break' do
      expect(described_class.render_as_markdown('--- icon:quote-left ---')).to eq("\n---")
    end

    it 'separates the break from a preceding paragraph so it cannot become a setext heading' do
      expect(described_class.render_as_markdown("Para\n--- or ---\nNext")).to eq("Para\n\n---\n\nor\n\nNext")
    end

    it 'degrades the alternative syntax, including an empty body' do
      expect(described_class.render_as_markdown(":::wa-divider end\nRelease *notes*\n:::"))
        .to eq("\n---\n\nRelease *notes*\n")
      expect(described_class.render_as_markdown(":::wa-divider\n:::")).to eq("\n---")
    end

    it 'leaves plain rules and table separators untouched' do
      input = "---\n\n--- | ---"
      expect(described_class.render_as_markdown(input)).to eq(input)
    end
  end
end
