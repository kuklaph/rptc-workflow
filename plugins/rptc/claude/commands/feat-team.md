---
description: Develop a complex feature with a persistent Claude team and continuous cross-agent feedback
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, EnterPlanMode, ExitPlanMode, TeamCreate, SendMessage
---

# /rptc:feat-team

Shared contract: `shared/workflows/feature.md`

Claude-only adapter for one complex feature that benefits from persistent peers.
Codex has no equivalent peer-team inbox and uses the standard feature adapter
with parent-orchestrated agents.

## When to use

Use this flow when:

- the feature is normal or high risk;
- research, architecture, implementation, and review need ongoing exchange;
- one implementation writer can own the shared worktree.

Use `/rptc:feat` for local changes and ordinary features. Use the
`rptc:agent-teams` skill for several independent workstreams.

## 1. Initialize

Load:

```text
rptc:core-principles
rptc:brainstorming
rptc:unslop-writing-clearly
rptc:verification-evidence
```

Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/feature.md`.

Ground the repository enough to state the feature, affected area, route,
acceptance predicates, and verification surfaces.

Ask whether to use the current branch or a sibling worktree. Recommend a
worktree for high-risk work. Only the implementer writes product files, so the
team itself does not justify concurrent shared writes.

## 2. Create the team

Create one team with four persistent roles:

- `researcher`: read-only codebase and external research;
- `architect`: read-only design and plan guardianship;
- `implementer`: the only product-code writer;
- `reviewer`: report-only request, correctness, security, and documentation review.

Create tasks:

1. Discovery.
2. Architecture and acceptance.
3. Implementation.
4. Final verification.
5. Wrap-up.

Block each task on the previous task.

Every spawn prompt includes:

- repo and worktree path;
- feature request;
- role and write scope;
- shared contract path;
- acceptance predicates known so far;
- required report shape;
- instruction to escalate product decisions to the Team Lead.

## 3. Discovery

The researcher traces entry points, consumers, data flow, side effects, tests,
project patterns, and project checks. It reports evidence with file and symbol
locations to the architect and Team Lead.

The researcher stays available for bounded questions. It does not become a
second implementation worker.

## 4. Architecture

The architect uses `rptc:architect-methodology`.

It returns one recommended design. Alternatives appear only when materially
different structures are viable.

The Team Lead enters Plan Mode and presents:

- acceptance predicates;
- route and risk;
- interface and data shape;
- ownership and sequencing;
- verification;
- rollback for high-risk work;
- open product decisions.

The user approves consequential choices. After approval, the architect becomes
a plan guardian. The plan is a hypothesis and may be revised when a
representative slice disproves it.

## 5. Implementation and continuous feedback

The implementer loads `rptc:tdd-agent-methodology`.

For each vertical slice:

1. announce the behavior, seam, and intended files;
2. show the failing executable check when practical;
3. implement the minimum coherent passing change;
4. run focused and nearby checks;
5. send the diff summary and evidence to architect and reviewer;
6. wait for both responses;
7. address confirmed findings before the next slice.

The architect checks plan assumptions, ownership, and integration. The reviewer
keeps these axes separate:

- request fidelity;
- correctness and risk;
- repository fit;
- security impact;
- documentation impact.

Neither reviewer edits product files. Findings require a location plus evidence
or a documented rule. No numerical confidence threshold applies.

## 6. Final verification

After all slices:

1. run project-declared affected checks;
2. rerun all acceptance predicates on the strongest feasible surfaces;
3. have architect and reviewer inspect the complete diff and evidence;
4. address confirmed cross-cutting findings;
5. rerun affected evidence.

Do not repeat reviewers merely to obtain zero findings.

## 7. Wrap up

Shut down team members after collecting their final reports.

Report delivered behavior, files, design changes, feedback addressed, project
checks, and each predicate as `VERIFIED`, `NOT VERIFIED`, or `INCONCLUSIVE`.

Do not commit, push, open a pull request, deploy, or send an external
notification unless explicitly requested.
