# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::LightboxTransformer do
  let(:square) { 'width: 100%; aspect-ratio: 1; object-fit: cover; border-radius: var(--wa-border-radius-m)' }

  describe '.transform' do
    it 'transforms a full gallery (exact)' do
      markdown = <<~MD.chomp
        ::::lightbox loop thumbnails min:10rem gap:s label:"Lisbon trip"
        ![Tram](tram.jpg "Tram 28 in Alfama")
        [![Bridge](bridge-thumb.jpg)](bridge-full.jpg "25 de Abril")
        [![Drone](drone-poster.jpg)](drone.mp4 "From above")
        ::::
      MD

      expect(described_class.transform(markdown)).to eq(
        '<wa-lightbox class="wa-grid wa-gap-s" style="--min-column-size: 10rem" label="Lisbon trip" ' \
        'loop with-thumbnails>' \
        '<wa-lightbox-item src="tram.jpg" caption="Tram 28 in Alfama">' \
        "<img src=\"tram.jpg\" alt=\"Tram\" loading=\"lazy\" style=\"#{square}\"></wa-lightbox-item>" \
        '<wa-lightbox-item src="bridge-full.jpg" caption="25 de Abril">' \
        "<img src=\"bridge-thumb.jpg\" alt=\"Bridge\" loading=\"lazy\" style=\"#{square}\"></wa-lightbox-item>" \
        '<wa-lightbox-item type="video" src="drone.mp4" caption="From above">' \
        "<img src=\"drone-poster.jpg\" alt=\"Drone\" loading=\"lazy\" style=\"#{square}\"></wa-lightbox-item>" \
        '</wa-lightbox>'
      )
    end

    it 'emits a bare grid lightbox without params' do
      expect(described_class.transform("::::lightbox\n![A](a.jpg)\n::::")).to eq(
        '<wa-lightbox class="wa-grid"><wa-lightbox-item src="a.jpg">' \
        "<img src=\"a.jpg\" alt=\"A\" loading=\"lazy\" style=\"#{square}\"></wa-lightbox-item></wa-lightbox>"
      )
    end

    it 'supports the :::wa-lightbox alternative syntax' do
      result = described_class.transform(":::wa-lightbox no-zoom\n![A](a.jpg)\n:::")
      expect(result).to start_with('<wa-lightbox class="wa-grid" without-zoom>')
      expect(result).to include('<wa-lightbox-item src="a.jpg">')
    end

    it 'emits flags in a fixed order regardless of input order' do
      result = described_class.transform("::::lightbox no-zoom no-counter no-nav thumbnails loop\n![A](a.jpg)\n::::")
      expect(result).to start_with(
        '<wa-lightbox class="wa-grid" loop with-thumbnails without-navigation without-counter without-zoom>'
      )
    end

    it 'does not read words inside the label as flags' do
      result = described_class.transform("::::lightbox label:'loop the thumbnails'\n![A](a.jpg)\n::::")
      expect(result).to start_with('<wa-lightbox class="wa-grid" label="loop the thumbnails">')
    end

    it 'escapes the label' do
      result = described_class.transform("::::lightbox label:\"Tom & <Jerry>\"\n![A](a.jpg)\n::::")
      expect(result).to include('label="Tom &amp; &lt;Jerry&gt;"')
    end

    it 'reuses the grid rules for gap, min, align and justify' do
      result = described_class.transform("::::lightbox gap:xl min:8rem align:center gap:bogus\n![A](a.jpg)\n::::")
      expect(result).to start_with(
        '<wa-lightbox class="wa-grid wa-gap-xl wa-align-items-center" style="--min-column-size: 8rem">'
      )
    end

    it 'strips unsafe characters from min:' do
      result = described_class.transform("::::lightbox min:10rem;color:red\n![A](a.jpg)\n::::")
      expect(result).to include('style="--min-column-size: 10remcolor:red"')
    end

    context 'with thumbnail shapes' do
      {
        'landscape' => 'width: 100%; aspect-ratio: 4 / 3; object-fit: cover; border-radius: var(--wa-border-radius-m)',
        'portrait' => 'width: 100%; aspect-ratio: 3 / 4; object-fit: cover; border-radius: var(--wa-border-radius-m)',
        'natural' => 'width: 100%; height: auto; border-radius: var(--wa-border-radius-m)',
        'square' => 'width: 100%; aspect-ratio: 1; object-fit: cover; border-radius: var(--wa-border-radius-m)'
      }.each do |shape, style|
        it "styles #{shape} thumbnails" do
          result = described_class.transform("::::lightbox #{shape}\n![A](a.jpg)\n::::")
          expect(result).to include("style=\"#{style}\"")
          expect(result).to start_with('<wa-lightbox class="wa-grid">')
        end
      end

      it 'lets the rightmost shape win' do
        result = described_class.transform("::::lightbox portrait natural\n![A](a.jpg)\n::::")
        expect(result).to include('style="width: 100%; height: auto;')
      end
    end

    context 'with items' do
      it 'uses the link title as the caption, falling back to the image title' do
        result = described_class.transform(
          "::::lightbox\n[![A](t.jpg \"Image title\")](f.jpg \"Link title\")\n[![B](t2.jpg \"Only image\")](f2.jpg)\n::::"
        )
        expect(result).to include('<wa-lightbox-item src="f.jpg" caption="Link title">')
        expect(result).to include('<wa-lightbox-item src="f2.jpg" caption="Only image">')
      end

      it 'omits an empty caption' do
        expect(described_class.transform("::::lightbox\n![A](a.jpg)\n::::"))
          .to include('<wa-lightbox-item src="a.jpg"><img')
      end

      %w[clip.mp4 clip.WEBM clip.mov clip.ogv clip.m4v clip.mp4?t=10 clip.webm#start].each do |href|
        it "marks #{href} as a video" do
          result = described_class.transform("::::lightbox\n[![P](p.jpg)](#{href})\n::::")
          expect(result).to include("<wa-lightbox-item type=\"video\" src=\"#{href}\">")
        end
      end

      it 'does not mark a non-video href as a video' do
        result = described_class.transform("::::lightbox\n[![P](p.jpg)](mp4.jpg)\n::::")
        expect(result).not_to include('type="video"')
      end

      it 'escapes item attributes' do
        result = described_class.transform("::::lightbox\n![A \"quoted\" & co](a.jpg?x=1&y=2 \"Fish & chips\")\n::::")
        expect(result).to include('src="a.jpg?x=1&amp;y=2" caption="Fish &amp; chips"')
        expect(result).to include('alt="A &quot;quoted&quot; &amp; co"')
      end

      it 'ignores blank lines and indentation' do
        result = described_class.transform("::::lightbox\n\n  ![A](a.jpg)\n\n![B](b.jpg)\n\n::::")
        expect(result.scan('<wa-lightbox-item').length).to eq(2)
        expect(result).not_to include('<p>')
      end

      it 'renders non-image lines as Markdown in place' do
        result = described_class.transform("::::lightbox\n![A](a.jpg)\nSome *note*\nmore\n\nSecond\n![B](b.jpg)\n::::")
        expect(result).to include('</wa-lightbox-item><p>Some <em>note</em>' \
                                  "\nmore</p>\n\n<p>Second</p><wa-lightbox-item src=\"b.jpg\">")
      end
    end

    it 'does not match ::::lightboxes or a grid' do
      input = "::::lightboxes\n![A](a.jpg)\n::::"
      expect(described_class.transform(input)).to eq(input)
      expect(described_class.transform("::::grid\n![A](a.jpg)\n::::")).to eq("::::grid\n![A](a.jpg)\n::::")
    end

    it 'transforms several lightboxes in one document' do
      result = described_class.transform("::::lightbox\n![A](a.jpg)\n::::\n\nText\n\n::::lightbox\n![B](b.jpg)\n::::")
      expect(result.scan('<wa-lightbox ').length).to eq(2)
      expect(result).to include("</wa-lightbox>\n\nText\n\n<wa-lightbox")
    end
  end
end
