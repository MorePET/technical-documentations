// Hello World CLI - Complete Product Documentation
// Following the V-Model Software Development Lifecycle

#set document(title: "Hello World CLI - Product Documentation", author: "Development Team")
#set text(font: "Libertinus Serif", size: 11pt)

// Note: Page setup commented out for HTML compatibility
// #set page(
//   numbering: "1",
//   header: context [
//     #set text(9pt)
//     _Hello World CLI - V-Model Documentation_ #h(1fr) #counter(page).display()
//     #line(length: 100%, stroke: 0.5pt)
//   ]
// )

// ============================================
// TITLE PAGE
// ============================================

#align(center)[
  #v(3em)
  #text(28pt, weight: "bold")[
    Hello World CLI
  ]

  #v(1em)
  #text(18pt)[
    Complete Product Documentation
  ]

  #v(2em)
  #text(14pt, style: "italic")[
    Following the V-Model Development Lifecycle
  ]

  #v(3em)

  #box(
    fill: rgb("#f5f5f5"),
    inset: 2em,
    radius: 8pt,
    [
      #text(12pt)[
        *Version:* 1.0.0 \
        *Date:* #datetime.today().display() \
        *Status:* Production Ready \
        *Coverage:* See Test Rewhports Below
      ]
    ]
  )

  #v(3em)

  #text(10pt, fill: gray)[
    _This document demonstrates a complete V-Model development lifecycle,_\
    _from requirements through acceptance testing._
  ]
]

#pagebreak()

// ============================================
// TABLE OF CONTENTS
// ============================================

#outline(
  title: "Table of Contents",
  indent: auto,
  depth: 3
)

#pagebreak()

// ============================================
// V-MODEL DIAGRAM
// ============================================

= V-Model Overview

The V-Model is a software development methodology that emphasizes the relationship between each development phase and its corresponding testing phase. This document follows the V-Model structure:

#figure(
  image("diagrams/v-model.svg", width: 90%),
  caption: [V-Model Software Development Lifecycle]
) <fig-vmodel>

As shown in @fig-vmodel, the V-Model consists of:

*Left Side (Descending):*
- Requirements Analysis → Defines WHAT the system should do
- System Design → Defines HOW the system is structured
- Detailed Design → Defines implementation specifics

*Bottom (Implementation):*
- Implementation & Unit Testing → WHERE the code lives and how it's tested

*Right Side (Ascending):*
- Integration Testing → Verifies component interactions
- System Testing → Verifies system behavior
- Acceptance Testing → Validates user requirements

Each design phase on the left has a corresponding testing phase on the right (shown by dashed lines), ensuring complete traceability from requirements to validation.

#pagebreak()

// ============================================
// NARRATIVE DOCUMENTATION (V-MODEL PHASES)
// ============================================

#include "narrative.typ"


// ============================================
// BOTTOM OF THE V: IMPLEMENTATION DETAILS
// ============================================

= Implementation Details (Bottom of V-Model)

This section provides the detailed implementation documentation automatically extracted from source code. This represents the *bottom of the V-Model* where design becomes reality through code.

== About This Section

The following API documentation is automatically generated from Python source code using:

- *griffe*: AST-based code analysis (no code execution)
- *docstring-parser*: Structured docstring parsing
- *Type hints*: Full type information from annotations

This ensures documentation stays synchronized with implementation.

#pagebreak()

// ============================================
// AUTO-GENERATED API REFERENCE
// ============================================

#include "../generated/api-reference.typ"

#pagebreak()

// ============================================
// TEST COVERAGE REPORT (Bottom of V)
// ============================================

= Testing & Verification (Bottom of V-Model)

This section provides detailed test coverage metrics, representing the quality verification at the implementation level.

#include "../generated/test-coverage.typ"

#pagebreak()

// ============================================
// TEST RESULTS
// ============================================

#include "../generated/test-results.typ"

#pagebreak()

// ============================================
// APPENDIX: BUILD INFORMATION
// ============================================

= Appendix: Documentation Build Information

== About This Documentation

This documentation was automatically generated using a custom pipeline:

=== Build Process

```
Python Source Code
    ↓
[griffe] AST Analysis
    ↓
API Documentation (Typst)
    +
V-Model Narrative (Typst)
    +
Test Reports (pytest + coverage)
    ↓
typst compile
    ↓
PDF + HTML outputs
```

=== Key Features

- *Automatic Sync:* API docs extracted from code - never out of date
- *Type Safety:* Full type hint information included
- *Comprehensive Testing:* Coverage metrics and test results
- *V-Model Traceability:* Requirements → Design → Implementation → Testing

=== Technologies Used

*Documentation Generation:*
- Typst: Document compilation
- griffe: Python API extraction (AST-based)
- docstring-parser: Docstring structure parsing
- pytest + pytest-cov: Test execution and coverage

*Source Code:*
- Python 3.12+
- Type hints throughout
- Google-style docstrings
- PEP 8 compliant

=== Regenerating Documentation

To rebuild this documentation:

```bash
# From project root
python -m src.doc_generator.extract_api
python -m src.doc_generator.test_report
typst compile docs/main.typ
```

Or use the provided build script:

```bash
./build_docs.sh
```

== Document Metadata

*Generated:* #datetime.today().display() \
*Typst Version:* 0.12.0+ \
*Python Version:* 3.12+ \
*Test Framework:* pytest 8.0+ \
*Coverage Tool:* pytest-cov 4.0+

---

#align(center)[
  #text(10pt, fill: gray)[
    _End of Document_
  ]
]
