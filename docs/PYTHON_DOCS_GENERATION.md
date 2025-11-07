# Python Documentation Generation for Typst

This document describes the Python documentation generation system that integrates with the Typst documentation pipeline.

## Overview

The Python documentation generation system automatically extracts docstrings from Python source code and generates documentation in formats that can be consumed by Typst. This creates a seamless workflow where Python API documentation stays synchronized with the source code.

## Features

- ✅ **Automatic Extraction**: Parses Python files and extracts module, class, and function docstrings
- ✅ **Google-Style Docstrings**: Supports Google-style docstring format (Args, Returns, Raises sections)
- ✅ **Type Annotations**: Captures type hints from function signatures
- ✅ **Multiple Output Formats**: Generates both JSON and Typst format files
- ✅ **Build System Integration**: Integrated into the Makefile build pipeline
- ✅ **Formatted Output**: Creates beautifully formatted documentation blocks in Typst

## Quick Start

### Generate Documentation

```bash
# Generate Python documentation (JSON + Typst)
make python-docs

# Or run the script directly
python3 scripts/build-python-docs.py
```

### Use in Typst Documents

```typst
// Import the generated documentation
#import "../lib/generated/python-docs.typ": *

// Display documentation for a module
#doc_hello  // Shows documentation for hello.py module
```

## Documentation Script

### Location

`scripts/build-python-docs.py`

### Usage

```bash
python3 scripts/build-python-docs.py [project_dir] [--output-format json|typst|both] [--output-dir DIR]
```

**Arguments:**

- `project_dir`: Python project directory (default: `example/python-project/src`)
- `--output-format`: Output format - `json`, `typst`, or `both` (default: `both`)
- `--output-dir`: Output directory for generated files (default: `lib/generated`)

**Examples:**

```bash
# Default: Process example project, generate both formats
python3 scripts/build-python-docs.py

# Process a different project
python3 scripts/build-python-docs.py my-python-project/src

# Generate only JSON output
python3 scripts/build-python-docs.py --output-format json

# Use custom output directory
python3 scripts/build-python-docs.py --output-dir docs/generated
```

## Output Files

### JSON Output

**File:** `lib/generated/python-docs.json`

Contains structured documentation data:

```json
{
  "modules": [
    {
      "path": "example/python-project/src/hello.py",
      "name": "hello",
      "description": "Example module demonstrating best practices.",
      "functions": [
        {
          "name": "greet",
          "description": "Generate a greeting message.",
          "args": [
            {
              "name": "name",
              "type": "str",
              "description": "Name of the person to greet"
            }
          ],
          "returns": {
            "type": "str",
            "description": "A formatted greeting message"
          }
        }
      ]
    }
  ]
}
```

### Typst Output

**File:** `lib/generated/python-docs.typ`

Contains Typst functions for rendering documentation:

- `#python-function()`: Helper function to format function documentation
- `#doc_<module_name>`: Function to display documentation for each module

## Docstring Format

The extraction script supports **Google-style docstrings**:

```python
def greet(name: str, excited: bool = False) -> str:
    """Generate a greeting message.

    Args:
        name: Name of the person to greet
        excited: Whether to add excitement to the greeting

    Returns:
        A formatted greeting message

    Raises:
        ValueError: If name is empty
    """
    # Function implementation
```

**Supported Sections:**

- **Description**: First paragraph of the docstring
- **Args/Arguments**: Function parameters with descriptions
- **Returns/Return**: Return value description
- **Raises/Raise**: Exceptions that may be raised

## Integration with Build System

### Makefile Integration

The Python documentation generation is integrated into the build pipeline:

```makefile
# Standalone target
make python-docs

# Automatically runs as part of project builds
make example                    # Builds example project (includes python-docs)
make technical-documentation    # Builds technical docs (includes python-docs)
make all-projects              # Builds all projects (includes python-docs)
```

### Build Process

1. **Extract Colors**: `make colors` generates color files
2. **Extract Python Docs**: `make python-docs` generates documentation ← NEW!
3. **Compile Diagrams**: `make diagrams` compiles Typst diagrams to SVG
4. **Compile PDF**: Typst generates PDF output
5. **Compile HTML**: Typst generates HTML output

### Clean Target

Generated Python documentation files are removed with:

```bash
make clean          # Removes all generated files including python-docs
make clean-generated # Removes only generated files
```

## Example Usage

### Complete Example Document

See `example/python-docs-demo.typ` for a complete example:

```typst
// Import the technical documentation package
#import "../lib/technical-documentation-package.typ": *
// Import the generated Python documentation
#import "../lib/generated/python-docs.typ": *

// Apply styles to the document
#show: tech-doc

= Python API Documentation

// Display documentation for modules
#doc_hello  // hello.py module
#doc_main   // main.py module
```

