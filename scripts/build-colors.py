#!/usr/bin/env python3
"""
Color palette generator.

Reads colors.json and generates:
- generated/colors.css (CSS custom properties with dark mode support)
- generated/colors.typ (Typst color definitions)

Usage:
    python3 build-colors.py
"""

import json
import sys
from pathlib import Path


def load_colors(colors_file: Path) -> dict:
    """Load color configuration from JSON file."""
    with colors_file.open() as f:
        return json.load(f)


def generate_css(colors: dict, output_file: Path):
    """Generate CSS custom properties from color configuration."""

    css_lines = [
        "/* Auto-generated from colors.json - DO NOT EDIT MANUALLY */",
        "/* Run: python3 build-colors.py to regenerate */",
        "",
        ":root {",
    ]

    # Add light mode colors
    for name, config in colors["colors"].items():
        css_name = f"--color-{name}"
        light_value = config["light"]
        comment = f"  /* {config['description']} */" if "description" in config else ""

        if comment:
            css_lines.append(comment)
        css_lines.append(f"  {css_name}: {light_value};")

    css_lines.append("}")
    css_lines.append("")

    # Add dark mode colors (system preference)
    css_lines.append("@media (prefers-color-scheme: dark) {")
    css_lines.append("  :root {")

    for name, config in colors["colors"].items():
        css_name = f"--color-{name}"
        dark_value = config["dark"]
        css_lines.append(f"    {css_name}: {dark_value};")

    css_lines.append("  }")
    css_lines.append("}")
    css_lines.append("")

    # Add explicit dark theme override (Bootstrap data-bs-theme attribute)
    css_lines.append("/* Dark theme via Bootstrap data-bs-theme */")
    css_lines.append("[data-bs-theme='dark'] {")

    for name, config in colors["colors"].items():
        css_name = f"--color-{name}"
        dark_value = config["dark"]
        css_lines.append(f"  {css_name}: {dark_value};")

    css_lines.append("}")
    css_lines.append("")

    # Add explicit light theme override (Bootstrap data-bs-theme attribute)
    css_lines.append(
        "/* Light theme via Bootstrap data-bs-theme (overrides system dark mode) */"
    )
    css_lines.append("[data-bs-theme='light'] {")

    for name, config in colors["colors"].items():
        css_name = f"--color-{name}"
        light_value = config["light"]
        css_lines.append(f"  {css_name}: {light_value};")

    css_lines.append("}")
    css_lines.append("")

    # Also support legacy data-theme for backward compatibility
    css_lines.append("/* Legacy data-theme support (backward compatibility) */")
    css_lines.append("[data-theme='dark'] {")

    for name, config in colors["colors"].items():
        css_name = f"--color-{name}"
        dark_value = config["dark"]
        css_lines.append(f"  {css_name}: {dark_value};")

    css_lines.append("}")
    css_lines.append("")

    css_lines.append("[data-theme='light'] {")

    for name, config in colors["colors"].items():
        css_name = f"--color-{name}"
        light_value = config["light"]
        css_lines.append(f"  {css_name}: {light_value};")

    css_lines.append("}")
    css_lines.append("")

    # Add utility classes for diagrams
    css_lines.extend(
        [
            "/* Utility classes for diagrams */",
            ".diagram {",
            "  max-width: 100%;",
            "  height: auto;",
            "  margin: 1em auto;",
            "  display: block;",
            "}",
            "",
            ".diagram-container {",
            "  text-align: center;",
            "  padding: 1em 0;",
            "}",
            "",
        ]
    )

    output_file.write_text("\n".join(css_lines))
    print(f"✓ Generated {output_file}")


def generate_typst(colors: dict, output_file: Path):
    """Generate Typst color definitions from color configuration."""

    typ_lines = [
        "// Auto-generated from colors.json - DO NOT EDIT MANUALLY",
        "// Run: python3 build-colors.py to regenerate",
        "",
        "// Color definitions for diagrams",
        "",
    ]

    # Generate light mode colors
    typ_lines.append("// Light mode colors (default)")
    for name, config in colors["colors"].items():
        typ_name = name.replace("-", "_")

        # Add _color suffix for names that conflict with Typst built-ins
        if typ_name in ["text", "stroke", "background", "link", "label"]:
            typ_name = typ_name + "_color"

        light_value = config["light"]

        typ_value = "none" if light_value == "transparent" else f'rgb("{light_value}")'

        comment = f"// {config['description']}" if "description" in config else ""
        if comment:
            typ_lines.append(comment)
        typ_lines.append(f"#let {typ_name} = {typ_value}")

    typ_lines.append("")
    typ_lines.append("// Dark mode colors")
    typ_lines.append("// Note: Use these when generating dark mode variants")

    for name, config in colors["colors"].items():
        base_name = name.replace("-", "_")

        # Add _color suffix for names that conflict with Typst built-ins
        if base_name in ["text", "stroke", "background", "link", "label"]:
            base_name = base_name + "_color"

        typ_name = f"{base_name}_dark"
        dark_value = config["dark"]

        typ_value = "none" if dark_value == "transparent" else f'rgb("{dark_value}")'

        typ_lines.append(f"#let {typ_name} = {typ_value}")

    typ_lines.append("")

    # Add theme helper functions
    typ_lines.extend(
        [
            "// ============================================",
            "// THEME HELPERS",
            "// ============================================",
            "",
            "// Get current theme from sys.inputs (defaults to 'light')",
            '#let get-theme() = sys.inputs.at("theme", default: "light")',
            "",
            "// Select color based on theme",
            "#let theme-color(light, dark) = {",
            '  if get-theme() == "dark" { dark } else { light }',
            "}",
            "",
            "// ============================================",
            "// SEMANTIC THEME-AWARE COLORS",
            "// ============================================",
            "// These automatically select the right color based on theme",
            "",
        ]
    )

    # Generate semantic color shortcuts
    for name, config in colors["colors"].items():
        base_name = name.replace("-", "_")

        # Add _color suffix for names that conflict with Typst built-ins
        if base_name in ["text", "stroke", "background", "link", "label"]:
            base_name = base_name + "_color"

        # Create short name for common use
        short_name = base_name.replace("_color", "-c").replace("_", "-")

        comment = (
            f"// {config['description']}" if "description" in config else f"// {name}"
        )
        typ_lines.append(comment)
        typ_lines.append(
            f"#let {short_name} = theme-color({base_name}, {base_name}_dark)"
        )

    typ_lines.append("")

    output_file.write_text("\n".join(typ_lines))
    print(f"✓ Generated {output_file}")


def main():
    """Main entry point."""
    project_root = Path(__file__).parent.parent  # Go up from scripts/ to project root
    colors_file = project_root / "lib" / "colors.json"
    generated_dir = project_root / "lib" / "generated"

    # Check if colors.json exists
    if not colors_file.exists():
        print(f"Error: {colors_file} not found")
        sys.exit(1)

    # Create generated directory
    generated_dir.mkdir(exist_ok=True)

    # Load colors
    print("Loading color configuration...")
    colors = load_colors(colors_file)

    # Generate output files
    print("\nGenerating output files...")
    generate_css(colors, generated_dir / "colors.css")
    generate_typst(colors, generated_dir / "colors.typ")

    print("\n" + "=" * 50)
    print("✓ Color generation complete!")
    print("\nNext steps:")
    print("1. Include 'generated/colors.typ' in your diagram files")
    print("2. Link 'generated/colors.css' in your HTML")
    print("3. Run build-diagrams.py to regenerate SVGs")

    return 0


if __name__ == "__main__":
    sys.exit(main())
