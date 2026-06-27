# frozen_string_literal: true

require_relative 'base_transformer'
require_relative '../icon_slot_parser'

module Markawesome
  # Transforms tree syntax into wa-tree / wa-tree-item elements from a nested
  # Markdown bullet list.
  # Primary syntax:
  #   ||||||open?
  #   - icon:folder? expanded? Label
  #     - child label
  #   ||||||
  # Alternative syntax: :::wa-tree open? ...same list... :::
  #
  # Web Awesome's tree is fundamentally a *selection* control, which is
  # interactive (needs JS). On a static site we deliberately emit a
  # display/navigation-only tree: visual hierarchy via nesting, initial expand
  # state, and leading folder/file icons — all declarative and static-safe. We
  # skip selection, lazy, selected, and selection events entirely.
  #
  # Fence token:
  #   - open (alias expanded) -> mark every branch (node with children) expanded
  # Per-node leading tokens (stripped from the label):
  #   - expanded -> force this one branch open
  #   - icon:name -> leading content <wa-icon name="name"> on the item
  # The remaining text is the (plain-text, HTML-escaped) label.
  #
  # expanded is emitted only on nodes that HAVE children AND (fence open OR the
  # node's own expanded flag); leaves never get expanded.
  #
  # WA runtime caveat (verified against the WA 3.9.0 kit): <wa-tree-item> only
  # honors a static `expanded` on items that are VISIBLE at load, so in practice
  # `open` expands the TOP-LEVEL branches and deeper branches stay collapsed
  # until their parent is opened (WA strips `expanded` from nested items at
  # init). We still emit `expanded` on every branch on purpose: it's harmless
  # (WA ignores the nested ones), records authorial intent, and is
  # forward-compatible if WA ever honors nested initial-expand.
  class TreeTransformer < BaseTransformer
    # Content slot: emits <wa-icon name="..."> with no slot attribute.
    ICON_SLOTS = {
      default: 'content',
      slots: %w[content],
      slot_map: { 'content' => 'content' }
    }.freeze

    ITEM_FLAGS = %w[expanded].freeze
    FENCE_TOKENS = %w[open expanded].freeze
    TAB_WIDTH = 4

    PRIMARY_REGEX = /^\|{6}[ \t]*([^\n]*)\n(.*?)\n\|{6}/m
    ALTERNATIVE_REGEX = /^:::wa-tree[ \t]*([^\n]*)\n(.*?)\n:::/m
    LIST_LINE_REGEX = /^(\s*)[-*+]\s+(.*)$/

    def self.transform(content)
      transform_proc = proc do |params_string, body, _third|
        fence_open = fence_open?(params_string)
        nodes = parse_lines(body)
        "<wa-tree>#{build_items(nodes, fence_open)}</wa-tree>"
      end

      patterns = dual_syntax_patterns(PRIMARY_REGEX, ALTERNATIVE_REGEX, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    # Degrade to a clean nested Markdown list (2-space indent per depth, tokens
    # stripped, fence removed).
    def self.render_as_markdown(content, _options = {})
      transform_proc = proc do |_params_string, body, _third|
        nodes = parse_lines(body)
        render_list(nodes, -1, { pos: 0 }, 0)
      end

      patterns = dual_syntax_patterns(PRIMARY_REGEX, ALTERNATIVE_REGEX, transform_proc)
      apply_multiple_patterns(content, patterns)
    end

    class << self
      private

      def fence_open?(params_string)
        params_string.to_s.strip.split(/\s+/).any? { |t| FENCE_TOKENS.include?(t) }
      end

      # Keep only list lines; record each line's indent width and its raw text
      # (everything after the bullet). Blank/non-list lines are skipped.
      def parse_lines(body)
        nodes = []
        body.to_s.each_line do |line|
          match = LIST_LINE_REGEX.match(line.chomp)
          next unless match

          nodes << { indent: indent_width(match[1]), raw: match[2] }
        end
        nodes
      end

      def indent_width(whitespace)
        whitespace.to_s.chars.sum { |char| char == "\t" ? TAB_WIDTH : 1 }
      end

      def build_items(nodes, fence_open)
        helper(nodes, -1, { pos: 0 }, fence_open)
      end

      # Pointer + recursion comparing actual indent values (width-agnostic, no
      # fixed step assumed): children are strictly more indented than the parent.
      def helper(nodes, parent_indent, state, fence_open)
        out = +''
        while state[:pos] < nodes.length && nodes[state[:pos]][:indent] > parent_indent
          node = nodes[state[:pos]]
          current = node[:indent]
          state[:pos] += 1
          children_html = helper(nodes, current, state, fence_open)
          out << emit_item(node, children_html, fence_open)
        end
        out
      end

      def emit_item(node, children_html, fence_open)
        icon_result = IconSlotParser.parse(node[:raw], ICON_SLOTS)
        flags, label = parse_item_flags_and_label(icon_result[:remaining])
        has_children = !children_html.empty?
        expanded = has_children && (fence_open || flags.include?('expanded'))

        attrs = expanded ? ' expanded' : ''
        icon_html = IconSlotParser.to_html(icon_result[:icons], ICON_SLOTS[:slot_map])
        "<wa-tree-item#{attrs}>#{icon_html}#{escape_html(label)}#{children_html}</wa-tree-item>"
      end

      def render_list(nodes, parent_indent, state, depth)
        lines = []
        while state[:pos] < nodes.length && nodes[state[:pos]][:indent] > parent_indent
          node = nodes[state[:pos]]
          current = node[:indent]
          state[:pos] += 1
          _flags, label = parse_item_flags_and_label(IconSlotParser.parse(node[:raw], ICON_SLOTS)[:remaining])
          lines << "#{'  ' * depth}- #{label}"
          child = render_list(nodes, current, state, depth + 1)
          lines << child unless child.empty?
        end
        lines.join("\n")
      end

      # Consume leading expanded tokens; the remainder is the label.
      def parse_item_flags_and_label(remaining)
        tokens = remaining.to_s.strip.split(/\s+/)
        flags = []
        flags << tokens.shift while tokens.any? && ITEM_FLAGS.include?(tokens.first)
        [flags, tokens.join(' ')]
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
