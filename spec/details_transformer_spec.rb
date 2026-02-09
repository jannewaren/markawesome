# frozen_string_literal: true

RSpec.describe Markawesome::DetailsTransformer do
  describe '.transform' do
    it 'transforms basic summary/details' do
      markdown = "^^^\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\'>')
      expect(result).to include('<span slot=\'summary\'><p>Summary here</p>')
      expect(result).to include('<p>Details here</p>')
      expect(result).to include('</wa-details>')
    end

    it 'transforms filled appearance' do
      markdown = "^^^filled\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'filled\' icon-placement=\'end\'>')
    end

    it 'transforms filled-outlined appearance' do
      markdown = "^^^filled-outlined\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'filled outlined\' icon-placement=\'end\'>')
    end

    it 'transforms plain appearance' do
      markdown = "^^^plain\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'plain\' icon-placement=\'end\'>')
    end

    it 'transforms outlined appearance explicitly' do
      markdown = "^^^outlined\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\'>')
    end

    it 'handles multiline summary and details' do
      markdown = "^^^\nSummary line 1\nSummary line 2\n>>>\nDetails line 1\n\nDetails line 2\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<span slot=\'summary\'><p>Summary line 1')
      expect(result).to include('Summary line 2</p>')
      expect(result).to include('<p>Details line 1</p>')
      expect(result).to include('<p>Details line 2</p>')
    end

    it 'does not transform incomplete syntax' do
      markdown = "^^^\nSummary here\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to eq(markdown)
    end

    it 'transforms with icon placement start' do
      markdown = "^^^ start\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'start\'>')
      expect(result).to include('<span slot=\'summary\'><p>Summary here</p>')
      expect(result).to include('<p>Details here</p>')
      expect(result).to include('</wa-details>')
    end

    it 'transforms with icon placement end' do
      markdown = "^^^ end\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\'>')
    end

    it 'defaults to end icon placement when not specified' do
      markdown = "^^^\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\'>')
    end

    it 'transforms with both appearance and icon placement' do
      markdown = "^^^filled start\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'filled\' icon-placement=\'start\'>')
    end

    it 'transforms with appearance first then icon placement' do
      markdown = "^^^outlined end\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\'>')
    end

    it 'transforms filled-outlined with start placement' do
      markdown = "^^^filled-outlined start\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'filled outlined\' icon-placement=\'start\'>')
    end

    it 'transforms alternative syntax with icon placement' do
      markdown = ":::wa-details filled start\nSummary here\n>>>\nDetails here\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'filled\' icon-placement=\'start\'>')
    end

    it 'transforms alternative syntax with only icon placement' do
      markdown = ":::wa-details start\nSummary here\n>>>\nDetails here\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'start\'>')
    end

    it 'handles parameter order flexibility' do
      markdown_1 = "^^^start filled\nSummary here\n>>>\nDetails here\n^^^"
      markdown_2 = "^^^filled start\nSummary here\n>>>\nDetails here\n^^^"

      result_1 = described_class.transform(markdown_1)
      result_2 = described_class.transform(markdown_2)

      # Both should produce the same result regardless of parameter order
      expect(result_1).to include('<wa-details appearance=\'filled\' icon-placement=\'start\'>')
      expect(result_2).to include('<wa-details appearance=\'filled\' icon-placement=\'start\'>')
      expect(result_1).to eq(result_2)
    end

    it 'transforms with disabled attribute' do
      markdown = "^^^disabled\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\' disabled>')
      expect(result).to include('<span slot=\'summary\'><p>Summary here</p>')
      expect(result).to include('<p>Details here</p>')
    end

    it 'transforms with open attribute' do
      markdown = "^^^open\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\' open>')
      expect(result).to include('<span slot=\'summary\'><p>Summary here</p>')
      expect(result).to include('<p>Details here</p>')
    end

    it 'transforms with name attribute' do
      markdown = "^^^name:group-1\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\' name=\'group-1\'>')
      expect(result).to include('<span slot=\'summary\'><p>Summary here</p>')
      expect(result).to include('<p>Details here</p>')
    end

    it 'transforms with disabled and open together' do
      markdown = "^^^disabled open\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\' disabled open>')
    end

    it 'transforms with all attributes combined' do
      markdown = "^^^filled start disabled open name:accordion-1\nSummary here\n>>>\nDetails here\n^^^"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'filled\' icon-placement=\'start\' disabled open name=\'accordion-1\'>')
      expect(result).to include('<span slot=\'summary\'><p>Summary here</p>')
      expect(result).to include('<p>Details here</p>')
    end

    it 'transforms alternative syntax with disabled' do
      markdown = ":::wa-details disabled\nSummary here\n>>>\nDetails here\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\' disabled>')
    end

    it 'transforms alternative syntax with open' do
      markdown = ":::wa-details open\nSummary here\n>>>\nDetails here\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\' open>')
    end

    it 'transforms alternative syntax with name' do
      markdown = ":::wa-details name:my-group\nSummary here\n>>>\nDetails here\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'outlined\' icon-placement=\'end\' name=\'my-group\'>')
    end

    it 'transforms alternative syntax with all new attributes' do
      markdown = ":::wa-details filled-outlined start disabled open name:test-group\nSummary here\n>>>\nDetails here\n:::"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-details appearance=\'filled outlined\' icon-placement=\'start\' disabled open name=\'test-group\'>')
    end

    context 'with custom expand/collapse icons' do
      it 'transforms with custom expand icon' do
        markdown = "^^^icon:expand:plus\nSummary here\n>>>\nDetails here\n^^^"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-icon slot="expand-icon" name="plus"></wa-icon>')
      end

      it 'transforms with custom collapse icon' do
        markdown = "^^^icon:collapse:minus\nSummary here\n>>>\nDetails here\n^^^"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-icon slot="collapse-icon" name="minus"></wa-icon>')
      end

      it 'transforms with both expand and collapse icons' do
        markdown = "^^^icon:expand:plus icon:collapse:minus\nSummary here\n>>>\nDetails here\n^^^"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-icon slot="expand-icon" name="plus"></wa-icon>')
        expect(result).to include('<wa-icon slot="collapse-icon" name="minus"></wa-icon>')
      end

      it 'combines icons with other attributes' do
        markdown = "^^^icon:expand:chevron-down outlined open\nSummary here\n>>>\nDetails here\n^^^"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-icon slot="expand-icon" name="chevron-down"></wa-icon>')
        expect(result).to include("appearance='outlined'")
        expect(result).to include('open>')
      end

      it 'works without icons (existing behavior preserved)' do
        markdown = "^^^filled\nSummary here\n>>>\nDetails here\n^^^"
        result = described_class.transform(markdown)

        expect(result).to include("<wa-details appearance='filled' icon-placement='end'>")
        expect(result).not_to include('<wa-icon')
      end

      it 'works with alternative syntax' do
        markdown = ":::wa-details icon:expand:caret-right icon:collapse:caret-down\nSummary here\n>>>\nDetails here\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-icon slot="expand-icon" name="caret-right"></wa-icon>')
        expect(result).to include('<wa-icon slot="collapse-icon" name="caret-down"></wa-icon>')
      end

      it 'combines icons with name attribute' do
        markdown = "^^^icon:expand:plus name:group-1\nSummary here\n>>>\nDetails here\n^^^"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-icon slot="expand-icon" name="plus"></wa-icon>')
        expect(result).to include("name='group-1'")
      end
    end

    it 'handles flexible parameter ordering with new attributes' do
      markdown_1 = "^^^disabled name:g1 open filled\nSummary\n>>>\nDetails\n^^^"
      markdown_2 = "^^^filled open disabled name:g1\nSummary\n>>>\nDetails\n^^^"

      result_1 = described_class.transform(markdown_1)
      result_2 = described_class.transform(markdown_2)

      expect(result_1).to include('<wa-details appearance=\'filled\' icon-placement=\'end\' disabled open name=\'g1\'>')
      expect(result_2).to include('<wa-details appearance=\'filled\' icon-placement=\'end\' disabled open name=\'g1\'>')
    end
  end
end
