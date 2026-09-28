---
description: Debug with competing-hypothesis investigators on a Claude agent team, then fix as a single writer
allowed-tools: Bash(git worktree add *), Bash(npm test *), Bash(npm run *), Bash(pnpm test *), Bash(pnpm run *), Bash(yarn test *), Bash(yarn run *), Bash(bun test *), Bash(bun run *), Bash(pytest *), Bash(python -m pytest *), Bash(uv run pytest *), Bash(cargo test *), Bash(cargo build *), Bash(cargo check *), Bash(cargo clippy *), Bash(go test *), Bash(go build *), Bash(go vet *), Bash(dotnet test *), Bash(dotnet build *), Read, Write, Edit, Glob, Grep, Agent, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, EnterPlanMode, ExitPlanMode, SendMessage
---

# /rptc:fix-team

Shared contract: `shared/workflows/fix.md`

Claude-only debugging mode. Several investigators each own one hypothesis and
try to disprove each other's, so the diagnosis does not anchor on the first
plausible explanation. The lead then fixes the bug alone.

## When to use

Use this when the bug reproduces but several plausible mechanisms remain and a
single investigator would likely settle on the first one it explores. For a
clear or localized defect, use `/rptc:fix`.

This mode needs Claude agent teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
in an interactive session. Without them, use `/rptc:fix`.

## 1. Initialize

Load:

```text
Skill("rptc:core-principles")
Skill("rptc:diagnose-methodology")
Skill("rptc:verification-evidence")
```

Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/fix.md` and the project's own
instructions and checks.

## 2. Reproduce

The lead owns the user's original reproduction and the final same-surface
check. Produce one repeatable failing command or interaction before spawning
anyone. If the bug does not reproduce, continue with `/rptc:fix`, whose
reproduction step covers blocked environments; a debate without a failing loop
has nothing to test against.

## 3. Investigate with competing hypotheses

List the plausible mechanisms. Spawn one investigator teammate per mechanism,
up to five. With only one plausible mechanism, use `/rptc:fix` instead.

Teammates load CLAUDE.md, MCP servers, and skills, but not the lead's
conversation, so each spawn prompt has to stand on its own:

- the symptom as the user observed it;
- the exact reproduction command or steps;
- the teammate's hypothesis and the names of the other investigators;
- the evidence standard: executable or runtime evidence, with inference labeled
  as inference;
- the skills to load, such as `rptc:diagnose-methodology` (a teammate does not
  inherit an agent definition's preloaded skills);
- the report shape: verdict (supported, refuted, or inconclusive), evidence
  with commands and output, and what would change the verdict.

Investigators do not edit files. They read code, run the reproduction and other
existing commands, and report. When a hypothesis needs temporary
instrumentation, the investigator describes it and the lead adds, runs, and
removes it, so the shared checkout has one writer.

Have investigators message each other to try to disprove each other's
hypotheses, not only to support their own. A mechanism survives only when it
explains the reproduction with executable or runtime evidence and the others
have been ruled out or shown to be contributing factors.

Claude Code approves teammate plan requests automatically. If a teammate
submits a plan, read it yourself before relying on its conclusions.

## 4. Decide and shut down

The lead decides the mechanism from the evidence, not from which teammate
argued longest. If no mechanism survives, report that as `INCONCLUSIVE`,
say which observation would separate the remaining candidates, and ask the user
how to proceed.

Ask each teammate to shut down once its report is collected, before any
product code changes.

## 5. Fix, verify, review

The lead is the only writer. Continue with `/rptc:fix` from design onward:
design only when needed, implement the supported fix with regression
protection, verify on the same surface, and run the review lanes that test a
distinct unresolved risk.

## 6. Complete

Report the symptom, the hypotheses tested and how each was resolved, the
confirmed mechanism, the fix, failing-before and passing-after evidence,
checks, reviews, and each material claim as `VERIFIED`, `NOT VERIFIED`, or
`INCONCLUSIVE`.

Do not commit, push, create a pull request, or deploy unless the user
explicitly requests it.
