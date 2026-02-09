# frozen_string_literal: true

module Markawesome
  # Parses icon:... tokens from parameter strings for Web Awesome component icon slots
  # Supports default slot mapping, explicit slot names, and slot name remapping
  #
  # Examples:
  #   "icon:gear"           → default slot gets "gear"
  #   "icon:end:arrow-right" → "end" slot gets "arrow-right"
  #   "success icon:gear large" → icons: { 'start' => 'gear' }, remaining: "success large"
  class IconSlotParser
    # Parse icon tokens from a parameter string
    # @param params_string [String] Space-separated parameter string potentially containing icon:... tokens
    # @param slot_config [Hash] Configuration for icon slots
    #   :default [String, nil] Default slot name for icon:name tokens (nil = no default)
    #   :slots [Array<String>] Allowed slot names
    #   :slot_map [Hash] Optional mapping from short slot names to HTML slot attributes
    # @return [Hash] { icons: Hash, remaining: String }
    def self.parse(params_string, slot_config)
      return { icons: {}, remaining: '' } if params_string.nil? || params_string.strip.empty?

      icons = {}
      remaining_tokens = []
      tokens = params_string.strip.split(/\s+/)

      tokens.each do |token|
        if token.start_with?('icon:')
          parts = token.split(':', 3) # ["icon", slot_or_name, maybe_name]

          if parts.length == 3
            # Explicit slot: icon:slot:name
            slot = parts[1]
            name = parts[2]
            icons[slot] = name if slot_config[:slots]&.include?(slot)
          elsif parts.length == 2 && slot_config[:default]
            # Default slot: icon:name
            name = parts[1]
            icons[slot_config[:default]] = name unless name.empty?
          end
        else
          remaining_tokens << token
        end
      end

      { icons: icons, remaining: remaining_tokens.join(' ') }
    end

    # Generate <wa-icon> HTML elements for parsed icons
    # @param icons_hash [Hash] Slot name => icon name pairs
    # @param slot_map [Hash, nil] Optional mapping from parsed slot names to HTML slot attributes
    # @return [String] HTML string with <wa-icon> elements
    def self.to_html(icons_hash, slot_map = nil)
      icons_hash.map do |slot, name|
        html_slot = slot_map ? (slot_map[slot] || slot) : slot
        if html_slot == 'content'
          "<wa-icon name=\"#{name}\"></wa-icon>"
        else
          "<wa-icon slot=\"#{html_slot}\" name=\"#{name}\"></wa-icon>"
        end
      end.join
    end
  end
end
