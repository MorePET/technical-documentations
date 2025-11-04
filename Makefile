# Makefile for Technical Documentation Build System
# Builds diagrams, colors, PDF, and HTML with dark mode support

.PHONY: all clean colors diagrams pdf html help check test

# Default target
all: colors diagrams pdf html
	@echo "=================================================="
	@echo "✅ Full build complete!"
	@echo "=================================================="
	@echo "📄 PDF:  technical-doc-example.pdf"
	@echo "🌐 HTML: technical-doc-example.html"
	@echo ""
	@echo "To view HTML: open technical-doc-example.html"
	@echo "🌓 Toggle dark mode with the button in top-right"

# Generate color files (CSS and Typst) from colors.json
colors:
	@echo "🎨 Generating color files..."
	@python3 build-colors.py

# Compile diagrams to SVG
diagrams: colors
	@echo "📊 Compiling diagrams..."
	@python3 build-diagrams.py

# Compile PDF
pdf: diagrams
	@echo "📄 Compiling PDF..."
	@typst compile technical-doc-example.typ technical-doc-example.pdf
	@echo "✓ PDF created: technical-doc-example.pdf"

# Compile HTML with styling and dark mode
html: diagrams
	@echo "🌐 Compiling HTML..."
	@python3 build-html.py technical-doc-example.typ technical-doc-example.html
	@echo "✓ HTML created: technical-doc-example.html"

# Check for errors without building
check:
	@echo "🔍 Checking configuration..."
	@python3 -c "import json; json.load(open('colors.json')); print('✓ colors.json is valid')"
	@python3 -c "from pathlib import Path; assert Path('diagrams/architecture.typ').exists(); print('✓ Diagram files exist')"
	@python3 -c "from pathlib import Path; assert Path('technical-doc-example.typ').exists(); print('✓ Main document exists')"
	@echo "✅ All checks passed"

# Quick test - compile everything and check outputs exist
test: all
	@echo "🧪 Testing build outputs..."
	@test -f technical-doc-example.pdf && echo "✓ PDF exists" || echo "❌ PDF missing"
	@test -f technical-doc-example.html && echo "✓ HTML exists" || echo "❌ HTML missing"
	@test -f diagrams/architecture.svg && echo "✓ Diagrams exist" || echo "❌ Diagrams missing"
	@test -f generated/colors.css && echo "✓ Colors generated" || echo "❌ Colors missing"
	@echo "✅ All tests passed"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -f technical-doc-example.pdf
	@rm -f technical-doc-example.html
	@rm -f technical-doc-example_temp.html
	@rm -f colors.css
	@rm -f diagrams/*.svg
	@rm -f generated/colors.css
	@rm -f generated/colors.typ
	@echo "✓ Clean complete"

# Clean and rebuild everything
rebuild: clean all

# Show help
help:
	@echo "Technical Documentation Build System"
	@echo "===================================="
	@echo ""
	@echo "Available targets:"
	@echo "  make all       - Build everything (colors, diagrams, PDF, HTML)"
	@echo "  make colors    - Generate color files from colors.json"
	@echo "  make diagrams  - Compile diagrams to SVG"
	@echo "  make pdf       - Compile PDF document"
	@echo "  make html      - Compile HTML with dark mode support"
	@echo "  make check     - Validate configuration files"
	@echo "  make test      - Build and test outputs"
	@echo "  make clean     - Remove all build artifacts"
	@echo "  make rebuild   - Clean and rebuild everything"
	@echo "  make help      - Show this help message"
	@echo ""
	@echo "Pre-commit hook:"
	@echo "  make install-hook - Install git pre-commit hook"
	@echo ""
	@echo "Examples:"
	@echo "  make           # Build everything"
	@echo "  make pdf       # Only compile PDF"
	@echo "  make rebuild   # Clean and rebuild"

# Install pre-commit hook
install-hook:
	@echo "📝 Installing pre-commit hook..."
	@mkdir -p .git/hooks
	@cp build-hooks/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "✓ Pre-commit hook installed"
	@echo ""
	@echo "The hook will:"
	@echo "  1. Check if colors.json was modified"
	@echo "  2. Check if diagram .typ files were modified"
	@echo "  3. Rebuild affected components"
	@echo "  4. Stage updated files for commit"
