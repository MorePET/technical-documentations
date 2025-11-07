# Changelog

All notable changes to this template will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Python Documentation Generation**
  - Automated extraction of Python docstrings (module, class, function level)
  - Support for Google-style docstring format (Args, Returns, Raises)
  - Type annotation capture from function signatures
  - Dual output formats: JSON and Typst
  - Integration with Makefile build pipeline (`make python-docs`)
  - Beautiful formatted documentation blocks in Typst
  - Example project demonstrating Python API documentation
  - Comprehensive documentation in `docs/PYTHON_DOCS_GENERATION.md`
  - New script: `scripts/build-python-docs.py`
  - Demo document: `example/python-docs-demo.typ`

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

[Unreleased]: https://github.com/MorePET/technical-documentations/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/MorePET/technical-documentations/releases/tag/v0.1.0
