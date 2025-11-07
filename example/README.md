# Dual-Theme Diagram Workflow

This example demonstrates a complete workflow for generating beautiful diagrams with full light/dark theme support.

## Features

✨ **Dual-Theme Support**: Diagrams automatically render in both light and dark themes
🎨 **Beautiful Color Scheme**: Uses colors from `colors.json` with semantic meaning
🔄 **Automatic Theme Detection**: Respects system preferences
💾 **Theme Persistence**: Remembers user's theme choice
📱 **Fully Offline**: Single HTML file works without internet
🎯 **Bootstrap Compatible**: Works with both Bootstrap and standalone HTML

## Workflow

### 1. Build Diagrams (Both Themes)

```bash
# Generate both light and dark theme SVGs from .typ files
python3 ../scripts/build-diagrams.py example
```

This will create:

- `architecture-light.svg` and `architecture-dark.svg`
- `data-flow-light.svg` and `data-flow-dark.svg`
- `state-machine-light.svg` and `state-machine-dark.svg`

### 2. Process HTML

```bash
# Inject SVGs and add theme switching
python3 ../scripts/post-process-html.py demo-diagrams.html demo-diagrams-processed.html
```

This will:
- Inject both light and dark SVG versions
- Add CSS for theme-based visibility
- Add JavaScript for theme toggling
- Add a floating theme toggle button

### 3. View Result

Open `demo-diagrams-processed.html` in any browser. The diagrams will automatically match your system theme, and you can toggle between themes using the 🌓 button.

## How It Works

### Diagram Files (`.typ`)

Diagrams use color variables that get injected during build:

```typst
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#set page(width: auto, height: auto, margin: 5mm, fill: background_color)
#set text(font: "Libertinus Serif", size: 10pt, fill: text_color)

#align(center)[
  #diagram(
    node-stroke: (paint: stroke_color, thickness: 1pt),
    node-fill: node_bg_blue,
    // ... rest of diagram
  )
]
```

### Build Process

1. **Read `colors.json`**: Loads light and dark color definitions
2. **Inject Colors**: Creates temporary `.typ` files with theme-specific colors
3. **Compile**: Runs `typst compile` to generate SVGs
4. **Clean up**: Removes temporary files

### HTML Structure

The processed HTML contains both SVG versions:

```html
<div class="diagram-container">
  <div class="diagram-light" data-theme="light">
    <!-- Light theme SVG -->
  </div>
  <div class="diagram-dark" data-theme="dark">
    <!-- Dark theme SVG -->
  </div>
</div>
```

### Theme Switching

CSS controls visibility based on the `data-bs-theme` or `data-theme` attribute:

```css
[data-bs-theme="light"] .diagram-dark { display: none; }
[data-bs-theme="dark"] .diagram-light { display: none; }
```

JavaScript handles:
- System preference detection
- User toggle
- LocalStorage persistence
- System preference changes

## Color Configuration

Colors are defined in `/workspace/lib/colors.json`:

```json
{
  "colors": {
    "text": { "light": "#000000", "dark": "#ffffff" },
    "stroke": { "light": "#000000", "dark": "#ffffff" },
    "node-bg-blue": { "light": "#cfe2ff", "dark": "#084298" },
    "node-bg-green": { "light": "#d1e7dd", "dark": "#0f5132" },
    // ... more colors
  }
}
```

These colors are:
- **Semantic**: Named by purpose (e.g., `node-bg-blue`, `stroke`)
- **Accessible**: Provide good contrast in both themes
- **Bootstrap-aligned**: Match Bootstrap 5 color system

## File Structure

```text
example/
├── diagrams/
│   ├── architecture.typ          # Source diagram
│   ├── architecture-light.svg    # Generated light theme
│   ├── architecture-dark.svg     # Generated dark theme
│   ├── data-flow.typ
│   ├── data-flow-light.svg
│   ├── data-flow-dark.svg
│   ├── state-machine.typ
│   ├── state-machine-light.svg
│   └── state-machine-dark.svg
├── demo-diagrams.html            # Source HTML
├── demo-diagrams-processed.html  # Processed with dual themes
└── README.md                     # This file
```

## Advantages

### vs. CSS Variables (Old Approach)
- ✅ **No post-processing**: Colors are native Typst, not regex-replaced
- ✅ **Perfect accuracy**: No risk of missing colors or false matches
- ✅ **Instant switching**: No CSS calculation needed
- ✅ **Better compatibility**: Works in all browsers

### vs. WASM Approach
- ✅ **Works offline**: No 5MB WASM bundle needed
- ✅ **Instant load**: Pre-rendered, no compilation
- ✅ **Smaller file**: ~350KB vs 5MB+
- ✅ **Better compatibility**: No ES6 modules required

### Trade-offs
- ❌ **2x SVG size**: Both themes embedded
- ❌ **No dynamic filtering**: Would need WASM for that
- ❌ **Build step required**: Can't generate on-the-fly

## For Production

This workflow is ideal for:
- 📄 **Documentation sites**: Beautiful diagrams that match site theme
- 📊 **Technical reports**: Professional PDFs with embedded diagrams
- 📱 **Offline viewing**: Single HTML file, no dependencies
- 🔗 **Sharing**: Email or file share, works immediately

## Customization

### Add New Diagrams

1. Create `diagrams/my-diagram.typ` using color variables
2. Run `python3 ../scripts/build-diagrams.py example`
3. Add to HTML: `<img src="diagrams/my-diagram.svg">`
4. Run `python3 ../scripts/post-process-html.py ...`

### Customize Colors

Edit `/workspace/lib/colors.json` and rebuild:

```bash
python3 ../scripts/build-diagrams.py example
```

### Customize Theme Toggle

Edit `scripts/post-process-html.py`, function `add_theme_toggle_script()` to change:
- Button position
- Button style
- Keyboard shortcuts
- Animation effects

## Browser Support

- ✅ Chrome/Edge 88+
- ✅ Firefox 85+
- ✅ Safari 14+
- ✅ Mobile browsers
- ⚠️ IE11: Needs polyfills for localStorage and CSS variables

## Performance

| Metric | Value |
|--------|-------|
| File size (3 diagrams) | ~350KB |
| Load time | < 100ms |
| Theme switch | Instant (CSS) |
| Memory usage | Minimal |

## Next Steps

1. **Explore** the generated `demo-diagrams-processed.html`
2. **Try** the theme toggle button
3. **Customize** the colors in `colors.json`
4. **Create** your own diagrams in the `diagrams/` folder
5. **Build** and process to see them with dual themes

---

Built with ❤️ using Typst, Fletcher, and beautiful colors!
