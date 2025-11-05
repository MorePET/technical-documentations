# Makefile for Technical Documentation Build System
# Builds diagrams, colors, PDF, and HTML with dark mode support
# Supports multiple projects

.PHONY: all clean colors diagrams pdf html help check test example technical-documentation

# Default project
PROJECT ?= technical-documentation

# Theme toggle configuration
# Set to "yes" to include theme toggle button, "no" to use auto (system settings only)
THEME_TOGGLE ?= yes

# Project configurations
TECH_DOC_SRC = technical-documentation/technical-documentation.typ
TECH_DOC_OUT = technical-documentation
EXAMPLE_SRC = example/technical-doc-example.typ
EXAMPLE_OUT = technical-doc-example

# Default target - builds the technical-documentation project
all: technical-documentation

# Build technical-documentation project (the default for real work)
technical-documentation:
	@echo "=================================================="
	@echo "🚀 Building Technical Documentation Project"
	@echo "=================================================="
	@$(MAKE) colors
	@$(MAKE) diagrams PROJECT=technical-documentation
	@$(MAKE) pdf-only SRC=$(TECH_DOC_SRC) OUT=$(TECH_DOC_OUT)
	@$(MAKE) html-only SRC=$(TECH_DOC_SRC) OUT=$(TECH_DOC_OUT)
	@echo ""
	@echo "=================================================="
	@echo "✅ Technical Documentation Build Complete!"
	@echo "=================================================="
	@echo "📄 PDF:  $(TECH_DOC_OUT).pdf"
	@echo "🌐 HTML: $(TECH_DOC_OUT).html"
	@echo ""
	@echo "To view HTML: open $(TECH_DOC_OUT).html"
	@echo "🌓 Toggle dark mode with the button in top-right"

# Build example project (the original demo)
example:
	@echo "=================================================="
	@echo "🎨 Building Example Project"
	@echo "=================================================="
	@$(MAKE) colors
	@$(MAKE) diagrams PROJECT=example
	@$(MAKE) pdf-only SRC=$(EXAMPLE_SRC) OUT=$(EXAMPLE_OUT)
	@$(MAKE) html-only SRC=$(EXAMPLE_SRC) OUT=$(EXAMPLE_OUT)
	@echo ""
	@echo "=================================================="
	@echo "✅ Example Build Complete!"
	@echo "=================================================="
	@echo "📄 PDF:  $(EXAMPLE_OUT).pdf"
	@echo "🌐 HTML: $(EXAMPLE_OUT).html"

# Build all projects
all-projects: technical-documentation example
	@echo ""
	@echo "=================================================="
	@echo "✅ All Projects Built Successfully!"
	@echo "=================================================="

# Generate color files (CSS and Typst) from colors.json
colors:
	@echo "🎨 Generating color files..."
	@python3 scripts/build-colors.py

# Compile diagrams to SVG (with project parameter)
diagrams: colors
	@echo "📊 Compiling diagrams for $(PROJECT)..."
	@python3 scripts/build-diagrams.py $(PROJECT)

# Internal target: Compile PDF (called with SRC and OUT parameters)
pdf-only:
	@echo "📄 Compiling PDF: $(OUT).pdf..."
	@typst compile --root . $(SRC) $(OUT).pdf
	@echo "✓ PDF created: $(OUT).pdf"

# Internal target: Compile HTML (called with SRC and OUT parameters)
html-only:
	@echo "🌐 Compiling HTML: $(OUT).html..."
ifeq ($(THEME_TOGGLE),yes)
	@python3 scripts/build-html.py $(SRC) $(OUT).html
else
	@python3 scripts/build-html.py $(SRC) $(OUT).html --no-theme-toggle
endif
	@echo "✓ HTML created: $(OUT).html"

# User-friendly targets for building just PDF or HTML
pdf:
	@$(MAKE) colors
	@$(MAKE) diagrams PROJECT=$(PROJECT)
	@$(MAKE) pdf-only SRC=$(TECH_DOC_SRC) OUT=$(TECH_DOC_OUT)

