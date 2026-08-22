---
description: Fix accepted verification findings and recheck affected evidence until claims are resolved or explicitly open
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion
---

# /rptc:verify-loop

Shared contract: `shared/workflows/verification.md`

This command remains for compatibility. Its target is resolved evidence, not an
empty stochastic reviewer report.

## Arguments

Same scope rules as `/rptc:verify`.

## Loop

1. Run one `/rptc:verify` pass.
2. Separate confirmed findings from context-needed or inconclusive items.
3. Present consequential fixes for approval.
4. Apply accepted fixes:
   - mechanical corrections may proceed when the user authorized fixing;
   - architecture, public contract, security behavior, and broad refactoring
     require an explicit decision.
5. Rerun:
   - checks affected by the fix;
   - original acceptance predicates;
   - only the review axes that produced confirmed findings.
6. Stop when every material claim is:
   - `VERIFIED`;
   - `NOT VERIFIED`;
   - `INCONCLUSIVE`;
   - or explicitly accepted as open.

## Safety

Default to five iterations. Stop earlier when:

- the same evidence-backed finding returns after a materially different fix;
- the required environment is unavailable;
- fixes would exceed the approved scope;
- the next step requires product judgment;
- no accepted fix changed the evidence.

Do not treat an agent failure as zero findings. Do not suppress a declined
finding from the final report.

## Report

Include iterations, fixes, evidence changes, remaining open items, and the final
status of every acceptance predicate.
