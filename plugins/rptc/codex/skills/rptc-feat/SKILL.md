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

Codex has no persistent peer teams. For parallel work, the parent session
coordinates `spawn_agent` workers with exclusive ownership and waits for them.

## 1. Initialize

Load:

```text
rptc:core-principles
rptc:verification-evidence
```

Load conditionally:

```text
rptc:brainstorming          unresolved product or preference decisions
rptc:architect-methodology  uncertain interfaces, data shapes, ownership, or sequencing
rptc:tdd-methodology        changed behavior with a practical test seam
rptc:frontend-design        new user-facing UI or an explicit redesign or polish request
rptc:unslop-writing-clearly substantial prose, documentation, or user-facing copy
```

Read `../../../shared/workflows/feature.md` (relative to this SKILL.md).

Read project `AGENTS.md`, repository contribution guidance, task-runner files,
and project SOPs. Project and Codex global guidance override RPTC defaults.

Do not initialize the full `update_plan` phase structure before classifying the
work. For a local route, omit `update_plan` when the work is obvious and can be
completed without losing dependencies or unfinished items. For normal and
high-risk routes, track only phases that correspond to real work.

## 2. Ground and classify

Inspect the affected entry points, consumers, tests, project checks, public
contracts, nearby patterns, git status, and branch.

Use repository search, symbol navigation, and runtime tools according to the
evidence needed. No optional navigation service is required.

Classify the route:

- **Local:** established, reversible, narrow, and strongly verifiable.
- **Normal:** behavior changes across concerns or execution has enough moving parts that visible progress tracking protects completion.
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

Execution complexity and decision uncertainty are separate. For normal or
high-risk work, use Plan Mode and load `rptc:architect-methodology` only when
interfaces, data shapes, ownership, sequencing, migration, rollback, or
meaningful alternatives remain unresolved. Obtain approval for consequential
choices, not routine reversible implementation details that follow the agreed
intent and repository conventions.

The plan remains a hypothesis. Revise it when a representative slice disproves
its assumptions.

When the approved work will span many turns, offer a ready-to-paste
`/goal <condition>` built as the shared contract's long-running work section
describes. Codex uses the goal text as both the first prompt and the completion
criteria, so state outcome, constraints, and verification in it.

## 5. Delegate with Codex mechanics

Use the current workspace by default. Create a sibling worktree when the user
requested isolation, parallel writers need exclusive ownership, or the change is
high risk and an isolated branch materially improves recovery.

If a required `rptc:*` custom agent is unavailable, run `rptc:rptc-init` once to
install the packaged agents, mention the installation in the final report, and
retry. If the environment has no sub-agent tools, the parent executes the same
contract directly.

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

- code review when normal or high-risk changes leave meaningful correctness,
  request-fidelity, or repository-fit risk not already settled by decisive evidence;
- security review when trust boundaries or sensitive behavior changed;
- documentation review when public behavior or operational steps changed;
- independent final verification for high-risk work;
- no agent review when it would merely duplicate decisive deterministic
  evidence, unless requested.

Use the Codex spawn barrier for every selected verification agent. Give each the
exact diff, request or spec, project standards, and evidence.

Act on blocking and should-fix findings that affect correctness, the request,
security, or a documented rule; list optional findings without acting on them.
Rerun affected predicates and recheck the axis that raised each finding. Do not
loop solely to produce an empty model report.

## 8. Complete

Report the route, delivered behavior, files changed, checks run, reviews, and
each acceptance predicate as `VERIFIED`, `NOT VERIFIED`, or `INCONCLUSIVE`.

Do not commit, push, create a pull request, or deploy unless the user explicitly
requests that action.
