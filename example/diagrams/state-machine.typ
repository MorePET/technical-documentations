#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "/lib/generated/colors.typ": text-c, stroke-c, background-c, node-bg-blue-light, node-bg-green, node-bg-red

// State Machine Diagram
#set page(width: auto, height: auto, margin: 5mm)
#set text(font: "Libertinus Serif", size: 10pt)

#align(center)[
  #diagram(
    node-stroke: (paint: stroke-c, thickness: 1pt),
    edge-stroke: (paint: stroke-c, thickness: 1pt),
    spacing: 5em,
    node-corner-radius: 5pt,

    node((0, 0), [Draft], fill: node-bg-blue-light),
    node((1, 0), [Review], fill: node-bg-blue-light),
    node((2, 0), [Approved], fill: node-bg-green),
    node((1, 1), [Rejected], fill: node-bg-red),

    edge((0, 0), (1, 0), [submit], "->", label-pos: 0.5),
    edge((1, 0), (2, 0), [approve], "->", label-pos: 0.5),
    edge((1, 0), (1, 1), [reject], "->", label-pos: 0.5, label-side: left),
    edge((1, 1), (0, 0), [revise], "->", bend: -25deg, label-pos: 0.5, label-side: left),
  )
]
