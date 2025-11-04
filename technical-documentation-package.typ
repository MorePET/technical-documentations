// Technical Documentation Package
// Shared definitions and functions for technical documents

// Import Fletcher for diagram creation
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

// Main template function that applies all formatting
#let tech-doc(
  body,
  // HTML export options
  html-css: "styles.css", // CSS file with automatic dark mode support
  html-inline-css: none, // Or embed CSS directly with read("styles.css")
) = {
  // Set page format
  // set page(
  //   paper: "a4",
  //   margin: (left: 2.5cm, right: 2.5cm, top: 3cm, bottom: 3cm),
  // )

  // Set text properties
  set text(
    font: "Libertinus Serif",
    size: 10pt,
    lang: "en",
  )

  // Set paragraph properties (block-aligned)
  // set par(
  //   justify: true,
  //   leading: 0.65em,
  // )

  // Set heading properties
  set heading(numbering: "1.1")
  show heading: it => {
    set text(weight: "bold")
    block(above: 1.4em, below: 1em, it)
  }

  // Note: HTML styling must be added after export using Python script:
  // python add-styling.py your-file.html --force
  //
  // Your Typst build does not include the HTML module, so direct html.elem()
  // calls will cause errors. Use the post-processing approach instead.

  // Apply the formatted body
  body
}

#let stakeholder-table(headers, rows) = {
  let col-count = headers.len()

  table(
    columns: (1fr,) + (2fr,) * (col-count - 1),
    stroke: none,
    align: (col, row) => {
      if col == 0 { left } else { left }
    },
    inset: 10pt,

    // Top line
    table.hline(stroke: 1.5pt),

    // Header row
    ..headers.map(h => [*#h*]),

    // Line after header
    table.hline(stroke: 1pt),

    // Data rows
    ..rows.flatten(),

    // Bottom line
    table.hline(stroke: 1.5pt),
  )
}

// Simple table helper (alternative style)
#let simple-table(..args) = {
  table(
    stroke: (x, y) => {
      if y == 0 { (top: 1.5pt, bottom: 1pt) } else if y == args.pos().len() - 1 { (bottom: 1.5pt) } else { none }
    },
    inset: 8pt,
    ..args
  )
}


// Note/callout box
#let note(body) = {
  block(
    fill: rgb("#f0f0f0"),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
  )[
    #body
  ]
}

