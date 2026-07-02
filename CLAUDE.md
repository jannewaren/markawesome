# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Markawesome is a framework-agnostic Ruby gem that transforms custom Markdown syntax into [Web Awesome](https://webawesome.com/) HTML components (`<wa-callout>`, `<wa-button>`, `<wa-badge>`, etc.). It serves as the transformation engine for the [jekyll-webawesome](https://github.com/jannewaren/jekyll-webawesome) plugin but can be used with any static site generator.

## The markawesome ecosystem — keep the syntax in sync

The Markawesome-flavoured Markdown syntax spans **five repositories that must
stay in lockstep**:

| Repo | Role | Stack | Registry |
|------|------|-------|----------|
| `markawesome` | **Authors** the syntax (engine) | Ruby | RubyGems |
| `markawesome-js` | **Authors** the syntax (engine) | TypeScript / Node | npm |
| `jekyll-webawesome` | **Uses** it (Jekyll integration) | Ruby | RubyGems |
| `eleventy-plugin-webawesome` | **Uses** it (Eleventy integration) | Node | npm |
| `markawesome-vscode` | **Produces** it (snippets/completions/validation) | TypeScript | VS Code Marketplace |

**This repo's role:** **authors** the syntax — the Ruby engine. A syntax change may
start here, but must be mirrored in `markawesome-js` (byte-for-byte) and reflected
in `markawesome-vscode`.

**Sync rule:** any change to the Markawesome Markdown syntax must land in **both
engines** (`markawesome` *and* `markawesome-js`) so the Ruby and Node worlds accept
identical input, **and** in `markawesome-vscode` so the editor emits it. The VS Code
extension is shared across both worlds, so it may only produce syntax that **both**
engines support. Confirm the engines still agree via `markawesome-js`'s
`test/parity-corpus.test.ts` plus the Ruby specs in `markawesome/spec/`.

## Commands

```bash
bundle exec rspec                           # Run all tests
bundle exec rspec spec/callout_transformer_spec.rb  # Run a single test file
bundle exec rubocop                         # Lint
bundle exec rake                            # Run both tests and rubocop (default task)
gem build markawesome.gemspec               # Build the gem
```

## Architecture

### Transformation Pipeline

`Markawesome::Transformer.process(content, options)` is the entry point. It runs content through a fixed sequence of transformers, each applied via `gsub` on the full string. Order matters — `ImageDialogTransformer` must run before `DialogTransformer` (controlled by the `image_dialog` option).

### Transformer Pattern

All transformers live in `lib/markawesome/transformers/` and inherit from `BaseTransformer`. The standard pattern:

1. Define a **primary regex** (shorthand symbols like `:::`, `%%%`, `!!!`, `++++++`) and an **alternative regex** (explicit `:::wa-component` syntax)
2. Define a shared `transform_proc` for the HTML output
3. Call `dual_syntax_patterns()` + `apply_multiple_patterns()` from `BaseTransformer`

Inner Markdown content is converted to HTML via `markdown_to_html()` (wraps Kramdown).

### AttributeParser

`lib/markawesome/attribute_parser.rb` — a reusable parser for space-separated attribute tokens with rightmost-wins semantics. Used by `BadgeTransformer` for flexible parameter ordering (e.g., `!!!pill pulse brand`). New transformers that accept multiple unordered parameters should use this.

### Configuration

`Markawesome.configure` allows customizing callout icons and registering custom components. Transformers access config via `Markawesome.configuration`.

## Test Conventions

- Tests are in `spec/`, one file per transformer (`spec/<name>_transformer_spec.rb`)
- Tests call individual transformer `.transform()` methods directly, not the full pipeline
- Uses `expect` syntax only (monkey patching disabled)

## Development & Release Workflow (markawesome + jekyll-webawesome)

markawesome (this transformation engine) and jekyll-webawesome (the Jekyll
integration) are developed together. Component markup changes are made here and
validated end-to-end through jekyll-webawesome's `examples/` site before either
gem is released. Follow this order:

1. **Change markawesome first.** Make the transformer change here, update its
   specs, add a `CHANGELOG.md` entry, and commit.
2. **Use local markawesome from jekyll-webawesome.** Temporarily point
   jekyll-webawesome at this working copy by switching its root `Gemfile` to
   `gem 'markawesome', path: '../markawesome'`, then `bundle install`.
   (jekyll-webawesome's `examples/Gemfile` already uses the local path.)
3. **Add real test cases to the examples site.** Add cases to
   jekyll-webawesome's `examples/index.md` that exercise the change — not
   synthetic snippets, but markup that would visibly break or render wrong
   without it.
4. **Check them visually.** Serve the examples site
   (`cd examples && bundle exec jekyll serve`) and verify the rendered
   components in a browser. Confirm the change actually renders (measure/inspect
   the live DOM), not just that the HTML attribute is present. The Web Awesome
   version is **pinned to 3.9.0** in the CDN URLs in the examples layout
   (`jekyll-webawesome/examples/_layouts/default.html`), so validate against that
   exact version; bump the pin deliberately when moving to a new WA release.
5. **Release markawesome.** Bump `lib/markawesome/version.rb`, finalize the
   CHANGELOG, `gem build markawesome.gemspec`, and `gem push` to RubyGems.
6. **Update the required markawesome version in jekyll-webawesome.** Bump the
   `~> X.Y` constraint in its gemspec, restore its root `Gemfile` from the local
   path back to the published `~> X.Y`, bump its version + CHANGELOG, and commit.
7. **Release jekyll-webawesome.** `gem build` and `gem push` it to RubyGems.

> **Push every release commit to git immediately after `gem push`.** A gem
> published to RubyGems but never pushed to the repo leaves clones diverged: the
> version bump and any code in that release become invisible to other machines,
> and the next release collides on the version number.

## Releases are tagged to match the published version

Every version published to a registry gets a matching **GitHub Release**, so the
repo's releases line up 1:1 with what's installable:

1. Tag the released commit `vX.Y.Z` — the same version as `lib/markawesome/version.rb`.
2. Push the commit and the tag.
3. `gh release create vX.Y.Z` with notes drawn from `CHANGELOG.md`.

The GitHub Release tag **must equal** the version published to RubyGems.
