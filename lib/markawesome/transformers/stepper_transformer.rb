# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../attribute_parser'
require_relative '../icon_slot_parser'

module Markawesome
  # Transforms stepper syntax into a display-only <wa-stepper> / <wa-step>
  # progress indicator, written as a Markdown task list.
  #
  # Primary syntax:
  #   >>>>>> vertical label:"Checkout progress"
  #   - [x] Cart
  #   - [x] Shipping
  #     Standard, 3–5 days
  #   - [ ] pulse icon:credit-card Payment
  #   - [ ] Review
  #   >>>>>>
  # Alternative syntax: :::wa-stepper params? ...same list... :::
  #
  # Container params:
  #   - horizontal, vertical, auto -> orientation
  #   - label:"text"               -> label (accessible name)
  # Steps are unindented list lines (`-`, `*` or `+`):
  #   - [x] / [X] marks the step completed; [ ] or no box means not completed
  #   - leading flags: active, loading, disabled, a variant (neutral, brand,
  #     success, warning, danger), an attention (none, pulse, bounce), and
  #     icon:name (slotted into the step's icon slot)
  #   - the rest of the line is the label, rendered as inline Markdown
  #   - lines indented by two or more spaces under a step are joined into its
  #     description slot, rendered as inline Markdown
  #
  # Steps are named step-1..N and the container's `active` points at the step
  # flagged `active` (last one wins), else the first incomplete step, else the
  # last step. Interactivity (`clickable`, `linear`, step invokers) is omitted
  # on purpose: these steps have no content panels, so there is nothing to
  # navigate between without app JavaScript.
  class StepperTransformer < BaseTransformer
    STEPPER_ATTRIBUTES = {
      orientation: %w[horizontal vertical auto]
    }.freeze

    STEP_ATTRIBUTES = {
      variant: %w[neutral brand success warning danger],
      attention: %w[none pulse bounce]
    }.freeze

    STEP_FLAGS = %w[active loading disabled].freeze

    ICON_SLOTS = {
      default: 'icon',
      slots: %w[icon],
      slot_map: { 'icon' => 'icon' }
    }.freeze

    PRIMARY_REGEX = /^>{6}([^\n]*)\n(.*?)\n>{6}[ \t]*$/m
    ALTERNATIVE_REGEX = /^:::wa-stepper[ \t]*([^\n]*)\n(.*?)\n:::[ \t]*$/m
    LABEL_REGEX = /label:(?:"([^"]*)"|'([^']*)')/
    STEP_LINE_REGEX = /\A[-*+][ \t]+(.*)\z/
    CONTINUATION_REGEX = /\A[ \t]{2,}(\S.*)\z/
    CHECKBOX_REGEX = /\A\[([ xX])\](?:[ \t]+(.*))?\z/

    def self.transform(content)
      transform_proc = proc do |params_string, body|
        label, params_string = extract_label(params_string.to_s)
        attributes = AttributeParser.parse(params_string, STEPPER_ATTRIBUTES)
        steps = parse_steps(body)
        active = active_index(steps)

        attr_parts = []
        attr_parts << "orientation=\"#{attributes[:orientation]}\"" if attributes[:orientation]
        attr_parts << "label=\"#{escape_html(label)}\"" unless label.empty?
        attr_parts << "active=\"step-#{active + 1}\"" if active
        attrs_string = attr_parts.empty? ? '' : " #{attr_parts.join(' ')}"

        steps_html = steps.each_with_index.map { |step, index| build_step(step, index) }.join
        "<wa-stepper#{attrs_string}>#{steps_html}</wa-stepper>"
      end

      patterns = dual_syntax_patterns(PRIMARY_REGEX, ALTERNATIVE_REGEX, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    # Degrade to an ordered task list: completed steps keep [x], the current
    # step is bold, and a description becomes an indented continuation line.
    def self.render_as_markdown(content, _options = {})
      transform_proc = proc do |_params_string, body|
        steps = parse_steps(body)
        active = active_index(steps)

        steps.each_with_index.map do |step, index|
          marker = "#{index + 1}. "
          label = index == active && !step[:label].empty? ? "**#{step[:label]}**" : step[:label]
          line = "#{marker}[#{step[:completed] ? 'x' : ' '}]"
          line += " #{label}" unless label.empty?
          line += "\n#{' ' * marker.length}#{step[:description]}" unless step[:description].empty?
          line
        end.join("\n")
      end

      patterns = dual_syntax_patterns(PRIMARY_REGEX, ALTERNATIVE_REGEX, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      # Pull out label:"…" (or label:'…') before the bare tokens are parsed, so
      # words inside the label can't be read as orientation tokens.
      def extract_label(params_string)
        match = LABEL_REGEX.match(params_string)
        return ['', params_string] unless match

        [(match[1] || match[2]).strip, params_string.sub(LABEL_REGEX, ' ')]
      end

      def parse_steps(body)
        steps = []
        body.to_s.each_line do |line|
          line = line.chomp
          if (match = STEP_LINE_REGEX.match(line))
            steps << parse_step(match[1])
          elsif (match = CONTINUATION_REGEX.match(line)) && steps.any?
            steps.last[:description_lines] << match[1].strip
          end
        end
        steps.each { |step| step[:description] = step.delete(:description_lines).join(' ') }
      end

      def parse_step(raw)
        completed = false
        if (match = CHECKBOX_REGEX.match(raw.strip))
          completed = match[1] != ' '
          raw = match[2].to_s
        end

        tokens = raw.strip.split(/\s+/)
        lead = []
        lead << tokens.shift while tokens.any? && leading_token?(tokens.first)
        lead_string = lead.join(' ')

        {
          completed: completed,
          flags: lead & STEP_FLAGS,
          attributes: AttributeParser.parse(lead_string, STEP_ATTRIBUTES),
          icons: IconSlotParser.parse(lead_string, ICON_SLOTS)[:icons],
          label: tokens.join(' '),
          description_lines: []
        }
      end

      def leading_token?(token)
        token.start_with?('icon:') ||
          STEP_FLAGS.include?(token) ||
          STEP_ATTRIBUTES.values.any? { |values| values.include?(token) }
      end

      # The explicitly active step (last wins), else the first incomplete one,
      # else the last step; nil when there are no steps.
      def active_index(steps)
        return nil if steps.empty?

        explicit = steps.rindex { |step| step[:flags].include?('active') }
        return explicit if explicit

        steps.index { |step| !step[:completed] } || (steps.length - 1)
      end

      def build_step(step, index)
        attr_parts = ["name=\"step-#{index + 1}\""]
        attr_parts << 'completed' if step[:completed]
        attr_parts << 'loading' if step[:flags].include?('loading')
        attr_parts << 'disabled' if step[:flags].include?('disabled')
        attr_parts << "variant=\"#{step[:attributes][:variant]}\"" if step[:attributes][:variant]
        attr_parts << "attention=\"#{step[:attributes][:attention]}\"" if step[:attributes][:attention]

        icon_html = IconSlotParser.to_html(step[:icons], ICON_SLOTS[:slot_map])
        description = render_inline(step[:description])
        description_html = description.empty? ? '' : "<span slot=\"description\">#{description}</span>"

        "<wa-step #{attr_parts.join(' ')}>#{icon_html}#{render_inline(step[:label])}#{description_html}</wa-step>"
      end

      # Inline Markdown: render, then drop the wrapping <p> (the badge idiom).
      def render_inline(text)
        return '' if text.empty?

        markdown_to_html(text).strip.sub(%r{\A<p>(.*)</p>\z}m, '\1')
      end

      def escape_html(text)
        text.to_s
            .gsub('&', '&amp;')
            .gsub('<', '&lt;')
            .gsub('>', '&gt;')
            .gsub('"', '&quot;')
            .gsub("'", '&#39;')
      end
    end
  end
end
