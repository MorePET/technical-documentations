// Test Pyramid Diagram
// Shows the testing strategy with unit and integration tests

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let test_pyramid_diagram() = {
  align(center)[
    #diagram(
      spacing: (8em, 3em),
      node-stroke: 1pt,
      edge-stroke: 1pt,

      // Top layer - Integration Tests
      node((1, 0), [Integration Tests (2)],
           shape: fletcher.shapes.rect,
           width: 8em,
           height: 2em,
           fill: orange.lighten(70%)),

      // Bottom layer - Unit Tests
      node((1, 1), [Unit Tests (20+)],
           shape: fletcher.shapes.rect,
           width: 12em,
           height: 2em,
           fill: blue.lighten(70%)),

      // Visual connection
      edge((1, 0), (1, 1), "->", label-side: right, label: [foundation]),
    )
  ]
}
