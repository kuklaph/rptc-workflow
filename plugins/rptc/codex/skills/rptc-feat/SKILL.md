---
name: rptc-feat
description: Implement a feature with RPTC, scaling research, planning, TDD, delegation, and verification to the change's uncertainty and risk. Use for RPTC feature or refactoring requests.
---

# RPTC Feature

Shared contract: `shared/workflows/feature.md`

This is the Codex adapter. It preserves the shared feature outcome while using
Codex planning, `update_plan`, and parent-orchestrated sub-agents.

## Invocation

Use for requests such as:

- `Use RPTC to implement "<feature>".`
- `Use rptc:rptc-feat for this change.`

Codex does not expose Claude's persistent `/rptc:feat-team` command. For
parallel work, the parent session coordinates `spawn_agent` workers with
exclusive ownership and waits for them.

## 1. Initialize

Load:

```text
rptc:core-principles
rptc:unslop-writing-clearly
rptc:verification-evidence
```

Load conditionally:

```text
rptc:brainstorming          unresolved product or preference decisions
rptc:architect-methodology  uncertain interfaces, data shapes, ownership, or sequencing
rptc:tdd-methodology        changed behavior with a practical test seam
rptc:frontend-design        user-facing frontend work
```

Read `RPTC plugin root/shared/workflows/feature.md`.

Read project `AGENTS.md`, repository contribution guidance, task-runner files,
and project SOPs. Project and Codex global guidance override RPTC defaults.

Initialize `update_plan` with these top-level phases and keep them visible:

1. Ground and classify.
2. Define acceptance and evidence.
3. Design when needed.
4. Implement verified slices.
5. Verify and summarize.

Codex plans are flat. Prefix implementation and verification child items with
their phase number rather than replacing the top-level phases.

## 2. Ground and classify

Inspect the affected entry points, consumers, tests, project checks, public
contracts, nearby patterns, git status, and branch.

Use repository search, symbol navigation, and runtime tools according to the
evidence needed. No optional navigation service is required.

Classify the route:

- **Local:** established, reversible, narrow, and strongly verifiable.
- **Normal:** behavior or a public seam changes across more than one concern.
- **High risk:** broad, hard to reverse, weakly observable, or sensitive.

State the route and its evidence. Reclassify when new facts change it.

## 3. Define acceptance and evidence

Write observable acceptance predicates. For each, name the strongest feasible
check.

Investigate facts from the repository or runtime. Ask the user only for product
intent, preference, scope, or irreversible trade-offs.

`request_user_input` is a planning-mode tool. Before using it, confirm Codex
Plan Mode is active. If the harness cannot enter Plan Mode at this point, ask
the question in normal chat and stop for the answer rather than simulating a
tool response.

## 4. Design only when needed

Skip formal planning for a local change that follows an established pattern.

For normal or high-risk work:

1. confirm Plan Mode before planning questions;
2. load `rptc:architect-methodology`;
3. produce one recommended design;
4. add alternatives only when materially different structures are viable;
5. cover interface, data shape, ownership, sequencing, verification, and
   rollback where applicable;
6. obtain approval for consequential choices.

The plan remains a hypothesis. Revise it when a representative slice disproves
its assumptions.

## 5. Delegate with Codex mechanics

If a required `rptc:*` custom agent is unavailable, run `rptc:rptc-init` once
and retry. If the environment has no sub-agent tools, the parent executes the
same contract directly.

At each `spawn_agent` point:

1. spawn only bounded agents with an explicit agent type, scope, file ownership,
   and output contract;
2. immediately call `wait_agent` for all required agent IDs;
3. do not research, edit, test, or synthesize in the parent while they run;
4. process results only after all required agents return or fail.

Parallelize independent investigations or artifacts. Keep one writer for every
shared file or branch.

## 6. Implement verified slices

For changed code behavior with a practical seam, load `rptc:tdd-methodology`.

Use one failing behavior followed by the minimum passing implementation. Run
the focused check before advancing to the next slice.

When no practical automated seam exists, establish the closest repeatable
runtime or integration check and state why it is the better signal.

Keep the diff inside scope. Inspect delegated artifacts and the actual diff;
do not trust a worker's completion summary alone.

## 7. Verify

Run project-declared affected checks first. Do not guess test commands or impose
universal coverage numbers.

Select report-only agents by changed properties:

- code review for normal and high-risk code changes;
- security review when trust boundaries or sensitive behavior changed;
- documentation review when public behavior or operational steps changed;
- no agent review for a genuinely mechanical local change with decisive
  evidence, unless requested.

Use the Codex spawn barrier for every selected verification agent. Give each the
exact diff, request or spec, project standards, and evidence.

Fix confirmed findings, rerun affected predicates, and recheck the axis that
raised the finding. Do not loop solely to produce an empty model report.

## 8. Complete

Report the route, delivered behavior, files changed, checks run, reviews, and
each acceptance predicate as `VERIFIED`, `NOT VERIFIED`, or `INCONCLUSIVE`.

Do not commit, push, create a pull request, or deploy unless the user explicitly
requests that action.
