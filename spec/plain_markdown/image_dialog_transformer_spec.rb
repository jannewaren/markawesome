# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::ImageDialogTransformer do
  describe '.render_as_markdown' do
    it 'leaves plain markdown images untouched' do
      md = '![Alt](image.png)'
      expect(described_class.render_as_markdown(md)).to eq(md)
    end
  end
end
