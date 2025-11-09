#!/bin/bash
# Build documentation for Hello World CLI project

set -e

echo "=================================================="
echo "🚀 Building Hello World CLI Documentation"
echo "=================================================="
echo ""

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

# Step 1: Extract API documentation
echo "📖 Step 1/5: Extracting API documentation..."
python3 -m src.doc_generator.extract_api
echo "✓ API documentation extracted"
echo ""

# Step 2: Run tests and generate coverage
echo "🧪 Step 2/5: Running tests and generating coverage..."
python3 -m src.doc_generator.test_report
echo "✓ Test reports generated"
echo ""

# Step 3: Compile V-model diagram
echo "📊 Step 3/5: Compiling V-model diagram..."
mkdir -p build/diagrams
typst compile --root "$PROJECT_ROOT" docs/diagrams/v-model.typ build/diagrams/v-model.svg
echo "✓ V-model diagram compiled"
echo ""

# Step 4: Compile PDF documentation
echo "📄 Step 4/5: Compiling PDF documentation..."
mkdir -p build
typst compile --root "$PROJECT_ROOT" docs/main.typ build/documentation.pdf
echo "✓ PDF generated: build/documentation.pdf"
echo ""

# Step 5: Compile HTML documentation
echo "🌐 Step 5/5: Compiling HTML documentation..."
# Use the workspace build script for HTML with dark mode
python3 ../../scripts/build-html.py docs/main.typ build/documentation.html
echo "✓ HTML generated: build/documentation.html"
echo ""

echo "=================================================="
echo "✅ Build Complete!"
echo "=================================================="
echo ""
echo "📄 PDF:  $PROJECT_ROOT/build/documentation.pdf"
echo "🌐 HTML: $PROJECT_ROOT/build/documentation.html"
echo ""
echo "💡 Open documentation.pdf to view the complete V-Model documentation"
echo "🌓 Open documentation.html in a browser for interactive dark mode"
echo ""
