---
name: architect-methodology
description: Design implementation structure when module boundaries, interfaces, data shapes, dependencies, ownership, or sequencing are genuinely uncertain. Use before non-trivial cross-component work or high-risk changes. Skip localized work that follows an established pattern.
---

# Architect Methodology

## Outcome

Produce the smallest design decision needed to implement and verify the change.

## Ground first

Read the affected entry points, public contracts, tests, consumers, project
instructions, and nearby patterns. Distinguish current behavior from intended
behavior.

## Decide what needs design

Focus on:

- the public seam;
- the core data shape and invariants;
- ownership of behavior and state;
- dependency direction;
- migration and rollback boundaries;
- how the result will be verified.

Do not generate alternatives for ceremony. Explore two or three materially
different designs only when several are viable and the trade-off matters.

## Plan as hypothesis

State assumptions and the evidence that would invalidate the design. For a
large change, implement one representative vertical slice before committing to
the remaining structure. Redesign when reality repeatedly fights the plan.

## Output

Return:

1. context and constraints;
2. recommended design;
3. alternatives considered when relevant;
4. interface and data-shape decisions;
5. implementation slices and dependencies;
6. verification and rollback;
7. open product decisions.

Avoid universal line, file, test-count, and coverage quotas. Project rules win.
