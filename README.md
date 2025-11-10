# Typst Technical Documentation Template

A complete development environment and build system for creating professional
technical documentation with Typst, featuring automated diagram compilation,
dual PDF/HTML output with dark mode support, and comprehensive Python API
documentation generation.

## Features

### Documentation Generation

- **Dual Output Format**: Generate both PDF and HTML from the same Typst source
- **Bootstrap HTML**: Modern, responsive HTML with Bootstrap 5.3 styling
- **Dark Mode**: Automatic dark mode support with manual toggle and system preference detection
- **Live Development Server**: Auto-reloading development server (live-server with Python fallback)
- **Cache-Busting**: Automatic CSS cache invalidation for reliable updates

### Diagram Support

- **Fletcher Diagrams**: Architecture, data flow, and state machine diagrams
- **Theme-Aware**: Diagrams automatically switch colors for light/dark modes
- **Automatic Compilation**: Diagrams compile automatically as part of the build process
- **SVG Embedding**: Diagrams embedded as SVG in HTML for crisp rendering

### Python Documentation

- **API Documentation**: Generate API reference from Python source using griffe
- **Google-Style Docstrings**: Full support for structured docstring parsing
- **Test Integration**: Automatically include test coverage and results
- **Self-Contained**: All documentation generated within the build system

### Development Environment

- **VS Code Devcontainer**: Pre-configured development environment with all tools
- **SSH Agent Integration**: Git commit/tag signing works seamlessly in container
- **Pre-commit Hooks**: Automatic linting and formatting (Ruff, shellcheck, pymarkdown, yamllint)
- **Protected Configs**: Linting configuration files protected from accidental modification

## Quick Start

### 1. Open in Devcontainer

Open this repository in VS Code and select "Reopen in Container" when prompted.

### 2. Build Your Documentation

```bash
# Build the default project (technical-documentation/)
make

# Build the example project
make example

# Build a specific project
make PROJECT=my-project
```

The build automatically:

- Generates color palettes from `lib/colors.json`
- Compiles all diagrams in `diagrams/` folder
- Builds PDF output
- Builds HTML with Bootstrap styling
- Starts development server on <http://localhost:8000>

### 3. View Your Documentation

Open your browser to <http://localhost:8000> to see:

- PDF version: `technical-documentation.pdf`
- HTML version: `technical-documentation.html`

## Build System

### Main Targets

```bash
make                    # Build technical-documentation (default)
make example            # Build the example project
make test               # Build and validate all projects
make clean              # Remove all build artifacts
make rebuild            # Clean and rebuild everything
```

### Component Targets

```bash
make colors             # Generate color files from colors.json
make diagrams           # Compile all diagrams for current project
make pdf                # Compile PDF only
make html               # Compile HTML with Bootstrap styling
```

### Server Control

```bash
make server-start       # Start development server on port 8000
make server-stop        # Stop the development server
make server-status      # Check if server is running
```

### Configuration Options

```bash
# Disable theme toggle (use system preference only)
make THEME_TOGGLE=no

# Build specific project
make PROJECT=example

# Compile diagrams for specific project
make diagrams PROJECT=example
```

## Project Structure

```text
workspace/
├── technical-documentation/       # Default project
│   ├── technical-documentation.typ    # Main document
│   ├── diagrams/                      # Diagram source files
│   └── build/                         # Build outputs
│       ├── diagrams/                  # Compiled diagram SVGs
│       ├── technical-documentation.pdf
│       └── technical-documentation.html
│
├── example/                       # Example project
│   ├── technical-documentation.typ
│   ├── diagrams/
│   └── build/
│
├── lib/                          # Shared library
│   ├── technical-documentation-package.typ  # Typst functions
│   ├── colors.json                         # Color palette
│   ├── styles-bootstrap.css                # HTML styling
│   └── generated/                          # Auto-generated files
│
├── scripts/                      # Build scripts
│   ├── build-html-bootstrap.py   # HTML processing
│   └── generate-colors.py        # Color palette generator
│
└── Makefile                      # Build system
```

## Creating Documentation

### 1. Create Your Document

Edit `docs/main.typ`:

```typst
#import "../lib/technical-documentation-package.typ": *

#show: tech-doc.with(
  title: "My Technical Documentation",
  authors: ("Your Name",),
  date: datetime.today(),
)

= Introduction

Your content here...
```

### 2. Add Diagrams

Create diagrams in `technical-documentation/diagrams/`:

```typst
// diagrams/architecture.typ
#import "../../lib/generated/colors.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#set page(width: auto, height: auto, margin: 1em, fill: none)

#align(center)[
  #diagram(
    node-stroke: 1pt,
    node-fill: node-bg-blue,
    spacing: 5em,

    node((0, 0), [Frontend]),
    node((1, 0), [Backend]),
    edge((0, 0), (1, 0), [API], "->"),
  )
]
```

### 3. Include Diagrams

In your main document:

