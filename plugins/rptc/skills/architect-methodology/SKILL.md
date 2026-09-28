---
name: architect-methodology
description: Plan a design when interfaces, data shapes, ownership, sequencing, or migration are genuinely uncertain, including high-risk work. Skip changes that follow an established pattern, even across several files.
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
large change, name the representative vertical slice to implement first and the
signals from it that should trigger a redesign before the remaining structure
is built.

## Output

Return:

1. context and constraints;
2. recommended design;
3. alternatives considered when relevant;
4. interface and data-shape decisions;
5. implementation slices and dependencies, representative slice first;
6. verification; rollback when high-risk or hard to reverse;
7. assumptions and invalidation signals;
8. open product decisions.

Avoid universal line, file, test-count, and coverage quotas. Project rules win.
