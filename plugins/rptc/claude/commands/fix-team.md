---
description: Diagnose and fix a difficult bug with a persistent Claude team and continuous root-cause review
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, EnterPlanMode, ExitPlanMode, TeamCreate, SendMessage
---

# /rptc:fix-team

Shared contract: `shared/workflows/fix.md`

Claude-only adapter for a difficult bug whose diagnosis benefits from persistent
research, architecture, implementation, and review peers.

Use `/rptc:fix` for clear or localized defects. Codex uses its standard fix
adapter with parent-orchestrated agents.

## 1. Initialize

Load:

```text
rptc:core-principles
rptc:diagnose-methodology
rptc:unslop-writing-clearly
rptc:verification-evidence
```

Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/fix.md`.

Create one team with:

- `researcher`: read-only reproduction support and code tracing;
- `architect`: read-only mechanism and fix-design guardian;
- `implementer`: the only product-code writer;
- `reviewer`: report-only regression, correctness, security, and docs review.

Create sequential tasks for reproduction, diagnosis, fix design, implementation,
final verification, and wrap-up.

Use an isolated worktree when the fix is high risk or the user requests it.
One implementation writer owns all shared product files.

## 2. Reproduce

The Team Lead owns the user's original reproduction and the final same-surface
check.

The researcher helps trace entry points, history, related failures, and
candidate instrumentation. It returns evidence to the architect and Team Lead.

Do not advance until there is a trustworthy failing loop or a precise
`INCONCLUSIVE` statement describing why the environment cannot reproduce it.

## 3. Diagnose

The architect and researcher apply `rptc:diagnose-methodology`:

1. minimize the loop when useful;
2. form falsifiable mechanisms;
3. choose observations that eliminate the most possibilities;
4. instrument one variable at a time;
5. confirm the surviving mechanism.

The architect proposes the smallest fix supported by the evidence. Use Plan
Mode only when the fix changes interfaces, crosses modules, requires migration
or rollback, or has consequential alternatives.

The user decides product behavior and consequential trade-offs.

## 4. Implement and review

The implementer loads `rptc:tdd-agent-methodology`.

For each fix slice:

1. demonstrate failing-before behavior at a stable seam when practical;
2. apply the minimum coherent production correction;
3. remove speculative attempts and temporary instrumentation;
4. run focused checks;
5. send the actual changed paths and evidence to architect and reviewer;
6. wait for both responses;
7. address confirmed findings.

The architect rejects symptom treatment not supported by the mechanism.
The reviewer evaluates regression protection, correctness, repository fit,
security impact, and documentation impact. Reviewers remain report-only.

## 5. Final verification

Rerun:

- the minimized reproduction;
- the original user reproduction on the same surface;
- repository-declared affected checks;
- complete-diff architecture and review passes.

Do not seek an empty reviewer report. Resolve every material claim as verified,
failed, inconclusive, or explicitly open.

## 6. Wrap up

Shut down team members after collecting reports.

Return the symptom, confirmed mechanism, fix, failing-before and passing-after
evidence, checks, feedback, and unresolved claims.

No commit, push, pull request, or deployment occurs without explicit user
intent.
