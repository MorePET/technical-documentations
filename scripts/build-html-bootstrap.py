#!/usr/bin/env python3
"""
Complete Bootstrap HTML build workflow.

This script:
1. Compiles Typst document to HTML (with use-svg=true flag)
2. Post-processes HTML to inject SVG diagrams
3. Adds Bootstrap classes to HTML elements
4. Adds Bootstrap CSS/JS and custom styling
5. Optionally adds theme toggle and TOC sidebar

Usage:
    python3 build-html-bootstrap.py input.typ output.html [--no-theme-toggle] [--no-toc]
"""

import shutil
import subprocess
import sys
from pathlib import Path


def compile_typst_to_html(typ_file: Path, html_file: Path) -> bool:
    """Compile Typst document to HTML with SVG support."""
    print(f"Compiling {typ_file} to HTML...")

    try:
        result = subprocess.run(
            [
                "typst",
                "compile",
                "--root",
                ".",
                "--features",
                "html",
                "--input",
                "use-svg=true",
                str(typ_file),
                str(html_file),
            ],
            capture_output=True,
            text=True,
            check=True,
        )

        # Filter out warnings
        if result.stderr:
            lines = result.stderr.split("\n")
            errors = [line for line in lines if "error:" in line.lower()]
            if errors:
                print("Errors:")
                for error in errors:
                    print(f"  {error}")

        print(f"  ✓ Compiled to {html_file}")
        return True

    except subprocess.CalledProcessError as e:
        print(f"  ✗ Error compiling: {e.stderr}")
        return False
    except FileNotFoundError:
        print("  ✗ Error: 'typst' command not found.")
        return False


def post_process_html(input_html: Path, output_html: Path) -> bool:
    """Run HTML post-processing to inject SVGs."""
    print("\nPost-processing HTML (injecting SVG diagrams)...")

    script = Path(__file__).parent / "post-process-html.py"

    try:
        result = subprocess.run(
            ["python3", str(script), str(input_html), str(output_html)],
            capture_output=True,
            text=True,
            check=True,
        )

        if result.stdout:
            print(result.stdout)

        return True

    except subprocess.CalledProcessError as e:
        print(f"  ✗ Error post-processing: {e.stderr}")
        return False


def add_bootstrap_classes(input_html: Path, output_html: Path) -> bool:
    """Add Bootstrap classes to HTML elements."""
    print("\nAdding Bootstrap classes to elements...")

    script = Path(__file__).parent / "add-bootstrap-classes.py"

    try:
        result = subprocess.run(
            ["python3", str(script), str(input_html), str(output_html)],
            capture_output=True,
            text=True,
            check=True,
        )

        if result.stdout:
            print(result.stdout)

        return True

    except subprocess.CalledProcessError as e:
        print(f"  ✗ Error adding classes: {e.stderr}")
        return False


def copy_css(output_html: Path):
    """Copy Bootstrap custom CSS and colors.css to the same directory as the HTML."""
    project_root = Path(__file__).parent.parent

    # Copy styles-bootstrap.css
    styles_source = project_root / "lib" / "styles-bootstrap.css"
    styles_dest = output_html.parent / "styles-bootstrap.css"

    if not styles_source.exists():
        print(f"\n⚠ Warning: {styles_source} not found")
        return False

    # Copy colors.css
    colors_source = project_root / "lib" / "generated" / "colors.css"
    colors_dest = output_html.parent / "colors.css"

    if not colors_source.exists():
        print(f"\n⚠ Warning: {colors_source} not found")
        return False

    try:
        shutil.copy(styles_source, styles_dest)
        print(f"\n✓ Copied styles-bootstrap.css to {styles_dest}")
        shutil.copy(colors_source, colors_dest)
        print(f"✓ Copied colors.css to {colors_dest}")
        return True
    except Exception as e:
        print(f"\n✗ Error copying CSS: {e}")
        return False


