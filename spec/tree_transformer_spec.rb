# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::TreeTransformer do
  describe '.transform' do
    it 'transforms a basic nested list with icons and fence open (exact)' do
      markdown = "||||||open\n- icon:folder src\n  - icon:file index.ts\n  - icon:file utils.ts\n- icon:file README.md\n||||||"
      result = described_class.transform(markdown)

      expect(result).to eq(
        '<wa-tree>' \
        '<wa-tree-item expanded><wa-icon name="folder"></wa-icon>src' \
        '<wa-tree-item><wa-icon name="file"></wa-icon>index.ts</wa-tree-item>' \
        '<wa-tree-item><wa-icon name="file"></wa-icon>utils.ts</wa-tree-item>' \
        '</wa-tree-item>' \
        '<wa-tree-item><wa-icon name="file"></wa-icon>README.md</wa-tree-item>' \
        '</wa-tree>'
      )
    end

    it 'transforms a flat list with no nesting' do
      markdown = "||||||\n- One\n- Two\n||||||"
      result = described_class.transform(markdown)

      expect(result).to eq('<wa-tree><wa-tree-item>One</wa-tree-item><wa-tree-item>Two</wa-tree-item></wa-tree>')
    end

    context 'with indentation width' do
      it 'nests with 2-space indentation' do
        markdown = "||||||\n- parent\n  - child\n||||||"
        result = described_class.transform(markdown)

        expect(result).to eq('<wa-tree><wa-tree-item>parent<wa-tree-item>child</wa-tree-item></wa-tree-item></wa-tree>')
      end

      it 'nests with 4-space indentation identically' do
        markdown = "||||||\n- parent\n    - child\n||||||"
        result = described_class.transform(markdown)

        expect(result).to eq('<wa-tree><wa-tree-item>parent<wa-tree-item>child</wa-tree-item></wa-tree-item></wa-tree>')
      end

      it 'treats a tab as four columns of indentation' do
        markdown = "||||||\n- parent\n\t- child\n||||||"
        result = described_class.transform(markdown)

        expect(result).to eq('<wa-tree><wa-tree-item>parent<wa-tree-item>child</wa-tree-item></wa-tree-item></wa-tree>')
      end

      it 'supports * and + bullet markers' do
        markdown = "||||||\n* parent\n  + child\n||||||"
        result = described_class.transform(markdown)

        expect(result).to eq('<wa-tree><wa-tree-item>parent<wa-tree-item>child</wa-tree-item></wa-tree-item></wa-tree>')
      end
    end

    context 'with expand state' do
      it 'expands every branch when the fence is open' do
        markdown = "||||||open\n- a\n  - b\n||||||"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tree-item expanded>a')
      end

      it 'treats expanded as an alias for the open fence token' do
        markdown = "||||||expanded\n- a\n  - b\n||||||"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tree-item expanded>a')
      end

      it 'expands only the flagged branch when the fence is closed' do
        markdown = "||||||\n- expanded a\n  - b\n- c\n  - d\n||||||"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tree-item expanded>a')
        expect(result).to include('<wa-tree-item>c')
      end

      it 'never marks a leaf as expanded even with the open fence' do
        markdown = "||||||open\n- a\n- b\n||||||"
        result = described_class.transform(markdown)

        expect(result).not_to include('expanded')
        expect(result).to eq('<wa-tree><wa-tree-item>a</wa-tree-item><wa-tree-item>b</wa-tree-item></wa-tree>')
      end

      it 'never marks a leaf as expanded even with a per-node expanded flag' do
        markdown = "||||||\n- expanded a\n||||||"
        result = described_class.transform(markdown)

        expect(result).to eq('<wa-tree><wa-tree-item>a</wa-tree-item></wa-tree>')
      end
    end

    context 'with a leading icon' do
      it 'emits the icon as the item first child with no slot attribute' do
        markdown = "||||||\n- icon:folder src\n||||||"
        result = described_class.transform(markdown)

        expect(result).to eq('<wa-tree><wa-tree-item><wa-icon name="folder"></wa-icon>src</wa-tree-item></wa-tree>')
      end

      it 'combines an icon with the expanded flag on a branch' do
        markdown = "||||||\n- expanded icon:folder src\n  - leaf\n||||||"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tree-item expanded><wa-icon name="folder"></wa-icon>src')
      end
    end

    context 'with label escaping' do
      it 'escapes < and > in labels' do
        markdown = "||||||\n- 5 > 3 & <tag>\n||||||"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tree-item>5 &gt; 3 &amp; &lt;tag&gt;</wa-tree-item>')
      end

      it 'keeps colon-bearing labels (element names) intact, not parsed as icons' do
        markdown = "||||||\n- Invoice\n  - cbc:ID\n  - cac:Item\n||||||"
        result = described_class.transform(markdown)

        expect(result).not_to include('<wa-icon')
        expect(result).to include('<wa-tree-item>cbc:ID</wa-tree-item>')
        expect(result).to include('<wa-tree-item>cac:Item</wa-tree-item>')
      end
    end

    it 'skips blank and non-list lines in the body' do
      markdown = "||||||\n- a\n\nnot a list line\n- b\n||||||"
      result = described_class.transform(markdown)

      expect(result).to eq('<wa-tree><wa-tree-item>a</wa-tree-item><wa-tree-item>b</wa-tree-item></wa-tree>')
    end

    it 'does not transform incomplete syntax (no closing fence)' do
      markdown = "||||||\n- a\n- b"
      result = described_class.transform(markdown)

      expect(result).to eq(markdown)
    end

    context 'with alternative :::wa-tree syntax' do
      it 'transforms a basic tree' do
        markdown = ":::wa-tree\n- a\n  - b\n:::"
        result = described_class.transform(markdown)

        expect(result).to eq('<wa-tree><wa-tree-item>a<wa-tree-item>b</wa-tree-item></wa-tree-item></wa-tree>')
      end

      it 'accepts the open fence token' do
        markdown = ":::wa-tree open\n- a\n  - b\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tree-item expanded>a')
      end
    end

    context 'callout guard' do
      it 'is not hijacked by the callout transformer' do
        markdown = ":::wa-tree\n- a\n  - b\n:::"

        expect(Markawesome::CalloutTransformer.transform(markdown)).not_to include('<wa-callout')
        expect(described_class.transform(markdown)).to include('<wa-tree')
      end

      it 'yields a tree (not a callout) through the full pipeline' do
        markdown = ":::wa-tree\n- a\n  - b\n:::"
        result = Markawesome::Transformer.process(markdown)

        expect(result).to include('<wa-tree')
        expect(result).not_to include('<wa-callout')
      end
    end
  end

  describe '.render_as_markdown' do
    it 'degrades to a clean nested list with tokens stripped' do
      markdown = "||||||open\n- icon:folder src\n  - icon:file index.ts\n  - icon:file utils.ts\n- icon:file README.md\n||||||"
      result = described_class.render_as_markdown(markdown)

      expect(result).to eq("- src\n  - index.ts\n  - utils.ts\n- README.md")
    end

    it 'normalizes 4-space indentation to a 2-space clean list' do
      markdown = "||||||\n- parent\n    - child\n||||||"
      result = described_class.render_as_markdown(markdown)

      expect(result).to eq("- parent\n  - child")
    end

    it 'degrades the alternative syntax too' do
      markdown = ":::wa-tree\n- a\n  - b\n:::"
      result = described_class.render_as_markdown(markdown)

      expect(result).to eq("- a\n  - b")
    end
  end
end
