# RPTC Workflow Guide

## Research → Plan → TDD → Commit with PM Collaboration

---

## Quick Start

```bash
# Install the workflow
bash setup-rptc-workflow.sh

# Start using it
/rptc:helper:catch-up-med                    # Get context
/rptc:research "topic to explore"   # Interactive discovery
/rptc:plan "@research.md"             # Collaborative planning
/rptc:tdd "@plan.md"                  # TDD implementation
/rptc:commit pr                       # Verify and ship
```

---

## Philosophy: You Are the Project Manager

**This workflow puts YOU in control.**

- Claude is your **collaborative partner**, not the decision maker
- You have **final sign-off** on all major decisions
- Claude **asks permission** before creating specialist agents
- **Explicit approvals** required at every phase transition

**Your authority includes**:

- ✅ Approving research findings
- ✅ Approving delegation to Master specialist agents
- ✅ Approving plans before implementation
- ✅ Approving quality gate reviews
- ✅ Approving final completion

---

## The Four Phases

### 1. Research Phase: `/rptc:research "topic"`

**Purpose**: Interactive discovery and brainstorming

**What happens**:

1. **Discovery Q&A**: Claude asks probing questions until solid understanding

   - Scope exploration
   - Requirement clarification
   - Risk identification
   - Best practice alignment
   - "Did you think about this?" prompts

2. **Codebase Exploration**: Searches for relevant patterns and reusable code

   - Related files identified
   - Patterns documented
   - Reusable components noted

3. **Optional Web Research**: Only with your permission

   - You approve delegation to Master Web Research Agent
   - Agent finds best practices and examples
   - Results integrated into findings

4. **PM Sign-Off**: You explicitly approve before research is saved

**Output**: `.rptc/research/[topic].md`

**When to use**:

- Complex or unfamiliar work
- Major architectural changes
- Need to understand existing patterns
- Want to explore best practices

**When to skip**:

- Simple bug fixes
- Familiar code changes
- Well-understood features

---

### 2. Planning Phase: `/rptc:plan "feature"` or `@research.md`

**Purpose**: Collaborative planning with test strategy

**What happens**:

1. **Context Loading**: Loads research (if exists) and project standards

2. **Initial Scaffolding**: Claude creates high-level plan structure

   - Feature overview
   - High-level steps (3-7 typically)
   - Initial test strategy thoughts

3. **Clarifying Questions**: Refines plan through Q&A

   - Step validation
   - Requirement clarification
   - Test strategy alignment
   - Technical decisions

4. **PM Approval for Master Planner**: You explicitly approve delegation

5. **Master Feature Planner**: Creates comprehensive TDD-ready plan

   - Detailed steps with tests defined first
   - Complete test strategy (happy path, edge cases, errors)
   - File creation/modification list
   - Dependencies and risks
   - Acceptance criteria

6. **Plan Review**: You review, request modifications, and approve

7. **PM Sign-Off**: Explicit approval before plan is saved

**Output**: `.rptc/plans/[name].md`

**When to use**:

- Medium to complex work items
- Unfamiliar implementation patterns
- Need test strategy design
- Want structured approach

**When to skip**:

- Trivial bug fixes
- Very simple changes
- Prototype/exploration code

---

### 3. TDD Phase: `/rptc:tdd "@plan.md"`

**Purpose**: Test-driven implementation with quality gates

**What happens**:

1. **Load Plan**: Reads implementation plan and extracts steps

2. **TDD Cycle for Each Step**:

   - **RED**: Write tests FIRST (happy path, edge cases, errors)
   - **GREEN**: Minimal implementation + auto-iteration (max 10 attempts)
   - **REFACTOR**: Improve code while keeping tests green
   - **VERIFY**: Run full suite, check coverage

3. **After All Tests Passing**:

   **Efficiency Gate** (with your approval):

   - You approve delegation to Master Efficiency Agent
   - Agent removes dead code, simplifies logic, improves readability
   - Ensures KISS and YAGNI principles
   - All tests must remain passing

   **Security Gate** (with your approval):

   - You approve delegation to Master Security Agent
   - Agent identifies vulnerabilities
   - Validates input sanitization, auth/authz
   - Fixes security issues, adds security tests
   - All tests must remain passing

