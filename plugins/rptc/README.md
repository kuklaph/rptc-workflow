# RPTC Workflow Plugin

> Research → Plan → TDD → Commit: Systematic development workflow with PM collaboration and quality gates

**Version**: 3.16.2
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

Claude exposes `/rptc:*` slash commands directly.

### Codex Installation

Install the Codex plugin from this repository, then run the `rptc-init` skill once to copy packaged agent TOML files into the Codex agents directory. The workflow checks agent TOML file existence at startup and before custom agent spawning.

Invoke RPTC in Codex with natural language, for example:

```text
Use RPTC to implement your feature description.
Run RPTC verification on this change.
```

---

## What is RPTC?

RPTC is a structured development workflow that puts **YOU in control** as the Project Manager, with the AI coding agent as your collaborative partner.

### The Workflow

```text
RESEARCH → PLAN → TDD → COMMIT
```

All phases are unified in the feature workflow: Claude uses `/rptc:feat`; Codex uses the equivalent `rptc-feat` skill through natural-language invocation.

### Core Principles

- **You are the PM**: Final decision authority
- **Task-appropriate workflow**: TDD for code, direct execution for non-code tasks
- **Ask permission, not forgiveness**: Explicit approvals required
- **Quality gates matter**: Code Review, Security & Documentation verification

---

## Commands

Claude exposes `/rptc:*` slash commands. Codex exposes equivalent `rptc-*` skills; use natural-language invocations such as "Use RPTC to implement..." or "Run RPTC verification...".

### Primary Workflow

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/rptc:feat "description"` | **Complete feature development**: Discovery → Architecture → Implementation → Quality Verification | New features, enhancements, refactoring |
| `/rptc:feat-team "description"` | **Claude only**: 4 persistent agents with real-time cross-agent feedback | Complex features needing continuous review during implementation |
| `/rptc:fix "bug description"` | **Systematic bug fixing**: Reproduction → Root Cause → Fix → Verify | Bug triaging and fixing |
| `/rptc:fix-team "bug description"` | **Claude only**: 4 persistent agents with root cause guardianship and regression focus | Complex bugs, unclear root cause, cross-cutting regressions |

### Supporting Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/rptc:config` | Configure RPTC in project instruction file (`CLAUDE.md` or `AGENTS.md`) | First-time setup, after plugin updates, sync settings |
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

- Launches 2-3 parallel exploration agents for codebase analysis
- Optional web research for unfamiliar topics
- Summarizes key patterns, files to modify, and dependencies
- **Branch Strategy**: Choose to work on the current branch or create a new git worktree — new worktrees are placed in a sibling `<repo>.worktrees/<branch-name>` directory next to the repo (e.g., repo at `~/projects/myapp` → worktrees at `~/projects/myapp.worktrees/feature/add-auth`)

### Phase 2: Architecture

**Goal**: Design the implementation approach with user approval.

- Enters the provider planning mode
- Launches 3 plan agents with different perspectives:
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
- Runs batches in parallel when independent
- Strict RED → GREEN → REFACTOR cycle per step
- ~40% token reduction vs. individual step execution

### Phase 4: Quality Verification

**Goal**: Review changes and create fix list for main context.

