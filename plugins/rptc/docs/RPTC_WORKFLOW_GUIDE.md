# RPTC Workflow Guide

## Research → Plan → TDD → Commit with PM Collaboration

---

## Quick Start

### Claude

```bash
# Install the plugin
/plugin marketplace add https://github.com/kuklaph/rptc-workflow
/plugin install rptc

# Start building
/rptc:feat "your feature description"
```

### Codex

Install or enable the RPTC plugin from the Codex plugin directory, then ask for
the same workflow intent in chat:

```text
Use RPTC to implement "your feature description".
Use RPTC to fix "bug description".
Run an RPTC verification pass.
```

Claude exposes `/rptc:*` as plugin slash commands. Codex does not expose these as custom slash commands; the `rptc-workflow` skill maps the same intents to Codex-native tools.

That's it. The unified feature workflow handles everything. For complex features needing continuous review during implementation, use the team workflow intent. For complex bugs where the root cause is unclear, use the team-based bug fixing intent.

---

## Philosophy: You Are the Project Manager

**This workflow puts YOU in control.**

- Claude or Codex is your **collaborative partner**, not the decision maker
- You have **final sign-off** on all major decisions
- **Explicit approvals** required at key decision points

**Your authority includes:**

- Selecting the planning approach (Minimal, Clean, or Pragmatic)
- Approving the implementation plan
- Reviewing quality gate findings
- Deciding what to ship

---

## The Unified `/rptc:feat` Command

### Overview

For Claude, `/rptc:feat` is RPTC's primary slash command. For Codex, the primary entrypoint is the `rptc-workflow` skill through chat intent. Both represent the same feature workflow:

```text
/rptc:feat "feature description"
    ↓
Phase 1: Discovery (codebase exploration)
    ↓
Branch Strategy (current branch or new git worktree)
    ↓
Phase 2: Architecture (you select approach)
    ↓
Phase 3: Implementation
    → Route A (non-code): Direct execution
    → Route B (code): TDD with smart batching
    ↓
Phase 4: Quality Verification (report-only checks; Claude may use command-defined agents; Codex delegates or parallelizes only with provider policy and explicit user approval)
    ↓
Phase 5: Complete (summary)
```

### Phase 1: Discovery

**Goal**: Understand what to build and existing patterns.

**What happens:**
1. Creates initial provider task tracker entries
2. Performs exploration; Claude may launch 2-3 parallel exploration agents, while Codex runs discovery in the main context unless the user explicitly approves parallel agents:
   - Feature Discovery: Entry points, core files, boundaries
   - Architecture Analysis: Layers, patterns, cross-cutting concerns
   - Code Flow Tracing: Call chains, data flow, dependencies
3. Optional web research for unfamiliar topics
4. Summarizes findings: patterns found, files to modify, dependencies

**Agents used:** `rptc:research-agent` with code-explorer methodology

**After Discovery:** The workflow continues to Branch Strategy (current branch or new worktree), then Phase 2. If you have multiple independent features or want real-time team-based feedback, use the active provider's team workflow intent (Claude: `/rptc:feat-team`; Codex: `rptc-workflow` chat intent, with `rptc:agent-teams` only after explicit delegation approval).

### Phase 2: Architecture

**Goal**: Design the implementation approach with your approval.

**What happens:**
1. Enters provider planning context
2. Produces 3 planning perspectives; Claude may use parallel plan agents, while Codex stays in the main context unless the user explicitly approves parallel agents:
   - **Minimal**: Smallest change possible, reuses existing code, fast but may accumulate tech debt
   - **Clean**: Maintainability-focused, elegant abstractions, takes longer but easier to extend
   - **Pragmatic**: Balanced approach, good enough architecture without over-engineering
3. Presents all 3 approaches with recommendations
4. **You select** which approach fits your needs
5. Tracks the selected plan in the provider-native plan record
6. **You approve** the plan using the provider approval mechanism

