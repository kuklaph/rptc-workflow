# RPTC Plugin Architecture

> Technical documentation for plugin structure, installation, and internals

---

## Plugin Distribution

When users install the plugin:

```bash
/plugin marketplace add https://github.com/kuklaph/rptc-workflow
/plugin install rptc
```

They receive the entire repository cloned to their Claude plugin directory.

### Plugin Structure

```text
rptc-workflow/                      # ${CLAUDE_PLUGIN_ROOT}
├── .claude-plugin/
│   ├── plugin.json                 # Plugin metadata & version
│   └── marketplace.json            # Marketplace listing
│
├── commands/                       # Flat structure (10 commands)
│   ├── commit.md                   # /rptc:commit
│   ├── config.md                   # /rptc:config
│   ├── feat.md                     # /rptc:feat (PRIMARY)
│   ├── feat-team.md                # /rptc:feat-team (team-based feat)
│   ├── fix.md                      # /rptc:fix
│   ├── research.md                 # /rptc:research
│   ├── structure.md                # /rptc:structure
│   ├── sync-prod-to-tests.md       # /rptc:sync-prod-to-tests
│   ├── verify.md                   # /rptc:verify (standalone verification)
│   └── verify-loop.md              # /rptc:verify-loop (convergence loop)
│
├── agents/                         # Specialist agents (9 agents)
│   ├── docs-agent.md               # Documentation sync
│   ├── code-review-agent.md        # Code review
│   ├── architect-agent.md          # Implementation planning
│   ├── research-agent.md           # Research and exploration
│   ├── review-agent.md             # Unified review (code+security+docs) for teams
│   ├── security-agent.md           # Security review
│   ├── tdd-agent.md                # TDD execution
│   ├── test-fixer-agent.md         # Test repair
│   └── test-sync-agent.md          # Test-production sync
│
├── sop/                            # Standard Operating Procedures (10 SOPs)
│   ├── architecture-patterns.md
│   ├── flexible-testing-guide.md
│   ├── frontend-guidelines.md
│   ├── git-and-deployment.md
│   ├── languages-and-style.md
│   ├── post-tdd-refactoring.md
│   ├── security-and-performance.md
│   ├── test-sync-guide.md
│   ├── testing-guide.md
│   └── todowrite-guide.md
│
├── skills/                         # Skills (18 skills)
│   ├── agent-teams/
│   ├── architect-methodology/
│   ├── brainstorming/
│   ├── code-review-methodology/
│   ├── core-principles/
│   ├── discord-notify/
│   ├── docs-methodology/
│   ├── frontend-design/
│   ├── html-report-generator/
│   ├── research-methodology/
│   ├── security-methodology/
│   ├── structure-methodology/
│   ├── tdd-agent-methodology/
│   ├── tdd-methodology/
│   ├── test-fixer-methodology/
│   ├── test-sync-methodology/
│   ├── tool-guide/
│   └── writing-clearly-and-concisely/
│
├── templates/                      # Document templates
│   ├── ai-sop-enhancement-pattern.md
│   ├── plan-overview.md
│   ├── plan-step.md
│   ├── research-codebase.md
│   ├── research-hybrid.md
│   └── research-web.md
│
├── docs/                           # Documentation
│   ├── PLUGIN_ARCHITECTURE.md      # This file
│   ├── PROJECT_TEMPLATE.md         # User project template
│   ├── RPTC_WORKFLOW_GUIDE.md      # Complete workflow guide
│   └── AI_CODING_BEST_PRACTICES.md # AI coding guidelines
│
├── README.md                       # Main documentation
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

## Installation Flow

### Step 1: User Installs Plugin

```bash
/plugin marketplace add https://github.com/kuklaph/rptc-workflow
/plugin install rptc
```

**What happens:**

- Claude clones repo to plugin directory
- This becomes `${CLAUDE_PLUGIN_ROOT}`
- All 10 commands registered and available
- Agents available for delegation
- SOPs available for agent reference

### Step 2: User Starts Building

```bash
/rptc:feat "add user authentication"
```

**What happens:**

- `/rptc:feat` handles entire workflow
- Phase 1: Discovery (codebase exploration)
- Phase 2: Architecture (plan creation in `~/.claude/plans/`)
- Phase 3: TDD Implementation
- Phase 4: Quality Verification
- Phase 5: Complete

**No workspace initialization required.** RPTC uses Claude's native plan mode.

---

## User Projects (Minimal Footprint)

RPTC requires almost nothing in user projects:

```text
user-project/
├── docs/research/               # Optional: saved research documents
├── CLAUDE.md                    # Optional: project context (recommended)
└── [your project files]
```

**Plans are stored in:** `~/.claude/plans/` (Claude's native location)

**No `.rptc/` directory needed.** No `.claude/settings.json` configuration needed.

---

## Command Architecture

### The Unified `/rptc:feat` Command

The primary command handles the complete workflow:

```text
/rptc:feat "description"
    ↓
Phase 1: Discovery
    → Launches 2-3 parallel exploration agents
    → Uses rptc:research-agent with code-explorer methodology
    ↓
Teams Analysis
    → Single task: continue to Branch Strategy
    → Multiple independent tasks: Agent Teams mode (skill orchestrates)
    ↓
Branch Strategy
    → Current branch or new git worktree
    ↓
Phase 2: Architecture
    → Enters Claude's native plan mode
    → Launches 3 parallel plan agents (Minimal, Clean, Pragmatic)
    → User selects approach
    → Plan written to ~/.claude/plans/
    ↓
Phase 3: Implementation
    → Route A (non-code): Main context executes directly
    → Route B (code): TDD with smart batching via rptc:tdd-agent
    ↓
