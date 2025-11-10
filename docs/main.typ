#import "../lib/technical-documentation-package.typ": *
#show: tech-doc

#outline(
  title: "Table of Contents",
  // depth: 3,
  indent: auto
)

#pagebreak()

// Style table header row (y: 0) as bold
#show table.cell.where(y: 0): strong

// Disable default table grid/strokes - only manual hlines will show
#set table(stroke: none)

// Align first column to left
#show table.cell.where(x: 0): set align(left)

#align(center)[
  #v(3em)
  #text(28pt, weight: "bold")[
    Medical Device Development
    <b---company-product>
  ]
]


= IVDR (EU) 2017/746 EN Version
<ivdr-eu-2017746-en-version>
== TEXTBOOK
<textbook>
#link("attachments/Regulatory_Pathways_for_IVD-Medical_Devices.docx")[Regulatory\_Pathways\_for\_IVD-Medical\_Devices.docx]
(2.2 MB)

= MDR (EU) 2017/745 EN Version
<mdr-eu-2017745-en-version>
== TEXTBOOK
<textbook-1>

#link("attachments/Regulatory_Pathways_for_Medical_Devices.docx")[Regulatory\_Pathways\_for\_Medical\_Devices.docx]
(2.1 MB)

= ExoPET
<exopet>
== iUse / wPrinciples / Classification
<iuse-wprinciples-classification>
=== Intended Purpose / Intended Use
<intended-purpose-intended-use>
#strong[Intended Purpose] \
The DUPLET / EXOPET system is intended to perform simultaneous
dual-tracer Positron Emission Tomography (PET) imaging using
radiopharmaceuticals that emit #betaplus particles, enabling non-invasive in
vivo detection, spatial localization, and functional characterization of
cancer lesions with high spatial and temporal resolution. It aims to
improve diagnosis and therapy planning by resolving intralesional and
interlesional tumor heterogeneity through the separation and analysis of
tracer-specific annihilation and nuclear gamma signals during a single
scan.

#strong[Clinical Application Domains:]

- Oncology diagnostics
- Patient stratification for peptide receptor radionuclide therapy
  (PRRT)
- Evaluation of metabolic vs.~receptor-mediated tracer uptake
- Comparative and translational imaging (e.g., human and veterinary
  oncology)

#strong[Target Population:] \
Patients undergoing diagnostic PET imaging for the assessment of cancer,
particularly in the context of tumor heterogeneity, therapeutic response
prediction, and theragnostic imaging pathways.

#strong[Medical Benefit:] \
Improved lesion-level characterization, reduced patient radiation
exposure (compared to sequential scans), better alignment of diagnostic
imaging with targeted therapies, and potential for new biomarker
discovery through positron annihilation lifetime analysis.

=== Working Principle, Components, and Accessories
<working-principle-components-and-accessories>
==== Working Principle
<working-principle>
DUPLET departs from traditional sinogram-based PET by acquiring and
analyzing #strong[list-mode PET data];, enabling:

- Capture of full photon energy and timestamp data for each detection
  event.
