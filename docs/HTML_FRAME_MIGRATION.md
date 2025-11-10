# HTML Frame-Based Diagram Rendering Migration Guide

This guide helps you migrate from the legacy dual-SVG approach to the new `html.frame`-based diagram rendering system.

## What Changed?

### Old Approach (Deprecated)

```
Diagram .typ files
    ↓
build-diagrams.py (compile with --input theme=light/dark)
    ↓
diagram-light.svg + diagram-dark.svg
    ↓
Typst compile (references SVG files)
    ↓
post-process-html.py (inject dual SVGs with CSS show/hide)
    ↓
HTML with theme-switching CSS
```

**Problems:**
- Required pre-compiling diagrams to SVG files
- Needed dual-theme SVG files (2x file size)
- Complex build pipeline with post-processing
- SVG injection prone to errors
- Diagrams couldn't be included inline easily

### New Approach (Recommended)

```
Diagram .typ files (light theme colors)
    ↓
Include directly in document
    ↓
Typst compile with --input html-export=true
    ↓
Show rule wraps diagrams in html.frame
    ↓
HTML with inline SVG
    ↓
diagram-theme-switcher.js (recolor on theme change)
```

**Benefits:**
- ✅ No pre-compilation needed
- ✅ Single light-theme diagram source
- ✅ Simpler build pipeline
- ✅ More natural Typst workflow
- ✅ Diagrams work like any other content
- ✅ Dynamic theme switching via JavaScript

## Migration Steps

### 1. Update Your Diagram Files (Optional)

Your existing diagram files should already work! They use colors from `lib/generated/colors.typ` which provides light theme by default.

**Before (still works):**
```typst
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "/lib/generated/colors.typ": text-c, stroke-c, node-bg-blue

// Uses theme-aware colors (defaults to light)
#diagram(
  node-stroke: (paint: stroke-c, thickness: 1pt),
  // ...
)
```

**After (more explicit, same result):**
```typst
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "/lib/generated/colors.typ": text_color, stroke_color, node_bg_blue

// Uses explicit light theme colors
#diagram(
  node-stroke: (paint: stroke_color, thickness: 1pt),
  // ...
)
```

Both approaches work! The new system only uses light theme colors since JavaScript handles theme switching.

### 2. Update Your Document Files

**Before:**
```typst
#import "lib/technical-documentation-package.typ": *

// Old approach: use pre-compiled SVG
#fig(
  "diagrams/architecture.typ",
  mode: "svg",  // Force SVG mode
  caption: [System Architecture]
)
```

**After:**
```typst
#import "lib/technical-documentation-package.typ": *

// New approach: include directly (show rule handles everything)
#fig(
  "diagrams/architecture.typ",
  caption: [System Architecture]
)
```

The `mode` parameter is no longer needed. The show rule automatically:
- Wraps diagrams in `html.frame` for HTML export
- Renders normally for PDF export

### 3. Update Build Commands

**Before:**
```bash
# Old workflow
python3 scripts/build-diagrams.py example  # Pre-compile SVGs
python3 scripts/build-html-bootstrap.py example/docs/main.typ output.html
```

**After:**
```bash
# New workflow (no diagram pre-compilation for HTML!)
python3 scripts/build-html-bootstrap.py example/docs/main.typ output.html
```

That's it! The `build-html-bootstrap.py` script now:
1. Compiles with `--input html-export=true`
2. Automatically includes `diagram-theme-switcher.js`
3. No post-processing needed

### 4. Clean Up (Optional)

You can optionally remove pre-compiled SVG files:

```bash
rm -rf example/build/diagrams/*.svg
```

These are no longer needed for HTML export. However, keep them if you use them for other purposes.

## How It Works

### Show Rule (Automatic)

In `lib/technical-documentation-package.typ`:

```typst
show figure: it => {
  let is-html = sys.inputs.at("html-export", default: "false") == "true"
  
  if is-html {
    // For HTML: wrap in html.frame to generate inline SVG
    figure(
      html.frame(it.body),
      caption: it.caption,
      kind: it.kind,
      supplement: it.supplement,
    )
  } else {
    // For PDF: render normally
    it
  }
}
```