**Roles used:** `rptc:architect-agent` planning methodology for 3 perspectives; Claude may parallelize, while Codex stays in the main context unless explicit delegation approval exists

### Phase 3: Implementation

**Goal**: Execute the plan using the appropriate method for the task type.

**Task Classification** determines the route:
- **Code tasks** (`.ts`, `.js`, `.py`, source files): Route B (TDD)
- **Non-Code tasks** (`.md`, `.json`, config, docs): Route A (Direct)

#### Route A: Non-Code Tasks (Direct Execution)

For documentation, config, and non-code changes:
1. Main context executes steps directly
2. No TDD overhead for non-code work
3. Proceeds to Phase 4

#### Route B: Code Tasks (TDD with Smart Batching)

**Smart Batching** combines related steps for efficiency:
- Groups steps by file cohesion and dependencies
- Claude may run independent batches according to command-defined agent behavior; Codex delegates or parallelizes only when provider policy and explicit user approval allow it
- Maintains strict RED → GREEN → REFACTOR discipline
- ~40% token reduction vs. sequential execution

**What happens:**
1. Extracts steps from approved plan
2. Analyzes dependencies between steps
3. Groups into batches based on:
   - File cohesion (steps targeting same files)
   - Sequential chains (step N+1 depends only on N)
   - Size threshold (combined lines < 150)
4. For each batch, routes work to the TDD executor; Codex uses the main context unless the user explicitly approved delegation:
   - RED: Write tests for all steps in batch
   - GREEN: Implement minimal code to pass
   - REFACTOR: Improve while keeping tests green
5. Independent batches execute sequentially or, in Claude, according to command-defined agent behavior; Codex delegates or parallelizes only when provider policy and explicit user approval allow it
6. Updates progress tracking as batches complete

**Role used:** `rptc:tdd-agent` methodology for code tasks; Codex delegates to a subagent only when explicitly approved

### Phase 4: Quality Verification

**Goal**: Review changes and create fix list for main context.

**Mode**: Report-only. Agents DO NOT make changes—they report findings.

**What happens:**
1. Collects all files modified during Implementation phase
2. Runs ALL THREE verification roles; Claude may launch verification agents in parallel, while Codex runs report-only checks in the main context unless the user explicitly approved parallel agents:
   - **Code Review Agent**: Complexity, KISS/YAGNI violations, dead code, readability
   - **Security Agent**: Input validation, auth checks, injection vulnerabilities, data exposure
   - **Documentation Agent**: README updates, API doc changes, inline comment accuracy
3. Consolidates findings with confidence scoring (only shows ≥80 confidence)
4. Creates tasks with findings for main context to address
5. **Main context handles fixes**:
   - Simple fixes: Applied directly
   - Structural changes: Shown to you for approval

**Roles used:** `rptc:code-review-agent` + `rptc:security-agent` + `rptc:docs-agent` (report-only; parallel only when provider policy and user approval allow it)

### Phase 5: Complete

**Goal**: Summarize what was built.

**What happens:**
1. Marks provider task tracker entries complete
2. Outputs summary:
   - Files created/modified
   - Tests added
   - Key implementation decisions
   - Any remaining tracked tasks or known issues
3. Ready for the active provider's RPTC commit workflow (Claude: `/rptc:commit`; Codex: commit chat intent)

---

## Supporting Commands

### `/rptc:research "topic"`

**Purpose**: Standalone research and discovery.

**When to use:**
- Exploring unfamiliar topics before building
- Need deep understanding before starting a feature
- Want to save research findings for reference

**How it works:**
1. Interactive discovery through questions
2. Codebase exploration for existing patterns
3. Optional web research (with permission)
4. Presents findings inline
5. Optional save to `docs/research/` (HTML, Markdown, or both)

### `/rptc:commit [pr]`

**Purpose**: Verify and ship changes.

**When to use:**
- After completing feature implementation
- Ready to commit and optionally create PR

**How it works:**
1. Runs affected tests (blocks if any fail)
2. Validates coverage (80%+ target)
3. Generates conventional commit message
4. Creates commit
5. Optional: Creates pull request (with `pr` argument)

