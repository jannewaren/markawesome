# frozen_string_literal: true

require_relative 'base_transformer'

module Markawesome
  # Transforms comparison syntax into wa-comparison elements
  # Primary syntax: |||\n![before](before.jpg)\n![after](after.jpg)\n|||
  # Primary syntax with position: |||50\n![before](before.jpg)\n![after](after.jpg)\n|||
  # Alternative syntax: :::wa-comparison\n![before](before.jpg)\n![after](after.jpg)\n:::
  # Alternative syntax with position: :::wa-comparison 50\n![before](before.jpg)\n![after](after.jpg)\n:::
  # Expects exactly two image elements inside the wrapper
  class ComparisonTransformer < BaseTransformer
    def self.transform(content)
      # Process primary syntax
      content = content.gsub(/^\|\|\|(\d+)?\n(.*?)\n\|\|\|/m) do |match|
        position = Regexp.last_match(1)
        inner_content = Regexp.last_match(2).strip
        images = extract_images(inner_content)

        if images.length == 2
          build_comparison_html(inner_content, position)
        else
          match # Return original match if not exactly 2 images
        end
      end

      # Process alternative syntax
      content.gsub(/^:::wa-comparison\s*(\d+)?\n(.*?)\n:::/m) do |match|
        position = Regexp.last_match(1)
        inner_content = Regexp.last_match(2).strip
        images = extract_images(inner_content)

        if images.length == 2
          build_comparison_html(inner_content, position)
        else
          match # Return original match if not exactly 2 images
        end
      end
    end

    def self.render_as_markdown(content, _options = {})
      content = content.gsub(/^\|\|\|(\d+)?\n(.*?)\n\|\|\|/m) do |match|
        images = extract_images(::Regexp.last_match(2))
        images.length == 2 ? render_comparison_markdown(images) : match
      end

      content.gsub(/^:::wa-comparison\s*(\d+)?\n(.*?)\n:::/m) do |match|
        images = extract_images(::Regexp.last_match(2))
        images.length == 2 ? render_comparison_markdown(images) : match
      end
    end

    class << self
      private

      def render_comparison_markdown(images)
        before_alt, before_src = images[0]
        after_alt, after_src = images[1]
        "**Before:** ![#{before_alt}](#{before_src})\n\n**After:** ![#{after_alt}](#{after_src})"
      end

      def build_comparison_html(content, position = nil)
        images = extract_images(content)

        before_image = build_image_html(images[0], 'before')
        after_image = build_image_html(images[1], 'after')

        position_attr = position ? " position=\"#{position}\"" : ''

        "<wa-comparison#{position_attr}>#{before_image}#{after_image}</wa-comparison>"
      end

      def extract_images(content)
        # Extract markdown image syntax: ![alt](url)
        image_regex = /!\[([^\]]*)\]\(([^)]+)\)/
        content.scan(image_regex)
      end

      def build_image_html(image_match, slot)
        alt_text = image_match[0]
        src = image_match[1]

        # Escape HTML characters in alt text
        escaped_alt = alt_text.gsub('&', '&amp;').gsub('"', '&quot;').gsub('<', '&lt;').gsub('>', '&gt;')

        "<img slot=\"#{slot}\" src=\"#{src}\" alt=\"#{escaped_alt}\" />"
      end
    end
  end
end
