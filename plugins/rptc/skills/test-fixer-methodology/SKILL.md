---
name: test-fixer-methodology
description: Apply an approved production, test, or harness correction after expected behavior has been established by the RPTC test-impact analysis. Never weaken tests merely to match current production.
---

# Test Impact Fixer Methodology

Read `RPTC plugin root/shared/workflows/test-impact.md`.

## Required input

Do not edit until the parent supplies:

- the observable behavior;
- the behavioral authority;
- the classification;
- the approved target;
- affected files;
- the failing command or reproduction.

If any item is missing, return `INCONCLUSIVE` to the parent.

## Allowed corrections

### Stale or incorrect test

Update only the assertions, setup, or names contradicted by the established
behavior. Preserve unrelated passing coverage.

### Missing regression protection

Use `rptc:tdd-agent-methodology`. Add one focused failing test or executable
check, confirm the intended failure, then make it pass if production also needs
an approved correction.

### Production defect

Apply only after explicit approval of the product behavior change. Preserve the
valid test signal.

### Harness gap

Make the smallest harness change that enables a real behavior check. Do not add
a broad new framework without approval.

### Orphaned test

Delete or reconnect it only when the owning behavior and replacement protection
are clear.

## Prohibitions

- No production-as-truth fallback.
- No assertion weakening after a rejected production change.
- No universal coverage target.
- No retry loop that changes expectations until tests pass.
- No edits outside the approved target.

## Evidence

Run the failing-before check when available and the passing-after check. Report
the diff, commands, observed results, and anything still inconclusive.
