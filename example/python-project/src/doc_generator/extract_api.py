"""Extract API documentation from Python source code using griffe."""

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

    # Signature
    if hasattr(func_data, "parameters") and func_data.parameters:
        params = []
        try:
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
            typst += f"```python\n{func_name}(...)\n```\n\n"

    # Docstring
    if func_data.docstring and func_data.docstring.value:
        parsed = parse_docstring(func_data.docstring.value)

        if parsed.short_description:
            typst += f"{parsed.short_description}\n\n"

        if parsed.long_description:
            typst += f"{parsed.long_description}\n\n"

        if parsed.params:
            typst += "*Parameters:*\n\n"
            for param in parsed.params:
                typst += format_parameter(param) + "\n"
            typst += "\n"

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

        if parsed.raises:
            typst += "*Raises:*\n\n"
            for exc in parsed.raises:
                typst += f"- `{exc.type_name}`"
                if exc.description:
                    typst += f": {exc.description}"
                typst += "\n"
            typst += "\n"

        if parsed.examples:
            typst += "*Examples:*\n\n"
            typst += f"```python\n{parsed.examples.strip()}\n```\n\n"
    else:
        typst += "_No documentation available._\n\n"

    return typst


def format_class(class_name: str, class_data) -> str:
    """Format a class as Typst markup."""

    typst = f"=== Class: `{class_name}`\n\n"

    if class_data.docstring and class_data.docstring.value:
        typst += f"{class_data.docstring.value}\n\n"

    # Methods
    methods = {}
    for name, member in class_data.members.items():
        if name.startswith("_"):
            continue
        if member.kind.value == "alias":
            continue
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


def extract_module(module_path: str, search_path: Path) -> str:
    """Extract documentation from a Python module."""

    try:
        module = griffe.load(module_path, search_paths=[str(search_path)])
    except Exception as e:
        print(f"  ⚠ Error loading module {module_path}: {e}", file=sys.stderr)
        return f"= Module: `{module_path}`\n\n_Could not load module_\n\n"

    typst = f"= Module: `{module.name}`\n\n"

    if module.docstring and module.docstring.value:
        typst += f"{module.docstring.value}\n\n"

    # Functions
    functions = {}
    for name, member in module.members.items():
        if name.startswith("_"):
            continue
        if member.kind.value == "alias":
            continue
        try:
            if member.is_function:
                functions[name] = member
        except Exception:
            continue

    if functions:
        typst += "== Functions\n\n"
        for func_name, func_data in functions.items():
            typst += format_function(func_name, func_data)

    # Classes
    classes = {}
    for name, member in module.members.items():
        if name.startswith("_"):
            continue
        if member.kind.value == "alias":
            continue
        try:
            if member.is_class:
                classes[name] = member
        except Exception:
            continue

    if classes:
        typst += "== Classes\n\n"
        for class_name, class_data in classes.items():
            typst += format_class(class_name, class_data)

    return typst


def generate_api_docs(
    modules: list[str], output_file: Path, project_root: Path
) -> None:
    """Generate API documentation for specified modules.

    Args:
        modules: List of module names to document (e.g., ['src.hello', 'src.main'])
        output_file: Path where to write the output .typ file
        project_root: Root directory of the project
    """
    print("📖 Extracting API documentation...")

    all_docs = "= API Reference\n\n"
    all_docs += "This section contains auto-generated API documentation extracted from Python docstrings.\n\n"

    for module_path in modules:
        print(f"  Processing {module_path}...")
        try:
            module_docs = extract_module(module_path, project_root)
            all_docs += module_docs + "\n"
        except Exception as e:
            print(f"  ✗ Error: {e}", file=sys.stderr)
            continue

    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(all_docs)

    print(f"✅ Generated {output_file}")
    print(f"   Total size: {len(all_docs)} bytes")


if __name__ == "__main__":
    # Example usage
    project_root = Path(__file__).parent.parent.parent
    output = project_root / "build" / "generated" / "api-reference.typ"
    generate_api_docs(["src.hello", "src.main"], output, project_root)
