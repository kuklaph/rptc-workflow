# RPTC Workflow Plugin

> Research → Plan → TDD → Commit: Systematic development workflow with PM collaboration and quality gates

**Version**: 3.16.0
**Status**: Beta
**License**: MIT

---

## Quick Start

### Claude Installation

```bash
# Step 1: Add the marketplace
/plugin marketplace add https://github.com/kuklaph/rptc-workflow

# Step 2: Install the plugin
/plugin install rptc

# Step 3: Start building
/rptc:feat "your feature description"
```

Claude installs plugins to user scope by default, making RPTC available across projects.

### Codex Installation

RPTC ships one installable plugin package for both Claude and Codex under `plugins\rptc`.

```text
.claude-plugin/marketplace.json
.agents/plugins/marketplace.json
plugins/rptc/.claude-plugin/plugin.json
plugins/rptc/.codex-plugin/plugin.json
plugins/rptc/agents/
plugins/rptc/claude/commands/
plugins/rptc/claude/agents/
```

In Codex, install or enable the `rptc` plugin from the RPTC marketplace, then ask Codex to use RPTC:

```text
Use RPTC to implement "your feature description".
Use RPTC to fix "bug description".
Run an RPTC verification pass.
```

No project initialization is required for either provider.

For global Codex use, use the same package shape at your Codex home level:

```text
~/.agents/plugins/marketplace.json
~/.codex/plugins/rptc/.codex-plugin/plugin.json
```

Point the personal marketplace source path at `./.codex/plugins/rptc`, relative to the marketplace root. In this repository, the Codex marketplace source remains `./plugins/rptc`.

The package is canonical. Edit files directly under `plugins\rptc`; no sync or build step is required.

---

## What is RPTC?

RPTC is a structured development workflow that puts **YOU in control** as the Project Manager, with Claude or Codex as your collaborative partner.

### The Workflow

```text
RESEARCH → PLAN → TDD → COMMIT
```

In Claude, phases are unified in slash commands such as `/rptc:feat` and Claude plugin subagents. In Codex, the `rptc-workflow` skill maps the same intents to Codex-native tools and runs in the main context unless the user explicitly approves `spawn_agent` delegation. Codex role-definition references live in `plugins\rptc\agents`.

### Core Principles

- **You are the PM**: Final decision authority
- **Task-appropriate workflow**: TDD for code, direct execution for non-code tasks
- **Ask permission, not forgiveness**: Explicit approvals required
- **Quality gates matter**: Code Review, Security & Documentation verification

---

## Commands

Claude exposes these as namespaced slash commands. Codex treats the same names
as workflow intents through the `rptc-workflow` skill, so ask in chat with the
same intent text, for example "Use RPTC feat to ...".

### Primary Workflow

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/rptc:feat "description"` | **Complete feature development**: Discovery → Architecture → Implementation → Quality Verification | New features, enhancements, refactoring |
| `/rptc:feat-team "description"` | **Team-based feature development**: 4 persistent agents with real-time cross-agent feedback | Complex features needing continuous review during implementation |
| `/rptc:fix "bug description"` | **Systematic bug fixing**: Reproduction → Root Cause → Fix → Verify | Bug triaging and fixing |
| `/rptc:fix-team "bug description"` | **Team-based bug fixing**: 4 persistent agents with root cause guardianship and regression focus | Complex bugs, unclear root cause, cross-cutting regressions |

### Supporting Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/rptc:config` | Configure RPTC in provider project context (`CLAUDE.md`/`AGENTS.md`) | First-time setup, after plugin updates, sync settings |
| `/rptc:research "topic"` | Standalone research and discovery | Exploring unfamiliar topics separately |
| `/rptc:commit [pr]` | Verify and ship | After completing implementation |
| `/rptc:verify [path]` | Run quality verification agents on demand | After any code change, independent verification |
| `/rptc:verify-loop [path]` | Run verification in a loop until 0 findings | After implementation, when you want a fully clean result |
| `/rptc:structure [path]` | Analyze and improve codebase structure for AI-ready development | Codebase restructuring, AI-readiness audits |
| `/rptc:sync-prod-to-tests "[dir]"` | Sync tests to production code with auto-fix | Test maintenance |

