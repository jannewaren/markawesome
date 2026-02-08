# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