// Load stakeholder table from CSV file
#let stakeholder-table-from-csv(file: "stakeholders.csv") = {
  let data = csv(file)

  // First row is headers
  let headers = data.at(0)

  // Remaining rows are data
  let rows = ()
  for i in range(1, data.len()) {
    let row = data.at(i)
    rows.push((
      [*#row.at(0)*],
      {
        // Split multiline text by newlines and create list
        let lines = row.at(1).split("\n")
        for line in lines {
          [- #line]
        }
      },
      [#row.at(2)],
      {
        let lines = row.at(3).split("\n")
        for line in lines {
          [#line]
        }
      },
    ))
  }

  stakeholder-table(headers, rows)
}

// Load stakeholder table from JSON file
#let stakeholder-table-from-json(file: "stakeholders.json", key: "stakeholders") = {
  let data = json(file)
  let items = data.at(key)

  // Deduce headers from first object's keys (capitalize first letter)
  let first-item = items.at(0)
  let keys = first-item.keys()
  let headers = keys.map(k => k.replace(regex("^\w"), m => upper(m.text)))

  let rows = ()
  for item in items {
    let row = ()

    for (i, key) in keys.enumerate() {
      let value = item.at(key)

      // Check if value is an array
      if type(value) == array {
        // Format as bulleted list
        row.push({
          for v in value {
            [- #v]
          }
        })
      } else {
        // First column should be bold
        if i == 0 {
          row.push([*#value*])
        } else {
          row.push([#value])
        }
      }
    }

    rows.push(row)
  }

  stakeholder-table(headers, rows)
}

// Load stakeholder table from YAML file
#let stakeholder-table-from-yaml(file: "stakeholders.yaml", key: "stakeholders") = {
  let data = yaml(file)
  let items = data.at(key)

  // Deduce headers from first object's keys (capitalize first letter)
  let first-item = items.at(0)
  let keys = first-item.keys()
  let headers = keys.map(k => k.replace(regex("^\w"), m => upper(m.text)))

  let rows = ()
  for item in items {
    let row = ()

    for (i, key) in keys.enumerate() {
      let value = item.at(key)

      // Check if value is an array
      if type(value) == array {
        // Format as bulleted list
        row.push({
          for v in value {
            [- #v]
          }
        })
      } else {
        // First column should be bold
        if i == 0 {
          row.push([*#value*])
        } else {
          row.push([#value])
        }
      }
    }

    rows.push(row)
  }

  stakeholder-table(headers, rows)
}

// ============================================================================
// DIAGRAM FUNCTIONS
// ============================================================================

// Helper function to check if we should use SVG images (for HTML export)
#let should-use-svg() = {
  sys.inputs.at("use-svg", default: "false") == "true"
}

// System Architecture Diagram
// Shows a typical system architecture with frontend, API gateway, backend, database, and cache
#let architecture-diagram() = {
  align(center)[
    #if should-use-svg() {
      // For HTML export: use pre-generated SVG
      image("diagrams/architecture.svg")
    } else {
      // For PDF: render directly with Fletcher
      diagram(
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
    }
  ]
}

// Data Flow Diagram
// Visualizes how data moves through a processing pipeline
#let data-flow-diagram() = {
  align(center)[
    #if should-use-svg() {
      // For HTML export: use pre-generated SVG
      image("diagrams/data-flow.svg")
    } else {
      // For PDF: render directly with Fletcher
      diagram(
        spacing: (6em, 3.5em),
        node-stroke: 1pt,
        edge-stroke: 1pt,
        node-corner-radius: 5pt,
        label-sep: 5pt,

        node((0, 0), [User Input], shape: fletcher.shapes.hexagon, fill: green.lighten(80%)),
        node((1, 0), [Validation], fill: blue.lighten(80%)),
        node((2, 0), [Processing], fill: blue.lighten(80%)),
        node((3, 0), [Storage], shape: fletcher.shapes.pill, fill: orange.lighten(80%)),
        node((2, 1), [External API], shape: fletcher.shapes.hexagon, fill: purple.lighten(80%)),

        edge((0, 0), (1, 0), [raw data], "->", label-pos: 0.5),
        edge((1, 0), (2, 0), [validated], "->", label-pos: 0.5),
        edge((2, 0), (2, 1), [enrich], "<->", label-pos: 0.5, label-side: right),
        edge((2, 0), (3, 0), [persist], "->", label-pos: 0.5),
      )
    }
  ]
}

// State Machine Diagram
// Shows workflow states and transitions (e.g., document approval workflow)
#let state-diagram() = {
  align(center)[
    #if should-use-svg() {
      // For HTML export: use pre-generated SVG
      image("diagrams/state-machine.svg")
    } else {
      // For PDF: render directly with Fletcher
      diagram(
        node-stroke: 1pt,
        node-fill: blue.lighten(90%),
        spacing: 6em,
        edge-stroke: 1pt,
        node-shape: fletcher.shapes.circle,
        label-sep: 5pt,

        node((0, 0), [Draft]),
        node((1, 0), [Review]),
        node((2, 0), [Approved], fill: green.lighten(80%)),
        node((1, 1), [Rejected], fill: red.lighten(80%)),

        edge((0, 0), (1, 0), [submit], "->", label-pos: 0.5),
        edge((1, 0), (2, 0), [approve], "->", label-pos: 0.5),
        edge((1, 0), (1, 1), [reject], "->", label-pos: 0.5, label-side: left),
        edge((1, 1), (0, 0), [revise], "->", bend: -25deg, label-pos: 0.5, label-side: left),
      )
    }
  ]
}

