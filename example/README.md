# Example: Complete Documentation Build Demonstration

This directory demonstrates the **complete technical documentation build process**, showing both source files and their generated outputs.

## 📋 What This Demonstrates

This example showcases how the technical documentation build system transforms various inputs into beautiful PDF and HTML outputs with dark mode support.

## 📁 Directory Structure

```text
example/
├── README.md                      # This file
├── technical-doc-example.typ      # Main Typst document (SOURCE)
├── technical-doc-example.pdf      # Generated PDF (OUTPUT - kept for demo)
├── technical-doc-example.html     # Generated HTML (OUTPUT - kept for demo)
├── diagrams/                      # Diagram sources and outputs
│   ├── architecture.typ          # Diagram source (SOURCE)
│   ├── architecture.svg          # Generated diagram (OUTPUT - kept for demo)
│   ├── data-flow.typ             # Diagram source (SOURCE)
│   ├── data-flow.svg             # Generated diagram (OUTPUT - kept for demo)
│   ├── state-machine.typ         # Diagram source (SOURCE)
│   └── state-machine.svg         # Generated diagram (OUTPUT - kept for demo)
├── stakeholders.csv              # Sample data in CSV format
├── stakeholders.json             # Sample data in JSON format
├── stakeholders.yaml             # Sample data in YAML format
└── python-project/               # Example Python project structure
    ├── src/                      # Python source code
    │   ├── __init__.py
    │   ├── hello.py
    │   └── main.py
    └── tests/                    # Python tests
        ├── __init__.py
        └── test_hello.py
```

## 🎯 Purpose

**Unlike most projects**, we deliberately **keep the generated outputs** (PDFs, HTML, SVGs) in version control here to:

1. **Show the end result** - Visitors can see what the build system produces
2. **Demonstrate capabilities** - The outputs showcase the system's features
3. **Provide examples** - Serve as reference for what's possible
4. **Enable quick preview** - No need to build to see the results

## 🚀 Building This Example

From the repository root, run:

```bash
# Build just the example
make example

# View the HTML output
open example/technical-doc-example.html
# or navigate to: http://localhost:8000/technical-doc-example.html
```

## 📚 What the Example Shows

The `technical-doc-example.typ` document demonstrates:

- **Stakeholder Analysis Matrix** - Multiple approaches to creating tables
- **Data Import** - Reading from CSV, JSON, and YAML files
- **Diagram Integration** - Including SVG diagrams compiled from Typst
- **Styling** - Professional styling with the technical documentation package
- **Dark Mode** - Automatic light/dark theme switching in HTML output

## 🐍 Python Project Example

The `python-project/` subdirectory contains a sample Python application that demonstrates:

- Modern Python project structure
- Type hints and documentation
- Command-line interface
- Logging and error handling
- Unit tests with pytest

This serves as example code that could be documented using the technical documentation system.

## 🔗 Related Files

- **Main package**: `../lib/technical-documentation-package.typ`
- **Build scripts**: `../scripts/`
- **Makefile targets**: See `../Makefile`
- **System documentation**: `../docs/`

## 💡 Using This as a Template

To create your own technical documentation:

1. Copy the structure of `technical-doc-example.typ`
2. Modify the content for your needs
3. Add your own diagrams in `diagrams/`
4. Run `make` to build
5. View the results in PDF and HTML formats
