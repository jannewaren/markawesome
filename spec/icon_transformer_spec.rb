# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::IconTransformer do
  describe '.transform' do
    context 'with primary syntax ($$$icon-name)' do
      it 'transforms basic icon syntax' do
        content = 'Click the $$$settings icon to configure.'
        expected = 'Click the <wa-icon name="settings"></wa-icon> icon to configure.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms hyphenated icon names' do
        content = 'Use the $$$user-circle icon.'
        expected = 'Use the <wa-icon name="user-circle"></wa-icon> icon.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms underscored icon names' do
        content = 'Click $$$home_page for navigation.'
        expected = 'Click <wa-icon name="home_page"></wa-icon> for navigation.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms numeric icon names' do
        content = 'See $$$icon123 for details.'
        expected = 'See <wa-icon name="icon123"></wa-icon> for details.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms multiple icons in one line' do
        content = 'Icons: $$$home, $$$settings, and $$$user.'
        expected = 'Icons: <wa-icon name="home"></wa-icon>, <wa-icon name="settings"></wa-icon>, and <wa-icon name="user"></wa-icon>.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms icons across multiple lines' do
        content = <<~MARKDOWN
          First line with $$$home icon.
          Second line with $$$settings icon.
          Third line with $$$user-circle icon.
        MARKDOWN

        expected = <<~HTML
          First line with <wa-icon name="home"></wa-icon> icon.
          Second line with <wa-icon name="settings"></wa-icon> icon.
          Third line with <wa-icon name="user-circle"></wa-icon> icon.
        HTML

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'works within markdown formatting' do
        content = 'Click **$$$settings** to configure or *$$$home* to navigate.'
        expected = 'Click **<wa-icon name="settings"></wa-icon>** to configure or *<wa-icon name="home"></wa-icon>* to navigate.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'works within links' do
        content = '[Go to $$$home page](https://example.com)'
        expected = '[Go to <wa-icon name="home"></wa-icon> page](https://example.com)'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'works in list items' do
        content = <<~MARKDOWN
          - $$$home Home page
          - $$$settings Configuration
          - $$$user-circle User profile
        MARKDOWN

        expected = <<~HTML
          - <wa-icon name="home"></wa-icon> Home page
          - <wa-icon name="settings"></wa-icon> Configuration
          - <wa-icon name="user-circle"></wa-icon> User profile
        HTML

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'ignores invalid icon names with spaces' do
        content = 'Invalid $$$icon name with spaces.'
        expected = 'Invalid $$$icon name with spaces.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'ignores incomplete syntax' do
        content = 'Incomplete $$$ syntax.'
        expected = 'Incomplete $$$ syntax.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'preserves existing wa-icon elements' do
        content = 'Existing <wa-icon name="test"></wa-icon> and new $$$home icon.'
        expected = 'Existing <wa-icon name="test"></wa-icon> and new <wa-icon name="home"></wa-icon> icon.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end
    end

    context 'with alternative syntax (:::wa-icon)' do
      it 'transforms basic alternative syntax' do
        content = <<~MARKDOWN
          Click the :::wa-icon settings
          ::: icon to configure.
        MARKDOWN

        expected = <<~HTML
          Click the <wa-icon name="settings"></wa-icon> icon to configure.
        HTML

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms hyphenated icon names' do
        content = <<~MARKDOWN
          Use the :::wa-icon user-circle
          ::: icon.
        MARKDOWN

        expected = <<~HTML
          Use the <wa-icon name="user-circle"></wa-icon> icon.
        HTML

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms multiple alternative syntax icons' do
        content = <<~MARKDOWN
          Icons: :::wa-icon home
          :::, :::wa-icon settings
          :::, and :::wa-icon user
          :::.
        MARKDOWN

        expected = <<~HTML
          Icons: <wa-icon name="home"></wa-icon>, <wa-icon name="settings"></wa-icon>, and <wa-icon name="user"></wa-icon>.
        HTML

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'handles extra whitespace' do
        content = <<~MARKDOWN
          :::wa-icon    settings#{'   '}
          :::
        MARKDOWN

        expected = <<~HTML
          <wa-icon name="settings"></wa-icon>
        HTML

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end
    end

    context 'with enriched alternative syntax' do
      it 'adds a family attribute' do
        result = described_class.transform(":::wa-icon star sharp\n:::")
        expect(result).to eq('<wa-icon name="star" family="sharp"></wa-icon>')
      end

      it 'adds a variant attribute' do
        result = described_class.transform(":::wa-icon star solid\n:::")
        expect(result).to eq('<wa-icon name="star" variant="solid"></wa-icon>')
      end

      it 'adds an animation attribute' do
        result = described_class.transform(":::wa-icon star spin\n:::")
        expect(result).to eq('<wa-icon name="star" animation="spin"></wa-icon>')
      end

      it 'combines family, variant, animation, and label in deterministic order' do
        result = described_class.transform(":::wa-icon star spin solid sharp\nFeatured\n:::")
        expect(result).to eq(
          '<wa-icon name="star" family="sharp" variant="solid" animation="spin" label="Featured"></wa-icon>'
        )
      end

      it 'is token-order-independent' do
        result = described_class.transform(":::wa-icon star spin solid sharp\n:::")
        expect(result).to eq(
          '<wa-icon name="star" family="sharp" variant="solid" animation="spin"></wa-icon>'
        )
      end

      it 'applies rightmost-wins for repeated attributes' do
        result = described_class.transform(":::wa-icon star thin solid\n:::")
        expect(result).to eq('<wa-icon name="star" variant="solid"></wa-icon>')
      end

      it 'silently drops unknown tokens' do
        result = described_class.transform(":::wa-icon star bogus spin\n:::")
        expect(result).to eq('<wa-icon name="star" animation="spin"></wa-icon>')
      end

      it 'sets a multi-word label from the block body' do
        result = described_class.transform(":::wa-icon heart solid\nAdd to favorites\n:::")
        expect(result).to eq('<wa-icon name="heart" variant="solid" label="Add to favorites"></wa-icon>')
      end

      it 'collapses a multi-line body into a single-space label' do
        result = described_class.transform(":::wa-icon bell shake\nFirst line\nSecond line\n:::")
        expect(result).to eq('<wa-icon name="bell" animation="shake" label="First line Second line"></wa-icon>')
      end

      it 'HTML-escapes the label value' do
        result = described_class.transform(%(:::wa-icon flag\nit's <a> & "b"\n:::))
        expect(result).to eq(%(<wa-icon name="flag" label="it&#39;s &lt;a&gt; &amp; &quot;b&quot;"></wa-icon>))
      end

      it 'emits a bare name for an empty body (backward compatible)' do
        result = described_class.transform(":::wa-icon settings\n:::")
        expect(result).to eq('<wa-icon name="settings"></wa-icon>')
      end

      it 'leaves $$$ inline icons name-only with trailing tokens untouched' do
        result = described_class.transform('$$$heart solid')
        expect(result).to eq('<wa-icon name="heart"></wa-icon> solid')
      end

      it 'does not transform an enriched block inside a fenced code block' do
        content = "```\n:::wa-icon star spin\n:::\n```"
        expect(described_class.transform(content)).to eq(content)
      end
    end

    context 'with mixed syntax' do
      it 'transforms both primary and alternative syntax' do
        content = <<~MARKDOWN
          Primary $$$home and alternative :::wa-icon settings
          ::: syntax together.
        MARKDOWN

        expected = <<~HTML
          Primary <wa-icon name="home"></wa-icon> and alternative <wa-icon name="settings"></wa-icon> syntax together.
        HTML

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end
    end

    context 'with code blocks' do
      it 'ignores icons inside code blocks' do
        content = <<~MARKDOWN
          Normal $$$home icon.

          ```
          Code block with $$$settings icon.
          ```

          More $$$user content.
        MARKDOWN

        # The transformer should preserve code blocks as-is
        # Icons inside code blocks should not be transformed
        result = described_class.transform(content)

        expect(result).to include('<wa-icon name="home"></wa-icon>')
        expect(result).to include('<wa-icon name="user"></wa-icon>')
        expect(result).to include('$$$settings icon.') # Should remain unchanged in code block
      end

      it 'ignores icons inside inline code' do
        content = 'Normal $$$home and `code with $$$settings` and more $$$user.'

        result = described_class.transform(content)

        expect(result).to include('<wa-icon name="home"></wa-icon>')
        expect(result).to include('<wa-icon name="user"></wa-icon>')
        expect(result).to include('`code with $$$settings`') # Should remain unchanged
      end
    end

    context 'edge cases' do
      it 'handles empty content' do
        content = ''
        result = described_class.transform(content)
        expect(result).to eq('')
      end

      it 'handles content with no icons' do
        content = 'This is regular content without any icons.'
        result = described_class.transform(content)
        expect(result).to eq(content)
      end

      it 'handles special characters around icons' do
        content = 'Before($$$home)after and [before$$$settings]after.'
        expected = 'Before(<wa-icon name="home"></wa-icon>)after and [before<wa-icon name="settings"></wa-icon>]after.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end
    end
  end
end
