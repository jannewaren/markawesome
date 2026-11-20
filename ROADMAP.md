# Roadmap

This is the **shared roadmap for the whole Markawesome ecosystem** — the six
repositories that must stay in lockstep (`markawesome`, `markawesome-js`,
`jekyll-webawesome`, `eleventy-plugin-webawesome`, `markawesome-vscode`,
`markawesome-skill`; see `CLAUDE.md`). Each item below is tagged with the repo(s) it touches. Shipped
history lives in each repo's `CHANGELOG.md`.

---

## Planned — cross-project

### 1. Add a "Web Awesome HTML → Markawesome" mode

_Repo: `markawesome-js`_

A reverse transform that parses existing `<wa-*>` markup back into Markawesome
shorthand, so hand-written or legacy WA HTML can be adopted into the Markawesome
authoring flow. This is a **new capability neither engine has today**; design it in
`markawesome-js` first, then decide whether Ruby `markawesome` mirrors it (the sync
rule applies to any syntax it emits).

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

## Plain-Markdown renderer parity in `markawesome-js` — done

_Repo: `markawesome-js`_

Ruby `markawesome` has `Markawesome::PlainMarkdownRenderer` (each transformer's
`render_as_markdown`), which degrades every Web Awesome component to its closest GFM
equivalent — used to serve per-page `.md` endpoints and to generate `llms.txt` content
that LLM consumers can read without understanding `<wa-*>` tags. `markawesome-js` now
mirrors it: `src/plain-markdown-renderer.ts`, exported as `plainMarkdown` from
`src/index.ts`, byte-for-byte compatible with the Ruby renderer and covered both by
`test/plain-markdown-renderer.test.ts` (mirroring `spec/plain_markdown/renderer_spec.rb`)
and by the shared `test/parity-corpus.test.ts`. Both engines expose the same
degrade-to-Markdown capability.

---

## Web Awesome 3.15.0 audit — done

_Repos: all six_

WA **3.15.0** (November 17th, 2026) was audited against the whole ecosystem. The
manifest fixture was refreshed in both engines (`rake wa:manifest[3.15.0]` /
`npm run update-wa-manifest 3.15.0`, `WA_VERSION` → `3.15.0`) and the enum diff is
**purely additive**: five new tags (`wa-code-highlighter`, `wa-counter`, `wa-lightbox`,
`wa-lightbox-item`, `wa-number-ticker`) and the enums on them. **Zero DRIFT, zero GAP**
against the enums we accept — no transformer constant changed.

**What we get for free** by moving the pins:

- **`<wa-stepper>` / `<wa-step>` are now stable.** We emit them, so the
  "experimental" caveat was dropped from the engines, the editor and the skill.

**What was added (new syntax in both engines, the editor, the skill and both example sites; shipped in markawesome 0.21.0 / markawesome-js 0.6.0 / jekyll-webawesome 0.27.0 / eleventy-plugin-webawesome 0.6.0 / markawesome-vscode 0.16.0 / markawesome-skill 0.3.0):**

- **Lightbox gallery.** `<wa-lightbox>` / `<wa-lightbox-item>` (experimental) open
  images and videos in a full-screen viewer from their thumbnails. New
  `::::lightbox` fence — it *is* a `wa-grid` (`gap:`, `min:` reuse the layout rules)
  whose body is Markdown images: `![alt](src "caption")`, or a linked image
  `[![alt](thumb)](full "caption")` for a separate full-size file; a video
  extension makes the item `type="video"`. Flags: `loop`, `thumbnails`, `no-nav`,
  `no-counter`, `no-zoom`, `label:"…"`; thumbnails are square-cropped by default
  (`landscape`, `portrait`, `natural`). Each item's `src` is a real link target, so
  the gallery still works without JavaScript.
- **Counter.** `<wa-counter>` (experimental) counts down to / up from a date. A
  mode of the existing `[[[ … ]]]` date syntax: `countdown` / `countup`, with
  `largest:`/`smallest:` units, `format:`, `no-labels`, `delimiter:"…"`,
  `label:"…"` and `finished:"…"` (the finished slot).
- **Number ticker.** `<wa-number-ticker>` (experimental) counts up to a value when
  it scrolls into view. Also `[[[ … ]]]`: a leading number (`[[[ 87% ]]]`,
  `[[[ 18452.75 currency:EUR ]]]`) with `from:`, `duration:`, `delay:`, `easing:`,
  `eager`, `no-grouping`, `decimals:`, `display:` and `lang:`.

