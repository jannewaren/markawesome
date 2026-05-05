# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::PopoverTransformer do
  describe '.render_as_markdown' do
    it 'renders inline popover as bold trigger followed by parenthetical content' do
      md = '&&&trigger >>> the content&&&'
      expect(described_class.render_as_markdown(md)).to eq('**trigger** (the content)')
    end

    it 'renders block popover as bold trigger plus content paragraph' do
      md = "&&&\nTrigger\n>>>\nBody text\n&&&"
      expect(described_class.render_as_markdown(md)).to eq("**Trigger**\n\nBody text")
    end

    it 'handles alternative :::wa-popover syntax' do
      md = ":::wa-popover\nTrigger\n>>>\nBody\n:::"
      expect(described_class.render_as_markdown(md)).to eq("**Trigger**\n\nBody")
    end
  end
end
