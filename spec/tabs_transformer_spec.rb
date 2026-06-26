# frozen_string_literal: true

RSpec.describe Markawesome::TabsTransformer do
  describe '.transform' do
    it 'transforms basic tab group' do
      markdown = "++++++\n+++ Tab 1\nContent 1\n+++\n+++ Tab 2\nContent 2\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-tab-group placement="top">')
      expect(result).to include('<wa-tab panel="tab-1">Tab 1</wa-tab>')
      expect(result).to include('<wa-tab panel="tab-2">Tab 2</wa-tab>')
      expect(result).to include('<wa-tab-panel name="tab-1"><p>Content 1</p>')
      expect(result).to include('<wa-tab-panel name="tab-2"><p>Content 2</p>')
      expect(result).to include('</wa-tab-group>')
    end

    it 'transforms tab group with start placement' do
      markdown = "++++++start\n+++ Tab 1\nContent 1\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-tab-group placement="start">')
    end

    it 'transforms tab group with bottom placement' do
      markdown = "++++++bottom\n+++ Tab 1\nContent 1\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-tab-group placement="bottom">')
    end

    it 'transforms tab group with end placement' do
      markdown = "++++++end\n+++ Tab 1\nContent 1\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-tab-group placement="end">')
    end

    it 'defaults to top placement when none specified' do
      markdown = "++++++\n+++ Tab 1\nContent 1\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-tab-group placement="top">')
    end

    it 'handles multiple tabs with complex content' do
      markdown = <<~MD
        ++++++
        +++ First Tab
        # Heading in tab
        Some content here.
        +++
        +++ Second Tab
        - List item 1
        - List item 2
        +++
        +++ Third Tab
        **Bold text** and *italic text*.
        +++
        ++++++
      MD

      result = described_class.transform(markdown)

      expect(result).to include('<wa-tab panel="tab-1">First Tab</wa-tab>')
      expect(result).to include('<wa-tab panel="tab-2">Second Tab</wa-tab>')
      expect(result).to include('<wa-tab panel="tab-3">Third Tab</wa-tab>')
      expect(result).to include('<h1 id="heading-in-tab">Heading in tab</h1>')
      expect(result).to include('<li>List item 1</li>')
      expect(result).to include('<strong>Bold text</strong>')
    end

    it 'does not transform incomplete tab syntax' do
      markdown = "++++++\n+++ Tab 1\nContent 1\n++++++"
      result = described_class.transform(markdown)

      expect(result).to eq(markdown)
    end

    it 'transforms tab group with activation manual' do
      markdown = "++++++manual\n+++ Tab 1\nContent 1\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-tab-group placement="top" activation="manual">')
    end

    it 'transforms tab group with activation auto' do
      markdown = "++++++auto\n+++ Tab 1\nContent 1\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-tab-group placement="top" activation="auto">')
    end

    it 'transforms tab group with active panel' do
      markdown = "++++++tab-2\n+++ Tab 1\nContent 1\n+++\n+++ Tab 2\nContent 2\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-tab-group placement="top" active="tab-2">')
    end

    it 'transforms tab group with no-scroll-controls' do
      markdown = "++++++no-scroll-controls\n+++ Tab 1\nContent 1\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('without-scroll-controls')
    end

    it 'transforms tab group with multiple attributes' do
      markdown = "++++++bottom manual tab-3 no-scroll-controls\n+++ Tab 1\nContent 1\n+++\n+++ Tab 2\nContent 2\n+++\n+++ Tab 3\nContent 3\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('<wa-tab-group placement="bottom" activation="manual" active="tab-3" without-scroll-controls>')
    end

    it 'transforms tab group with attributes in different order' do
      markdown = "++++++manual bottom\n+++ Tab 1\nContent 1\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('placement="bottom"')
      expect(result).to include('activation="manual"')
    end

    it 'uses rightmost wins for duplicate placement' do
      markdown = "++++++start end\n+++ Tab 1\nContent 1\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('placement="end"')
    end

    it 'uses rightmost wins for duplicate activation' do
      markdown = "++++++manual auto\n+++ Tab 1\nContent 1\n+++\n++++++"
      result = described_class.transform(markdown)

      expect(result).to include('activation="auto"')
    end

    context 'with a disabled tab' do
      it 'emits the disabled attribute and strips the leading flag from the label' do
        markdown = "++++++\n+++ disabled Coming soon\nNot yet available.\n+++\n++++++"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tab panel="tab-1" disabled>Coming soon</wa-tab>')
      end

      it 'leaves non-disabled sibling tabs unaffected' do
        markdown = "++++++\n+++ Tab 1\nContent 1\n+++\n+++ disabled Tab 2\nContent 2\n+++\n++++++"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tab panel="tab-1">Tab 1</wa-tab>')
        expect(result).to include('<wa-tab panel="tab-2" disabled>Tab 2</wa-tab>')
      end

      it 'only treats a leading disabled token as the flag, not a label that contains the word' do
        markdown = "++++++\n+++ Why this is disabled\nContent\n+++\n++++++"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tab panel="tab-1">Why this is disabled</wa-tab>')
      end

      it 'works with the alternative wa-tab-group syntax' do
        markdown = ":::wa-tab-group\n+++ disabled Coming soon\nNot yet available.\n+++\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tab panel="tab-1" disabled>Coming soon</wa-tab>')
      end
    end

    context 'with alternative syntax' do
      it 'transforms with wa-tab-group keyword' do
        markdown = ":::wa-tab-group\n+++ Tab 1\nContent 1\n+++\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tab-group placement="top">')
        expect(result).to include('<wa-tab panel="tab-1">Tab 1</wa-tab>')
      end

      it 'transforms with wa-tab-group and placement' do
        markdown = ":::wa-tab-group bottom\n+++ Tab 1\nContent 1\n+++\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('<wa-tab-group placement="bottom">')
      end

      it 'transforms with wa-tab-group and manual activation' do
        markdown = ":::wa-tab-group manual\n+++ Tab 1\nContent 1\n+++\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('activation="manual"')
      end

      it 'transforms with wa-tab-group and active panel' do
        markdown = ":::wa-tab-group tab-2\n+++ Tab 1\nContent 1\n+++\n+++ Tab 2\nContent 2\n+++\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('active="tab-2"')
      end

      it 'transforms with wa-tab-group and no-scroll-controls' do
        markdown = ":::wa-tab-group no-scroll-controls\n+++ Tab 1\nContent 1\n+++\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('without-scroll-controls')
      end

      it 'transforms with wa-tab-group and multiple attributes' do
        markdown = ":::wa-tab-group end manual advanced no-scroll-controls\n+++ Tab 1\nContent 1\n+++\n+++ Tab 2\nContent 2\n+++\n:::"
        result = described_class.transform(markdown)

        expect(result).to include('placement="end"')
        expect(result).to include('activation="manual"')
        expect(result).to include('active="advanced"')
        expect(result).to include('without-scroll-controls')
      end
    end
  end

  describe '.render_as_markdown' do
    it 'degrades tabs to headings' do
      markdown = "++++++\n+++ Tab 1\nContent 1\n+++\n+++ Tab 2\nContent 2\n+++\n++++++"
      result = described_class.render_as_markdown(markdown)

      expect(result).to include("### Tab 1\n\nContent 1")
      expect(result).to include("### Tab 2\n\nContent 2")
    end

    it 'strips a leading disabled flag from the degraded heading' do
      markdown = "++++++\n+++ Tab 1\nContent 1\n+++\n+++ disabled Coming soon\nNot yet available.\n+++\n++++++"
      result = described_class.render_as_markdown(markdown)

      expect(result).to include("### Tab 1\n\nContent 1")
      expect(result).to include("### Coming soon\n\nNot yet available.")
      expect(result).not_to include('disabled')
    end
  end
end
