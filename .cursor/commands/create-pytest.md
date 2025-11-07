# Instructions for Writing Pytest Tests

## Core Directive

When asked to write tests, you MUST write tests that validate **what code should do**, not verify **what code does**. Focus on intentions and business rules, not implementation details.

## Your Constraints

1. **Write ONE test at a time** - Never generate multiple tests in a single response unless explicitly requested
2. **Ask clarifying questions** - Before writing tests, ask: "What specific behavior or edge case should I test?"
3. **Default to minimal coverage** - Resist the urge to test every parameter combination or prop variant
4. **Justify each test** - Explain why this test catches meaningful bugs or validates business logic

## What You MUST Test

- Business logic and domain rules (e.g., "users cannot order negative quantities")
- Edge cases and boundary conditions (e.g., empty inputs, maximum values)
- Error handling and failure modes (e.g., what happens when API calls fail)
- Integration points and contracts (e.g., correct data passed between functions)
- Security constraints (e.g., unauthorized access is blocked)
- Unexpected user actions (e.g., submitting forms multiple times)

## What You MUST NOT Test

- Framework behavior (e.g., "does React render correctly?")
- Language features (e.g., "does variable assignment work?")
- Every possible prop/parameter combination
- Implementation details (private methods, internal class names, exact CSS classes)
- Things that would break the entire ecosystem if they failed (e.g., basic HTML button rendering)
- Whether imports work correctly

## Before Writing Any Test

Ask yourself: "If this test fails, does it indicate the code diverged from intended behavior, or just that implementation changed?"

If the answer is "just implementation changed," DO NOT write the test.

## Example Interaction Pattern

**User**: "Write tests for this button component"

**You**: "I should focus on meaningful behavior rather than exhaustive coverage. What specific behavior should I test? For example:
- Does the button need to prevent double-submission?
- Are there accessibility requirements?
- Should certain variants be disabled under specific conditions?

Otherwise, I'll write a minimal test validating it renders and handles clicks."

## When to Push Back

If you find yourself about to generate 10+ tests for a simple component, STOP. Tell the user:

"I'm about to generate many tests that verify implementation details rather than validate behavior. Can you specify which business rules or edge cases I should focus on?"

## Remember

- Fewer focused tests > many brittle tests
- Business logic > framework behavior
- Intentions > implementations
- Test code like it's production code - every line must justify its existence
