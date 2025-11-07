#!/usr/bin/env python3
"""
Python documentation extraction script.

This script:
1. Scans Python files for docstrings (module, class, function level)
2. Extracts documentation in a structured format
3. Generates JSON output that can be consumed by Typst
4. Optionally generates a Typst include file with formatted documentation

Usage:
    python build-python-docs.py [project_dir] [--output-format json|typst|both]

    project_dir: Python project directory (default: example/python-project)
    --output-format: Output format (default: both)
"""

import argparse
import ast
import json
import sys
from pathlib import Path
from typing import Any


def extract_docstring(node: ast.AST) -> str | None:
    """Extract docstring from an AST node."""
    if isinstance(node, (ast.FunctionDef, ast.ClassDef, ast.Module)):
        docstring = ast.get_docstring(node)
        return docstring if docstring else None
    return None


def parse_google_docstring(docstring: str) -> dict[str, Any]:
    """
    Parse Google-style docstring into structured format.

    Args:
        docstring: The docstring to parse

    Returns:
        Dictionary with sections: description, args, returns, raises, etc.
    """
    if not docstring:
        return {"description": ""}

    lines = docstring.split("\n")
    sections = {"description": "", "args": [], "returns": "", "raises": []}

    current_section = "description"
    current_content = []

    for line in lines:
        line_stripped = line.strip()

        # Check for section headers
        if line_stripped in ("Args:", "Arguments:"):
            sections[current_section] = "\n".join(current_content).strip()
            current_section = "args"
            current_content = []
        elif line_stripped in ("Returns:", "Return:"):
            sections[current_section] = (
                "\n".join(current_content).strip()
                if current_section == "description"
                else current_content
            )
            current_section = "returns"
            current_content = []
        elif line_stripped in ("Raises:", "Raise:"):
            sections[current_section] = (
                "\n".join(current_content).strip()
                if current_section in ("description", "returns")
                else current_content
            )
            current_section = "raises"
            current_content = []
        else:
            if current_section in ("args", "raises") and line_stripped:
                # Parse argument/exception line (format: "name: description")
                if ":" in line_stripped:
                    parts = line_stripped.split(":", 1)
                    current_content.append(
                        {"name": parts[0].strip(), "description": parts[1].strip()}
                    )
            else:
                current_content.append(line)

    # Finalize last section
    if current_section == "description":
        sections[current_section] = "\n".join(current_content).strip()
    elif current_section == "returns":
        sections[current_section] = "\n".join(current_content).strip()
    else:
        sections[current_section] = current_content

    return sections


def extract_function_info(node: ast.FunctionDef) -> dict[str, Any]:
    """Extract information from a function definition."""
    docstring = extract_docstring(node)
    parsed_doc = parse_google_docstring(docstring) if docstring else {}

    # Extract type hints from annotations
    args_info = []
    for arg in node.args.args:
        arg_name = arg.arg
        arg_type = ast.unparse(arg.annotation) if arg.annotation else None

        # Find description from parsed docstring
        arg_desc = ""
        for doc_arg in parsed_doc.get("args", []):
            if isinstance(doc_arg, dict) and doc_arg.get("name") == arg_name:
                arg_desc = doc_arg.get("description", "")
                break

        args_info.append({"name": arg_name, "type": arg_type, "description": arg_desc})

    return_type = ast.unparse(node.returns) if node.returns else None

    return {
        "name": node.name,
        "type": "function",
        "docstring": docstring or "",
        "description": parsed_doc.get("description", ""),
        "args": args_info,
        "returns": {
            "type": return_type,
            "description": parsed_doc.get("returns", ""),
        },
        "raises": parsed_doc.get("raises", []),
        "lineno": node.lineno,
    }


