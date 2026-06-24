# Roadmap

Future improvements for markawesome, captured from an audit of our generated
markup against [Web Awesome](https://webawesome.com/) **3.9.0** (latest as of
June 2026). The 3.8.0 → 3.9.0 release added no new attributes or values to any
component we currently emit — it was dominated by SSR plumbing, form controls
(out of scope), and bug fixes — so nothing in it requires a markup change here.
The two notes below flag where 3.9.0 touches items already on this backlog.

These are **enhancements, not bugs** — the markup we emit today is valid 3.x.
Everything below is backward-compatible and static-site-safe: no JavaScript,
data fetching, or form wiring required. Each item maps to a declarative Web
Awesome attribute or component that fits a "content comes from a static
Markdown file" model.

Items are roughly ordered by value within each section. Nothing here is
committed work — it's a prioritized backlog to pull from.

---

## Existing components — missing declarative attributes

These are components we already transform, but where Web Awesome exposes
attributes we don't yet surface in our Markdown syntax.

### `icon` — surface `animation`, `family`, `variant`, `label` *(biggest single gap)*

Our icon transformer only emits `name`. Web Awesome's `<wa-icon>` supports
several declarative attributes we never expose:

- **`animation`** (added in WA 3.2) — `spin`, `beat`, `fade`, `bounce`,
  `flip`, `pulse`, etc. Pure CSS animation, ideal for static "loading"-style
  or attention-drawing icons.
- **`family`** — selects the icon family (e.g. `classic`, `sharp`, `duotone`,
  `brands`). Without it authors are locked to the default family.
- **`variant`** — Pro weights (`thin`, `light`, `regular`, `solid`). We
  hard-code `variant="solid"` in some callers but never let authors choose.
- **`label`** — accessible label for standalone meaningful icons (a11y). When
  absent, screen readers get nothing useful.

**Why first:** highest leverage. Icons appear inside callouts, buttons, tags,
badges and on their own, so a richer icon syntax pays off everywhere.

### `copy-button` — `tooltip`

WA 3.6 refactored `<wa-copy-button>` onto a real internal button and added a
**`tooltip`** attribute: `full` (label + tooltip), `copy` (tooltip only),
`none`. We should expose this so authors can control the hover affordance.

### `popover` — aligned placements + `skidding`

`<wa-popover>` supports edge-aligned placements beyond the basic
`top`/`bottom`/`left`/`right`: **`top-start`, `top-end`, `bottom-start`,
`bottom-end`, `left-start`, …** plus a **`skidding`** offset along the
anchor. We currently only accept the four primary placements. Adding the
aligned variants gives finer control with no behavioral change.

### `tabs` — per-tab `disabled`

`<wa-tab>` accepts a **`disabled`** attribute (e.g. a "coming soon" tab that
renders but can't be activated). Our tab syntax has no way to mark an
individual tab disabled.

---

## New components worth adding

Recent Web Awesome components that genuinely fit Markdown authoring — declarative,
content-driven, no JS glue needed.

### ~~1. `accordion` / `accordion-item`~~ — ✅ shipped in 0.14.0

Multi-section collapsible container (WA 3.7) — the natural fit for FAQs, docs
sections, and "show more" content. The grouped, mutually-exclusive-capable
sibling of `details`. Shipped in markawesome **0.14.0** as `AccordionTransformer`:
`//////` container fence / `///` item fence (or the `:::wa-accordion` alternative),
with `appearance`/`mode`/`icon-placement`/`heading:N` container tokens and
`expanded`/`disabled`/`icon:` item flags. Still **experimental** in WA, but the
attributes we emit are all declarative and static-safe.

> _3.9.0 note:_ 3.9.0 fixed an accordion/accordion-item SSR hydration race
> (irrelevant to a static Jekyll build) and **removed the
> `--wa-accordion-divider-color` custom property** — we deliberately do not
> expose a divider-color attribute, it's no longer a supported knob.

### 2. `tooltip`

Inline contextual help on hover/focus. Zero JavaScript, and we can
auto-generate the `for`/`id` wiring between the tooltip and its anchor so
authors just write the trigger and the tip text. Great for glossary terms and
inline definitions.

### 3. `video` / `video-playlist`

Added in WA 3.6/3.7 (Pro). Declarative, accessible media embedding — a clean
upgrade over raw `<iframe>`/`<video>` in Markdown. The Pro package is already
installed in the `kaikuu` site, so the components are available there.

### 4. `format-date` / `relative-time`

Declarative timestamp rendering: absolute formatted dates and
"3 days ago"-style relative times. Perfect for blog post dates, changelog
entries, and "last updated" stamps driven by a static date value in the
Markdown.

### 5. `tree`

Hierarchical list rendering for file/directory layouts, taxonomies, and nested
navigation. Maps cleanly from nested Markdown lists to `<wa-tree>` /
`<wa-tree-item>`.

> _3.9.0 note:_ added a `leaf-multiple` value to `<wa-tree selection>`. Tree
> selection is interactive (needs JS to mean anything), so for static docs we'd
> emit `<wa-tree>` for display/navigation only and skip the selection modes.

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

### Known static-site caveat

`<wa-tag>` with `with-remove` renders a remove button that **does nothing**
without a JavaScript `wa-remove` listener — a dead end on a static site. We
should document this (or omit `with-remove` from the static-safe surface)
rather than imply it works.
