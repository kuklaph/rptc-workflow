---
description: Audit concrete codebase structure friction and propose evidence-backed deepening refactors
allowed-tools: Read, Write, Glob, Grep, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion
---

# /rptc:structure

Shared contract: `shared/workflows/structure.md`

## Arguments

- path: audit the named area;
- no path: use recent repository hotspots;
- `.`: audit the full codebase only when explicitly requested.

## Procedure

1. Load `rptc:core-principles` and `rptc:structure-methodology`. Load
   `rptc:unslop-writing-clearly` when the output is substantial prose.
2. Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/structure.md`.
3. Scope the audit before scanning.
4. Use read-only agents for distinct module, dependency, or testability angles
   only when the area is broad.
5. Inspect interfaces, callers, tests, ownership, and change history.
6. Report a small set of evidence-backed candidates with current friction,
   proposed seam, risk, and verification.
7. Recommend one candidate when appropriate.

This command is report-only. Start `/rptc:feat` to implement a selected
refactor.
