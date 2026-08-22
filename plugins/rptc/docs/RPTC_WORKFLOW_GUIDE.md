# RPTC workflow guide

## Feature work

The feature flow first classifies the task.

### Local route

Use for a localized, reversible change following a known pattern.

```text
ground -> change -> focused check -> inspect diff
```

### Normal route

Use for changed behavior or moderate uncertainty.

```text
ground
-> acceptance predicates and evidence
-> design only where uncertain
-> vertical implementation
-> project checks
-> selected review
-> evidence summary
```

### High-risk route

Add blast-radius analysis, rollback, a baseline or harness, staged verification,
and independent final review.

## Bug fixes

```text
reproduce the user's symptom
-> make the loop fast and deterministic
-> minimize when useful
-> form falsifiable mechanisms
-> instrument one variable at a time
-> confirm the cause
-> apply the smallest supported fix
-> add practical regression protection
-> rerun the original surface
```

No root-cause claim is complete without reproduction evidence or an explicit
`INCONCLUSIVE` result.

## Vertical TDD

RPTC uses:

```text
one failing behavior
-> minimum passing implementation
-> next failing behavior
-> minimum passing implementation
-> refactor while green
```

Project testing conventions and meaningful seams matter more than test quotas or
universal coverage percentages.

## Verification

Verification is claim-based. It combines project checks, runtime observations,
and selected review axes.

Statuses:

- `VERIFIED`;
- `NOT VERIFIED`;
- `INCONCLUSIVE`.

`verify-loop` rechecks evidence after accepted fixes. It does not loop merely to
obtain zero model findings.

## Test impact

`test-impact` compares tests and production against:

1. requirements;
2. public contracts and standards;
3. previously verified behavior;
4. existing tests;
5. current implementation.

Neither production nor tests are automatically correct.

## Shipping

`commit` discovers project checks, inspects the exact diff, presents selected
paths, and stages only approved files. Pushes and pull requests occur only when
explicitly requested.
