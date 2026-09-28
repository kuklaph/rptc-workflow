---
name: agent-teams
description: Claude-only orchestration for several independent substantial workstreams or a deliberate multi-perspective debate. Use explicitly when work can be divided into exclusive ownership or independent artifacts.
---

# RPTC Agent Teams

Claude exposes persistent teams and peer messaging. Codex does not; Codex uses
parent-orchestrated sub-agents through its feature and fix adapters.

Teams are experimental in Claude Code. They require
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` and an interactive session. Without
them, use ordinary sub-agents.

## Use teams when

- the user requested a team;
- several workstreams produce independent artifacts;
- file ownership can be made exclusive;
- active debate between perspectives adds material value.

Do not use a team merely because a task is large. One coherent feature with
shared files usually needs one implementation owner plus bounded research or
review agents.

For debugging with several plausible root causes, use `/rptc:fix-team`.

## Before spawning

1. State the shared done predicate.
2. Divide work by outcome, not arbitrary file count.
3. Give every writable path exactly one owner.
4. Keep shared integration files with the Team Lead or one named owner.
5. Define what each teammate returns and how it is verified.
6. Identify decisions that still require the user.

If exclusive ownership cannot be drawn, use one writer and parallel read-only
support.

## Spawn prompts

Teammates load CLAUDE.md, MCP servers, and skills, but not the lead's
conversation. Each spawn prompt needs everything the teammate would otherwise
have to guess: the goal, relevant paths and commands, the files it owns, the
evidence standard, the report shape, and the skills to load (a teammate does not
inherit an agent definition's preloaded skills).

## Team modes

### Independent streams

Each teammate owns a separate outcome and an exclusive set of files in the
shared checkout. Teammates are not isolated from each other, so ownership is
what prevents overwrites; an Agent call with `isolation` launches a subagent,
not a teammate. The Team Lead integrates and verifies the combined result.

### Shared design, separate implementation

The Team Lead settles contracts and acceptance first. Teammates implement
independent slices behind those contracts.

### Debate or review

Teammates are read-only specialists exploring competing designs, root-cause
mechanisms, or risk perspectives. Have them message each other to try to
disprove each other's findings; a conclusion that survives challenge is more
reliable than one reached alone. The Team Lead decides.

## Coordination

- Only the lead spawns teammates; teammates cannot spawn their own.
- Teammates do not recursively spawn teams.
- Product and irreversible decisions go through the Team Lead.
- Claude Code approves teammate plan requests automatically, so the Team Lead
  reads any teammate plan before relying on it.
- The Team Lead inspects artifacts rather than trusting completion summaries.
- Final integration checks run from the lead session.
- Shut down teammates after their reports are collected.

Use the applicable shared feature, fix, and verification contracts for the work
inside the team.
