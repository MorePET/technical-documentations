#!/usr/bin/env python3
"""
Build script for compiling diagrams to SVG format.

This script:
1. Compiles all .typ files in the diagrams/ folder to SVG
2. Post-processes SVGs to use CSS variables for dark mode support
3. Removes white backgrounds and injects CSS imports

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
from pathlib import Path


def load_color_mappings(colors_file: Path) -> dict:
    """Load color configuration and create RGB to CSS variable mappings."""
    if not colors_file.exists():
        print(f"Warning: {colors_file} not found, skipping color mapping")
        return {}
    
    with open(colors_file, 'r') as f:
        config = json.load(f)
    
    mappings = {}
    for name, color_config in config['colors'].items():
        light_color = color_config['light'].lower()
        if light_color != 'transparent':
            mappings[light_color] = f"var(--color-{name})"
    
    return mappings


def post_process_svg(svg_file: Path, color_mappings: dict) -> bool:
    """Post-process SVG to use CSS variables and remove white background."""
    try:
        content = svg_file.read_text()
        original_content = content
        
        # Remove white page backgrounds
        # Replace fill="#ffffff" or fill="#FFFFFF" in <path> tags (page background)
        content = re.sub(
            r'<path[^>]*fill="#[fF]{6}"[^>]*fill-rule="nonzero"[^>]*>',
            '',
            content
        )
        
        # Replace hard-coded colors with CSS variables
        for hex_color, css_var in color_mappings.items():
            # Handle both lowercase and uppercase hex
            patterns = [
                (hex_color, css_var),
                (hex_color.upper(), css_var),
            ]
            
            for color, var in patterns:
                # Replace fill="color"
                content = content.replace(f'fill="{color}"', f'fill="{var}"')
                # Replace stroke="color"
                content = content.replace(f'stroke="{color}"', f'stroke="{var}"')
        
        # Note: CSS is not embedded in SVGs anymore - it's inlined in the HTML head
        # This allows data-theme attribute to properly affect the SVG variables
        # SVG elements use var(--color-*) which inherit from the parent document
        
        # Only write if content changed
        if content != original_content:
            svg_file.write_text(content)
            print(f"  ✓ Post-processed {svg_file.name}")
        
        return True
        
    except Exception as e:
        print(f"  ✗ Error post-processing {svg_file.name}: {e}")
        return False


def compile_diagram(typ_file: Path, color_mappings: dict) -> bool:
    """Compile a single diagram file to SVG and post-process it."""
    svg_file = typ_file.with_suffix('.svg')
    
    print(f"Compiling {typ_file.name} → {svg_file.name}...")
    
    try:
        result = subprocess.run(
            ['typst', 'compile', str(typ_file), str(svg_file)],
            capture_output=True,
            text=True,
            check=True
        )
        
        if result.stdout:
            print(f"  Output: {result.stdout.strip()}")
        
        print(f"  ✓ Successfully created {svg_file.name}")
        
        # Post-process the SVG
        post_process_svg(svg_file, color_mappings)
        
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"  ✗ Error compiling {typ_file.name}:")
        print(f"    {e.stderr}")
        return False
    except FileNotFoundError:
        print("  ✗ Error: 'typst' command not found. Please install Typst.")
        return False


def main():
    """Compile all diagram files to SVG and post-process them."""
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description='Compile diagrams to SVG')
    parser.add_argument('project', nargs='?', default='technical-documentation',
                       help='Project folder name (default: technical-documentation)')
    args = parser.parse_args()
    
    project_root = Path(__file__).parent.parent  # Go up from scripts/ to project root
    project_dir = project_root / args.project
    diagrams_dir = project_dir / 'diagrams'
    colors_file = project_root / 'lib' / 'colors.json'
    
    print(f"Building diagrams for project: {args.project}")
    
    if not project_dir.exists():
        print(f"Error: project directory not found at {project_dir}")
        sys.exit(1)
    
    if not diagrams_dir.exists():
        print(f"Warning: diagrams directory not found at {diagrams_dir}")
        print(f"Creating empty diagrams directory...")
        diagrams_dir.mkdir(parents=True, exist_ok=True)
    
    # Load color mappings
    print("Loading color mappings...")
    color_mappings = load_color_mappings(colors_file)
    print(f"Loaded {len(color_mappings)} color mapping(s)\n")
    
    # Find all .typ files in the diagrams directory
    typ_files = sorted(diagrams_dir.glob('*.typ'))
    
    if not typ_files:
        print(f"No .typ files found in {diagrams_dir}")
        print("Nothing to compile.")
        return 0
    
    print(f"Found {len(typ_files)} diagram(s) to compile\n")
    
    # Compile each diagram
    success_count = 0
    for typ_file in typ_files:
        if compile_diagram(typ_file, color_mappings):
            success_count += 1
        print()  # Empty line between files
    
    # Summary
    print("=" * 50)
    print(f"Compilation complete: {success_count}/{len(typ_files)} successful")
    
    if success_count == len(typ_files):
        print("\n✓ All diagrams compiled and post-processed successfully!")
        return 0
    else:
        print(f"\n✗ {len(typ_files) - success_count} diagram(s) failed to compile")
        return 1


if __name__ == '__main__':
    sys.exit(main())