---

## The `/rptc:feat` Workflow

### Phase 1: Discovery

**Goal**: Understand what to build and existing patterns.

- Explores codebase patterns; Claude may launch parallel exploration agents, while Codex stays in the main context unless explicit parallel-agent approval exists
- Optional web research for unfamiliar topics
- Summarizes key patterns, files to modify, and dependencies
- **Branch Strategy**: Choose to work on the current branch or create a new git worktree — new worktrees are placed in a sibling `<repo>.worktrees/<branch-name>` directory next to the repo (e.g., repo at `~/projects/myapp` → worktrees at `~/projects/myapp.worktrees/feature/add-auth`)

### Phase 2: Architecture

**Goal**: Design the implementation approach with user approval.

- Enters provider planning context (Claude plan mode; Codex chat plan plus `update_plan`)
- Presents 3 planning perspectives:
  - **Minimal**: Smallest change, reuses existing code
  - **Clean**: Maintainability-focused, elegant abstractions
  - **Pragmatic**: Balanced approach, good enough without over-engineering
- **User selects approach** and approves plan

### Phase 3: Implementation

**Goal**: Execute the plan using the appropriate method.

**Route A - Non-Code Tasks** (docs, config, markdown):
- Main context executes steps directly
- No TDD overhead for non-code changes

**Route B - Code Tasks** (TDD with Smart Batching):
- Groups related steps into batches for efficiency
- Runs batches in parallel when independent in Claude or when Codex has explicit user approval for parallel-agent delegation; otherwise Codex keeps batching in the main context
- Strict RED → GREEN → REFACTOR cycle per step
- ~40% token reduction vs. individual step execution

### Phase 4: Quality Verification

**Goal**: Review changes and create fix list for main context.