4. **Final PM Sign-Off**: You explicitly approve TDD completion

5. **Plan Update**: Status changed to Complete (only after approval)

**Output**: Fully tested implementation with quality gates passed

**Key Principle**: Tests are ALWAYS written before implementation

---

### 4. Commit Phase: `/rptc:commit [pr]`

**Purpose**: Comprehensive verification before shipping

**What happens**:

1. **Test Verification**: Runs FULL test suite

   - **BLOCKS commit** if ANY test fails
   - Shows specific failures
   - Provides fix guidance

2. **Coverage Check**: Validates coverage (80%+ target)

   - Reports current coverage
   - Warns if below target (but allows)

3. **Code Quality**: Checks for issues

   - **BLOCKS** if `.env` files staged
   - **BLOCKS** if `console.log` in non-test files
   - **BLOCKS** if `debugger` statements
   - Warns for TODO/FIXME comments

4. **Linting & Type Checking**: Runs if available

   - Warns for errors (but allows commit)

5. **Commit Creation**: Generates conventional commit message

   - Analyzes diff for accurate message
   - Includes implementation summary, tests, coverage

6. **PR Creation** (if `pr` arg provided):
   - Pushes branch
   - Creates PR with detailed description
   - Links to research/plan docs

**Output**: Verified commit (and optional PR)

**Key Principle**: Quality is non-negotiable. Failures block commits.

---

## Helper Commands

### Context Catch-Up

Get project context at different depth levels:

#### `/rptc:helper:catch-up-quick` (2 minutes)

- Project basics (CLAUDE.md, package.json, README)
- Recent 5 commits
- Current branch status

**Use when**: Quick questions, small fixes, immediate tasks

#### `/rptc:helper:catch-up-med` (5-10 minutes)

- Architecture understanding
- Recent 15 commits with context
- Existing research/plans review
- Dependencies overview

**Use when**: Implementation work, understanding existing code

#### `/rptc:helper:catch-up-deep` (15-30 minutes)

- Complete architecture analysis
- Full git history review
- All documentation inventory
- Complete dependency analysis
- Code pattern analysis

**Use when**: Complex work, unfamiliar projects, major changes

### Plan Updates

#### `/rptc:helper:update-plan "@plan.md" "changes"`

Modify existing implementation plans:

**What happens**:

1. Loads existing plan
2. Understands requested changes (asks clarifying questions)
3. Drafts plan updates
4. Iterative refinement with you
5. Explicit PM approval before saving
6. Updates plan (preserves context, adds update log)

**Use when**:

- Requirements change mid-implementation
- New considerations discovered
- Test strategy needs adjustment
- Acceptance criteria evolve

---

## Master Specialist Agents

When you approve delegation, Claude creates specialized expert agents.

**Agent Definitions:**
Agent definitions are provided by the plugin at `${CLAUDE_PLUGIN_ROOT}/agents/`

These agents have specialized prompts and capabilities for specific tasks.

### Master Web Research Agent

**Purpose**: Find best practices and implementation examples

**Definition:** `${CLAUDE_PLUGIN_ROOT}/agents/master-web-research-agent.md`

**What it does**:

- Searches authoritative sources
- Identifies implementation patterns
- Lists common pitfalls and solutions
- Recommends libraries/frameworks
- Finds real-world examples

**When used**: During research phase (optional, with permission)

### Master Feature Planner

**Purpose**: Create comprehensive TDD-ready plans

**What it does**:

- Designs detailed implementation steps
- Creates complete test strategy (happy path, edge cases, errors)
- Maps all file changes
- Identifies dependencies and risks
- Defines measurable acceptance criteria

**When used**: During planning phase (with permission)

### Master Efficiency Agent

**Purpose**: Optimize code for simplicity and readability

**What it does**:

