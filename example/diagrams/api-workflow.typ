#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

// Use colors from the centralized color system
#let node-fill-blue = rgb("#cce3f7")
#let node-fill-green = rgb("#d1e7dd")
#let node-fill-orange = rgb("#fff3cd")
#let stroke-color = rgb("#000000")
#let text-color = rgb("#000000")

#set page(width: auto, height: auto, margin: 5mm)
#set text(font: "Libertinus Serif", size: 10pt, fill: text-color)

#align(center)[
  #diagram(
    node-stroke: (paint: stroke-color, thickness: 1pt),
    spacing: (15mm, 10mm),

    node((0, 0), [Python Source\ Code], shape: rect, fill: node-fill-blue, name: <code>),
    node((1, 0), [griffe\ (AST Parse)], shape: rect, fill: node-fill-green, name: <griffe>),
    node((2, 0), [formatter.py\ (Generate Typst)], shape: rect, fill: node-fill-green, name: <format>),
    node((3, 0), [api-reference.typ\ (Generated)], shape: rect, fill: node-fill-orange, name: <api>),
    node((3, 1), [narrative.typ\ (Hand-written)], shape: rect, fill: node-fill-orange, name: <narrative>),
    node((4, 0.5), [main.typ\ (Combined)], shape: rect, fill: node-fill-blue, name: <main>),
    node((5, 0.5), [typst compile], shape: rect, fill: node-fill-green, name: <compile>),
    node((6, 0), [docs.pdf], shape: rect, fill: node-fill-orange, name: <pdf>),
    node((6, 1), [docs.html], shape: rect, fill: node-fill-orange, name: <html>),

    edge(<code>, <griffe>, "->", label: "extract"),
    edge(<griffe>, <format>, "->", label: "structure"),
    edge(<format>, <api>, "->", label: "write"),
    edge(<api>, <main>, "->", label: "include"),
    edge(<narrative>, <main>, "->", label: "include"),
    edge(<main>, <compile>, "->"),
    edge(<compile>, <pdf>, "->"),
    edge(<compile>, <html>, "->"),
  )
]
