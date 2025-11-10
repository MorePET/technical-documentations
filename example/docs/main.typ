// Product Documentation Example - Complete
// Demonstrating V-Model Development + Technical Documentation Tools

#import "../../lib/technical-documentation-package.typ": *
#show: tech-doc

// ============================================
// TITLE PAGE
// ============================================

#align(center)[
  #v(3em)
  #text(28pt, weight: "bold")[
    Product Documentation Example
  ]

  #v(1em)
  #text(18pt)[
    Complete Technical Documentation Suite
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
        *Version:* 0.1.0 \
        *Date:* #datetime.today().display() \
        *Status:* Review
      ]
    ]
  )

  #v(3em)

  #text(10pt, fill: gray)[
    _This document demonstrates typst application to create a complete technical documentation suite,_\
    _combining V-Model development lifecycle, stakeholder analysis,_\
    _technical diagrams, and auto-generated API documentation._
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
// V-MODEL OVERVIEW
// ============================================

= V-Model Overview

The V-Model is a software development methodology that emphasizes the relationship between each development phase and its corresponding testing phase. This document follows the V-Model structure to demonstrate complete product development from requirements through acceptance testing.

// #include "diagrams/v-model.typ"
#fig(
  "diagrams/v-model.typ",
  width: 100%,
  caption: [V-Model Software Development Lifecycle],
  label-ref: <fig-vmodel>
)

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
// CHAPTER: STAKEHOLDER ANALYSIS
// ============================================

= Stakeholder Analysis Matrix

Effective product development requires understanding stakeholder needs. This section demonstrates various approaches to documenting stakeholder analysis, from manual tables to data-driven formats.

There are various ways to use tables and typst programming to implement a stakeholder analysis matrix. Here are examples of how to do it:
- Fully manual @fully-manual
- Using a table helper @using-table-helper
- From a CSV file @from-csv-file
- From a JSON file @from-json-file
- From a YAML file @from-yaml-file

#note([This is merely an example of the power of typst to create beautiful, professional documents in pdf and html.])

== Fully manual
<fully-manual>

#table(
  columns: (1fr, 2fr, 2fr, 2fr),
  stroke: none,
  align: left,
  inset: 10pt,

  // Top line
  table.hline(stroke: 1.5pt),

  // Header row
  [*Stakeholder*], [*Pain (Top 5, validated)*], [*Promise?*], [*Proof (or Plan to get there)*],

  // Line after header
  table.hline(stroke: 1pt),

  // Row 1: Physician
  [*Physician (plus nurse)*],
  [
    - Time-consuming documentation
    - Alert fatigue
    - Workflow disruption
    - Limited clinical decision support
    - Integration challenges
  ],
  [
    Reduce documentation time by 50% while improving care quality
  ],
  [
    - Pilot study with 10 physicians
    - Time-motion analysis
    - Satisfaction surveys
    - Clinical outcome tracking
  ],

  // Row 2: Patient
  [*Patient*],
  [
    - Lack of transparency
    - Limited access to care
    - Complex navigation
    - Poor communication
    - High out-of-pocket costs
  ],
  [
    Improve patient engagement and reduce barriers to care access
  ],
  [
    - Patient satisfaction scores
    - Access metrics
    - Engagement analytics
    - Cost analysis
  ],

  // Row 3: Provider (Hospital)
  [*Provider (Hospital)*],
  [
    - Rising operational costs
    - Staff burnout
    - Quality metrics pressure
    - Regulatory compliance burden
    - Technology integration issues
  ],
  [
    Reduce costs by 20% while maintaining or improving quality metrics
  ],
  [
    - Financial modeling
    - ROI analysis
    - Pilot program results
    - Benchmark comparisons
  ],

  // Row 4: Payer
  [*Payer*],
  [
    - Unsustainable cost growth
    - Fraud and abuse
    - Quality measurement challenges
    - Administrative burden
    - Member satisfaction issues
  ],
  [
    Demonstrate cost savings and improved outcomes through value-based care
  ],
  [
    - Claims data analysis
    - Cost-effectiveness studies
    - Quality metrics
    - Member retention data
  ],

  // Row 5: Policy maker (Guidelines)
  [*Policy maker (Guidelines)*],
  [
    - Limited evidence base
    - Implementation gaps
    - Health inequities
    - Resource allocation challenges
    - Regulatory complexity
  ],
  [
    Provide evidence-based solutions that scale and reduce health disparities
  ],
  [
    - Population health data
    - Implementation studies
    - Health equity metrics
    - Cost-effectiveness analysis
  ],

  // Bottom line
  table.hline(stroke: 1.5pt),
)

#pagebreak()

== Using a table helper
<using-table-helper>

