# Dark Mode Fix Summary

## Problems Identified

1. **Colors not adapting to dark mode in HTML**: The diagrams weren't changing colors when switching between light and dark modes.
2. **SVG CSS being stripped**: The embedded CSS in SVGs was being removed by the `add-styling.py` script.
3. **Hardcoded hex colors**: SVG elements used hardcoded hex colors instead of CSS variables.
4. **Architecture diagram using gradient**: The System Architecture Diagram used a radial gradient that wasn't part of the color system.
5. **Color mapping mismatch**: The `colors.json` file didn't include the actual hex colors that Typst was generating.

## Solutions Implemented

### 1. Updated `colors.json`
- Added the actual hex colors that Typst generates (e.g., `#cce3f7` for blue nodes)
- This allows `build-diagrams.py` to find and replace these colors with CSS variables

### 2. Fixed `add-styling.py`
**Problem**: Line 46 was removing ALL `<style>` tags from the HTML:
```python
html_content = re.sub(r'<style>.*?</style>', '', html_content, flags=re.DOTALL)
```

**Solution**: Modified to only remove `<style>` tags from the `<head>` section, preserving styles inside embedded SVGs:
```python
head_end = html_content.find('</head>')
if head_end != -1:
    head_section = html_content[:head_end]
    body_section = html_content[head_end:]
    
    # Remove style/link tags only from head
    head_section = re.sub(r'<style>.*?</style>', '', head_section, flags=re.DOTALL)
    
    html_content = head_section + body_section
```

### 3. Updated `build-diagrams.py`
- Changed CSS embedding from `@import url('colors.css')` to directly embedding the CSS content
- This ensures CSS works when SVGs are embedded inline in HTML

### 4. Removed gradient from Architecture Diagram
- Changed from `gradient.radial(white, blue.lighten(80%), ...)` to solid `blue.lighten(80%)`
- Updated both `diagrams/architecture.typ` and `technical-documentation-package.typ`
- Ensures consistent color treatment across all diagrams

### 5. Updated `build-html.py`
- Added automatic call to `add-styling.py` with `--theme-toggle` and `--toc-sidebar` flags
- Streamlined the build process to include all enhancements automatically

## How It Works Now

### Color System Flow
1. **`colors.json`** → defines all colors with light/dark variants
2. **`build-colors.py`** → generates:
   - `generated/colors.css` with CSS variables and `@media (prefers-color-scheme: dark)` rules
   - `generated/colors.typ` with Typst color definitions
3. **`build-diagrams.py`** → for each diagram:
   - Compiles `.typ` to `.svg`
   - Replaces hardcoded hex colors with `var(--color-name)`
   - Embeds `colors.css` directly into the SVG `<defs><style>` section
4. **`build-html.py`** → builds the final HTML:
   - Compiles Typst to HTML
   - Injects SVG content (with embedded CSS) into HTML
   - Adds theme toggle and TOC sidebar via `add-styling.py`

### Dark Mode Switching
When a user toggles dark mode:
1. The theme toggle button sets `data-theme="dark"` on the `<body>`
2. CSS `@media (prefers-color-scheme: dark)` rules activate
3. All CSS variables (`var(--color-*)`) automatically update to their dark variants
4. SVG elements referencing these variables instantly reflect the new colors

## Files Modified

1. `/workspace/colors.json` - Updated hex color values to match Typst output
2. `/workspace/add-styling.py` - Fixed to preserve SVG `<style>` tags
3. `/workspace/build-diagrams.py` - Embed CSS directly instead of via `@import`
4. `/workspace/build-html.py` - Auto-apply styling with theme toggle and TOC
5. `/workspace/diagrams/architecture.typ` - Removed gradient, use solid color
6. `/workspace/technical-documentation-package.typ` - Same gradient fix

## Color Palette Design

### Light Mode (Default)
- **Text, Arrows, Outlines**: Black `#000000` - crisp, professional
- **Node Fills**: Soft pastels that provide subtle contrast without being aggressive
  - Blue: `#cce3f7` (light sky blue)
  - Green: `#ccf2cc` (soft mint)
  - Orange: `#f2dcc4` (warm beige)
  - Purple: `#e5ccf2` (light lavender)
  - Red: `#f2cccc` (soft pink)
  - Neutral: `#f0f0f0` (very light gray)

### Dark Mode
- **Text, Arrows, Outlines**: White `#ffffff` - excellent contrast on dark backgrounds
- **Node Fills**: Muted darker tones that maintain distinction without glare
  - Blue: `#2a4a5a` (slate blue)
  - Green: `#2a4a2a` (forest green)
  - Orange: `#4a3a2a` (brown)
  - Purple: `#3a2a4a` (deep purple)
  - Red: `#4a2a2a` (burgundy)
  - Neutral: `#3a3a3a` (medium gray)

### Design Principles
1. **Maximum Contrast**: Black/white for all strokes and text ensures readability
2. **Subtle Fills**: Pastel (light) and muted (dark) backgrounds don't compete with content
3. **Consistent System**: All diagrams share the same palette for visual cohesion
4. **Professional Appearance**: Colors suitable for technical documentation

## Testing

To verify the fix works:

```bash
# Rebuild everything
python3 build-colors.py
python3 build-diagrams.py
python3 build-html.py technical-doc-example.typ technical-doc-example.html

# Check results
grep "prefers-color-scheme: dark" technical-doc-example.html  # Should find 4 instances
grep "var(--color-" technical-doc-example.html | wc -l  # Should be >200
```

Open `technical-doc-example.html` in a browser and:
1. Click the theme toggle button (🌓) in the top-right corner
2. Verify diagrams change colors appropriately in dark mode
3. Check that text is black in light mode, white in dark mode
4. Confirm arrows and edges are crisp and visible in both modes
5. Verify node fills are subtle but distinguishable from background

## Future Maintenance

When adding new colors:
1. Add to `colors.json` with both light and dark variants
2. Run `python3 build-colors.py` to regenerate CSS/Typst files
3. Run `python3 build-diagrams.py` to update SVGs
4. The post-processing will automatically handle color replacement

## Key Insight

The critical fix was recognizing that `add-styling.py` was inadvertently stripping the `<style>` tags from embedded SVGs while trying to clean up the HTML `<head>`. By making the regex replacement more targeted (only affecting the `<head>` section), we preserved the dark mode CSS in the SVGs while still allowing the script to update the page-level styling.

