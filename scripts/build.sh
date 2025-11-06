#!/bin/bash
# Build script: Export Typst to HTML and apply styling
# Usage: ./build.sh [filename-without-extension]

set -e  # Exit on error

# Default filename
FILENAME="${1:-stakeholder-example}"

echo "📝 Building ${FILENAME}..."

# Check if Typst file exists
if [ ! -f "${FILENAME}.typ" ]; then
    echo "❌ Error: ${FILENAME}.typ not found"
    exit 1
fi

# Compile Typst to HTML
echo "🔨 Compiling Typst to HTML..."
# Try with html feature flag first (for newer Typst versions)
if typst compile --format html "${FILENAME}.typ" 2>&1 | grep -q "features html"; then
    echo "⚠️  HTML export requires Typst to be compiled with --features html"
    echo "💡 If you already have an HTML file, we can just style that"
    if [ -f "${FILENAME}.html" ]; then
        echo "✓ Found existing ${FILENAME}.html, using that"
    else
        echo "❌ No HTML file found. Please export HTML from Typst manually or use a Typst build with HTML support"
        exit 1
    fi
else
    echo "✓ Typst compilation successful"
fi

# Add styling
echo "🎨 Adding CSS styling..."
if ! python add-styling.py "${FILENAME}.html" --force; then
    echo "❌ Styling failed"
    exit 1
fi

echo "✅ Done! Open ${FILENAME}.html in your browser"
echo "📁 Files: ${FILENAME}.html + styles.css"