**Mode**: Report-only (agents don't make changes)

- **Code Review Agent**: Complexity, KISS/YAGNI violations, dead code
- **Security Agent**: Input validation, auth checks, injection vulnerabilities
- **Documentation Agent**: README updates, API doc changes, inline comment accuracy
- All three run in parallel, report findings
- Main context addresses findings via provider task tracker

### Phase 5: Complete

**Goal**: Summarize what was built.

- Files created/modified
- Tests added
- Key implementation decisions

---

## Workflow Patterns

### Pattern 1: Standard Feature (Recommended)

```bash
# One command does everything
/rptc:feat "add user profile avatar upload"
# → Discovery → Architecture → TDD Implementation → Quality Verification → Complete

# Then ship
/rptc:commit pr
```

### Pattern 2: Research First

```bash
# Standalone research for complex/unfamiliar topics
/rptc:research "OAuth2 best practices for mobile apps"

# Then build with the knowledge gained
/rptc:feat "add OAuth2 authentication"

# Ship
/rptc:commit pr
```

### Pattern 3: Bug Fix

```bash
# Systematic bug triaging and fixing
/rptc:fix "cart items disappear after page refresh"
# → Reproduction → Root Cause Analysis → Fix → Verification

/rptc:commit
```

### Pattern 4: Parallel Features

```bash
# Multiple independent features in parallel.
# Claude: ask it to use the agent-teams skill.
# Codex: ask it to spawn parent-orchestrated agents with file ownership boundaries.
#   "add user auth, build notification system, create admin dashboard"
# → Main session coordinates approvals and integration

/rptc:commit pr
```

### Pattern 5: Team-Based Feature (Claude Only)

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

When you approve delegation, specialized AI agents provide expert analysis:

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

**Purpose**: Auto-repair test files based on sync analysis
**When**: `/rptc:sync-prod-to-tests` command (fix phase)
**Provides**: Update, add, create, and assertion fix scenarios

### Review Agent

**Purpose**: Unified quality reviewer combining code review, security, and documentation checks
**When**: `/rptc:feat-team` and `/rptc:fix-team` (runs continuously alongside TDD agent during implementation/fix)
**Provides**: Real-time consolidated feedback across all three quality domains per implementation step
**Architecture**: Report-only with team messaging — sends findings directly to TDD agent after each step

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
- `test-sync-guide.md` - Test-production matching algorithms and sync verification

Claude-specific SOPs:

- `claude/sop/todowrite-guide.md` - TodoWrite patterns for Claude research, commit, and sync commands

---

## Skills

### User-Facing Skills

| Skill | Purpose |
|-------|---------|
| `agent-teams` | Claude-only parallel execution via Agent Teams for batch/multi-feature work |
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
| `docs-methodology` | docs-agent, review-agent | 8-step workflow, instruction-file update policy, anti-patterns (incl. Stuffing instruction files), special cases |
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
│   └── plugin.json              # Claude metadata; commands path and explicit agent file list
├── .codex-plugin/
│   └── plugin.json              # Codex plugin metadata; points to ./codex/skills
├── claude/
│   ├── commands/                # Claude slash commands
│   ├── agents/                  # Claude specialist agents
│   └── sop/
│       └── todowrite-guide.md   # Claude-specific TodoWrite SOP
├── codex/
│   ├── skills/                  # Codex skills and command-equivalent skills
│   ├── agents/                  # Packaged Codex agent TOMLs, installed by rptc-init
│   └── sop/
│       └── update-plan-guide.md # Codex-specific task tracking SOP
├── sop/                         # 9 shared SOPs
├── templates/                   # Templates for artifacts
├── skills/                      # 18 skills
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
│   ├── tdd-agent-methodology/
│   ├── tdd-methodology/
│   ├── test-fixer-methodology/
│   ├── test-sync-methodology/
│   ├── structure-methodology/
│   ├── tool-guide/
│   └── writing-clearly-and-concisely/
└── docs/                        # Documentation
```

### Your Project (No Setup Required)

RPTC uses the provider planning mode. No special directories needed.

```text
your-project/
├── docs/research/               # Optional: saved research documents
├── CLAUDE.md or AGENTS.md       # Optional: project context (recommended)
└── [your project files]
```

**Plans are stored in**: the active RPTC plan location for the current provider.

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
- Parallel execution of independent batches
- Maintains strict TDD discipline

---

## Best Practices

### When to Use Each Approach

| Scenario | Approach |
|----------|----------|
| Bug Fix | `/rptc:fix "bug description"` |
| Complex Bug (root cause unclear) | Claude: `/rptc:fix-team "bug description"`; Codex: `/rptc:fix` with parent-orchestrated delegation |
| Small Feature | `/rptc:feat "add X"` |
| Medium Feature | `/rptc:feat "implement X"` |
| Large Feature | `/rptc:feat "build X"` (auto-batching handles size) |
| Complex Feature (continuous review) | Claude: `/rptc:feat-team "build X"`; Codex: `/rptc:feat` with parent-orchestrated delegation |
| Unfamiliar Code | `/rptc:research "X"` first, then `/rptc:feat` |

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
/rptc:feat "your feature description"
```

That's the main command. No setup needed.

### Q: How do I ship my changes?

```bash
/rptc:commit       # Simple commit
/rptc:commit pr    # Commit with PR creation
```

### Q: Need research before building?

```bash
/rptc:research "topic to explore"
# Then
/rptc:feat "feature based on research"
```

### Q: Tests out of sync with code?

```bash
/rptc:sync-prod-to-tests "src/"
```

### Q: Where are my plans stored?

Plans use the provider planning mode: the active RPTC plan location for the current provider

### Q: Do I need configuration?

No. RPTC uses sensible defaults. No `.claude/settings.json` required.

---

## Migration from Older Versions

If you have an existing `.rptc/` directory from older RPTC versions:

1. Plans in `.rptc/plans/` can be moved to the active RPTC plan location for the current provider
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

- **Documentation**: `docs/RPTC_WORKFLOW_GUIDE.md`
- **Issues**: https://github.com/kuklaph/rptc-workflow/issues
- **Discussions**: https://github.com/kuklaph/rptc-workflow/discussions
