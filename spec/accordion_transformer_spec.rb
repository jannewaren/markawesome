# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::AccordionTransformer do
  describe '.transform' do
    it 'transforms a basic accordion' do
      markdown = "//////\n/// What is Web Awesome?\nA library of web components.\n///\n//////"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-accordion appearance="outlined">')
      expect(result).to include('<wa-accordion-item label="What is Web Awesome?">')
      expect(result).to include('<p>A library of web components.</p>')
      expect(result).to include('</wa-accordion-item>')
      expect(result).to include('</wa-accordion>')
    end

    it 'transforms multiple items' do
      markdown = "//////\n/// One\nFirst body\n///\n/// Two\nSecond body\n///\n//////"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-accordion-item label="One">')
      expect(result).to include('<wa-accordion-item label="Two">')
      expect(result).to include('<p>First body</p>')
      expect(result).to include('<p>Second body</p>')
    end

    it 'always emits the default outlined appearance' do
      markdown = "//////\n/// Q\nA\n///\n//////"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-accordion appearance="outlined">')
    end

    context 'with appearance' do
      %w[filled filled-outlined plain outlined].each do |appearance|
        it "transforms #{appearance} appearance" do
          markdown = "//////#{appearance}\n/// Q\nA\n///\n//////"
          result = described_class.transform(markdown)

          expect(result).to include("<wa-accordion appearance=\"#{appearance}\">")
        end
      end
    end

    context 'with mode' do
      %w[multiple single single-collapsible].each do |mode|
        it "transforms #{mode} mode" do
          markdown = "//////#{mode}\n/// Q\nA\n///\n//////"
          result = described_class.transform(markdown)

          expect(result).to include("mode=\"#{mode}\"")
        end
      end

      it 'omits mode when not specified' do
        markdown = "//////\n/// Q\nA\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).not_to include('mode=')
      end
    end

    context 'with icon-placement' do
      it 'transforms start placement' do
        markdown = "//////start\n/// Q\nA\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).to include('icon-placement="start"')
      end

      it 'omits icon-placement when not specified (uses WA default end)' do
        markdown = "//////\n/// Q\nA\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).not_to include('icon-placement=')
      end
    end

    context 'with heading:N' do
      (1..6).each do |level|
        it "emits heading-level=\"#{level}\"" do
          markdown = "//////heading:#{level}\n/// Q\nA\n///\n//////"
          result = described_class.transform(markdown)

          expect(result).to include("heading-level=\"#{level}\"")
        end
      end

      it 'accepts heading:none' do
        markdown = "//////heading:none\n/// Q\nA\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).to include('heading-level="none"')
      end

      it 'falls back (omits heading-level) for out-of-range values' do
        markdown = "//////heading:7\n/// Q\nA\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).not_to include('heading-level=')
      end
    end

    context 'with combined container attributes' do
      it 'emits appearance, mode and icon-placement together' do
        markdown = "//////filled single start\n/// Q\nA\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-accordion appearance="filled" mode="single" icon-placement="start">')
      end

      it 'is order-independent' do
        markdown = "//////single filled\n/// Q\nA\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).to include('appearance="filled"')
        expect(result).to include('mode="single"')
      end

      it 'uses rightmost-wins for duplicate appearance' do
        markdown = "//////filled plain\n/// Q\nA\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).to include('appearance="plain"')
      end
    end

    context 'with item flags' do
      it 'emits expanded' do
        markdown = "//////\n/// expanded Open by default\nbody\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-accordion-item label="Open by default" expanded>')
      end

      it 'emits disabled' do
        markdown = "//////\n/// disabled Cannot open\nbody\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-accordion-item label="Cannot open" disabled>')
      end

      it 'emits expanded and disabled together' do
        markdown = "//////\n/// expanded disabled Both\nbody\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).to include('label="Both" expanded disabled>')
      end

      it 'does not treat a capitalized label word as a flag' do
        markdown = "//////\n/// Expanded view of the data\nbody\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-accordion-item label="Expanded view of the data">')
      end
    end

    context 'with a custom item icon' do
      it 'emits the icon as the item first child' do
        markdown = "//////\n/// icon:star Favorites\nbody\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-accordion-item label="Favorites"><wa-icon slot="icon" name="star"></wa-icon>')
      end

      it 'combines an icon with flags' do
        markdown = "//////\n/// expanded icon:star Favorites\nbody\n///\n//////"
        result = described_class.transform(markdown)

        expect(result).to include('label="Favorites" expanded>')
        expect(result).to include('<wa-icon slot="icon" name="star"></wa-icon>')
      end
    end

    it 'renders markdown in item bodies' do
      markdown = "//////\n/// Rich\n# Heading\n\n- item one\n- item two\n///\n//////"
      result = described_class.transform(markdown)

      expect(result).to include('<h1 id="heading">Heading</h1>')
      expect(result).to include('<li>item one</li>')
    end

    it 'escapes HTML in the label' do
      markdown = "//////\n/// 5 > 3 & \"quoted\"\nbody\n///\n//////"
      result = described_class.transform(markdown)

      expect(result).to include('label="5 &gt; 3 &amp; &quot;quoted&quot;"')
    end

    it 'does not transform incomplete syntax' do
      markdown = "//////\n/// Q\nA\n//////"
      result = described_class.transform(markdown)

      expect(result).to eq(markdown)
    end

    context 'with alternative :::wa-accordion syntax' do
      it 'transforms a basic accordion' do
        markdown = ":::wa-accordion\n/// Q\nA\n///\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-accordion appearance="outlined">')
        expect(result).to include('<wa-accordion-item label="Q">')
      end

      it 'accepts container attributes' do
        markdown = ":::wa-accordion filled single\n/// Q\nA\n///\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('appearance="filled"')
        expect(result).to include('mode="single"')
      end
    end

    context 'callout guard' do
      it 'is not hijacked by the callout transformer' do
        markdown = ":::wa-accordion\n/// Q\nA\n///\n:::"

        expect(Markawesome::CalloutTransformer.transform(markdown)).not_to include('<wa-callout')
        expect(described_class.transform(markdown)).to include('<wa-accordion')
      end

      it 'yields an accordion (not a callout) through the full pipeline' do
        markdown = ":::wa-accordion\n/// Q\nA\n///\n:::"
        result = Markawesome::Transformer.process(markdown)

        expect(result).to include('<wa-accordion')
        expect(result).not_to include('<wa-callout')
      end
    end
  end
end
