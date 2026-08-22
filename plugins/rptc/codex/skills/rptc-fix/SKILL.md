---
name: rptc-fix
description: Reproduce, diagnose, fix, and verify a bug with RPTC. Use for broken, failing, flaky, crashing, or unexpectedly slow behavior whose cause is not proven.
---

# RPTC Fix

Shared contract: `shared/workflows/fix.md`

This is the Codex adapter. It preserves the reproduction-first contract while
using `update_plan`, Codex Plan Mode, and parent-orchestrated sub-agents.

## 1. Initialize

Load:

```text
rptc:core-principles
rptc:diagnose-methodology
rptc:unslop-writing-clearly
rptc:verification-evidence
```

Load conditionally:

```text
rptc:tdd-methodology        a practical regression-test seam exists
rptc:architect-methodology  the fix changes interfaces or crosses modules
rptc:brainstorming          a genuine product decision remains
rptc:frontend-design        user-facing frontend behavior is affected
```

Read `RPTC plugin root/shared/workflows/fix.md`, project `AGENTS.md`,
repository guidance, and declared checks.

Keep these phases visible in `update_plan`:

1. Reproduce.
2. Diagnose.
3. Design if needed.
4. Fix and protect.
5. Verify and summarize.

Prefix child items with their phase number. Do not replace the phase structure
with a flat list of edits.

## 2. Reproduce

Drive the user's actual symptom on the closest available surface. Produce one
repeatable failing command or controlled interaction.

Make the loop fast and deterministic. Minimize it when that reduces the search
space.

If the environment cannot reproduce the bug, identify the exact missing access,
state, device, or condition. Do not promote a theory into a confirmed cause.

## 3. Diagnose

Use `rptc:diagnose-methodology`.

Form falsifiable mechanisms only after the loop is trustworthy. Instrument or
change one variable at a time. Confirm the surviving mechanism with executable
or runtime evidence.

For distinct read-only investigations, use `rptc:research-agent` when available.
If custom agents are missing, run `rptc:rptc-init` once. If sub-agent tools are
unavailable, perform the same investigation in the parent.

At every `spawn_agent` point, immediately call `wait_agent` for all required
agent IDs. The parent does not edit, test, or synthesize while they run.

## 4. Design only when needed

Skip formal planning for a clear localized correction.

Use Codex Plan Mode when the fix changes interfaces, crosses several modules,
requires migration or rollback, or has meaningful competing approaches.

Before `request_user_input`, confirm Plan Mode is active. If it cannot be
entered, ask in normal chat and stop for the answer.

Use one recommended design and preserve the shared contract's evidence and
approval boundaries.

## 5. Fix and protect

When a practical regression seam exists, load `rptc:tdd-methodology` and
demonstrate failing-before behavior.

Apply the smallest coherent change supported by the diagnosis. Remove
speculative changes and temporary instrumentation.

Delegate bounded writes only with exclusive ownership. Use the Codex spawn
barrier. Inspect the actual files and diff after the worker returns.

## 6. Verify

Rerun:

1. the minimized reproduction;
2. the original reproduction on the same surface;
3. repository-declared affected checks;
4. selected independent review.

Select code, security, and documentation reviewers by changed properties rather
than always running all reviewers. Use the spawn barrier for each selected set.

Address confirmed findings and rerun the affected evidence. Do not loop merely
to obtain zero findings.

## 7. Complete

Report the symptom, mechanism, fix, failing-before and passing-after evidence,
adjacent checks, reviews, and each material claim as `VERIFIED`,
`NOT VERIFIED`, or `INCONCLUSIVE`.

No commit, push, pull request, or deployment occurs without explicit user
intent.
