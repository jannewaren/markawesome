# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
