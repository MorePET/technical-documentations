#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "/lib/generated/colors.typ": text-c, stroke-c, node-bg-blue, node-bg-blue-light, node-bg-green, node-bg-orange, gradient-end-blue

// V-Model Diagram
#set page(width: auto, height: auto, margin: 5mm, fill: none)
#set text(font: "Libertinus Serif", size: 9pt, fill: text-c)

#align(center)[
  #diagram(
    node-stroke: (paint: stroke-c, thickness: 1pt),
    edge-stroke: (paint: stroke-c, thickness: 1pt),
    // spacing: (18mm, 12mm),

    // Left side - Requirements & Design (going down)
    node((0, 0), [*Requirements*\ Analysis], shape: rect, fill: node-bg-blue-light, name: <req>),
    node((1, 1), [*System*\ Design], shape: rect, fill: node-bg-blue, name: <sys>),
    node((2, 2), [*Detailed*\ Design], shape: rect, fill: gradient-end-blue, name: <detail>),

    // Bottom - Implementation & Testing
    node((3, 3), [*Implementation*\ & Unit Testing], shape: rect, fill: node-bg-orange, name: <impl>),

    // Right side - Validation (going up)
    node((4, 2), [*Integration*\ Testing], shape: rect, fill: node-bg-green, name: <integ>),
    node((5, 1), [*System*\ Testing], shape: rect, fill: node-bg-green, name: <sysTest>),
    node((6, 0), [*Acceptance*\ Testing], shape: rect, fill: node-bg-green, name: <accept>),

    // Main flow down and up
    edge(<req>, <sys>, "->", label: "decompose"),
    edge(<sys>, <detail>, "->", label: "design"),
    edge(<detail>, <impl>, "->", label: "code"),
    edge(<impl>, <integ>, "->", label: "test"),
    edge(<integ>, <sysTest>, "->", label: "verify"),
    edge(<sysTest>, <accept>, "->", label: "validate"),

    // V-connections (traceability)
    edge(<req>, <accept>, "-", stroke: (dash: "dashed", paint: stroke-c), label: "validates"),
    edge(<sys>, <sysTest>, "-", stroke: (dash: "dashed", paint: stroke-c), label: "verifies"),
    edge(<detail>, <integ>, "-", stroke: (dash: "dashed", paint: stroke-c), label: "tests"),
  )
]
