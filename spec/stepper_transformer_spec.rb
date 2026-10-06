# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::StepperTransformer do
  describe '.transform' do
    it 'transforms a checkout stepper (exact)' do
      markdown = <<~MD.chomp
        >>>>>> vertical label:"Checkout progress"
        - [x] Cart
        - [x] Shipping
          Standard, 3–5 days
        - [ ] pulse icon:credit-card Payment
        - [ ] Review
        >>>>>>
      MD

      expect(described_class.transform(markdown)).to eq(
        '<wa-stepper orientation="vertical" label="Checkout progress" active="step-3">' \
        '<wa-step name="step-1" completed>Cart</wa-step>' \
        '<wa-step name="step-2" completed>Shipping<span slot="description">Standard, 3–5 days</span></wa-step>' \
        '<wa-step name="step-3" attention="pulse"><wa-icon slot="icon" name="credit-card"></wa-icon>Payment</wa-step>' \
        '<wa-step name="step-4">Review</wa-step>' \
        '</wa-stepper>'
      )
    end

    it 'accepts steps without checkboxes and any bullet' do
      markdown = ">>>>>>\n- One\n* Two\n+ Three\n>>>>>>"
      expect(described_class.transform(markdown)).to eq(
        '<wa-stepper active="step-1"><wa-step name="step-1">One</wa-step>' \
        '<wa-step name="step-2">Two</wa-step><wa-step name="step-3">Three</wa-step></wa-stepper>'
      )
    end

    it 'treats [X] as completed' do
      expect(described_class.transform(">>>>>>\n- [X] Done\n- [ ] Next\n>>>>>>"))
        .to include('<wa-step name="step-1" completed>Done</wa-step>')
    end

    context 'when resolving the active step' do
      it 'makes the last step active when all are complete' do
        result = described_class.transform(">>>>>>\n- [x] A\n- [x] B\n>>>>>>")
        expect(result).to start_with('<wa-stepper active="step-2">')
      end

      it 'honors an explicit active flag over the first incomplete step' do
        result = described_class.transform(">>>>>>\n- [ ] A\n- [ ] active B\n- [ ] C\n>>>>>>")
        expect(result).to start_with('<wa-stepper active="step-2">')
        expect(result).to include('<wa-step name="step-2">B</wa-step>')
      end

      it 'lets the last explicit active flag win' do
        result = described_class.transform(">>>>>>\n- active A\n- B\n- active C\n>>>>>>")
        expect(result).to start_with('<wa-stepper active="step-3">')
      end

      it 'emits no active attribute for an empty stepper' do
        expect(described_class.transform(">>>>>> vertical\n\n>>>>>>"))
          .to eq('<wa-stepper orientation="vertical"></wa-stepper>')
      end
    end

    it 'emits step attributes in a fixed order' do
      result = described_class.transform(">>>>>>\n- [x] bounce danger disabled loading Late\n>>>>>>")
      expect(result).to include(
        '<wa-step name="step-1" completed loading disabled variant="danger" attention="bounce">Late</wa-step>'
      )
    end

    it 'uses rightmost-wins for variant and attention' do
      result = described_class.transform(">>>>>>\n- warning success pulse none X\n>>>>>>")
      expect(result).to include('<wa-step name="step-1" variant="success" attention="none">X</wa-step>')
    end

    it 'only consumes flags at the start of the label' do
      result = described_class.transform(">>>>>>\n- Ship the active order\n>>>>>>")
      expect(result).to include('<wa-step name="step-1">Ship the active order</wa-step>')
    end

    it 'joins multi-line descriptions and renders them as inline Markdown' do
      markdown = ">>>>>>\n- Deploy\n  Push to **main**\n    then wait\n>>>>>>"
      expect(described_class.transform(markdown)).to include(
        '<wa-step name="step-1">Deploy<span slot="description">Push to <strong>main</strong> then wait</span></wa-step>'
      )
    end

    it 'ignores blank lines, unindented prose and continuations before the first step' do
      markdown = ">>>>>>\n  orphan\n\n- A\n\nnot a step\n- B\n>>>>>>"
      expect(described_class.transform(markdown)).to eq(
        '<wa-stepper active="step-1"><wa-step name="step-1">A</wa-step><wa-step name="step-2">B</wa-step></wa-stepper>'
      )
    end

    it 'renders labels as inline Markdown' do
      result = described_class.transform(">>>>>>\n- [Docs](/docs) & *more*\n>>>>>>")
      expect(result).to include('<wa-step name="step-1"><a href="/docs">Docs</a> &amp; <em>more</em></wa-step>')
    end

    it 'HTML-escapes the container label' do
      result = described_class.transform(">>>>>> label:\"Tom & <Jerry>\"\n- A\n>>>>>>")
      expect(result).to start_with('<wa-stepper label="Tom &amp; &lt;Jerry&gt;" active="step-1">')
    end

    it 'accepts a single-quoted label and keeps its words out of the orientation tokens' do
      result = described_class.transform(">>>>>> label:'The vertical path' horizontal\n- A\n>>>>>>")
      expect(result).to start_with('<wa-stepper orientation="horizontal" label="The vertical path" active="step-1">')
    end

    it 'drops unknown container tokens' do
      result = described_class.transform(">>>>>> clickable linear auto\n- A\n>>>>>>")
      expect(result).to start_with('<wa-stepper orientation="auto" active="step-1">')
    end

    it 'transforms the alternative syntax identically' do
      primary = described_class.transform(">>>>>> vertical\n- [x] A\n- B\n>>>>>>")
      alternative = described_class.transform(":::wa-stepper vertical\n- [x] A\n- B\n:::")
      expect(alternative).to eq(primary)
    end

    it 'leaves a lone >>> separator alone' do
      markdown = "^^^\nSummary\n>>>\nBody\n^^^"
      expect(described_class.transform(markdown)).to eq(markdown)
    end
  end
end
