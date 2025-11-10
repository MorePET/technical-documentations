// Test Pyramid Diagram
// Shows the testing strategy with unit and integration tests

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let file_main = read("../../tests/test_main.py")
#let file_hello = read("../../tests/test_hello.py")

// Count total tests (simple heuristic: functions starting with test_)
#let test_pattern = regex("(?m)^\\s*def\\s+test_")
#let total_main_tests = file_main.find(test_pattern).len()
#let total_hello_tests = file_hello.find(test_pattern).len()
#let total_tests = total_main_tests + total_hello_tests

// Count integration tests (all test_ methods after 'class TestIntegration')
#let integration_parts = file_main.split("class TestIntegration")
#let integration_body = if integration_parts.len() > 1 { integration_parts.at(1) } else { "" }
#let integration_tests = integration_body.find(test_pattern).len()

// Unit tests = total - integration
#let unit_tests = total_tests - integration_tests
#let e2e_tests = 0 // no explicit e2e tests detected in this project

// Geometry for pyramid layers with consistent slope
#let cx = 5.0        // center x
#let y_top = 0.0
#let y_mid = 1.5
#let y_base = 3.0

#let w_top = 6em
#let w_base = 16em
#let w_mid = w_top + (w_base - w_top) * ((y_mid - y_top) / (y_base - y_top))

#let half = x => x / 2

#align(center)[
  #diagram(
    spacing: (2em, 2em),
    node-stroke: 1pt,

    // Top layer (E2E/System)
    node((cx, y_top), [E2E / System Tests (#e2e_tests)], shape: fletcher.shapes.rect, width: w_top, height: 1.2em, fill: orange.lighten(70%), stroke: 1pt + orange.darken(20%)),

    // Middle layer (Integration)
    node((cx, y_mid), [Integration Tests (#integration_tests)], shape: fletcher.shapes.rect, width: w_mid, height: 1.3em, fill: purple.lighten(75%), stroke: 1pt + purple.darken(20%)),

    // Bottom layer (Unit)
    node((cx, y_base), [Unit Tests (#unit_tests)], shape: fletcher.shapes.rect, width: w_base, height: 1.6em, fill: blue.lighten(70%), stroke: 1pt + blue.darken(20%)),
  )
]
