// Nuclear and radiopharmaceutical notation package
// Uses physica package for PDF, Unicode superscripts for HTML export
//
// HTML export automatically uses clean Unicode text (e.g., ⁴⁴Sc)
// PDF export uses physica package for proper mathematical typesetting

#import "@preview/physica:0.9.4": isotope

// ========================================
// Unicode character mappings for HTML export
// ========================================

// Map regular digits and letters to Unicode superscript characters
#let to-superscript(text) = {
  let char-map = (
    "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
    "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹",
    "m": "ᵐ", "n": "ⁿ",
    "+": "⁺", "-": "⁻",
  )

  let result = ""
  for char in text {
    result += char-map.at(char, default: char)
  }
  result
}

// Map regular digits to Unicode subscript characters
#let to-subscript(text) = {
  let char-map = (
    "0": "₀", "1": "₁", "2": "₂", "3": "₃", "4": "₄",
    "5": "₅", "6": "₆", "7": "₇", "8": "₈", "9": "₉",
  )

  let result = ""
  for char in text {
    result += char-map.at(char, default: char)
  }
  result
}

// ========================================
// Core isotope notation function
// ========================================
// A = mass number (superscript)
// Z = atomic number (subscript, optional)
//
// PDF: Uses physica package for proper math typography
// HTML: Uses Unicode superscripts for clean text output
#let nuclide(element, A: none, Z: none) = context {
  let is-html = sys.inputs.at("html-export", default: "false") == "true"

  if is-html {
    // HTML export: use Unicode superscripts/subscripts
    if Z != none {
      [#to-superscript(str(A))#to-subscript(str(Z))#element]
    } else if A != none {
      [#to-superscript(str(A))#element]
    } else {
      element
    }
  } else {
    // PDF export: use physica package for proper typography
    if Z != none {
      isotope(element, a: str(A), z: str(Z))
    } else if A != none {
      isotope(element, a: str(A))
    } else {
      element
    }
  }
}

// ========================================
// Convenience wrappers for common isotopes
// ========================================

// Fluorine isotopes
#let F18 = nuclide("F", A: "18")
#let F19 = nuclide("F", A: "19")

// Gallium isotopes
#let Ga68 = nuclide("Ga", A: "68")

// Scandium isotopes
#let Sc44 = nuclide("Sc", A: "44")
#let Sc47 = nuclide("Sc", A: "47")

// Carbon isotopes (for research/labeling)
#let C11 = nuclide("C", A: "11")
#let C13 = nuclide("C", A: "13")
#let C14 = nuclide("C", A: "14")

// Iodine isotopes
#let I123 = nuclide("I", A: "123")
#let I131 = nuclide("I", A: "131")

// Technetium
#let Tc99m = nuclide("Tc", A: "99m")

// Oxygen
#let O15 = nuclide("O", A: "15")

// Nitrogen
#let N13 = nuclide("N", A: "13")

// ========================================
// Radiopharmaceutical Tracer System
// ========================================

// Ligand builder function
// Creates a ligand with optional ID
#let ligand(name, id: none) = {
  if id != none and id != "" {
    [#name\-#id]
  } else {
    [#name]
  }
}

// Core tracer builder function
// Combines isotope and ligand into a radiopharmaceutical notation
// Call with: tracer(isotope: F18, ligand: FDG-ligand) or tracer(F18, FDG-ligand)
#let tracer(isotope, ligand) = {
  [#isotope\-#ligand]
}

// ========================================
// Common ligands
// ========================================

#let FDG-ligand = ligand("FDG")
#let PSMA-ligand = ligand("PSMA")
#let FAPI-ligand = ligand("FAPI")
#let FAPI04-ligand = ligand("FAPI", id: "04")
#let FAPI46-ligand = ligand("FAPI", id: "46")
#let DOTATATE-ligand = ligand("DOTATATE")
#let DOTATOC-ligand = ligand("DOTATOC")
#let PIB-ligand = ligand("PIB")
#let FET-ligand = ligand("FET")
#let MIBG-ligand = ligand("MIBG")

// ========================================
// Common radiopharmaceutical compounds
// ========================================

// FDG variants
#let FDG = tracer(F18, FDG-ligand)

// PSMA variants
#let Ga68PSMA = tracer(Ga68, PSMA-ligand)
#let Sc44PSMA = tracer(Sc44, PSMA-ligand)
#let F18PSMA = tracer(F18, PSMA-ligand)

// FAPI variants - as functions for flexible ID
#let Ga68FAPI(id: none) = tracer(Ga68, ligand("FAPI", id: id))
#let Sc44FAPI(id: none) = tracer(Sc44, ligand("FAPI", id: id))

// Common specific FAPI compounds
#let Ga68FAPI04 = tracer(Ga68, FAPI04-ligand)
#let Sc44FAPI04 = tracer(Sc44, FAPI04-ligand)
#let Ga68FAPI46 = tracer(Ga68, FAPI46-ligand)
#let Sc44FAPI46 = tracer(Sc44, FAPI46-ligand)

// DOTATATE/DOTATOC variants
#let Ga68DOTATATE = tracer(Ga68, DOTATATE-ligand)
#let Ga68DOTATOC = tracer(Ga68, DOTATOC-ligand)

// Other common tracers
#let C11PIB = tracer(C11, PIB-ligand)
#let F18FET = tracer(F18, FET-ligand)
#let I131MIBG = tracer(I131, MIBG-ligand)

// ========================================
// Greek symbols and particles
// ========================================

// Beta particles with Unicode support for HTML
// PDF: Uses math mode for proper typography
// HTML: Uses Unicode β⁺ and β⁻ for clean text output
#let betaplus = context {
  let is-html = sys.inputs.at("html-export", default: "false") == "true"
  if is-html {
    [β⁺]
  } else {
    $beta^+$
  }
}

#let betaminus = context {
  let is-html = sys.inputs.at("html-export", default: "false") == "true"
  if is-html {
    [β⁻]
  } else {
    $beta^-$
  }
}