- Removes dead code and unused imports
- Simplifies overly complex logic
- Improves variable/function names
- Identifies over-engineering
- Ensures KISS and YAGNI principles
- **Keeps all tests passing**

**When used**: After TDD implementation (with permission)

### Master Security Agent

**Purpose**: Identify and fix security vulnerabilities

**What it does**:

- Audits for OWASP Top 10 vulnerabilities
- Validates input sanitization
- Reviews authentication/authorization
- Checks for sensitive data exposure
- Fixes security issues
- Adds security tests
- **Keeps all tests passing**

**When used**: After efficiency review (with permission)

---

## Workflow Patterns

### Pattern 1: Simple Bug Fix

```bash
# Skip research and planning, go straight to TDD
> /rptc:tdd "fix login error with special characters"

# Claude:
# - Creates quick plan
# - Writes test reproducing bug (RED)
# - Implements fix (GREEN + auto-iteration)
# - Refactors
# - [Optional quality gates with your approval]
# - Gets your sign-off

> /rptc:commit
```

**When**: Bug fixes, small isolated changes

---

### Pattern 2: Medium Work Item (Familiar Code)

```bash
# Skip research, create plan directly
> /rptc:plan "add user profile avatar upload"

# Claude:
# - Creates initial scaffold
# - Asks clarifying questions
# - You approve Master Feature Planner delegation
# - Presents comprehensive plan
# - You approve plan

> /rptc:tdd "@user-avatar-upload.md"

# Claude executes with quality gates (with your approval)

> /rptc:commit pr
```

**When**: Medium work items, familiar codebase, clear requirements

---

### Pattern 3: Complex Work (Full Workflow)

```bash
# Get context first
> /rptc:helper:catch-up-med

# Interactive research phase
> /rptc:research "payment processing integration"

# Claude:
# - Asks discovery questions (keeps asking until solid understanding)
# - Explores codebase
# - [Optional] You approve web research
# - Presents findings
# - You approve research

# Collaborative planning
> /rptc:plan "@payment-processing.md"

# Claude:
# - Creates scaffold
# - Asks clarifying questions
# - You approve Master Planner delegation
# - Presents detailed plan
# - You approve plan

# TDD implementation
> /rptc:tdd "@payment-processing.md"

# Claude:
# - Executes each step (RED → GREEN → REFACTOR)
# - You approve Efficiency Agent
# - You approve Security Agent
# - You approve completion

# Verify and ship
> /rptc:commit pr
```

**When**: Complex work, unfamiliar code, major changes

---

### Pattern 4: Update Existing Plan

```bash
# Mid-implementation, requirements change
> /rptc:helper:update-plan "@payment-processing.md" "add PayPal support"

# Claude:
# - Loads current plan
# - Asks clarifying questions about changes
# - Drafts updates
# - You review and approve

# Continue implementation with updated plan
> /rptc:tdd "@payment-processing.md"
```

**When**: Requirements evolve, new considerations discovered

---

## Decision Tree: Which Commands?

```text
Need context first?
├─ Quick context (2 min) → /rptc:helper:catch-up-quick
├─ Medium context (5-10 min) → /rptc:helper:catch-up-med
└─ Deep analysis (15-30 min) → /rptc:helper:catch-up-deep

Is it a bug fix?
└─ Yes → /rptc:tdd "bug description"

Is it a simple change in familiar code?
└─ Yes → /rptc:plan "description" → /rptc:tdd "@plan.md"

Is it complex or unfamiliar?
└─ Yes → /rptc:research "topic" → /rptc:plan "@research.md" → /rptc:tdd "@plan.md"

Need to modify existing plan?
└─ Yes → /rptc:helper:update-plan "@plan.md" "changes"

Resuming previous work?
└─ Yes → /rptc:helper:resume-plan "@plan.md"

Ready to ship?
└─ Yes → /rptc:commit [pr]
```

---

## Key Principles

### 1. TDD is Non-Negotiable

- Tests ALWAYS written before implementation
- RED → GREEN → REFACTOR cycle strictly followed
- Auto-iteration on failures (max 10 attempts)
- Never commit with failing tests (enforced)