def extract_class_info(node: ast.ClassDef) -> dict[str, Any]:
    """Extract information from a class definition."""
    docstring = extract_docstring(node)
    parsed_doc = parse_google_docstring(docstring) if docstring else {}

    # Extract methods
    methods = []
    for item in node.body:
        if isinstance(item, ast.FunctionDef):
            methods.append(extract_function_info(item))

    return {
        "name": node.name,
        "type": "class",
        "docstring": docstring or "",
        "description": parsed_doc.get("description", ""),
        "methods": methods,
        "lineno": node.lineno,
    }


def extract_module_info(filepath: Path) -> dict[str, Any]:
    """Extract documentation from a Python module."""
    try:
        content = filepath.read_text(encoding="utf-8")
        tree = ast.parse(content, filename=str(filepath))
    except Exception as e:
        print(f"  ✗ Error parsing {filepath}: {e}")
        return None

    module_docstring = extract_docstring(tree)
    parsed_doc = parse_google_docstring(module_docstring) if module_docstring else {}

    functions = []
    classes = []

    for node in ast.iter_child_nodes(tree):
        if isinstance(node, ast.FunctionDef):
            functions.append(extract_function_info(node))
        elif isinstance(node, ast.ClassDef):
            classes.append(extract_class_info(node))

    return {
        "path": str(filepath.relative_to(Path.cwd())),
        "name": filepath.stem,
        "docstring": module_docstring or "",
        "description": parsed_doc.get("description", ""),
        "functions": functions,
        "classes": classes,
    }


def scan_python_project(project_dir: Path) -> list[dict[str, Any]]:
    """Scan a Python project directory for documentation."""
    modules = []

    # Find all Python files
    python_files = sorted(project_dir.rglob("*.py"))

    # Filter out __pycache__ and test files if desired
    python_files = [
        f
        for f in python_files
        if "__pycache__" not in str(f) and not f.name.startswith("test_")
    ]

    print(f"Found {len(python_files)} Python file(s) to process\n")

    for filepath in python_files:
        print(f"Processing {filepath.relative_to(Path.cwd())}...")
        module_info = extract_module_info(filepath)
        if module_info:
            modules.append(module_info)
            print(f"  ✓ Extracted documentation")

    return modules


def generate_json_output(modules: list[dict[str, Any]], output_file: Path):
    """Generate JSON output file."""
    output = {"modules": modules, "generated_by": "build-python-docs.py"}

    with output_file.open("w", encoding="utf-8") as f:
        json.dump(output, f, indent=2)

    print(f"\n✓ Generated {output_file}")


def escape_typst_string(text: str) -> str:
    """Escape special characters for Typst strings."""
    # Escape backslashes first, then other special characters
    return text.replace("\\", "\\\\").replace('"', '\\"').replace("#", "\\#")


