// Set document styling
#set document(title: "Python Project Documentation", author: "Auto-generated")
#set text(font: "Libertinus Serif", size: 11pt)

// Note: Page setup omitted for HTML compatibility
// When compiling to PDF, you can add page numbering and headers

// Title Page
#align(center)[
  #text(24pt, weight: "bold")[
    Python Project Documentation
  ]

  #v(2em)
  #text(14pt)[
    Example API Documentation with Typst
  ]

  #v(2em)
  #datetime.today().display()

  #v(2em)
  _Auto-generated from Python source code_
]

#pagebreak()

// Table of Contents
#outline(
  title: "Table of Contents",
  indent: auto
)

#pagebreak()

// ============================================
// HAND-WRITTEN NARRATIVE
// ============================================

#include "docs/narrative.typ"

#pagebreak()

// ============================================
// DIAGRAM: API WORKFLOW
// ============================================

= Documentation Pipeline

The following diagram shows how this documentation is generated:

#figure(
  image("diagrams/api-workflow.svg", width: 100%),
  caption: [Documentation generation workflow]
)

As shown in the diagram:

1. *Python Source Code* contains functions with docstrings
2. *griffe* parses the code using AST (no import needed!)
3. *formatter.py* converts the structure to Typst markup
4. *api-reference.typ* is auto-generated
5. *narrative.typ* is hand-written documentation
6. *main.typ* combines both
7. *typst compile* generates PDF and HTML outputs

This workflow ensures API documentation stays in sync with code!

#pagebreak()

// ============================================
// AUTO-GENERATED API REFERENCE
// ============================================

#include "generated/api-reference.typ"

#pagebreak()

// ============================================
// TEST COVERAGE
// ============================================

#include "generated/test-coverage.typ"

#pagebreak()

// ============================================
// TEST RESULTS
// ============================================

#include "generated/test-results.typ"
