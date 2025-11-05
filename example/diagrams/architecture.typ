#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#set page(width: auto, height: auto, margin: 5mm, fill: none)
#set text(font: "Libertinus Serif", size: 10pt)

#align(center)[
  #diagram(
    node-stroke: 1pt,
    node-fill: blue.lighten(80%),
    spacing: 5em,
    edge-stroke: 1pt,
    node-corner-radius: 5pt,
    label-sep: 5pt,

    node((0, 0), [Frontend]),
    node((1, 0), [API Gateway]),
    node((2, 0), [Backend]),
    node((2, 1), [Database]),
    node((1, 1), [Cache]),

    edge((0, 0), (1, 0), [HTTPS], "->", label-pos: 0.5),
    edge((1, 0), (2, 0), [REST], "->", label-pos: 0.5),
    edge((2, 0), (2, 1), [SQL], "<->", label-pos: 0.5, label-side: right),
    edge((1, 0), (1, 1), [Redis], "<->", label-pos: 0.5, label-side: right),
  )
]

