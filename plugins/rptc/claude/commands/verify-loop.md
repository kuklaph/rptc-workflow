---
description: Fix accepted verification findings and recheck affected evidence until claims are resolved or explicitly open
allowed-tools: Bash(npm test *), Bash(npm run *), Bash(pnpm test *), Bash(pnpm run *), Bash(yarn test *), Bash(yarn run *), Bash(bun test *), Bash(bun run *), Bash(pytest *), Bash(python -m pytest *), Bash(uv run pytest *), Bash(cargo test *), Bash(cargo build *), Bash(cargo check *), Bash(cargo clippy *), Bash(go test *), Bash(go build *), Bash(go vet *), Bash(dotnet test *), Bash(dotnet build *), Read, Write, Edit, Glob, Grep, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion
---

# /rptc:verify-loop

Shared contract: `shared/workflows/verification.md`

This command remains for compatibility. Its target is resolved evidence, not an
empty stochastic reviewer report.

## Arguments

Same scope rules as `/rptc:verify`.

## Loop

1. Apply the `/rptc:verify` procedure.
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
6. Stop when every accepted fix has been applied and rechecked, and each
   remaining claim is `VERIFIED`, or `NOT VERIFIED` / `INCONCLUSIVE` with a
   stated reason the loop cannot resolve it (declined, blocked, or awaiting a
   product decision).

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
