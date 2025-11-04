// Technical Documentation Package
// Shared definitions and functions for technical documents

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

