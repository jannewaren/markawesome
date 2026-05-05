# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::CarouselTransformer do
  describe '.render_as_markdown' do
    it 'flattens slides into sequential blocks' do
      md = <<~MD.strip
        ~~~~~~
        ~~~
        ![One](one.png)
        ~~~
        ~~~
        ![Two](two.png)
        ~~~
        ~~~~~~
      MD
      result = described_class.render_as_markdown(md)
      expect(result).to include('![One](one.png)')
      expect(result).to include('![Two](two.png)')
      expect(result).not_to include('~~~')
    end
  end
end
