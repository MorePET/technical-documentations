#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "/lib/generated/colors.typ": text-c, stroke-c, background-c, node-bg-blue, node-bg-green, node-bg-purple, node-bg-orange

// System Architecture Diagram
#set page(width: auto, height: auto, margin: 5mm)
#set text(font: "Libertinus Serif", size: 10pt)

#align(center)[
  #diagram(
    node-stroke: (paint: stroke-c, thickness: 1pt),
    node-fill: none,
    spacing: 5em,
    edge-stroke: (paint: stroke-c, thickness: 1pt),
    node-corner-radius: 5pt,
    label-sep: 5pt,

    node((0, 0), [Frontend], fill: node-bg-blue),
    node((1, 0), [API Gateway], fill: node-bg-green),
    node((2, 0), [Backend], fill: node-bg-purple),
    node((2, 1), [Database], fill: node-bg-orange),
    node((1, 1), [Cache], fill: node-bg-orange),

    edge((0, 0), (1, 0), [HTTPS], "->", label-pos: 0.5),
    edge((1, 0), (2, 0), [REST], "->", label-pos: 0.5),
    edge((2, 0), (2, 1), [SQL], "<->", label-pos: 0.5, label-side: right),
    edge((1, 0), (1, 1), [Redis], "<->", label-pos: 0.5, label-side: right),
  )
]
