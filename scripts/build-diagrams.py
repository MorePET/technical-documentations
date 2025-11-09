#!/usr/bin/env python3
"""
Build script for compiling diagrams to SVG format with dual theme support.

This script:
1. Compiles all .typ files in the diagrams/ folder to SVG
2. Generates both light and dark theme versions (-light.svg and -dark.svg)
3. Uses native Typst colors from colors.json (no post-processing needed)

Usage:
    python build-diagrams.py [project]

    project: Project folder name (default: technical-documentation)
             The script will look for diagrams in {project}/diagrams/
"""

import argparse
import json
import re
import subprocess
import sys
import time
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path


def load_colors(colors_file: Path) -> dict:
    """Load color configuration from colors.json."""
    if not colors_file.exists():
        print(f"Warning: {colors_file} not found")
        return {"colors": {}}

    with colors_file.open() as f:
        return json.load(f)


def generate_color_definitions(colors: dict, theme: str) -> str:
    """Generate Typst color definitions for a specific theme."""
    lines = [
        f"// Auto-generated {theme} theme colors",
        "",
    ]

    for name, config in colors["colors"].items():
        color_value = config[theme]
        # Convert kebab-case to snake_case and add _color suffix to avoid conflicts
        typst_name = name.replace("-", "_")

        # Add _color suffix for common names that might conflict with Typst functions
        if typst_name in ["text", "stroke", "background", "link", "label"]:
            typst_name = typst_name + "_color"

        if color_value.lower() == "transparent":
            typst_value = "none"
        else:
            typst_value = f'rgb("{color_value}")'

        lines.append(f"#let {typst_name} = {typst_value}")

    return "\n".join(lines)


def inject_colors_into_diagram(typ_content: str, color_definitions: str) -> str:
    """Inject color definitions into diagram .typ file."""
    # Find where to inject (after imports, before page settings)
    # Look for the fletcher import line
    import_pattern = r"(#import\s+[^\n]+\n)"

    match = re.search(import_pattern, typ_content)
    if match:
        # Insert after the last import
        insert_pos = match.end()
        return (
            typ_content[:insert_pos]
            + "\n"
            + color_definitions
            + "\n"
            + typ_content[insert_pos:]
        )
    else:
        # No imports found, insert at the beginning
        return color_definitions + "\n\n" + typ_content


def remove_white_background(svg_file: Path) -> bool:
    """Remove white background from SVG."""
    try:
        content = svg_file.read_text()

        # Remove white page backgrounds
        # Replace fill="#ffffff" or fill="#FFFFFF" in <path> tags (page background)
        new_content = re.sub(
            r'<path[^>]*fill="#[fF]{6}"[^>]*fill-rule="nonzero"[^>]*>', "", content
        )

        if new_content != content:
            svg_file.write_text(new_content)
            return True

        return False
    except Exception as e:
        print(f"  ⚠ Warning: Could not remove background from {svg_file.name}: {e}")
        return False


