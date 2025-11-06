#set page(width: 210mm, height: auto, margin: 15mm)
#set text(font: "Libertinus Serif", size: 11pt)

= Color Palette Demonstration
Light Mode vs Dark Mode Comparison

== Node Background Colors

This document shows all the colors used in our diagrams and how they transform between light and dark modes.

#let color-swatch(name, light-hex, dark-hex, light-color, dark-color) = {
  grid(
    columns: (1fr, 1fr),
    column-gutter: 10mm,
    row-gutter: 3mm,

    // Light mode - light color on white background
    [
      *Light Mode*
      #box(fill: white, width: 100%, height: 60pt, stroke: 0.5pt)[
        #align(center + horizon)[
          #box(fill: light-color, width: 90%, height: 40pt, stroke: 0.5pt)[
            #align(center + horizon)[
              #text(fill: black, size: 9pt, weight: "bold")[#name]
            ]
          ]
        ]
      ]
      #text(size: 9pt, fill: gray)[#light-hex.replace("#", "\\#")]
    ],

    // Dark mode - dark color on dark background
    [
      *Dark Mode*
      #box(fill: rgb("#1a1a1a"), width: 100%, height: 60pt, stroke: 0.5pt)[
        #align(center + horizon)[
          #box(fill: dark-color, width: 90%, height: 40pt, stroke: 0.5pt + white)[
            #align(center + horizon)[
              #text(fill: white, size: 9pt, weight: "bold")[#name]
            ]
          ]
        ]
      ]
      #text(size: 9pt, fill: gray)[#dark-hex.replace("#", "\\#")]
    ],
  )
  v(5mm)
}

=== Blue (Standard)
Used in: System Architecture, Data Flow (Validation, Processing)
#color-swatch(
  "node-bg-blue",
  "#cce3f7",
  "#1e3a5f",
  rgb("#cce3f7"),
  rgb("#1e3a5f"),
)

=== Blue (Lighter)
Used in: State Machine (Draft, Review states)
#color-swatch(
  "node-bg-blue-light",
  "#e6f1fb",
  "#1a2f4a",
  rgb("#e6f1fb"),
  rgb("#1a2f4a"),
)

=== Green
Used in: Data Flow (User Input), State Machine (Approved state)
#color-swatch(
  "node-bg-green",
  "#d5f5d9",
  "#1e3d1e",
  rgb("#d5f5d9"),
  rgb("#1e3d1e"),
)

=== Orange
Used in: Data Flow (Storage)
#color-swatch(
  "node-bg-orange",
  "#ffe7d1",
  "#4a3420",
  rgb("#ffe7d1"),
  rgb("#4a3420"),
)

=== Purple
Used in: Data Flow (External API)
#color-swatch(
  "node-bg-purple",
  "#efcff4",
  "#3a2651",
  rgb("#efcff4"),
  rgb("#3a2651"),
)

=== Red
Used in: State Machine (Rejected state)
#color-swatch(
  "node-bg-red",
  "#ffd9d7",
  "#4a2020",
  rgb("#ffd9d7"),
  rgb("#4a2020"),
)

=== Neutral (Gray)
Used in: General purpose nodes
#color-swatch(
  "node-bg-neutral",
  "#f0f0f0",
  "#2d3748",
  rgb("#f0f0f0"),
  rgb("#2d3748"),
)

== Text and Stroke Colors

These colors are used for text, arrows, and node borders.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 10mm,

  // Light mode
  [
    *Light Mode*
    #box(fill: white, width: 100%, height: 60pt, stroke: 0.5pt)[
      #align(center + horizon)[
        #stack(
          dir: ttb,
          spacing: 5pt,
          text(fill: black, weight: "bold")[Text: Black],
          text(fill: black, size: 9pt)[Arrows, borders, labels],
        )
      ]
    ]
    #text(size: 9pt, fill: gray)[\#000000 (black)]
  ],

  // Dark mode
  [
    *Dark Mode*
    #box(fill: rgb("#1a1a1a"), width: 100%, height: 60pt, stroke: 0.5pt)[
      #align(center + horizon)[
        #stack(
          dir: ttb,
          spacing: 5pt,
          text(fill: white, weight: "bold")[Text: White],
          text(fill: white, size: 9pt)[Arrows, borders, labels],
        )
      ]
    ]
    #text(size: 9pt, fill: gray)[\#ffffff (white)]
  ],
)

#pagebreak()

== Color Transformation Details

=== Design Principles

The dark mode colors follow industry standards (GitHub, VS Code, Material Design):

1. *Lightness*: Dark mode colors are in the 20-26% lightness range (HSL)
2. *Saturation*: Reduced saturation (30-50%) compared to light mode
3. *Contrast*: All colors maintain WCAG AA contrast ratios with white text
4. *Consistency*: Colors are recognizable across both modes

=== Light Mode (High Saturation, Bright)
- Designed for white backgrounds
- Vibrant, saturated pastels
- 80-90% lightness in HSL
- High visibility and energy

=== Dark Mode (Low Saturation, Muted)
- Designed for dark backgrounds
- Muted, desaturated tones
- 20-26% lightness in HSL
- Comfortable for extended viewing
- No eye strain

=== Color Mapping Table

#table(
  columns: (auto, 1fr, auto, auto),
  [*Color*], [*Typst Expression*], [*Light Hex*], [*Dark Hex*],

  [Blue], [blue.lighten(80%)], [\#cce3f7], [\#1e3a5f],
  [Blue (Light)], [blue.lighten(90%)], [\#e6f1fb], [\#1a2f4a],
  [Green], [green.lighten(80%)], [\#d5f5d9], [\#1e3d1e],
  [Orange], [orange.lighten(80%)], [\#ffe7d1], [\#4a3420],
  [Purple], [purple.lighten(80%)], [\#efcff4], [\#3a2651],
  [Red], [red.lighten(80%)], [\#ffd9d7], [\#4a2020],
  [Neutral], [N/A], [\#f0f0f0], [\#2d3748],
  [Text/Stroke], [black/white], [\#000000], [\#ffffff],
)

=== How It Works

1. *Typst compiles* diagrams with `color.lighten(%)` expressions
2. *Hex colors* are generated in SVG output
3. *Post-processing* replaces hex colors with CSS variables
4. *CSS rules* define different values for light and dark modes
5. *Theme toggle* changes `data-theme` attribute
6. *CSS variables* update automatically

This ensures diagrams adapt seamlessly to the selected theme!