- Identification of #strong[triplet events];: two 511 keV annihilation
  photons and an additional prompt nuclear gamma (e.g., from #Ga68 or
  #Sc44 decay).
- Separation of signals from multiple tracers in one scan by applying
  #strong[energy-time discrimination];, positron lifetime analysis, and
  ML-supported pattern recognition.
- High-fidelity image reconstruction via
  #strong[Cartesian-time-histogram space] with increased sensitivity and
  signal-to-noise ratio (SNR).

==== System Components
<system-components>
  #table(
    columns: (auto, 1fr),
    align: (auto,auto,),
    table.hline(),
    [Subsystem], [Description],
    table.hline(),
    [PET Detector Hardware (EXOPET)], [Custom-built modular scanner
    using LYSO crystals and SiPMs in arc-ring architecture, optimized
    for high-throughput and extended energy range detection (400–1500
    keV).],
    [Acquisition Electronics], [FPGA-based PETsys electronics with
    dedicated clocks, coincidence logic, and NVMe-based DAQ system
    supporting \>15 GB/s.],
    [Software and ML-based Analysis], [Dual-tracer discrimination
    algorithms using MVA/BDT, supervised learning, and domain-adapted
    image reconstruction (CASTOR, STIR, Geant4/GATE).],
    [Radiotracers and Isotopes], [Dual-tracer combinations, typically
    #FDG and #Ga68PSMA or #Sc44FAPI().],
    [Image Analysis Workstation], [GPU-supported server platform
    integrated with BioMedIT/Leonhard Med.],
    table.hline(),
  )
==== Accessories
<accessories>
- Phantom sets for validation and calibration
- Cyclotron-based isotope production (e.g., #Sc44 via Ca(p,n)Sc)
- Dose calibrators, gamma spectrometers, and QA tools
- Clinical interface (graphical front-end for acquisition and
  processing)

=== MDR Classification with Rationale (Annex VIII MDR 2017/745)
<mdr-classification-with-rationale-annex-viii-mdr-2017745>
==== Applicable Rules (Annex VIII, MDR)
<applicable-rules-annex-viii-mdr>
#figure(
  align(center)[#table(
    columns: (auto, auto),
    align: (auto,auto,),
    table.hline(),
    [Rule], [Justification],
    table.hline(),
    [Rule 10], [Applies to active devices for diagnosis that monitor
    vital physiological processes. Although PET imaging is not direct
    vital monitoring, the functional data supports critical oncology
    therapy planning.],
    [Rule 11], [As DUPLET includes software intended to provide
    information used for diagnostic and therapeutic decisions (SaMD),
    Rule 11 governs classification based on impact to patient care.],
    table.hline(),
  )]
  , kind: table
  )

==== Proposed Classification: [Class IIb]
<proposed-classification-class-iib>
#strong[Rationale:]

- The system informs therapeutic interventions, including
  #strong[patient selection for radioligand therapy];, #strong[response
  assessment];, and #strong[dosimetry planning];, which per Rule 11(c)
  meets the threshold for Class IIb (software providing information for
  decisions with diagnosis or therapeutic purposes that may cause
  serious deterioration in health if incorrect).
- Custom hardware may also be interpreted under Rule 10(b) as an
  #strong[active diagnostic device];, which by default enters Class IIa
  unless risk factors elevate it.
- The combination of SaMD components and physical scanning platform used
  in humans mandates a Class IIb classification due to the
  #strong[direct therapeutic implications] of the diagnostic
  information.

==== Software Risk Classification (IEC 62304): Class C
<software-risk-classification-iec-62304-class-c>
- The software is used to inform treatment selection decisions (e.g.,
  inclusion/exclusion from PRRT protocols).
- Misclassification due to incorrect tracer separation or signal
  discrimination could lead to #strong[incorrect patient management];.

== Design and Development
<design-and-development>
=== D&D Planning
<dd-planning>
==== Explanations
<explanations>

#table(
    columns: (5cm, auto),
    align: (auto,auto,),
    table.hline(),
    [Element], [Explanation],
    table.hline(),
    [Design & Development Plan (DDP)], [A roadmap describing how the medical device is developed — from idea to product release.],
    [Task], [A specific action that must be performed during development.],
    [Standard Reference], [Which international regulation or standard applies (e.g., MDR, ISO 13485, IEC 62304).],
    [Responsible], [Who owns or leads the task (e.g., project manager, software lead, regulatory affairs).],
    [Deliverable], [What result, document, or milestone should come from the task.],
    [Remarks / Reference], [A space to track status (e.g., "done"), link documents, or make internal notes.],
    table.hline(),
  )

==== This plan must ensure compliance with:
<this-plan-must-ensure-compliance-with>
- #strong[ISO 13485:2016] – Quality management system
- #strong[MDR 2017/745] – EU medical device regulation
- #strong[ISO 14971:2019] – Risk management
- #strong[IEC 62304:2006+A1:2015] – Software development
- #strong[ISO 10993] – Biocompatibility
- #strong[ISO 14155:2020] – Clinical investigation
- #strong[IEC 60601] – Electrical safety
- #strong[ISO 20416:2020] – Post-market surveillance

