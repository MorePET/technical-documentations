# Build System Documentation

## Overview

Complete automated build system for technical documentation with diagrams, dark mode support, and pre-commit hooks.

## Quick Start

### Option 1: Makefile (Recommended)

```bash
make              # Build everything (same as 'make all')
make help         # Show all available targets
make test         # Build and verify outputs
make clean        # Remove all build artifacts
make rebuild      # Clean and rebuild everything
```

### Option 2: Shell Script

```bash
./build-all.sh    # Complete build with colored output
```

## Available Make Targets

| Target | Description |
|--------|-------------|
| `make all` | Build everything (colors → diagrams → PDF → HTML) |
| `make colors` | Generate color files from colors.json |
| `make diagrams` | Compile all diagrams to SVG |
| `make pdf` | Compile PDF document |
| `make html` | Compile HTML with dark mode and styling |
| `make check` | Validate configuration files |
| `make test` | Build and test all outputs |
| `make clean` | Remove all build artifacts |
| `make rebuild` | Clean and rebuild everything |
| `make install-hook` | Install git pre-commit hook |
| `make help` | Show help message |

## Build Pipeline

The build system follows this dependency chain:

```text
colors.json
    ↓
[build-colors.py]
    ↓
generated/colors.css + generated/colors.typ
    ↓
┌─────────────────────┬─────────────────────┐
│                     │                     │
diagrams/*.typ        │                     │
    ↓                 │                     │
[build-diagrams.py]   │                     │
    ↓                 │                     │
diagrams/*.svg        │                     │
    ↓                 ↓                     ↓
technical-doc-example.typ ──────────────────┤
    ↓                                       ↓
[typst compile]         [build-html-bootstrap.py workflow]
    ↓                   ├─ post-process-html.py
technical-doc-example.pdf ├─ add-bootstrap-classes.py
                        └─ add-styling-bootstrap.py
                                            ↓
                        technical-doc-example.html
```

## Pre-Commit Hook

### Installation

```bash
make install-hook
```

### What It Does

The pre-commit hook automatically rebuilds components when source files change:

| Changed File | Triggers |
|--------------|----------|
| `colors.json` | Rebuilds colors → diagrams → PDF + HTML |
| `diagrams/*.typ` | Rebuilds diagrams → PDF + HTML |
| `technical-*.typ` | Rebuilds PDF + HTML |
| `build-*.py` | Rebuilds everything (safety) |

### How It Works

1. **Detects changes** in staged files
2. **Rebuilds** affected components
3. **Stages updated outputs** for commit
4. **Commits** with all outputs in sync

### Example

```bash
# Edit a diagram
vim diagrams/architecture.typ

# Stage the change
git add diagrams/architecture.typ

# Commit (pre-commit hook runs automatically)
git commit -m "Update architecture diagram"

# Output:
# 🔍 Pre-commit: Checking for documentation changes...
#   • Diagram source modified: diagrams/architecture.typ
# 🔨 Rebuilding affected components...
#   → Recompiling diagrams...
#   ✓ Diagrams updated
#   → Recompiling PDF...
#   ✓ PDF updated
#   → Recompiling HTML...
#   ✓ HTML updated
# ✅ Pre-commit build complete!
```

## Build Scripts

### Core Scripts

| Script | Purpose |
|--------|---------|
| `build-colors.py` | Generates CSS and Typst files from colors.json |
| `build-diagrams.py` | Compiles .typ diagrams to SVG, post-processes for dark mode |
| `build-html-bootstrap.py` | Orchestrates Bootstrap HTML build workflow |
| `post-process-html.py` | Injects SVG diagrams into HTML |
| `add-bootstrap-classes.py` | Applies Bootstrap classes to HTML elements |
| `add-styling-bootstrap.py` | Adds Bootstrap CDN, theme toggle, and TOC sidebar |
| `build-html.py` | DEPRECATED: Now redirects to build-html-bootstrap.py |

### Build Orchestration

| File | Purpose |
|------|---------|
| `Makefile` | GNU Make build system with targets and dependencies |
| `build-all.sh` | Bash script with colored output and progress |
| `build-hooks/pre-commit` | Git pre-commit hook for automatic rebuilds |

## Configuration Files

### colors.json

Master color palette for both light and dark modes:

```json
{
  "colors": {
    "node-bg-blue": {
      "light": "#cce3f7",
      "dark": "#1e3a5f",
      "description": "Blue node background"
    },
    ...
  }
}
```

**Edit this file** to change colors across all outputs (PDF, HTML, diagrams).

### Diagram Sources

- `diagrams/architecture.typ` - System architecture diagram
- `diagrams/data-flow.typ` - Data flow diagram
- `diagrams/state-machine.typ` - State machine diagram

Edit these files to modify diagram content.

## Output Files

### Primary Outputs

- `technical-doc-example.pdf` - Complete documentation (PDF)
- `technical-doc-example.html` - Interactive HTML with dark mode

### Generated Assets

