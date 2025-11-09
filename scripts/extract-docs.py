#!/usr/bin/env python3
"""
Extract API documentation from Python code using griffe.
Generates Typst-formatted documentation.
"""

import sys
from pathlib import Path

import griffe
from docstring_parser import parse as parse_docstring


def format_parameter(param) -> str:
    """Format a parameter for Typst."""
    result = f"- `{param.arg_name}`"
    if param.type_name:
        result += f" (_{param.type_name}_)"
    if param.is_optional:
        result += " _(optional)_"
    if param.description:
        result += f": {param.description}"
    return result


def format_function(func_name: str, func_data) -> str:
    """Format a function as Typst markup."""

    typst = f"=== `{func_name}()`\n\n"

    # Signature - get the actual signature string
    if hasattr(func_data, "parameters") and func_data.parameters:
        # Build signature from parameters
        params = []
        try:
            # Parameters is a list-like object
            for param in func_data.parameters:
                param_str = param.name
                if hasattr(param, "annotation") and param.annotation:
                    param_str += f": {param.annotation}"
                if hasattr(param, "default") and param.default:
                    param_str += f" = {param.default}"
                params.append(param_str)
            sig = f"({', '.join(params)})"
            if hasattr(func_data, "returns") and func_data.returns:
                sig += f" -> {func_data.returns}"
            typst += f"```python\n{func_name}{sig}\n```\n\n"
        except Exception:
            # If signature extraction fails, just show the function name
            typst += f"```python\n{func_name}(...)\n```\n\n"

    # Docstring
    if func_data.docstring and func_data.docstring.value:
        parsed = parse_docstring(func_data.docstring.value)

        # Short description
        if parsed.short_description:
            typst += f"{parsed.short_description}\n\n"

        # Long description
        if parsed.long_description:
            typst += f"{parsed.long_description}\n\n"

        # Parameters
        if parsed.params:
            typst += "*Parameters:*\n\n"
            for param in parsed.params:
                typst += format_parameter(param) + "\n"
            typst += "\n"

        # Returns
        if parsed.returns:
            return_desc = parsed.returns.description or ""
            return_type = parsed.returns.type_name or ""
            if return_type:
                typst += f"*Returns:* _{return_type}_"
            else:
                typst += "*Returns:*"
            if return_desc:
                typst += f" — {return_desc}"
            typst += "\n\n"

        # Raises
        if parsed.raises:
            typst += "*Raises:*\n\n"
            for exc in parsed.raises:
                typst += f"- `{exc.type_name}`"
                if exc.description:
                    typst += f": {exc.description}"
                typst += "\n"
            typst += "\n"

        # Examples
        if parsed.examples:
            typst += "*Examples:*\n\n"
            typst += f"```python\n{parsed.examples.strip()}\n```\n\n"
    else:
        typst += "_No documentation available._\n\n"

    return typst


def format_class(class_name: str, class_data) -> str:
    """Format a class as Typst markup."""

    typst = f"=== Class: `{class_name}`\n\n"

    # Class docstring
    if class_data.docstring and class_data.docstring.value:
        typst += f"{class_data.docstring.value}\n\n"

    # Methods (skip aliases)
    methods = {}
    for name, member in class_data.members.items():
        if name.startswith("_"):
            continue
        # Skip aliases
        if member.kind.value == "alias":
            continue
        # Check if it's a method
        try:
            if member.is_function:
                methods[name] = member
        except Exception:
            continue

    if methods:
        typst += "==== Methods\n\n"
        for method_name, method_data in methods.items():
            typst += format_function(method_name, method_data)

    return typst


def extract_module(module_path: str) -> str:
    """Extract documentation from a Python module."""

    try:
        # Load module without importing (AST-based)
        # Try to load from current directory structure
        module = griffe.load(
            module_path, search_paths=[str(Path("example/python-project"))]
        )
    except Exception as e:
        # Try alternative: load the file directly
        try:
            file_path = Path(
                f"example/python-project/{module_path.replace('.', '/')}.py"
            )
            if file_path.exists():
                module = griffe.load(
                    module_path, search_paths=[str(Path("example/python-project"))]
                )
            else:
                print(f"  ⚠ Error loading module {module_path}: {e}", file=sys.stderr)
                return f"= Module: `{module_path}`\n\n_Could not load module_\n\n"
        except Exception as e2:
            print(f"  ⚠ Error loading module {module_path}: {e2}", file=sys.stderr)
            return f"= Module: `{module_path}`\n\n_Could not load module_\n\n"

    typst = f"= Module: `{module.name}`\n\n"

    # Module docstring
    if module.docstring and module.docstring.value:
        typst += f"{module.docstring.value}\n\n"

    # Functions (skip aliases to avoid resolution errors)
    functions = {}
    for name, member in module.members.items():
        if name.startswith("_"):
            continue
        # Skip aliases (imports)
        if member.kind.value == "alias":
            continue
        # Check if it's a function
        try:
            if member.is_function:
                functions[name] = member
        except Exception:
            # Skip members that can't be checked
            continue

    if functions:
        typst += "== Functions\n\n"
        for func_name, func_data in functions.items():
            typst += format_function(func_name, func_data)

    # Classes (skip aliases to avoid resolution errors)
    classes = {}
    for name, member in module.members.items():
        if name.startswith("_"):
            continue
        # Skip aliases (imports)
        if member.kind.value == "alias":
            continue
        # Check if it's a class
        try:
            if member.is_class:
                classes[name] = member
        except Exception:
            # Skip members that can't be checked
            continue

    if classes:
        typst += "== Classes\n\n"
        for class_name, class_data in classes.items():
            typst += format_class(class_name, class_data)

    return typst


def main():
    """Main entry point."""

    # Output directory
    output_dir = Path("example/generated")
    output_dir.mkdir(exist_ok=True)

    print("📖 Extracting API documentation...")

    # Extract from each module
    modules = ["src.hello", "src.main"]

    all_docs = "= API Reference\n\n"
    all_docs += "This section contains auto-generated API documentation extracted from Python docstrings.\n\n"

    for module_path in modules:
        print(f"  Processing {module_path}...")
        try:
            module_docs = extract_module(module_path)
            all_docs += module_docs + "\n"
        except Exception as e:
            print(f"  ✗ Error: {e}", file=sys.stderr)
            continue

    # Write combined output
    output_file = output_dir / "api-reference.typ"
    output_file.write_text(all_docs)

    print(f"✅ Generated {output_file}")
    print(f"   Total size: {len(all_docs)} bytes")


if __name__ == "__main__":
    # Add parent directory to path so we can import from src
    sys.path.insert(0, str(Path(__file__).parent.parent / "example" / "python-project"))
    main()
