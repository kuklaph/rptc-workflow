---
name: rptc-fix
description: Reproduce, diagnose, fix, and verify a bug with RPTC. Use for broken, failing, flaky, crashing, or unexpectedly slow behavior whose cause is not proven.
---

# RPTC Fix

Shared contract: `shared/workflows/fix.md`

This is the Codex adapter. It preserves the reproduction-first contract while
using Codex Plan Mode and parent-orchestrated sub-agents.

## 1. Initialize

Load:

```text
rptc:core-principles
rptc:diagnose-methodology
rptc:verification-evidence
```

Load conditionally:

```text
rptc:tdd-methodology        a practical regression-test seam exists
rptc:architect-methodology  interfaces, ownership, or sequencing remain unresolved
rptc:brainstorming          a genuine product decision remains
rptc:unslop-writing-clearly substantial prose, documentation, or user-facing copy
```

Read `../../../shared/workflows/fix.md` (relative to this SKILL.md), project `AGENTS.md`,
repository guidance, and declared checks.

Do not use `update_plan` or create a task list before reproduction establishes
the shape of the work. For a narrow correction, skip the list unless it protects
a real dependency or unfinished item. For broader or high-risk fixes, keep a
short task list of the remaining diagnosis, implementation, and verification
work in your progress updates, marked as items finish.

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
If custom agents are missing, run `rptc:rptc-codex-init` once to install the
packaged agents, mention the installation in the final report, and confirm the
agent can be spawned. If it still cannot, report the spawn error and any reload
the user needs instead of reinstalling. If sub-agent tools are unavailable,
perform the same investigation in the parent.

At every `spawn_agent` point, keep calling `wait_agent` until every required
agent has returned or failed; one call can return when the first agent finishes
or the wait times out. The parent does not edit, test, or synthesize while they
run. Once results are collected, close agents that are no longer needed with
`close_agent` when available; finished agents count toward the concurrency limit
until closed.

## 4. Design only when needed

Skip formal planning for a clear localized correction.

Execution breadth alone does not require Plan Mode. Use Codex Plan Mode when interfaces, ownership, sequencing, migration, rollback, or meaningful competing approaches remain unresolved.

Before `request_user_input`, confirm Plan Mode is active. If it cannot be
entered, ask in normal chat and stop for the answer.

Use one recommended design and preserve the shared contract's evidence and
approval boundaries.

When the fix will span many turns, offer a ready-to-paste `/goal <condition>`
as the shared contract's long-running work section describes, stating outcome,
constraints, and verification.

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

Select reviewers by changed properties and unresolved risk rather than always running a general reviewer. Require independent final verification for high-risk fixes. Use security review when a trust boundary changed and documentation review when public or operational behavior changed. Use the spawn barrier for each selected set.

Act on blocking and should-fix findings that affect correctness, the request,
security, or a documented rule; list optional findings without acting on them.
Rerun the affected evidence. Do not loop merely to obtain zero findings.

## 7. Complete

Report the symptom, mechanism, fix, failing-before and passing-after evidence,
adjacent checks, reviews, and each material claim as `VERIFIED`,
`NOT VERIFIED`, or `INCONCLUSIVE`.

No commit, push, pull request, or deployment occurs without explicit user
intent.
