#!/usr/bin/env python3
"""
Complete HTML build workflow.

This script:
1. Compiles Typst document to HTML (with use-svg=true flag)
2. Post-processes HTML to inject SVG diagrams
3. Copies colors.css to output directory

Usage:
    python3 build-html.py input.typ output.html
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
    print("\nPost-processing HTML...")

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


def copy_css(output_html: Path):
    """Copy colors.css and styles.css to the same directory as the HTML."""
    project_root = Path(__file__).parent.parent  # Go up from scripts/ to project root

    # Copy colors.css
    colors_source = project_root / "lib" / "generated" / "colors.css"
    colors_dest = output_html.parent / "colors.css"

    if not colors_source.exists():
        print(f"\nWarning: {colors_source} not found. Run build-colors.py first.")
        return False

    # Copy styles.css
    styles_source = project_root / "lib" / "styles.css"
    styles_dest = output_html.parent / "styles.css"

    try:
        shutil.copy(colors_source, colors_dest)
        print(f"\n✓ Copied colors.css to {colors_dest}")

        if styles_source.exists():
            shutil.copy(styles_source, styles_dest)
            print(f"✓ Copied styles.css to {styles_dest}")
        else:
            print(f"⚠ Warning: {styles_source} not found")

        return True
    except Exception as e:
        print(f"\n✗ Error copying CSS: {e}")
        return False


def add_styling(output_html: Path, theme_toggle: bool = True) -> bool:
    """Run add-styling.py to add theme toggle and TOC sidebar."""
    print("\nAdding styling enhancements...")

    script = Path(__file__).parent / "add-styling.py"

    # Build command arguments
    args = ["python3", str(script), str(output_html)]
    if theme_toggle:
        args.append("--theme-toggle")
    args.extend(["--toc-sidebar", "--force"])

    try:
        result = subprocess.run(args, capture_output=True, text=True, check=True)

        if result.stdout:
            print(result.stdout)

        return True

    except subprocess.CalledProcessError as e:
        print(f"  ✗ Error adding styling: {e.stderr}")
        return False


def main():
    """Main entry point."""
    if len(sys.argv) < 3:
        print("Usage: python3 build-html.py input.typ output.html [--no-theme-toggle]")
        print("\nExample:")
        print("  python3 build-html.py diagram-test.typ diagram-test.html")
        print(
            "  python3 build-html.py diagram-test.typ diagram-test.html --no-theme-toggle"
        )
        sys.exit(1)

    typ_file = Path(sys.argv[1])
    html_file = Path(sys.argv[2])
    theme_toggle = "--no-theme-toggle" not in sys.argv

    if not typ_file.exists():
        print(f"Error: Input file not found: {typ_file}")
        sys.exit(1)

    print("=" * 60)
    print("HTML Build Workflow")
    print("=" * 60)

    # Step 1: Compile to HTML
    temp_html = html_file.parent / f"{html_file.stem}_temp.html"
    if not compile_typst_to_html(typ_file, temp_html):
        sys.exit(1)

    # Step 2: Post-process HTML
    if not post_process_html(temp_html, html_file):
        sys.exit(1)

    # Step 3: Copy CSS
    copy_css(html_file)

    # Step 4: Add styling enhancements (theme toggle, TOC sidebar)
    if not add_styling(html_file, theme_toggle=theme_toggle):
        sys.exit(1)

    # Clean up temp file
    if temp_html.exists():
        temp_html.unlink()

    print("\n" + "=" * 60)
    print("✓ HTML build complete!")
    print("=" * 60)
    print(f"\nOutput: {html_file}")
    print("\nTo view:")
    print(f"  Open {html_file} in a browser")
    if theme_toggle:
        print(
            "  🌓 Click the theme button to switch between light (🌕) / dark (🌑) / auto (🌓) modes!"
        )
    else:
        print("  🌓 Dark mode follows your system settings (auto mode)")
    print("  Use the TOC sidebar on the left to navigate sections!")

    return 0


if __name__ == "__main__":
    sys.exit(main())
