#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "/lib/generated/colors.typ": text-c, stroke-c, node-bg-blue, node-bg-green, node-bg-purple, node-bg-orange

// Documentation Build Pipeline Diagram
#set page(width: auto, height: auto, margin: 5mm)
#set text(font: "Libertinus Serif", size: 9pt)

#align(center)[
  #diagram(
    spacing: (8em, 2.5em),
    node-stroke: (paint: stroke-c, thickness: 1pt),
    edge-stroke: (paint: stroke-c, thickness: 1pt),
    node-corner-radius: 5pt,
    label-sep: 5pt,

    // Top node
    node((2, 0), [Documentation Sources], shape: fletcher.shapes.hexagon, fill: node-bg-green),

    // API Generation path
    node((0, 1), align(center)[Python Source Code\ `*.py`], fill: node-bg-blue, width: 10em),
    node((0, 2), [\[griffe\] AST Analysis], fill: node-bg-purple, width: 10em),
    node((0, 3), [`api-reference.typ`], fill: node-bg-orange, width: 10em),

    // Test Generation path
    node((1, 1), align(center)[pytest + pytest-cov], fill: node-bg-blue, width: 10em),
    node((1, 2), align(center)[`test-coverage.typ`\ `test-results.typ`], fill: node-bg-orange, width: 10em),

    // Hand-written path
    node((2, 1), align(center)[Hand-written Typst\ Narrative docs], fill: node-bg-blue, width: 10em),

    // Diagrams path
    node((3, 1), align(center)[Fletcher Diagrams\ `*.typ`], fill: node-bg-blue, width: 10em),
    node((3, 2), align(center)[\[typst compile\] → SVG], fill: node-bg-purple, width: 10em),
    node((3, 3), align(center)[light + dark mode\ variants], fill: node-bg-orange, width: 10em),

    // Merge node
    node((2, 4), [Combine All Sources], shape: fletcher.shapes.pill, fill: node-bg-green, width: 10em),

    // Final compilation
    node((2, 5), align(center)[typst compile\ main.typ], fill: node-bg-purple, width: 10em),
    node((2, 6), [PDF + HTML outputs], shape: fletcher.shapes.hexagon, fill: node-bg-orange, width: 10em),

    // Edges from top
    edge((2, 0), (0, 1), "->"),
    edge((2, 0), (1, 1), "->"),
    edge((2, 0), (2, 1), "->"),
    edge((2, 0), (3, 1), "->"),

    // API path edges
    edge((0, 1), (0, 2), "->"),
    edge((0, 2), (0, 3), "->"),
    edge((0, 3), (2, 4), "->"),

    // Test path edges
    edge((1, 1), (1, 2), "->"),
    edge((1, 2), (2, 4), "->"),

    // Hand-written edge
    edge((2, 1), (2, 4), "->"),

    // Diagrams path edges
    edge((3, 1), (3, 2), "->"),
    edge((3, 2), (3, 3), "->"),
    edge((3, 3), (2, 4), "->"),

    // Final edges
    edge((2, 4), (2, 5), "->"),
    edge((2, 5), (2, 6), "->"),
  )
]
