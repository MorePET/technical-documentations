# Python Example Project

This is an example Python project demonstrating best practices and automated documentation generation.

## Features

- **Type Annotations**: All functions use proper type hints
- **Google-Style Docstrings**: Comprehensive documentation following Google conventions
- **Modular Design**: Clean separation of concerns
- **Automated Documentation**: Documentation extracted for Typst integration

## Project Structure

```
python-project/
├── src/
│   ├── __init__.py      # Package initialization
│   ├── hello.py         # Example functions with docstrings
│   └── main.py          # CLI application entry point
└── tests/
    ├── __init__.py      # Test package initialization
    └── test_hello.py    # Unit tests
```

## Usage

### As a Module

```python
from example.python_project.src.hello import greet

message = greet("World", excited=True)
print(message)  # Output: Hello, World! 🎉
```

### As a CLI Application

```bash
# Show help
python -m example.python_project.src.main --help

# Greet someone
python -m example.python_project.src.main greet Alice

# Greet with excitement
python -m example.python_project.src.main greet Alice --excited

# Process a file
python -m example.python_project.src.main process myfile.txt
```

## Documentation Generation

This project serves as an example for the automated Python documentation generation system.

### Generate Documentation

```bash
# From project root
make python-docs

# Or run the script directly
python3 scripts/build-python-docs.py
```

This generates:
- `lib/generated/python-docs.json` - Structured documentation data
- `lib/generated/python-docs.typ` - Typst-formatted documentation

### Use in Typst Documents

```typst
#import "../lib/generated/python-docs.typ": *

// Display module documentation
#doc_hello  // Shows hello.py documentation
#doc_main   // Shows main.py documentation
```

See `example/python-docs-demo.typ` for a complete example.

## Development

### Running Tests

```bash
# Run tests with pytest
pytest example/python-project/tests

# With coverage
pytest --cov=example/python-project/src --cov-report=term-missing
```

### Code Quality

```bash
# Format code
ruff format example/python-project/

# Lint code
ruff check example/python-project/
```

## Docstring Format

This project uses Google-style docstrings:

```python
def example_function(arg1: str, arg2: int = 0) -> bool:
    """Brief description of the function.

    Longer description if needed, explaining the purpose
    and behavior of the function.

    Args:
        arg1: Description of first argument
        arg2: Description of second argument with default value

    Returns:
        Description of the return value

    Raises:
        ValueError: Description of when this exception is raised
        TypeError: Description of when this exception is raised
    """
    # Implementation
```

## Related Documentation

- [Python Documentation Generation](../../docs/PYTHON_DOCS_GENERATION.md) - Complete guide to the documentation system
- [Build System](../../docs/BUILD_SYSTEM.md) - Overall build system documentation

## Best Practices Demonstrated

1. **Type Hints**: All functions and methods use type annotations
2. **Docstrings**: Comprehensive documentation for all public APIs
3. **Error Handling**: Proper exception handling with custom error messages
4. **Logging**: Structured logging throughout the application
5. **Testing**: Unit tests with good coverage
6. **CLI Interface**: Well-designed command-line interface using argparse
7. **Modular Code**: Clean separation between modules
8. **Path Handling**: Using `pathlib.Path` instead of string paths

This example project serves as a template for Python projects that integrate with the Typst documentation pipeline.
