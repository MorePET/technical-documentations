# Typst Devcontainer Template

A comprehensive Typst documentation system with automated Python documentation generation, diagram compilation, and dark mode support.

## Features

- 🎨 **Color Management**: Centralized color definitions with automatic CSS and Typst generation
- 📚 **Python Documentation**: Automated extraction of Python docstrings into Typst format
- 📊 **Diagram Compilation**: Automatic compilation of Typst diagrams to SVG with dark mode support
- 🌓 **Dark Mode**: Built-in dark mode support with theme toggle for HTML output
- 🔨 **Build System**: Integrated Makefile for streamlined documentation generation
- 🐳 **Dev Container**: Pre-configured development environment

## Quick Start

```bash
# Build the default technical documentation project
make

# Build the example project
make example

# Build all projects
make all-projects

# Generate Python documentation
make python-docs

# Clean and rebuild
make rebuild
```

## Documentation

- [Build System](docs/BUILD_SYSTEM.md) - Complete build system documentation
- [Python Documentation Generation](docs/PYTHON_DOCS_GENERATION.md) - Python API docs integration ← NEW!
- [Dark Mode Standards](docs/DARK_MODE_COLOR_STANDARDS.md) - Color scheme guidelines
- [Dev Container Setup](docs/DEV_CONTAINER_SETUP.md) - Container configuration
- [Linter and Pre-commit](docs/LINTER_AND_PRECOMMIT.md) - Code quality tools

## New: Python Documentation Generation

Automatically extract Python docstrings and generate beautiful documentation:

```bash
# Extract documentation from Python source
make python-docs
```

```typst
// Use in your Typst documents
#import "../lib/generated/python-docs.typ": *

#doc_hello  // Display hello.py documentation
```

See [Python Documentation Generation](docs/PYTHON_DOCS_GENERATION.md) for complete details.

## Project Structure

```
.
├── lib/                          # Shared libraries and packages
│   ├── technical-documentation-package.typ
│   └── generated/                # Auto-generated files
│       ├── colors.css
│       ├── colors.typ
│       ├── python-docs.json     # NEW: Python API docs (JSON)
│       └── python-docs.typ      # NEW: Python API docs (Typst)
├── example/                      # Example project
│   ├── diagrams/                 # Diagram source files
│   ├── python-project/          # Python code example
│   ├── python-docs-demo.typ     # NEW: Python docs demo
│   └── technical-doc-example.typ
├── technical-documentation/      # Technical documentation project
│   └── technical-documentation.typ
├── scripts/                      # Build scripts
│   ├── build-colors.py
│   ├── build-diagrams.py
│   ├── build-python-docs.py     # NEW: Python docs extraction
│   ├── build-html.py
│   └── build-hooks/
└── docs/                         # Documentation

```

## Example Projects

### Example Project (Demo)
Location: `example/`

The original demonstration project showing stakeholder analysis tables, CSV/JSON/YAML parsing, and now Python documentation generation.

```bash
make example
```

Output: `technical-doc-example.pdf` and `technical-doc-example.html`

### Technical Documentation Project
Location: `technical-documentation/`

Your actual technical documentation (starts minimal - you fill it in).

```bash
make technical-documentation
# or just: make
```

Output: `technical-documentation.pdf` and `technical-documentation.html`

## Contributing

See [CHANGELOG.md](CHANGELOG.md) for version history and contribution guidelines.
