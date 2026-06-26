# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.17.0] - 2026-06-26

### Added

- New `VideoTransformer` producing Web Awesome's two media components — `<wa-video>` (a single embedded video with custom controls) and `<wa-video-playlist>` (a playlist wrapping multiple `<wa-video>` children). Both are Web Awesome **Pro** (experimental); the markup emitted is declarative and static-site-safe.
  - **Single video** (primary): a `;;;<tokens>` fence, body, closing `;;;`. **Playlist** (primary): a `;;;;;;<tokens>` container wrapping bare `;;;` items (mirroring the carousel `~~~`/`~~~~~~` structure — the bare `;;;` item open keeps the closing `;;;;;;` from being mis-read as an item). Block alternatives: `:::wa-video <tokens>` and `:::wa-video-playlist <tokens>`. Runs in the pipeline immediately after `ComparisonTransformer`.
  - **Body**: the first markdown link `[text](url)` supplies `title`/`src`; the first markdown image `![alt](url)` supplies `poster` (a negative lookbehind keeps the image's `[…]()` from being taken as the link). A block with no link (no `src`) is left untransformed.
  - **Tokens**: `controls:none|standard|full` and `preload:auto|metadata|none` (enum-validated `key:value`; invalid values dropped) plus the boolean flags `autoplay`, `autoplay-muted`, `autoplay-on-visible`, `loop`, `muted` (whole-token matched, so `autoplay-muted` never triggers `autoplay`). The playlist's `controls` preset is forwarded to the container only — children omit it. Deterministic emission order: `src`, `poster`, `title`, `controls`, `preload`, then `autoplay`, `autoplay-muted`, `autoplay-on-visible`, `loop`, `muted`; `src`/`poster`/`title` are HTML-escaped.
  - **Plain-markdown degradation** (`render_as_markdown`, used for `.md` endpoints / llms.txt): a single video degrades to `[title](src)`; a playlist degrades to a bulleted list of `- [title](src)`.
  - Captions (`<track>`) and multi-format `<source>` children are documented v1 follow-ups — a single `src` attribute suffices today.
- New `DateTransformer` producing Web Awesome's two declarative timestamp components — `<wa-format-date>` (an absolute, locale-formatted date such as "June 26, 2026") and `<wa-relative-time>` ("3 days ago", optionally live-ticking). The date value is baked into the markup at build time; both components are pure declarative wrappers over the browser's `Intl.DateTimeFormat` / `Intl.RelativeTimeFormat`, with no data fetching — ideal for blog post dates, changelog stamps, and "last updated".
  - **Inline syntax** (primary): `[[[ <date> <tokens> ]]]` — triple square brackets, single-line, transformed before Kramdown (runs right after `TooltipTransformer`). `[[[` collides with no other delimiter and survives Kramdown + Jekyll/Liquid.
  - **Block alternative**: `:::wa-format-date <date> <tokens>` / `:::wa-relative-time <date> <tokens>` with an empty body closed by `:::`. The selector name chooses the mode directly.
  - **Mode**: absolute (`<wa-format-date>`) is the default; a bare `relative` token in the inline form switches to `<wa-relative-time>`.
  - **Date token**: the token matching ISO 8601 `YYYY-MM-DD` (optionally `THH:MM[:SS][.s][Z|±HH:MM]`) is passed verbatim (escaped) into `date="…"`. If omitted, `date` is dropped and the component shows the viewer's **current** time (runtime-now). Datetimes use the `T` separator (a space would break tokenization).
  - **format-date formatting**: `style:short|medium|long|full` and `time:short|medium|long|full` presets expand to Web Awesome's granular attributes, with granular overrides (`weekday`, `era`, `year`, `month`, `day`, `hour`, `minute`, `second`, `hour-format`, `time-zone-name`, `time-zone`, `lang`/`locale` → `lang`) winning per key (rightmost-wins). Enum values are validated; invalid values and unknown tokens are silently dropped. A bare date with no style/time/granular field defaults to `style:long`. Deterministic emission order: `date weekday era year month day hour minute second time-zone-name time-zone hour-format lang`.
  - **relative-time formatting**: `format` (`long|short|narrow`, default `long` omitted), `numeric` (`auto|always`, default `auto` omitted), `sync` (boolean live-update flag), and `lang`/`locale` → `lang`. Date/style tokens are ignored in relative mode. Deterministic emission order: `date format numeric sync lang`.
  - **Plain-markdown degradation** (`render_as_markdown`, used for `.md` endpoints / llms.txt): each timestamp degrades to its raw date string (empty for a runtime-now timestamp), since plain text has no locale formatting.
- **Static-site caveat**: like `<wa-icon>`, both timestamp components render generated text into shadow DOM with no light-DOM fallback — with Web Awesome's JS disabled they show nothing. This matches our existing generated-content model (documented alongside the `<wa-tag with-remove>` caveat); no fallback text is emitted.
- `PopoverTransformer` and `TooltipTransformer` now accept **all twelve** Web Awesome placements — the four primary (`top`, `bottom`, `left`, `right`) plus the eight aligned variants (`top-start`, `top-end`, `right-start`, `right-end`, `bottom-start`, `bottom-end`, `left-start`, `left-end`) — matching `<wa-popover>`/`<wa-tooltip>`'s full `placement` surface. `AttributeParser` matches whole tokens, so `bottom-start` resolves without colliding with `bottom`.
- `PopoverTransformer` and `TooltipTransformer` gain a `skidding:N` token, mirroring `distance:N`. It emits `<wa-popover>`/`<wa-tooltip>`'s `skidding` attribute — the offset **along** the target (whereas `distance` is the offset **away** from it). Negative values are allowed (`skidding:-4`). Emission order is deterministic: `placement`, `without-arrow`, `distance`, `skidding` (popover) and `placement`, `distance`, `skidding` (tooltip).
- `TabsTransformer` supports a per-tab `disabled` flag as a **leading token** on the `+++ ` item header (e.g. `+++ disabled Coming soon`), mirroring the accordion item flags. It emits `<wa-tab disabled>` (the tab renders but cannot be selected) and strips the flag from the label; a non-leading occurrence of the word is left untouched. The `render_as_markdown` degradation strips the flag too (`### Coming soon`). Non-disabled tabs are byte-identical to before.

## [0.16.0] - 2026-06-25

### Added

- `CopyButtonTransformer` now accepts a `tooltip:full|copy|none` token controlling Web Awesome's `<wa-copy-button>` **`tooltip`** attribute (added in WA 3.6) — the *mode* of the built-in hover affordance, distinct from the existing `tooltip-placement`:
  - **`full`** (WA default) — the tooltip shows on hover **and** focus, and is reused to display the brief copy-success/error feedback. Emitting `tooltip="full"` is explicit-but-redundant.
  - **`copy`** — the tooltip stays **silent on hover/focus** and appears **only briefly to confirm a successful or failed copy** (feedback-only, no hover hint).
  - **`none`** — no tooltip in any state.
- The token is a `key:value` form (like `distance:N`, `icon:name`), order-independent with the other copy-button tokens. The capture is **enum-anchored** (`full|copy|none`), so invalid values such as `tooltip:bogus` simply don't match and are dropped, falling back to WA's default — consistent with the "unknown tokens dropped" convention. Emit order stays deterministic: `tooltip` follows `tooltip-placement`.
- The plain-markdown degradation path (`render_as_markdown`) is unaffected — the wrapper and all params are discarded, leaving only the copied content.

## [0.15.0] - 2026-06-24

### Added

- New `TooltipTransformer` producing Web Awesome `<wa-tooltip>` — inline contextual help on hover/focus for glossary terms and inline definitions. Declarative, zero-JS, and static-site-safe: the tooltip is attached to a focusable anchor `<span>` via an auto-generated `for`/`id` pair, so authors write only the trigger term and the tip text.
  - **Inline syntax** (primary): `(((anchor term >>> tip text)))`. The `(((` delimiter is unused by any other transformer, is not Markdown- or Liquid-special, and never appears in normal prose; the `>>>` separator matches the popover/dialog/details convention (anchor first, tip after `>>>`).
  - **Block alternative**: `:::wa-tooltip placement? distance:N?` / anchor / `>>>` / tip / `:::`, for consistency with every other component's `:::wa-*` form.
  - **Attributes** (order-independent leading tokens): `placement` (`top` default, `bottom`, `left`, `right`) and `distance:N`. Mirrors `PopoverTransformer`'s surface minus `link`/`without-arrow` (WA `<wa-tooltip>` has no `without-arrow` boolean — arrow size is CSS-only).
  - **Tip content** is plain text (HTML-escaped), with literal `\n` rendered as `<br>` — the same surface as the popover's *inline* form. Tooltips hold brief text, so there is no Markdown body.
  - **Emitted markup**: a focusable `<span id="tooltip-…" tabindex="0" class="ma-tooltip-anchor" style="text-decoration: underline dotted; cursor: help;">` anchor followed by `<wa-tooltip for="tooltip-…" placement="…" [distance="…"]>`. The anchor is focusable so keyboard/AT users get the tip (tooltips fire on focus too); `ma-tooltip-anchor` is a styling hook (mirrors popover's `ma-popover-trigger`).
  - **IDs** are auto-wired via `tooltip-<first 8 of MD5(anchor+tip)>`, with `-2`/`-3` dedup suffixes for repeated identical tooltips — the same scheme as `PopoverTransformer`. Runs immediately after `PopoverTransformer` (early, after `LayoutTransformer`) so inline tooltips inside cards/callouts/details are transformed before Kramdown escapes `(((`/`>>>`.
  - **Plain-markdown degradation** (`render_as_markdown`, used for `.md` endpoints / llms.txt): both forms degrade to `**anchor** (tip)`, mirroring the popover inline degradation.
- Aligned placements (`top-start`, …), `show-delay`/`hide-delay`, and a rich-content block form are explicit future follow-ups, not part of v1.

## [0.14.0] - 2026-06-24

### Added

- New `AccordionTransformer` producing Web Awesome `<wa-accordion>` / `<wa-accordion-item>` — a multi-section collapsible container for FAQs, docs sections, and "show more" content (the grouped, mutually-exclusive-capable sibling of `details`). The `/` delimiter is the container/item marker: container fence `//////` (6×), item fence `///` (3×) with an explicit `///` close, mirroring tabs (`++++++`/`+++`). An alternative `:::wa-accordion … :::` form is also accepted.
  - **Container line** (bare tokens, order-independent, rightmost-wins): `appearance` (`outlined` default, `filled`, `filled-outlined`, `plain`), `mode` (`multiple`, `single`, `single-collapsible`), `icon-placement` (`start`, `end`), and a value-form `heading:N` → `heading-level="N"` where `N` is `1`–`6` or `none` (out-of-range values fall back to omitting the attribute). `appearance` is always emitted (defaulting to `outlined`); `mode`, `icon-placement`, and `heading-level` are emitted only when specified.
  - **Item header** (`/// [expanded] [disabled] [icon:name] Label`): leading `expanded`/`disabled` flags become the matching boolean attributes; `icon:name` becomes a `<wa-icon slot="icon" name="…">` first child; the remaining text becomes the HTML-escaped `label`. Item bodies are full markdown and may contain other components.
  - **Plain-markdown degradation** (`render_as_markdown`, used for `.md` endpoints / llms.txt): each item degrades to a `### Label` heading followed by its body, mirroring tabs.
- `wa-accordion` is **experimental** in Web Awesome (added in 3.7), but `expanded`, `disabled`, and the `mode`/`appearance`/`icon-placement`/`heading-level` attributes are all declarative and static-site-safe — no JavaScript required. The interactive `expandAll()`/`collapseAll()` controls and rich/HTML `label` slot are out of scope for v1; item labels are plain text. The `--wa-accordion-divider-color` custom property removed in WA 3.9.0 is intentionally not exposed.

## [0.13.0] - 2026-06-20

### Added

- The standalone `:::wa-icon` block now accepts `family` (`classic`, `sharp`, `duotone`, `sharp-duotone`, `brands`), `variant` (`thin`, `light`, `regular`, `solid`), and `animation` (`beat`, `fade`, `beat-fade`, `bounce`, `flip`, `shake`, `spin`, `spin-pulse`, `spin-reverse`) as bare enumerated tokens after the icon name (order-independent, rightmost-wins, unknown tokens dropped — same parsing as button `variant`/`size`). The block body becomes the icon's accessible `label` (stripped, whitespace-collapsed, HTML-escaped); an empty body emits no `label`, leaving the icon presentational per Web Awesome's default. Emit order is deterministic: `name family variant animation label`.
- `CalloutTransformer` callouts can now override their icon's `family`/`variant`/`animation` using the same bare tokens on the callout line (e.g. `:::warning shake`). The historical `variant="solid"` default is preserved when no icon-variant token is given, so existing callouts render byte-identically. Works alongside the existing `icon:name` override.
- New shared `Markawesome::IconAttributes` module — single source of truth for the `<wa-icon>` family/variant/animation vocabulary (verified against Web Awesome 3.x), consumed by both `IconTransformer` and `CalloutTransformer`.

The inline `$$$name` form stays **name-only** (mid-prose, semantically decorative). Embedded `icon:slot:name` icons in button/tag/details are unchanged. Note: `family`/`variant` produce a *visible* weight/family change only with a Font Awesome Pro kit; the attributes are always emitted to the DOM regardless of kit tier (validated against the examples site's WA 3.8.0 kit, where `animation` and `label` are fully functional and the weight/family attributes reach the element without a visible glyph swap on the free tier).

## [0.12.0] - 2026-06-19

### Added

- `ButtonTransformer` link-form buttons now accept `target` (`_blank`, `_self`, `_parent`, `_top`) and a boolean `download` flag. When `target="_blank"` is set, `rel="noopener noreferrer"` is emitted automatically to guard against reverse tabnabbing. These attributes are emitted **only** on link-form buttons (markup wrapping a markdown link, e.g. `%%%brand _blank\n[Text](url)\n%%%`); written on a regular (non-link) button they are parsed but dropped, consistent with the existing unrecognized-token behavior. They are also absent from the plain-markdown degradation path (`render_as_markdown`), since a plain `[text](url)` can't express them. A `download:filename` value form is a possible future enhancement.

## [0.11.0] - 2026-06-16

Aligns generated markup with Web Awesome 3.8.0 (latest). See `ROADMAP.md` for the remaining enhancement backlog from the same audit.

### Fixed

- `DialogTransformer` footer button now emits `variant='brand'` instead of the non-existent `variant='primary'`. `primary` is a Shoelace-era value with no equivalent in Web Awesome 3.x, so the button silently fell back to the default neutral variant instead of rendering as a brand call-to-action.
- `DialogTransformer` image-trigger buttons now emit `appearance='plain'` instead of the invalid `variant='text'`. Because `text` is not a valid `variant`, the wrapping button fell back to the default `accent` appearance — rendering image thumbnails inside a filled accent button background. `appearance='plain'` removes the button chrome as intended.
- `PopoverTransformer` triggers now emit `appearance='plain'` instead of the invalid `variant='text'`, so popover triggers render as plain text rather than filled buttons.
- `DetailsTransformer` now emits `appearance='filled-outlined'` (hyphenated) instead of `'filled outlined'` (space). The space-separated value is not a valid appearance and silently fell back to `outlined`.

### Added

- Web Awesome 3.x size scale (`xs`, `s`, `m`, `l`, `xl`) is now accepted for `button`, `callout`, and `tag` components. The legacy `small`/`medium`/`large` tokens continue to work.
- Layout utilities now accept the `4xl` and `5xl` gap tokens (`wa-gap-4xl`, `wa-gap-5xl`), added to Web Awesome's spacing scale in 3.4.

## [0.10.1] - 2026-05-08

### Fixed

- `PopoverTransformer` no longer emits duplicate `id` attributes when the same popover (identical trigger text and content) appears more than once in a document. Popover IDs were derived solely from `MD5(trigger + content)`, so repeated popovers shared an ID and triggered HTML validators' `no-dup-id` rule. The first occurrence keeps its existing ID for backwards compatibility; subsequent occurrences are suffixed with `-2`, `-3`, etc.

## [0.10.0] - 2026-05-05

### Added

- `Markawesome::PlainMarkdownRenderer` — alternate output format that degrades each Web Awesome component to its closest plain-markdown equivalent: GFM alerts for callouts, `<details>` for details, sequential `###` sections for tabs, plain links for buttons, bold for badges/tags, and so on. Useful for sites that want to publish a clean-markdown copy of their pages alongside the HTML — for example, per-page `.md` endpoints or an `llms.txt`-style index that tools and LLM consumers can read without parsing `<wa-*>` tags.
- `Markawesome::CodeBlockProtector` — stateless helper that replaces fenced code blocks with opaque placeholders before transformation and restores them after. Extracted from `jekyll-webawesome`'s hook logic so the same guarantee applies anywhere Markawesome is used (Hugo, Middleman, plain Ruby).
- `render_as_markdown(content, options = {})` class method on every transformer, sitting alongside the existing `transform` method. `Markawesome::Transformer.process` still emits HTML; `Markawesome::PlainMarkdownRenderer.process` emits clean markdown.
- `Markawesome::PlainMarkdownRenderer.register_override(:component) { |content, opts| ... }` for swapping in a custom rendering of a single component without forking the gem.

### Changed

- `Markawesome::Transformer.process` now wraps the pipeline with `CodeBlockProtector.protect/restore`, so fenced code examples that contain `:::`/`^^^`/`@@@` no longer trigger accidental transformation. Previously this protection lived in `jekyll-webawesome`, leaving consumers of Markawesome on other frameworks without it.

## [0.9.5] - 2026-03-18

### Fixed

- Added `type='button'` attribute to link-style popover trigger `<button>` elements to satisfy `no-implicit-button-type` HTML validation rule

## [0.9.4] - 2026-03-13

### Changed

- Moved PopoverTransformer earlier in the pipeline (right after LayoutTransformer) so that inline popovers (`&&&trigger >>> content&&&`) work inside cards, callouts, details, and other block containers that markdown-process their body content. Previously, Kramdown would HTML-escape the `&&&` and `>>>` characters before PopoverTransformer had a chance to process them.

## [0.9.3] - 2026-03-13

### Added

- Inline popover content now supports `\n` escape sequences for line breaks — rendered as `<br>` in HTML output. Useful for structured multi-line content in table cells where actual newlines break markdown table syntax.

## [0.9.2] - 2026-03-13

### Added

- Link-style popover triggers now include a `ma-popover-trigger` CSS class for easier styling overrides in consumer projects

## [0.9.1] - 2026-03-12

### Changed

- Link-style popover triggers now use dotted underline (`text-decoration-style: dotted`) to visually distinguish them from navigation links

## [0.9.0] - 2026-03-12

### Added

- **PopoverTransformer**: Inline syntax `&&&trigger text >>> popover content&&&` for use within sentences
  - Always renders as link-styled trigger (underlined text button)
  - Supports all parameters: placement, `without-arrow`, `distance:N`
  - Parameters placed before trigger text, separated by spaces
  - Plain text content (HTML-escaped, no markdown processing)
  - Multiple inline popovers supported on the same line

## [0.8.0] - 2026-03-12

### Added

- **PopoverTransformer**: New `&&&` syntax for `wa-popover` floating content component
  - Trigger text and popover content separated by `>>>` (same pattern as dialog/details)
  - Placement options: `top` (default), `bottom`, `left`, `right`
  - `without-arrow` flag to hide the popover arrow
  - `distance:N` parameter for custom trigger-to-popover distance in pixels
  - `link` flag to render trigger as a link-styled element instead of a button
  - Unique anchor IDs generated via MD5 hash for trigger/popover pairing
  - Alternative `:::wa-popover` syntax supported
  - Markdown content support in popover body via Kramdown
  - HTML escaping for trigger text (XSS prevention)

## [0.7.0]

### Changed

- **BREAKING: Card header syntax** — Card headers now use `**bold text**` instead of `# heading`. The first bold-only line inside a card block becomes the header slot. This avoids markdownlint warnings about multiple top-level headings (MD025) and incorrect heading levels (MD001), and better reflects that card titles are not semantic document headings.

## [0.6.0] - 2026-02-14

_(Version bump included LayoutTransformer and icon slot syntax — see 0.5.0 and 0.4.0 entries below.)_

## [0.5.0] - 2026-02-10

### Added

- **LayoutTransformer**: New `::::` (quadruple colon) syntax for wrapping content in Web Awesome CSS layout containers
  - Supports 6 layout types: `grid`, `stack`, `cluster`, `split`, `flank`, `frame`
  - Common attributes: `gap:SIZE`, `align:VALUE`, `justify:VALUE` for all layouts
  - Grid-specific: `min:CSS_VALUE` for custom minimum column size (`--min-column-size`)
  - Split-specific: `row` and `column` direction modifiers
  - Flank-specific: `start`/`end` position modifiers, `size:CSS_VALUE`, `content:PCT`
  - Frame-specific: `landscape`/`portrait`/`square` aspect ratios, `radius:SIZE`
  - Dual syntax: both `::::grid` and `::::wa-grid` work identically
  - CSS value sanitization for user-provided values (strips quotes, angle brackets, semicolons)
  - Inner content is not markdown-converted, allowing component `:::` syntax to be processed by subsequent transformers
  - Runs first in the pipeline so layout containers wrap around component output

## [0.4.0] - 2026-02-09

### Added

- **IconSlotParser**: New reusable parser for `icon:name` and `icon:slot:name` syntax across components
- **ButtonTransformer**: Icon support with `icon:name` (start slot) and `icon:end:name` for start/end icon slots
- **CalloutTransformer**: Custom icon override with `icon:name` to replace default variant icons
- **DetailsTransformer**: Custom expand/collapse icons with `icon:expand:name` and `icon:collapse:name`
- **TagTransformer**: Inline content icons with `icon:name` for both block and inline tag syntax

### Design

- IconSlotParser composes with AttributeParser — strips icon tokens first, passes remaining params for attribute parsing
- Supports slot name mapping (e.g. `expand` → `expand-icon`) for Web Awesome's HTML slot conventions
- Rightmost-wins semantics consistent with AttributeParser
- Content slot mode omits `slot=` attribute for inline icon usage (tags)

## [0.3.0] - 2026-02-08

### Added

- **TagTransformer**: Comprehensive attribute support including variant, size, appearance, pill, and removable
- **TabsTransformer**: Added activation, active, and no-scroll-controls attributes
- **DetailsTransformer**: Added disabled, open, and name attributes
- **CopyButtonTransformer**: Comprehensive attribute support including variant, size, appearance, and disabled
- **CarouselTransformer**: Added autoplay-interval attribute support
- **CardTransformer**: Added orientation support

### Changed

- **AttributeParser Refactoring**: Migrated DetailsTransformer and CarouselTransformer to use AttributeParser for consistent, flexible attribute handling
- **DialogTransformer**: Refactored to use AttributeParser for improved attribute parsing
- **CardTransformer**: Refactored to use AttributeParser
- Added RuboCop configuration for better code quality management

### Improved

- Consistent attribute parsing across all major transformers
- Better test coverage for all new attributes
- More flexible, order-independent parameter syntax

## [0.2.0] - 2025-10-27

### Added

- Initial release of Markawesome
- Framework-agnostic Markdown to Web Awesome component transformation
- Support for Badge, Button, Callout, Card, Carousel, Comparison, Copy Button, Details, Dialog, Icon, Image Dialog, Tabs, and Tag components
- Configuration system for callout icons and custom components
- Extracted from jekyll-webawesome gem for reusability across frameworks