Phase 4: Quality Verification (Report-Only)
    → Parallel: code-review-agent + security-agent + docs-agent
    → Agents report findings only (no auto-fix)
    → Main context handles fixes via TaskCreate/TaskUpdate
    ↓
Phase 5: Complete
    → Summary of changes
    → Ready for /rptc:commit
```

### Supporting Commands

| Command | Purpose | Typical Usage |
|---------|---------|---------------|
| `/rptc:research "topic"` | Standalone research | Before `/rptc:feat` for unfamiliar topics |
| `/rptc:commit [pr]` | Verify and ship | After completing implementation |
| `/rptc:verify [path]` | Run verification agents on demand | After any code change |
| `/rptc:verify-loop [path]` | Run verification in a convergence loop until 0 findings | After implementation, when you want a fully clean result |
| `/rptc:feat-team "description"` | Team-based feature development with 4 persistent agents | Complex features needing continuous review |
| `/rptc:structure` | Codebase structure analysis and refactoring | When restructuring or analyzing project layout |
| `/rptc:config` | Configure RPTC in project CLAUDE.md | First-time setup, after plugin updates |
| `/rptc:sync-prod-to-tests "[dir]"` | Test maintenance | When tests drift from production |

---

## Agent Delegation Pattern

Commands delegate to specialist agents using the Task tool:

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

### Agent Responsibilities

| Agent | Phase | Purpose | Mode |
|-------|-------|---------|------|
| `rptc:research-agent` | Phase 1 | Codebase exploration, pattern discovery | Active |
| `rptc:architect-agent` | Phase 2 | Implementation planning (3 perspectives) | Active |
| `rptc:tdd-agent` | Phase 3 (code) | RED-GREEN-REFACTOR execution | Active |
| `rptc:code-review-agent` | Phase 4 | Code review, KISS/YAGNI | **Report-only** |
| `rptc:security-agent` | Phase 4 | Security review, OWASP compliance | **Report-only** |
| `rptc:docs-agent` | Phase 4 | Documentation impact review | **Report-only** |
| `rptc:review-agent` | `/feat-team` | Unified review (code+security+docs) with real-time feedback | **Report-only** |
| `rptc:test-sync-agent` | `/sync-prod-to-tests` | Analyze test-production relationships | Analysis |
| `rptc:test-fixer-agent` | `/sync-prod-to-tests` | Auto-repair test files | Active |

---

## Parallel Execution Architecture

RPTC maximizes efficiency through parallelization:

### Phase 1: Discovery

```text
┌─────────────────────┐
│  Feature Request    │
└─────────┬───────────┘
          │
    ┌─────┴─────┐
    ▼           ▼
┌───────┐   ┌───────┐
│Agent 1│   │Agent 2│   (2-3 parallel exploration agents)
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
│Mini-│ │Clean│ │Prag-│  (3 parallel plan agents)
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
│Code │ │Secu-│ │Docs │  (All 3 run in parallel)
│Revw │ │rity │ │Agent│  (REPORT-ONLY)
└──┬──┘ └──┬──┘ └──┬──┘
   │       │       │
   └───────┼───────┘
           ▼
    Findings → TaskCreate
           ▼
    Main Context Fixes
```

### The `/rptc:feat-team` Command (Team-Based)

An alternative to `/rptc:feat` that uses persistent agents with real-time messaging:

```text
/rptc:feat-team "description"
    ↓
Step 0: Initialize (topology, Serena, branch strategy)
    ↓
Step 1: Create Team (4 agents spawned in parallel)
    → researcher, architect, implementer, reviewer
    ↓
Step 2: Discovery
    → researcher explores → messages architect
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

**Key difference from `/rptc:feat`:** Verification is continuous (every step), not post-hoc (Phase 4 only). All agents stay alive for the entire session, communicating via team messages.

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
- All findings returned to main context via TaskCreate/TaskUpdate
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
- Parallel execution of independent batches
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

1. `.claude-plugin/plugin.json` → `"version"`
2. `.claude-plugin/marketplace.json` → `metadata.version`
3. `.claude-plugin/marketplace.json` → `plugins[0].version`
4. `README.md` → `**Version**: X.Y.Z`
5. `CHANGELOG.md` → `## [X.Y.Z]`

### Update Process

```bash
# One command updates all locations
./scripts/sync-version.sh X.Y.Z
```

Pre-commit hook automatically blocks commits with version mismatch.

---

## Migration from v1.x/v2.x

### What Changed in v2.8.0+

| Before | After |
|--------|-------|
| Separate `/rptc:plan` + `/rptc:tdd` | Unified `/rptc:feat` |
| 16 commands | 9 commands |
| `.rptc/` workspace required | Not needed |
| `.claude/settings.json` config | Not needed |
| SOP fallback chain (3 levels) | Plugin SOPs only |
| Helper commands (6+) | Merged into `/rptc:feat` |

### Migration Steps

1. No action required for new features
2. Existing `.rptc/` directories can be deleted
3. Old plans can be referenced by path if needed
4. Plans now stored in `~/.claude/plans/`

---

## Summary

**RPTC Architecture Principles:**

1. **One command for features**: `/rptc:feat` handles everything
2. **Task-appropriate workflow**: TDD for code, direct execution for non-code
3. **Parallel execution**: Maximize efficiency through concurrent agents
4. **Native plan mode**: Use Claude's built-in planning (`~/.claude/plans/`)
5. **Minimal footprint**: No workspace directories or configuration required
6. **User as PM**: You select approach, approve plans, review findings
7. **Report-only quality gates**: Agents report, main context fixes

**Plugin provides:**

- 10 commands (3 primary, 7 supporting)
- 9 specialist agents
- 10 SOPs
- 18 skills (7 user-facing + 11 agent methodology)

**User provides:**

- Feature descriptions
- Planning approach selection
- Plan approval
- Quality gate decisions