```typst
#figure(
  image("build/diagrams/architecture.svg"),
  caption: [System Architecture]
)
```

### 4. Build

```bash
make
```

## Available Functions

Import from the package:

```typst
#import "../lib/technical-documentation-package.typ": *
```

### Document Template

- `tech-doc()` - Main document template with proper styling

### Diagram Helpers

- `architecture-diagram()` - System architecture diagrams
- `data-flow-diagram()` - Data flow diagrams
- `state-diagram()` - State machine diagrams

### Typography

- `nuclide()` - Isotope notation (⁴⁴Sc, ⁶⁸Ga, ¹⁸F)
- `beta-plus()` - β⁺ particle
- `beta-minus()` - β⁻ particle

See `lib/NOTATIONS-README.md` for complete notation reference.

## Python API Documentation

Generate API documentation from Python source code:

```bash
# Generate API docs for your Python project
make python-api

# Run tests and generate coverage
make python-tests

# Compile Python-specific diagrams
make python-diagrams
```

The system uses `griffe` to extract API information and generates Typst documentation automatically.

## Customization

### Colors

Edit `lib/colors.json` to customize the color palette:

```json
{
  "light": {
    "primary": "#0066cc",
    "background": "#ffffff",
    ...
  },
  "dark": {
    "primary": "#4dabf7",
    "background": "#1a1a1a",
    ...
  }
}
```

Run `make colors` to regenerate color files.

### HTML Styling

Edit `lib/styles-bootstrap.css` for custom HTML styling. The template uses Bootstrap 5.3 as a base.

### Build Process

The `Makefile` orchestrates the complete build process:

1. **Color Generation**: `lib/colors.json` → `lib/generated/colors.typ`
2. **Diagram Compilation**: `diagrams/*.typ` → `build/diagrams/*.svg`
3. **PDF Build**: Typst compilation with all resources
4. **HTML Build**: Typst HTML export + Bootstrap styling + cache-busting
5. **Server Start**: Live-server or Python HTTP server

## Development Server

The template includes a smart development server:

- **Primary**: `live-server` (Node.js) with auto-reload on file changes
- **Fallback**: Python `ThreadingHTTPServer` if live-server unavailable
- **Port**: 8000 by default
- **Features**: Proper CORS headers, cache control, concurrent requests

Control the server:

```bash
make server-start   # Start server
make server-stop    # Stop server
make server-status  # Check status
```

## Dark Mode

HTML output automatically supports dark mode:

- **System Detection**: Respects `prefers-color-scheme`
- **Manual Toggle**: Button in top-right corner (optional)
- **Persistence**: Choice saved in localStorage
- **Diagrams**: All diagrams switch colors automatically

Disable the toggle button:

```bash
make THEME_TOGGLE=no
```

## Example Project

The `example/` directory contains a complete reference implementation:

- Technical documentation following V-Model structure
- Multiple diagram types (architecture, data flow, state machine)
- Stakeholder analysis with data from multiple sources (CSV, JSON, YAML)
- Python API documentation integration
- Test coverage integration

Build it:

```bash
make example
```

## Tips

1. **Multiple Projects**: Create new folders at workspace root, each with their own `technical-documentation.typ` and `diagrams/` folder
2. **Live Reload**: Use `live-server` for best development experience with auto-reload
3. **Diagram Organization**: Group related diagrams in subdirectories under `diagrams/`
4. **Color Consistency**: Use generated color variables from `lib/generated/colors.typ` in diagrams
5. **Version Control**: Build outputs (`build/` directories) are gitignored by default

## Documentation

- **Build System**: See `Makefile` for all targets and options
- **Git Workflow**: See `docs/git-workflow.md` for commit conventions
- **Devcontainer**: See `docs/devcontainer-setup.md` for environment details
- **Linting**: See `docs/linter-precommit-guide.md` for code quality tools

## Protected Configuration Files

This repository protects critical linting configuration files from accidental modifications:

### Protected Files

- `.pre-commit-config.yaml` - Pre-commit hooks
- `pyproject.toml` - Python dependencies and tools
- `.hadolint.yaml` - Container linting
- `.checkmake.ini` - Makefile linting
- `.yamllint` - YAML linting

These files are set to **read-only (444 permissions)** in the devcontainer.

### Editing Protected Files

```bash
# Use the helper script
edit-protected .pre-commit-config.yaml

# Or manually
chmod 644 .pre-commit-config.yaml
vim .pre-commit-config.yaml
chmod 444 .pre-commit-config.yaml
```

The protection is local-only and doesn't affect CI/CD workflows.

## Requirements

- **Devcontainer**: VS Code with Dev Containers extension
- **Or Manual Setup**:
  - Typst 0.12+
  - Python 3.12+
  - Node.js (optional, for live-server)
  - Make

## License

See LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch (`feature/my-feature`)
3. Follow conventional commit format (enforced by gitlint)
4. Ensure all pre-commit hooks pass
5. Submit a pull request

See `docs/git-workflow.md` for detailed guidelines.