#stakeholder-table(
  // Headers
  (
    [*Stakeholder*],
    [*Pain (Top 5, validated)*],
    [*Promise?*],
    [*Proof (or Plan to get there)*],
  ),
  // Rows
  (
    // Row 1: Physician (plus nurse)
    (
      [*Physician (plus nurse)*],
      [
        - Time-consuming documentation
        - Alert fatigue
        - Workflow disruption
        - Limited clinical decision support
        - Integration challenges
      ],
      [
        Reduce documentation time by 50% while improving care quality
      ],
      [
        - Pilot study with 10 physicians
        - Time-motion analysis
        - Satisfaction surveys
        - Clinical outcome tracking
      ],
    ),
    // Row 2: Patient
    (
      [*Patient*],
      [
        - Lack of transparency
        - Limited access to care
        - Complex navigation
        - Poor communication
        - High out-of-pocket costs
      ],
      [
        Improve patient engagement and reduce barriers to care access
      ],
      [
        - Patient satisfaction scores
        - Access metrics
        - Engagement analytics
        - Cost analysis
      ],
    ),
    // Row 3: Provider (Hospital)
    (
      [*Provider (Hospital)*],
      [
        - Rising operational costs
        - Staff burnout
        - Quality metrics pressure
        - Regulatory compliance burden
        - Technology integration issues
      ],
      [
        Reduce costs by 20% while maintaining or improving quality metrics
      ],
      [
        - Financial modeling
        - ROI analysis
        - Pilot program results
        - Benchmark comparisons
      ],
    ),
    // Row 4: Payer
    (
      [*Payer*],
      [
        - Unsustainable cost growth
        - Fraud and abuse
        - Quality measurement challenges
        - Administrative burden
        - Member satisfaction issues
      ],
      [
        Demonstrate cost savings and improved outcomes through value-based care
      ],
      [
        - Claims data analysis
        - Cost-effectiveness studies
        - Quality metrics
        - Member retention data
      ],
    ),
    // Row 5: Policy maker (Guidelines)
    (
      [*Policy maker (Guidelines)*],
      [
        - Limited evidence base
        - Implementation gaps
        - Health inequities
        - Resource allocation challenges
        - Regulatory complexity
      ],
      [
        Provide evidence-based solutions that scale and reduce health disparities
      ],
      [
        - Population health data
        - Implementation studies
        - Health equity metrics
        - Cost-effectiveness analysis
      ],
    ),
  ),
)

#pagebreak()

== From a CSV file
<from-csv-file>
#stakeholder-table-from-csv(
  file: "/example/stakeholders.csv",
)

== From a JSON file
<from-json-file>
#stakeholder-table-from-json(
  file: "/example/stakeholders.json",
)

== From a YAML file
<from-yaml-file>
#stakeholder-table-from-yaml(
  file: "/example/stakeholders.yaml",
)

#pagebreak()

// ============================================
// CHAPTER: TECHNICAL DIAGRAMS
// ============================================

= Technical Diagrams with Fletcher

The technical documentation package includes powerful diagram capabilities using Fletcher, a Typst library for creating flowcharts, architecture diagrams, and state machines. All diagrams support both PDF and HTML output with automatic dark mode adaptation.

#note([
  *Dark Mode Support*: When viewing in HTML, these diagrams automatically adapt to your system's color scheme using a centralized color palette defined in `lib/colors.json`. Try toggling dark mode to see the colors change seamlessly!
])

== System Architecture Diagram

A system architecture diagram helps visualize how different components of a software system interact. This example shows a typical three-tier web application architecture with a frontend, API gateway, backend services, database, and caching layer.

*Use cases*:
- Documenting microservices architectures
- Planning infrastructure layouts
- Communicating system design to stakeholders
- Technical onboarding materials

#fig(
  "../diagrams/architecture.typ",
  width: 60%,
  caption: [System Architecture],
  label-ref: <fig-arch>
)

The architecture diagram above illustrates:
- *Frontend*: User-facing web application
- *API Gateway*: Entry point for all client requests, handles routing and load balancing
- *Backend*: Application logic and business rules
- *Database*: Persistent data storage with SQL queries
- *Cache*: Redis layer for performance optimization

This pattern is commonly used in modern cloud-native applications, where each component can be scaled independently based on load requirements.

#pagebreak()

== Data Flow Diagram

Data flow diagrams trace how information moves through a system, from input to output. They're essential for understanding data transformations, identifying bottlenecks, and planning data governance strategies.

*Use cases*:
- ETL (Extract, Transform, Load) pipeline documentation
- Data privacy impact assessments
- API integration specifications
- Quality assurance planning

#fig(
  "../diagrams/data-flow.typ",
  caption: [Data Flow Through System],
  width: 60%,
  label-ref: <fig-dataflow>
)

The data flow shows a typical processing pipeline:
1. *User Input*: Raw data enters the system
2. *Validation*: Input is checked for correctness and security
3. *Processing*: Core business logic is applied
4. *External API*: Data is enriched with third-party information
5. *Storage*: Final results are persisted to the database