This show rule automatically:
- Detects HTML export mode via `--input html-export=true`
- Wraps figure content in `html.frame` for HTML (generates inline SVG)
- Renders normally for PDF (vector quality)

### JavaScript Theme Switcher

The `diagram-theme-switcher.js` script:

1. **Builds a color map** from light theme colors to CSS variables:
   ```javascript
   const LIGHT_COLOR_MAP = {
     '#cfe2ff': '--color-node-bg-blue',
     '#d1e7dd': '--color-node-bg-green',
     // ...
   };
   ```

2. **Finds all SVG elements** in the document

3. **Reads CSS variable values** based on current theme (light/dark)

4. **Rewrites SVG attributes** (fill, stroke) with current theme colors

5. **Watches for theme changes**:
   - Bootstrap theme toggle (`data-bs-theme` attribute)
   - System preference changes
   - Automatic recoloring on change

### Color System

All colors come from `lib/colors.json`:

```json
{
  "colors": {
    "node-bg-blue": {
      "light": "#cfe2ff",
      "dark": "#084298"
    }
  }
}
```

- **Typst:** Uses light theme values from `lib/generated/colors.typ`
- **CSS:** Provides CSS variables that change with theme
- **JavaScript:** Maps light colors to CSS variables for dynamic recoloring

## Troubleshooting

### Diagrams don't appear in HTML

**Check:**
1. Are you compiling with `--input html-export=true`?
2. Is `diagram-theme-switcher.js` included in your HTML?
3. Is `colors.css` linked in your HTML?

**Solution:**
Use `build-html-bootstrap.py` which handles everything automatically.

### Theme switching doesn't work

**Check:**
1. Is `diagram-theme-switcher.js` loaded?
2. Is `colors.css` loaded?
3. Are your diagram colors from `lib/generated/colors.typ`?

**Debug:**
Open browser console and look for:
```
Diagram theme switcher initialized
Diagram theme switcher: Recolored N SVG diagram(s)
```

### Colors don't match theme

**Check:**
1. Are you using colors from `lib/colors.json`?
2. Did you run `python3 scripts/build-colors.py` after editing colors?
3. Are your diagram colors hard-coded instead of using variables?

**Solution:**
Always use colors from `lib/generated/colors.typ`:
```typst
#import "/lib/generated/colors.typ": node_bg_blue, stroke_color
```

### PDF diagrams look wrong

**Check:**
1. Are you using light theme colors (default)?
2. Did you remove `--input theme=dark` from PDF compilation?

**Solution:**
PDF should always use light theme. Compile normally:
```bash
typst compile document.typ document.pdf
```

## Backward Compatibility

### Still Using Old Approach?

The old scripts still work but show deprecation warnings:

- `build-diagrams.py` - Shows deprecation notice but still functional
- `post-process-html.py` - Shows deprecation notice but still functional

These will be removed in a future version. We recommend migrating when convenient.

### Need Dual-SVG Files?

If you have external tools that need pre-compiled SVG files, you can still use:

```bash
python3 scripts/build-diagrams.py example
```

This generates `diagram-light.svg` and `diagram-dark.svg` files.

## Benefits Summary

| Aspect | Old (Dual-SVG) | New (html.frame) |
|--------|----------------|------------------|
| Build Steps | 3-4 steps | 1 step |
| SVG Files | 2 per diagram | 0 |
| File Size | Large (2x SVGs) | Small (inline) |
| Theme Switch | CSS show/hide | JS recolor |
| Maintainability | Complex | Simple |
| Developer UX | Awkward | Natural |
| Performance | Good | Better |

## Questions?

See also:
- `lib/diagram-theme-switcher.js` - JavaScript implementation
- `lib/technical-documentation-package.typ` - Show rule implementation
- `scripts/build-html-bootstrap.py` - Build pipeline
- `CHANGELOG.md` - Complete change list

---

**Note:** This migration is **optional but recommended**. The old approach still works, but the new approach is simpler, faster, and more maintainable.
