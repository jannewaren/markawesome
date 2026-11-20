# Markawesome

A framework-agnostic Ruby library that transforms custom Markdown syntax into [Web Awesome](https://webawesome.com/) HTML components. Use it with Jekyll, Hugo, Middleman, or any static site generator that processes Markdown.

Used as the transformation engine for the [jekyll-webawesome](https://github.com/jannewaren/jekyll-webawesome) plugin.

> **🔗 See it live — [hosted examples site](https://jannewaren.github.io/jekyll-webawesome/).** Every supported component shown side by side: the Markawesome markdown on the left, the live Web Awesome component it renders on the right. The clearest way to see what this project does.

## Features

- 🎯 **Framework Agnostic** - Works with any static site generator or Ruby application
- 🚀 **Simple Syntax** - Clean, intuitive Markdown extensions
- ⚙️ **Configurable** - Customize icons, variants, and component behavior

## Supported Components

| Component | Primary Syntax | Alternative Syntax | HTML Output |
|-----------|----------------|-------------------|-------------|
| **Accordion** | `//////params?` with `/// Title` items | `:::wa-accordion params?` | `<wa-accordion>` of `<wa-accordion-item label="…">` sections |
| **Badge** | `!!!variant` | `:::wa-badge variant` | `<wa-badge variant="brand">content</wa-badge>` |
| **Button** | `%%%variant` | `:::wa-button variant` | `<wa-button variant="brand" href="url">text</wa-button>` or `<wa-button variant="brand">text</wa-button>` |
| **Callout** | `:::info` | `:::wa-callout info` | `<wa-callout variant="brand"><wa-icon ...></wa-icon>content</wa-callout>` |
| **Card** | `===` | `:::wa-card` | `<wa-card>content</wa-card>` |
| **Carousel** | `~~~~~~` | `:::wa-carousel` | `<wa-carousel>` with carousel items |
| **Comparison** | `\|\|\|` or `\|\|\|25` | `:::wa-comparison` or `:::wa-comparison 25` | `<wa-comparison>` with before/after slots |
| **Copy Button** | `<<<placement? tooltip:full\|copy\|none?` | `:::wa-copy-button placement? tooltip:full\|copy\|none?` | `<wa-copy-button value="content" tooltip-placement="top" tooltip="copy"></wa-copy-button>` |
| **Counter** | `[[[ date countdown\|countup params? ]]]` | `:::wa-counter date params?` (empty body) | `<wa-counter date="2026-12-24" direction="up"></wa-counter>` |
| **Details** | `^^^appearance? icon-placement?` | `:::wa-details appearance? icon-placement?` | `<wa-details>content</wa-details>` |
| **Dialog** | `???params?` | `:::wa-dialog params?` | `<wa-dialog>` with trigger button and content |
| **Divider** | `--- label ---` (e.g. `--- start icon:star New ---`) | `:::wa-divider params?` (body is the label) | `<wa-divider label-placement="start"><wa-icon name="star"></wa-icon> New</wa-divider>` |
| **Format Date** | `[[[2026-06-26 style:long]]]` | `:::wa-format-date date params?` (empty body) | `<wa-format-date date="2026-06-26" year="numeric" month="long" day="numeric"></wa-format-date>` |
| **Icon** | `$$$icon-name` | `:::wa-icon icon-name` | `<wa-icon name="icon-name"></wa-icon>` |
| **Image Dialog** | `![alt](url)` | — | Wraps images in clickable `<wa-dialog>` overlays |
| **Lightbox** | `::::lightbox params?` wrapping image lines | `:::wa-lightbox params?` | `<wa-lightbox class="wa-grid"><wa-lightbox-item src="full.jpg" caption="…"><img …></wa-lightbox-item>…</wa-lightbox>` |
| **Number Ticker** | `[[[ number params? ]]]` (e.g. `[[[ 87% ]]]`) | `:::wa-number-ticker number params?` (empty body) | `<wa-number-ticker value="0.87" type="percent"></wa-number-ticker>` |
| **Popover** | `&&&params?` or inline `&&&trigger >>> content&&&` | `:::wa-popover params?` | `<wa-popover>` with trigger button and content |
| **Random Content** | `......params?` with `>>>`-separated options | `:::wa-random-content params?` | `<wa-random-content>` showing a random/rotating subset of its options |
| **Relative Time** | `[[[relative 2026-06-20]]]` | `:::wa-relative-time date params?` (empty body) | `<wa-relative-time date="2026-06-20"></wa-relative-time>` |
| **Stepper** | `>>>>>> params?` wrapping a task list | `:::wa-stepper params?` | `<wa-stepper active="step-2"><wa-step name="step-1" completed>…</wa-step>…</wa-stepper>` |
| **Tab Group** | `++++++` | `:::wa-tabs` | `<wa-tab-group><wa-tab>content</wa-tab></wa-tab-group>` |
| **Tag** | `@@@brand` | `:::wa-tag brand` | `<wa-tag variant="brand">content</wa-tag>` |
| **Tooltip** | `(((anchor >>> tip)))` | `:::wa-tooltip placement? distance:N?` | focusable `<span>` anchor + `<wa-tooltip for="…" placement="top">tip</wa-tooltip>` |
| **Tree** | `\|\|\|\|\|\|open?` wrapping a nested bullet list | `:::wa-tree open?` | `<wa-tree>` of nested `<wa-tree-item>`s |
| **Video** | `;;;params?` with a link + optional poster image | `:::wa-video params?` | `<wa-video>` (Web Awesome Pro) |
| **Video Playlist** | `;;;;;;params?` wrapping `;;;` videos | `:::wa-video-playlist params?` | `<wa-video-playlist>` (Web Awesome Pro) |

> **Note on `<wa-tag>` `with-remove`:** the `with-remove` attribute renders a
> remove (×) button, but Web Awesome only *fires* a `wa-remove` event — it does
> not remove the tag for you. On a page with no JavaScript beyond the Web Awesome
> library, the button is inert. To make it functional, add your own `wa-remove`
> listener (e.g. a single global handler that removes `event.target`). The markup
> we emit is valid either way.

> **Labeled divider:** `--- label ---` needs text between the mirrored dashes,
> so a plain `---` stays an `<hr>`. Leading `start`/`center`/`end`
> (label placement), `horizontal`/`vertical` (orientation) and `icon:name`
> tokens are consumed from the left; the rest is the label, as inline Markdown.
> A line made only of `|`, `:` and `-` (a pipe-less table separator) is left
> alone. Use `:::wa-divider` when a label must start with one of those words.

> **Stepper (display-only):** each unindented list line is a step. `[x]` marks
> it completed; leading `active`, `loading`, `disabled`, a variant, an attention
> (`pulse`/`bounce`/`none`) and `icon:name` are flags; lines indented under a
> step become its description. The active step is the one flagged `active`,
> else the first incomplete step, else the last. Container params are
> `horizontal`/`vertical`/`auto` and `label:"…"`. `wa-stepper` is stable as of
> Web Awesome 3.15.0; its interactive features (`clickable`, `linear`) are
> deliberately not exposed.

> **Lightbox:** each body line is an item — `![alt](src "caption")`, or a
> linked image `[![alt](thumb)](full "caption")` for a separate full-size file;
> a video extension (`.mp4`, `.webm`, `.mov`, `.ogv`, `.m4v`) makes it
> `type="video"`. Other lines are rendered as Markdown in place. The gallery is a
> `wa-grid` (`gap:`, `min:`, `align:`, `justify:`); flags are `loop`,
> `thumbnails`, `no-nav`, `no-counter`, `no-zoom` and `label:"…"`; thumbnails
> are square-cropped unless `landscape`, `portrait` or `natural`. Every item's
> `src` is a real link, so the gallery degrades to links without JavaScript.
> Experimental in Web Awesome 3.15.0.

> **Counter and number ticker:** both share the `[[[ … ]]]` date syntax. A
> `countdown`/`countup` token makes a `<wa-counter>` (`largest:`/`smallest:`
> units, `format:short|narrow`, `no-labels`, `delimiter:"…"`, `label:"…"`,
> `finished:"…"`, `lang:`); a leading number makes a `<wa-number-ticker>`
> (`87%` → `type="percent" value="0.87"`, `currency:EUR`, `display:`, `from:`,
> `duration:`, `delay:`, `easing:`, `eager`, `no-grouping`, `decimals:N`,
> `lang:`). Quote values with spaces: `key:"…"`. Like dates, both render into
> shadow DOM and show nothing without Web Awesome's JavaScript. Experimental in
> Web Awesome 3.15.0.

## Layout Utilities

Layout utilities use `::::` (quadruple colon) syntax to wrap content in CSS layout containers. Inner content is not markdown-converted, so component `:::` syntax inside layouts works normally.

| Layout | Primary Syntax | Alternative Syntax | HTML Output |
|--------|----------------|-------------------|-------------|
| **Grid** | `::::grid` | `::::wa-grid` | `<div class="wa-grid">content</div>` |
| **Stack** | `::::stack` | `::::wa-stack` | `<div class="wa-stack">content</div>` |
| **Cluster** | `::::cluster` | `::::wa-cluster` | `<div class="wa-cluster">content</div>` |
| **Split** | `::::split` | `::::wa-split` | `<div class="wa-split">content</div>` |
| **Flank** | `::::flank` | `::::wa-flank` | `<div class="wa-flank">content</div>` |
| **Frame** | `::::frame` | `::::wa-frame` | `<div class="wa-frame">content</div>` |

### Common layout attributes

All layouts support these key:value attributes:

- `gap:SIZE` — Sets spacing (`0`, `3xs`, `2xs`, `xs`, `s`, `m`, `l`, `xl`, `2xl`, `3xl`, `4xl`, `5xl`)
- `align:VALUE` — Align items (`start`, `end`, `center`, `stretch`, `baseline`)
- `justify:VALUE` — Justify content (`start`, `end`, `center`, `space-between`, `space-around`, `space-evenly`)

### Layout-specific attributes

- **Grid**: `min:CSS_VALUE` — Minimum column size (e.g., `min:200px`)
- **Split**: `row` or `column` — Direction modifier
- **Flank**: `start` or `end` — Position modifier; `size:CSS_VALUE`, `content:PCT`
- **Frame**: `landscape`, `portrait`, or `square` — Aspect ratio; `radius:SIZE` (`s`, `m`, `l`, `pill`, `circle`, `square`)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'markawesome'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install markawesome
```

## Usage

### Basic Usage

```ruby
require 'markawesome'

markdown = <<~MD
  !!!brand
  New Feature
  !!!

  :::info
  This is an informational callout
  :::
MD

html = Markawesome::Transformer.process(markdown)
```

### Configuration

Configure Markawesome globally to customize icon names and add custom components:

```ruby
Markawesome.configure do |config|
  # Customize callout icons
  config.callout_icons = {
    info: 'circle-info',
    success: 'circle-check',
    neutral: 'gear',
    warning: 'triangle-exclamation',
    danger: 'circle-exclamation'
  }

  # Add custom components (for future extensibility)
  config.custom_components = {
    'my-component' => 'MyComponent'
  }
end
```

### Image Dialog Feature

Transform images into clickable dialogs:

```ruby
markdown = '![Diagram](diagram.png)'

# Enable image dialog transformation
html = Markawesome::Transformer.process(markdown, image_dialog: true)

# Or with configuration
html = Markawesome::Transformer.process(markdown, image_dialog: { default_width: '80vw' })
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jannewaren/markawesome.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
