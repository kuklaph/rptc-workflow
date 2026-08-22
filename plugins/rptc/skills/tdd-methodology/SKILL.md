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
6. Run nearby affected checks.
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

- Assert externally meaningful outcomes.
- Mock external boundaries, not the system under test.
- Keep each test deterministic and independent.
- Do not weaken an assertion merely to match current production behavior.
- Do not add quota-driven tests or target a universal coverage percentage.
- Follow project-defined coverage and test policies when they exist.

## Evidence

Report the exact failing-before and passing-after commands and observations.
A statement that TDD was followed is not evidence.
