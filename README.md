# Markawesome

A framework-agnostic Ruby library that transforms custom Markdown syntax into [Web Awesome](https://webawesome.com/) HTML components. Use it with Jekyll, Hugo, Middleman, or any static site generator that processes Markdown.

Used as the transformation engine for the [jekyll-webawesome](https://github.com/jannewaren/jekyll-webawesome) plugin.

## Features

- 🎯 **Framework Agnostic** - Works with any static site generator or Ruby application
- 🚀 **Simple Syntax** - Clean, intuitive Markdown extensions
- ⚙️ **Configurable** - Customize icons, variants, and component behavior

## Supported Components

| Component | Primary Syntax | Alternative Syntax | HTML Output |
|-----------|----------------|-------------------|-------------|
| **Badge** | `!!!variant` | `:::wa-badge variant` | `<wa-badge variant="brand">content</wa-badge>` |
| **Button** | `%%%variant` | `:::wa-button variant` | `<wa-button variant="brand" href="url">text</wa-button>` or `<wa-button variant="brand">text</wa-button>` |
| **Callout** | `:::info` | `:::wa-callout info` | `<wa-callout variant="brand"><wa-icon ...></wa-icon>content</wa-callout>` |
| **Card** | `===` | `:::wa-card` | `<wa-card>content</wa-card>` |
| **Carousel** | `~~~~~~` | `:::wa-carousel` | `<wa-carousel>` with carousel items |
| **Comparison** | `\|\|\|` or `\|\|\|25` | `:::wa-comparison` or `:::wa-comparison 25` | `<wa-comparison>` with before/after slots |
| **Copy Button** | `<<<` | `:::wa-copy-button` | `<wa-copy-button value="content">content</wa-copy-button>` |
| **Details** | `^^^appearance? icon-placement?` | `:::wa-details appearance? icon-placement?` | `<wa-details>content</wa-details>` |
| **Dialog** | `???params?` | `:::wa-dialog params?` | `<wa-dialog>` with trigger button and content |
| **Icon** | `$$$icon-name` | `:::wa-icon icon-name` | `<wa-icon name="icon-name"></wa-icon>` |
| **Image Dialog** | `![alt](url)` | — | Wraps images in clickable `<wa-dialog>` overlays |
| **Tab Group** | `++++++` | `:::wa-tabs` | `<wa-tab-group><wa-tab>content</wa-tab></wa-tab-group>` |
| **Tag** | `@@@brand` | `:::wa-tag brand` | `<wa-tag variant="brand">content</wa-tag>` |

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

- `gap:SIZE` — Sets spacing (`0`, `3xs`, `2xs`, `xs`, `s`, `m`, `l`, `xl`, `2xl`, `3xl`)
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
