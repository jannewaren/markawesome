# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome::DateTransformer do
  describe '.transform' do
    context 'with the inline [[[ ]]] form (format-date)' do
      it 'defaults a bare date to style:long' do
        result = described_class.transform('[[[2026-06-26]]]')

        expect(result).to eq(
          '<wa-format-date date="2026-06-26" year="numeric" month="long" ' \
          'day="numeric"></wa-format-date>'
        )
      end

      it 'expands the style:short preset' do
        result = described_class.transform('[[[2026-06-26 style:short]]]')

        expect(result).to eq(
          '<wa-format-date date="2026-06-26" year="2-digit" month="numeric" ' \
          'day="numeric"></wa-format-date>'
        )
      end

      it 'expands the style:medium preset' do
        result = described_class.transform('[[[2026-06-26 style:medium]]]')

        expect(result).to include('year="numeric" month="short" day="numeric"')
      end

      it 'expands the style:full preset with a weekday' do
        result = described_class.transform('[[[2026-06-26 style:full]]]')

        expect(result).to eq(
          '<wa-format-date date="2026-06-26" weekday="long" year="numeric" ' \
          'month="long" day="numeric"></wa-format-date>'
        )
      end

      it 'expands time:short to hour/minute only (no date fields)' do
        result = described_class.transform('[[[2026-06-26T14:30:00Z time:short]]]')

        expect(result).to eq(
          '<wa-format-date date="2026-06-26T14:30:00Z" hour="numeric" ' \
          'minute="numeric"></wa-format-date>'
        )
      end

      it 'expands time:long to add a short time-zone name' do
        result = described_class.transform('[[[2026-06-26T14:30:00Z time:long]]]')

        expect(result).to include('hour="numeric" minute="numeric" second="numeric" ' \
                                  'time-zone-name="short"')
      end

      it 'combines style and time presets plus hour-format' do
        result = described_class.transform(
          '[[[2026-06-26T14:30:00Z style:medium time:short hour-format:24]]]'
        )

        expect(result).to eq(
          '<wa-format-date date="2026-06-26T14:30:00Z" year="numeric" month="short" ' \
          'day="numeric" hour="numeric" minute="numeric" hour-format="24"></wa-format-date>'
        )
      end

      it 'lets a granular token override a preset (rightmost-wins per key)' do
        result = described_class.transform('[[[2026-06-26 style:long month:short]]]')

        expect(result).to eq(
          '<wa-format-date date="2026-06-26" year="numeric" month="short" ' \
          'day="numeric"></wa-format-date>'
        )
      end

      it 'accepts a datetime token with a timezone offset' do
        result = described_class.transform('[[[2026-06-26T14:30:00+02:00 style:full]]]')

        expect(result).to include('date="2026-06-26T14:30:00+02:00"')
      end

      it 'emits a runtime-now component when no date token is present' do
        result = described_class.transform('[[[style:long]]]')

        expect(result).to eq(
          '<wa-format-date year="numeric" month="long" day="numeric"></wa-format-date>'
        )
        expect(result).not_to include('date=')
      end
    end

    context 'with the inline relative flag' do
      it 'switches to <wa-relative-time>' do
        result = described_class.transform('[[[relative 2026-06-20]]]')

        expect(result).to eq('<wa-relative-time date="2026-06-20"></wa-relative-time>')
      end

      it 'emits non-default format and numeric values' do
        result = described_class.transform('[[[relative 2026-06-20 format:short numeric:always]]]')

        expect(result).to eq(
          '<wa-relative-time date="2026-06-20" format="short" ' \
          'numeric="always"></wa-relative-time>'
        )
      end

      it 'omits the default format:long and numeric:auto values' do
        result = described_class.transform('[[[relative 2026-06-20 format:long numeric:auto]]]')

        expect(result).to eq('<wa-relative-time date="2026-06-20"></wa-relative-time>')
      end

      it 'emits the sync boolean flag' do
        result = described_class.transform('[[[relative 2026-06-20 sync]]]')

        expect(result).to eq('<wa-relative-time date="2026-06-20" sync></wa-relative-time>')
      end

      it 'ignores date/style tokens in relative mode' do
        result = described_class.transform('[[[relative 2026-06-20 style:full month:short]]]')

        expect(result).to eq('<wa-relative-time date="2026-06-20"></wa-relative-time>')
      end
    end

    context 'with lang/locale aliasing' do
      it 'maps lang: to the lang attribute' do
        result = described_class.transform('[[[2026-06-26 style:long lang:fr]]]')

        expect(result).to include('lang="fr"')
      end

      it 'maps locale: to the lang attribute (alias)' do
        result = described_class.transform('[[[2026-06-26 locale:fr-CA]]]')

        expect(result).to include('lang="fr-CA"')
      end

      it 'maps lang: on a relative-time too' do
        result = described_class.transform('[[[relative 2026-06-20 lang:de]]]')

        expect(result).to eq('<wa-relative-time date="2026-06-20" lang="de"></wa-relative-time>')
      end
    end

    context 'with the time-zone free-string token' do
      it 'passes a time-zone value through (escaped)' do
        result = described_class.transform('[[[2026-06-26T14:30:00Z time:short time-zone:America/New_York]]]')

        expect(result).to include('time-zone="America/New_York"')
      end
    end

    context 'with multiple timestamps on one line' do
      it 'transforms each independently' do
        result = described_class.transform('A [[[2026-01-01]]] and B [[[2026-12-31]]].')

        expect(result.scan('<wa-format-date').length).to eq(2)
        expect(result).to include('date="2026-01-01"')
        expect(result).to include('date="2026-12-31"')
      end
    end

    context 'with the block :::wa-format-date / :::wa-relative-time forms' do
      it 'transforms a format-date block (mode from the selector)' do
        result = described_class.transform(":::wa-format-date 2026-06-26 style:full lang:fr\n:::")

        expect(result).to eq(
          '<wa-format-date date="2026-06-26" weekday="long" year="numeric" ' \
          'month="long" day="numeric" lang="fr"></wa-format-date>'
        )
      end

      it 'transforms a relative-time block (mode from the selector)' do
        result = described_class.transform(":::wa-relative-time 2026-06-20 sync\n:::")

        expect(result).to eq('<wa-relative-time date="2026-06-20" sync></wa-relative-time>')
      end

      it 'defaults an empty format-date block to a runtime-now long date' do
        result = described_class.transform(":::wa-format-date\n:::")

        expect(result).to eq(
          '<wa-format-date year="numeric" month="long" day="numeric"></wa-format-date>'
        )
      end
    end

    context 'with invalid or unknown tokens' do
      it 'drops invalid preset/enum/unknown tokens and falls back to style:long' do
        result = described_class.transform('[[[2026-06-26 style:bogus month:huge color:red]]]')

        expect(result).to eq(
          '<wa-format-date date="2026-06-26" year="numeric" month="long" ' \
          'day="numeric"></wa-format-date>'
        )
      end

      it 'drops an invalid relative format value' do
        result = described_class.transform('[[[relative 2026-06-20 format:bogus]]]')

        expect(result).to eq('<wa-relative-time date="2026-06-20"></wa-relative-time>')
      end
    end

    context 'with content that is not a timestamp' do
      it 'leaves a non-date bracket span untouched when no date and no tokens map' do
        result = described_class.transform('[[[just some words]]]')

        # No date, no recognized formatting token -> runtime-now long date.
        expect(result).to eq(
          '<wa-format-date year="numeric" month="long" day="numeric"></wa-format-date>'
        )
      end

      it 'does not match across newlines' do
        input = "[[[2026-06-26\nstyle:long]]]"
        result = described_class.transform(input)

        expect(result).to eq(input)
      end
    end
  end

  describe '.render_as_markdown' do
    it 'degrades an inline format-date to its raw date string' do
      result = described_class.render_as_markdown('Published [[[2026-06-26 style:long]]].')

      expect(result).to eq('Published 2026-06-26.')
    end

    it 'degrades an inline relative-time to its raw date string' do
      result = described_class.render_as_markdown('Updated [[[relative 2026-06-20 sync]]].')

      expect(result).to eq('Updated 2026-06-20.')
    end

    it 'degrades a block form to its raw date string' do
      result = described_class.render_as_markdown(":::wa-format-date 2026-06-26 style:full\n:::")

      expect(result).to eq('2026-06-26')
    end

    it 'degrades a runtime-now timestamp to an empty string' do
      result = described_class.render_as_markdown('[[[style:long]]]')

      expect(result).to eq('')
    end
  end
end