- `generated/colors.css` - CSS variables for dark/light modes
- `generated/colors.typ` - Typst color definitions
- `diagrams/*.svg` - Diagram SVGs with dark mode support
- `colors.css` - Copy of colors.css for HTML
- `styles-bootstrap.css` - Copy of Bootstrap custom styles for HTML

## Cleaning Up

### Remove Build Artifacts

```bash
make clean
```

Removes:

- PDF and HTML outputs
- Generated SVGs
- Generated color files
- Temporary files

### Rebuild from Scratch

```bash
make rebuild
```

Equivalent to `make clean && make all`.

## Troubleshooting

### Build Fails

```bash
# Check configuration
make check

# Clean and retry
make rebuild
```

### Pre-commit Hook Not Working

```bash
# Reinstall
make install-hook

# Check git repo exists
ls -la .git/hooks/
```

### Colors Not Updating

```bash
# Force regenerate
make colors diagrams

# Or rebuild everything
make rebuild
```

### Dark Mode Not Switching

Check that `colors.css` is properly inlined in HTML:

```bash
grep "data-theme" technical-doc-example.html
```

## Integration with IDEs

### VS Code

Add to `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Documentation",
      "type": "shell",
      "command": "make all",
      "group": {
        "kind": "build",
        "isDefault": true
      }
    }
  ]
}
```

Press `Ctrl+Shift+B` to build.

### Continuous Build (Watch Mode)

```bash
# Using entr (if installed)
ls colors.json diagrams/*.typ *.typ | entr -c make all

# Or inotifywait
while inotifywait -e modify colors.json diagrams/*.typ *.typ; do
  make all
done
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Build Documentation
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: typst-community/setup-typst@v3
      - run: make test
      - uses: actions/upload-artifact@v3
        with:
          name: documentation
          path: |
            technical-doc-example.pdf
            technical-doc-example.html
```

## Performance

Typical build times on modern hardware:

- Colors: ~0.5s
- Diagrams: ~2s (3 diagrams)
- PDF: ~1s
- HTML: ~2s
- **Total: ~5s**

Incremental builds (only changed components) are faster.

## Best Practices

1. **Always use the build system** - Don't compile manually
2. **Commit outputs** - Keep PDF/HTML in sync with sources
3. **Test both modes** - Always check light and dark mode
4. **Use `make check`** - Validate before committing
5. **Let pre-commit work** - It keeps everything synchronized

## Advanced Usage

### Custom Build Order

```bash
# Just update colors and diagrams
make colors diagrams

# Only HTML (no PDF)
make colors diagrams html
```

### Parallel Builds

```bash
# Use -j for parallel execution
make -j4 all
```

### Dry Run

```bash
# See what would be built
make -n all
```

### Debug Mode

```bash
# Verbose output
make all V=1

# Or use the shell script (more verbose by default)
./build-all.sh
```

## File Structure

```text
/workspace/
├── Makefile                          # GNU Make build system
├── scripts/
│   ├── build-all.sh                  # Shell script builder
│   ├── build-hooks/
│   │   └── pre-commit                # Git pre-commit hook
│   ├── build-colors.py               # Color generator
│   ├── build-diagrams.py             # Diagram compiler
│   ├── build-html-bootstrap.py       # Bootstrap HTML orchestrator
│   ├── build-html.py                 # DEPRECATED: Redirects to Bootstrap
│   ├── post-process-html.py          # SVG injector
│   ├── add-bootstrap-classes.py      # Bootstrap class applicator
│   └── add-styling-bootstrap.py      # Bootstrap style enhancer
├── lib/
│   ├── colors.json                   # Master color config
│   ├── styles-bootstrap.css          # Bootstrap custom styles
│   ├── generated/
│   │   ├── colors.css                # Generated colors
│   │   └── colors.typ
│   └── technical-documentation-package.typ # Package
├── example/
│   ├── diagrams/                     # Diagram sources
│   │   ├── architecture.typ
│   │   ├── data-flow.typ
│   │   └── state-machine.typ
│   ├── build/                        # Generated outputs
│   │   ├── diagrams/*.svg            # Generated SVGs
│   │   ├── technical-doc-example.pdf # Output: PDF
│   │   └── technical-doc-example.html # Output: HTML (Bootstrap)
│   └── technical-doc-example.typ     # Main document
└── technical-documentation/
    ├── build/                        # Generated outputs
    └── technical-documentation.typ   # Main document
```

## Support

For issues or questions:

1. Run `make check` to validate configuration
2. Run `make rebuild` for a clean build
3. Check individual scripts: `python3 build-*.py`
4. Review build logs for error messages

## Quick Reference Card

```bash
# Daily workflow
make                    # Build everything
make test               # Build and verify

# Development
make diagrams           # Just rebuild diagrams
make html               # Just rebuild HTML
make pdf                # Just rebuild PDF

# Cleanup
make clean              # Remove outputs
make rebuild            # Clean and rebuild

# Setup
make install-hook       # Install pre-commit hook

# Help
make help               # Show all targets
```
