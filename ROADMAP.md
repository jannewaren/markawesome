# Roadmap

Future improvements for markawesome, captured from an audit of our generated
markup against [Web Awesome](https://webawesome.com/) **3.9.0** (latest as of
June 2026).

These are **enhancements, not bugs** — the markup we emit today is valid 3.x.
Everything below is backward-compatible and static-site-safe: no JavaScript,
data fetching, or form wiring required. Each item maps to a declarative Web
Awesome attribute or component that fits a "content comes from a static
Markdown file" model.

> The **"missing declarative attributes" audit against WA 3.9.0 is fully
> addressed** — every component we transform now surfaces the declarative
> attributes WA exposes for it. The `tree` component has landed (see
> `CHANGELOG.md` `[Unreleased]`), so what remains below is a single
> documentation task. (Shipped history lives in `CHANGELOG.md`.)

---

## Documentation task

`<wa-tag>` with `with-remove` renders a remove button that **does nothing**
without a JavaScript `wa-remove` listener — a dead end on a static site. We
should document this (or omit `with-remove` from the static-safe surface)
rather than imply it works.

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
