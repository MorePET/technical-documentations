// Nuclear and radiopharmaceutical notation package
// Uses physica package with html.frame for HTML export compatibility
//
// Note: HTML export is enabled via show rule in technical-documentation-package.typ

#import "@preview/physica:0.9.4": isotope

// ========================================
// Core isotope notation function
// ========================================
// A = mass number (superscript)
// Z = atomic number (subscript, optional)
//
// Uses physica package for both PDF and HTML
// HTML export enabled via html.frame show rule above
#let nuclide(element, A: none, Z: none) = {
  if Z != none {
    isotope(element, a: str(A), z: str(Z))
  } else if A != none {
    isotope(element, a: str(A))
  } else {
    element
  }
}

// ========================================
// Convenience wrappers for common isotopes
// ========================================

// Fluorine isotopes
#let F18 = isotope("F", a: "18")
#let F19 = isotope("F", a: "19")

// Gallium isotopes
#let Ga68 = isotope("Ga", a: "68")

// Scandium isotopes
#let Sc44 = isotope("Sc", a: "44")
#let Sc47 = isotope("Sc", a: "47")

// Carbon isotopes (for research/labeling)
#let C11 = isotope("C", a: "11")
#let C13 = isotope("C", a: "13")
#let C14 = isotope("C", a: "14")

// Iodine isotopes
#let I123 = isotope("I", a: "123")
#let I131 = isotope("I", a: "131")

// Technetium
#let Tc99m = isotope("Tc", a: "99m")

// Oxygen
#let O15 = isotope("O", a: "15")

// Nitrogen
#let N13 = isotope("N", a: "13")

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

// Beta particles
#let betaplus = $beta^+$
#let betaminus = $beta^-$