==== Product Realization Plan
<product-realization-plan>
#link("attachments/Regulatory_Thinking_Product_Realization_Plan.xlsx")[Regulatory\_Thinking\_Product\_Realization\_Plan.xlsx]
(33.2 kB)

===== Design & Development Plan – DUPLET / EXOPET
<design-development-plan-duplet-exopet>

  #table(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (auto,auto,auto,auto,auto,auto,),
    table.hline(),
    [Phase / Milestone], [Task], [Standa
      Reference], [Responsible], [Review / Deliverable], [Remarks /
      Reference],
    table.hline(),
    [Initial Planning], [Define project structure], [ISO 13485 §7.3.2 /
    MDR Annex II], [Project Manager], [DDP v1], [],
    [Initial Planning], [Identify stakeholders], [ISO 13485
    §7.3.2], [Project Manager], [Stakeholder map], [],
    [Initial Planning], [Begin requirements management], [ISO 13485
    §7.3.2], [Project Manager], [Requirements overview], [],
    [User & Market Needs], [Define intended use], [MDR Annex
    I], [Regulatory Affairs + Clinicians], [Use specification], [],
    [User & Market Needs], [Capture use scenarios], [ISO 62366-1
    §5.2], [Usability Engineer], [Use scenario document], [],
    [User & Market Needs], [Define usability requirements], [ISO 62366-1
    §5.3], [Usability Engineer], [User needs matrix], [],
    [User & Market Needs], [Determine regulatory classification], [MDR
    Annex VIII], [Regulatory Affairs], [Classification report], [],
    [Risk Management], [Create risk management plan], [ISO 14971
    §4], [Safety Officer], [Risk Management Plan (RMP)], [],
    [Risk Management], [Perform preliminary hazard analysis (PHA)], [ISO
    14971 §5], [Safety Officer], [Preliminary Hazard Report], [],
    [Risk Management], [Conduct detailed risk analysis], [ISO 14971
    §6], [Safety Officer], [Risk analysis matrix], [],
    [System Design], [Define system architecture], [ISO 13485
    §7.3.3], [Technical Lead], [Architecture diagram], [],
    [System Design], [Specify hardware/software components], [ISO 13485
    §7.3.3], [System Architect], [Component specifications], [],
    [System Design], [Define system interfaces], [ISO 13485
    §7.3.3], [System Architect], [Interface specification], [],
    [Software Lifecycle], [Perform software safety classification], [IEC
    62304 §4], [Software Lead], [SW Safety Classification Report], [],
    [Software Lifecycle], [Create software development plan (SDP)], [IEC
    62304 §5], [Software Lead], [Software Development Plan], [],
    [Software Lifecycle], [Define SW architecture and modules], [IEC
    62304 §5.3], [Software Lead], [SW Architecture Document], [],
    [Software Lifecycle], [Plan unit and integration testing], [IEC
    62304 §5.5], [Software Lead], [SW Test Plan], [],
    [Design Outputs], [Create design output documentation], [ISO 13485
    §7.3.4], [HW + SW Design Team], [Design specifications, IFU,
    labels], [],
    [Verification], [Define verification strategy & test
    protocols], [ISO 13485 §7.3.6 / ISO 60601 / ISO 10993], [QA +
    Testing Team], [Verification plan and report], [],
    [Validation], [Prepare clinical validation (incl.~Human
    Factors)], [MDR Annex XIV / ISO 14155 / IEC 62366-2], [Clinical Team
    \+ Principal Investigator], [HFE Report, V&V Reports], [],
    [Final Risk Review], [Update risk management with V&V data], [ISO
    14971 §7–9], [Safety Officer], [Final Risk Report], [],
    [Design Transfer], [Prepare technical documentation for CE
    mark], [ISO 13485 §7.3.8 / MDR Annex II], [Regulatory
    Affairs], [Technical File], [],
    [Market Launch & PMS], [Prepare Post-Market Surveillance (PMS) and
    Vigilance], [MDR Chapter VII / ISO 20416], [RA + Post-Market
    Team], [PMS Plan, PMCF, Feedback Register], [],
    table.hline(),
  )
