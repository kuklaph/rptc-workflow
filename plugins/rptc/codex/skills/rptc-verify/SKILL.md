---
name: rptc-verify
description: Verify RPTC acceptance claims, changed risks, and repository fit using direct checks and selected report-only agents. Use for an RPTC verification pass on a diff, path, or codebase.
---

# RPTC Verify

Shared contract: `shared/workflows/verification.md`

## 1. Initialize

Load:

```text
rptc:core-principles
rptc:verification-evidence
rptc:unslop-writing-clearly
```

Read `../../../shared/workflows/verification.md` (relative to this SKILL.md).

## 2. Establish scope and claims

Default to staged and unstaged changes. Use a supplied path when present. Verify
the full project only when explicitly requested.

Identify the source request or spec, project standards, declared checks, changed
public behavior, trust boundaries, and documentation impact. State when no
usable specification exists.

When the pass is non-trivial, keep a short task list of verification phases in
your progress updates.

## 3. Run direct checks

Discover commands from repository scripts, build files, CI, and contribution
guidance. Run focused checks first. Record what each observation proves.

## 4. Select and run reviewers

A mechanical change with decisive deterministic evidence may need no model
review unless the user requests one.

Select report-only agents by changed properties:

- `rptc:code-review-agent`;
- `rptc:security-agent`;
- `rptc:docs-agent`.

If the custom agents are missing, run `rptc:rptc-codex-init` once to install the
packaged agents, mention the installation in the final report, and confirm the
agent can be spawned. If it still cannot, report the spawn error and any reload
the user needs instead of reinstalling. If sub-agent tools are unavailable,
perform the review axes in the parent.

For every selected set, spawn in parallel, then keep calling `wait_agent` until
every required agent has returned or failed; one call can return when the first
agent finishes or the wait times out. Do not edit, test, or synthesize in the
parent while they run. Once results are collected, close agents that are no
longer needed with `close_agent` when available; finished agents count toward
the concurrency limit until closed.

## 5. Consolidate

Keep request fidelity, correctness and risk, repository fit, security, and
documentation findings separate.

A finding needs a location plus evidence or a documented rule. Do not use
arbitrary numerical confidence as a gate.

Mark blocking and should-fix findings that affect correctness, the stated
request, security, or a documented rule as requiring action; list optional
findings separately.

Fix them only when the user explicitly asks this pass to fix findings;
otherwise this skill is report-only.

## 6. Report

Classify every material claim as `VERIFIED`, `NOT VERIFIED`, or `INCONCLUSIVE`.
Include exact commands, artifacts, observations, unavailable checks, findings,
and the smallest next action.
