# Color Palette Guide for Technical Documentation

This document describes the carefully chosen color palette for diagrams in the technical documentation system.

## Design Philosophy

The color palette is designed to be:
- **Professional**: Suitable for technical and business documentation
- **Accessible**: High contrast for readability in both light and dark modes
- **Subtle**: Non-aggressive colors that don't distract from content
- **Consistent**: Unified system across all diagram types

## Color Specifications

### Core Colors

#### Light Mode
```
Text & Strokes:       #000000 (Pure Black)
├─ Node outlines
├─ Arrow lines  
├─ Arrow heads
└─ Text labels

Node Backgrounds:
├─ Blue:     #cce3f7  (Light Sky Blue)
├─ Green:    #ccf2cc  (Soft Mint)
├─ Orange:   #f2dcc4  (Warm Beige)
├─ Purple:   #e5ccf2  (Light Lavender)
├─ Red:      #f2cccc  (Soft Pink)
└─ Neutral:  #f0f0f0  (Very Light Gray)
```

#### Dark Mode
```
Text & Strokes:       #ffffff (Pure White)
├─ Node outlines
├─ Arrow lines
├─ Arrow heads
└─ Text labels

Node Backgrounds (Industry Standard - 20-26% Lightness):
├─ Blue:     #1e3a5f  (Deep Slate - professional, like GitHub)
├─ Green:    #1e3d1e  (Forest Green - muted, not bright)
├─ Orange:   #4a3420  (Warm Brown - earthy tone)
├─ Purple:   #3a2651  (Deep Amethyst - sophisticated)
├─ Red:      #4a2020  (Burgundy - subtle, not alarming)
└─ Neutral:  #2d3748  (Cool Gray - from Tailwind slate-700)
```

## Usage in Typst

In your `.typ` diagram files, use these expressions:

```typst
// For nodes
node-fill: blue.lighten(80%)      // Maps to #cce3f7
node-fill: green.lighten(80%)     // Maps to #ccf2cc
node-fill: orange.lighten(80%)    // Maps to #f2dcc4
node-fill: purple.lighten(80%)    // Maps to #e5ccf2
node-fill: red.lighten(80%)       // Maps to #f2cccc

// For strokes and text (automatically black, converted to white in dark mode)
node-stroke: 1pt
edge-stroke: 1pt
```

## Color Mapping System

The build system automatically:
1. Detects the hex colors Typst generates
2. Replaces them with CSS variables
3. Applies appropriate colors based on light/dark mode

### How It Works

1. **Typst Compilation**: `blue.lighten(80%)` → `#cce3f7`
2. **Post-Processing**: `#cce3f7` → `var(--color-node-bg-blue)`
3. **CSS Variables**: Automatically switch based on theme
   ```css
   /* Light mode */
   --color-node-bg-blue: #cce3f7;
   
   /* Dark mode */
   @media (prefers-color-scheme: dark) {
     --color-node-bg-blue: #2a4a5a;
   }
   ```

## Semantic Mapping

Colors are also mapped to semantic meanings:

- **Primary** (Blue): Core system components, main flow
- **Success** (Green): Positive outcomes, data inputs, successful states
- **Warning** (Orange): Storage, persistence, caution states
- **Danger** (Red): Error states, rejected items
- **Info** (Purple): External services, enrichment, special processing
- **Neutral** (Gray): Generic components, intermediate states

## Examples

### System Architecture Diagram
- All nodes: Blue (primary system components)
- Provides visual unity

### Data Flow Diagram
- Input: Green (data entry point)
- Processing: Blue (core logic)
- Storage: Orange (persistence)
- External API: Purple (third-party)

### State Machine Diagram
- Draft: Neutral (starting state)
- Review: Blue (in progress)
- Approved: Green (success)
- Rejected: Red (failure)

## Customization

To adjust colors:

1. Edit `/workspace/colors.json`:
   ```json
   "node-bg-blue": {
     "light": "#cce3f7",
     "dark": "#2a4a5a",
     "description": "Blue node background"
   }
   ```

2. Rebuild color files:
   ```bash
   python3 build-colors.py
   ```

3. Rebuild diagrams:
   ```bash
   python3 build-diagrams.py
   ```

4. Rebuild HTML:
   ```bash
   python3 build-html.py technical-doc-example.typ technical-doc-example.html
   ```

## Accessibility Notes

- **Contrast Ratio**: Pure black/white on pastel backgrounds exceeds WCAG AA standards
- **Color Blindness**: Node shapes (rectangle, hexagon, pill) provide additional distinction beyond color
- **Screen Readers**: Text labels remain accessible regardless of visual theme
- **Print Friendly**: Light mode colors print clearly on white paper

## Best Practices

1. **Consistency**: Use the same color for the same type of element across all diagrams
2. **Semantic Meaning**: Let color reinforce the purpose (green for success, red for errors)
3. **Balance**: Don't use too many different colors in one diagram (3-4 max)
4. **Test Both Modes**: Always verify diagrams in both light and dark modes
5. **Preserve Contrast**: Ensure text is always readable against node backgrounds

