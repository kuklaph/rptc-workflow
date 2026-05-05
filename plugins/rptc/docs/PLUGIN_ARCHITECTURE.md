# RPTC Plugin Architecture

> Technical documentation for plugin structure, installation, and internals

---

## Plugin Distribution

RPTC is provider-agnostic at the workflow/methodology layer and provider-specific only at the manifest/adapter layer.

The installable package is `plugins/rptc`. It is self-contained and includes both provider manifests:

- `plugins/rptc/.claude-plugin/plugin.json`
- `plugins/rptc/.codex-plugin/plugin.json`
- `plugins/rptc/agents/`
- `plugins/rptc/claude/commands/`
- `plugins/rptc/claude/agents/`
- `plugins/rptc/skills/`
- `plugins/rptc/sop/`
- `plugins/rptc/templates/`
- `plugins/rptc/docs/`

`plugins/rptc` is the editable source and install package. There is no generated copy and no sync step.

### Claude Distribution

When users install the Claude plugin:

```bash
/plugin marketplace add https://github.com/kuklaph/rptc-workflow
/plugin install rptc
```

Claude's marketplace entry points to `./plugins/rptc`, so users receive that package in Claude's plugin cache. User scope is the default install scope, so the plugin is available across projects.

### Codex Distribution

Codex uses the same package under `plugins/rptc`:

```text
.agents/plugins/marketplace.json
plugins/rptc/.claude-plugin/plugin.json
plugins/rptc/.codex-plugin/plugin.json
plugins/rptc/agents/
plugins/rptc/skills/
plugins/rptc/sop/
plugins/rptc/templates/
```

The Codex marketplace entry points to `./plugins/rptc`. The package keeps Claude-only files under `claude/` and provides Codex role-definition references under the plugin root `agents/`. The `rptc-workflow` skill is the Codex-native entrypoint and maps Claude slash-command intents to Codex-native primitives such as `update_plan`, direct user questions, available skill loading, and `spawn_agent` only when the user explicitly permits delegation.

For global Codex use, place the same package shape at the Codex home level:

```text
~/.agents/plugins/marketplace.json
~/.codex/plugins/rptc/.codex-plugin/plugin.json
```

Point the personal marketplace source path at `./.codex/plugins/rptc`, relative to the marketplace root. In this repository, the Codex marketplace source remains `./plugins/rptc`.

### Repository Structure

```text
rptc-workflow/
├── .claude-plugin/
│   └── marketplace.json            # Claude marketplace listing, source ./plugins/rptc
│
├── .agents/plugins/
│   └── marketplace.json            # Codex marketplace listing, source ./plugins/rptc
│
├── plugins/rptc/                   # Shared install package for Claude and Codex
│   ├── .claude-plugin/plugin.json  # Claude plugin metadata
│   ├── .codex-plugin/plugin.json   # Codex plugin metadata
│   ├── claude/                     # Claude-only plugin surfaces
│   │   ├── commands/               # Claude slash commands
│   │   └── agents/                 # Claude specialist agents
│   ├── agents/                     # Codex role-definition references
│   ├── skills/                     # Shared skills, including Codex adapter
│   ├── sop/                        # SOPs
│   ├── templates/                  # Templates
│   ├── docs/                       # Documentation
│   ├── README.md
│   └── LICENSE
│
├── README.md                       # Repository overview
├── CONTRIBUTING.md                 # Contribution guidelines
├── CHANGELOG.md                    # Version history
└── LICENSE                         # MIT License
```

---

## NOT Distributed

These files are development artifacts:

```text
rptc-workflow/
├── legacy/                         # Development history
├── scripts/                        # Maintainer tools
├── .git/                           # Version control
├── .claude/                        # Local dev settings
└── CLAUDE.md                       # Maintainer documentation
```

---

## Claude Installation Flow

### Step 1: User Installs Plugin

```bash
/plugin marketplace add https://github.com/kuklaph/rptc-workflow
/plugin install rptc
```

**What happens:**

- Claude clones repo to plugin directory
- Claude installs `plugins/rptc` into its plugin cache
- That package becomes `${CLAUDE_PLUGIN_ROOT}`
- All 11 commands registered from `claude/commands`
- Claude agents available for delegation from `claude/agents`
- SOPs available for agent reference

## Codex Installation Flow

Codex uses the same package through the Codex marketplace entry:

```text
.agents/plugins/marketplace.json
plugins/rptc/.codex-plugin/plugin.json
plugins/rptc/skills/
plugins/rptc/agents/
```

**What happens:**

