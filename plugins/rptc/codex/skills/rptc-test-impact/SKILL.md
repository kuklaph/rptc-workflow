---
name: rptc-test-impact
description: Audit changed behavior against tests and independent contracts without assuming implementation or tests are automatically correct. Use for failing assertions after behavior changes, missing regression protection, orphaned tests, and unclear test ownership.
---

# RPTC Test Impact

Shared contract: `shared/workflows/test-impact.md`

This is the Codex adapter. It uses `update_plan` and optional
parent-orchestrated read-only investigations while preserving the shared
behavioral-authority contract.

## 1. Initialize

Load:

```text
rptc:core-principles
rptc:test-impact-methodology
rptc:verification-evidence
```

Read `RPTC plugin root/shared/workflows/test-impact.md`.

Default to changed files. Accept a path or dry-run request.

Keep these phases visible in `update_plan`:

1. Establish behavioral authority.
2. Analyze affected behavior and tests.
3. Resolve decisions.
4. Apply approved corrections.
5. Verify and report.

## 2. Establish authority

Collect requirements, public contracts, prior verified behavior, existing
tests, and current implementation in that order.

Do not make either implementation or tests the automatic source of truth.

## 3. Analyze

Apply `rptc:test-impact-methodology` directly.

For each changed behavior, trace consumers, locate tests and harnesses, run the
narrowest relevant check, classify the result, and cite its authority.

Use `spawn_agent` only for bounded independent read-only investigations. At
every spawn, immediately call `wait_agent` for all required IDs. The parent does
not edit, test, or synthesize while those agents run. The parent owns the final
classification.

## 4. Decide and correct

Dry-run stops after analysis.

Apply test-only corrections only when expected behavior is established and the
edit preserves valid assertions.

Product behavior, public contracts, ambiguous expectations, and broad harness
work require user approval. `request_user_input` requires Plan Mode; otherwise
ask in normal chat and stop for the answer.

Apply the smallest approved correction. Delegate a write only with exclusive
ownership, then inspect the actual diff.

## 5. Verify and report

Rerun affected checks and nearby project-declared checks. Report
failing-before and passing-after evidence where applicable.

Unresolved expectations remain `INCONCLUSIVE`. Project-defined coverage policy
applies; RPTC supplies no universal percentage.
