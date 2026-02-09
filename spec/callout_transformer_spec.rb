# frozen_string_literal: true

RSpec.describe Markawesome::CalloutTransformer do
  describe '.transform' do
    it 'transforms info callouts (alias for brand)' do
      markdown = ":::info\nThis is info\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-callout variant="brand">')
      expect(result).to include('<wa-icon slot="icon" name="circle-info" variant="solid"></wa-icon>')
      expect(result).to include('<p>This is info</p>')
      expect(result).to include('</wa-callout>')
    end

    it 'transforms brand callouts' do
      markdown = ":::brand\nThis is brand\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-callout variant="brand">')
      expect(result).to include('<wa-icon slot="icon" name="circle-info" variant="solid"></wa-icon>')
    end

    it 'transforms success callouts' do
      markdown = ":::success\nThis is success\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-callout variant="success">')
      expect(result).to include('<wa-icon slot="icon" name="circle-check" variant="solid"></wa-icon>')
    end

    it 'transforms warning callouts' do
      markdown = ":::warning\nThis is warning\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-callout variant="warning">')
      expect(result).to include('<wa-icon slot="icon" name="triangle-exclamation" variant="solid"></wa-icon>')
    end

    it 'transforms danger callouts' do
      markdown = ":::danger\nThis is danger\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-callout variant="danger">')
      expect(result).to include('<wa-icon slot="icon" name="circle-exclamation" variant="solid"></wa-icon>')
    end

    it 'transforms neutral callouts' do
      markdown = ":::neutral\nThis is neutral\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-callout variant="neutral">')
      expect(result).to include('<wa-icon slot="icon" name="gear" variant="solid"></wa-icon>')
    end

    it 'supports size attribute' do
      markdown = ":::info small\nThis is small\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-callout variant="brand" size="small">')
    end

    it 'supports appearance attribute' do
      markdown = ":::info accent\nThis is accent\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-callout variant="brand" appearance="accent">')
    end

    it 'supports size and appearance together' do
      markdown = ":::warning large filled-outlined\nContent\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-callout variant="warning" appearance="filled-outlined" size="large">')
    end

    context 'with custom icon override' do
      it 'overrides default icon with icon:name' do
        markdown = ":::warning icon:shield\nSecurity notice\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-icon slot="icon" name="shield" variant="solid"></wa-icon>')
        expect(result).not_to include('triangle-exclamation')
      end

      it 'uses default icon when no icon token present' do
        markdown = ":::warning\nRegular warning\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-icon slot="icon" name="triangle-exclamation" variant="solid"></wa-icon>')
      end

      it 'combines custom icon with size and appearance' do
        markdown = ":::brand icon:rocket large filled\nBlast off\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-callout variant="brand" appearance="filled" size="large">')
        expect(result).to include('<wa-icon slot="icon" name="rocket" variant="solid"></wa-icon>')
      end

      it 'works with explicit icon slot' do
        markdown = ":::success icon:icon:star\nStarred\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-icon slot="icon" name="star" variant="solid"></wa-icon>')
      end

      it 'handles hyphenated icon names' do
        markdown = ":::danger icon:circle-xmark\nError occurred\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-icon slot="icon" name="circle-xmark" variant="solid"></wa-icon>')
      end

      it 'works with alternative syntax' do
        markdown = ":::wa-callout warning icon:shield\nSecurity notice\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-icon slot="icon" name="shield" variant="solid"></wa-icon>')
        expect(result).to include('<wa-callout variant="warning">')
      end

      it 'works with info alias and custom icon' do
        markdown = ":::info icon:lightbulb\nTip content\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-callout variant="brand">')
        expect(result).to include('<wa-icon slot="icon" name="lightbulb" variant="solid"></wa-icon>')
      end
    end

    it 'does not transform invalid callout types' do
      markdown = ":::invalid\nThis is invalid\n:::"
      result = described_class.transform(markdown)

      expect(result).to eq(markdown)
    end

    it 'handles multiline content' do
      markdown = ":::info\nLine 1\nLine 2\n\nLine 4\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-callout variant="brand">')
      expect(result).to include('<p>Line 1')
      expect(result).to include('Line 2</p>')
      expect(result).to include('<p>Line 4</p>')
    end

    it 'handles two separate paragraphs' do
      markdown = ":::warning\nFirst paragraph\n\nSecond one.\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-callout variant="warning">')
      expect(result).to include('<p>First paragraph</p>')
      expect(result).to include('<p>Second one.</p>')
      expect(result).to include('</wa-callout>')
    end
  end
end