### `/rptc:verify [path]`

**Purpose**: Run quality verification agents on demand.

**When to use:**
- After any code change, independent of `/rptc:feat` or `/rptc:fix`
- To verify specific areas or the entire application
- As a standalone quality check before shipping

**How it works:**
1. Determines scope (default: uncommitted changes via `git diff`)
2. Asks which agents to run: Full (all 3), Code + Security, or Docs only
3. Runs selected verification roles in report-only mode; Claude may use command-defined agents, while Codex delegates or parallelizes only when provider policy and explicit user approval allow it
4. Consolidates findings and applies fixes via provider task tracking

### `/rptc:verify-loop [path]`

**Purpose**: Run quality verification agents in a convergence loop until all report 0 findings.

**When to use:**
- After implementation, when you want a fully clean result rather than a single-pass report
- When iterating on fixes and want auto-convergence with a safety guard

**How it works:**
1. Determines scope once (default: uncommitted changes via `git diff`)
2. Asks which agents to run: Full (all 3), Code + Security, or Docs only
3. Runs selected verification roles each iteration; Claude may use command-defined agents, while Codex delegates or parallelizes only when provider policy and explicit user approval allow it; auto-fixes Tier 2-4 findings
4. Asks user approval before Tier 1 changes (architecture, security, breaking API, structural refactoring)
5. Loops until all agents return 0 findings, or exits on stagnation, max iterations, or user skip

### `/rptc:config`

**Purpose**: Configure RPTC in your provider project context (`CLAUDE.md` for Claude, `AGENTS.md` for Codex).

**When to use:**
- First time setting up RPTC in a project
- After updating the RPTC plugin to sync configuration
- To verify project is properly configured

**How it works:**
1. Detects current RPTC configuration state in the provider context file
2. Prompts for verification mode preference (automatic/all/minimal)
3. Inserts or updates the RPTC configuration section at the top of the provider context file
4. Preserves user customizations (verification mode, project-specific notes)
5. Cleans up legacy/orphaned RPTC content if detected

**Note:** `/rptc:feat` and `/rptc:fix` will suggest running `/rptc:config` if no RPTC configuration is found in your project.

### `/rptc:feat-team "description"`

**Purpose**: Team-based feature development with 4 persistent roles.

**When to use:**
- Complex features that benefit from continuous review during implementation
- When you want the architect to monitor plan adherence in real-time
- When you want code quality, security, and docs feedback after every implementation step (not just at the end)

**How it works:**
1. Creates or coordinates 4 persistent roles: researcher, architect, implementer (TDD), reviewer. Claude uses Agent Teams; Codex enters through the `rptc-workflow` chat intent and may use `rptc:agent-teams` only after explicit delegation approval.
2. Researcher explores the codebase and passes findings to the architect role through the provider coordination channel
3. Architect creates an implementation plan; Team Lead presents it to you for approval
4. After approval, the implementer executes each step using TDD
5. After every step, both the architect (plan adherence) and reviewer (quality/security/docs) review the changes and send feedback
6. The implementer addresses all feedback — including nits — before proceeding to the next step
7. After all steps complete, the architect and reviewer collaborate on a final holistic review of all changes together, catching cross-cutting issues that per-step reviews miss
8. The implementer addresses any final findings, then Team Lead collects reports and presents a summary

**Agents used:** `rptc:research-agent` + `rptc:architect-agent` + `rptc:tdd-agent` + `rptc:review-agent` (Claude: persistent team messaging; Codex: main-session coordination and completion reports)

**Key difference from `/rptc:feat`:** In `/rptc:feat`, verification happens once at the end (Phase 4). In `/rptc:feat-team`, verification happens continuously during implementation — every step is reviewed before the next one begins.

### `/rptc:fix-team "bug description"`

**Purpose**: Team-based bug fixing with 4 persistent roles, adapted for root cause analysis and regression testing.

