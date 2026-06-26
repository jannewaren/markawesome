# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'

module Markawesome
  # Transforms tabs syntax into wa-tab-group elements
  # Primary syntax: ++++++[attributes]\n+++tab1\ncontent\n+++\n+++tab2\ncontent\n+++\n++++++
  # Alternative syntax: :::wa-tab-group [attributes]\n+++tab1\ncontent\n+++\n+++tab2\ncontent\n+++\n:::
  # Attributes:
  #   - placement: top (default), bottom, start, end
  #   - activation: auto (default), manual
  #   - active: panel name to show initially (e.g., "general", "tab-2")
  #   - no-scroll-controls: disables scroll arrows
  # Per-tab flag (leading token on the `+++ ` item header, mirroring accordion):
  #   - disabled: this tab renders but cannot be selected (e.g., "+++ disabled Coming soon")
  class TabsTransformer < BaseTransformer
    COMPONENT_ATTRIBUTES = {
      placement: %w[top bottom start end],
      activation: %w[auto manual]
    }.freeze
    def self.transform(content)
      # Define both regex patterns
      # Captures optional attributes (placement, activation, active, no-scroll-controls)
      primary_regex = /^\+{6}([^\n]*)\n((\+\+\+ [^\n]+\n.*?\n\+\+\+\n?)+)\+{6}/m
      alternative_regex = /^:::wa-tab-group\s*([^\n]*)\n((\+\+\+ [^\n]+\n.*?\n\+\+\+\n?)+):::/m

      # Define shared transformation logic
      transform_proc = proc do |params_string, tabs_block, _third_capture|
        # Parse attributes using AttributeParser
        attributes = AttributeParser.parse(params_string.to_s.strip, COMPONENT_ATTRIBUTES)

        # Extract boolean flags
        no_scroll_controls = params_string.to_s.include?('no-scroll-controls')

        # Extract active panel name (any token that's not a placement or activation)
        active_panel = nil
        params_string.to_s.split.each do |token|
          next if COMPONENT_ATTRIBUTES[:placement].include?(token)
          next if COMPONENT_ATTRIBUTES[:activation].include?(token)
          next if token == 'no-scroll-controls'

          active_panel = token
          break
        end

        tabs, tab_panels = extract_tabs_and_panels(tabs_block)

        # Build HTML attributes
        html_attrs = []
        html_attrs << "placement=\"#{attributes[:placement] || 'top'}\""
        html_attrs << "activation=\"#{attributes[:activation]}\"" if attributes[:activation]
        html_attrs << "active=\"#{active_panel}\"" if active_panel
        html_attrs << 'without-scroll-controls' if no_scroll_controls

        "<wa-tab-group #{html_attrs.join(' ')}>#{tabs.join}#{tab_panels.join}</wa-tab-group>"
      end

      # Apply both patterns
      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    def self.render_as_markdown(content, _options = {})
      primary_regex = /^\+{6}([^\n]*)\n((\+\+\+ [^\n]+\n.*?\n\+\+\+\n?)+)\+{6}/m
      alternative_regex = /^:::wa-tab-group\s*([^\n]*)\n((\+\+\+ [^\n]+\n.*?\n\+\+\+\n?)+):::/m

      transform_proc = proc do |_params_string, tabs_block, _third|
        tab_contents = tabs_block.scan(/^\+\+\+ ([^\n]+)\n(.*?)\n\+\+\+/m)
        tab_contents.map do |title, panel_content|
          label, = parse_tab_header(title)
          "### #{label}\n\n#{panel_content.strip}"
        end.join("\n\n")
      end

      patterns = dual_syntax_patterns(primary_regex, alternative_regex, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def extract_tabs_and_panels(tabs_block)
        # Extract individual tabs
        tab_contents = tabs_block.scan(/^\+\+\+ ([^\n]+)\n(.*?)\n\+\+\+/m)
        tabs = []
        tab_panels = []

        tab_contents.each_with_index do |(title, panel_content), index|
          tab_id = "tab-#{index + 1}"
          label, disabled = parse_tab_header(title)

          tab_attrs = ["panel=\"#{tab_id}\""]
          tab_attrs << 'disabled' if disabled
          tabs << "<wa-tab #{tab_attrs.join(' ')}>#{label}</wa-tab>"

          panel_html = markdown_to_html(panel_content.strip)
          tab_panels << "<wa-tab-panel name=\"#{tab_id}\">#{panel_html}</wa-tab-panel>"
        end

        [tabs, tab_panels]
      end

      # Parse a tab item header. A leading `disabled` token (case-sensitive,
      # exactly `disabled` or `disabled `-prefixed) flags the tab as disabled and
      # is stripped from the label; otherwise the label is the stripped title,
      # unchanged. Mirrors accordion's leading item flags.
      def parse_tab_header(title)
        stripped = title.to_s.strip
        return [stripped, false] unless stripped == 'disabled' || stripped.start_with?('disabled ')

        [stripped.sub(/\Adisabled\s*/, ''), true]
      end
    end
  end
end
