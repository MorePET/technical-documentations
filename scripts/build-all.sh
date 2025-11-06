#!/bin/bash
# build-all.sh - Complete build script for technical documentation
# This script orchestrates the entire build pipeline
# Usage: ./build-all.sh [project]
#   project: Project folder name (default: technical-documentation)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project name (default: technical-documentation)
PROJECT="${1:-technical-documentation}"

# Determine source and output file names based on project
if [ "$PROJECT" = "example" ]; then
    SRC_FILE="example/technical-doc-example.typ"
    OUT_NAME="technical-doc-example"
elif [ "$PROJECT" = "technical-documentation" ]; then
    SRC_FILE="technical-documentation/technical-documentation.typ"
    OUT_NAME="technical-documentation"
else
    # Generic pattern for other projects
    SRC_FILE="${PROJECT}/${PROJECT}.typ"
    OUT_NAME="$PROJECT"
fi

# Print header
echo -e "${BLUE}=================================================="
echo "Technical Documentation Build System"
echo "Project: $PROJECT"
echo -e "==================================================${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_step() {
    echo -e "${YELLOW}▶${NC} $1"
}

# Check for required tools
print_step "Checking required tools..."
command -v python3 >/dev/null 2>&1 || { print_error "python3 is required but not installed."; exit 1; }
command -v typst >/dev/null 2>&1 || { print_error "typst is required but not installed."; exit 1; }
print_status "All required tools available"
echo ""

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root
cd "$PROJECT_ROOT"

# Check if project exists
if [ ! -d "$PROJECT" ]; then
    print_error "Project directory not found: $PROJECT"
    echo "Available projects:"
    for dir in */; do
        if [ -d "$dir" ] && [ "$dir" != "lib/" ] && [ "$dir" != "scripts/" ] && [ "$dir" != "docs/" ]; then
            echo "  - ${dir%/}"
        fi
    done
    exit 1
fi

# Check if source file exists
if [ ! -f "$SRC_FILE" ]; then
    print_error "Source file not found: $SRC_FILE"
    exit 1
fi

# Step 1: Generate colors
print_step "Step 1/4: Generating color files from lib/colors.json..."
if python3 scripts/build-colors.py; then
    print_status "Color files generated (CSS and Typst)"
else
    print_error "Color generation failed"
    exit 1
fi
echo ""

# Step 2: Compile diagrams
print_step "Step 2/4: Compiling diagrams to SVG for project '$PROJECT'..."
if python3 scripts/build-diagrams.py "$PROJECT"; then
    print_status "Diagrams compiled successfully"
else
    print_error "Diagram compilation failed"
    exit 1
fi
echo ""

# Step 3: Compile PDF
print_step "Step 3/4: Compiling PDF..."
if typst compile --root . "$SRC_FILE" "${OUT_NAME}.pdf"; then
    print_status "PDF created: ${OUT_NAME}.pdf"
else
    print_error "PDF compilation failed"
    exit 1
fi
echo ""

# Step 4: Compile HTML
print_step "Step 4/4: Compiling HTML with dark mode support..."
if python3 scripts/build-html.py "$SRC_FILE" "${OUT_NAME}.html"; then
    print_status "HTML created: ${OUT_NAME}.html"
else
    print_error "HTML compilation failed"
    exit 1
fi
echo ""

# Print summary
echo -e "${GREEN}=================================================="
echo "✅ Build Complete!"
echo -e "==================================================${NC}"
echo ""
echo "Project: $PROJECT"
echo "Output files:"
echo "  📄 PDF:  ${OUT_NAME}.pdf"
echo "  🌐 HTML: ${OUT_NAME}.html"
echo ""
echo "Generated files:"
echo "  🎨 Colors: lib/generated/colors.css, colors.typ"
echo "  📊 Diagrams: ${PROJECT}/diagrams/*.svg"
echo ""
echo "To view:"
echo "  PDF:  open ${OUT_NAME}.pdf"
echo "  HTML: open ${OUT_NAME}.html"
echo "        🌓 Click theme button (top-right) to switch light (🌕) / dark (🌑) / auto (🌓) modes"
echo "        Use TOC sidebar (left) to navigate sections"
echo ""

# File size info
if command -v du >/dev/null 2>&1; then
    PDF_SIZE=$(du -h "${OUT_NAME}.pdf" 2>/dev/null | cut -f1)
    HTML_SIZE=$(du -h "${OUT_NAME}.html" 2>/dev/null | cut -f1)
    echo "File sizes:"
    echo "  PDF:  $PDF_SIZE"
    echo "  HTML: $HTML_SIZE"
    echo ""
fi

exit 0