**When to use:**
- Complex bugs where the root cause is unclear
- Bugs that may cross file/module boundaries
- Bugs where symptom treatment is a real risk (and you want an architect continuously challenging the fix)
- When you want regression coverage verified alongside the fix

**How it works:**
1. Creates or coordinates 4 persistent roles: researcher, architect, implementer (TDD), reviewer. Claude uses Agent Teams; Codex enters through the `rptc-workflow` chat intent and may use `rptc:agent-teams` only after explicit delegation approval.
2. Researcher reproduces the bug, maps the failure path, and assesses impact; passes findings to the architect role through the provider coordination channel
3. Architect applies 5 Whys methodology to identify the root cause and designs a minimal fix with regression test strategy; Team Lead presents plan to you for approval
4. After approval, the implementer writes a regression test FIRST that reproduces the bug (must fail against the broken code), then applies the minimal fix
5. After every step, the architect checks for symptom treatment (guards against shallow fixes) and the reviewer checks code quality, security, docs, AND regression coverage
6. The implementer addresses all feedback before proceeding
7. After the fix is complete, the architect and reviewer collaborate on a final regression review: did we address the root cause? Are related code paths also covered? Does the regression test suite prevent this class of bug?
8. The implementer addresses any final findings, then Team Lead collects reports and presents a summary

**Agents used:** `rptc:research-agent` + `rptc:architect-agent` + `rptc:tdd-agent` + `rptc:review-agent` (Claude: persistent team messaging; Codex: main-session coordination and completion reports)

**Key difference from `/rptc:fix`:** Sequential `/rptc:fix` applies the fix and then verifies once. `/rptc:fix-team` adds continuous root cause guardianship — the architect challenges every step to ensure the fix addresses the cause rather than just the symptom, and the reviewer tracks regression coverage alongside quality.

### `/rptc:structure`

**Purpose**: Codebase structure analysis and refactoring.

**When to use:**
- Analyzing or restructuring project layout
- Evaluating codebase organization patterns
- Planning structural refactoring

**How it works:**
1. Analyzes current project structure
2. Identifies structural patterns and issues
3. Recommends improvements based on structure-methodology

### `/rptc:sync-prod-to-tests "[directory]"`

**Purpose**: Sync tests to production code.

**When to use:**
- Tests are out of sync with production code
- Need to verify test-production alignment
- Periodic test maintenance

**How it works:**
1. **Analysis phase** (`rptc:test-sync-agent`):
   - Multi-layer confidence scoring (naming, directory, imports, semantic, intent)
   - 4-level sync verification
   - Structured mismatch reports
2. **Fix phase** (`rptc:test-fixer-agent`):
   - 4 fix scenarios: update, add, create, assertion fix
   - Routes test generation through the provider-approved TDD path (Claude: `rptc:tdd-agent`; Codex: main context unless explicit delegation approval exists)
   - Retry logic for complex cases

---

## Architecture Deep Dive

### Native Planning

RPTC uses the provider's native planning mechanism:
- Claude plans are stored in `~/.claude/plans/`
- Codex plans are tracked with `update_plan` and chat approval unless a project plan file is requested
- No `.rptc/` workspace required
- No configuration files needed

### Agent Delegation Pattern

Claude commands delegate to specialized agents using the Task tool and `claude/agents`. Codex uses the `rptc-workflow` skill mapping plus role-definition references in `agents/`; it may use `spawn_agent` only when the user explicitly permits delegation.

```
Use Task tool with subagent_type="rptc:[agent-name]":

## Context
[Feature description, relevant findings]

## Your Task
[Specific work for this agent]

## Output Required
[Expected deliverable format]
```

For Codex, send the same role intent through `spawn_agent` only after explicit delegation approval. Include the assigned role, task, file ownership boundaries, and output format in the spawn prompt. Codex does not provide Claude Team inbox semantics, so the main session coordinates subagent work.

### Provider-Aware Execution

