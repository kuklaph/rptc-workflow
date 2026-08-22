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

Read `RPTC plugin root/shared/workflows/verification.md`.

## 2. Establish scope and claims

Default to staged and unstaged changes. Use a supplied path when present. Verify
the full project only when explicitly requested.

Identify the source request or spec, project standards, declared checks, changed
public behavior, trust boundaries, and documentation impact. State when no
usable specification exists.

Keep verification phases in `update_plan` when the pass is non-trivial.

## 3. Run direct checks

Discover commands from repository scripts, build files, CI, and contribution
guidance. Run focused checks first. Record what each observation proves.

## 4. Select and run reviewers

Select report-only agents by changed properties:

- `rptc:code-review-agent`;
- `rptc:security-agent`;
- `rptc:docs-agent`.

If custom agents are missing, run `rptc:rptc-init` once. If sub-agent tools are
unavailable, perform the review axes in the parent.

For every selected set, spawn in parallel and immediately call `wait_agent` for
all required IDs. Do not edit, test, or synthesize in the parent while they run.

## 5. Consolidate

Keep request fidelity, correctness and risk, repository fit, security, and
documentation findings separate.

A finding needs a location plus evidence or a documented rule. Do not use
arbitrary numerical confidence as a gate.

This skill is report-only unless the user explicitly asks it to fix findings.

## 6. Report

Classify every material claim as `VERIFIED`, `NOT VERIFIED`, or `INCONCLUSIVE`.
Include exact commands, artifacts, observations, unavailable checks, findings,
and the smallest next action.
