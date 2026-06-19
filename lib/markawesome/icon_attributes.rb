# frozen_string_literal: true

module Markawesome
  # Shared <wa-icon> attribute vocabulary (family/variant/animation) and emission helper.
  # Values verified against Web Awesome 3.x. Adding a value later is a one-line change.
  module IconAttributes
    SCHEMA = {
      family: %w[classic sharp duotone sharp-duotone brands],
      variant: %w[thin light regular solid],
      animation: %w[beat fade beat-fade bounce flip shake spin spin-pulse spin-reverse]
    }.freeze

    # Returns ordered ['family="…"', 'variant="…"', 'animation="…"'] for present keys.
    def self.pairs(attributes)
      %i[family variant animation].filter_map do |key|
        "#{key}=\"#{attributes[key]}\"" if attributes[key]
      end
    end
  end
end
