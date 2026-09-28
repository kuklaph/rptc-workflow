---
description: Implement a feature with rigor scaled to uncertainty, risk, and available evidence
allowed-tools: Bash(git worktree add *), Bash(npm test *), Bash(npm run *), Bash(pnpm test *), Bash(pnpm run *), Bash(yarn test *), Bash(yarn run *), Bash(bun test *), Bash(bun run *), Bash(pytest *), Bash(python -m pytest *), Bash(uv run pytest *), Bash(cargo test *), Bash(cargo build *), Bash(cargo check *), Bash(cargo clippy *), Bash(go test *), Bash(go build *), Bash(go vet *), Bash(dotnet test *), Bash(dotnet build *), Read, Write, Edit, Glob, Grep, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, EnterPlanMode, ExitPlanMode
---

# /rptc:feat

Shared contract: `shared/workflows/feature.md`

Implement new or changed behavior. Claude owns the Claude-specific planning,
task-tracking, and delegation mechanics below. The shared contract owns the
engineering outcome.

## Arguments

`/rptc:feat "<feature description>"`

For several independent workstreams with separate file owners, the
`rptc:agent-teams` skill describes when a Claude agent team is worth its cost.

## 1. Initialize

Load:

```text
Skill("rptc:core-principles")
Skill("rptc:verification-evidence")
```

Load these only when their condition applies:

```text
rptc:brainstorming          unresolved product or preference decisions
rptc:architect-methodology  uncertain interfaces, data shapes, ownership, or sequencing
rptc:tdd-methodology        changed behavior with a practical test seam
rptc:frontend-design        new user-facing UI or an explicit redesign or polish request
rptc:unslop-writing-clearly substantial prose, documentation, or user-facing copy
```

Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/feature.md`.

Read project `CLAUDE.md`, repository contribution guidance, task-runner files,
and any project SOPs. Project rules override RPTC defaults.

Do not create a full phase structure before classifying the work. For a local
route, track work only when it protects a real dependency or unfinished item.
For normal and high-risk routes, create only tasks that correspond to real work.
Use `TaskUpdate` to preserve unfinished work and dependencies.

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

Use when behavior changes across concerns or execution has enough moving parts
that visible progress tracking protects completion. Complexity alone does not
imply design uncertainty.

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

Use `AskUserQuestion` when a structured choice helps. Batch independent
decisions; ask dependent ones in sequence.

## 4. Design only when needed

### Local route

Follow the established pattern. Do not enter Plan Mode solely to restate an
obvious edit.

### Normal or high-risk route

Execution complexity and decision uncertainty are separate. Enter Plan Mode and
load `rptc:architect-methodology` only when interfaces, data shapes, ownership,
sequencing, migration, rollback, or meaningful alternatives remain unresolved.

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

When the approved work will span many turns, offer a ready-to-paste
`/goal <condition>` built as the shared contract's long-running work section
describes. Keep it under 4,000 characters and recommend running it in auto mode
for unattended turns. Claude's goal evaluator reads only the transcript and runs
no commands, so print each check's result.

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

- code review when normal or high-risk changes leave meaningful correctness,
  request-fidelity, or repository-fit risk not already settled by decisive evidence;
- security review when trust boundaries or sensitive behavior changed;
- documentation review when public behavior or operational steps changed;
- independent final verification for high-risk work;
- no agent review when it would merely duplicate decisive deterministic
  evidence, unless the user requested it.

Launch selected report-only agents in parallel. Give them the exact diff,
request or spec, project standards, and evidence. Act on blocking and
should-fix findings that affect correctness, the request, security, or a
documented rule; list optional findings without acting on them. Then rerun
evidence affected by the fixes and any acceptance predicates whose state may
have changed.

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