RPTC uses the execution model supported by the active provider:
- **Discovery**: Claude may run 2-3 exploration agents simultaneously; Codex stays in the main context unless explicit delegation approval exists
- **Architecture**: Claude may generate 3 plan perspectives in parallel; Codex presents the same perspectives from the main context unless explicit delegation approval exists
- **TDD**: Independent batches can be delegated only when provider policy and user approval allow it
- **Quality Verification**: Code Review, Security, and Documentation roles report findings; parallel execution is provider- and approval-dependent

### Report-Only Verification System

Quality verification agents analyze code and report findings—they do NOT make changes.

| Confidence | Action |
|------------|--------|
| ≥90% | High priority finding, reported first |
| 80-89% | Medium priority finding, reported |
| <80% | Skipped (below confidence threshold) |

Main context receives findings and handles all fixes with user approval using provider task tracking.

---

## Specialist Agents

### Research Agent (`rptc:research-agent`)

**Purpose**: Research through web search and codebase exploration

**Modes:**
- **Mode A (Codebase)**: 4-phase code-explorer methodology
- **Mode B (Web)**: Consults 20+ sources with cross-verification
- **Mode C (Hybrid)**: Combines both with gap analysis

### Architect Agent (`rptc:architect-agent`)

**Purpose**: Create comprehensive TDD-ready implementation plans

**Capabilities:**
- Detailed test strategies before implementation steps
- File change mapping
- Dependency and risk identification
- Measurable acceptance criteria

### TDD Agent (`rptc:tdd-agent`)

**Purpose**: Execute strict RED-GREEN-REFACTOR cycle

**Features:**
- Batch mode for multiple steps
- Smart test allocation based on complexity
- Flexible testing guide for AI-generated code
- SOP integration

### Code Review Agent (`rptc:code-review-agent`)

**Purpose**: Code review for efficiency issues (report-only)

**Focus areas:**
- Cyclomatic complexity (>10 per function)
- Cognitive complexity (>15)
- KISS/YAGNI violations
- Dead code detection

**Mode**: Reports findings only—main context handles fixes

### Security Agent (`rptc:security-agent`)

**Purpose**: Security review for vulnerabilities (report-only)

**Coverage:**
- OWASP Top 10 vulnerabilities
- Input validation gaps
- Authentication/authorization issues
- Data exposure risks

**Mode**: Reports findings only—main context handles fixes

### Test Sync Agent (`rptc:test-sync-agent`)

**Purpose**: Analyze test-production relationships

**Capabilities:**
- 5-layer confidence scoring
- 4-level sync verification
- Structured mismatch reports

### Test Fixer Agent (`rptc:test-fixer-agent`)

**Purpose**: Repair test files through the active provider workflow

**Scenarios:**
- Update existing tests
- Add missing test cases
- Create new test files
- Fix failing assertions

### Documentation Agent (`rptc:docs-agent`)

**Purpose**: Sync documentation with code changes

**Capabilities:**
- Diff-driven analysis
- Confidence-based routing
- Multi-document consistency

### Review Agent (`rptc:review-agent`)

**Purpose**: Unified quality reviewer combining code review, security, and documentation checks

**When used:** `/rptc:feat-team` and `/rptc:fix-team` (runs continuously alongside TDD agent)

**Capabilities:**
- All three review domains in a single pass per file (code quality, security, docs)
- Provider-specific coordination: Claude team messaging when available; Codex parent-session coordination through subagent completion reports
- Categorized urgency: blocking (fix before next step), warning (fix before completion), nit (fix before next step)
- Confidence threshold ≥80% (same as individual review agents)

**Mode**: Report-only — sends findings through the provider coordination channel, never modifies code

---

## Best Practices

### Feature Development

1. **Start with the provider feature entrypoint** - Claude: `/rptc:feat`; Codex: ask for the RPTC feature intent
2. **Select Pragmatic** for most features - It's the balanced default
3. **Trust smart batching** - Let the system optimize TDD execution
4. **Review quality findings** - Focus on high-confidence issues

