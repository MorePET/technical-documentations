# Quick Start Guide - Dual Theme Diagrams

## 🚀 Try It Now (5 seconds)

```bash
# Open the demo in your browser
open example/demo-diagrams-processed.html
```

Click the 🌓 button in the top-right to toggle themes!

## 📝 Create Your Own (2 minutes)

### Step 1: Create a Diagram

Create `diagrams/my-diagram.typ`:

```typst
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#set page(width: auto, height: auto, margin: 5mm, fill: background_color)
#set text(font: "Libertinus Serif", size: 10pt, fill: text_color)

#align(center)[
  #diagram(
    node-stroke: (paint: stroke_color, thickness: 1pt),
    edge-stroke: (paint: stroke_color, thickness: 1pt),

    node((0, 0), [Start], fill: node_bg_green),
    node((1, 0), [Process], fill: node_bg_blue),
    node((2, 0), [End], fill: node_bg_red),

    edge((0, 0), (1, 0), "->"),
    edge((1, 0), (2, 0), "->"),
  )
]
```

### Step 2: Build It

```bash
python3 ../scripts/build-diagrams.py example
```

Output:
```
✓ Successfully created my-diagram-light.svg
✓ Successfully created my-diagram-dark.svg
```

### Step 3: Add to HTML

Create `my-page.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>My Diagrams</title>
</head>
<body>
    <h1>My Workflow</h1>
    <img src="diagrams/my-diagram.svg" alt="My Diagram">
</body>
</html>
```

### Step 4: Process It

```bash
python3 ../scripts/post-process-html.py my-page.html my-page-final.html
```

### Step 5: Open It

```bash
open my-page-final.html
```

That's it! Your diagram now has:
- ✅ Light theme
- ✅ Dark theme
- ✅ Auto-detection
- ✅ Toggle button
- ✅ Offline support

## 🎨 Available Colors

Use these in your diagrams:

| Variable | Light | Dark |
|----------|-------|------|
| `node_bg_blue` | 🔵 Light Blue | 🔵 Deep Blue |
| `node_bg_green` | 🟢 Light Green | 🟢 Deep Green |
| `node_bg_orange` | 🟠 Light Orange | 🟠 Deep Orange |
| `node_bg_purple` | 🟣 Light Purple | 🟣 Deep Purple |
| `node_bg_red` | 🔴 Light Red | 🔴 Deep Red |
| `node_bg_blue_light` | 💙 Lighter Blue | 💙 Darker Blue |
| `text_color` | ⚫ Black | ⚪ White |
| `stroke_color` | ⚫ Black | ⚪ White |
| `background_color` | Transparent | Transparent |

## 💡 Pro Tips

### Custom Colors

Edit `/workspace/lib/colors.json`:

```json
{
  "colors": {
    "my-custom-color": {
      "light": "#ff69b4",
      "dark": "#8b008b"
    }
  }
}
```

Then rebuild diagrams.

### Shapes Available

```typst
node((0, 0), [Text], shape: fletcher.shapes.circle)
node((1, 0), [Text], shape: fletcher.shapes.rect)      // default
node((2, 0), [Text], shape: fletcher.shapes.hexagon)
node((3, 0), [Text], shape: fletcher.shapes.pill)
```

### Edge Styles

```typst
edge((0,0), (1,0), "->")           // Arrow
edge((0,0), (1,0), "<->")          // Double arrow
edge((0,0), (1,0), "--")           // Line
edge((0,0), (1,0), "=>")           // Double arrow line
edge((0,0), (1,0), bend: 30deg)    // Curved
```

## 🐛 Troubleshooting

### Diagram not showing?

Check that:
1. SVG files were generated: `ls diagrams/*-light.svg`
2. HTML has the img tag: `<img src="diagrams/my-diagram.svg">`
3. Paths match: diagram filename matches img src

### Colors not working?

Make sure color variables don't conflict with Typst functions:
- ✅ Use: `text_color`, `stroke_color`, `background_color`
- ❌ Avoid: `text`, `stroke`, `background`

### Theme not switching?

Open browser console (F12) and check for JavaScript errors.

## 📚 More Examples

See the three included diagrams:
- `architecture.typ` - System architecture with multiple layers
- `data-flow.typ` - Data processing pipeline with shapes
- `state-machine.typ` - Workflow states with circles and curves

## 🎯 Next Steps

1. Try modifying an existing diagram
2. Create your own from scratch
3. Customize the colors in `colors.json`
4. Share your HTML file (it works offline!)

Happy diagramming! 🎨