### Considered but out of scope (3.15.0)

- `<wa-code-highlighter>` — would take over every code fence, and every host
  (Jekyll/Rouge, Eleventy plugins) already highlights at build time. Revisit as an
  opt-in.
- `<wa-rich-text-editor>` — a Pro form control; see *Explicitly out of scope*.
- `<wa-timeline>` — announced but not in 3.15.0. Revisit at 3.16.
- `--backdrop-color`, `disable-sticky` and the new `*__<component>` CSS parts — none
  apply to markup we emit.
- Lightbox `data-lightbox` external triggers, `width`/`height`/`srcset`, the
  `actions` slot and `<template>` slides — need per-image metadata or app
  JavaScript Markdown can't express.
- Counter `duration` (relative to page load, not a date) and `paused` (needs JS to
  resume); ticker significant/integer digits, `valueFormatter` and `restart()`.

---

## Web Awesome 3.14.0 audit — done

_Repos: all six_

WA **3.13.0** (September 16th, 2026) and **3.14.0** (September 24th, 2026) were audited
together against the whole ecosystem. The manifest fixture was refreshed in both engines
(`rake wa:manifest[3.14.0]` / `npm run update-wa-manifest 3.14.0`, `WA_VERSION` →
`3.14.0`) and the enum diff is **purely additive**: three new tags (`wa-step`,
`wa-stepper`, `wa-tag-input`) and a new `label-placement` enum on `wa-divider`.
**Zero DRIFT, zero GAP** against the enums we accept — no transformer constant changed.

**What we get for free** by moving the pins:

- **`<wa-accordion>` and `<wa-random-content>` are now stable** (along with
  `wa-known-date`, `wa-otp-input`, `wa-pagination` and `wa-time-input`). Both are
  components we emit, so the "experimental" caveats were dropped from the engines,
  the editor and the skill.

**What was added (new syntax in both engines, the editor, the skill and both example sites; shipped in markawesome 0.20.0 / markawesome-js 0.5.0):**

- **Labeled divider.** `<wa-divider>` gained a default-slot label and
  `label-placement` (`start`/`center`/`end`). New mirrored shorthand
  `--- label ---` (plain `---` stays an `<hr>`), with leading
  `start|center|end`, `horizontal|vertical` and `icon:name` tokens, plus the
  `:::wa-divider` alt syntax. A labeled divider is pure presentation — a natural fit.
- **Display-only stepper.** `<wa-stepper>` / `<wa-step>` (experimental) show
  progress through a process. New `>>>>>>` fence whose body is a task list —
  `[x]` marks completed steps, leading flags set `active`/`loading`/`disabled`,
  variant, attention and `icon:name`, and indented continuation lines become the
  step's `description` slot. The active step is resolved statically (explicit
  `active`, else the first incomplete step, else the last). Interactivity —
  `clickable`, `linear`, `data-stepper` invokers — is **excluded**: our steps have no
  content panels, so navigation without app JavaScript has nothing to show (the
  same stance as `<wa-tree>`).

Both run first in the pipeline (right after code-block protection), so they nest
inside any container. Ruby and Node output is byte-identical across 14 new
parity-corpus cases, and both were checked live on the two example sites against
the 3.14.0 CDN.

### Considered but out of scope (3.13.0 / 3.14.0)

- `<wa-tag-input>` — a form control (experimental); see *Explicitly out of scope*.
- `<wa-combobox>` async options — form control, JS-supplied data.
- `<wa-page>` `nonce` — CSP plumbing for the page shell, which we don't emit.
- `<wa-zoomable-frame>` `label` / `name` / `allow` — we don't emit zoomable frames.
- `<wa-data-grid>` additions — Pro, experimental, JS-supplied data.
- `with-label` on `<wa-dialog>` / `<wa-drawer>` and `with-description` /
  `with-label` on `<wa-step>` / `<wa-divider>` — SSR hints that tell the server
  render a slot is populated. We render client-side, so WA detects the slots itself.

---

## Web Awesome 3.12.0 audit — done

_Repos: all six_

