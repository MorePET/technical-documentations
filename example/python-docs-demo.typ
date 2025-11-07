// Import the technical documentation package
#import "../lib/technical-documentation-package.typ": *
// Import the generated Python documentation
#import "../lib/generated/python-docs.typ": *

// Apply styles to the document
#show: tech-doc

= Python API Documentation

This document demonstrates automatic documentation generation from Python source code.

#note([
  This documentation is automatically extracted from Python docstrings using the `build-python-docs.py` script.
  To regenerate: `make python-docs`
])

== Overview

The example Python project demonstrates best practices for Python development, including:
- Type annotations for better code clarity
- Comprehensive docstrings following Google style
- Proper error handling
- Modular code organization

== Module Documentation

The following sections contain automatically generated documentation from the Python source code.

// Display documentation for the hello module
#doc_hello

// Display documentation for the main module  
#doc_main

== Usage Examples

Here are some examples of how to use the documented functions:

=== Greeting Example

```python
from hello import greet

# Basic greeting
message = greet("World")
print(message)  # Output: Hello, World!

# Excited greeting
message = greet("Python", excited=True)
print(message)  # Output: Hello, Python! 🎉
```

=== File Processing Example

```python
from pathlib import Path
from hello import process_file

# Process a file
filepath = Path("example.txt")
content = process_file(filepath)
if content:
    print(f"File contains {len(content)} characters")
```

=== Command Line Usage

```bash
# Show help
python -m example.python-project --help

# Greet someone
python -m example.python-project greet Alice

# Greet with excitement
python -m example.python-project greet Alice --excited

# Process a file
python -m example.python-project process myfile.txt
```

== Build Pipeline Integration

This documentation is automatically generated as part of the build pipeline:

+ *Extract Documentation*: `make python-docs` runs the extraction script
+ *Generate Outputs*: Creates both JSON and Typst format files
+ *Include in Documents*: Import the generated `.typ` file
+ *Build Final Output*: Compile to PDF/HTML with `make example`

The pipeline ensures documentation stays synchronized with the code.
