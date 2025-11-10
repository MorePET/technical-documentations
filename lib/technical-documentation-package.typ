// Technical Documentation Package
// Shared definitions and functions for technical documents

// Import Fletcher for diagram creation
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

// Import Cheq for markdown-like checklists
#import "@preview/cheq:0.3.0": checklist

// Main template function that applies all formatting
#let tech-doc(
  body,
  // HTML export options (Bootstrap-based)
  html-css: "styles-bootstrap.css", // Bootstrap custom CSS with dark mode support
  html-inline-css: none, // Or embed CSS directly with read("styles-bootstrap.css")
) = {
  // Set page format (commented out for HTML compatibility)
  // set page(
  //   paper: "a4",
  //   margin: (left: 2.5cm, right: 2.5cm, top: 3cm, bottom: 3cm),
  //   header: context {
  //     // Skip header on first page and before any content headings (i.e., on TOC pages)
  //     let page-num = counter(page).get().first()
  //     if page-num > 1 {
  //       // Query all headings up to and including current page
  //       let all-headings = query(heading)
  //       let headings-before = all-headings.filter(h => {
  //         counter(page).at(h.location()).first() <= page-num
  //       })
  //
  //       // Filter for only level 1 headings
  //       let level1-headings = headings-before.filter(h => h.level == 1)
  //
  //       // Only show header if we have at least one level 1 heading (past TOC)
  //       if level1-headings.len() > 0 {
  //         let current-heading = level1-headings.last().body
  //         align(left)[
  //           _Technical Documentation Example: #current-heading _
  //         ]
  //         line(length: 100%, stroke: 0.5pt)
  //       }
  //     }
  //   },
  //   footer: context align(center)[
  //     #counter(page).display() / #counter(page).final().first()
  //   ]
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

  // Show rule for Fletcher diagrams: Use html.frame for HTML export
  // This renders diagrams as inline SVG in HTML, which can be recolored via JavaScript
  show figure: it => {
    // Check if we're exporting to HTML
    let is-html = sys.inputs.at("html-export", default: "false") == "true"
    
    // Check if the figure contains a diagram (looking for Fletcher diagram elements)
    // We'll wrap any figure body in html.frame for HTML export
    // For PDF, render normally
    if is-html {
      // For HTML: wrap in html.frame to generate inline SVG
      figure(
        html.frame(it.body),
        caption: it.caption,
        kind: it.kind,
        supplement: it.supplement,
      )
    } else {
      // For PDF: render normally
      it
    }
  }

  // Note: HTML styling must be added after export using Bootstrap build script:
  // python3 scripts/build-html-bootstrap.py your-file.typ your-file.html
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

// ============================================
// UNIFIED FIGURE WRAPPER
// ============================================

// Unified figure wrapper for diagrams
// Includes .typ diagram files directly - the show rule handles HTML vs PDF rendering
//
// Parameters:
//   - diagram-path: SOURCE path to .typ file (e.g., "diagrams/v-model.typ")
//   - caption: Figure caption
//   - label-ref: Label for cross-references
//   - width: Width of the figure (default 90%)
#let fig(
  diagram-path,
  caption: none,
  label-ref: none,
  width: 90%,
) = {
  // Convert relative path to absolute path from workspace root
  let absolute-path = if diagram-path.starts-with("/") {
    diagram-path
  } else if diagram-path.starts-with("../") {
    // "../diagrams/x.typ" -> "/example/diagrams/x.typ"
    "/example/" + diagram-path.slice(3)
  } else {
    // Assume calling document is in example/docs/
    "/example/docs/" + diagram-path
  }

  // Include the diagram file directly
  // The show rule will automatically handle:
  // - HTML export: wrap in html.frame for inline SVG
  // - PDF export: render normally with light theme
  let content = include absolute-path

  // Return figure with optional label
  if label-ref != none {
    [#figure(content, caption: caption) #label-ref]
  } else {
    figure(content, caption: caption)
  }
}