- Codex reads `.agents/plugins/marketplace.json`
- The marketplace points to `./plugins/rptc`
- Codex loads `.codex-plugin/plugin.json`
- The `rptc-workflow` skill becomes the Codex-native entrypoint
- `plugins/rptc/agents/` stays packaged as role-definition references for approved delegation, not as a top-level Codex plugin manifest surface

### Step 2: User Starts Building

Claude slash command:

```bash
/rptc:feat "add user authentication"
```

Codex chat intent:

```text
Use RPTC to implement "add user authentication".
```

**What happens:**

- `/rptc:feat` handles entire workflow
- Phase 1: Discovery (codebase exploration)
- Phase 2: Architecture (provider planning context: Claude `~/.claude/plans/`; Codex `update_plan`/chat approval)
- Phase 3: TDD Implementation
- Phase 4: Quality Verification
- Phase 5: Complete

**No workspace initialization required.** RPTC uses the provider's native planning mechanism.

---

## User Projects (Minimal Footprint)

RPTC requires almost nothing in user projects:

```text
user-project/
├── docs/research/               # Optional: saved research documents
├── CLAUDE.md or AGENTS.md       # Optional: provider project context
└── [your project files]
```

**Plans are stored in:** Claude uses `~/.claude/plans/`; Codex tracks plans in-session with `update_plan` unless the user asks for a project plan file.

**No `.rptc/` directory needed.** No provider settings file is required.

---

## Command Architecture

### The Unified `/rptc:feat` Command

The primary command handles the complete workflow:

```text
/rptc:feat "description"
    ↓
Phase 1: Discovery
    → Explores codebase; Claude may launch 2-3 parallel exploration agents
    → Codex stays in main context unless explicit parallel-agent approval exists
    → Uses rptc:research-agent with code-explorer methodology
    ↓
Branch Strategy
    → Current branch or new git worktree
    ↓
Phase 2: Architecture
    → Enters provider planning context
    → Produces 3 planning perspectives (Minimal, Clean, Pragmatic)
    → Claude may parallelize via agents; Codex stays in main context unless approved
    → User selects approach
    → Plan tracked in provider-native form
    ↓
Phase 3: Implementation
    → Route A (non-code): Main context executes directly
    → Route B (code): TDD with smart batching via rptc:tdd-agent
    ↓
Phase 4: Quality Verification (Report-Only)
    → Run code-review + security + docs roles
    → Claude may use command-defined agents; Codex delegates or parallelizes only with provider policy and explicit user approval
    → Agents report findings only (no auto-fix)
    → Main context handles fixes via provider task tracking
    ↓
Phase 5: Complete
    → Summary of changes
    → Ready for the active provider's RPTC commit workflow
```

### Supporting Commands

| Command | Purpose | Typical Usage |
|---------|---------|---------------|
| `/rptc:research "topic"` | Standalone research | Before `/rptc:feat` for unfamiliar topics |
| `/rptc:commit [pr]` | Verify and ship | After completing implementation |
| `/rptc:verify [path]` | Run verification agents on demand | After any code change |
| `/rptc:verify-loop [path]` | Run verification in a convergence loop until 0 findings | After implementation, when you want a fully clean result |
| `/rptc:feat-team "description"` | Team-based feature development with 4 persistent roles | Complex features needing continuous review |
| `/rptc:fix-team "bug description"` | Team-based bug fixing with 4 persistent roles, root cause guardianship, regression focus | Complex bugs, unclear root cause, cross-cutting regressions |
| `/rptc:structure` | Codebase structure analysis and refactoring | When restructuring or analyzing project layout |
| `/rptc:config` | Configure RPTC in provider project context (`CLAUDE.md`/`AGENTS.md`) | First-time setup, after plugin updates |
| `/rptc:sync-prod-to-tests "[dir]"` | Test maintenance | When tests drift from production |

---

## Agent Delegation Pattern

Claude commands delegate to specialist agents using the Task tool and the Markdown agents in `claude/agents`. Codex uses the `rptc-workflow` skill mapping plus role-definition references in `agents/`; it may use `spawn_agent` only when the user explicitly permits delegation.

Claude Task prompt shape:

```markdown
Use Task tool with subagent_type="rptc:[agent-name]":

## Context
[Feature description, relevant findings]

## Your Task
[Specific work for this agent]

## SOPs to Reference
- ${CLAUDE_PLUGIN_ROOT}/sop/[relevant-sop].md

## Output Required
[Expected deliverable format]
```

Codex delegation uses the same role names conceptually, but prompts should go through Codex `spawn_agent` only after explicit delegation approval and include the role, task, file ownership boundaries, and expected output. Codex standalone custom agents outside a plugin are TOML files in `.codex/agents` or `~/.codex/agents`; this package keeps plugin-local Markdown role-definition references so Claude and Codex can share one install package without duplicating the whole workflow.

