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

#note(["This is merely an example of the power of typst to create beautiful, professional documents in pdf and html."])

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

