# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Markawesome is a framework-agnostic Ruby gem that transforms custom Markdown syntax into [Web Awesome](https://webawesome.com/) HTML components (`<wa-callout>`, `<wa-button>`, `<wa-badge>`, etc.). It serves as the transformation engine for the [jekyll-webawesome](https://github.com/jannewaren/jekyll-webawesome) plugin but can be used with any static site generator.

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