def compile_diagram_theme(typ_file: Path, theme: str) -> bool:
    """Compile a diagram for a specific theme using --input."""
    base_name = typ_file.stem
    # Output to build/diagrams/ directory
    project_root = Path(__file__).parent.parent
    # Get relative project path (e.g., "example" or "technical-documentation")
    relative_to_root = typ_file.parent.relative_to(project_root)
    project_name = relative_to_root.parts[0]  # First part is project name
    build_diagrams_dir = project_root / project_name / "build" / "diagrams"
    build_diagrams_dir.mkdir(parents=True, exist_ok=True)
    svg_file = build_diagrams_dir / f"{base_name}-{theme}.svg"

    print(f"  Compiling {theme} theme → {svg_file.name}...")
    start_time = time.time()

    try:
        # Compile with Typst, passing theme as input
        # Use --root to allow importing from lib/generated/
        t0 = time.time()
        subprocess.run(
            [
                "typst",
                "compile",
                "--root",
                str(project_root),
                "--input",
                f"theme={theme}",
                str(typ_file),
                str(svg_file),
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        compile_time = time.time() - t0

        # Remove white background
        t0 = time.time()
        remove_white_background(svg_file)
        bg_remove_time = time.time() - t0

        total_time = time.time() - start_time

        print(f"    ✓ Successfully created {svg_file.name} ({total_time * 1000:.1f}ms)")
        print(
            f"      [typst: {compile_time * 1000:.1f}ms | bg-remove: {bg_remove_time * 1000:.1f}ms]"
        )
        return True

    except subprocess.CalledProcessError as e:
        print(f"    ✗ Error compiling {theme} theme:")
        print(f"      {e.stderr}")
        return False
    except FileNotFoundError:
        print("    ✗ Error: 'typst' command not found. Please install Typst.")
        return False
    except Exception as e:
        print(f"    ✗ Unexpected error: {e}")
        return False


def compile_diagram_both_themes(typ_file: Path) -> bool:
    """Compile a diagram for both light and dark themes."""
    print(f"Compiling {typ_file.name}...")

    # Compile both themes (theme is passed via --input to typst)
    light_success = compile_diagram_theme(typ_file, "light")
    dark_success = compile_diagram_theme(typ_file, "dark")

    # Create base .svg file (copy of light version) for Typst HTML compilation
    if light_success:
        project_root = Path(__file__).parent.parent
        relative_to_root = typ_file.parent.relative_to(project_root)
        project_name = relative_to_root.parts[0]
        build_diagrams_dir = project_root / project_name / "build" / "diagrams"
        base_name = typ_file.stem
        light_file = build_diagrams_dir / f"{base_name}-light.svg"
        base_file = build_diagrams_dir / f"{base_name}.svg"

        try:
            import shutil

            shutil.copy(light_file, base_file)
            print(f"    ✓ Created base file {base_file.name}")
        except Exception as e:
            print(f"    ⚠ Warning: Could not create base file: {e}")

    return light_success and dark_success


def main():
    """Compile all diagram files to SVG with dual theme support."""
    # Parse command-line arguments
    parser = argparse.ArgumentParser(
        description="Compile diagrams to SVG (light + dark themes)"
    )
    parser.add_argument(
        "project",
        nargs="?",
        default="technical-documentation",
        help="Project folder name (default: technical-documentation)",
    )
    args = parser.parse_args()

    project_root = Path(__file__).parent.parent  # Go up from scripts/ to project root
    project_dir = project_root / args.project
    diagrams_dir = project_dir / "diagrams"
    colors_file = project_root / "lib" / "colors.json"

    print(f"Building diagrams for project: {args.project}")
    print("=" * 60)

    if not project_dir.exists():
        print(f"Error: project directory not found at {project_dir}")
        sys.exit(1)

    if not diagrams_dir.exists():
        print(f"Warning: diagrams directory not found at {diagrams_dir}")
        print("Creating empty diagrams directory...")
        diagrams_dir.mkdir(parents=True, exist_ok=True)

    # Load colors configuration
    print("Loading color configuration from colors.json...")
    colors = load_colors(colors_file)
    print(f"Loaded {len(colors['colors'])} color definition(s)\n")

    # Find all .typ files in the diagrams directory
    typ_files = sorted(diagrams_dir.glob("*.typ"))

    if not typ_files:
        print(f"No .typ files found in {diagrams_dir}")
        print("Nothing to compile.")
        return 0

    print(f"Found {len(typ_files)} diagram(s) to compile")

    # Compile diagrams in parallel for faster build times
    overall_start = time.time()
    success_count = 0

    # Use ProcessPoolExecutor for true parallelism (not limited by GIL)
    max_workers = min(len(typ_files), 8)  # Use up to 8 workers
    print(f"⚡ Using parallel compilation with {max_workers} worker(s)\n")

    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        # Submit all compilation tasks
        future_to_file = {
            executor.submit(compile_diagram_both_themes, typ_file): typ_file
            for typ_file in typ_files
        }

        # Process results as they complete
        for future in as_completed(future_to_file):
            typ_file = future_to_file[future]
            try:
                if future.result():
                    success_count += 1
                print()  # Empty line between files
            except Exception as e:
                print(f"✗ Error compiling {typ_file.name}: {e}")
                print()

    overall_time = time.time() - overall_start

    # Summary
    print("=" * 60)
    print(f"Compilation complete: {success_count}/{len(typ_files)} successful")
    print(f"Generated {success_count * 2} SVG files (light + dark themes)")
    print(f"Total time: {overall_time:.3f}s ({overall_time * 1000:.1f}ms)")
    print(
        f"Average per diagram: {(overall_time / len(typ_files)):.3f}s ({(overall_time / len(typ_files)) * 1000:.1f}ms)"
    )

    if success_count == len(typ_files):
        print("\n✓ All diagrams compiled successfully!")
        print("\nNext steps:")
        print("  - Use post-process-html.py to inject SVGs into HTML")
        print("  - Both light and dark theme SVGs are now available")
        return 0
    else:
        print(f"\n✗ {len(typ_files) - success_count} diagram(s) failed to compile")
        return 1


if __name__ == "__main__":
    sys.exit(main())
