# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::BadgeTransformer do
  describe '.transform' do
    context 'with basic badge syntax' do
      it 'transforms simple badge without attributes' do
        input = "!!!\nNew\n!!!"
        expected = '<wa-badge>New</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with brand variant' do
        input = "!!!brand\n5\n!!!"
        expected = '<wa-badge variant="brand">5</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with success variant' do
        input = "!!!success\nOnline\n!!!"
        expected = '<wa-badge variant="success">Online</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with warning variant' do
        input = "!!!warning\n3 pending\n!!!"
        expected = '<wa-badge variant="warning">3 pending</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with danger variant' do
        input = "!!!danger\nError\n!!!"
        expected = '<wa-badge variant="danger">Error</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with neutral variant' do
        input = "!!!neutral\nDraft\n!!!"
        expected = '<wa-badge variant="neutral">Draft</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with appearance attribute' do
      it 'transforms badge with accent appearance' do
        input = "!!!brand accent\nBadge\n!!!"
        expected = '<wa-badge variant="brand" appearance="accent">Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with filled appearance' do
        input = "!!!brand filled\nBadge\n!!!"
        expected = '<wa-badge variant="brand" appearance="filled">Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with outlined appearance' do
        input = "!!!brand outlined\nBadge\n!!!"
        expected = '<wa-badge variant="brand" appearance="outlined">Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with filled-outlined appearance' do
        input = "!!!brand filled-outlined\nBadge\n!!!"
        expected = '<wa-badge variant="brand" appearance="filled-outlined">Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with pill attribute' do
      it 'transforms badge with pill flag' do
        input = "!!!brand pill\nBadge\n!!!"
        expected = '<wa-badge variant="brand" pill>Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with pill and appearance' do
        input = "!!!brand pill filled\nBadge\n!!!"
        expected = '<wa-badge variant="brand" appearance="filled" pill>Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with attention attribute' do
      it 'transforms badge with none attention' do
        input = "!!!brand none\nBadge\n!!!"
        expected = '<wa-badge variant="brand" attention="none">Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with pulse attention' do
        input = "!!!brand pulse\nBadge\n!!!"
        expected = '<wa-badge variant="brand" attention="pulse">Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with bounce attention' do
        input = "!!!brand bounce\nBadge\n!!!"
        expected = '<wa-badge variant="brand" attention="bounce">Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with multiple attributes' do
      it 'combines variant, appearance, and attention' do
        input = "!!!brand filled pulse\nBadge\n!!!"
        expected = '<wa-badge variant="brand" appearance="filled" attention="pulse">Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines all attributes' do
        input = "!!!danger outlined pill bounce\nAlert\n!!!"
        expected = '<wa-badge variant="danger" appearance="outlined" attention="bounce" pill>Alert</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles attributes in any order' do
        input = "!!!pill brand filled\nBadge\n!!!"
        expected = '<wa-badge variant="brand" appearance="filled" pill>Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles attributes with rightmost-wins for variant conflicts' do
        input = "!!!brand danger\nBadge\n!!!"
        expected = '<wa-badge variant="danger">Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles attributes with rightmost-wins for appearance conflicts' do
        input = "!!!brand filled outlined\nBadge\n!!!"
        expected = '<wa-badge variant="brand" appearance="outlined">Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles attributes with rightmost-wins for attention conflicts' do
        input = "!!!brand pulse bounce\nBadge\n!!!"
        expected = '<wa-badge variant="brand" attention="bounce">Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with alternative badge syntax' do
      it 'transforms simple badge without attributes' do
        input = ":::wa-badge\nNew\n:::"
        expected = '<wa-badge>New</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with brand variant' do
        input = ":::wa-badge brand\n5\n:::"
        expected = '<wa-badge variant="brand">5</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms badge with multiple attributes' do
        input = ":::wa-badge brand filled pill\nBadge\n:::"
        expected = '<wa-badge variant="brand" appearance="filled" pill>Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles attributes in any order with alternative syntax' do
        input = ":::wa-badge pill brand filled\nBadge\n:::"
        expected = '<wa-badge variant="brand" appearance="filled" pill>Badge</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with markdown content' do
      it 'handles markdown formatting within badges' do
        input = "!!!brand\n**Bold** text\n!!!"
        expected = '<wa-badge variant="brand"><strong>Bold</strong>&nbsp;text</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles links within badges' do
        input = "!!!\n[Link](http://example.com)\n!!!"
        expected = '<wa-badge><a href="http://example.com">Link</a></wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'removes paragraph tags for simple text' do
        input = "!!!\nSimple text\n!!!"
        expected = '<wa-badge>Simple text</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles markdown with multiple attributes' do
        input = "!!!brand filled\n**Bold** text\n!!!"
        expected = '<wa-badge variant="brand" appearance="filled"><strong>Bold</strong>&nbsp;text</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with multiple badges' do
      it 'transforms multiple badges in content' do
        input = <<~MARKDOWN
          !!!brand
          First
          !!!

          Some content here.

          !!!success pill
          Second
          !!!
        MARKDOWN

        result = described_class.transform(input)
        expect(result).to include('<wa-badge variant="brand">First</wa-badge>')
        expect(result).to include('<wa-badge variant="success" pill>Second</wa-badge>')
        expect(result).to include('Some content here.')
      end
    end

    context 'with invalid syntax' do
      it 'ignores unrecognized attribute values and creates simple badge' do
        input = "!!!invalid\nContent\n!!!"
        expected = '<wa-badge>Content</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'does not transform incomplete badge syntax' do
        input = "!!!\nContent without closing"
        expected = "!!!\nContent without closing"

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'does not transform inline ! symbols' do
        input = 'This has !!! in the middle of text'
        expected = 'This has !!! in the middle of text'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with whitespace handling' do
      it 'trims whitespace from badge content' do
        input = "!!!\n  Spaced content  \n!!!"
        expected = '<wa-badge>Spaced content</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles multiline content' do
        input = "!!!\nLine one\nLine two\n!!!"
        expected = "<wa-badge>Line one\nLine two</wa-badge>"

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles whitespace in parameters' do
        input = "!!!  brand   filled   pill  \nContent\n!!!"
        expected = '<wa-badge variant="brand" appearance="filled" pill>Content</wa-badge>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end
  end
end
