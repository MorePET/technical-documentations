# Notations Package Documentation

## Overview

The `notations.typ` package provides a comprehensive system for writing isotope and radiopharmaceutical notation in Typst documents, using the `@preview/physica:0.9.4` package.

## Usage

```typst
#import "lib/notations.typ": *
// or through the technical documentation package:
#import "lib/technical-documentation-package.typ": *
```

## Isotope Notation

### Individual Isotopes

Pre-defined isotope constants with proper superscript mass numbers:

```typst
#F18   // ¹⁸F
#F19   // ¹⁹F
#Ga68  // ⁶⁸Ga
#Sc44  // ⁴⁴Sc
#Sc47  // ⁴⁷Sc
#C11   // ¹¹C
#C13   // ¹³C
#C14   // ¹⁴C
#I123  // ¹²³I
#I131  // ¹³¹I
#Tc99m // ⁹⁹ᵐTc
#O15   // ¹⁵O
#N13   // ¹³N
```

### Custom Isotopes

Use the `nuclide()` function for custom isotopes:

```typst
#nuclide("U", A: 235)           // ²³⁵U (mass number only)
#nuclide("U", A: 235, Z: 92)    // ²³⁵₉₂U (mass and atomic number)
```

## Radiopharmaceutical Tracers (DRY & SOLID Design)

### Core Building Blocks

The system follows SOLID principles with three composable functions:

1. **`isotope(element, a: mass)`** - creates isotope notation
2. **`ligand(name, id: none)`** - creates ligand with optional ID
3. **`tracer(isotope, ligand)`** - combines isotope + ligand

### Creating Ligands

```typst
#ligand("FDG")                 // FDG
#ligand("PSMA")                // PSMA
#ligand("FAPI")                // FAPI
#ligand("FAPI", id: "04")      // FAPI-04
#ligand("PSMA", id: "617")     // PSMA-617
```

### Creating Tracers by Composition

Combine any isotope with any ligand:

```typst
// Using named parameters (recommended for clarity)
#tracer(isotope: F18, ligand: ligand("FDG"))

// Using positional parameters
#tracer(F18, ligand("FDG"))                    // ¹⁸F-FDG
#tracer(Ga68, ligand("PSMA"))                  // ⁶⁸Ga-PSMA
#tracer(Sc44, ligand("FAPI", id: "04"))        // ⁴⁴Sc-FAPI-04
#tracer(I131, ligand("MIBG"))                  // ¹³¹I-MIBG
#tracer(C11, ligand("Methionine"))             // ¹¹C-Methionine
```

### Pre-defined Common Tracers

For convenience, common tracers are pre-defined:

```typst
#FDG          // ¹⁸F-FDG
#Ga68PSMA     // ⁶⁸Ga-PSMA
#Sc44PSMA     // ⁴⁴Sc-PSMA
#F18PSMA      // ¹⁸F-PSMA
#Ga68FAPI04   // ⁶⁸Ga-FAPI-04
#Sc44FAPI04   // ⁴⁴Sc-FAPI-04
#Ga68FAPI46   // ⁶⁸Ga-FAPI-46
#Sc44FAPI46   // ⁴⁴Sc-FAPI-46
#Ga68DOTATATE // ⁶⁸Ga-DOTATATE
#Ga68DOTATOC  // ⁶⁸Ga-DOTATOC
#C11PIB       // ¹¹C-PIB
#F18FET       // ¹⁸F-FET
#I131MIBG     // ¹³¹I-MIBG
```

### Dynamic FAPI Functions

FAPI tracers support flexible ID specification:

```typst
#Ga68FAPI()           // ⁶⁸Ga-FAPI (no ID)
#Ga68FAPI(id: "04")   // ⁶⁸Ga-FAPI-04
#Ga68FAPI(id: "46")   // ⁶⁸Ga-FAPI-46
#Sc44FAPI(id: "02")   // ⁴⁴Sc-FAPI-02
```

### Pre-defined Ligand Constants

Common ligands are available as constants:

```typst
FDG-ligand        // FDG
PSMA-ligand       // PSMA
FAPI-ligand       // FAPI
FAPI04-ligand     // FAPI-04
FAPI46-ligand     // FAPI-46
DOTATATE-ligand   // DOTATATE
DOTATOC-ligand    // DOTATOC
PIB-ligand        // PIB
FET-ligand        // FET
MIBG-ligand       // MIBG
```

Use them to create custom combinations:

```typst
#tracer(F18, PSMA-ligand)      // ¹⁸F-PSMA
#tracer(Sc47, FAPI04-ligand)   // ⁴⁷Sc-FAPI-04
```