=== D&D Matrix (DiDo)
<dd-matrix-dido>
==== Stakeholder Definitions for DUPLET / EXOPET System
<stakeholder-definitions-for-duplet-exopet-system>
#table(
    columns: (5cm, auto),
    align: (auto,auto,),
    table.hline(),
    [Stakeholder], [Definition and Role],
    table.hline(),
    [Medical Doctors], [Physicians specializing in nuclear medicine,
    oncology, radiology, or theranostics who are responsible for
    clinical decision-making, patient inclusion, and interpretation of
    PET images.],
    [Nurses], [Clinical staff assisting in patient preparation, tracer
    injection, monitoring during the scan, and post-scan care. May also
    support informed consent and patient communication.],
    [Service & Maintenance Personnel], [Technicians responsible for
    ensuring hardware integrity, calibration, radiation shielding, IT
    network integration, and scheduled servicing of the PET scanner
    system and components.],
    [Patients], [Individuals undergoing dual-tracer PET imaging for
    diagnostic purposes, particularly in oncology. Their physiological
    condition directly influences imaging quality and safety
    considerations.],
    [Clinical Researchers / Investigators], [Professionals responsible
    for study design, protocol compliance, data acquisition, image
    annotation, and ensuring ethical compliance in human or veterinary
    studies.],
    [Veterinary Oncologists], [Clinicians involved in animal studies
    (e.g., canine sarcoma models), using DUPLET/EXOPET in translational
    oncology to bridge human and veterinary diagnostics.],
    [Radiopharmacists / Radiochemists], [Experts responsible for the
    production, radiolabeling, quality control, and dosing of PET
    tracers such as #FDG and #Sc44FAPI04 under GMP or
    equivalent standards.],
    [Software Developers / Data Scientists], [Personnel developing and
    maintaining the reconstruction, dual-tracer separation, and ML
    algorithms used in the image processing pipeline, ensuring software
    is reliable and traceable.],
    [Payers (e.g., Health Insurers)], [Institutions covering costs for
    diagnostic procedures; they require evidence of medical benefit,
    health economic value, and regulatory approval to support
    reimbursement.],
    [Competent Authorities], [National or regional regulatory bodies
    (e.g., Swissmedic, EMA, FDA) responsible for evaluating the
    conformity of the device and approving clinical trials and market
    access.],
    [Notified Bodies], [Designated organizations authorized to assess
    conformity to MDR requirements for CE certification (e.g., verifying
    GSPR compliance, technical documentation, and clinical
    evaluation).],
    [Hospital IT / PACS Admins], [Stakeholders responsible for
    integrating DUPLET system data into clinical IT infrastructure
    (e.g., PACS, RIS), ensuring cybersecurity and data interoperability
    (ISO/IEC 27001).],
    [Medical Physicists], [Experts involved in system calibration, dose
    optimization, and performance validation (e.g., NEMA NU 2-2018),
    ensuring patient safety and data quality.],
    [Ethics Committees / IRBs], [Bodies that approve and monitor
    clinical study protocols involving human or animal subjects,
    ensuring compliance with legal and ethical research standards (e.g.,
    Swiss HFG).],
    [PET Scanner Manufacturers], [Companies (e.g., GE, Siemens, Philips)
    providing commercial PET/CT systems. They may partner in hardware
    modification, acquisition mode configuration, or data extraction for
    DUPLET.],
    [External Reviewers / Auditors], [Third-party reviewers (e.g., for
    funding agencies, notified bodies, sponsors) who assess project
    progress, data integrity, and regulatory compliance throughout
    development and trials.],
    table.hline(),
  )

