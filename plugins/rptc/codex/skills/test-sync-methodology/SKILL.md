---
name: test-sync-methodology
description: Analyze how changed behavior relates to tests and verification harnesses. Classify production defects, stale tests, missing protection, orphaned tests, harness gaps, and unresolved contracts without treating either production or tests as automatic truth.
---

# Test Impact Analysis Methodology

Read `RPTC plugin root/shared/workflows/test-impact.md`.

## Scope

Default to changed files. Accept an explicit path. Identify behavior, not merely
same-stem file pairs.

## Discovery

1. Read project test commands and conventions.
2. Identify changed production behavior from the diff and callers.
3. Find relevant tests through imports, public seams, behavior names, routes,
   commands, schemas, and existing harnesses.
4. Run the narrowest relevant checks.
5. Record available runtime and integration tools.

Filename similarity is one clue, not a proof of coverage.

## Behavioral authority

For each disagreement, locate the highest available authority:

1. requirement or acceptance criterion;
2. public contract, schema, protocol, standard, or API guarantee;
3. previously verified external behavior or reproduction;
4. existing test;
5. current implementation.

## Classification

Use exactly one primary classification:

- `production_defect`;
- `stale_or_incorrect_test`;
- `missing_regression_protection`;
- `orphaned_test`;
- `testability_or_harness_gap`;
- `inconclusive_contract`.

## Finding contract

Every finding includes:

- observable behavior;
- production location;
- related tests or harness;
- failing command and result when available;
- behavioral authority and citation;
- classification;
- recommended target: `production`, `test`, `harness`, or `decision`;
- smallest correction;
- approval requirement.

Do not assign point-based pairing or intent scores.

## Output

Return structured findings and a summary. Do not edit files.
