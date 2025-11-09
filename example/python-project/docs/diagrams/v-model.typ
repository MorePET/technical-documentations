#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

// V-Model Diagram
#set page(width: auto, height: auto, margin: 5mm)
#set text(font: "Libertinus Serif", size: 9pt)

#align(center)[
  #diagram(
    node-stroke: 1pt,
    spacing: (18mm, 12mm),

    // Left side - Requirements & Design (going down)
    node((0, 0), [*Requirements*\ Analysis], shape: rect, fill: rgb("#e3f2fd"), name: <req>),
    node((1, 1), [*System*\ Design], shape: rect, fill: rgb("#bbdefb"), name: <sys>),
    node((2, 2), [*Detailed*\ Design], shape: rect, fill: rgb("#90caf9"), name: <detail>),

    // Bottom - Implementation & Testing
    node((3, 3), [*Implementation*\ & Unit Testing], shape: rect, fill: rgb("#fff9c4"), name: <impl>),

    // Right side - Validation (going up)
    node((4, 2), [*Integration*\ Testing], shape: rect, fill: rgb("#c5e1a5"), name: <integ>),
    node((5, 1), [*System*\ Testing], shape: rect, fill: rgb("#a5d6a7"), name: <sysTest>),
    node((6, 0), [*Acceptance*\ Testing], shape: rect, fill: rgb("#81c784"), name: <accept>),

    // Main flow down and up
    edge(<req>, <sys>, "->", label: "decompose"),
    edge(<sys>, <detail>, "->", label: "design"),
    edge(<detail>, <impl>, "->", label: "code"),
    edge(<impl>, <integ>, "->", label: "test"),
    edge(<integ>, <sysTest>, "->", label: "verify"),
    edge(<sysTest>, <accept>, "->", label: "validate"),

    // V-connections (traceability)
    edge(<req>, <accept>, "-", stroke: (dash: "dashed", paint: gray), label: "validates"),
    edge(<sys>, <sysTest>, "-", stroke: (dash: "dashed", paint: gray), label: "verifies"),
    edge(<detail>, <integ>, "-", stroke: (dash: "dashed", paint: gray), label: "tests"),
  )
]

#v(1em)
#align(center)[
  #text(8pt, fill: gray)[
    _The V-Model shows how each design phase corresponds to a testing phase_
  ]
]
