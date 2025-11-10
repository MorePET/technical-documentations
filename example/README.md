# Documentation Example

This example demonstrates professional documentation practices using Typst, combining V-Model development lifecycle, stakeholder analysis, technical diagrams, and auto-generated API documentation.

## Structure

```text
example/
├── docs/
│   └── main.typ                    # High-level product documentation
├── python-project/                 # Implementation package example
│   ├── docs/
│   │   ├── main.typ               # V-Model phases for this package
│   │   └── diagrams/
│   │       ├── v-model.typ        # V-Model diagram source
│   │       └── v-model.svg        # Compiled diagram
│   ├── src/                       # Python source code
│   │   ├── hello.py               # Core functionality
│   │   ├── main.py                # CLI entry point
│   │   └── doc_generator/         # Documentation generation tools
│   │       ├── extract_api.py     # API documentation extraction
│   │       └── test_report.py     # Test report generation
│   ├── tests/                     # Test suite
│   │   ├── test_hello.py
│   │   └── test_main.py
│   └── build/                     # Build outputs
│       ├── generated/             # Auto-generated docs
│       │   ├── api-reference.typ
│       │   ├── test-coverage.typ
│       │   └── test-results.typ
│       └── diagrams/              # Compiled diagrams
│           └── v-model.svg
├── diagrams/                       # Technical diagram sources
│   ├── architecture.typ
│   ├── data-flow.typ
│   └── state-machine.typ
├── build/                          # Example documentation build outputs
│   ├── example-documentation.pdf   # Final PDF
│   ├── example-documentation.html  # Final HTML with dark mode
│   └── diagrams/                   # Compiled technical diagrams
│       ├── architecture.svg
│       ├── architecture-light.svg
│       ├── architecture-dark.svg
│       ├── data-flow.svg
│       ├── data-flow-light.svg
│       ├── data-flow-dark.svg
│       ├── state-machine.svg
│       ├── state-machine-light.svg
│       └── state-machine-dark.svg
└── stakeholders.{csv,json,yaml}    # Example data files
```

## Building

### Build Complete Example Documentation

```bash
make example
```

This will:

1. Generate Python API documentation from source code
2. Run tests and generate coverage reports
3. Compile all diagrams (both light and dark themes)
4. Build the complete documentation (PDF + HTML)
5. Start a local web server on port 8000

Output files:
- `example/build/example-documentation.pdf` (~500KB)
- `example/build/example-documentation.html` (~300KB)

### Clean Build

```bash
make clean
make example
```

## What's Included

### High-Level Documentation (`example/docs/main.typ`)

The main documentation combines:

1. **V-Model Overview**: Software development lifecycle methodology
2. **Stakeholder Analysis**: Multiple table formats (manual, CSV, JSON, YAML)
3. **Technical Diagrams**: Architecture, data flow, and state machines with Fletcher
4. **Implementation Example**: Complete Python CLI package with V-Model phases
5. **Auto-Generated Content**: API docs, test coverage, and test results

### Python Project (`example/python-project/`)

A complete Python CLI application demonstrating:

- ✅ V-Model development phases (Requirements → Acceptance Testing)
- ✅ Comprehensive test coverage (80%+)
- ✅ Auto-generated API documentation from docstrings
- ✅ Test reports with coverage metrics
- ✅ Professional CLI with argparse
- ✅ Type hints throughout
- ✅ PEP 8 compliant

## Features

✨ **Dual-Theme Support**: HTML output with automatic light/dark mode switching
📊 **Technical Diagrams**: Fletcher-based diagrams with semantic colors
🔄 **Auto-Generated**: API docs extracted from Python source code using griffe
🧪 **Test Integration**: Coverage reports and test results embedded in docs
📖 **V-Model Methodology**: Complete software lifecycle documentation
🎨 **Stakeholder Analysis**: Multiple formats for stakeholder documentation
💾 **Theme Persistence**: HTML remembers user's theme choice
📱 **Fully Offline**: Single HTML file works without internet

## Customization

### Add New Diagrams

1. Create `diagrams/my-diagram.typ` using color variables from `lib/colors.json`
2. Run `make example` to compile with both themes
3. Reference in Typst: `#architecture-diagram()` (or create similar function)

### Customize Colors

Edit `/workspace/lib/colors.json` and rebuild:

```bash
make colors
make example
```

### Extend Python Project

1. Add new modules to `python-project/src/`
2. Add tests to `python-project/tests/`
3. Update `python-project/src/doc_generator/extract_api.py` module list
4. Run `make example` to regenerate docs

## Documentation Pipeline

```text
Python Source Code
    ↓
[griffe] AST Analysis
    ↓
API Documentation (Typst)
    +
V-Model Narrative (Typst)
    +
Test Reports (pytest + coverage)
    +
Stakeholder Analysis
    +
Technical Diagrams (Fletcher)
    ↓
typst compile
    ↓
PDF + HTML outputs with dark mode
```

## Technologies

**Documentation:**
- Typst: Modern document compilation
- griffe: Python API extraction (AST-based)
- docstring-parser: Docstring parsing
- pytest + pytest-cov: Test and coverage
- Fletcher: Typst diagramming library

**Implementation:**
- Python 3.12+
- Type hints throughout
- Google-style docstrings
- PEP 8 compliant (Ruff enforced)

## Benefits

1. **Single Source of Truth**: API docs extracted directly from code
2. **Always Up-to-Date**: Auto-generated on every build
3. **Professional Output**: Publication-quality PDF with Libertinus Serif
4. **Modern HTML**: Dark mode support with theme persistence
5. **Complete Lifecycle**: V-Model from requirements to acceptance
6. **Reusable**: Python package structure can be copied to other projects

## Next Steps

1. **Explore** the generated `example/build/example-documentation.html`
2. **Try** the theme toggle button (🌓) in top-right
3. **Review** the V-Model phases in the documentation
4. **Examine** the auto-generated API reference
5. **Study** the test coverage report
6. **Customize** for your own projects

## Learn More

- See `python-project/README.md` for package-specific details
- See `/workspace/docs/BUILD_SYSTEM.md` for build system documentation
- See `/workspace/docs/DARK_MODE_COLOR_STANDARDS.md` for color system details
