---
description: Audit changed behavior against tests and independent contracts without assuming implementation or tests are automatically correct
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion
---

# /rptc:test-impact

Shared contract: `shared/workflows/test-impact.md`

## Arguments

- no argument: analyze changed implementation and test files;
- path: analyze behavior under the named path;
- `--dry-run`: report only.

## 1. Initialize

Load:

```text
Skill("rptc:core-principles")
Skill("rptc:test-impact-methodology")
Skill("rptc:verification-evidence")
```

Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/test-impact.md`.

Create tasks for authority, analysis, decisions, corrections, and verification.

## 2. Establish behavioral authority

Collect, in order:

1. explicit requirements or acceptance criteria;
2. public contracts, schemas, standards, or API guarantees;
3. previously verified external behavior or a reproduction;
4. existing tests;
5. current implementation.

Do not proceed from the assumption that either current implementation or tests
are correct.

## 3. Analyze

Apply `rptc:test-impact-methodology` directly.

For each changed behavior:

- trace the affected entry point and consumers;
- locate relevant tests and runtime harnesses;
- run the narrowest relevant check;
- classify the result;
- cite the authority and evidence for the classification.

Use report-only `Task` agents only for bounded independent investigations, such
as a contract lookup or a separate package inventory. The parent owns the
behavioral authority, classification, and final judgment.

## 4. Decide and correct

For `--dry-run`, stop after the report.

Test-only corrections may proceed when expected behavior is established and the
edit preserves valid assertions.

Ask the user before:

- changing product behavior;
- changing a public contract;
- choosing between reasonable but conflicting expectations;
- adding a broad new test harness.

Apply the smallest correction in the parent session or delegate one bounded
write with exclusive ownership. Inspect the actual diff afterward.

## 5. Verify

Rerun each affected check and report failing-before and passing-after evidence.
Run nearby project-declared checks when the change can affect them.

Classify unresolved behavior as `INCONCLUSIVE`; do not force convergence.

## 6. Report

List behavior, authority, classification, correction, evidence, and remaining
gaps. Project-defined coverage policy applies; RPTC supplies no universal
percentage.
