# RPTC Workflow Guide

## Research → Plan → TDD → Commit with PM Collaboration

---

## Quick Start

```bash
# Install the plugin
/plugin marketplace add https://github.com/kuklaph/rptc-workflow
/plugin install rptc

# Start building
/rptc:feat "your feature description"
```

That's it! The unified `/rptc:feat` command handles everything.

---

## Philosophy: You Are the Project Manager

**This workflow puts YOU in control.**

- Claude is your **collaborative partner**, not the decision maker
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

The `/rptc:feat` command is RPTC's primary interface. It combines what used to be separate commands into one seamless flow:

```text
/rptc:feat "feature description"
    ↓
Phase 1: Discovery (codebase exploration)
    ↓
Phase 2: Architecture (you select approach)
    ↓
Phase 3: Implementation
    → Route A (non-code): Direct execution
    → Route B (code): TDD with smart batching
    ↓
Phase 4: Quality Review (report-only, parallel agents)
    ↓
Phase 5: Complete (summary)
```

### Phase 1: Discovery

**Goal**: Understand what to build and existing patterns.

**What happens:**
1. Creates initial todo list tracking progress
2. Launches 2-3 parallel exploration agents (if needed):
   - Feature Discovery: Entry points, core files, boundaries
   - Architecture Analysis: Layers, patterns, cross-cutting concerns
   - Code Flow Tracing: Call chains, data flow, dependencies
3. Optional web research for unfamiliar topics
4. Summarizes findings: patterns found, files to modify, dependencies

**Agents used:** `rptc:research-agent` with code-explorer methodology

### Phase 2: Architecture

**Goal**: Design the implementation approach with your approval.

**What happens:**
1. Enters Claude's native plan mode
2. Launches 3 plan agents in parallel with different perspectives:
   - **Minimal**: Smallest change possible, reuses existing code, fast but may accumulate tech debt
   - **Clean**: Maintainability-focused, elegant abstractions, takes longer but easier to extend
   - **Pragmatic**: Balanced approach, good enough architecture without over-engineering
3. Presents all 3 approaches with recommendations
4. **You select** which approach fits your needs
5. Writes selected plan to plan file
6. **You approve** the plan via ExitPlanMode

**Agents used:** `rptc:architect-agent` (3 parallel instances)

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
- Runs batches in parallel when independent
- Maintains strict RED → GREEN → REFACTOR discipline
- ~40% token reduction vs. sequential execution

**What happens:**
1. Extracts steps from approved plan
2. Analyzes dependencies between steps
3. Groups into batches based on:
   - File cohesion (steps targeting same files)
   - Sequential chains (step N+1 depends only on N)
   - Size threshold (combined lines < 150)
4. For each batch, delegates to TDD executor:
   - RED: Write tests for all steps in batch
   - GREEN: Implement minimal code to pass
   - REFACTOR: Improve while keeping tests green
5. Parallel batches execute simultaneously
6. Updates progress tracking as batches complete

**Agents used:** `rptc:tdd-agent` (one per batch, code tasks only)

### Phase 4: Quality Review

**Goal**: Review changes and create fix list for main context.

**Mode**: Report-only. Agents DO NOT make changes—they report findings.

**What happens:**
1. Collects all files modified during Implementation phase
2. Launches ALL THREE review agents in parallel:
   - **Code Review Agent**: Complexity, KISS/YAGNI violations, dead code, readability
   - **Security Agent**: Input validation, auth checks, injection vulnerabilities, data exposure
   - **Documentation Agent**: README updates, API doc changes, inline comment accuracy
3. Consolidates findings with confidence scoring (only shows ≥80 confidence)
4. Creates TodoWrite with findings for main context to address
5. **Main context handles fixes**:
   - Simple fixes: Applied directly
   - Structural changes: Shown to you for approval

**Agents used:** `rptc:code-review-agent` + `rptc:security-agent` + `rptc:docs-agent` (parallel, report-only)

### Phase 5: Complete

**Goal**: Summarize what was built.

**What happens:**
1. Marks all todos complete
2. Outputs summary:
   - Files created/modified
   - Tests added
   - Key implementation decisions
   - Any remaining todos or known issues
