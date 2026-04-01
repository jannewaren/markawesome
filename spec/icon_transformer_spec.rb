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

    context 'with extended inline syntax ($$$icon-name[params])' do
      it 'transforms icon with rotate attribute' do
        content = 'Rotated $$$arrow-right[rotate:90] icon.'
        expected = 'Rotated <wa-icon name="arrow-right" rotate="90"></wa-icon> icon.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms icon with flip attribute' do
        content = 'Flipped $$$arrow-left[flip:x] icon.'
        expected = 'Flipped <wa-icon name="arrow-left" flip="x"></wa-icon> icon.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms icon with flip both' do
        content = '$$$arrow-up[flip:both]'
        expected = '<wa-icon name="arrow-up" flip="both"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms icon with animation attribute' do
        content = 'Loading $$$spinner[animation:spin] please wait.'
        expected = 'Loading <wa-icon name="spinner" animation="spin"></wa-icon> please wait.'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'supports all animation values' do
        %w[beat flip bounce shake spin spin-pulse spin-reverse].each do |anim|
          content = "$$$icon[animation:#{anim}]"
          result = described_class.transform(content)
          expect(result).to include("animation=\"#{anim}\"")
        end
      end

      it 'transforms icon with family attribute' do
        content = 'Brand icon: $$$twitter[family:brands]'
        expected = 'Brand icon: <wa-icon name="twitter" family="brands"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'supports all family values' do
        %w[classic brands sharp duotone sharp-duotone].each do |fam|
          content = "$$$icon[family:#{fam}]"
          result = described_class.transform(content)
          expect(result).to include("family=\"#{fam}\"")
        end
      end

      it 'transforms icon with variant attribute' do
        content = '$$$gear[variant:solid]'
        expected = '<wa-icon name="gear" variant="solid"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'supports all variant values' do
        %w[thin light regular solid].each do |var|
          content = "$$$icon[variant:#{var}]"
          result = described_class.transform(content)
          expect(result).to include("variant=\"#{var}\"")
        end
      end

      it 'transforms icon with label attribute' do
        content = '$$$home[label:"Go home"]'
        expected = '<wa-icon name="home" label="Go home"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms icon with label using single quotes' do
        content = "$$$home[label:'Go home']"
        expected = '<wa-icon name="home" label="Go home"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'combines multiple attributes' do
        content = '$$$spinner[family:classic variant:solid animation:spin]'
        expected = '<wa-icon name="spinner" family="classic" variant="solid" animation="spin"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'combines rotate and flip' do
        content = '$$$arrow-right[rotate:90 flip:x]'
        expected = '<wa-icon name="arrow-right" rotate="90" flip="x"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'combines all attributes' do
        content = '$$$star[family:classic variant:solid rotate:180 flip:y animation:beat label:"Favorite"]'
        result = described_class.transform(content)

        expect(result).to include('name="star"')
        expect(result).to include('family="classic"')
        expect(result).to include('variant="solid"')
        expect(result).to include('rotate="180"')
        expect(result).to include('flip="y"')
        expect(result).to include('animation="beat"')
        expect(result).to include('label="Favorite"')
      end

      it 'ignores invalid attribute values' do
        content = '$$$icon[rotate:45]'
        result = described_class.transform(content)
        expect(result).not_to include('rotate=')
        expect(result).to include('name="icon"')
      end

      it 'still transforms simple syntax alongside extended' do
        content = 'Simple $$$home and extended $$$spinner[animation:spin] icons.'
        result = described_class.transform(content)

        expect(result).to include('<wa-icon name="home"></wa-icon>')
        expect(result).to include('<wa-icon name="spinner" animation="spin"></wa-icon>')
      end
    end

    context 'with alternative syntax and attributes' do
      it 'transforms icon with attributes in block syntax' do
        content = ":::wa-icon spinner animation:spin\n:::"
        expected = '<wa-icon name="spinner" animation="spin"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms icon with family in block syntax' do
        content = ":::wa-icon twitter family:brands\n:::"
        expected = '<wa-icon name="twitter" family="brands"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms icon with multiple attributes in block syntax' do
        content = ":::wa-icon gear variant:solid rotate:90 flip:x\n:::"
        expected = '<wa-icon name="gear" variant="solid" rotate="90" flip="x"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'transforms icon with label in block syntax' do
        content = ":::wa-icon home label:\"Go home\"\n:::"
        expected = '<wa-icon name="home" label="Go home"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
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

      it 'handles empty brackets' do
        content = '$$$home[]'
        expected = '<wa-icon name="home"></wa-icon>'

        result = described_class.transform(content)
        expect(result).to eq(expected)
      end

      it 'does not transform brackets without icon name' do
        content = 'Text with [rotate:90] not an icon.'
        result = described_class.transform(content)
        expect(result).to eq(content)
      end
    end
  end
end
