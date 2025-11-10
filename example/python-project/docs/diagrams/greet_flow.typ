// Greet Command Flow Diagram
// Shows the data flow for the greet command

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#align(center)[
  #diagram(
    node-stroke: 1pt,
    node-fill: blue.lighten(80%),
    spacing: (5em, 3em),
    edge-stroke: 1pt,
    node-corner-radius: 5pt,
    label-sep: 5pt,

    node((0, 0), [User Input], shape: fletcher.shapes.hexagon, fill: green.lighten(80%)),
    node((1, 0), [parse_args()], fill: blue.lighten(80%)),
    node((2, 0), [greet()], fill: blue.lighten(80%)),
    node((3, 0), [stdout], shape: fletcher.shapes.hexagon, fill: orange.lighten(80%)),
    node((1, 1), [Logging System], shape: fletcher.shapes.pill, fill: purple.lighten(80%)),

    edge((0, 0), (1, 0), "->"),
    edge((1, 0), (2, 0), "->"),
    edge((2, 0), (3, 0), "->"),
    edge((1, 0), (1, 1), "->", label-side: right),
  )
]
