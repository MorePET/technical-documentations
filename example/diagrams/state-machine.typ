#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "../../lib/generated/colors.typ": *

// Select theme based on input (defaults to light)
#let theme = sys.inputs.at("theme", default: "light")
#let text_col = if theme == "dark" { text_color_dark } else { text_color }
#let stroke_col = if theme == "dark" { stroke_color_dark } else { stroke_color }
#let background_col = if theme == "dark" { background_color_dark } else { background_color }

#set page(width: auto, height: auto, margin: 5mm, fill: background_col)
#set text(font: "Libertinus Serif", size: 10pt, fill: text_col)

#align(center)[
  #diagram(
    node-stroke: (paint: stroke_col, thickness: 1pt),
    node-fill: none,
    spacing: 6em,
    edge-stroke: (paint: stroke_col, thickness: 1pt),
    node-shape: fletcher.shapes.circle,
    label-sep: 5pt,

    node((0, 0), [Draft], fill: if theme == "dark" { node_bg_blue_light_dark } else { node_bg_blue_light }),
    node((1, 0), [Review], fill: if theme == "dark" { node_bg_blue_light_dark } else { node_bg_blue_light }),
    node((2, 0), [Approved], fill: if theme == "dark" { node_bg_green_dark } else { node_bg_green }),
    node((1, 1), [Rejected], fill: if theme == "dark" { node_bg_red_dark } else { node_bg_red }),

    edge((0, 0), (1, 0), [submit], "->", label-pos: 0.5),
    edge((1, 0), (2, 0), [approve], "->", label-pos: 0.5),
    edge((1, 0), (1, 1), [reject], "->", label-pos: 0.5, label-side: left),
    edge((1, 1), (0, 0), [revise], "->", bend: -25deg, label-pos: 0.5, label-side: left),
  )
]
