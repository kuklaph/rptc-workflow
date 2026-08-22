---
name: rptc-test-impact
description: Audit changed behavior against tests and independent contracts without assuming production or tests are automatically correct. Use for test drift, failing assertions after behavior changes, missing regression protection, and orphaned tests.
---

# RPTC Test Impact

Shared contract: `shared/workflows/test-impact.md`

## 1. Initialize

Load:

```text
rptc:core-principles
rptc:test-sync-methodology
rptc:test-fixer-methodology
rptc:verification-evidence
```

Read `RPTC plugin root/shared/workflows/test-impact.md`.

Default to changed files. Accept a path or dry-run request.

## 2. Establish authority

Collect requirements, public contracts, prior verified behavior, existing
tests, and current implementation in that order.

## 3. Analyze

Use `rptc:test-sync-agent` as a report-only test-impact analyst. If custom
agents are missing, run `rptc:rptc-init` once. If sub-agent tools are
unavailable, apply the same methodology in the parent.

At every spawn, immediately call `wait_agent`. The parent does not edit, test,
or synthesize while the required agent runs.

Classify each item and cite the authority for the proposed target.

## 4. Decide and fix

Dry-run stops after analysis.

Apply test-only corrections only when expected behavior is established and the
edit preserves valid assertions.

Product behavior, public contracts, ambiguous expectations, and broad harness
work require user approval. `request_user_input` requires Plan Mode; otherwise
ask in normal chat and stop for the answer.

Use `rptc:test-fixer-agent` only with an explicit approved target.

## 5. Verify and report

Rerun affected checks. Report failing-before and passing-after evidence.
Unresolved expectations remain `INCONCLUSIVE`. Project-defined coverage policy
applies; RPTC supplies no universal percentage.
