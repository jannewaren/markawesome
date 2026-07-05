# frozen_string_literal: true

require 'spec_helper'
require 'json'

# Guards the hand-curated enum lists our transformers accept against Web Awesome's
# machine-readable Custom Elements Manifest. The fixture is a distilled, vendored
# slice of WA's `custom-elements.json`, regenerated with `rake wa:manifest[X.Y.Z]`
# (never hand-edited). For each mapped (constant -> WA tag/attribute) it fails on:
#   DRIFT — a value we accept that WA no longer lists (alias-exempt), and
#   GAP   — a WA value we do not expose (unless intentionally omitted).
# Entries WA can't describe as an inline enum become a surfaced `skip`.
# See markawesome-js's test/webawesome-manifest-coverage.test.ts — same scope.

# The Web Awesome release these lists are curated against. Bump in lockstep with
# regenerating the fixture.
wa_version = '3.10.0'

fixture = JSON.parse(File.read(File.expand_path('fixtures/webawesome-enums.json', __dir__)))
all_tags = fixture.dig('_meta', 'allTags')

# WA enum values we knowingly do not expose, keyed 'wa-tag attr' => %w[values].
# Starts empty: a new WA value fails the build until we adopt it or record it
# here with a one-line reason.
intentionally_omitted = {}

# Each entry maps a live transformer constant to the WA (tag, attribute) it must
# track. `attr` is the WA attribute name, which can differ from our internal key
# (e.g. copy-button placement -> tooltip-placement). `accepted` is a lambda so the
# *live* constant is read — editing a transformer is seen here. `aliases` are
# input-only values WA does not list but we deliberately accept.
coverage = [
  { label: 'callout variant', tag: 'wa-callout', attr: 'variant',
    accepted: -> { Markawesome::CalloutTransformer::VARIANTS }, aliases: %w[info] },
  { label: 'callout size', tag: 'wa-callout', attr: 'size',
    accepted: -> { Markawesome::CalloutTransformer::CALLOUT_ATTRIBUTES[:size] } },
  { label: 'callout appearance', tag: 'wa-callout', attr: 'appearance',
    accepted: -> { Markawesome::CalloutTransformer::CALLOUT_ATTRIBUTES[:appearance] } },

  { label: 'badge variant', tag: 'wa-badge', attr: 'variant',
    accepted: -> { Markawesome::BadgeTransformer::BADGE_ATTRIBUTES[:variant] } },
  { label: 'badge appearance', tag: 'wa-badge', attr: 'appearance',
    accepted: -> { Markawesome::BadgeTransformer::BADGE_ATTRIBUTES[:appearance] } },
  { label: 'badge attention', tag: 'wa-badge', attr: 'attention',
    accepted: -> { Markawesome::BadgeTransformer::BADGE_ATTRIBUTES[:attention] } },

  { label: 'button variant', tag: 'wa-button', attr: 'variant',
    accepted: -> { Markawesome::ButtonTransformer::BUTTON_ATTRIBUTES[:variant] } },
  { label: 'button appearance', tag: 'wa-button', attr: 'appearance',
    accepted: -> { Markawesome::ButtonTransformer::BUTTON_ATTRIBUTES[:appearance] } },
  { label: 'button size', tag: 'wa-button', attr: 'size',
    accepted: -> { Markawesome::ButtonTransformer::BUTTON_ATTRIBUTES[:size] } },
  { label: 'button target', tag: 'wa-button', attr: 'target',
    accepted: -> { Markawesome::ButtonTransformer::BUTTON_ATTRIBUTES[:target] } },

  { label: 'tag variant', tag: 'wa-tag', attr: 'variant',
    accepted: -> { Markawesome::TagTransformer::COMPONENT_ATTRIBUTES[:variant] } },
  { label: 'tag appearance', tag: 'wa-tag', attr: 'appearance',
    accepted: -> { Markawesome::TagTransformer::COMPONENT_ATTRIBUTES[:appearance] } },
  { label: 'tag size', tag: 'wa-tag', attr: 'size',
    accepted: -> { Markawesome::TagTransformer::COMPONENT_ATTRIBUTES[:size] } },

  { label: 'card appearance', tag: 'wa-card', attr: 'appearance',
    accepted: -> { Markawesome::CardTransformer::CARD_ATTRIBUTES[:appearance] } },
  { label: 'card orientation', tag: 'wa-card', attr: 'orientation',
    accepted: -> { Markawesome::CardTransformer::CARD_ATTRIBUTES[:orientation] } },

  { label: 'accordion appearance', tag: 'wa-accordion', attr: 'appearance',
    accepted: -> { Markawesome::AccordionTransformer::CONTAINER_ATTRIBUTES[:appearance] } },
  { label: 'accordion mode', tag: 'wa-accordion', attr: 'mode',
    accepted: -> { Markawesome::AccordionTransformer::CONTAINER_ATTRIBUTES[:mode] } },
  { label: 'accordion icon-placement', tag: 'wa-accordion', attr: 'icon-placement',
    accepted: -> { Markawesome::AccordionTransformer::CONTAINER_ATTRIBUTES[:icon_placement] } },

  { label: 'details appearance', tag: 'wa-details', attr: 'appearance',
    accepted: -> { Markawesome::DetailsTransformer::COMPONENT_ATTRIBUTES[:appearance] } },
  { label: 'details icon-placement', tag: 'wa-details', attr: 'icon-placement',
    accepted: -> { Markawesome::DetailsTransformer::COMPONENT_ATTRIBUTES[:icon_placement] } },

  { label: 'tabs placement', tag: 'wa-tab-group', attr: 'placement',
    accepted: -> { Markawesome::TabsTransformer::COMPONENT_ATTRIBUTES[:placement] } },
  { label: 'tabs activation', tag: 'wa-tab-group', attr: 'activation',
    accepted: -> { Markawesome::TabsTransformer::COMPONENT_ATTRIBUTES[:activation] } },

  { label: 'popover placement', tag: 'wa-popover', attr: 'placement',
    accepted: -> { Markawesome::PopoverTransformer::POPOVER_ATTRIBUTES[:placement] } },

  { label: 'tooltip placement', tag: 'wa-tooltip', attr: 'placement',
    accepted: -> { Markawesome::TooltipTransformer::TOOLTIP_ATTRIBUTES[:placement] } },

  { label: 'copy-button placement', tag: 'wa-copy-button', attr: 'tooltip-placement',
    accepted: -> { Markawesome::CopyButtonTransformer::COPY_BUTTON_ATTRIBUTES[:placement] } },

  { label: 'random-content mode', tag: 'wa-random-content', attr: 'mode',
    accepted: -> { Markawesome::RandomContentTransformer::COMPONENT_ATTRIBUTES[:mode] } },
  { label: 'random-content animation', tag: 'wa-random-content', attr: 'animation',
    accepted: -> { Markawesome::RandomContentTransformer::COMPONENT_ATTRIBUTES[:animation] } },

  { label: 'relative-time format', tag: 'wa-relative-time', attr: 'format',
    accepted: -> { Markawesome::DateTransformer::RELATIVE_FORMATS } },
  { label: 'relative-time numeric', tag: 'wa-relative-time', attr: 'numeric',
    accepted: -> { Markawesome::DateTransformer::RELATIVE_NUMERICS } },

  { label: 'format-date weekday', tag: 'wa-format-date', attr: 'weekday',
    accepted: -> { Markawesome::DateTransformer::GRANULAR_ENUMS['weekday'] } },
  { label: 'format-date era', tag: 'wa-format-date', attr: 'era',
    accepted: -> { Markawesome::DateTransformer::GRANULAR_ENUMS['era'] } },
  { label: 'format-date year', tag: 'wa-format-date', attr: 'year',
    accepted: -> { Markawesome::DateTransformer::GRANULAR_ENUMS['year'] } },
  { label: 'format-date month', tag: 'wa-format-date', attr: 'month',
    accepted: -> { Markawesome::DateTransformer::GRANULAR_ENUMS['month'] } },
  { label: 'format-date day', tag: 'wa-format-date', attr: 'day',
    accepted: -> { Markawesome::DateTransformer::GRANULAR_ENUMS['day'] } },
  { label: 'format-date hour', tag: 'wa-format-date', attr: 'hour',
    accepted: -> { Markawesome::DateTransformer::GRANULAR_ENUMS['hour'] } },
  { label: 'format-date minute', tag: 'wa-format-date', attr: 'minute',
    accepted: -> { Markawesome::DateTransformer::GRANULAR_ENUMS['minute'] } },
  { label: 'format-date second', tag: 'wa-format-date', attr: 'second',
    accepted: -> { Markawesome::DateTransformer::GRANULAR_ENUMS['second'] } },
  { label: 'format-date hour-format', tag: 'wa-format-date', attr: 'hour-format',
    accepted: -> { Markawesome::DateTransformer::GRANULAR_ENUMS['hour-format'] } },
  { label: 'format-date time-zone-name', tag: 'wa-format-date', attr: 'time-zone-name',
    accepted: -> { Markawesome::DateTransformer::GRANULAR_ENUMS['time-zone-name'] } },

  # Skipped: WA declares these as freeform strings / opaque named types, not
  # inline enums, so the CEM can't check our richer hand-curated lists.
  { label: 'icon family', tag: 'wa-icon', attr: 'family',
    accepted: -> { Markawesome::IconAttributes::SCHEMA[:family] } },
  { label: 'icon variant', tag: 'wa-icon', attr: 'variant',
    accepted: -> { Markawesome::IconAttributes::SCHEMA[:variant] } },
  { label: 'icon animation', tag: 'wa-icon', attr: 'animation',
    accepted: -> { Markawesome::IconAttributes::SCHEMA[:animation] } },
  { label: 'icon canvas', tag: 'wa-icon', attr: 'canvas',
    accepted: -> { Markawesome::IconAttributes::SCHEMA[:canvas] } },

  # Skipped: wa-video is absent from WA core's manifest, so its enums can't be
  # checked here (lists manually verified).
  { label: 'video controls', tag: 'wa-video', attr: 'controls',
    accepted: -> { Markawesome::VideoTransformer::CONTROLS_VALUES } },
  { label: 'video preload', tag: 'wa-video', attr: 'preload',
    accepted: -> { Markawesome::VideoTransformer::PRELOAD_VALUES } }
]

