#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#set page(width: auto, height: auto, margin: 5mm, fill: none)
#set text(font: "Libertinus Serif", size: 10pt)

#align(center)[
  #diagram(
    node-stroke: 1pt,
    node-fill: blue.lighten(90%),
    spacing: 6em,
    edge-stroke: 1pt,
    node-shape: fletcher.shapes.circle,
    label-sep: 5pt,

    node((0, 0), [Draft]),
    node((1, 0), [Review]),
    node((2, 0), [Approved], fill: green.lighten(80%)),
    node((1, 1), [Rejected], fill: red.lighten(80%)),

    edge((0, 0), (1, 0), [submit], "->", label-pos: 0.5),
    edge((1, 0), (2, 0), [approve], "->", label-pos: 0.5),
    edge((1, 0), (1, 1), [reject], "->", label-pos: 0.5, label-side: left),
    edge((1, 1), (0, 0), [revise], "->", bend: -25deg, label-pos: 0.5, label-side: left),
  )
]

