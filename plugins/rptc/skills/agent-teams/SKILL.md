---
name: agent-teams
description: Claude-only orchestration for several independent substantial workstreams or a deliberate multi-perspective debate. Use explicitly when work can be divided into exclusive ownership or independent artifacts.
---

# RPTC Agent Teams

Claude exposes persistent teams and peer messaging. Codex does not; Codex uses
parent-orchestrated sub-agents through its feature and fix adapters.

## Use teams when

- the user requested a team;
- several workstreams produce independent artifacts;
- file ownership can be made exclusive;
- active debate between perspectives adds material value.

Do not use a team merely because a task is large. One coherent feature with
shared files usually needs one implementation owner plus bounded research or
review agents.

## Before spawning

1. State the shared done predicate.
2. Divide work by outcome, not arbitrary file count.
3. Give every writable path exactly one owner.
4. Keep shared integration files with the Team Lead or one named owner.
5. Define what each teammate returns and how it is verified.
6. Identify decisions that still require the user.

If exclusive ownership cannot be drawn, use one writer and parallel read-only
support.

## Team modes

### Independent streams

Each teammate owns a separate outcome and branch or worktree. The Team Lead
integrates and verifies the combined result.

### Shared design, separate implementation

The Team Lead settles contracts and acceptance first. Teammates implement
independent slices behind those contracts.

### Debate or review

Teammates are read-only specialists exploring competing designs, root-cause
mechanisms, or risk perspectives. The Team Lead decides.

## Coordination

- Only the Team Lead creates the team.
- Teammates do not recursively spawn teams.
- Product and irreversible decisions go through the Team Lead.
- The Team Lead inspects artifacts rather than trusting completion summaries.
- Final integration checks run from the lead session.
- Shut down teammates after their reports are collected.

Use the applicable shared feature, fix, and verification contracts for the work
inside the team.
