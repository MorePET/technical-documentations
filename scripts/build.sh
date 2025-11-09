#!/bin/bash
# DEPRECATED: This script is deprecated. Use build-html-bootstrap.py instead.
# Build script: Export Typst to HTML and apply Bootstrap styling
# Usage: ./build.sh [filename-without-extension]
#
# Recommended: Use build-html-bootstrap.py directly:
#   python3 scripts/build-html-bootstrap.py input.typ output.html

set -e  # Exit on error

echo "⚠️  DEPRECATION WARNING"
echo "This script (build.sh) is deprecated."
echo "Use: python3 scripts/build-html-bootstrap.py input.typ output.html"
echo ""

# Default filename
FILENAME="${1:-stakeholder-example}"

echo "📝 Building ${FILENAME} with Bootstrap styling..."

# Check if Typst file exists
if [ ! -f "${FILENAME}.typ" ]; then
    echo "❌ Error: ${FILENAME}.typ not found"
    exit 1
fi

# Use the Bootstrap build workflow
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! python3 "${SCRIPT_DIR}/build-html-bootstrap.py" "${FILENAME}.typ" "${FILENAME}.html"; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Done! Open ${FILENAME}.html in your browser"
echo "📁 Files: ${FILENAME}.html + styles-bootstrap.css + colors.css"