This pattern ensures data quality and enables traceability throughout the system. Each transformation step can be monitored, logged, and audited for compliance requirements.

#pagebreak()

== State Machine Diagram

State machines model how systems transition between different states in response to events. They're invaluable for workflow design, business process modeling, and ensuring state consistency in distributed systems.

*Use cases*:
- Order fulfillment workflows
- Document approval processes
- User authentication flows
- IoT device lifecycle management

#fig(
  "../diagrams/state-machine.typ",
  width: 60%,
  caption: [Workflow State Machine],
  label-ref: <fig-state>
)

The workflow state machine represents a document review process:
- *Draft*: Initial creation phase where authors can freely edit
- *Review*: Document is submitted for peer review and approval
- *Approved*: Content has passed review and is published
- *Rejected*: Review identified issues requiring revision

Transitions between states are triggered by user actions (submit, approve, reject) or system events (timeout, validation failure). The "revise" transition creates a feedback loop, allowing iterative improvement until approval is achieved.

== Customizing Diagrams

These diagrams are defined in simple Typst code and can be customized with different layouts, labels, and spacing to match your specific use case.

#note([
  *Color System*: All diagram colors come from `lib/colors.json`, which defines light/dark mode pairs. Using arbitrary colors will break dark mode! To customize colors:
  - Edit `lib/colors.json` to add/modify color pairs
  - Run `make colors` to regenerate CSS and Typst files
  - Use the predefined colors: `node-bg-blue`, `node-bg-green`, `node-bg-orange`, `node-bg-purple`, `node-bg-red`, `node-bg-neutral`

  See `docs/DARK_MODE_COLOR_STANDARDS.md` for details on the color system and `technical-documentation/README.md` for diagram examples.
])

#pagebreak()

// ============================================
// CHAPTER: IMPLEMENTATION EXAMPLE
// ============================================

= Implementation Example: Hello World CLI

This section demonstrates a complete implementation following the V-Model methodology. The Hello World CLI is a production-ready Python command-line application that showcases best practices in software development, from requirements through acceptance testing.

== About This Implementation

The following sections present detailed V-Model phases for a real Python CLI application, including:

- *Requirements Analysis*: Business and functional requirements with acceptance criteria
- *System Design*: Architecture overview and component design
- *Detailed Design*: Module-level specifications and algorithms
- *Implementation*: Auto-generated API documentation from source code
- *Testing*: Unit, integration, and acceptance test documentation with coverage metrics

This serves as a complete reference implementation demonstrating how to apply the V-Model in practice.

#pagebreak()

// Include the detailed narrative from python-project
#[
  #set heading(offset: 1)
  #include "../python-project/docs/main.typ"
]

#pagebreak()

// ============================================
// APPENDIX: BUILD INFORMATION
// ============================================

= Appendix: Documentation Build System

== About This Documentation

This documentation was automatically generated using a custom Typst-based pipeline that combines:

- *Hand-written narrative*: Product vision, V-Model phases, stakeholder analysis
- *Auto-generated API docs*: Extracted from Python source code using griffe
- *Test reports*: Generated from pytest execution with coverage metrics
- *Technical diagrams*: Created with Fletcher (Typst diagramming library)

=== Build Pipeline

#fig(
  "diagrams/build-pipeline.typ",
  caption: [Documentation Build Pipeline],
  label-ref: <fig-pipeline>
)

=== Key Features

- *Automatic Sync*: API docs extracted from code - never out of date
- *Type Safety*: Full type hint information included
- *Comprehensive Testing*: Coverage metrics and test results
- *V-Model Traceability*: Requirements → Design → Implementation → Testing
- *Dark Mode*: HTML output with automatic theme switching
- *Professional Typography*: Publication-quality PDF with Libertinus Serif

=== Technologies Used

*Documentation Generation:*
- Typst: Modern document compilation system
- griffe: Python API extraction (AST-based, no code execution)
- docstring-parser: Structured docstring parsing
- pytest + pytest-cov: Test execution and coverage
- Fletcher: Diagramming library for Typst

*Source Code:*
- Python 3.12+
- Type hints throughout
- Google-style docstrings
- PEP 8 compliant (enforced by Ruff)

=== Regenerating Documentation

To rebuild this documentation:

```bash
# From workspace root
make example
```

This will:
1. Generate colors and diagram assets
2. Extract API docs from Python source
3. Run tests and generate coverage reports
4. Compile all Typst diagrams to SVG
5. Build PDF and HTML outputs
6. Apply HTML post-processing for dark mode

== Document Metadata

*Generated:* #datetime.today().display() \
*Typst Version:* 0.12.0+ \
*Python Version:* 3.12+ \
*Test Framework:* pytest 8.0+ \
*Coverage Tool:* pytest-cov 4.0+ \
*Diagram Library:* Fletcher 0.5.8