WA **3.12.0** (August 2026) was audited against the whole ecosystem. The manifest
fixture was refreshed in both engines (`rake wa:manifest[3.12.0]` /
`npm run update-wa-manifest 3.12.0`, `WA_VERSION` → `3.12.0`) and the enum diff is
**one additive line**: `wa-dropdown-item` gained a `target` enum
(`_blank`/`_parent`/`_self`/`_top`) to go with its new `href`/`rel`/`download`
navigation attributes. **Zero DRIFT, zero GAP** — no transformer enum constant
changed.

**Nothing in 3.12.0 asks for new Markawesome syntax.** Both of its component-level
additions land on components that are already *Explicitly out of scope* below:
`<wa-dropdown-item>` (dropdowns need JS-driven open/close state) and
`<wa-data-grid>`'s new `filterOptions` column option (Pro, experimental, driven
entirely by JS-supplied data). The remaining "Added" item is the Figma Design Kit.
Every 3.12.0 *Fixed* and *Changed* entry is internal to Web Awesome's own shadow
DOM — no markup we emit has to change to benefit.

**What we get for free** by moving the pins:

- **`<wa-button>` keeps its accessible name while loading, and gains `aria-busy`.**
  Both engines already accept a bare `loading` token, so every `loading` button we
  emit becomes correctly announced with no engine change.
- **Duplicate landmarks removed from `<wa-card>`, `<wa-dialog>` and `<wa-drawer>`** —
  three elements the engines emit directly.
- **`<wa-tooltip>` light dismiss** behaves better on target presses and page clicks.

**What did change here:**

- **Example-site CDN pins bumped to 3.12.0** in `jekyll-webawesome` and
  `eleventy-plugin-webawesome`, with the docs/skill pin references following.

Still outstanding: refresh the vendored WA Agent Skill under `.claude/skills/` to
the 3.12.0 copy shipped in `@awesome.me/webawesome-pro` (its `skills-lock.json`
hash is maintained by the installer, not by hand).

---

## Web Awesome 3.11.0 audit — done

_Repos: all six_

WA **3.11.0** (July 30th, 2026) was audited against the whole ecosystem. The
manifest fixture was refreshed in both engines (`rake wa:manifest[3.11.0]` /
`npm run update-wa-manifest 3.11.0`, `WA_VERSION` → `3.11.0`) and the diff was
**purely additive** — four new tags, **zero DRIFT and zero GAP** — so no
transformer enum constant changed. Verified separately: `IconAttributes` still
matches WA's `IconAnimation`/`IconCanvas` exactly, and every slot the engines
emit (`footer`, `icon`, `summary`) plus the `<wa-page>` slots the example shells
use still exist.

**What did change:**

- **`::part(base)` → `::part(base), ::part(button)`** in the image-dialog trigger
  styling, in both engines. 3.11.0 gives every component a part named after itself
  and softly deprecates the generic `base` part; WA's manifest now marks `wa-button`'s
  `base` as *"Deprecated. Use the `button` part instead."* We emit both selectors so
  the trigger stays chrome-less on 3.10-pinned sites (no `button` part) and on 3.11+
  sites once `base` is dropped. Previously untested in either engine; now locked by
  specs/tests on both sides.
- **Example-site CDN pins bumped to 3.11.0** in `jekyll-webawesome` and
  `eleventy-plugin-webawesome`, with the docs/skill pin references following.

### `<wa-pagination>` — considered, then rejected

_Repos: none — no code planned_

`<wa-pagination>` (experimental, 3.11.0) was the one new 3.11.0 component that looked
like a fit: its **`href-template`** attribute renders each page control as a real `<a>`,
so it works with zero authored JavaScript — the bar the rest of the engine meets. It was
carried as a planned item for a while. On closer analysis it is **not worth a
transformer**, for three reasons, weakest first:

1. **The control belongs in a layout, not a page body.** Paginating posts, docs or
   products puts the markup in `_layouts/blog.html` (or an Eleventy layout). The Jekyll
   hook has a `markdown_file?` guard — we only ever touch `.md` — so for the common case
   our transformer is structurally unreachable.
2. **The transform would be an identity function.** Every other transformer earns its
   keep: `:::wa-callout` slots an icon, converts inner Markdown, applies configured
   defaults. Pagination has no inner content, no slots to fill and no icon lookup — it is
   a 1:1 attribute rename onto a void element. The shorthand comes out *longer* than the
   HTML it replaces (two lines vs one).