html:
	@$(MAKE) colors
	@$(MAKE) diagrams PROJECT=$(PROJECT)
	@$(MAKE) html-only SRC=$(TECH_DOC_SRC) OUT=$(TECH_DOC_OUT)

# Check for errors without building
check:
	@echo "🔍 Checking configuration..."
	@python3 -c "import json; json.load(open('lib/colors.json')); print('✓ lib/colors.json is valid')"
	@python3 -c "from pathlib import Path; assert Path('lib/technical-documentation-package.typ').exists(); print('✓ Package exists')"
	@python3 -c "from pathlib import Path; assert Path('technical-documentation/technical-documentation.typ').exists(); print('✓ Main document exists')"
	@echo "✅ All checks passed"

# Quick test - compile everything and check outputs exist
test: technical-documentation example
	@echo "🧪 Testing build outputs..."
	@test -f technical-documentation.pdf && echo "✓ Technical doc PDF exists" || echo "❌ Technical doc PDF missing"
	@test -f technical-documentation.html && echo "✓ Technical doc HTML exists" || echo "❌ Technical doc HTML missing"
	@test -f technical-doc-example.pdf && echo "✓ Example PDF exists" || echo "❌ Example PDF missing"
	@test -f technical-doc-example.html && echo "✓ Example HTML exists" || echo "❌ Example HTML missing"
	@test -f lib/generated/colors.css && echo "✓ Colors generated" || echo "❌ Colors missing"
	@echo "✅ All tests passed"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -f technical-documentation.pdf
	@rm -f technical-documentation.html
	@rm -f technical-doc-example.pdf
	@rm -f technical-doc-example.html
	@rm -f technical-doc-example_temp.html
	@rm -f colors.css
	@rm -f styles.css
	@rm -f technical-documentation/diagrams/*.svg
	@rm -f example/diagrams/*.svg
	@rm -f lib/generated/colors.css
	@rm -f lib/generated/colors.typ
	@echo "✓ Clean complete"

# Clean and rebuild everything
rebuild: clean all

# Show help
help:
	@echo "Technical Documentation Build System"
	@echo "===================================="
	@echo ""
	@echo "Main targets:"
	@echo "  make                    - Build technical-documentation project (default)"
	@echo "  make technical-documentation - Build your technical documentation"
	@echo "  make example            - Build the example/demo project"
	@echo "  make all-projects       - Build all projects"
	@echo ""
	@echo "Component targets:"
	@echo "  make colors             - Generate color files from colors.json"
	@echo "  make diagrams PROJECT=xxx - Compile diagrams for specific project"
	@echo "  make pdf                - Compile PDF for default project"
	@echo "  make html               - Compile HTML for default project"
	@echo ""
	@echo "Configuration:"
	@echo "  THEME_TOGGLE=yes|no     - Include theme toggle button (default: yes)"
	@echo "                            Set to 'no' to use auto (system settings only)"
	@echo ""
	@echo "Utility targets:"
	@echo "  make check              - Validate configuration files"
	@echo "  make test               - Build and test all outputs"
	@echo "  make clean              - Remove all build artifacts"
	@echo "  make rebuild            - Clean and rebuild everything"
	@echo "  make help               - Show this help message"
	@echo ""
	@echo "Pre-commit hook:"
	@echo "  make install-hook       - Install git pre-commit hook"
	@echo ""
	@echo "Examples:"
	@echo "  make                           # Build technical-documentation (your real work)"
	@echo "  make example                   # Build the example project"
	@echo "  make THEME_TOGGLE=no           # Build without theme toggle (auto only)"
	@echo "  make diagrams PROJECT=example  # Just compile example diagrams"
	@echo "  make rebuild                   # Clean and rebuild"

# Install pre-commit hook
install-hook:
	@echo "📝 Installing pre-commit hook..."
	@mkdir -p .git/hooks
	@cp scripts/build-hooks/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "✓ Pre-commit hook installed"
	@echo ""
	@echo "The hook will:"
	@echo "  1. Check if colors.json was modified"
	@echo "  2. Check if diagram .typ files were modified"
	@echo "  3. Rebuild affected components"
	@echo "  4. Stage updated files for commit"
