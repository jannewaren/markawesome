# Roadmap

This is the **shared roadmap for the whole Markawesome ecosystem** — the five
repositories that must stay in lockstep (`markawesome`, `markawesome-js`,
`jekyll-webawesome`, `eleventy-plugin-webawesome`, `markawesome-vscode`; see
`CLAUDE.md`). Each item below is tagged with the repo(s) it touches. Shipped
history lives in each repo's `CHANGELOG.md`.

---

## Planned — cross-project

### 1. Pin the Web Awesome version via CDN in the example sites, drop the kit

_Repos: `jekyll-webawesome`, `eleventy-plugin-webawesome`_

Both example sites currently load Web Awesome through an opaque hosted **kit**
(`<script src="https://kit.webawesome.com/43e2fc18755d4267.js">` in
`jekyll-webawesome/examples/_layouts/default.html` and
`eleventy-plugin-webawesome/examples/_includes/base.njk`). The kit URL hides
which WA version it serves, so the rendered version drifts silently and
validation isn't reproducible — a point already called out in `CLAUDE.md`'s
release workflow.

Web Awesome's current recommendation is a **CDN include with the version pinned**
in the URL. Switch both example layouts to the pinned-version CDN so the WA
version is explicit and deterministic, and drop the kit script. Bump the pinned
version deliberately when validating against a new WA release.

### 2. Reach engine parity + add a reverse mode in `markawesome-js`

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

### 3. Add an "annotate with explanatory comments" mode to `markawesome-vscode`

_Repo: `markawesome-vscode`_

A command/mode that inserts a short explanatory Markdown comment above each
Markawesome element, so a reader **without** the extension (or any prior
knowledge) understands what the shorthand does — e.g. a comment noting that the
syntax translates into a `<wa-callout>` with a `<wa-icon>` slotted in. The
human-readable descriptions already exist in `src/data/components.json` (surfaced
today by `hoverProvider`), so the mode can reuse them; it fits alongside the
existing commands in `src/commands/transformCommands.ts`.

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
