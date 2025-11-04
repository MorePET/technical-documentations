# Dark Mode Guide for Diagram SVGs

## The Challenge

Fletcher-generated SVGs embed colors directly as attributes (e.g., `fill="#f0f0f0"`, `stroke="#000000"`). These hard-coded values cannot be easily overridden by CSS without significant work.

## Solutions for Dark Mode

### Option 1: Generate Two Sets of SVGs (Recommended for Quality)

Generate separate SVG files for light and dark modes.

**Approach:**
1. Create dark mode versions of diagrams in `diagrams/dark/`
2. Update colors to work on dark backgrounds
3. Use CSS media queries to switch between them

**Example:**

```typst
// diagrams/dark/architecture.typ
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#set page(width: auto, height: auto, margin: 5mm, fill: rgb("#1e1e1e"))
#set text(font: "Libertinus Serif", size: 10pt, fill: rgb("#e0e0e0"))

#align(center)[
  #diagram(
    node-stroke: 1pt + rgb("#505050"),
    node-fill: gradient.radial(rgb("#2d2d2d"), rgb("#1a3a5a")),
    // ... rest of diagram with dark-friendly colors
  )
]
```

**HTML/CSS:**
```html
<style>
  @media (prefers-color-scheme: light) {
    .diagram-light { display: block; }
    .diagram-dark { display: none; }
  }
  @media (prefers-color-scheme: dark) {
    .diagram-light { display: none; }
    .diagram-dark { display: block; }
  }
</style>

<img src="diagrams/architecture.svg" class="diagram-light" alt="Architecture Diagram">
<img src="diagrams/dark/architecture.svg" class="diagram-dark" alt="Architecture Diagram">
```

**Build Script:**
```python
# Add to build-diagrams.py
def compile_dark_diagrams():
    dark_dir = Path(__file__).parent / 'diagrams' / 'dark'
    if dark_dir.exists():
        typ_files = sorted(dark_dir.glob('*.typ'))
        for typ_file in typ_files:
            svg_file = typ_file.with_suffix('.svg')
            subprocess.run(['typst', 'compile', str(typ_file), str(svg_file)])
```

### Option 2: CSS Filters (Quick but Imperfect)

Use CSS filters to automatically adjust colors. Works but may not look perfect.

**CSS:**
```css
@media (prefers-color-scheme: dark) {
  img[src*="diagrams/"] {
    filter: invert(0.9) hue-rotate(180deg);
  }
}
```

**Pros:**
- No need to maintain separate SVGs
- Automatic color inversion

**Cons:**
- Colors may look off (especially blues/greens)
- All colors are inverted, which may not be desired
- Text and fills inverted together

### Option 3: CSS Custom Properties in SVG (Advanced)

Post-process SVGs to use CSS variables instead of hard-coded colors.

**Post-processing script:**
```python
import re
from pathlib import Path

def add_css_vars_to_svg(svg_file):
    content = svg_file.read_text()
    
    # Replace common colors with CSS variables
    replacements = {
        'fill="#0000ff"': 'fill="var(--diagram-primary, #0000ff)"',
        'stroke="#000000"': 'stroke="var(--diagram-stroke, #000000)"',
        'fill="#ffffff"': 'fill="var(--diagram-bg, #ffffff)"',
        # Add more color mappings
    }
    
    for old, new in replacements.items():
        content = content.replace(old, new)
    
    svg_file.write_text(content)
```

**CSS:**
```css
:root {
  --diagram-primary: #0066cc;
  --diagram-stroke: #000000;
  --diagram-bg: #ffffff;
}

@media (prefers-color-scheme: dark) {
  :root {
    --diagram-primary: #5599ff;
    --diagram-stroke: #ffffff;
    --diagram-bg: #1e1e1e;
  }
}
```

### Option 4: SVG with Embedded Styles (Best Flexibility)

Modify Fletcher output or post-process to include `<style>` tags in SVG.

**Example SVG structure:**
```xml
<svg xmlns="http://www.w3.org/2000/svg">
  <style>
    .node-fill { fill: #e6f2ff; }
    .node-stroke { stroke: #000000; }
    
    @media (prefers-color-scheme: dark) {
      .node-fill { fill: #1a3a5a; }
      .node-stroke { stroke: #ffffff; }
    }
  </style>
  
  <rect class="node-fill node-stroke" ... />
</svg>
```

This requires post-processing or modifying Fletcher's SVG output.

## Recommended Approach

For production use, I recommend **Option 1 (Two Sets of SVGs)**:

1. **Better quality**: Hand-crafted colors that work well in each mode
2. **No CSS hacks**: Clean, predictable rendering
3. **More control**: Different color schemes, not just inverted
4. **Performance**: No filter calculations

### Implementation Steps

1. **Create dark mode diagrams:**
```bash
mkdir -p diagrams/dark
```

2. **Copy and modify each diagram** with dark-friendly colors:
   - Background: `#1e1e1e` or `#0d1117`
   - Text: `#e0e0e0` or `#c9d1d9`
   - Node fills: Darker, desaturated versions
   - Strokes: Lighter colors (`#505050` instead of `#000000`)

3. **Update package to support dark mode:**
```typst
#let architecture-diagram(dark: false) = {
  align(center)[
    #if should-use-svg() {
      if dark {
        image("diagrams/dark/architecture.svg")
      } else {
        image("diagrams/architecture.svg")
      }
    } else {
      // PDF always uses appropriate colors based on document
      diagram(/* ... */)
    }
  ]
}
```

4. **Update HTML generation** to include both versions with CSS switching

## Color Recommendations for Dark Mode

| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Background | `#ffffff` | `#1e1e1e` or `#0d1117` |
| Text | `#000000` | `#e0e0e0` or `#c9d1d9` |
| Node Fill (Blue) | `#e6f2ff` | `#1a3a5a` |
| Node Fill (Green) | `#e6ffe6` | `#1a4a1a` |
| Node Fill (Red) | `#ffe6e6` | `#4a1a1a` |
| Strokes | `#000000` | `#505050` or `#808080` |
| Links/Arrows | `#0066cc` | `#5599ff` |

## Testing Dark Mode

1. **Browser DevTools**: Toggle dark mode
2. **macOS**: System Preferences → Appearance → Dark
3. **Windows**: Settings → Personalization → Colors → Dark
4. **CSS**: Add `.dark-mode` class for testing

## Conclusion

While CSS filters offer a quick solution, **generating separate dark mode SVGs** provides the best user experience with proper contrast, readability, and aesthetic quality. The additional maintenance is worth it for professional documentation.

