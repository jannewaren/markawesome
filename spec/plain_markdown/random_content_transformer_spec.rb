# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::RandomContentTransformer do
  describe '.render_as_markdown' do
    it 'flattens options into blank-line-separated blocks and drops the fences' do
      md = <<~MD.chomp
        ......mode:random items:2
        First **option**
        >>>
        Second option
        ......
      MD

      result = described_class.render_as_markdown(md)

      expect(result).to include('First **option**')
      expect(result).to include('Second option')
      expect(result).to include("First **option**\n\nSecond option")
      expect(result).not_to include('......')
      expect(result).not_to include(':::')
      expect(result).not_to include('>>>')
    end

    it 'degrades the alternative syntax identically' do
      md = <<~MD.chomp
        :::wa-random-content
        First option
        >>>
        Second option
        :::
      MD

      result = described_class.render_as_markdown(md)

      expect(result).to eq("First option\n\nSecond option")
    end

    it 'drops empty options' do
      md = "......\nA\n>>>\n>>>\nB\n......"

      result = described_class.render_as_markdown(md)

      expect(result).to eq("A\n\nB")
    end
  end
end