3. **It already works with no code from us.** Verified against both host converters: a
   raw `<wa-pagination …></wa-pagination>` passes through Kramdown untouched and through
   markdown-it wrapped in a `<p>` (harmless — the `<nav>` is in the shadow root). Authors
   on both integrations can use the component today; a transformer would compete with
   something that already functions.

Also weighing against it: without `href-template` the component emits a `wa-page-change`
event and needs a listener, which is out of scope; and it is **experimental**, so its API
may still move.

**What actually paginates what** — recorded so it isn't re-derived. Eleventy's
`pagination` front matter is fully generic and chunks any array (a collection *or* a
`_data/rows.json`), so splitting a 1000-row table across real URLs is native there, with
the data living in JSON/CSV rather than Markdown. Jekyll has no equivalent:
`jekyll-paginate` handles posts only, `jekyll-paginate-v2` handles collections, and
arbitrary data rows need a custom generator plugin. `{% include table.md %}` does not
help — Jekyll fires `:pre_render` at `renderer.rb:61` and only calls `render_liquid` at
line 80, so included content is Kramdown-converted but never Markawesome-transformed.

**If anything is ever built here**, it belongs in `markawesome-skill` as an authoring
recipe (the Eleventy data-file pattern; "write it in your layout" for Jekyll), not as
syntax in the engines.

### Considered but out of scope (3.11.0)

- `<wa-toast>` / `<wa-toast-item>` moving **Pro → Core** — good news for consumers
  (stackable notifications are now free), but toasts are created imperatively via
  `.create()`; nothing to author in Markdown.
- `<wa-otp-input>` — a form control, out of scope per the list at the bottom of this
  file. `<wa-data-grid>` — Pro, experimental, and driven entirely by JS-supplied data.
- `<wa-carousel>` `addSlide()` / `removeSlide()` — imperative methods for live data;
  our carousel is authored from static slides.
- `<wa-include src="#my-id">` (include a single element by id) — there is no include
  transformer to extend, and includes are the host SSG's job.
- Default `<table>` styles dropping `font-variant-numeric: tabular-nums` (now opt-in
  via the `wa-tabular-nums` class) — no repo relied on it. Worth knowing if a site's
  numeric Markdown tables suddenly look less aligned; the fix is a class on the host's
  own table styling, not engine output.

---

## Web Awesome 3.10.0 uptake — done (shipped)

_Captured from the [Web Awesome changelog](https://webawesome.com/docs/resources/changelog)
for releases **after 3.9.0** (which we've already fully addressed — see the "done"
audit below). The relevant post-3.9.0 surface is **3.10.0** (June 30th, 2026): one
new static-safe component and a batch of new `<wa-icon>` attributes/values. **Both
items below shipped** in markawesome **0.18.0** (2026-07-04) and its sibling releases
across the engines + editor, and are reflected in the integration example sites. The
other post-3.8.0 additions are form controls or interactive/selection features and stay
out of scope (see the note at the end of this section)._

### 3. New component: `<wa-random-content>` (rotating / random content) — done

_Repos: `markawesome`, `markawesome-js`, `markawesome-vscode`_

Shipped as `RandomContentTransformer` (and its `markawesome-js` mirror + VS Code
tooling). `<wa-random-content>` (added in WA 3.10.0, stable since 3.13.0) "randomly shows
one or more of its children — handy for rotating testimonials, tips, or featured
content." It is a **great fit for static sites**: it adds a genuine dynamic feel
with **zero JavaScript wiring from the author** — the component picks its
child(ren) on its own, and (with `autoplay`) can rotate them client-side.

The declarative surface (`mode`, `items`, `animation`, `autoplay`,
`autoplay-interval`) and the final shorthand — a `......` outer fence with `>>>`
option separators, each option wrapped in a single `<div>` so WA sees exactly one
selectable element child — are documented in each engine's `CHANGELOG.md` 0.18.0
entry.

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
  `switch`, `slider`, `rating`, `color-picker`, date/time pickers, `combobox`,
  `tag-input`
- All chart types
- `dropdown`, `drawer`, `dialog`-as-app-modal beyond our current usage
- Toasts/notifications, `mutation-observer` / `resize-observer`, `page`,
  `markdown` (we *are* the Markdown layer)
