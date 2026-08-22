# Test-impact workflow contract

## Purpose

Audit how a behavior change affects tests. Do not assume that either current
implementation or an existing test is automatically correct.

## Behavioral authority

Resolve expected behavior in this order:

1. explicit requirements or acceptance criteria;
2. a public contract, protocol, schema, standard, or API guarantee;
3. previously verified external behavior or a captured reproduction;
4. existing tests, treated as evidence;
5. current implementation, treated as an observation of current behavior.

When no independent source resolves a disagreement, classify it as
`INCONCLUSIVE: expected behavior is not established`.

## Procedure

1. Identify externally observable behavior changed by the diff or target path.
2. Locate tests and verification harnesses that claim to protect that behavior.
3. Run the narrowest relevant checks.
4. Compare failures against the behavioral authority above.
5. Classify each item as:
   - implementation defect;
   - stale or incorrect test;
   - missing regression protection;
   - orphaned test;
   - testability or harness gap;
   - inconclusive contract.
6. Propose the smallest correction and cite its authority.
7. Require user approval for changes to product behavior or public contracts.
8. Apply test-only corrections automatically only when the authority is clear
   and the edit does not weaken valid assertions.
9. Rerun the affected check and report evidence.

## Prohibitions

- Do not update an assertion merely because implementation returns a different
  value.
- Do not convert a rejected implementation fix into a test rewrite.
- Do not use coverage percentage alone to decide whether a behavior is protected.
- Do not infer test relationships only from matching filenames.
