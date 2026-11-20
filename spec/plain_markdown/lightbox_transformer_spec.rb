# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::LightboxTransformer do
  describe '.render_as_markdown' do
    it 'keeps the image lines as written and drops the fence' do
      input = "::::lightbox loop label:\"Trip\"\n![A](a.jpg \"Cap\")\n[![B](t.jpg)](b.mp4 \"Clip\")\n::::"
      expect(described_class.render_as_markdown(input)).to eq("![A](a.jpg \"Cap\")\n[![B](t.jpg)](b.mp4 \"Clip\")")
    end

    it 'degrades the alternative syntax too' do
      expect(described_class.render_as_markdown(":::wa-lightbox\n![A](a.jpg)\n:::")).to eq('![A](a.jpg)')
    end

    it 'degrades a lightbox inside a grid through the full renderer' do
      input = "::::grid\n::::lightbox\n![A](a.jpg)\n::::\nAfter\n::::"
      expect(Markawesome::PlainMarkdownRenderer.process(input)).to eq("![A](a.jpg)\nAfter")
    end
  end
end
