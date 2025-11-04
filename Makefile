# Makefile for building styled HTML from Typst documents
# Usage:
#   make                    # Build stakeholder-example.html
#   make FILE=myfile        # Build myfile.html
#   make clean              # Remove generated HTML files

# Default file to build
FILE ?= stakeholder-example

# Files
TYP_FILE = $(FILE).typ
HTML_FILE = $(FILE).html

# Tools
TYPST = typst
PYTHON = python
STYLE_SCRIPT = add-styling.py
CSS_FILE = styles.css

# Default target
.PHONY: all
all: $(HTML_FILE)

# Build HTML from Typst and apply styling
$(HTML_FILE): $(TYP_FILE) $(CSS_FILE) $(STYLE_SCRIPT)
	@echo "📝 Building $(FILE)..."
	@echo "🔨 Compiling Typst to HTML..."
	@if $(TYPST) compile --format html $(TYP_FILE) 2>&1 | grep -q "features html"; then \
		echo "⚠️  HTML export requires Typst compiled with --features html"; \
		if [ -f "$(HTML_FILE)" ]; then \
			echo "✓ Using existing $(HTML_FILE)"; \
		else \
			echo "❌ No HTML file found. Export manually first."; \
			exit 1; \
		fi; \
	else \
		echo "✓ Typst compilation successful"; \
	fi
	@echo "🎨 Adding CSS styling..."
	@$(PYTHON) $(STYLE_SCRIPT) $(HTML_FILE) --force
	@echo "✅ Done! Open $(HTML_FILE) in your browser"

# Build with inline CSS (single file)
.PHONY: inline
inline: $(TYP_FILE) $(CSS_FILE) $(STYLE_SCRIPT)
	@echo "📝 Building $(FILE) with inline CSS..."
	@echo "🔨 Compiling Typst to HTML..."
	$(TYPST) compile --format html $(TYP_FILE)
	@echo "🎨 Adding inline CSS..."
	$(PYTHON) $(STYLE_SCRIPT) $(HTML_FILE) --inline --force
	@echo "✅ Done! Open $(HTML_FILE) in your browser"

# Build all Typst files in directory
.PHONY: all-files
all-files:
	@echo "📝 Building all Typst files..."
	@for file in *.typ; do \
		if [ -f "$$file" ]; then \
			base=$${file%.typ}; \
			echo "Building $$base..."; \
			$(TYPST) compile --format html "$$file"; \
			$(PYTHON) $(STYLE_SCRIPT) "$$base.html" --force; \
		fi \
	done
	@echo "✅ All files built!"

# Clean generated HTML files
.PHONY: clean
clean:
	@echo "🧹 Cleaning generated HTML files..."
	@rm -f *.html
	@echo "✅ Clean complete!"

# Watch mode: rebuild on changes (requires entr or similar)
.PHONY: watch
watch:
	@if command -v entr >/dev/null 2>&1; then \
		echo "👀 Watching for changes... (Ctrl+C to stop)"; \
		echo "$(TYP_FILE)" | entr -c make; \
	else \
		echo "❌ Error: 'entr' not found. Install with: apt install entr"; \
		exit 1; \
	fi

# Open in default browser (Linux)
.PHONY: open
open: $(HTML_FILE)
	@if command -v xdg-open >/dev/null 2>&1; then \
		xdg-open $(HTML_FILE); \
	else \
		echo "✅ Open $(HTML_FILE) in your browser"; \
	fi

# Show help
.PHONY: help
help:
	@echo "Typst HTML Build System"
	@echo ""
	@echo "Usage:"
	@echo "  make              Build stakeholder-example.html (default)"
	@echo "  make FILE=myfile  Build myfile.html"
	@echo "  make inline       Build with inline CSS (single file)"
	@echo "  make all-files    Build all .typ files in directory"
	@echo "  make clean        Remove generated HTML files"
	@echo "  make watch        Watch for changes and rebuild (requires 'entr')"
	@echo "  make open         Build and open in browser"
	@echo "  make help         Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make                           # Build default file"
	@echo "  make FILE=report               # Build report.typ"
	@echo "  make inline FILE=presentation  # Build with inline CSS"

# Prevent make from deleting intermediate files
.PRECIOUS: $(HTML_FILE)

