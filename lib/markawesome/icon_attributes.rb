# frozen_string_literal: true

module Markawesome
  # Shared <wa-icon> attribute vocabulary (family/variant/animation/canvas) and emission helper.
  # Values verified against Web Awesome 3.10.0. Adding a value later is a one-line change.
  module IconAttributes
    SCHEMA = {
      family: %w[
        classic sharp duotone sharp-duotone brands
        mosaic pixel vellum slab-duo slab-press-duo chisel etch graphite
        jelly jelly-duo jelly-fill notdog notdog-duo slab slab-press
        thumbprint utility utility-duo utility-fill whiteboard
      ],
      variant: %w[thin light regular solid semibold],
      animation: %w[
        beat fade beat-fade bounce flip shake spin spin-pulse spin-reverse
        flip-360 spin-snap spin-snap-4 spin-snap-8 buzz float jello swing wag
      ],
      canvas: %w[fixed auto square roomy]
    }.freeze

    # Returns ordered ['family="…"', 'variant="…"', 'animation="…"', 'canvas="…"'] for present
    # keys. Emission order is fixed (canvas last) for byte-for-byte parity with markawesome-js.
    def self.pairs(attributes)
      %i[family variant animation canvas].filter_map do |key|
        "#{key}=\"#{attributes[key]}\"" if attributes[key]
      end
    end
  end
end