def generate_typst_output(modules: list[dict[str, Any]], output_file: Path):
    """Generate Typst include file with formatted documentation."""
    lines = [
        "// Auto-generated Python documentation - DO NOT EDIT MANUALLY",
        "// Run: python3 scripts/build-python-docs.py to regenerate",
        "",
        "// Python Documentation Display Functions",
        "",
    ]

    # Add helper functions for rendering documentation
    lines.extend(
        [
            "#let python-function(name, args, returns, description, raises: none) = {",
            "  block(",
            "    fill: rgb(\"#f8f8f8\"),",
            "    inset: 12pt,",
            "    radius: 4pt,",
            "    width: 100%,",
            "  )[",
            "    === #text(font: \"Fira Code\", size: 11pt)[`#name()`]",
            "    ",
            "    #if description != \"\" [",
            "      #par(justify: false)[#description]",
            "    ]",
            "    ",
            "    #if args.len() > 0 [",
            "      *Arguments:*",
            "      #for arg in args [",
            "        - `#arg.name`#if arg.type != none [ (#arg.type)]#if arg.description != \"\" [: #arg.description]",
            "      ]",
            "    ]",
            "    ",
            "    #if returns.type != none or returns.description != \"\" [",
            "      *Returns:*",
            "      #if returns.type != none [",
            "        Type: `#returns.type`",
            "      ]",
            "      #if returns.description != \"\" [",
            "        #par(justify: false)[#returns.description]",
            "      ]",
            "    ]",
            "    ",
            "    #if raises != none and raises.len() > 0 [",
            "      *Raises:*",
            "      #for exc in raises [",
            "        - `#exc.name`#if exc.description != \"\" [: #exc.description]",
            "      ]",
            "    ]",
            "  ]",
            "}",
            "",
        ]
    )

    # Generate documentation content for each module
    for module in modules:
        module_name = module["name"]
        lines.append(f"// Module: {module_name}")
        lines.append(f"#let doc_{module_name} = {{")

        if module["description"]:
            lines.append(f'  heading(level: 2)[Module: {module_name}]')
            escaped_desc = escape_typst_string(module["description"])
            lines.append(f'  par(justify: false)["{escaped_desc}"]')
            lines.append("")

        # Add functions
        for func in module["functions"]:
            args_typst = []
            for arg in func["args"]:
                arg_type_str = f'"{arg["type"]}"' if arg["type"] else "none"
                arg_desc = escape_typst_string(arg["description"])
                args_typst.append(
                    f'(name: "{arg["name"]}", type: {arg_type_str}, description: "{arg_desc}")'
                )

            returns_type = f'"{func["returns"]["type"]}"' if func["returns"]["type"] else "none"
            returns_desc = escape_typst_string(func["returns"]["description"])

            raises_typst = []
            for exc in func.get("raises", []):
                if isinstance(exc, dict):
                    exc_name = escape_typst_string(exc.get("name", ""))
                    exc_desc = escape_typst_string(exc.get("description", ""))
                    raises_typst.append(f'(name: "{exc_name}", description: "{exc_desc}")')

            escaped_func_desc = escape_typst_string(func["description"])

            lines.append(
                f'  python-function("{func["name"]}", ({", ".join(args_typst)},), '
                f'(type: {returns_type}, description: "{returns_desc}"), '
                f'"{escaped_func_desc}"'
            )
            if raises_typst:
                lines.append(f'    , raises: ({", ".join(raises_typst)},)')
            lines.append("  )")
            lines.append("")

        lines.append("}")
        lines.append("")

    with output_file.open("w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"✓ Generated {output_file}")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Extract Python documentation and generate output for Typst"
    )
    parser.add_argument(
        "project_dir",
        nargs="?",
        default="example/python-project/src",
        help="Python project directory (default: example/python-project/src)",
    )
    parser.add_argument(
        "--output-format",
        choices=["json", "typst", "both"],
        default="both",
        help="Output format (default: both)",
    )
    parser.add_argument(
        "--output-dir",
        default="lib/generated",
        help="Output directory for generated files (default: lib/generated)",
    )
    args = parser.parse_args()

    project_root = Path(__file__).parent.parent
    project_dir = project_root / args.project_dir
    output_dir = project_root / args.output_dir

    print("Python Documentation Extraction")
    print("=" * 50)
    print(f"Project directory: {project_dir}")

    if not project_dir.exists():
        print(f"Error: project directory not found at {project_dir}")
        sys.exit(1)

    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)

    # Scan project and extract documentation
    print("\nScanning Python project...")
    modules = scan_python_project(project_dir)

    if not modules:
        print("\nWarning: No Python modules found or processed")
        return 0

    print(f"\n✓ Successfully processed {len(modules)} module(s)")

    # Generate output files
    print("\nGenerating output files...")

    if args.output_format in ("json", "both"):
        json_output = output_dir / "python-docs.json"
        generate_json_output(modules, json_output)

    if args.output_format in ("typst", "both"):
        typst_output = output_dir / "python-docs.typ"
        generate_typst_output(modules, typst_output)

    print("\n" + "=" * 50)
    print("✓ Python documentation extraction complete!")
    print("\nNext steps:")
    print("1. Include 'generated/python-docs.typ' in your Typst documents")
    print("2. Use the generated documentation functions in your documents")
    print("   Example: #doc_hello  // Display hello.py documentation")

    return 0


if __name__ == "__main__":
    sys.exit(main())
