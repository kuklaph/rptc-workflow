---
name: test-impact-methodology
description: Audit how changed behavior affects tests using requirements, public contracts, prior verified behavior, tests, and current implementation as ordered evidence. Use for failing assertions after behavior changes, missing regression protection, orphaned tests, and unclear test ownership.
---

# Test Impact Methodology

## Outcome

Produce behavior-by-behavior classifications and evidence-backed corrections
without assuming that either tests or implementation are automatically right.

## Establish behavioral authority

Use this order:

1. explicit requirements or acceptance criteria;
2. public APIs, schemas, protocols, standards, or documented guarantees;
3. previously verified external behavior or a captured reproduction;
4. existing tests, treated as evidence;
5. current implementation, treated as an observation.

When those sources do not establish one expectation, return
`INCONCLUSIVE: expected behavior is not established`.

## Analyze

For each observable changed behavior:

1. identify the affected entry point and consumers;
2. locate tests and runtime harnesses that claim to protect it;
3. run the narrowest relevant check;
4. compare the result against the authority above;
5. classify it as:
   - implementation defect;
   - stale or incorrect test;
   - missing regression protection;
   - orphaned test;
   - testability or harness gap;
   - inconclusive contract;
6. cite the authority and evidence for the classification.

Do not infer a relationship from matching filenames alone. Follow imports,
calls, public seams, test names, fixtures, and runtime paths.

## Correct

A dry run makes no edits.

Test-only corrections may proceed when expected behavior is established and the
edit preserves or strengthens valid assertions.

Ask the user before:

- changing product behavior;
- changing a public contract;
- choosing between reasonable conflicting expectations;
- adding a broad new test harness.

Prefer protection through a stable public seam. Keep the correction limited to
the behavior under review.

## Verify

Show failing-before and passing-after evidence when a correction addresses a
failure. Rerun the affected check and any nearby project-declared checks.

Report unresolved expectations as `INCONCLUSIVE`. Do not force a pass through a
weaker assertion or a coverage percentage.

## Prohibitions

- Do not update an assertion merely because implementation returns a different
  value.
- Do not convert a rejected implementation fix into a test rewrite.
- Do not use coverage percentage alone to claim that behavior is protected.
- Do not make current implementation the default source of expected behavior.
