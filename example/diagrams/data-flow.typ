#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#set page(width: auto, height: auto, margin: 5mm, fill: none)
#set text(font: "Libertinus Serif", size: 10pt)

#align(center)[
  #diagram(
    spacing: (6em, 3.5em),
    node-stroke: 1pt,
    edge-stroke: 1pt,
    node-corner-radius: 5pt,
    label-sep: 5pt,

    node((0, 0), [User Input], shape: fletcher.shapes.hexagon, fill: green.lighten(80%)),
    node((1, 0), [Validation], fill: blue.lighten(80%)),
    node((2, 0), [Processing], fill: blue.lighten(80%)),
    node((3, 0), [Storage], shape: fletcher.shapes.pill, fill: orange.lighten(80%)),
    node((2, 1), [External API], shape: fletcher.shapes.hexagon, fill: purple.lighten(80%)),

    edge((0, 0), (1, 0), [raw data], "->", label-pos: 0.5),
    edge((1, 0), (2, 0), [validated], "->", label-pos: 0.5),
    edge((2, 0), (2, 1), [enrich], "<->", label-pos: 0.5, label-side: right),
    edge((2, 0), (3, 0), [persist], "->", label-pos: 0.5),
  )
]
