# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::ButtonTransformer do
  describe '.transform' do
    context 'with link button syntax' do
      it 'transforms simple link button without variant' do
        input = "%%%\n[Click here](https://example.com)\n%%%"
        expected = '<wa-button href="https://example.com">Click here</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms link button with brand variant' do
        input = "%%%brand\n[Download](https://example.com/download)\n%%%"
        expected = '<wa-button variant="brand" href="https://example.com/download">Download</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms link button with success variant' do
        input = "%%%success\n[Get Started](https://example.com/start)\n%%%"
        expected = '<wa-button variant="success" href="https://example.com/start">Get Started</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms link button with warning variant' do
        input = "%%%warning\n[Proceed with Caution](https://example.com/warning)\n%%%"
        expected = '<wa-button variant="warning" href="https://example.com/warning">Proceed with Caution</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms link button with danger variant' do
        input = "%%%danger\n[Delete](https://example.com/delete)\n%%%"
        expected = '<wa-button variant="danger" href="https://example.com/delete">Delete</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms link button with neutral variant' do
        input = "%%%neutral\n[Continue](https://example.com/continue)\n%%%"
        expected = '<wa-button variant="neutral" href="https://example.com/continue">Continue</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with alternative link button syntax' do
      it 'transforms simple link button without variant' do
        input = ":::wa-button\n[Click here](https://example.com)\n:::"
        expected = '<wa-button href="https://example.com">Click here</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms link button with brand variant' do
        input = ":::wa-button brand\n[Download](https://example.com/download)\n:::"
        expected = '<wa-button variant="brand" href="https://example.com/download">Download</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with regular button syntax' do
      it 'transforms simple button without variant' do
        input = "%%%\nClick me\n%%%"
        expected = '<wa-button>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with brand variant' do
        input = "%%%brand\nSubmit Form\n%%%"
        expected = '<wa-button variant="brand">Submit Form</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with danger variant' do
        input = "%%%danger\nDelete Account\n%%%"
        expected = '<wa-button variant="danger">Delete Account</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with alternative regular button syntax' do
      it 'transforms simple button without variant' do
        input = ":::wa-button\nClick me\n:::"
        expected = '<wa-button>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with brand variant' do
        input = ":::wa-button brand\nSubmit Form\n:::"
        expected = '<wa-button variant="brand">Submit Form</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with markdown content in links' do
      it 'handles bold text in link buttons' do
        input = "%%%brand\n[**Download** Now](https://example.com)\n%%%"
        expected = '<wa-button variant="brand" href="https://example.com"><strong>Download</strong>&nbsp;Now</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles italic text in link buttons' do
        input = "%%%success\n[*Get* Started](https://example.com)\n%%%"
        expected = '<wa-button variant="success" href="https://example.com"><em>Get</em>&nbsp;Started</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles complex formatting in link buttons' do
        input = "%%%brand\n[**Download** *v2.0*](https://example.com/v2)\n%%%"
        expected = '<wa-button variant="brand" href="https://example.com/v2"><strong>Download</strong>&nbsp;<em>v2.0</em></wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with markdown content in regular buttons' do
      it 'handles bold text in regular buttons' do
        input = "%%%brand\n**Submit** Form\n%%%"
        expected = '<wa-button variant="brand"><strong>Submit</strong>&nbsp;Form</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles italic text in regular buttons' do
        input = "%%%warning\n*Proceed* with Caution\n%%%"
        expected = '<wa-button variant="warning"><em>Proceed</em>&nbsp;with Caution</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with invalid syntax' do
      it 'ignores invalid attribute names and creates button' do
        input = "%%%invalid\nContent\n%%%"
        expected = '<wa-button>Content</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'does not transform incomplete button syntax' do
        input = "%%%\nContent without closing"
        expected = "%%%\nContent without closing"

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'does not transform inline % symbols' do
        input = 'This has %%% in the middle of text'
        expected = 'This has %%% in the middle of text'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with whitespace handling' do
      it 'trims whitespace from button content' do
        input = "%%%\n  Spaced content  \n%%%"
        expected = '<wa-button>Spaced content</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles multiline regular button content' do
        input = "%%%\nLine one\nLine two\n%%%"
        expected = "<wa-button>Line one\nLine two</wa-button>"

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'edge cases' do
      it 'does not confuse partial link syntax' do
        input = "%%%\n[Incomplete link\n%%%"
        expected = '<wa-button>[Incomplete link</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles links with complex URLs' do
        input = "%%%brand\n[Query Link](https://example.com/path?param=value&other=123)\n%%%"
        expected = '<wa-button variant="brand" href="https://example.com/path?param=value&other=123">Query Link</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles relative URLs' do
        input = "%%%\n[Local Link](/path/to/page)\n%%%"
        expected = '<wa-button href="/path/to/page">Local Link</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with appearance attribute' do
      it 'transforms button with accent appearance' do
        input = "%%%accent\nClick me\n%%%"
        expected = '<wa-button appearance="accent">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with filled appearance' do
        input = "%%%filled\nClick me\n%%%"
        expected = '<wa-button appearance="filled">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with outlined appearance' do
        input = "%%%outlined\nClick me\n%%%"
        expected = '<wa-button appearance="outlined">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with filled-outlined appearance' do
        input = "%%%filled-outlined\nClick me\n%%%"
        expected = '<wa-button appearance="filled-outlined">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with plain appearance' do
        input = "%%%plain\nClick me\n%%%"
        expected = '<wa-button appearance="plain">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines variant and appearance' do
        input = "%%%brand filled\nClick me\n%%%"
        expected = '<wa-button variant="brand" appearance="filled">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles appearance in any order' do
        input = "%%%filled brand\nClick me\n%%%"
        expected = '<wa-button variant="brand" appearance="filled">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with size attribute' do
      it 'transforms button with small size' do
        input = "%%%small\nClick me\n%%%"
        expected = '<wa-button size="small">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with medium size' do
        input = "%%%medium\nClick me\n%%%"
        expected = '<wa-button size="medium">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with large size' do
        input = "%%%large\nClick me\n%%%"
        expected = '<wa-button size="large">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines variant and size' do
        input = "%%%brand large\nClick me\n%%%"
        expected = '<wa-button variant="brand" size="large">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles size in any order' do
        input = "%%%large brand\nClick me\n%%%"
        expected = '<wa-button variant="brand" size="large">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with pill attribute' do
      it 'transforms button with pill' do
        input = "%%%pill\nClick me\n%%%"
        expected = '<wa-button pill>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines variant and pill' do
        input = "%%%brand pill\nClick me\n%%%"
        expected = '<wa-button variant="brand" pill>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines pill with size' do
        input = "%%%pill large\nClick me\n%%%"
        expected = '<wa-button size="large" pill>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles pill in any order' do
        input = "%%%large brand pill\nClick me\n%%%"
        expected = '<wa-button variant="brand" size="large" pill>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with caret attribute' do
      it 'transforms button with caret' do
        input = "%%%caret\nClick me\n%%%"
        expected = '<wa-button with-caret>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines variant and caret' do
        input = "%%%brand caret\nClick me\n%%%"
        expected = '<wa-button variant="brand" with-caret>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines caret with size' do
        input = "%%%small caret\nClick me\n%%%"
        expected = '<wa-button size="small" with-caret>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with loading attribute' do
      it 'transforms button with loading' do
        input = "%%%loading\nClick me\n%%%"
        expected = '<wa-button loading>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines variant and loading' do
        input = "%%%brand loading\nClick me\n%%%"
        expected = '<wa-button variant="brand" loading>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines loading with size' do
        input = "%%%large loading\nClick me\n%%%"
        expected = '<wa-button size="large" loading>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with disabled attribute' do
      it 'transforms button with disabled' do
        input = "%%%disabled\nClick me\n%%%"
        expected = '<wa-button disabled>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines variant and disabled' do
        input = "%%%brand disabled\nClick me\n%%%"
        expected = '<wa-button variant="brand" disabled>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines disabled with link button' do
        input = "%%%disabled brand\n[Link](https://example.com)\n%%%"
        expected = '<wa-button variant="brand" disabled href="https://example.com">Link</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with complex attribute combinations' do
      it 'combines variant, appearance, size, and pill' do
        input = "%%%brand filled large pill\nClick me\n%%%"
        expected = '<wa-button variant="brand" appearance="filled" size="large" pill>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines multiple attributes in any order' do
        input = "%%%pill success small outlined\nClick me\n%%%"
        expected = '<wa-button variant="success" appearance="outlined" size="small" pill>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'combines all possible attributes' do
        input = "%%%danger filled large pill caret loading disabled\nClick me\n%%%"
        expected = '<wa-button variant="danger" appearance="filled" size="large" pill with-caret loading disabled>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'uses rightmost-wins for duplicate attributes' do
        input = "%%%small large\nClick me\n%%%"
        expected = '<wa-button size="large">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with alternative syntax and new attributes' do
      it 'transforms with appearance using alternative syntax' do
        input = ":::wa-button brand filled\nClick me\n:::"
        expected = '<wa-button variant="brand" appearance="filled">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms with size using alternative syntax' do
        input = ":::wa-button large\nClick me\n:::"
        expected = '<wa-button size="large">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms with pill using alternative syntax' do
        input = ":::wa-button pill brand\nClick me\n:::"
        expected = '<wa-button variant="brand" pill>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms with all attributes using alternative syntax' do
        input = ":::wa-button success outlined small pill caret\nClick me\n:::"
        expected = '<wa-button variant="success" appearance="outlined" size="small" pill with-caret>Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with icon support' do
      it 'transforms button with start icon (default)' do
        input = "%%%icon:download\nDownload File\n%%%"
        expected = '<wa-button><wa-icon slot="start" name="download"></wa-icon>Download File</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with explicit start icon' do
        input = "%%%icon:start:gear\nSettings\n%%%"
        expected = '<wa-button><wa-icon slot="start" name="gear"></wa-icon>Settings</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with end icon' do
        input = "%%%icon:end:arrow-right\nNext\n%%%"
        expected = '<wa-button><wa-icon slot="end" name="arrow-right"></wa-icon>Next</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms button with both start and end icons' do
        input = "%%%icon:start:gear icon:end:arrow-right\nSettings\n%%%"
        result = described_class.transform(input)

        expect(result).to include('<wa-icon slot="start" name="gear"></wa-icon>')
        expect(result).to include('<wa-icon slot="end" name="arrow-right"></wa-icon>')
        expect(result).to include('Settings</wa-button>')
      end

      it 'combines icon with variant and other attributes' do
        input = "%%%success icon:gear large pill\nSettings\n%%%"
        expected = '<wa-button variant="success" size="large" pill>' \
                   '<wa-icon slot="start" name="gear"></wa-icon>Settings</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms link button with icon' do
        input = "%%%brand icon:download\n[Download](https://example.com/file.zip)\n%%%"
        expected = '<wa-button variant="brand" href="https://example.com/file.zip">' \
                   '<wa-icon slot="start" name="download"></wa-icon>Download</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'transforms link button with end icon' do
        input = "%%%icon:end:arrow-right\n[Continue](https://example.com)\n%%%"
        expected = '<wa-button href="https://example.com">' \
                   '<wa-icon slot="end" name="arrow-right"></wa-icon>Continue</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'works with alternative syntax' do
        input = ":::wa-button brand icon:download\nGet File\n:::"
        expected = '<wa-button variant="brand"><wa-icon slot="start" name="download"></wa-icon>Get File</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'handles icon with hyphenated name' do
        input = "%%%icon:circle-check\nVerified\n%%%"
        expected = '<wa-button><wa-icon slot="start" name="circle-check"></wa-icon>Verified</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'existing tests still work without icons' do
        input = "%%%brand\nClick me\n%%%"
        expected = '<wa-button variant="brand">Click me</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end

    context 'with link buttons and new attributes' do
      it 'applies size to link buttons' do
        input = "%%%large\n[Link](https://example.com)\n%%%"
        expected = '<wa-button size="large" href="https://example.com">Link</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'applies appearance to link buttons' do
        input = "%%%filled\n[Link](https://example.com)\n%%%"
        expected = '<wa-button appearance="filled" href="https://example.com">Link</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'applies pill to link buttons' do
        input = "%%%pill brand\n[Download](https://example.com/file.zip)\n%%%"
        expected = '<wa-button variant="brand" pill href="https://example.com/file.zip">Download</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end

      it 'applies multiple attributes to link buttons' do
        input = "%%%success outlined small pill\n[Get Started](https://example.com/start)\n%%%"
        expected = '<wa-button variant="success" appearance="outlined" size="small" pill href="https://example.com/start">Get Started</wa-button>'

        result = described_class.transform(input)
        expect(result).to eq(expected)
      end
    end
  end
end