## Particles and Symbols

```typst
#betaplus   // β⁺
#betaminus  // β⁻
```

## Examples in Context

```typst
#import "lib/notations.typ": *

= PET Imaging Study

Radiopharmaceuticals that emit #betaplus particles enable PET imaging.

Dual-tracer combinations typically include #FDG and #Ga68PSMA or #Sc44FAPI().

The radiopharmacist prepared #FDG and #Sc44FAPI04 under GMP conditions.

Comparison study: #F18PSMA vs #Ga68PSMA in prostate cancer imaging.

Detection of triplet events from #Ga68 or #Sc44 decay enables multi-tracer separation.
```

## Creating Custom Tracers

The composable design allows maximum flexibility:

```typst
// Create a custom ligand
#let MyLigand = ligand("CustomCompound", id: "v2")

// Use it with any isotope
#tracer(F18, MyLigand)        // ¹⁸F-CustomCompound-v2
#tracer(Ga68, MyLigand)       // ⁶⁸Ga-CustomCompound-v2

// On-the-fly custom tracers
#tracer(N13, ligand("Ammonia"))           // ¹³N-Ammonia
#tracer(O15, ligand("Water"))             // ¹⁵O-Water
#tracer(C11, ligand("Acetate"))           // ¹¹C-Acetate
#tracer(F18, ligand("Florbetapir"))       // ¹⁸F-Florbetapir
#tracer(Ga68, ligand("PSMA", id: "617"))  // ⁶⁸Ga-PSMA-617
```

## Technical Notes

### HTML Export with Unicode Superscripts

The notation system uses different rendering approaches for PDF and HTML:

**How it works:**
- **PDF export:** Uses the `physica` package's `isotope()` function for proper mathematical typography
- **HTML export:** Uses Unicode superscript characters (e.g., ⁴⁴, ⁶⁸, ¹⁸) for clean text output
- Automatic mode detection via `sys.inputs.at("html-export", default: "false")`
- Inline isotopes stay inline within paragraphs in both formats

**Implementation:**

```typst
#let nuclide(element, A: none, Z: none) = context {
  let is-html = sys.inputs.at("html-export", default: "false") == "true"

  if is-html {
    // HTML: use Unicode superscripts/subscripts
    [#to-superscript(str(A))#element]
  } else {
    // PDF: use physica package for proper typography
    isotope(element, a: str(A))
  }
}
```

**Benefits:**
- Clean ASCII/Unicode text in HTML (no SVG fragments needed)
- Perfect math typography in PDF using physica package
- Better accessibility - screen readers can read the Unicode text directly
- Smaller HTML file sizes (no embedded SVGs for isotopes)
- Better text selection and copy/paste in HTML

### Implementation Details

- Unicode superscript mapping: 0→⁰, 1→¹, 2→², 3→³, 4→⁴, 5→⁵, 6→⁶, 7→⁷, 8→⁸, 9→⁹, m→ᵐ, n→ⁿ, +→⁺, -→⁻
- Unicode subscript mapping: 0→₀, 1→₁, 2→₂, 3→₃, 4→₄, 5→₅, 6→₆, 7→₇, 8→₈, 9→₉
- Beta particles (β⁺ and β⁻) also use Unicode in HTML export for consistency
- Hyphens in tracer names are escaped to prevent interpretation as subtraction
- Supports full range of mass numbers (0-9) and special characters (m for metastable states)
- The build script (`build-html-bootstrap.py`) automatically sets the `html-export=true` flag

## Design Principles (DRY & SOLID)

### Single Responsibility Principle

Each function has one clear purpose:

- `isotope()` - creates isotope notation only
- `ligand()` - creates ligand notation only
- `tracer()` - combines isotope + ligand only

### Don't Repeat Yourself (DRY)

- No element-specific tracer functions (removed `F18tracer()`, `Ga68tracer()`, etc.)
- Single `tracer()` function handles all isotope-ligand combinations
- Ligand logic centralized in one `ligand()` function

### Open/Closed Principle

- System is open for extension (add new isotopes/ligands)
- Closed for modification (core functions don't need changes)
- Example: Add new isotopes by defining constants, not modifying functions

### Composition over Inheritance

- Build complex tracers by composing simple building blocks
- `tracer(isotope, ligand)` composes two independent concepts
- Users can create any combination without code changes

### Dependency Inversion

- High-level pre-defined tracers (`#FDG`, `#Ga68PSMA`) depend on abstractions
- Core functions (`tracer`, `ligand`, `isotope`) are stable abstractions
- Changes to specific tracers don't affect the core system