### When to Use Standalone Research

- **Unfamiliar technology**: Research OAuth2 before implementing auth
- **Complex domain**: Research payment processing before building checkout
- **Multiple approaches**: Research to compare options before committing

### TDD Discipline (Code Tasks)

**Note**: TDD applies to code tasks only. Non-code tasks (docs, config) execute directly.

1. **Tests define behavior** - Write what you want, not what exists
2. **Minimal implementation** - Just enough to pass tests
3. **Refactor with confidence** - Tests catch regressions
4. **All tests must pass** - Never commit broken tests

### Quality Verification

- **Review high-confidence findings** (≥90%) - These are clear issues
- **Consider medium-confidence findings** (80-89%) - Verify impact before fixing
- **Main context handles all fixes** - Agents report, you decide what to address

---

## Troubleshooting

### Q: Feature is too complex for one session?

Break the feature into smaller, manageable steps:
- Use `/rptc:research` to explore and understand the scope
- Plan implementation in phases with clear boundaries
- Each phase should be completable in one session
- Resume by referencing the plan and picking up where you left off

### Q: Tests failing after implementation?

1. Check if tests match current implementation
2. Use the provider's RPTC test-sync workflow to analyze alignment
3. Repair mismatches in the active provider workflow; Codex stays in the main context unless explicit delegation approval exists

### Q: Quality verification found many issues?

1. Focus on high-confidence findings (≥90) first
2. Review medium-confidence findings (80-89) for context
3. Address findings via provider task tracking; main context handles all changes

### Q: Plan approach doesn't fit?

You can ask for modifications:
- "Make this more minimal"
- "Add more abstraction for extensibility"
- "Focus on performance"

---

## Reference

### Available SOPs

- `testing-guide.md` - Testing frameworks and TDD guidance
- `flexible-testing-guide.md` - Flexible assertions for AI-generated code
- `architecture-patterns.md` - Architecture and design patterns
- `frontend-guidelines.md` - Frontend design and accessibility
- `git-and-deployment.md` - Git workflow and CI/CD
- `languages-and-style.md` - Language conventions
- `security-and-performance.md` - Security practices
- `post-tdd-refactoring.md` - Refactoring checklist
- `todowrite-guide.md` - Provider task tracking patterns
- `test-sync-guide.md` - Test synchronization

### User-Facing Skills

| Skill | Purpose |
|-------|---------|
| `rptc-workflow` | Codex-native RPTC chat-intent adapter for feature, fix, research, verify, structure, and commit workflows |
| `agent-teams` | Provider-aware delegation for batch/multi-feature work |
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
| `structure-methodology` | architect-agent, code-review-agent, review-agent | Codebase structure analysis, refactoring patterns, project layout guidance |
| `docs-methodology` | docs-agent, review-agent | 8-step workflow, AI context file policy, anti-patterns (incl. context-file stuffing), special cases |
| `research-methodology` | research-agent | 3 research modes, mode selection logic |
| `security-methodology` | security-agent, review-agent | Finding categories, OWASP Top 10, confidence scoring |
| `tdd-agent-methodology` | tdd-agent | Batch execution, RED-GREEN-REFACTOR-VERIFY cycle |
| `test-fixer-methodology` | test-fixer-agent | Approval-aware execution, 5 fix scenarios |
| `test-sync-methodology` | test-sync-agent | 5-phase analysis, classification decision tree |

---

## Summary

RPTC provides a systematic development workflow that puts you in control:

1. **Feature workflow entrypoint**: Claude `/rptc:feat "description"`; Codex `rptc-workflow` chat intent
2. **You select the approach**: Minimal, Clean, or Pragmatic
3. **Task-appropriate execution**: TDD for code, direct execution for non-code
4. **Report-only quality gates**: Agents report, main context fixes
5. **Ship with confidence**: Claude `/rptc:commit [pr]`; Codex RPTC commit chat intent

The workflow handles complexity while keeping you as the decision maker.
