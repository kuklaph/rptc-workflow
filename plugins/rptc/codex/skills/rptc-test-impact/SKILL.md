---
name: rptc-test-impact
description: Audit changed behavior against tests and independent contracts without assuming implementation or tests are automatically correct. Use for failing assertions after behavior changes, missing regression protection, orphaned tests, and unclear test ownership.
---

# RPTC Test Impact

Shared contract: `shared/workflows/test-impact.md`

This is the Codex adapter. It uses optional parent-orchestrated read-only
investigations while preserving the shared behavioral-authority contract.

## 1. Initialize

Load:

```text
rptc:core-principles
rptc:test-impact-methodology
rptc:verification-evidence
```

Read `../../../shared/workflows/test-impact.md` (relative to this SKILL.md).

Default to changed files. Accept a path or dry-run request.

When several behaviors or packages are in scope, keep a short task list of these
phases in your progress updates, marked as items finish:

1. Establish behavioral authority.
2. Analyze affected behavior and tests.
3. Resolve decisions.
4. Apply approved corrections.
5. Verify and report.

## 2. Establish authority

Apply the shared contract's behavioral-authority order.

Do not make either implementation or tests the automatic source of truth.

## 3. Analyze

Apply `rptc:test-impact-methodology` directly.

For each changed behavior, trace consumers, locate tests and harnesses, run the
narrowest relevant check, classify the result, and cite its authority.

Use `spawn_agent` only for bounded independent read-only investigations. At
every spawn, keep calling `wait_agent` until every required agent has returned
or failed; one call can return when the first agent finishes or the wait times
out. The parent does not edit, test, or synthesize while those agents run. Once
results are collected, close agents that are no longer needed with `close_agent`
when available; finished agents count toward the concurrency limit until closed.
The parent owns the final classification.

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
failing-before and passing-after evidence where applicable. List every test
edit applied automatically.

Unresolved expectations remain `INCONCLUSIVE`. Project-defined coverage policy
applies; RPTC supplies no universal percentage.