### Agent Responsibilities

| Agent | Phase | Purpose | Mode |
|-------|-------|---------|------|
| `rptc:research-agent` | Phase 1 | Codebase exploration, pattern discovery | Active |
| `rptc:architect-agent` | Phase 2 | Implementation planning (3 perspectives) | Active |
| `rptc:tdd-agent` | Phase 3 (code) | RED-GREEN-REFACTOR execution | Active |
| `rptc:code-review-agent` | Phase 4 | Code review, KISS/YAGNI | **Report-only** |
| `rptc:security-agent` | Phase 4 | Security review, OWASP compliance | **Report-only** |
| `rptc:docs-agent` | Phase 4 | Documentation impact review | **Report-only** |
| `rptc:review-agent` | `/feat-team`, `/fix-team` | Unified review (code+security+docs) with real-time feedback | **Report-only** |
| `rptc:test-sync-agent` | `/rptc:sync-prod-to-tests` / Codex sync intent | Analyze test-production relationships | Analysis |
| `rptc:test-fixer-agent` | `/rptc:sync-prod-to-tests` / Codex sync intent | Repair test files through the active provider workflow | Active |

---

## Provider-Aware Execution Architecture

RPTC maximizes efficiency where the provider and approval policy allow
parallelization. Claude command workflows can delegate to specialist agents.
Codex runs the workflow in the main context by default and uses `spawn_agent`
only after explicit delegation or parallel-agent approval.

### Phase 1: Discovery

```text
┌─────────────────────┐
│  Feature Request    │
└─────────┬───────────┘
          │
    ┌─────┴─────┐
    ▼           ▼
┌───────┐   ┌───────┐
│Role 1 │   │Role 2 │   (parallel agents in Claude; main context in Codex unless approved)
│Feature│   │Arch   │
│Disco- │   │Analy- │
│very   │   │sis    │
└───┬───┘   └───┬───┘
    │           │
    └─────┬─────┘
          ▼
   Consolidated Findings
```

### Phase 2: Architecture

```text
┌─────────────────────┐
│  Discovery Results  │
└─────────┬───────────┘
          │
    ┌─────┼─────┐
    ▼     ▼     ▼
┌─────┐ ┌─────┐ ┌─────┐
│Mini-│ │Clean│ │Prag-│  (3 perspectives; parallel agents only when approved)
│mal  │ │     │ │matic│
└──┬──┘ └──┬──┘ └──┬──┘
   │       │       │
   └───────┼───────┘
           ▼
    User Selects One
```

### Phase 4: Quality Verification (Report-Only)

```text
┌─────────────────────┐
│ Implementation Done │
└─────────┬───────────┘
          │
    ┌─────┼─────┐
    ▼     ▼     ▼
┌─────┐ ┌─────┐ ┌─────┐
│Code │ │Secu-│ │Docs │  (Claude may parallelize)
│Revw │ │rity │ │Agent│  (Codex requires approval)
└──┬──┘ └──┬──┘ └──┬──┘
   │       │       │
   └───────┼───────┘
           ▼
    Findings → Provider Task Tracking
           ▼
    Main Context Fixes
```

### The `/rptc:feat-team` Command (Team-Based)

An alternative to `/rptc:feat` that uses persistent roles and provider-supported coordination:

```text
/rptc:feat-team "description"
    ↓
Step 0: Initialize (Serena, branch strategy)
    ↓
Step 1: Create or coordinate team roles
    → researcher, architect, implementer, reviewer
    → Claude may spawn persistent agents; Codex requires explicit delegation approval
    ↓
Step 2: Discovery
    → researcher explores → passes findings to architect role
    ↓
Step 3: Architecture
    → architect plans → Team Lead gets user approval
    ↓
Step 4: Implementation + Review (parallel feedback loop)
    → implementer: TDD per step
    → architect: plan adherence check after each step
    → reviewer: quality/security/docs check after each step
    → implementer addresses all feedback before next step
    ↓
Step 5: Final Holistic Review
    → architect + reviewer: cross-cutting review of ALL changes together
    → catches integration issues, gaps, cross-file concerns
    → implementer addresses any final findings
    ↓
Step 6: Complete
    → Collect reports → Summary → /rptc:commit
```

**Key difference from `/rptc:feat`:** Verification is continuous (every step), not post-hoc (Phase 4 only). Claude agents may stay alive for the entire session; Codex coordinates through the parent session and subagent completion reports when delegation is explicitly approved.