===== DIDO Matrix – DUPLET / EXOPET
<dido-matrix-duplet-exopet>
#table(
    columns: (auto, auto, auto, auto),
    align: (auto,auto,auto,auto,),
    table.hline(),
    [Stakeholder], [Stakeholder Requirement], [Product
      Requirement], [Preliminary Product Specification],
    table.hline(),
    [Medical Doctors], [Clear image separation for two
    tracers], [Dual-tracer separation must be \>90% accurate], [ML-based
    event separation algorithm with \>90% validated accuracy],
  [Medical Doctors], [Quantifiable lesion metrics (e.g., SUV for each
  tracer)], [Output DICOM images must include distinct tracer
  overlays], [DICOM output with dual-layer tracer overlays],
  [Medical Doctors], [Support therapy planning], [SUV quantification
  for each VOI must be available], [VOI-based SUV quantification and
  export to DICOM SR],
  [Nurses], [Safe injection procedure], [UI with tracer injection
  logging and safety alerts], [Touchscreen UI with injection tracker
  and alerts],
  [Nurses], [User-friendly patient interface], [Minimized patient
  movement workflow], [Patient position sensors with visual/audio
  alerts],
  [Service & Maintenance], [Easy access to system
  diagnostics], [Modular hardware with diagnostic port], [Maintenance
  GUI + VPN-enabled diagnostic access],
  [Service & Maintenance], [Replaceable parts with low
  MTTR], [Field-replaceable components and service
  documentation], [Quick-release board mounts and spare part kit],
  [Patients], [Minimal scan duration], [Scan duration \<15 min in dual
  mode], [Dual-mode scan preset: 5+5 min per tracer],
  [Patients], [Low radiation dose], [Compliant tracer dosage protocols
  per standard], [Dosimetry software linked to injection input],
  [Patients], [Accurate diagnosis], [High-resolution dual-tracer
  reconstruction pipeline], [Cartesian-time-histogram reconstruction
  pipeline],
  [Clinical Researchers], [Access to list-mode data], [Raw data export
  in standard formats (e.g., ROOT, HDF5)], [List-mode acquisition in
  ROOT/HDF5 with labeling],
  [Clinical Researchers], [Traceable reconstruction steps], [Log
  reconstruction parameters for traceability], [Configuration logs
  auto-attached to each dataset],
  [Radiopharmacists], [Compatibility with standard
  radiotracers], [Input for tracer type and time; compatible with GMP
  tracers], [UI/API for entering tracer info incl.~activity],
  [Radiopharmacists], [Accurate activity logging and half-life
  corrections], [Half-life correction algorithm with manual/API
  entry], [Decay correction engine tied to isotope metadata],
  [Software Developers], [Modular, testable
  pipeline], [Microservice-based modular backend], [Docker-based
  microservice deployment],
  [Software Developers], [Configurable ML models], [ML tuning via ONNX
  or equivalent format], [ONNX config panel with model selection
  option],
  [Payers / Insurers], [Evidence of diagnostic
  superiority], [Validation reports proving diagnostic
  accuracy], [Benchmark study dataset with labeled ground truth],
  [Payers / Insurers], [Cost-efficient scan path], [Health economic
  model for scan cost efficiency], [Cost analysis calculator for dual
  vs.~single scan],
  [Competent Authorities], [Conformity to MDR, ISO
  standards], [Complete technical file with GSPR checklist], [TD file
  structure with all ISO/MDR compliance sections],
  [Medical Physicists], [Calibration tools], [Support for standard
  phantoms and calibration scans], [Calibration GUI for daily/weekly
  QA using phantom],
  [Medical Physicists], [NEMA NU 2-2018 conformity], [Automated NEMA
  NU 2-2018 test suite], [NEMA test scripts + result dashboard],
  [Ethics Committees / IRBs], [Risk minimization for
  participants], [Radiation dose per tracer must stay within legal
  limits], [Tracer activity management in injection module],
  [Ethics Committees / IRBs], [Informed consent and data
  protection], [Data anonymization and encrypted storage], [Hash-based
  patient ID with AES encryption],
  [PET Scanner Manufacturers], [Compatibility with commercial
  scanners], [No interference with existing PET operations], [Clamp-on
  PET ring with passthrough DICOM I/O],
  [PET Scanner Manufacturers], [Minimal hardware
  interference], [Retrofittable PET ring
  hardware], [Aluminum/magnesium PET ring retrofit unit],
  [Veterinary Oncologists], [Adaptable scan workflow for
  animals], [Adjustable animal table insert with
  immobilization], [Animal positioning frame with adjustable bed],
  [Veterinary Oncologists], [Image resolution sufficient for small
  tumors], [Min. voxel resolution of 2 mm], [Image interpolation to 2
  mm resolution],
  [IT / PACS Admins], [Secure and interoperable image
  transfer], [Integration with PACS and secure transmission], [Secure
  PACS tunnel with dual-factor auth],
  [IT / PACS Admins], [DICOM support], [HL7/DICOM compliant export
  interface], [DICOM network node configuration module],
  table.hline(),
  )

