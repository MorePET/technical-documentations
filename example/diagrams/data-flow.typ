#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "/lib/generated/colors.typ": text-c, stroke-c, background-c, node-bg-blue, node-bg-green, node-bg-purple, node-bg-orange

// Data Flow Diagram
#set page(width: auto, height: auto, margin: 5mm)
#set text(font: "Libertinus Serif", size: 10pt)

#align(center)[
  #diagram(
    node-stroke: (paint: stroke-c, thickness: 1pt),
    edge-stroke: (paint: stroke-c, thickness: 1pt),
    spacing: 4em,
    node-corner-radius: 5pt,

    node((0, 0), [User Input], shape: fletcher.shapes.hexagon, fill: node-bg-green),
    node((1, 0), [Validation], fill: node-bg-blue),
    node((2, 0), [Processing], fill: node-bg-blue),
    node((3, 0), [Storage], shape: fletcher.shapes.pill, fill: node-bg-orange),
    node((2, 1), [External API], shape: fletcher.shapes.hexagon, fill: node-bg-purple),

    edge((0, 0), (1, 0), [submit], "->", label-pos: 0.5),
    edge((1, 0), (2, 0), [validated], "->", label-pos: 0.5),
    edge((2, 0), (2, 1), [request], "->", label-pos: 0.5, label-side: right),
    edge((2, 1), (2, 0), [response], "->", label-pos: 0.5, label-side: left),
    edge((2, 0), (3, 0), [save], "->", label-pos: 0.5),
  )
]
