---
description: Audit changed behavior against tests and independent contracts without assuming production or tests are automatically correct
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion
---

# /rptc:test-impact

Shared contract: `shared/workflows/test-impact.md`

## Arguments

- no argument: analyze changed production and test files;
- path: analyze behavior under the named path;
- `--dry-run`: report only.

## 1. Initialize

Load:

```text
Skill("rptc:core-principles")
Skill("rptc:test-sync-methodology")
Skill("rptc:test-fixer-methodology")
Skill("rptc:verification-evidence")
```

Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/test-impact.md`.

## 2. Establish behavioral authority

Collect, in order:

1. explicit requirements or acceptance criteria;
2. public contracts, schemas, standards, or API guarantees;
3. previously verified external behavior or a reproduction;
4. existing tests;
5. current implementation.

Do not proceed from the assumption that current production code is correct.

## 3. Analyze

Use `rptc:test-sync-agent` in report-only mode to:

- identify observable changed behavior;
- locate relevant tests and harnesses;
- run the narrowest relevant checks;
- classify production defects, stale tests, missing protection, orphaned tests,
  harness gaps, and inconclusive contracts;
- cite the authority for every recommended correction.

The agent name is retained for compatibility. Its role is test-impact analysis.

## 4. Decide and fix

For `--dry-run`, stop after the report.

Test-only corrections may proceed when the authority is clear and the edit does
not weaken a valid assertion.

Ask the user before:

- changing product behavior;
- changing a public contract;
- choosing between reasonable but conflicting expectations;
- adding a broad new test harness.

Use `rptc:test-fixer-agent` only after the expected behavior and approved target
are explicit.

## 5. Verify

Rerun each affected check and report failing-before and passing-after evidence.
Classify unresolved behavior as `INCONCLUSIVE`; do not force convergence.

## 6. Report

List behavior, authority, classification, correction, evidence, and remaining
gaps. No universal coverage target applies unless the project defines one.
