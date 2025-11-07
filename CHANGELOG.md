# Changelog

All notable changes to this template will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0]

### Added

- **Cursor AI Integration**
  - Complete workflow automation with commands for git, PRs, releases, and issues
  - `/git-commit` command for automated conventional commits
  - `/create-pr` command for pull request creation
  - `/create-release` command for release management
  - `/create-issue` command for issue creation with templates
  - Comprehensive documentation for all cursor commands

- **Python Example Project**
  - Example project demonstrating Typst documentation pipeline integration
  - Python script integration with documentation generation
  - Closes #2 (Python example doc generation)

- **Enhanced Automation**
  - Renovate split into 3 specialized workflows (external deps, internal deps, containers)
  - CodeQL analysis workflow for security scanning
  - Centralized GitHub Actions workflow templates
  - Improved CI/CD pipeline configuration

- **Issue & PR Management**
  - Migration from labels to GitHub native issue types (Bug/Feature/Task)
  - Enhanced issue templates with clear categorization
  - Improved pull request templates and guidelines
  - Comprehensive git workflow documentation

- **Documentation Improvements**
  - Language-specific rules (Python, Typst)
  - Git workflow and GitHub Actions documentation
  - Setup repository command for new projects
  - Enhanced markdown documentation with proper formatting

### Fixed

- Markdown linter issues across all documentation files
- YAML linter issues in GitHub workflow files
- Typst pre-commit hook now uses correct project root
- Line length and formatting issues in documentation
- Nested code block handling in markdown heredocs

### Changed

- Switched from labels to GitHub native issue types
- Reorganized Renovate configuration for better maintainability
- Improved pre-commit hook configuration
- Enhanced `.gitignore` patterns

## [0.1.0]

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
