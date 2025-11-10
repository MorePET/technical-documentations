# Changelog

All notable changes to this template will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0-dev]

### Added

### Changed

### Fixed

## [0.3.0]

### Added

- **Development Server**
  - Node.js and live-server integration for better development experience
  - Automatic setup in devcontainer via `setup-node-liveserver.sh`
  - Smart fallback to Python server if live-server unavailable
  - Auto-reload on file changes with live-server
  - Better concurrent request handling and no Content-Length mismatch issues

- **Cache-Busting**
  - Automatic timestamp-based cache-busting for CSS files
  - Uses file modification time for efficient browser cache invalidation
  - Applies to both `colors.css` and `styles-bootstrap.css`

- **Python Documentation Generation**
  - Self-contained documentation generator using griffe for API extraction
  - Automatic API reference generation from Python source code
  - Test coverage and test results integration
  - Comprehensive example project demonstrating V-Model development lifecycle
  - Support for Google-style docstrings with structured parsing

- **Enhanced Documentation Examples**
  - Complete product documentation suite following V-Model structure
  - Stakeholder analysis matrices with multiple data sources (manual, CSV, JSON, YAML)
  - Technical diagrams with Fletcher (architecture, data flow, state machines)
  - Implementation examples with CLI tools
  - Integrated API documentation with narrative content

- **Typst Library Enhancements**
  - Checklist support with customizable icons
  - Expanded technical documentation package
  - Theme-aware diagram support with automatic color switching

- **Bootstrap Styling Support**
  - Bootstrap 5.3.2 integration for HTML output
  - New `build-html-bootstrap.py` script for complete Bootstrap workflow
  - `add-styling-bootstrap.py` for adding Bootstrap CDN links and components
  - `add-bootstrap-classes.py` for automatic class application to HTML elements
  - Bootstrap-compatible theme toggle (light/dark/auto modes)
  - Bootstrap Offcanvas TOC sidebar for navigation
  - Responsive mobile-first design with Bootstrap grid
  - Custom `styles-bootstrap.css` for Typst-specific enhancements

- **Makefile Targets**
  - `make html-bootstrap` - Build HTML with Bootstrap styling
  - `make example-bootstrap` - Build example with Bootstrap styling
  - `make python-api` - Generate Python API documentation
  - `make python-tests` - Run tests and generate coverage reports
  - `make python-diagrams` - Compile project-specific diagrams

### Changed

- **Build System Restructuring**
  - All build outputs now use `build/` directories instead of `out/`
  - Consolidated diagram outputs to project-specific build directories
  - Simplified gitignore patterns for build artifacts
  - Updated all include paths to reference build directories
  - Unified example and main build processes to use same pipeline (colors → diagrams → pdf → html)
  - Example project outputs now in dedicated `example/build/` folder

- **Documentation Migration**
  - Migrated all documentation from Markdown to Typst format
  - Replaced markdown docs with comprehensive Typst documentation
  - Enhanced example project with complete technical documentation suite

- **HTML Processing**
  - Build scripts now support both custom CSS and Bootstrap workflows
  - Theme toggle adapted to work with Bootstrap's `data-bs-theme` attribute
  - TOC sidebar uses Bootstrap Offcanvas component for better mobile support
  - Improved regex patterns for SVG injection to prevent content deletion

- **Typst Library Enhancements**
  - Isotope and beta particle notation now uses Unicode superscripts/subscripts in HTML export
  - Better accessibility with native Unicode text instead of SVG fragments
  - Smaller HTML file sizes with improved text selection and copy/paste support
  - PDF export unchanged (still uses physica package for proper typesetting)

### Fixed

- **Table Column Widths**
  - Fixed 2-column tables not expanding Description column to full width
  - Changed System Components table from `columns: (auto, auto)` to `columns: (auto, 1fr)`
  - Added CSS override for 2-column tables to allow second column expansion

- **HTTP Server Issues**
  - Resolved Content-Length mismatch errors with Python's http.server
  - Replaced basic http.server with ThreadingHTTPServer for better stability
  - Added proper CORS and Cache-Control headers for development

- **Dark Mode Support**
  - Fixed dark mode text color in Fletcher diagrams (text now uses theme-aware colors)
  - Fixed white backgrounds in diagrams by setting transparent page fills
  - Removed gradient backgrounds that appeared incorrectly in dark mode

- **HTML Post-Processing**
  - Fixed critical regex bug that was deleting large sections of HTML content
  - Fixed duplicate figure rendering in HTML exports
  - Improved pattern matching to handle base64 data URI images correctly

- **Python Import Issues**
  - Fixed runpy warnings by using lazy imports in documentation generator

## [0.2.0] - 2025-01-09

### Added

- **Commit Standards Enforcement**
  - Gitlint integration for conventional commit validation
  - Required scopes with defined allowed list (20 scopes)
  - Automatic commit message linting in pre-commit hooks

- **GitHub Workflow Automation**
  - CodeQL analysis workflow for security scanning
  - Automated dependency management with Renovate (split into 3 specialized workflows)
  - Centralized GitHub Actions workflow templates
  - Issue and PR template synchronization
  - Auto-merge setup for dependency updates

- **Documentation Standards**
  - GitHub issue templates with proper formatting
  - Pull request templates and guidelines
  - Enhanced git workflow documentation with scope guidelines
  - Commit command documentation with examples

- **Development Dependencies**
  - Arrow package for date/time handling

### Changed

- **Documentation Style**
  - Replaced emoji checkmarks with standard markdown checkboxes
  - Enforced no-emoji style for professional documentation
  - Updated commit examples with required scopes

- **Configuration**
  - Removed redundant scopes to avoid type/scope overlap
  - Improved devcontainer image monitoring flexibility
  - Enhanced security update handling

## [0.1.0] - 2025-01-06

### Added

- **Dev Container Setup**
  - Automatic GitHub CLI authentication via host token extraction
  - Secure token passing through environment variables (no disk writes)
  - SSH key and git configuration synchronization from host
  - Comprehensive dev container documentation
  - Support for both Docker and Podman container runtimes

- **Development Tools**
  - Pre-commit hooks with multiple linters (ruff, shellcheck, pymarkdown, yamllint, checkmake)
  - Ruff Python linter and formatter via uv
  - Automatic code formatting and validation
  - Git hooks for maintaining code quality

- **Documentation**
  - Complete dev container setup guide with troubleshooting
  - GitHub CLI authentication documentation
  - Build system documentation
  - Dark mode color standards guide
  - Linter and pre-commit guide

- **Build System**
  - Typst technical documentation template
  - Automated diagram compilation (architecture, data-flow, state-machine)
  - HTML and PDF generation from Typst sources
  - Color palette system with light/dark mode support
  - Live server for development preview

- **Security**
  - GitHub tokens never written to disk (environment variables only)
  - Proper `.gitignore` patterns for sensitive files and macOS system files
  - SSH key permissions and validation

[Unreleased]: https://github.com/MorePET/technical-documentations/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/MorePET/technical-documentations/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/MorePET/technical-documentations/releases/tag/v0.1.0
