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
    spacing: (6em, 3.5em),
    node-stroke: (paint: stroke_col, thickness: 1pt),
    edge-stroke: (paint: stroke_col, thickness: 1pt),
    node-corner-radius: 5pt,
    label-sep: 5pt,

    node((0, 0), [User Input], shape: fletcher.shapes.hexagon, fill: if theme == "dark" { node_bg_green_dark } else { node_bg_green }),
    node((1, 0), [Validation], fill: if theme == "dark" { node_bg_blue_dark } else { node_bg_blue }),
    node((2, 0), [Processing], fill: if theme == "dark" { node_bg_blue_dark } else { node_bg_blue }),
    node((3, 0), [Storage], shape: fletcher.shapes.pill, fill: if theme == "dark" { node_bg_orange_dark } else { node_bg_orange }),
    node((2, 1), [External API], shape: fletcher.shapes.hexagon, fill: if theme == "dark" { node_bg_purple_dark } else { node_bg_purple }),

    edge((0, 0), (1, 0), [raw data], "->", label-pos: 0.5),
    edge((1, 0), (2, 0), [validated], "->", label-pos: 0.5),
    edge((2, 0), (2, 1), [enrich], "<->", label-pos: 0.5, label-side: right),
    edge((2, 0), (3, 0), [persist], "->", label-pos: 0.5),
  )
]
