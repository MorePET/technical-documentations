# Color System Documentation

## Overview

This project uses a centralized color management system that enables automatic dark mode switching for diagrams. Colors are defined once in `colors.json` and automatically generate both CSS and Typst color definitions.

## Architecture

```
colors.json                    # Single source of truth
     ↓
build-colors.py               # Generator script
     ↓
  ┌──────┴──────┐
  ↓             ↓
colors.css   colors.typ       # Auto-generated
  ↓             ↓
HTML ←     diagrams/*.typ → SVG
```

## File Structure

```
workspace/
├── colors.json                  # Color configuration
├── build-colors.py              # Color generator
├── generated/
│   ├── colors.css              # Auto-generated CSS
│   └── colors.typ              # Auto-generated Typst colors
├── diagrams/
│   ├── *.typ                   # Diagram source files
│   └── *.svg                   # Generated SVGs (with CSS variables)
└── build-diagrams.py           # Compiles & post-processes SVGs
```

## Workflow

### 1. Define Colors

Edit `colors.json`:

```json
{
  "colors": {
    "background": {
      "light": "transparent",
      "dark": "transparent",
      "description": "Page background"
    },
    "text": {
      "light": "#000000",
      "dark": "#e0e0e0",
      "description": "Primary text color"
    }
  }
}
```

### 2. Generate Color Files

```bash
python3 build-colors.py
```

This creates:
- `generated/colors.css` with CSS custom properties
- `generated/colors.typ` with Typst color definitions

### 3. Build Diagrams

```bash
python3 build-diagrams.py
```

This:
1. Compiles `.typ` files to SVG
2. Removes white backgrounds
3. Replaces hard-coded colors with CSS variables
4. Injects CSS imports

### 4. Build HTML

```bash
python3 build-html.py input.typ output.html
```

This:
1. Compiles Typst to HTML
2. Injects SVG diagrams inline
3. Links colors.css
4. Copies CSS to output directory

### 5. Build PDF

```bash
typst compile input.typ output.pdf
```

PDF works directly without post-processing.

## How It Works

### CSS Variables

The `colors.css` file uses CSS custom properties that automatically switch based on system theme:

```css
:root {
  --color-text: #000000;        /* Light mode */
  --color-background: #ffffff;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-text: #e0e0e0;      /* Dark mode */
    --color-background: #1e1e1e;
  }
}
```

### SVG Post-Processing

The `build-diagrams.py` script automatically:

1. **Removes white backgrounds**:
   ```xml
   <!-- Before -->
   <path fill="#ffffff" ...>
   
   <!-- After -->
   (removed)
   ```

2. **Replaces colors with CSS variables**:
   ```xml
   <!-- Before -->
   <path fill="#000000" stroke="#0066cc">
   
   <!-- After -->
   <path fill="var(--color-text)" stroke="var(--color-link)">
   ```

3. **Injects CSS import**:
   ```xml
   <svg ...>
     <defs>
       <style>
         @import url('colors.css');
       </style>
     </defs>
     <!-- diagram content -->
   </svg>
   ```

## Adding New Colors

1. **Add to `colors.json`**:
   ```json
   {
     "colors": {
       "accent": {
         "light": "#ff6600",
         "dark": "#ff8833",
         "description": "Accent color for highlights"
       }
     }
   }
   ```

2. **Regenerate**:
   ```bash
   python3 build-colors.py
   python3 build-diagrams.py
   ```

3. **Use in Typst**:
   ```typst
   #import "generated/colors.typ": accent
   
   node((0,0), [Text], fill: accent)
   ```

4. **Use in CSS**:
   ```css
   .highlight {
     color: var(--color-accent);
   }
   ```

## Migrating to Different CSS Frameworks

### Bootstrap

Update `build-colors.py` to generate Bootstrap variables:

```python
def generate_bootstrap_scss(colors, output_file):
    lines = ["// Bootstrap SCSS variables"]
    for name, config in colors['colors'].items():
        lines.append(f"${name}: {config['light']};")
    output_file.write_text('\n'.join(lines))
```

### Tailwind

Update to generate Tailwind config:

```python
def generate_tailwind_config(colors):
    config = {
        "theme": {
            "extend": {
                "colors": {}
            }
        }
    }
    for name, cfg in colors['colors'].items():
        config["theme"]["extend"]["colors"][name] = {
            "light": cfg["light"],
            "dark": cfg["dark"]
        }
    return json.dumps(config, indent=2)
```

## Color Palette Reference

### Current Colors

| Name | Light Mode | Dark Mode | Usage |
|------|------------|-----------|-------|
| background | transparent | transparent | Page background |
| text | #000000 | #e0e0e0 | Primary text |
| stroke | #000000 | #808080 | Lines and borders |
| node-bg-blue | #e6f2ff | #1a3a5a | Blue nodes |
| node-bg-green | #e6ffe6 | #1a4a1a | Green nodes |
| node-bg-orange | #ffe6cc | #4a3a1a | Orange nodes |
| node-bg-purple | #f2e6ff | #3a1a5a | Purple nodes |
| node-bg-red | #ffe6e6 | #4a1a1a | Red nodes |
| node-bg-neutral | #f0f0f0 | #2d2d2d | Gray nodes |
| gradient-start | #ffffff | #2d2d2d | Gradient light center |
| gradient-end-blue | #cce5ff | #1a3a5a | Blue gradient edge |
| link-color | #0066cc | #5599ff | Links and arrows |
| label-color | #333333 | #cccccc | Edge labels |

## Testing Dark Mode

### In Browser

1. **Chrome DevTools**:
   - Open DevTools (F12)
   - Press Cmd/Ctrl + Shift + P
   - Type "Rendering"
   - Select "Emulate CSS prefers-color-scheme: dark"

2. **Firefox**:
   - about:config
   - Set `ui.systemUsesDarkTheme` to `1`

3. **System-wide**:
   - **macOS**: System Settings → Appearance → Dark
   - **Windows**: Settings → Personalization → Colors → Dark
   - **Linux**: Depends on DE (usually in Settings → Appearance)

### Manual CSS Class

Add this to your HTML for testing:

```css
.dark-mode {
  color-scheme: dark;
}

.dark-mode {
  --color-text: #e0e0e0;
  --color-background: #1e1e1e;
  /* ... other dark colors */
}
```

## Troubleshooting

### Colors not changing in dark mode

**Problem**: SVGs don't respond to dark mode
**Solution**: 
1. Check that `colors.css` is linked in HTML
2. Verify CSS variables are in the SVG: `grep "var(--color" diagram.svg`
3. Rebuild diagrams: `python3 build-diagrams.py`

### White backgrounds appearing

**Problem**: SVGs have white background rectangles
**Solution**:
1. Update diagram files: `#set page(fill: none)` instead of `fill: white`
2. Rebuild: `python3 build-diagrams.py`
3. Check post-processing is removing white paths

### Colors don't match

**Problem**: CSS and Typst show different colors
**Solution**:
1. Regenerate from source: `python3 build-colors.py`
2. Rebuild diagrams: `python3 build-diagrams.py`
3. Clear browser cache

## Future Enhancements

- [ ] Theme variants (high contrast, accessibility)
- [ ] Color scheme previewer
- [ ] Automated color harmony checks
- [ ] WCAG contrast ratio validation
- [ ] Color palette export to design tools

## References

- [CSS Custom Properties](https://developer.mozilla.org/en-US/docs/Web/CSS/--*)
- [prefers-color-scheme](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme)
- [Typst Colors](https://typst.app/docs/reference/visualize/color/)


