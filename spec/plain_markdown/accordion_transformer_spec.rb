# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::AccordionTransformer do
  describe '.render_as_markdown' do
    it 'flattens items into sequential h3 sections' do
      md = <<~MD.strip
        //////
        /// What is it?
        A library.
        ///
        /// Is it free?
        Yes.
        ///
        //////
      MD
      expected = "### What is it?\n\nA library.\n\n### Is it free?\n\nYes."
      expect(described_class.render_as_markdown(md)).to eq(expected)
    end

    it 'strips leading flags and icon tokens from the heading' do
      md = <<~MD.strip
        //////
        /// expanded icon:star Favorites
        Body.
        ///
        //////
      MD
      result = described_class.render_as_markdown(md)
      expect(result).to eq("### Favorites\n\nBody.")
    end

    it 'handles the alternative :::wa-accordion syntax' do
      md = <<~MD.strip
        :::wa-accordion
        /// One
        First
        ///
        /// Two
        Second
        ///
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
