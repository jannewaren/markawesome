# Roadmap

This is the **shared roadmap for the whole Markawesome ecosystem** — the six
repositories that must stay in lockstep (`markawesome`, `markawesome-js`,
`jekyll-webawesome`, `eleventy-plugin-webawesome`, `markawesome-vscode`,
`markawesome-skill`; see `CLAUDE.md`). Each item below is tagged with the repo(s) it touches. Shipped
history lives in each repo's `CHANGELOG.md`.

---

## Planned — cross-project

### 1. Reach engine parity + add a reverse mode in `markawesome-js`

_Repo: `markawesome-js`_

a) **Port the "Markawesome → plain Markdown" renderer.** Ruby `markawesome` has
   `Markawesome::PlainMarkdownRenderer` (each transformer's `render_as_markdown`),
   which degrades every Web Awesome component to its closest GFM equivalent — used
   to serve per-page `.md` endpoints and to generate `llms.txt` content that LLM
   consumers can read without understanding `<wa-*>` tags. `markawesome-js` only
   exports `process` (Markawesome → HTML) and has no plain-Markdown path. Port it
   so both engines expose the same degrade-to-Markdown capability, and cover it in
   the parity corpus.

b) **Add a full "Web Awesome HTML → Markawesome" mode.** A reverse transform that
   parses existing `<wa-*>` markup back into Markawesome shorthand, so hand-written
   or legacy WA HTML can be adopted into the Markawesome authoring flow. This is a
   **new capability neither engine has today**; design it in `markawesome-js`
   first, then decide whether Ruby `markawesome` mirrors it (the sync rule applies
   to any syntax it emits).

### 2. Add an "annotate with explanatory comments" mode to `markawesome-vscode`

_Repo: `markawesome-vscode`_

A command/mode that inserts a short explanatory Markdown comment above each
Markawesome element, so a reader **without** the extension (or any prior
knowledge) understands what the shorthand does — e.g. a comment noting that the
syntax translates into a `<wa-callout>` with a `<wa-icon>` slotted in. The
human-readable descriptions already exist in `src/data/components.json` (surfaced
today by `hoverProvider`), so the mode can reuse them; it fits alongside the
existing commands in `src/commands/transformCommands.ts`.

---

## Web Awesome 3.10.0 uptake — done (unreleased)

_Captured from the [Web Awesome changelog](https://webawesome.com/docs/resources/changelog)
for releases **after 3.9.0** (which we've already fully addressed — see the "done"
audit below). The relevant post-3.9.0 surface is **3.10.0** (June 30th, 2026): one
new static-safe component and a batch of new `<wa-icon>` attributes/values. **Both
items below are implemented** across the engines + editor and reflected in the
integration example sites; they sit under each repo's `## [Unreleased]` CHANGELOG
pending the next release (bundled together — no interim publish). The other
post-3.8.0 additions are form controls or interactive/selection features and stay
out of scope (see the note at the end of this section)._

### 3. New component: `<wa-random-content>` (rotating / random content) — done

_Repos: `markawesome`, `markawesome-js`, `markawesome-vscode`_

Shipped as `RandomContentTransformer` (and its `markawesome-js` mirror + VS Code
tooling). `<wa-random-content>` (experimental, added in WA 3.10.0) "randomly shows
one or more of its children — handy for rotating testimonials, tips, or featured
content." It is a **great fit for static sites**: it adds a genuine dynamic feel
with **zero JavaScript wiring from the author** — the component picks its
child(ren) on its own, and (with `autoplay`) can rotate them client-side.

The declarative surface (`mode`, `items`, `animation`, `autoplay`,
`autoplay-interval`) and the final shorthand — a `......` outer fence with `>>>`
option separators, each option wrapped in a single `<div>` so WA sees exactly one
selectable element child — are documented in each engine's `CHANGELOG.md`
`## [Unreleased]` entry.

### 4. `<wa-icon>` enhancements from WA 3.10.0 — done

_Repos: `markawesome`, `markawesome-js`, `markawesome-vscode`_

Synced the shared `<wa-icon>` vocabulary in `Markawesome::IconAttributes::SCHEMA`
(inherited for free by `$$$name` / `:::wa-icon …` **and** callout icon overrides),
byte-for-byte mirrored in `markawesome-js`, and reflected in `markawesome-vscode`
completions/hover/snippets:

- **New `canvas` attribute** — `fixed` (default, 1.25 × 1em), `auto` (natural
  width), `square` (1.25 × 1.25em), `roomy` (1.5 × 1.5em). Added to
  `IconAttributes::SCHEMA` + `pairs`; emitted only when specified (default
  `fixed`), appended **last** in the deterministic order for JS parity.
- **New animations** (3.10.0) — `flip-360`, `spin-snap`, `spin-snap-4`,
  `spin-snap-8`, `buzz`, `float`, `jello`, `swing`, `wag` added to the
  `animation` list.
- **Full family sync** — the entire current WA family vocabulary was added (the
  3.10.0 five — Mosaic, Pixel, Vellum, Slab Duo, Slab Press Duo — plus `chisel`,
  `etch`, `graphite`, `jelly`, `jelly-duo`, `jelly-fill`, `notdog`, `notdog-duo`,
  `slab`, `slab-press`, `thumbprint`, `utility`, `utility-duo`, `utility-fill`,
  `whiteboard`), not just the five: the values are passthrough and emitting them
  is harmless; whether a given family renders depends on the site's Font Awesome
  kit tier (Pro / Pro+), which is the author's concern.
- **New `variant`** — `semibold` added to `thin light regular solid`.
- **`auto-width` deprecation** — WA deprecated `auto-width` in favor of
  `canvas="auto"`. We never emitted `auto-width` (verified), so nothing to
  migrate; `canvas` gives authors the supported replacement.

### Considered but out of scope (post-3.8.0)

- `<wa-tree>` `leaf-multiple` selection value (3.9.0) — selection is an
  interactive/JS feature; our tree is deliberately **display/navigation-only**
  (see `tree_transformer.rb`), so we skip it, consistent with that design.
- `<wa-checkbox-group>` (3.9.0), `<wa-date-input>` / `<wa-date-picker>` /
  `<wa-known-date>` / `<wa-time-input>` (3.8.0) — form controls / interactive
  inputs; already out of scope per the list at the bottom of this file.
- `<wa-button-group>` gaining native-`<button>` support (3.9.0) — button-group
  is a pre-existing, purely presentational component we don't currently emit;
  not requested and not a post-3.8.0 *new* component. Could be revisited
  separately if grouped buttons become desirable.
- Text utility classes (`wa-text-*`, `wa-prose`) and `<wa-qr-code>` new
  attributes (3.8.0) — utility classes don't fit our component-transform model;
  qr-code is a pre-existing component we don't transform.

---

## Pin the Web Awesome version via CDN in the example sites — done

_Repos: `jekyll-webawesome`, `eleventy-plugin-webawesome`_

Both example sites previously loaded Web Awesome through an opaque hosted **kit**
(`<script src="https://kit.webawesome.com/43e2fc18755d4267.js">`), which hid
which WA version it served — so the rendered version drifted silently and visual
validation wasn't reproducible (a point called out in `CLAUDE.md`'s release
workflow). Both example layouts
(`jekyll-webawesome/examples/_layouts/default.html` and
`eleventy-plugin-webawesome/examples/_includes/base.njk`) now load Web Awesome
from the **pinned-version CDN** (`webawesome@3.9.0` in the URL: theme + palette +
native + utilities stylesheets and the autoloader), with the tailspin theme /
vogue palette / indigo brand and the FA Pro kit code set explicitly on `<html>`.
The kit script is dropped and the WA version is now explicit and deterministic;
bump the pin deliberately when moving to a new WA release.

