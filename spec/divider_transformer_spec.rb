# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::DividerTransformer do
  describe '.transform' do
    it 'transforms a centered label (exact)' do
      expect(described_class.transform('--- or ---')).to eq('<wa-divider>or</wa-divider>')
    end

    it 'maps start/center/end to label-placement' do
      expect(described_class.transform('--- start Release notes ---'))
        .to eq('<wa-divider label-placement="start">Release notes</wa-divider>')
      expect(described_class.transform('--- center Mid ---'))
        .to eq('<wa-divider label-placement="center">Mid</wa-divider>')
      expect(described_class.transform('--- end Fin ---'))
        .to eq('<wa-divider label-placement="end">Fin</wa-divider>')
    end

    it 'puts an icon before the label, separated by a space' do
      expect(described_class.transform('--- end icon:star New ---'))
        .to eq('<wa-divider label-placement="end"><wa-icon name="star"></wa-icon> New</wa-divider>')
    end

    it 'supports an icon-only label' do
      expect(described_class.transform('--- icon:quote-left ---'))
        .to eq('<wa-divider><wa-icon name="quote-left"></wa-icon></wa-divider>')
    end

    it 'maps vertical/horizontal to orientation, emitted before label-placement' do
      expect(described_class.transform('--- vertical vs ---'))
        .to eq('<wa-divider orientation="vertical">vs</wa-divider>')
      expect(described_class.transform('--- start horizontal Notes ---'))
        .to eq('<wa-divider orientation="horizontal" label-placement="start">Notes</wa-divider>')
    end

    it 'uses rightmost-wins among the leading tokens' do
      expect(described_class.transform('--- start end icon:a icon:b X ---'))
        .to eq('<wa-divider label-placement="end"><wa-icon name="b"></wa-icon> X</wa-divider>')
    end

    it 'only consumes tokens at the start of the label' do
      expect(described_class.transform('--- Read from start to end ---'))
        .to eq('<wa-divider>Read from start to end</wa-divider>')
    end

    it 'renders the label as inline Markdown and escapes text' do
      expect(described_class.transform('--- **Bold** & `code` ---'))
        .to eq('<wa-divider><strong>Bold</strong> &amp; <code>code</code></wa-divider>')
    end

    it 'transforms a divider in the middle of a document' do
      result = described_class.transform("Before\n\n--- or ---\n\nAfter")
      expect(result).to eq("Before\n\n<wa-divider>or</wa-divider>\n\nAfter")
    end

    it 'tolerates trailing whitespace after the closing dashes' do
      expect(described_class.transform("--- or ---  \nNext")).to eq("<wa-divider>or</wa-divider>\nNext")
    end

    context 'when the line is not a labeled divider' do
      ['---', '--- ---', '---  ---', '--- | ---', '--- | :---: | ---:', '---- x ----', '--- x', 'x --- y ---',
       '  --- indented ---'].each do |input|
        it "leaves #{input.inspect} untouched" do
          expect(described_class.transform(input)).to eq(input)
        end
      end
    end

    context 'with the alternative syntax' do
      it 'uses the body as the label (exact)' do
        markdown = ":::wa-divider start icon:star\nRelease **notes**\n:::"
        expect(described_class.transform(markdown))
          .to eq('<wa-divider label-placement="start"><wa-icon name="star"></wa-icon> Release <strong>notes</strong></wa-divider>')
      end

      it 'lets a label start with a reserved word' do
        expect(described_class.transform(":::wa-divider\nstart here\n:::"))
          .to eq('<wa-divider>start here</wa-divider>')
      end

      it 'emits a bare divider for an empty body' do
        expect(described_class.transform(":::wa-divider vertical\n:::"))
          .to eq('<wa-divider orientation="vertical"></wa-divider>')
      end

      it 'drops unknown tokens' do
        expect(described_class.transform(":::wa-divider bogus end\nX\n:::"))
          .to eq('<wa-divider label-placement="end">X</wa-divider>')
      end

      it 'does not close on a ::: that starts another component' do
        markdown = ":::wa-divider\n:::info\nBody\n:::"
        expect(described_class.transform(markdown)).to start_with('<wa-divider>:::info')
      end
    end
  end
end