### The `/rptc:fix-team` Command (Team-Based Bug Fixing)

Parallels `/rptc:feat-team` but adapted for bug fixing — root cause focus, 5 Whys methodology, regression-test-first:

```text
/rptc:fix-team "bug description"
    ↓
Step 0: Initialize (Serena, branch strategy)
    ↓
Step 1: Create or coordinate team roles
    → researcher, architect, implementer, reviewer
    → Claude may spawn persistent agents; Codex requires explicit delegation approval
    ↓
Step 2: Reproduction & Triage
    → researcher reproduces bug, maps failure path, passes findings to architect role
    ↓
Step 3: Root Cause Analysis
    → architect applies 5 Whys → designs minimal fix → Team Lead gets user approval
    ↓
Step 4: Fix + Review (parallel feedback loop)
    → implementer: regression test FIRST (must fail against broken code), then surgical fix
    → architect: root cause guardianship (flags symptom treatment)
    → reviewer: quality/security/docs/regression coverage check after each step
    → implementer addresses all feedback before next step
    ↓
Step 5: Final Regression Review
    → architect + reviewer verify root cause addressed, related paths covered
    → regression test suite adequately prevents this class of bug
    → implementer addresses any final findings
    ↓
Step 6: Complete
    → Collect reports → Summary → /rptc:commit
```

**Key difference from `/rptc:fix`:** Same continuous verification as `feat-team`, plus Architect continuously challenges whether the fix addresses the root cause rather than just the symptom.

---

## Report-Only Verification System

Quality verification agents (code-review, security, docs) operate in **report-only mode**:

| Confidence | Priority | Action |
|------------|----------|--------|
| ≥90% | High | Reported first, clear issues |
| 80-89% | Medium | Reported, verify context |
| <80% | Skip | Below threshold, not reported |

**Principles:**

- Agents DO NOT edit, write, or auto-fix anything
- All findings returned to main context via provider task tracking
- Main context handles fixes with user approval as needed
- User decides which findings to address

---

## Smart Batching (TDD Phase)

Related implementation steps are grouped for efficiency:

### Batching Criteria

1. **File cohesion**: Steps targeting same files
2. **Sequential chains**: Step N+1 depends only on N
3. **Size threshold**: Combined lines < 150

### Benefits

- ~40% token reduction vs. sequential execution
- Claude command-defined parallel execution of independent batches; Codex delegation or parallel execution only with provider policy and explicit user approval
- Maintains strict TDD discipline per step

### Example

```text
Plan with 7 steps:
  Step 1: Add User model
  Step 2: Add User repository
  Step 3: Add User service
  Step 4: Add Auth middleware
  Step 5: Add Login endpoint
  Step 6: Add Register endpoint
  Step 7: Add Tests

Batching result:
  Batch A: [1, 2, 3] - Core user module (parallel)
  Batch B: [4]       - Middleware (sequential after A)
  Batch C: [5, 6]    - Endpoints (parallel after B)
  Batch D: [7]       - Tests (sequential after C)
```

---

## Version Management

### Plugin Version Locations

All must stay synchronized:

1. `plugins/rptc/.claude-plugin/plugin.json` → `"version"`
2. `plugins/rptc/.codex-plugin/plugin.json` → `"version"`
3. `.claude-plugin/marketplace.json` → `metadata.version`
4. `.claude-plugin/marketplace.json` → `plugins[0].version`
5. `plugins/rptc/README.md` → `**Version**: X.Y.Z`
6. `CHANGELOG.md` → `## [X.Y.Z]`

### Update Process

Update each version location in the same change. There is no package sync step because `plugins/rptc` is canonical.

---

## Summary

**RPTC Architecture Principles:**

1. **Provider-native feature entrypoint**: Claude uses `/rptc:feat`; Codex uses the `rptc-workflow` feature chat intent
2. **Task-appropriate workflow**: TDD for code, direct execution for non-code
3. **Provider-aware execution**: Claude may use command-defined concurrent agents; Codex delegates or parallelizes only with provider policy and explicit user approval
4. **Native planning**: Use Claude's plan mode or Codex `update_plan`/chat approval
5. **Minimal footprint**: No workspace directories or configuration required
6. **User as PM**: You select approach, approve plans, review findings
7. **Report-only quality gates**: Agents report, main context fixes

**Plugin provides:**

- 11 Claude slash commands (4 primary, 7 supporting)
- 9 Claude specialist agents and 9 Codex role-definition references for approved delegation
- 10 SOPs
- 19 skills (8 user-facing + 11 agent methodology)

**User provides:**

- Feature descriptions
- Planning approach selection
- Plan approval
- Quality gate decisions
