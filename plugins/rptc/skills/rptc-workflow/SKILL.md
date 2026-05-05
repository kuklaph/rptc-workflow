---
name: rptc-workflow
description: Use when the user asks Codex to run RPTC, Research -> Plan -> TDD -> Commit, /rptc:feat, /rptc:fix, /rptc:research, /rptc:verify, /rptc:commit, /rptc:structure, or /rptc:sync-prod-to-tests. Provides the Codex-native adapter for the original Claude Code RPTC workflow.
---

# RPTC Workflow for Codex

RPTC is a provider-agnostic Research -> Plan -> TDD -> Commit workflow. This skill is the Codex adapter. The Claude adapter lives in `claude/commands/` and `claude/agents/`; Codex role-definition references live in `agents/`; shared methodology lives in `skills/`, `sop/`, and `templates/`.

Execute the workflow in the main Codex context by default. Use Codex `spawn_agent` only when the user explicitly asks for delegation, parallel agents, or subagents. When delegation is approved, prefer the RPTC Codex agent roles from `agents/` when available; otherwise use Codex built-in `explorer` for read-only discovery/review and `worker` for scoped implementation.

## Start Here

Load these RPTC skills before executing a feature or fix workflow:

- `rptc:core-principles`
- `rptc:tool-guide`
- `rptc:brainstorming`
- `rptc:writing-clearly-and-concisely`
- `rptc:tdd-methodology`
- `rptc:structure-methodology`

For frontend work, also load `rptc:frontend-design`.

If Serena is available, activate it and prefer Serena tools for project files. If it is unavailable, use Codex-native file search and shell commands.

## Provider Mapping

Use Codex-native primitives in place of Claude-only tools:

| RPTC concept | Claude adapter | Codex adapter |
| --- | --- | --- |
| Plan mode | `EnterPlanMode` / `ExitPlanMode` | concise plan in chat, `update_plan` for task tracking |
| Structured questions | `AskUserQuestion` | direct question; `request_user_input` only when available |
| Task tracking | `TaskCreate` / `TaskUpdate` | `update_plan` |
| Subagents | `Task` with `subagent_type` | RPTC Codex agent roles or built-in `explorer`/`worker` via `spawn_agent`, only when user explicitly permits delegation |
| Team messaging | `TeamCreate` / `SendMessage` | no Codex adapter; coordinate through the parent session and do not assume team inbox semantics |
| Project memory | `CLAUDE.md` | `AGENTS.md` and available memory tools |
| Plugin root | `${CLAUDE_PLUGIN_ROOT}` | skill-relative references; inspect installed plugin paths when needed |
| User global SOPs | `~/.claude/global/sop/` | project `sop/`, `AGENTS.md`, and plugin `sop/` fallback |

Never call Claude-only tools from Codex.

## Codex Agent Roles

Codex role-definition references are provided under `agents/` for parity with Claude's `claude/agents/` roles:

| Role | Use |
| --- | --- |
| `research-agent` | Delegated codebase, web, or hybrid research |
| `architect-agent` | Delegated implementation planning |
| `tdd-agent` | Delegated scoped TDD implementation |
| `code-review-agent` | Report-only code review |
| `security-agent` | Report-only security review |
| `docs-agent` | Report-only documentation review |
| `review-agent` | Unified report-only reviewer for team-style workflows |
| `test-sync-agent` | Test-production sync analysis |
| `test-fixer-agent` | Approved test repair |

Do not assume these agents are loaded in every Codex environment. If an RPTC role is unavailable, use the closest built-in Codex role and include the relevant RPTC methodology skill names in the spawn prompt.

## Command Intents

Users may still phrase requests with Claude slash commands. Interpret them as these Codex workflows:

| User intent | Codex workflow |
| --- | --- |
| `/rptc:feat "..."` | Discovery -> Architecture -> Implementation -> Quality Verification -> Complete |
| `/rptc:feat-team "..."` | Team-style feature workflow; ask for explicit delegation permission, then use `rptc:agent-teams` if approved |
| `/rptc:fix "..."` | Reproduce -> Root Cause -> Regression Test -> Fix -> Verification -> Complete |
| `/rptc:fix-team "..."` | Team-style fix workflow; ask for explicit delegation permission, then use `rptc:agent-teams` if approved |
| `/rptc:research "..."` | Codebase, web, or hybrid research using `rptc:research-methodology` |
| `/rptc:verify [path]` | Report-only quality verification using code, security, and docs checks |
| `/rptc:verify-loop [path]` | Repeat verification and fixes until no actionable findings remain |
| `/rptc:commit [pr]` | Verify worktree, summarize diff, propose commit/PR actions; never commit without approval |
| `/rptc:structure [path]` | Structure assessment using `rptc:structure-methodology` |
| `/rptc:sync-prod-to-tests "[dir]"` | Test/production sync analysis and repair workflow |

## Feature Workflow

1. Discovery -> verify: identify relevant files, existing tests, patterns, risks.
2. Architecture -> verify: present minimal plan and get user approval before code edits when plan changes are material.
3. Implementation -> verify: use TDD for production code; keep tests synchronized.
4. Quality verification -> verify: run code review, security, and docs checks in report-only mode in the main context unless the user explicitly approved parallel agents.
5. Complete -> verify: summarize changed files, tests run, and remaining risks.

## Fix Workflow

1. Reproduction -> verify: create or identify a failing regression test where possible.
2. Root cause -> verify: explain the actual failure path from evidence.
3. Fix -> verify: make the smallest production change that passes the regression test.
4. Quality verification -> verify: rerun focused tests and relevant review checks.
5. Complete -> verify: report root cause, fix, tests, and any residual risk.

## Verification Rules

- Search for complementary tests before changing production code.
- Do not commit automatically.
- Use provider-neutral wording in new shared methodology. Put Claude-only or Codex-only instructions in adapter files.
- Keep edits surgical. Do not refactor adjacent content unless it is required for the requested workflow.
