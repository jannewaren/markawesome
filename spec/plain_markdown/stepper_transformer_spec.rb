# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::StepperTransformer do
  describe '.render_as_markdown' do
    it 'degrades to an ordered task list with the current step in bold (exact)' do
      md = <<~MD.chomp
        >>>>>> vertical label:"Checkout progress"
        - [x] Cart
        - [x] Shipping
          Standard, 3–5 days
        - [ ] pulse icon:credit-card Payment
        - [ ] Review
        >>>>>>
      MD

      expect(described_class.render_as_markdown(md)).to eq(
        "1. [x] Cart\n2. [x] Shipping\n   Standard, 3–5 days\n3. [ ] **Payment**\n4. [ ] Review"
      )
    end

    it 'bolds the last step when every step is complete' do
      expect(described_class.render_as_markdown(">>>>>>\n- [x] A\n- [x] B\n>>>>>>")).to eq("1. [x] A\n2. [x] **B**")
    end

    it 'bolds the explicitly active step and drops its flags' do
      expect(described_class.render_as_markdown(">>>>>>\n- A\n- active warning B\n>>>>>>"))
        .to eq("1. [ ] A\n2. [ ] **B**")
    end

    it 'indents descriptions to the marker width past nine steps' do
      steps = (1..10).map { |n| "- [x] S#{n}" }
      steps[-1] += "\n  Last one"
      result = described_class.render_as_markdown(">>>>>>\n#{steps.join("\n")}\n>>>>>>")
      expect(result).to end_with("10. [x] **S10**\n    Last one")
    end

    it 'degrades the alternative syntax identically' do
      primary = described_class.render_as_markdown(">>>>>>\n- [x] A\n- B\n>>>>>>")
      alternative = described_class.render_as_markdown(":::wa-stepper\n- [x] A\n- B\n:::")
      expect(alternative).to eq(primary)
    end
  end
end
