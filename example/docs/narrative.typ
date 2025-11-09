= Introduction

This is an example Python project demonstrating best practices for command-line applications. The project showcases:

- Clean code structure
- Comprehensive docstrings
- Type hints
- Logging
- Error handling
- Unit tests with pytest

== Project Structure

The project is organized as follows:

```
python-project/
├── src/
│   ├── hello.py    # Core functionality
│   └── main.py     # CLI entry point
└── tests/
    └── test_hello.py  # Unit tests
```

== Key Features

=== Greeting Function

The `greet()` function generates personalized greeting messages with optional excitement. It demonstrates:

- Input validation
- Default parameters
- Type hints
- Comprehensive error handling

=== File Processing

The `process_file()` function reads and processes files with proper error handling:

- Path validation
- Exception handling
- Logging
- Return None on errors (no exceptions to caller)

=== Command-Line Interface

The CLI supports multiple commands:

- `greet NAME` - Generate a greeting
- `process FILE` - Process a file

Both commands support verbose logging with the `--verbose` flag.

== Usage Examples

=== Basic Greeting

```bash
python -m src.main greet Alice
# Output: Hello, Alice!
```

=== Excited Greeting

```bash
python -m src.main greet Bob --excited
# Output: Hello, Bob! 🎉
```

=== Process a File

```bash
python -m src.main process README.md
```

=== Verbose Logging

```bash
python -m src.main --verbose greet Charlie
```

== Design Principles

This project follows these principles:

1. *Single Responsibility*: Each function does one thing well
2. *Type Safety*: All functions have type hints
3. *Documentation*: Comprehensive docstrings in Google style
4. *Testing*: High test coverage (>80%)
5. *Logging*: Proper use of Python logging module
6. *Error Handling*: Graceful failure with clear error messages

== Next Steps

For detailed API documentation, see the API Reference section below. For testing information, see the Test Coverage section.