### 2. PM Has Final Authority

- You approve all major decisions
- Explicit sign-offs required (no assumptions)
- You control specialist agent delegation
- You approve quality gate reviews

### 3. Ask Permission, Not Forgiveness

- Claude asks before creating sub-agents
- Claude asks before major changes
- Claude waits for explicit approvals
- No surprises, full transparency

### 4. Quality Gates Matter

- Efficiency review catches over-engineering
- Security review prevents vulnerabilities
- All tests must remain passing
- Code quality is maintained

### 5. Plans Are Living Documents

- Update as you learn (/rptc:helper:update-plan)
- Preserve context from research
- Track changes with update logs
- Reference in future work

---

## File Organization

```text
your-project/
├── .rptc/                     # Working directory (gitignored)
│   ├── research/              # Active research findings
│   │   ├── payment-processing.md
│   │   └── user-authentication.md
│   ├── plans/                 # Implementation plans
│   │   ├── payment-processing.md
│   │   └── user-authentication.md
│   └── archive/               # Completed work
│
├── .claude/
│   ├── sop/                   # Project SOP overrides (optional)
│   ├── settings.json
│   └── CLAUDE.md
│
├── docs/                      # Permanent documentation
│   ├── architecture/
│   ├── api/
│   └── patterns/
│
└── src/                       # Your application code
```

**Plugin provides** (not in your project):

- Commands: `${CLAUDE_PLUGIN_ROOT}/commands/`
- Agents: `${CLAUDE_PLUGIN_ROOT}/agents/`
- SOPs: `${CLAUDE_PLUGIN_ROOT}/sop/`
- Templates: `${CLAUDE_PLUGIN_ROOT}/templates/`

**Agent Location:**
`${CLAUDE_PLUGIN_ROOT}/agents/` - Agent definitions provide specialized capabilities for research, planning, and quality gates.

---

## Troubleshooting

### Q: Claude isn't asking enough questions during research

**A**: Remind Claude: "Keep asking questions until you have solid understanding"

### Q: Tests keep failing after 10 iterations

**A**: Test expectations might be wrong. Review test requirements and clarify.

### Q: I want to skip a quality gate

**A**: Type "skip" when asked for Efficiency or Security agent approval

### Q: Plan needs changes mid-implementation

**A**: Use `/rptc:helper:update-plan "@plan.md" "your changes"`

### Q: Forgot what we researched

**A**: Read `.rptc/research/[topic].md` or use `/rptc:helper:catch-up-med`

### Q: Resuming work after a break

**A**: Use `/rptc:helper:resume-plan "@plan.md"` for smart context restoration

### Q: Want to see what Master agents do

**A**: Check the detailed prompts in plugin command files (`${CLAUDE_PLUGIN_ROOT}/commands/*.md`)

---

## Success Metrics

After using this workflow:

- ✅ 80%+ test coverage maintained
- ✅ Zero bugs from untested code
- ✅ Clear documentation trail (research → plan → implementation)
- ✅ Efficient collaboration (you guide, Claude executes)
- ✅ Quality code (efficiency and security reviewed)
- ✅ Professional commits (conventional format, verified)
- ✅ Knowledge retention (plans as living docs)

---

## Next Steps

1. **Customize for your stack**:

   - Edit `.claude/CLAUDE.md` with your tech stack
   - Update test commands in settings

2. **Try a simple flow**:

   ```bash
   /rptc:plan "add calculator functionality"
   /rptc:tdd "@calculator-functionality.md"
   /rptc:commit
   ```

3. **Try a complex flow**:

   ```bash
   /rptc:helper:catch-up-med
   /rptc:research "complex topic"
   /rptc:plan "@complex-topic.md"
   /rptc:tdd "@complex-topic.md"
   /rptc:commit pr
   ```

4. **Read the command files**:
   - See detailed workflows in `${CLAUDE_PLUGIN_ROOT}/commands/*.md`
   - Understand Master agent prompts
   - Customize if needed

---

**Welcome to systematic, PM-controlled development with Claude as your collaborative partner!** 🚀
