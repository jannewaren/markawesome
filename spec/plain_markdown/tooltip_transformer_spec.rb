# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::TooltipTransformer do
  describe '.render_as_markdown' do
    it 'renders an inline tooltip as a bold anchor followed by parenthetical tip' do
      md = '(((CSS >>> Cascading Style Sheets)))'
      expect(described_class.render_as_markdown(md)).to eq('**CSS** (Cascading Style Sheets)')
    end

    it 'strips leading params from the inline anchor' do
      md = '(((bottom distance:10 API >>> Application Programming Interface)))'
      expect(described_class.render_as_markdown(md)).to eq('**API** (Application Programming Interface)')
    end

    it 'renders an inline tooltip mid-sentence' do
      md = 'Styled with (((CSS >>> Cascading Style Sheets))) here.'
      expect(described_class.render_as_markdown(md)).to eq('Styled with **CSS** (Cascading Style Sheets) here.')
    end

    it 'renders the alternative block syntax' do
      md = ":::wa-tooltip\nCSS\n>>>\nCascading Style Sheets\n:::"
      expect(described_class.render_as_markdown(md)).to eq('**CSS** (Cascading Style Sheets)')
    end
  end
end
