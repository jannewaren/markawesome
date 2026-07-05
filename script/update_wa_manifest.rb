# frozen_string_literal: true

# Regenerates the vendored Web Awesome enum slice used by the manifest-coverage
# spec (spec/fixtures/webawesome-enums.json). Never hand-edit that fixture — it
# is a derived artifact. When Web Awesome ships a new version, run:
#
#   rake wa:manifest[3.11.0]
#
# then bump WA_VERSION in spec/webawesome_manifest_coverage_spec.rb and re-run
# the specs. See CHANGELOG / the sibling Node script scripts/update-wa-manifest.mjs
# in markawesome-js — the two generators share this logic and MUST produce
# byte-identical output.
#
# It fetches WA's machine-readable Custom Elements Manifest, keeps every wa-*
# custom element's inline-union (string-literal) attributes, and writes them as
# a compact, sorted JSON slice.

require 'json'
require 'open-uri'

version = ARGV[0]
abort 'Usage: ruby script/update_wa_manifest.rb <version>   (e.g. 3.10.0)' unless version

source = "@awesome.me/webawesome@#{version}/dist/custom-elements.json"
url = "https://unpkg.com/#{source}"

cem = JSON.parse(URI.parse(url).open(&:read))

all_tags = []
by_tag = {}

Array(cem['modules']).each do |mod|
  Array(mod['declarations']).each do |decl|
    tag = decl['tagName']
    next unless decl['customElement'] && tag&.start_with?('wa-')

    all_tags << tag

    enums = {}
    Array(decl['attributes']).each do |attr|
      text = attr.dig('type', 'text')
      # An inline-union enum has a `|`-joined type of single-quoted literals.
      # Opaque named types (e.g. animations) and `string`/`boolean` are skipped.
      next unless text&.include?('|')

      values = text.scan(/'([^']*)'/).flatten
      next if values.empty?

      enums[attr['name']] = values
    end
    by_tag[tag] = enums unless enums.empty?
  end
end

all_tags.sort!

# Build with `_meta` first, then tag keys sorted; attribute keys sorted, value
# order preserved from upstream. Byte-identical to the Node generator's output.
fixture = { '_meta' => { 'webAwesomeVersion' => version, 'source' => source, 'allTags' => all_tags } }
by_tag.keys.sort.each do |tag|
  fixture[tag] = by_tag[tag].keys.sort.to_h { |attr| [attr, by_tag[tag][attr]] }
end

out_path = File.expand_path('../spec/fixtures/webawesome-enums.json', __dir__)
File.write(out_path, "#{JSON.pretty_generate(fixture)}\n")

attr_count = by_tag.values.sum(&:size)
puts "Wrote #{all_tags.size} wa-* tags (#{attr_count} inline-enum attributes) for WA #{version}"
