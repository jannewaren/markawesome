# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::VideoTransformer do
  describe '.transform single video' do
    context 'with primary syntax' do
      it 'transforms a single video with link, poster, controls, and flags' do
        input = <<~MARKDOWN
          ;;;controls:full autoplay muted
          [My Clip](test_video.mp4)
          ![Poster](test_video_poster.jpg)
          ;;;
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to eq(
          '<wa-video src="test_video.mp4" poster="test_video_poster.jpg" ' \
          'title="My Clip" controls="full" autoplay muted></wa-video>' \
          "\n"
        )
      end

      it 'emits only src and title when the body is a bare link' do
        result = described_class.transform(";;;\n[Clip](v.mp4)\n;;;")

        expect(result).to eq('<wa-video src="v.mp4" title="Clip"></wa-video>')
      end

      it 'leaves the block untransformed when there is no link (no src)' do
        input = ";;;controls:full\n![Just a poster](p.jpg)\n;;;"

        expect(described_class.transform(input)).to eq(input)
      end
    end

    context 'with alternative syntax' do
      it 'transforms :::wa-video' do
        result = described_class.transform(":::wa-video preload:none loop\n[Clip](v.mp4)\n:::")

        expect(result).to eq('<wa-video src="v.mp4" title="Clip" preload="none" loop></wa-video>')
      end
    end
  end

  describe '.transform attributes' do
    def single(tokens)
      described_class.transform(";;;#{tokens}\n[X](x.mp4)\n;;;")
    end

    it 'accepts each controls preset' do
      %w[none standard full].each do |value|
        expect(single("controls:#{value}")).to include("controls=\"#{value}\"")
      end
    end

    it 'drops an invalid controls value' do
      expect(single('controls:bogus')).to eq('<wa-video src="x.mp4" title="X"></wa-video>')
    end

    it 'accepts each preload value' do
      %w[auto metadata none].each do |value|
        expect(single("preload:#{value}")).to include("preload=\"#{value}\"")
      end
    end

    it 'drops an invalid preload value' do
      expect(single('preload:weird')).not_to include('preload')
    end

    it 'emits each boolean flag as a bare token' do
      %w[autoplay autoplay-muted autoplay-on-visible loop muted].each do |flag|
        expect(single(flag)).to eq("<wa-video src=\"x.mp4\" title=\"X\" #{flag}></wa-video>")
      end
    end

    it 'distinguishes autoplay-muted from autoplay (whole-token match)' do
      result = single('autoplay-muted')

      expect(result).to include('autoplay-muted')
      expect(result).not_to match(/ autoplay></) # not the bare autoplay flag
    end

    it 'emits attributes in deterministic order regardless of token order' do
      result = single('muted loop autoplay preload:auto controls:standard autoplay-on-visible autoplay-muted')

      expect(result).to eq(
        '<wa-video src="x.mp4" title="X" controls="standard" preload="auto" ' \
        'autoplay autoplay-muted autoplay-on-visible loop muted></wa-video>'
      )
    end
  end

  describe '.transform body parsing' do
    it 'uses the first link for title and src and the first image for poster' do
      result = described_class.transform("Body\n\n;;;\n[Title](movie.mp4)\n![Alt](poster.jpg)\n;;;")

      expect(result).to include('src="movie.mp4"')
      expect(result).to include('title="Title"')
      expect(result).to include('poster="poster.jpg"')
    end

    it 'does not treat the image as the link source' do
      result = described_class.transform(";;;\n![Poster](poster.jpg)\n[Title](movie.mp4)\n;;;")

      expect(result).to eq('<wa-video src="movie.mp4" poster="poster.jpg" title="Title"></wa-video>')
    end

    it 'HTML-escapes src, poster, and title' do
      result = described_class.transform(";;;\n[A & B <\"'>](u.mp4?a=1&b=2)\n![P&Q](p.jpg?x=1&y=2)\n;;;")

      expect(result).to include('src="u.mp4?a=1&amp;b=2"')
      expect(result).to include('poster="p.jpg?x=1&amp;y=2"')
      expect(result).to include('title="A &amp; B &lt;&quot;&#39;&gt;"')
    end
  end

  describe '.transform playlist' do
    context 'with primary syntax' do
      it 'wraps items and forwards controls to the container only' do
        input = <<~MARKDOWN
          ;;;;;;controls:standard
          ;;;
          [Part 1](a.mp4)
          ![Poster A](a.jpg)
          ;;;
          ;;;
          [Part 2](b.mp4)
          ;;;
          ;;;;;;
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to eq(
          '<wa-video-playlist controls="standard">' \
          '<wa-video src="a.mp4" poster="a.jpg" title="Part 1"></wa-video>' \
          '<wa-video src="b.mp4" title="Part 2"></wa-video>' \
          '</wa-video-playlist>' \
          "\n"
        )
      end

      it 'omits the container controls attribute when not specified' do
        input = ";;;;;;\n;;;\n[One](1.mp4)\n;;;\n;;;;;;"

        expect(described_class.transform(input)).to eq(
          '<wa-video-playlist><wa-video src="1.mp4" title="One"></wa-video></wa-video-playlist>'
        )
      end

      it 'does not emit controls on the children' do
        input = ";;;;;;controls:full\n;;;\n[One](1.mp4)\n;;;\n;;;;;;"

        result = described_class.transform(input)

        expect(result.scan('controls=').length).to eq(1)
        expect(result).to include('<wa-video-playlist controls="full">')
        expect(result).to include('<wa-video src="1.mp4" title="One"></wa-video>')
      end
    end

    context 'with alternative syntax' do
      it 'transforms :::wa-video-playlist scanning the body for ;;; items' do
        input = <<~MARKDOWN
          :::wa-video-playlist controls:none
          ;;;
          [One](1.mp4)
          ;;;
          ;;;
          [Two](2.mp4)
          ![P](2.jpg)
          ;;;
          :::
        MARKDOWN

        result = described_class.transform(input)

        expect(result).to eq(
          '<wa-video-playlist controls="none">' \
          '<wa-video src="1.mp4" title="One"></wa-video>' \
          '<wa-video src="2.mp4" poster="2.jpg" title="Two"></wa-video>' \
          '</wa-video-playlist>' \
          "\n"
        )
      end
    end
  end

  describe '.render_as_markdown' do
    it 'degrades a single video to a markdown link' do
      result = described_class.render_as_markdown(";;;controls:full\n[My Clip](test_video.mp4)\n![P](p.jpg)\n;;;")

      expect(result).to eq('[My Clip](test_video.mp4)')
    end

    it 'leaves a link-less single block untransformed' do
      input = ";;;\n![Only poster](p.jpg)\n;;;"

      expect(described_class.render_as_markdown(input)).to eq(input)
    end

    it 'degrades a playlist to a bulleted list of links' do
      input = <<~MARKDOWN.chomp
        ;;;;;;controls:standard
        ;;;
        [Part 1](a.mp4)
        ;;;
        ;;;
        [Part 2](b.mp4)
        ;;;
        ;;;;;;
      MARKDOWN

      result = described_class.render_as_markdown(input)

      expect(result).to eq("- [Part 1](a.mp4)\n- [Part 2](b.mp4)")
    end
  end

  describe 'pipeline integration' do
    it 'runs as part of Transformer.process and preserves surrounding content' do
      input = "Intro text.\n\n;;;\n[Clip](v.mp4)\n;;;\n\nOutro text."

      result = Markawesome::Transformer.process(input)

      expect(result).to include('Intro text.')
      expect(result).to include('Outro text.')
      expect(result).to include('<wa-video src="v.mp4" title="Clip"></wa-video>')
    end
  end
end