def add_bootstrap_styling(
    output_html: Path, theme_toggle: bool = True, toc_sidebar: bool = True
) -> bool:
    """Run add-styling-bootstrap.py to add Bootstrap, theme toggle, and TOC sidebar."""
    print("\nAdding Bootstrap styling, theme toggle, and TOC sidebar...")

    script = Path(__file__).parent / "add-styling-bootstrap.py"

    # Build command arguments
    args = ["python3", str(script), str(output_html)]
    if theme_toggle:
        args.append("--theme-toggle")
    if toc_sidebar:
        args.append("--toc-sidebar")
    args.append("--force")

    try:
        result = subprocess.run(args, capture_output=True, text=True, check=True)

        if result.stdout:
            print(result.stdout)

        return True

    except subprocess.CalledProcessError as e:
        print(f"  ✗ Error adding Bootstrap styling: {e.stderr}")
        return False


def fix_trailing_whitespace(html_file: Path) -> None:
    """Remove trailing whitespace from HTML file to pass linter checks."""
    content = html_file.read_text(encoding="utf-8")
    # Strip trailing whitespace from each line
    fixed_content = "\n".join(line.rstrip() for line in content.splitlines())
    # Ensure file ends with newline
    if fixed_content and not fixed_content.endswith("\n"):
        fixed_content += "\n"
    html_file.write_text(fixed_content, encoding="utf-8")


def main():
    """Main entry point."""
    if len(sys.argv) < 3:
        print(
            "Usage: python3 build-html-bootstrap.py input.typ output.html [--no-theme-toggle] [--no-toc]"
        )
        print("\nOptions:")
        print("  --no-theme-toggle  Disable the theme toggle button")
        print("  --no-toc          Disable the table of contents sidebar")
        print("\nExample:")
        print(
            "  python3 build-html-bootstrap.py example/technical-doc-example.typ output.html"
        )
        sys.exit(1)

    typ_file = Path(sys.argv[1])
    html_file = Path(sys.argv[2])
    theme_toggle = "--no-theme-toggle" not in sys.argv
    toc_sidebar = "--no-toc" not in sys.argv

    if not typ_file.exists():
        print(f"Error: Input file not found: {typ_file}")
        sys.exit(1)

    print("=" * 70)
    print("Bootstrap HTML Build Workflow")
    print("=" * 70)

    # Step 1: Compile to HTML
    temp_html = html_file.parent / f"{html_file.stem}_temp.html"
    if not compile_typst_to_html(typ_file, temp_html):
        sys.exit(1)

    # Step 2: Post-process HTML (inject SVGs)
    temp_html2 = html_file.parent / f"{html_file.stem}_temp2.html"
    if not post_process_html(temp_html, temp_html2):
        sys.exit(1)

    # Step 3: Add Bootstrap classes
    temp_html3 = html_file.parent / f"{html_file.stem}_temp3.html"
    if not add_bootstrap_classes(temp_html2, temp_html3):
        sys.exit(1)

    # Step 4: Copy custom CSS
    copy_css(html_file)

    # Step 5: Add Bootstrap styling (CSS/JS, theme toggle, TOC)
    # Copy temp file to final output first
    shutil.copy(temp_html3, html_file)

    if not add_bootstrap_styling(
        html_file, theme_toggle=theme_toggle, toc_sidebar=toc_sidebar
    ):
        sys.exit(1)

    # Step 6: Fix trailing whitespace
    fix_trailing_whitespace(html_file)

    # Clean up temp files
    for temp_file in [temp_html, temp_html2, temp_html3]:
        if temp_file.exists():
            temp_file.unlink()

    print("\n" + "=" * 70)
    print("✓ Bootstrap HTML build complete!")
    print("=" * 70)
    print(f"\nOutput: {html_file}")
    print("\nFeatures:")
    print("  ✅ Bootstrap 5.3.2 styling")
    print("  ✅ Responsive design (mobile-first)")
    print("  ✅ Dark mode support (auto/light/dark)")
    if theme_toggle:
        print("  ✅ Theme toggle button (top-right corner)")
    if toc_sidebar:
        print("  ✅ Table of contents sidebar (collapsible)")
    print("\nTo view:")
    print(f"  Open {html_file} in a browser")
    if theme_toggle:
        print(
            "  🌓 Click the theme button to switch between light (🌕) / dark (🌑) / auto (🌓) modes!"
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
