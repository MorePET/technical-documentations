// Layered Architecture Diagram
// Shows the three-tier architecture of the CLI application

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let layered_architecture_diagram() = {
  align(center)[
    #diagram(
      node-stroke: 1pt,
      node-fill: blue.lighten(80%),
      spacing: (4em, 2em),
      edge-stroke: 1pt,
      node-corner-radius: 5pt,

      // CLI Layer
      node((0, 0), [Command-Line Interface (CLI)], width: 15em, height: 2em),
      node((1, 0), [main.py], stroke: none, fill: none),

      // Business Logic Layer
      node((0, 1), [Business Logic Layer], width: 15em, height: 2em),
      node((1, 1), [hello.py], stroke: none, fill: none),

      // Infrastructure Layer
      node((0, 2), [Infrastructure Layer], width: 15em, height: 2em),
      node((1, 2), [logging, file I/O], stroke: none, fill: none),

      // Connections between layers
      edge((0, 0), (0, 1), "->", label-side: left),
      edge((0, 1), (0, 2), "->", label-side: left),
    )
  ]
}
