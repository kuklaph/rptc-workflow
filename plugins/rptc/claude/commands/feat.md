---
description: Implement a feature with rigor scaled to uncertainty, risk, and available evidence
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, EnterPlanMode, ExitPlanMode
---

# /rptc:feat

Shared contract: `shared/workflows/feature.md`

Implement new or changed behavior. Claude owns the Claude-specific planning,
task-tracking, and delegation mechanics below. The shared contract owns the
engineering outcome.

## Arguments

`/rptc:feat "<feature description>"`

Use `/rptc:feat-team` only when persistent peer agents and continuous
cross-agent feedback provide a concrete advantage.

## 1. Initialize

Load:

```text
Skill("rptc:core-principles")
Skill("rptc:unslop-writing-clearly")
Skill("rptc:verification-evidence")
```

Load these only when their condition applies:

```text
rptc:brainstorming          unresolved product or preference decisions
rptc:architect-methodology  uncertain interfaces, data shapes, ownership, or sequencing
rptc:tdd-methodology        changed behavior with a practical test seam
rptc:frontend-design        user-facing frontend work
```

Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/feature.md`.

Read project `CLAUDE.md`, repository contribution guidance, task-runner files,
and any project SOPs. Project rules override RPTC defaults.

Create five Claude tasks:

1. Ground and classify.
2. Define acceptance and evidence.
3. Design when needed.
4. Implement verified slices.
5. Verify and summarize.

Use `TaskUpdate` as each phase starts and completes. Do not create child tasks
for trivial actions.

## 2. Ground and classify

Inspect:

- the affected entry points and consumers;
- existing behavior and tests;
- nearby implementation patterns;
- project checks and conventions;
- relevant public contracts;
- current git status and branch.

Use repository search, symbol navigation, and runtime tools according to the
evidence needed. No optional navigation service is required.

Classify the route.

### Local

Use when the change is localized, follows an established pattern, is reversible,
and has a strong focused check.

### Normal

Use when behavior changes across modules, a public seam changes, or the design
has moderate uncertainty.

### High risk

Use when the change is broad, hard to reverse, weakly observable, or touches
authorization, secrets, money, user data, persistence, deployment, or migration.

State the route and why. Reclassify when new evidence changes the risk.

## 3. Define acceptance and evidence

Turn the request into observable predicates. For each predicate name the
strongest feasible evidence:

- focused automated check;
- integration command;
- browser, CLI, or application drive;
- migration dry run;
- trace, screenshot, or artifact comparison;
- independent review.

Investigate discoverable facts. Ask the user only about product intent,
preferences, scope, or irreversible trade-offs.

Use `AskUserQuestion` one decision at a time when a structured choice helps.

## 4. Design only when needed

### Local route

Follow the established pattern. Do not enter Plan Mode solely to restate an
obvious edit.

### Normal or high-risk route

Enter Plan Mode. Load `rptc:architect-methodology`.

Produce one recommended design. Add alternatives only when materially different
structures are viable.

Cover:

- interface and data shape;
- ownership and dependency direction;
- implementation slices;
- verification;
- migration and rollback for high-risk work;
- assumptions that could invalidate the design.

Exit Plan Mode only after the user approves the consequential design choices.

A plan is a hypothesis. If the first representative slice repeatedly fights the
design, stop and revise the plan instead of adding exceptions.

## 5. Choose workspace and delegation

Use the current workspace by default.

Create a sibling worktree when:

- the user requested isolation;
- parallel writers need exclusive ownership;
- the change is high risk and an isolated branch materially improves recovery.

Delegate only bounded work with clear file ownership and a checkable result.
Use parallel `Task` calls for independent investigations or artifacts. Keep one
writer for shared files.

The parent owns design, diff review, evidence, and final judgment. Do not pass a
sub-agent summary through without inspecting its output.

## 6. Implement verified slices

For code behavior with a practical seam, load `rptc:tdd-methodology`.

Use:

```text
one failing behavior
-> minimal passing implementation
-> nearby checks
-> next behavior
```

For work without a practical automated seam, create the closest repeatable
verification before or alongside the change.

Keep the diff inside the approved scope. Remove speculative code, temporary
instrumentation, and unrelated cleanup.

After every independently meaningful slice:

1. run its focused check;
2. inspect the diff;
3. update the task state;
4. continue only from a known-good state.

## 7. Verify

First run the repository's declared affected checks. Do not guess a test runner
or impose a universal coverage target.

Then select independent review by changed properties:

- code review for normal and high-risk code changes;
- security review when trust boundaries or sensitive behavior changed;
- documentation review when public behavior or operational steps changed;
- no agent review for a truly mechanical local change with decisive
  deterministic evidence, unless the user requested it.

Launch selected report-only agents in parallel. Give them the exact diff,
request or spec, project standards, and evidence. Address confirmed findings,
then rerun the affected checks and acceptance predicates.

Do not rerun reviewers merely to obtain zero findings.

## 8. Complete

Report:

- route used and why;
- behavior delivered;
- files changed;
- each acceptance predicate as `VERIFIED`, `NOT VERIFIED`, or `INCONCLUSIVE`;
- exact checks and runtime observations;
- review findings addressed or left open;
- anything deliberately out of scope.

Do not commit, push, create a pull request, or deploy unless the user explicitly
invokes the corresponding action.
