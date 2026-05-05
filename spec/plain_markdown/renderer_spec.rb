# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::PlainMarkdownRenderer do
  describe '.process' do
    it 'strips Kramdown attribute syntax' do
      md = "## Heading {:.my-class}"
      expect(described_class.process(md)).to eq('## Heading')
    end

    it 'strips Kramdown attribute IDs' do
      md = "## Heading {:#slug}"
      expect(described_class.process(md)).to eq('## Heading')
    end

    it 'protects fenced code blocks from transformation' do
      md = <<~MD.strip
        Here is a callout example:

        ```markdown
        :::info
        should stay verbatim
        :::
        ```

        :::info
        This becomes a real note.
        :::
      MD
      result = described_class.process(md)
      expect(result).to include("```markdown\n:::info\nshould stay verbatim\n:::\n```")
      expect(result).to include('> [!NOTE]')
      expect(result).to include('This becomes a real note.')
    end

    it 'leaves vanilla markdown untouched' do
      md = <<~MD.strip
        # Title

        A paragraph with **bold** and _italic_ text, plus a [link](/go).

        - one
        - two

        | a | b |
        |---|---|
        | 1 | 2 |
      MD
      expect(described_class.process(md)).to eq(md)
    end

    it 'degrades a realistic docs page without leaking component markers' do
      md = <<~MD.strip
        # Getting started

        :::info
        Read this first.
        :::

        ::::grid gap:m
        ===
        ![Cover](cover.png)
        **Call it out**
        A short line.
        ===
        ::::

        ++++++
        +++ Tab 1
        Tab one body.
        +++
        +++ Tab 2
        Tab two body.
        +++
        ++++++

        %%%brand
        [Go](/go)
        %%%

        !!!brand
        New
        !!!

        Check @@@ brand Beta @@@ out.

        $$$cog

        See the heading {:.foo}.
      MD
      result = described_class.process(md)

      [
        /:::/, /\^\^\^/, /@@@/, /!!!/, /%%%/, /^===/, /^~~~~~~/,
        /^\|\|\|/, /^<<</, /^\?\?\?/, /\{:\./, /\{:#/, %r{<wa-[a-z-]+}
      ].each do |pattern|
        expect(result).not_to match(pattern), "expected output to not contain #{pattern}: #{result.inspect}"
      end

      expect(result).to include('> [!NOTE]')
      expect(result).to include('![Cover](cover.png)')
      expect(result).to include('### Call it out')
      expect(result).to include('### Tab 1')
      expect(result).to include('[Go](/go)')
      expect(result).to include('**New**')
      expect(result).to include('**Beta**')
    end
  end

  describe '.register_override' do
    after { described_class.reset_overrides! }

    it 'allows a host app to override a component rendering' do
      described_class.register_override(:callout) do |content, _opts|
        content.gsub(/^:::info\n(.*?)\n:::/m, 'CUSTOM: \1')
      end

      md = ":::info\nhi\n:::"
      expect(described_class.process(md)).to eq('CUSTOM: hi')
    end
  end
end