3. Ready for `/rptc:commit`

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
1. Runs full test suite (blocks if any fail)
2. Validates coverage (80%+ target)
3. Generates conventional commit message
4. Creates commit
5. Optional: Creates pull request (with `pr` argument)

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
   - Delegates test generation to `rptc:tdd-agent`
   - Retry logic for complex cases

---

## Architecture Deep Dive

### Native Plan Mode

RPTC uses Claude's native plan mode for planning:
- Plans stored in `~/.claude/plans/`
- No `.rptc/` workspace required
- No configuration files needed

### Agent Delegation Pattern

Commands delegate to specialized agents using the Task tool:

```
Use Task tool with subagent_type="rptc:[agent-name]":

## Context
[Feature description, relevant findings]

## Your Task
[Specific work for this agent]

## Output Required
[Expected deliverable format]
```

### Parallel Execution

RPTC maximizes efficiency through parallelization:
- **Discovery**: 2-3 exploration agents run simultaneously
- **Architecture**: 3 plan perspectives generated in parallel
- **TDD**: Independent batches execute in parallel
- **Quality Review**: Optimizer and Security agents run together

### Report-Only Review System

Quality review agents analyze code and report findings—they do NOT make changes.

| Confidence | Action |
|------------|--------|
| ≥90% | High priority finding, reported first |
| 80-89% | Medium priority finding, reported |
| <80% | Skipped (below confidence threshold) |

Main context receives findings via TodoWrite and handles all fixes with user approval as needed.

---

## Specialist Agents

### Research Agent (`rptc:research-agent`)

**Purpose**: Research through web search and codebase exploration

**Modes:**
- **Mode A (Codebase)**: 4-phase code-explorer methodology
- **Mode B (Web)**: Consults 20+ sources with cross-verification
- **Mode C (Hybrid)**: Combines both with gap analysis

### Plan Agent (`rptc:architect-agent`)

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

**Purpose**: Auto-repair test files

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

---

## Best Practices

### Feature Development

1. **Start with `/rptc:feat`** - It handles complexity automatically
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

### Quality Review

- **Review high-confidence findings** (≥90%) - These are clear issues
- **Consider medium-confidence findings** (80-89%) - Verify impact before fixing
- **Main context handles all fixes** - Agents report, you decide what to address

---

## Troubleshooting

### Q: Feature is too complex for one session?

RPTC uses auto-handoff with dynamic prediction:
- 80% hard cap (160K tokens)
- Automatic checkpoint creation
- Resume in fresh context by referencing the plan

### Q: Tests failing after implementation?

1. Check if tests match current implementation
2. Use `/rptc:sync-prod-to-tests` to analyze alignment
3. Let Test Fixer agent repair mismatches

### Q: Quality review found many issues?

1. Focus on high-confidence findings (≥90) first
2. Review medium-confidence findings (80-89) for context
3. Address findings via TodoWrite—main context handles all changes

### Q: Plan approach doesn't fit?

You can ask for modifications:
- "Make this more minimal"
- "Add more abstraction for extensibility"
- "Focus on performance"

---

## Migration from Older Versions

### From v1.x/v2.x to v2.8.0+

**What changed:**
- Separate `/rptc:plan` + `/rptc:tdd` → Unified `/rptc:feat`
- Helper commands (6+) → Merged into `/rptc:feat` workflow
- `.rptc/` workspace → Not needed (uses native plan mode)
- `.claude/settings.json` config → Not needed (sensible defaults)
- SOP fallback chain → Plugin defaults only

**Migration steps:**
1. No action required for new features
2. Existing `.rptc/` directories can be deleted
3. Old plans can be referenced by path if needed

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
- `todowrite-guide.md` - Progress tracking patterns
- `test-sync-guide.md` - Test synchronization

### Skills

- `html-report-generator` - Convert research to HTML reports
- `discord-notify` - Real-time notifications
- `tdd-methodology` - TDD guidance in main context

---

## Summary

RPTC provides a systematic development workflow that puts you in control:

1. **One command for features**: `/rptc:feat "description"`
2. **You select the approach**: Minimal, Clean, or Pragmatic
3. **Task-appropriate execution**: TDD for code, direct execution for non-code
4. **Report-only quality gates**: Agents report, main context fixes
5. **Ship with confidence**: `/rptc:commit [pr]`

The workflow handles complexity while keeping you as the decision maker.
