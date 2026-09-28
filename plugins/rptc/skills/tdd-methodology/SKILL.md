---
name: tdd-methodology
description: Build changed behavior through small failing-then-passing vertical slices at a stable seam. Use when behavior changes and a practical executable test path exists. Skip for prototypes, pure documentation, and cases where a new test would be brittle or disproportionately expensive.
---

# TDD Methodology

## Outcome

Protect meaningful behavior through a repeatable executable check.

## Choose the seam

Prefer the highest stable interface that is still fast enough for development.
Tests should exercise what a caller or user can observe, not private helper
calls or incidental internal state.

Use existing project test patterns before introducing a new harness.

## Vertical loop

For each behavior:

1. State the observable behavior.
2. Add the smallest test that expresses it.
3. Run that test and confirm it fails for the intended reason.
4. Add the smallest implementation that makes it pass.
5. Run the focused test.
6. Run the affected checks: the tests that reach the changed code through
   imports, calls, or fixtures, not only the same-named test file.
7. Continue with the next behavior.
8. Refactor only while the checks remain green.

Use:

`RED -> minimal GREEN -> next RED -> minimal GREEN -> refactor`

Do not write a complete imagined test suite before implementation teaches you
about the interface.

## Bug fixes

A regression test is useful when it can reproduce the confirmed bug at a stable
seam. Demonstrate failing-before and passing-after behavior.

When a practical test is unavailable, state why and use the closest executable
check: a targeted script, browser drive, CLI transcript, integration command,
trace comparison, or other repeatable observation.

## Test quality

- Add tests where the task asks for them or the repository already keeps tests
  for this kind of change. Aim for one focused test per stated behavior. Do not
  add tests for reversible, low-impact changes that would only mirror the
  implementation.
- Derive expected values from the requirement or contract, not by reading or
  running the implementation. The exception is a characterization test written
  on purpose to pin current behavior before a refactor.
- Include the boundary and failure behaviors the requirement implies, not only
  the happy path.
- Mock only external or nondeterministic boundaries. Use real internal
  collaborators and assert outputs or state, not calls to internals.
- Keep each test deterministic and independent.
- For inherently nondeterministic output, such as LLM-backed features, assert
  facts, structure, contracts, and security properties exactly. Allow tolerance
  only for free-form prose, and never widen a tolerance to silence flakiness.
- Reach GREEN only through the requested behavior. For tests whose expected
  behavior the request does not change, do not delete, skip, loosen, or rewrite
  them, special-case test inputs, or detect the test environment. If such a test
  conflicts with the requirement, stop and report the conflict.
- When the request intentionally changes behavior, update the assertions that
  encode the old behavior, and list each test you edited or removed in the
  report.
- "Minimal" GREEN still means real logic for all valid inputs.
- Do not add quota-driven tests or target a universal coverage percentage.
- Follow project-defined coverage and test policies when they exist.

## Evidence

Report the exact failing-before and passing-after commands and observations.
A statement that TDD was followed is not evidence.
