# RPTC Workflow Plugin

> Provider-aware engineering workflows for Claude Code and Codex.

**Version**: 4.2.0
**Status**: Beta
**License**: MIT

RPTC preserves one engineering contract across two different agent harnesses.
It does not pretend Claude Code and Codex expose the same planning, task,
delegation, or team features.

## Installation

### Claude Code

```text
/plugin marketplace add https://github.com/kuklaph/rptc-workflow
/plugin install rptc
```

Claude exposes `/rptc:*` slash commands and plugin-declared agents.

### Codex

Install the plugin from this repository, then run `rptc-init` once when custom
agents are not already installed.

Invoke skills through chat, for example:

```text
Use RPTC to implement this feature.
Use RPTC to diagnose and fix this bug.
Run an RPTC verification pass.
```

## Core model

RPTC uses:

- a small shared engineering policy;
- task-specific disciplines;
- risk-scaled workflows;
- provider-specific adapters;
- direct evidence for completion claims.

Plans are hypotheses. Project rules override RPTC defaults. A completion claim
is `VERIFIED`, `NOT VERIFIED`, or `INCONCLUSIVE`.

## Primary flows

| Claude command | Codex skill | Purpose |
|---|---|---|
| `/rptc:feat` | `rptc-feat` | Implement behavior with rigor scaled to uncertainty and risk |
| `/rptc:fix` | `rptc-fix` | Reproduce, diagnose, fix, and verify a defect |
| `/rptc:verify` | `rptc-verify` | Verify claims and changed risks with direct evidence |
| `/rptc:verify-loop` | `rptc-verify-loop` | Fix accepted findings and recheck affected evidence |
| `/rptc:test-impact` | `rptc-test-impact` | Audit changed behavior against tests and independent contracts |
| `/rptc:commit [pr]` | `rptc-commit` | Run project checks, stage selected paths, and perform requested git actions |
| `/rptc:research` | `rptc-research` | Investigate a codebase question or external topic with sourced findings |
| `/rptc:structure` | `rptc-structure` | Audit concrete structure friction and propose evidence-backed refactors |
| `/rptc:config` | `rptc-config` | Add a short "Checks" section with the project's real check commands to `CLAUDE.md` or `AGENTS.md` |
| (not needed) | `rptc-init` | Install the packaged Codex agent TOML files |

## Claude-only flows

`/rptc:fix-team` runs competing read-only investigators that try to disprove
each other's hypotheses, then continues with the `/rptc:fix` steps. It needs
Claude agent teams, which are experimental and enabled with
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. The `rptc:agent-teams` skill covers
other team uses, such as parallel workstreams with separate file owners.

Codex sub-agents report only to the parent, so Codex uses the standard feature
and fix skills with parent-orchestrated `spawn_agent` workers and `wait_agent`
barriers. This is an intentional capability difference, not missing parity.

## Long-running work

When approved `feat` or `fix` work will span many turns, RPTC offers a
ready-to-paste `/goal` condition built from the acceptance predicates and their
checks. You start goal mode; RPTC only drafts the condition.

## Risk-scaled execution

### Local

For localized, reversible work following an established pattern:

```text
ground -> change -> focused check -> inspect diff
```

### Normal

For behavior changes with moderate uncertainty:

```text
ground -> acceptance and evidence -> design if needed
-> vertical implementation -> verify -> review
```

### High risk

For broad, irreversible, sensitive, or weakly observable work, add:

- blast-radius analysis;
- baseline or verification harness;
- rollback or recovery;
- staged implementation;
- independent final verification.

## Provider architecture

Shared contracts live in:

```text
shared/
├── engineering-policy.md
├── provider-adapter-contract.md
└── workflows/
```

Claude mechanics live in `claude/`. Codex mechanics live in `codex/`. The
mapping and intentional asymmetries are declared in `provider-contract.json`.

Run:

```bash
python3 scripts/validate-rptc.py
```

before submitting changes.

## Project configuration

RPTC reads your project's own instructions and task-runner files. `config`
discovers the real check commands (focused tests, full tests, typecheck, lint,
build) and, with your approval, adds a short "Checks" section to `CLAUDE.md`
(Claude) or `AGENTS.md` (Codex) when one is missing. RPTC does not copy its
command catalog into always-loaded project context.

## Evidence

For every material claim, report:

```text
<claim>: <VERIFIED | NOT VERIFIED | INCONCLUSIVE>. <command or artifact> → <observed result>
```

A typecheck proves type consistency. It does not automatically prove runtime
behavior.

## Documentation

- [Plugin architecture](docs/PLUGIN_ARCHITECTURE.md)
- [Workflow guide](docs/RPTC_WORKFLOW_GUIDE.md)
- [Provider adapters](docs/PROVIDER_ADAPTERS.md)
- [Project configuration](docs/PROJECT_TEMPLATE.md)