### Compile the Example

```bash
# Generate documentation and compile to PDF
make python-docs
typst compile --root . example/python-docs-demo.typ example/python-docs-demo.pdf

# Or use HTML
python3 scripts/build-html.py example/python-docs-demo.typ example/python-docs-demo.html
```

## Customization

### Custom Styling

The `python-function()` helper in `python-docs.typ` can be customized:

```typst
#let python-function(name, args, returns, description, raises: none) = {
  block(
    fill: rgb("#f8f8f8"),  // Change background color
    inset: 12pt,            // Change padding
    radius: 4pt,            // Change border radius
    width: 100%,
  )[
    // Customize rendering here
  ]
}
```

### Filtering Files

The script automatically filters out:

- Files in `__pycache__` directories
- Test files (starting with `test_`)

To modify filtering, edit `scan_python_project()` in `scripts/build-python-docs.py`.

### Adding New Sections

To support additional docstring sections (e.g., "Examples", "Notes"):

1. Modify `parse_google_docstring()` to recognize new sections
2. Update `generate_typst_output()` to render new sections
3. Update the `python-function()` helper to display new sections

## Workflow Integration

### Pre-commit Hook

Consider adding Python documentation generation to the pre-commit hook:

```bash
# In scripts/build-hooks/pre-commit
if git diff --cached --name-only | grep -q "\.py$"; then
    echo "Python files changed, regenerating documentation..."
    make python-docs
    git add lib/generated/python-docs.json lib/generated/python-docs.typ
fi
```

### CI/CD Integration

For CI/CD pipelines, ensure documentation is up-to-date:

```yaml
# Example GitHub Actions workflow
- name: Generate Python Documentation
  run: make python-docs

- name: Check for uncommitted changes
  run: |
    if ! git diff --exit-code lib/generated/; then
      echo "Python documentation is out of date!"
      exit 1
    fi
```

## Troubleshooting

### Issue: No modules found

**Problem**: Script reports "No Python modules found or processed"

**Solution**:
- Check the project directory path
- Ensure Python files exist in the directory
- Verify files don't start with `test_`

### Issue: Import error in Typst

**Problem**: Typst reports "file not found" when importing `python-docs.typ`

**Solution**:
- Run `make python-docs` to generate the file
- Check that `lib/generated/python-docs.typ` exists
- Verify the import path is correct relative to your document

### Issue: Malformed output

**Problem**: Generated Typst code causes syntax errors

**Solution**:
- Check for special characters in docstrings (especially `#`, `"`, `\`)
- The script should escape these, but complex formatting may need adjustment
- Review the `escape_typst_string()` function

### Issue: Missing documentation

**Problem**: Some functions don't appear in generated docs

**Solution**:
- Ensure functions have docstrings
- Check that docstrings follow Google-style format
- Verify functions are not inside test files

## Technical Details

### AST Parsing

The script uses Python's `ast` module to parse source files:

```python
tree = ast.parse(content, filename=str(filepath))
```

This approach:
- Works without importing/executing the code
- Captures accurate type annotations
- Handles syntax correctly

### Type Annotation Support

Type hints are extracted from function signatures:

```python
# Function definition
def greet(name: str, excited: bool = False) -> str:
    ...

# Extracted information
{
  "args": [
    {"name": "name", "type": "str"},
    {"name": "excited", "type": "bool"}
  ],
  "returns": {"type": "str"}
}
```

### Docstring Parsing

Google-style docstrings are parsed into sections:

```python
parsed = {
  "description": "Main description",
  "args": [{"name": "arg1", "description": "..."}],
  "returns": "Return value description",
  "raises": [{"name": "Exception", "description": "..."}]
}
```

## Future Enhancements

Potential improvements:

- [ ] Support for NumPy-style docstrings
- [ ] Class documentation with attributes
- [ ] Cross-references between functions
- [ ] Example code block extraction
- [ ] Markdown formatting in docstrings
- [ ] Inheritance and method override tracking
- [ ] Module dependency graphs

## Related Documentation

- [Build System](BUILD_SYSTEM.md) - Main build system documentation
- [Dark Mode Standards](DARK_MODE_COLOR_STANDARDS.md) - Color scheme documentation
- [Linter and Pre-commit](LINTER_AND_PRECOMMIT.md) - Code quality tools

## Summary

The Python documentation generation system provides:

1. **Automated Extraction**: No manual documentation maintenance
2. **Type Safety**: Preserves type annotations from source code
3. **Beautiful Output**: Professional formatting in Typst documents
4. **Build Integration**: Seamless workflow with existing pipeline
5. **Flexible Output**: Both JSON and Typst formats available

This ensures your Python API documentation stays synchronized with your code and integrates beautifully into your Typst-generated technical documents.
