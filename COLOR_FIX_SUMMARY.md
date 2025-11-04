# Color Switching Fix - Summary

## The Problem

Only the **System Architecture Diagram** was switching colors between light and dark mode. The other diagrams (Data Flow, State Machine) remained in light mode colors even when dark mode was active.

## Root Cause

**Hex color mismatch** between `colors.json` and what Typst actually generates.

The diagrams use Typst color expressions like `blue.lighten(80%)`, but the hex codes in `colors.json` didn't match what Typst compiles to:

| Typst Expression | Expected (colors.json) | Actually Generated | Match? |
|------------------|------------------------|-------------------|--------|
| `blue.lighten(80%)` | `#cce3f7` | `#cce3f7` | ✅ YES |
| `blue.lighten(90%)` | (missing) | `#e6f1fb` | ❌ MISSING |
| `green.lighten(80%)` | `#ccf2cc` | `#d5f5d9` | ❌ NO |
| `orange.lighten(80%)` | `#f2dcc4` | `#ffe7d1` | ❌ NO |
| `purple.lighten(80%)` | `#e5ccf2` | `#efcff4` | ❌ NO |
| `red.lighten(80%)` | `#f2cccc` | `#ffd9d7` | ❌ NO |

**Result**: Only blue matched, so only blue nodes switched colors!

## The Fix

### 1. Discovered Actual Hex Codes
Created a test file to compile each Typst color and extract the actual hex values:

```bash
typst compile test-colors.typ test-colors.svg
# Extracted: #cce3f7, #e6f1fb, #d5f5d9, #ffe7d1, #efcff4, #ffd9d7
```

### 2. Updated colors.json
Replaced incorrect hex codes with the actual values Typst generates:

```json
{
  "node-bg-blue": {
    "light": "#cce3f7",  // ✅ Already correct
    "dark": "#1e3a5f"
  },
  "node-bg-blue-light": {
    "light": "#e6f1fb",  // ✅ NEW - was missing
    "dark": "#1a2f4a"
  },
  "node-bg-green": {
    "light": "#d5f5d9",  // ✅ FIXED (was #ccf2cc)
    "dark": "#1e3d1e"
  },
  "node-bg-orange": {
    "light": "#ffe7d1",  // ✅ FIXED (was #f2dcc4)
    "dark": "#4a3420"
  },
  "node-bg-purple": {
    "light": "#efcff4",  // ✅ FIXED (was #e5ccf2)
    "dark": "#3a2651"
  },
  "node-bg-red": {
    "light": "#ffd9d7",  // ✅ FIXED (was #f2cccc)
    "dark": "#4a2020"
  }
}
```

### 3. Rebuilt Everything
```bash
make rebuild
```

This regenerated:
- `generated/colors.css` - with correct hex-to-CSS-variable mappings
- All diagram SVGs - with proper color replacements
- PDF and HTML - with fully functional dark mode

## How the Color Pipeline Works

```
Typst Source (.typ)
    ↓
  color.lighten(%)  ← Typst color functions
    ↓
[typst compile]
    ↓
  Hex colors (#rrggbb)  ← Generated in SVG
    ↓
[build-diagrams.py]
    ↓
  Replace hex with var(--color-name)  ← Post-processing
    ↓
[colors.css]
    ↓
  :root { --color-name: #light }  ← Light mode
  [data-theme='dark'] { --color-name: #dark }  ← Dark mode
    ↓
[Theme Toggle]
    ↓
  Changes data-theme attribute
    ↓
  CSS variables update → Colors switch! ✨
```

## Verification

### Before Fix
- ✅ System Architecture: Blue nodes switched (matched)
- ❌ Data Flow: Green, orange, purple stayed light (no match)
- ❌ State Machine: Light blue, green, red stayed light (no match)

### After Fix
- ✅ All diagrams switch colors
- ✅ All node types respond to theme toggle
- ✅ Professional dark mode colors (20-26% lightness)
- ✅ Consistent with GitHub/VS Code/Material Design

## Testing

1. **Open HTML**: `technical-doc-example.html`
2. **Toggle theme**: Click button (top-right)
3. **Check diagrams**:
   - System Architecture: Blue nodes switch ✅
   - Data Flow: Green, orange, purple, blue all switch ✅
   - State Machine: Light blue, green, red all switch ✅

## Color Palette Demos Created

### 1. Interactive HTML Demo
**File**: `color-palette-demo.html`

- Shows all 7 colors side-by-side (light vs dark)
- Interactive theme toggle
- Real-time color switching
- Includes full mapping table

**Open in browser to test!**

### 2. PDF Reference
**File**: `color-palette-demo.pdf`

- Static side-by-side comparison
- All colors with hex codes
- Usage notes and design principles
- Print-friendly reference

## Key Learnings

1. **Always verify Typst output**: Color functions like `lighten()` may generate unexpected hex codes
2. **Test with actual compilation**: Don't assume hex values match color names
3. **Use build pipeline**: The color mapping must be exact for CSS variable replacement to work
4. **Centralized colors**: `colors.json` is the single source of truth - must match Typst output

## Files Modified

- ✅ `colors.json` - Fixed all hex codes
- ✅ `generated/colors.css` - Regenerated with correct mappings
- ✅ `diagrams/*.svg` - Recompiled with proper color replacements
- ✅ `technical-doc-example.html` - Now fully functional
- ✅ `technical-doc-example.pdf` - Updated with correct colors

## Build System

All of this is now automated:

```bash
# Full rebuild
make rebuild

# Or step by step
make colors    # Regenerate colors.css
make diagrams  # Recompile SVGs with new colors
make html      # Rebuild HTML
make pdf       # Rebuild PDF
```

The pre-commit hook ensures colors stay in sync automatically!

## Result

🎉 **All diagrams now properly switch between light and dark modes!**

- Professional color palette
- Smooth transitions
- Perfect contrast ratios
- Industry-standard dark mode