===== System Components Overview – DUPLET / EXOPET
<system-components-overview-duplet-exopet>
#table(
    columns: (5cm, auto),
    align: (left,auto,),
    table.hline(),
    [System Component], [Definition and Purpose],
    table.hline(),
    [PET Detector Hardware (EXOPET Ring)], [Modular ring of LYSO
    crystals and SiPMs for detection of #betaplus annihilation and nuclear
    gamma rays (e.g., from #Ga68 or #Sc44). Enables simultaneous
    multi-tracer imaging with high spatial and temporal resolution.],
    [Acquisition Electronics & DAQ System], [FPGA-based timestamping and
    digitization of all detection events in list mode (incl. energy &
    time). High data rate and real-time storage for ML-supported event
    analysis.],
    [Image Processing Software & ML Pipeline], [Software framework for
    tracer discrimination (e.g., #Ga68 vs.~#F18), based on time-energy
    correlations and ML algorithms. Supports quantitative image
    reconstruction (e.g., SUV calculation) and positron lifetime
    analysis.],
    [User Interface & Workflow Software], [Touchscreen-controlled
    interface for managing injections, scan start/stop, logging, patient
    safety, and positioning. Workflow guidance to ensure dual-tracer
    compatibility.],
    [Radiopharmaceutical Interface], [Input modules for tracer
    information (e.g., activity, injection time, half-life), automated
    decay correction, and integration with dosimetry algorithms.
    GMP-compliant.],
    [Housing & Mechanics], [Clamp-on ring structure for retrofitting
    existing PET/CT devices. Maintenance-friendly, modular design with
    quick access to components for service purposes.],
    [Data Export & PACS Integration], [HL7 and DICOM-compatible export
    to clinical IT systems (PACS/RIS). Data transmission secured through
    AES encryption, audit trail, and BioMedIT integration.],
    [Calibration & QA Accessories], [NEMA NU-2 compliant phantoms (e.g.,
    IEC Body Phantom), automatic calibration routines, daily quality
    control functions for energy, time resolution, and sensitivity.],
    [Animal Imaging Interface], [Special imaging inserts and
    immobilization aids for PET/CT diagnostics in dogs (e.g., for
    comparative oncology). Adaptable for small animals.],
    [IT Security & Data Management], [Secure storage and processing of
    raw data and patient data. GDPR/HFG-compliant pseudonymization,
    role-based user login, data transmission via BioMedIT/Leonhard Med.],
    table.hline(),
  )
=== Verification and Validation (V&V)
<verification-and-validation-vv>
==== V&V Plan
<vv-plan>
==== V&V Report
<vv-report>
==== Testing
<testing>
=== Software Development
<software-development>
- #strong[Development environment & OS (IEC 62304 §5.1.6; ISO 13485
  §7.5.6)]
  - Document OS version, patch level, drivers, and system libraries.
  - Automate environment capture (`pip freeze`, `dpkg`,
    `conda env export`, `docker inspect`), plus manual notes for
    HW/driver/security settings.
- #strong[Containerization & virtual environments]
  - Develop in Docker/Podman with pinned tags/digests; use
    `venv`/`poetry` where containers are not feasible.
- #strong[Preferred container runtime: Podman over Docker]
  - Rootless and daemonless operation reduces attack surface and
    privileged-daemon risk; aligns with ISO 13485 secure environment
    control and MDR Annex I GSPR 17.2 (cybersecurity).
  - OCI-compatible; near drop-in for Docker CLI; interoperable images
    and registries; works in CI without `--privileged` Docker-in-Docker.
  - Clear separation of build/run users and systemd integration supports
    policy-based control in regulated environments.
  - Docker remains acceptable where infrastructure requires it; images
    are interchangeable (OCI).