**Bumped to 3.10.0 (July 2, 2026).** Both example pins were subsequently moved
from `webawesome@3.9.0` to `webawesome@3.10.0` (the June 30, 2026 release) in
`jekyll-webawesome/examples/_layouts/default.html` and
`eleventy-plugin-webawesome/examples/_includes/base.njk`, and re-validated live
in the browser: all 695 `wa-*` elements on the Jekyll example page upgrade
(`:defined`) and render with correct dimensions, only `webawesome@3.10.0` assets
load, and the console is clean. This unblocks the live end-to-end validation
needed to close the remaining 3.10.0 uptake items above (`<wa-random-content>`
and the new `<wa-icon>` attributes).

---

## Engine markup audit against Web Awesome 3.9.0 — done

_Repos: `markawesome`, `markawesome-js`_

Captured from an audit of our generated markup against
[Web Awesome](https://webawesome.com/) **3.9.0** (latest as of June 2026). These
were **enhancements, not bugs** — the markup we emit is valid 3.x, and every item
was backward-compatible and static-site-safe: no JavaScript, data fetching, or
form wiring required. Each mapped to a declarative Web Awesome attribute or
component that fits a "content comes from a static Markdown file" model.

> The **"missing declarative attributes" audit against WA 3.9.0 is fully
> addressed** — every component we transform now surfaces the declarative
> attributes WA exposes for it. The `tree` component has landed, and the
> `<wa-tag with-remove>` static-site caveat is now documented in the README, so
> **nothing actionable remains in this audit** — only the out-of-scope list
> below.

---

## Documentation task — done

`<wa-tag>` with `with-remove` renders a remove button that **does nothing**
without a JavaScript `wa-remove` listener. We chose to **keep** the attribute
(the emitted markup is valid Web Awesome) and document the caveat in the README
rather than omit it from the static-safe surface.

---

## Explicitly out of scope

These Web Awesome components need JavaScript, live data, or form submission
wiring and **don't** fit a static-Markdown model:

- All form controls — `input`, `textarea`, `select`, `checkbox`, `radio`,
  `switch`, `slider`, `rating`, `color-picker`, date/time pickers, `combobox`
- All chart types
- `dropdown`, `drawer`, `dialog`-as-app-modal beyond our current usage
- Toasts/notifications, `mutation-observer` / `resize-observer`, `page`,
  `markdown` (we *are* the Markdown layer)
