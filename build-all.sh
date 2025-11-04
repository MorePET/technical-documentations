#!/bin/bash
# build-all.sh - Complete build script for technical documentation
# This script orchestrates the entire build pipeline

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}=================================================="
echo "Technical Documentation Build System"
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

# Step 1: Generate colors
print_step "Step 1/4: Generating color files from colors.json..."
python3 build-colors.py
if [ $? -eq 0 ]; then
    print_status "Color files generated (CSS and Typst)"
else
    print_error "Color generation failed"
    exit 1
fi
echo ""

# Step 2: Compile diagrams
print_step "Step 2/4: Compiling diagrams to SVG..."
python3 build-diagrams.py
if [ $? -eq 0 ]; then
    print_status "All diagrams compiled successfully"
else
    print_error "Diagram compilation failed"
    exit 1
fi
echo ""

# Step 3: Compile PDF
print_step "Step 3/4: Compiling PDF..."
typst compile technical-doc-example.typ technical-doc-example.pdf
if [ $? -eq 0 ]; then
    print_status "PDF created: technical-doc-example.pdf"
else
    print_error "PDF compilation failed"
    exit 1
fi
echo ""

# Step 4: Compile HTML
print_step "Step 4/4: Compiling HTML with dark mode support..."
python3 build-html.py technical-doc-example.typ technical-doc-example.html
if [ $? -eq 0 ]; then
    print_status "HTML created: technical-doc-example.html"
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
echo "Output files:"
echo "  📄 PDF:  technical-doc-example.pdf"
echo "  🌐 HTML: technical-doc-example.html"
echo ""
echo "Generated files:"
echo "  🎨 Colors: generated/colors.css, generated/colors.typ"
echo "  📊 Diagrams: diagrams/architecture.svg, data-flow.svg, state-machine.svg"
echo ""
echo "To view:"
echo "  PDF:  open technical-doc-example.pdf"
echo "  HTML: open technical-doc-example.html"
echo "        🌓 Click theme button (top-right) to switch light/dark/auto modes"
echo "        📚 Use TOC sidebar (left) to navigate sections"
echo ""

# File size info
if command -v du >/dev/null 2>&1; then
    PDF_SIZE=$(du -h technical-doc-example.pdf 2>/dev/null | cut -f1)
    HTML_SIZE=$(du -h technical-doc-example.html 2>/dev/null | cut -f1)
    echo "File sizes:"
    echo "  PDF:  $PDF_SIZE"
    echo "  HTML: $HTML_SIZE"
    echo ""
fi

exit 0

