// Import the technical documentation package
#import "technical-documentation-package.typ": *
// apply styles to the document
#show: tech-doc



= Stakeholder Analysis Matrix

There are various ways to use tables and typst programming to implement a stakeholder analysis matrix. Here are examples of how to do it.
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

== From a CSV file
<from-csv-file>
#stakeholder-table-from-csv(
  file: "stakeholders.csv",
)

== From a JSON file
<from-json-file>
#stakeholder-table-from-json(
  file: "stakeholders.json",
)

== From a YAML file
<from-yaml-file>
#stakeholder-table-from-yaml(
  file: "stakeholders.yaml",
)

#pagebreak()

= Technical Diagrams with Fletcher

The technical documentation package includes powerful diagram capabilities using Fletcher, a Typst library for creating flowcharts, architecture diagrams, and state machines. All diagrams support both PDF and HTML output with automatic dark mode adaptation.

#note([
  *Dark Mode Support*: When viewing in HTML, these diagrams automatically adapt to your system's color scheme. Try toggling dark mode to see the colors change seamlessly!
])

== System Architecture Diagram

A system architecture diagram helps visualize how different components of a software system interact. This example shows a typical three-tier web application architecture with a frontend, API gateway, backend services, database, and caching layer.

*Use cases*:
- Documenting microservices architectures
- Planning infrastructure layouts
- Communicating system design to stakeholders
- Technical onboarding materials

#architecture-diagram()

The architecture diagram above illustrates:
- *Frontend*: User-facing web application
- *API Gateway*: Entry point for all client requests, handles routing and load balancing
- *Backend*: Application logic and business rules
- *Database*: Persistent data storage with SQL queries
- *Cache*: Redis layer for performance optimization

This pattern is commonly used in modern cloud-native applications, where each component can be scaled independently based on load requirements.

== Data Flow Diagram

Data flow diagrams trace how information moves through a system, from input to output. They're essential for understanding data transformations, identifying bottlenecks, and planning data governance strategies.

*Use cases*:
- ETL (Extract, Transform, Load) pipeline documentation
- Data privacy impact assessments
- API integration specifications
- Quality assurance planning

#data-flow-diagram()

The data flow shows a typical processing pipeline:
1. *User Input*: Raw data enters the system
2. *Validation*: Input is checked for correctness and security
3. *Processing*: Core business logic is applied
4. *External API*: Data is enriched with third-party information
5. *Storage*: Final results are persisted to the database

This pattern ensures data quality and enables traceability throughout the system. Each transformation step can be monitored, logged, and audited for compliance requirements.

== State Machine Diagram

State machines model how systems transition between different states in response to events. They're invaluable for workflow design, business process modeling, and ensuring state consistency in distributed systems.

*Use cases*:
- Order fulfillment workflows
- Document approval processes
- User authentication flows
- IoT device lifecycle management

#state-diagram()

The workflow state machine represents a document review process:
- *Draft*: Initial creation phase where authors can freely edit
- *Review*: Document is submitted for peer review and approval
- *Approved*: Content has passed review and is published
- *Rejected*: Review identified issues requiring revision

Transitions between states are triggered by user actions (submit, approve, reject) or system events (timeout, validation failure). The "revise" transition creates a feedback loop, allowing iterative improvement until approval is achieved.

== Benefits of Diagram-Driven Documentation

Using diagrams in technical documentation provides several advantages:

*Clarity*: Visual representations often communicate complex concepts more effectively than text alone. A single diagram can replace pages of description.

*Maintenance*: Diagrams created with code (like these Fletcher examples) can be version-controlled, diffed, and automatically regenerated when system designs change.

*Accessibility*: Modern diagram tools produce semantic markup that works with screen readers and other assistive technologies.

*Consistency*: Using a standardized diagramming library ensures visual consistency across all documentation, making it easier for readers to understand different sections.

*Collaboration*: Text-based diagram definitions can be reviewed in pull requests just like code, enabling better team collaboration.

#note([
  *Pro Tip*: These diagrams are defined in simple Typst code and can be customized with different colors, layouts, and labels to match your specific use case. Check the source code to see how easy they are to modify!
])

