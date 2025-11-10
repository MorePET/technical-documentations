# Typst Devcontainer Template

## Protected Linting Configuration Files

This repository protects critical linting configuration files from accidental modifications using a **simple read-only permission model**.

### Protected Files

The following files are set to **444 (read-only)** to prevent casual edits:

- `.pre-commit-config.yaml` - Pre-commit hooks configuration
- `pyproject.toml` - Python project dependencies and tool settings
- `.hadolint.yaml` - Containerfile/Dockerfile linting rules
- `.checkmake.ini` - Makefile linting rules
- `.yamllint` - YAML linting rules

### Why Protected?

These files control the linting and quality checks for the entire project. Accidental modifications can:
- Disable important security checks
- Break CI/CD pipelines
- Introduce inconsistent code formatting
- Allow bad code to slip through

### Security Model

**Layer 1: Warning Comments**
- Each file contains prominent "DO NOT EDIT" warnings
- Visual deterrent for casual modifications

**Layer 2: File Permissions (444)**
- Read-only for ALL users (including root and AI)
- Both manual tools and auto-fixers get "Permission denied"
- Forces conscious, deliberate modification

**Layer 3: Manual Intervention Required**
- If pre-commit auto-fixers fail on these files, you MUST manually review
- Explicit chmod required → visible in command history
- Changes appear in git commits

### How to Edit Protected Files

When you genuinely need to modify a protected configuration file:

```bash
# Option 1: Use the helper script (recommended)
edit-protected .pre-commit-config.yaml

# Option 2: Manual three-step process
chmod 644 .pre-commit-config.yaml
vim .pre-commit-config.yaml
chmod 444 .pre-commit-config.yaml
```

### Pre-commit Behavior

When pre-commit runs and encounters issues in protected files:

```text
fix end of files.........................................................Failed
- hook id: end-of-file-fixer
- exit code: 1

PermissionError: [Errno 13] Permission denied: '.pre-commit-config.yaml'

→ Manual intervention required! Use: edit-protected .pre-commit-config.yaml
```

This is **by design** - it forces you to consciously review and fix the issue.

### CI/CD Compatibility

✅ **GitHub Actions works fine** - Git doesn't store 444 permissions, so CI gets normal 644 files
✅ **Renovate can update** - PRs can modify files normally
✅ **Auto-merge works** - No permission issues in CI

The protection is **local only**, which is exactly what we want!

### Benefits

✅ **Simple** - Just 444 permissions, no complex user management
✅ **Effective** - Blocks both humans and AI from casual edits
✅ **Visible** - chmod commands appear in history/logs
✅ **CI-friendly** - No impact on automated workflows
✅ **Fail-safe** - Auto-fixers fail loudly instead of silently modifying

### Automated Setup

Protection is automatically applied during devcontainer creation:

```bash
.devcontainer/scripts/setup-protected-configs.sh
```

This runs as part of `.devcontainer/post-create.sh`.

### Verification

```bash
# Check permissions
ls -la .pre-commit-config.yaml
# Expected: -r--r--r-- ... .pre-commit-config.yaml

# Test protection
echo "test" >> .pre-commit-config.yaml
# Expected: Permission denied ✓
```

### Related

- GitHub Issue: [#9 - Protected config file security](https://github.com/MorePET/technical-documentations/issues/9)
- Setup script: `.devcontainer/scripts/setup-protected-configs.sh`

---

## HTML Frame-Based Diagram Rendering

### New Approach for HTML Export

This project now uses Typst's `html.frame` feature for generating diagrams in HTML output, eliminating the need for pre-compiled dual-theme SVG files.

**Key Features:**
- ✨ **Inline SVG generation** - Diagrams rendered directly during Typst compilation
- 🎨 **Dynamic theme switching** - JavaScript recolors diagrams based on theme
- 🚀 **Simplified workflow** - No pre-compilation or post-processing needed
- 📦 **Smaller output** - Single light-theme source instead of dual SVGs
- 🔧 **Better DX** - Diagrams work like any other Typst content

### Quick Start

**1. Create a diagram:**
```typst
// example/diagrams/my-diagram.typ
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "/lib/generated/colors.typ": stroke_color, node_bg_blue

#diagram(
  node-stroke: (paint: stroke_color, thickness: 1pt),
  node((0, 0), [Start], fill: node_bg_blue),
  node((1, 0), [End], fill: node_bg_blue),
  edge((0, 0), (1, 0), "->")
)
```

**2. Include in your document:**
```typst
#import "lib/technical-documentation-package.typ": *
#show: tech-doc

= My Document

#fig(
  "diagrams/my-diagram.typ",
  caption: [My Diagram]
)
```

**3. Build HTML:**
```bash
python3 scripts/build-html-bootstrap.py example/docs/main.typ output.html
```

That's it! The diagram will:
- Render inline as SVG in HTML
- Automatically switch colors when theme changes
- Work perfectly in both light and dark modes

### How It Works

1. **Show Rule** - Automatically wraps figures in `html.frame` for HTML export
2. **Light Theme** - All diagrams use light theme colors from `lib/generated/colors.typ`
3. **JavaScript** - `diagram-theme-switcher.js` dynamically recolors SVGs on theme change
4. **CSS Variables** - Colors defined in `lib/colors.json` → `lib/generated/colors.css`

### Migration from Old Approach

If you're using the old dual-SVG approach, see the migration guide:
- **📖 [HTML Frame Migration Guide](docs/HTML_FRAME_MIGRATION.md)**

The old approach still works but is deprecated:
- `build-diagrams.py` - Pre-compile diagrams (deprecated)
- `post-process-html.py` - Inject dual SVGs (deprecated)

### Resources

- **Color System:** `lib/colors.json` - Define your color palette
- **Generated Files:** `lib/generated/colors.typ` & `colors.css`
- **JS Module:** `lib/diagram-theme-switcher.js`
- **Show Rule:** `lib/technical-documentation-package.typ`
- **Build Script:** `scripts/build-html-bootstrap.py`

---