RSpec.describe 'Web Awesome manifest coverage' do
  it 'pins the fixture to the expected Web Awesome version' do
    expect(fixture.dig('_meta', 'webAwesomeVersion')).to eq(wa_version)
  end

  coverage.each do |entry|
    it "keeps #{entry[:label]} in sync with #{entry[:tag]} #{entry[:attr]}" do
      skip "#{entry[:tag]} is not in the WA #{wa_version} core manifest — list manually verified" unless all_tags.include?(entry[:tag])

      wa_enum = fixture.dig(entry[:tag], entry[:attr])
      skip "#{entry[:tag]} #{entry[:attr]} is not an inline enum in WA #{wa_version} — list manually verified" if wa_enum.nil?

      accepted = entry[:accepted].call
      aliases = entry[:aliases] || []
      omitted = intentionally_omitted["#{entry[:tag]} #{entry[:attr]}"] || []

      drift = accepted - wa_enum - aliases
      gap = wa_enum - accepted - omitted

      expect(drift).to be_empty,
                       "DRIFT: #{entry[:label]} accepts #{drift.inspect}, absent from WA #{entry[:tag]} #{entry[:attr]}"
      expect(gap).to be_empty,
                     "GAP: WA #{entry[:tag]} #{entry[:attr]} lists #{gap.inspect}, not exposed by #{entry[:label]}"
    end
  end
end