**Mode**: Report-only (agents don't make changes)

- **Code Review Agent**: Complexity, KISS/YAGNI violations, dead code
- **Security Agent**: Input validation, auth checks, injection vulnerabilities
- **Documentation Agent**: README updates, API doc changes, inline comment accuracy
- All three report findings; parallelize only when provider policy and user approval allow it
- Main context addresses findings via provider task tracking (`TaskCreate`/`TaskUpdate` in Claude, `update_plan` in Codex)

### Phase 5: Complete

**Goal**: Summarize what was built.

- Files created/modified
- Tests added
- Key implementation decisions

---

## Workflow Patterns

### Pattern 1: Standard Feature (Recommended)

```bash
# Claude: one command does everything
/rptc:feat "add user profile avatar upload"
# → Discovery → Architecture → TDD Implementation → Quality Verification → Complete

# Then ship
/rptc:commit pr
```

```text
Codex: Use RPTC to implement "add user profile avatar upload".
Codex: Use RPTC commit with PR preparation.
```

### Pattern 2: Research First

```bash
# Claude: standalone research for complex/unfamiliar topics
/rptc:research "OAuth2 best practices for mobile apps"

# Then build with the knowledge gained
/rptc:feat "add OAuth2 authentication"

# Ship
/rptc:commit pr
```

```text
Codex: Use RPTC to research "OAuth2 best practices for mobile apps".
Codex: Use RPTC to implement "add OAuth2 authentication".
Codex: Use RPTC commit with PR preparation.
```

### Pattern 3: Bug Fix

```bash
# Claude: systematic bug triaging and fixing
/rptc:fix "cart items disappear after page refresh"
# → Reproduction → Root Cause Analysis → Fix → Verification

/rptc:commit
```

```text
Codex: Use RPTC to fix "cart items disappear after page refresh".
Codex: Use RPTC commit.
```

### Pattern 4: Parallel Features (Agent Teams)

```bash
# Multiple independent features in parallel — invoke the agent-teams skill directly
# (applies to multi-stream batch work; for a single complex feature, Claude uses /rptc:feat-team and Codex uses the team feature chat intent)
# Ask Claude or Codex to "use the agent-teams skill to coordinate these in parallel":
#   "add user auth, build notification system, create admin dashboard"
# → agent-teams skill creates provider-available teammates/subagents with file ownership boundaries
# → Team Lead (main session) coordinates approvals and integration

/rptc:commit pr
```

### Pattern 5: Team-Based Feature (Continuous Review)

```bash
# Complex feature with real-time architect + review feedback during implementation
/rptc:feat-team "add user authentication with OAuth2 and role-based access control"
# → 4 agents collaborate: researcher, architect, implementer, reviewer
# → Architect monitors plan adherence, reviewer checks quality/security/docs after every step
# → Implementation agent addresses feedback before proceeding
# → Final holistic review catches cross-cutting issues across all changes

/rptc:commit pr
```

---

## Specialist Agents

In Claude, specialized plugin subagents provide expert analysis from `claude\agents` according to Claude command behavior. In Codex, `agents\` contains packaged role-definition references for the `rptc-workflow` skill and for approved `spawn_agent` delegation. Use Codex `spawn_agent` only when the user explicitly asks for delegation or parallel agents.

### Research Agent

**Purpose**: Research best practices through web search and codebase exploration
**When**: Discovery phase (Phase 1)
**Provides**: Existing patterns, implementation examples, dependencies
**Architecture**: Parallel sub-agents using code-explorer methodology

### Architect Agent

**Purpose**: Create comprehensive TDD-ready plans
**When**: Architecture phase (Phase 2)
**Provides**: 3 perspectives (Minimal/Clean/Pragmatic), file changes, test strategy
**Architecture**: 3 parallel agents, user selects approach

### TDD Agent

**Purpose**: Execute strict RED-GREEN-REFACTOR cycle
**When**: Implementation phase (Phase 3, code tasks only)
**Provides**: Tests first, minimal implementations, batched execution
**Architecture**: Smart batching for related steps

### Code Review Agent

**Purpose**: Review code for simplicity issues (KISS/YAGNI)
**When**: Quality Verification phase (Phase 4, parallel with Security and Docs)
**Provides**: Findings for dead code, complexity, readability improvements
**Architecture**: Report-only with confidence scoring

### Security Agent

**Purpose**: Identify vulnerabilities and security issues
**When**: Quality Verification phase (Phase 4, parallel with Code Review and Docs)
**Provides**: OWASP audit findings, input validation issues, auth/authz concerns
**Architecture**: Report-only with confidence scoring

### Documentation Agent

**Purpose**: Review documentation impact of changes
**When**: Quality Verification phase (Phase 4, parallel with Code Review and Security)
**Provides**: Findings for README updates, API doc changes, inline comment accuracy
**Architecture**: Report-only with confidence scoring

### Test Sync Agent

**Purpose**: Analyze test-production relationships
**When**: `/rptc:sync-prod-to-tests` command
**Provides**: Multi-layer confidence matching, mismatch reports

### Test Fixer Agent

**Purpose**: Repair test files through the active provider workflow based on sync analysis
**When**: `/rptc:sync-prod-to-tests` command (fix phase)
**Provides**: Update, add, create, and assertion fix scenarios

### Review Agent

**Purpose**: Unified quality reviewer combining code review, security, and documentation checks
**When**: `/rptc:feat-team` and `/rptc:fix-team` (runs continuously alongside TDD agent during implementation/fix)
**Provides**: Real-time consolidated feedback across all three quality domains per implementation step
**Architecture**: Report-only with provider-specific coordination. Claude team workflows can use team messaging; Codex coordinates through the main session and completion reports.

---

## Available SOPs

Standard Operating Procedures provide guidance for agents:

- `testing-guide.md` - Testing frameworks, patterns, TDD guidance
- `flexible-testing-guide.md` - Flexible assertions for AI-generated and non-deterministic code
- `architecture-patterns.md` - Architecture and design patterns
- `frontend-guidelines.md` - Frontend design, visual style, accessibility
- `git-and-deployment.md` - Git workflow, CI/CD, deployment
- `languages-and-style.md` - Language conventions, formatters, linters
- `security-and-performance.md` - Security practices, performance optimization
- `post-tdd-refactoring.md` - 5-phase refactoring checklist for code review agent
- `todowrite-guide.md` - Provider task tracking patterns (Claude `TodoWrite`/`TaskCreate`; Codex `update_plan`)
- `test-sync-guide.md` - Test-production matching algorithms and sync verification

---

## Skills

### User-Facing Skills

| Skill | Purpose |
|-------|---------|
| `rptc-workflow` | Codex-native adapter for RPTC command intents |
| `agent-teams` | Parallel execution via Agent Teams for batch/multi-feature work |
| `brainstorming` | Structured dialogue for requirement clarification before planning |
| `discord-notify` | Send Discord notifications on task completion |
| `frontend-design` | Distinctive, production-grade frontend aesthetics (complements `frontend-guidelines.md` SOP) |
| `html-report-generator` | Convert markdown research to professional HTML reports |
| `tdd-methodology` | TDD guidance in main context (alternative to sub-agent) |
| `writing-clearly-and-concisely` | Apply Strunk's Elements of Style to prose |

### Agent Methodology Skills

Preloaded into agents via `skills:` frontmatter at session start. Most are not invoked directly by users — exception: `tool-guide` is also loaded as a mandatory skill in `/rptc:feat` and `/rptc:fix` to activate Serena MCP in the main context.

| Skill | Agent | Content |
|-------|-------|---------|
| `core-principles` | All agents | Surgical Coding, Simplicity, Pattern Reuse |
| `tool-guide` | All agents | Serena MCP, Memory, Context7 |
| `architect-methodology` | architect-agent | 6-phase planning, constraints, output template |
| `code-review-methodology` | code-review-agent, review-agent | 4-tier review framework, over-engineering checklist, behavioral testing checklist, assertion quality checklist |
| `structure-methodology` | architect-agent, code-review-agent, review-agent | Codebase structure analysis and design guidance (deep module principles) |
| `docs-methodology` | docs-agent, review-agent | 8-step workflow, AI context file policy, anti-patterns (incl. context-file stuffing), special cases |
| `research-methodology` | research-agent | 3 research modes, mode selection logic |
| `security-methodology` | security-agent, review-agent | Finding categories, OWASP Top 10, confidence scoring |
| `tdd-agent-methodology` | tdd-agent | Batch execution, RED-GREEN-REFACTOR-VERIFY cycle |
| `test-fixer-methodology` | test-fixer-agent | Approval-aware execution, 5 fix scenarios |
| `test-sync-methodology` | test-sync-agent | 5-phase analysis, classification decision tree |

---

## Directory Structure

### Plugin Structure

```text
rptc-workflow/
├── .claude-plugin/
│   └── marketplace.json         # Claude marketplace listing
├── .agents/plugins/
│   └── marketplace.json         # Codex marketplace listing
├── README.md                    # Repository overview
├── CHANGELOG.md                 # Version history
├── LICENSE                      # MIT license
└── plugins/rptc/                # Canonical plugin package
    ├── .claude-plugin/plugin.json # Claude plugin metadata
    ├── .codex-plugin/plugin.json  # Codex plugin metadata
    ├── claude/
    │   ├── commands/              # Claude slash commands
    │   └── agents/                # Claude specialist agents
    ├── agents/                    # Codex role-definition references
    ├── skills/                    # Shared skills, including Codex adapter
    ├── sop/                       # SOPs
    ├── templates/                 # Templates
    ├── docs/                      # Documentation
    ├── README.md
    └── LICENSE
```

Package contents:

```text
plugins/rptc/claude/commands/   # 11 Claude commands
plugins/rptc/claude/agents/     # 9 Claude specialist agents
plugins/rptc/agents/            # 9 Codex role-definition references
plugins/rptc/sop/               # 10 SOPs
plugins/rptc/templates/         # Templates for artifacts
plugins/rptc/skills/            # 19 shared skills, including Codex adapter
plugins/rptc/docs/              # Documentation
```

### Your Project (No Setup Required)

RPTC is designed as a global workflow plugin. No special directories are required in target projects.

```text
your-project/
├── docs/research/               # Optional: saved research documents
├── CLAUDE.md or AGENTS.md       # Optional: provider project context
└── [your project files]
```

Claude plans use `~/.claude/plans/`. Codex tracks plans in-session with `update_plan` and chat approval.

---

## Advanced Features

### Test Allocation

**Purpose**: AI-accelerated comprehensive test generation from plan specifications.

**How it works**: During `/rptc:feat` Phase 3, the tdd-agent automatically generates tests based on step complexity:
- Simple steps (~15 tests): 1 file, <30 lines
- Medium steps (~30 tests): 1-2 files, 30-80 lines
- Complex steps (~50 tests): 3+ files, >80 lines

Coverage targets: happy paths, edge cases, error conditions, integration.

### Smart Batching

**Purpose**: Combine related TDD steps for efficiency.

**Benefits**:
- ~40% token reduction
- Parallel execution of independent batches in Claude or approved Codex delegation; otherwise main-context batching
- Maintains strict TDD discipline

---

## Best Practices

### When to Use Each Approach

| Scenario | Approach |
|----------|----------|
| Bug Fix | Claude: `/rptc:fix "bug description"`; Codex: ask for the RPTC fix intent |
| Complex Bug (root cause unclear) | Claude: `/rptc:fix-team "bug description"`; Codex: ask for the RPTC team fix intent with explicit delegation approval |
| Small Feature | Claude: `/rptc:feat "add X"`; Codex: ask for the RPTC feature intent |
| Medium Feature | Claude: `/rptc:feat "implement X"`; Codex: ask for the RPTC feature intent |
| Large Feature | Claude: `/rptc:feat "build X"`; Codex: ask for the RPTC feature intent |
| Complex Feature (continuous review) | Claude: `/rptc:feat-team "build X"`; Codex: ask for the RPTC team feature intent with explicit delegation approval |
| Unfamiliar Code | Claude: `/rptc:research "X"` then `/rptc:feat`; Codex: ask for RPTC research, then the RPTC feature intent |

### TDD Best Practices

1. **RED**: Write failing test first
2. **GREEN**: Minimal code to pass
3. **REFACTOR**: Improve while keeping tests green
4. **VERIFY**: Run affected tests

### Quality Gate Best Practices

- **Code Review Gate**: Catches over-engineering, enforces KISS/YAGNI
- **Security Gate**: Prevents vulnerabilities before they ship
- **All tests must remain passing** after each gate

---

## Troubleshooting

### Q: How do I start?

```bash
# Claude
/rptc:feat "your feature description"
```

```text
Codex: Use RPTC to implement "your feature description".
```

No setup needed.

### Q: How do I ship my changes?

```bash
# Claude
/rptc:commit       # Simple commit
/rptc:commit pr    # Commit with PR creation
```

```text
Codex: Use RPTC commit.
Codex: Use RPTC commit with PR preparation.
```

### Q: Need research before building?

```bash
# Claude
/rptc:research "topic to explore"
# Then
/rptc:feat "feature based on research"
```

```text
Codex: Use RPTC to research "topic to explore".
Codex: Use RPTC to implement "feature based on research".
```

### Q: Tests out of sync with code?

```bash
# Claude
/rptc:sync-prod-to-tests "src/"
```

```text
Codex: Use RPTC to sync production and tests for "src/".
```

### Q: Where are my plans stored?

Claude plans use native plan mode: `~/.claude/plans/`. Codex tracks plans in-session with `update_plan` unless the user asks for a project plan file.

### Q: Do I need configuration?

No. RPTC uses sensible defaults. No `.claude/settings.json` or `.codex/settings.json` required.

---

## Migration from Older Versions

If you have an existing `.rptc/` directory from older RPTC versions:

1. Plans in `.rptc/plans/` can be moved to the provider plan location (Claude: `~/.claude/plans/`; Codex: keep by path or ask for a project plan file)
2. Research in `.rptc/research/` can be moved to `docs/research/`
3. The `.rptc/` directory can be deleted

**Migration is optional** - old plans still work if referenced by path.

### What Changed (v2.8.0+)

| Before | After |
|--------|-------|
| Separate `/rptc:plan` + `/rptc:tdd` | Unified `/rptc:feat` |
| `.rptc/` directory required | Not needed |
| `.claude/settings.json` config | Not needed |
| Helper commands (6+) | Merged into `/rptc:feat` |
| SOP fallback chain | Plugin defaults only |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

- **Documentation**: `plugins\rptc\docs\RPTC_WORKFLOW_GUIDE.md`
- **Issues**: https://github.com/kuklaph/rptc-workflow/issues
- **Discussions**: https://github.com/kuklaph/rptc-workflow/discussions