- #strong[Reproducible builds & CI/CD (IEC 62304 §5; ISO 13485 §7.3; FDA
  GPSV)]
  - Build-as-code; deterministic builds with checksums and logs;
    automated unit/integration tests; optional artifact signing.
- #strong[Python environment management: prefer uv (IEC 62304 §5.1.6,
  §8; ISO 13485 §7.5.6)]
  - Use `uv` for fast, deterministic dependency resolution with lockfile
    and hashed pins; commit lockfile for reproducibility.
  - Workflow: `uv init`/`uv add` → `uv lock` → `uv sync` →
    `uv run -m pytest` in CI for hermetic builds.
  - Where heavy native stacks are needed (e.g., CUDA, MKL), allow base
    setup via Conda/Mamba; install application deps with `uv`; document
    in `environment.md`.
  - `uv` remains pip-compatible (`uv pip install -r requirements.txt`)
    for incremental adoption.
- #strong[SOUP inventory and evaluation (IEC 62304 Annex C)]
  - Maintain an SBOM of OS, libraries, drivers, and ML frameworks (e.g.,
    `glibc`, CUDA).
  - Record intended use, known anomalies, and available
    verification/validation evidence.
- #strong[Change and patch management (ISO 13485 §7.3.9; IEC 62304 §6;
  ISO/TR 80002‑1; ISO 14971)]
  - Define process for OS/library updates and CVEs: impact analysis,
    risk evaluation, regression testing, and documented decision.
- #strong[Configuration and traceability (IEC 62304 §5.1.5, §8; ISO
  13485 §7.3.3)]
  - Maintain bidirectional traceability: requirements → design →
    implementation → tests → risks/controls.
  - Use tagged releases; link releases to Docker image digests and
    commit IDs.
- #strong[Audit focus (MDR Annex I GSPR 17.2; IEC 62304)]
  - SOUP classification and control; validated environment; reproducible
    build pipeline; evidence of verification/validation.
- #strong[Concrete next steps (EXOPET)]
  - Create/maintain `environment.md`, `requirements.txt`, and
    `Dockerfile` with pinned versions and image digests.
  - Establish CI/CD to produce test reports and signed build artifacts.
  - Start SOUP/SBOM list (OS, `glibc`, CUDA, ML frameworks, drivers) and
    evaluation records.
  - Define patch policy and responsibilities, incl.~CVE monitoring
    cadence.
- #strong[Core deliverables (IEC 62304 / ISO 13485)]
  - Software Development Plan (SDP), Software Architecture Document,
    Software Verification & Validation Plan/Report, Configuration
    Management and Problem Resolution procedures.

==== ISO 62304 Checklist
<iso-62304-checklist>
#link("attachments/ISO_62304_Implementation_Checklist.xlsx")[ISO\_62304\_Implementation\_Checklist.xlsx]
(37.5 kB)

== Risk Management (RM)
<risk-management-rm>
=== RM Plan
<rm-plan>
#link("attachments/BD_Risk_Management_Plan.docx")[BD\_Risk\_Management\_Plan.docx]
(114.6 kB)

=== RM Report
<rm-report>
#link("attachments/BD_Risk_Management_Report.docx")[BD\_Risk\_Management\_Report.docx]
(77.7 kB)

=== FMEA
<fmea>
== Usability Engineering (UE)
<usability-engineering-ue>
=== UE Plan
<ue-plan>
=== UE Report
<ue-report>
== Clinical Evaluation (ClinEval)
<clinical-evaluation-clineval>
=== Clinical Study Development Plan
<clinical-study-development-plan>
==== IB MDR - Investigator´s Brochure
<ib-mdr---investigators-brochure>
#link("attachments/RT_Basis-Document_IB_MD.docx")[RT\_Basis-Document\_IB\_MD.docx]
(90.6 kB)

=== ClinEval Plan
<clineval-plan>
=== ClinEval Report
<clineval-report>
== EU AI ACT
<eu-ai-act>
== PMS - Post Market Surveillance
<pms---post-market-surveillance>
=== Post Market Surveillance Medical Devices
<post-market-surveillance-medical-devices>
=== Post Market Surveillance IVD Medical Devices
<post-market-surveillance-ivd-medical-devices>
