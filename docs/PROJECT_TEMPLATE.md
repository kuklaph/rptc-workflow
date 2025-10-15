# RPTC Workflow Project

> **NOTE**: This file is auto-created at `.rptc/CLAUDE.md` when you run `/rptc:admin:init`.
> If you have a project root `CLAUDE.md`, the init command automatically adds a reference to this file.

---

## Tech Stack

- **Language**: [Your Language]
- **Framework**: [Your Framework]
- **Database**: [Your Database]
- **Testing**: [Your Test Framework]

## Essential Commands

```bash
# Development
[dev command]      # Start development server
[build command]    # Production build
[test command]     # Run all tests

# RPTC Workflow
/rptc:research "topic"        # Interactive discovery & brainstorming
/rptc:plan "feature"          # Collaborative planning with Master Planner
/rptc:tdd "@plan.md"          # TDD implementation with quality gates
/rptc:commit [pr]             # Verify and ship (optional PR)

# Helpers
/rptc:helper:catch-up-quick          # Quick context (2 min)
/rptc:helper:catch-up-med            # Medium context (5-10 min)
/rptc:helper:catch-up-deep           # Deep analysis (15-30 min)
/rptc:helper:update-plan "@plan.md"  # Modify existing plan
/rptc:helper:resume-plan "@plan.md"  # Resume from previous session
```

## RPTC Workflow Philosophy

**You are the PROJECT MANAGER. Claude is your collaborative partner.**

Every feature follows this workflow:

**RESEARCH** → Interactive discovery with brainstorming
**PLAN** → Collaborative design with Master Feature Planner
**TDD** → Test-driven implementation with quality gates
**COMMIT** → Comprehensive verification before shipping

### Your Role as PM

- ✅ Final decision maker on all major choices
- ✅ Sign-off authority on research, plans, and implementation
- ✅ Approve delegation to Master Specialist Agents
- ✅ Review and approve all quality gates

### Claude's Role

- 🤝 Brainstorming partner and questioner
- 🔍 Discovery facilitator (asks probing questions)
- 📋 Planning coordinator (works with Master Planner)
- 🧪 TDD executor (strict test-first approach)
- 🎯 Quality gate manager (Efficiency & Security reviews)

## The RPTC Process

### 1. Research Phase (`/rptc:research "topic"`)

**Interactive Discovery**:

- Claude asks probing questions until understanding is solid
- Explores codebase for patterns and reusable code
- Optional web research (with your approval)
- Identifies gotchas and best practices
- **YOU approve** research before it's saved

**Master Web Research Sub Agent** (optional, with permission):

- Finds best practices and implementation examples
- Identifies common pitfalls
- Recommends libraries/frameworks

### 2. Planning Phase (`/rptc:plan "feature"` or `@research.md`)

**Collaborative Planning**:

- Claude creates initial plan scaffold
- Asks clarifying questions
- **YOU approve** sending to Master Feature Planner
- Master Planner creates comprehensive TDD-ready plan
- **YOU review and approve** final plan before saving

**Master Feature Planner Sub Agent** (with permission):

- Creates detailed implementation steps
- Designs comprehensive test strategy
- Maps all file changes
- Identifies risks and dependencies

### 3. TDD Phase (`/rptc:tdd "@plan.md"`)

**Strict Test-Driven Development**:

- For each step: RED (tests first) → GREEN (implementation) → REFACTOR
- Auto-iteration on test failures (max 10 per step)
- After implementation complete:
  - **YOU approve** Master Efficiency Agent review
  - **YOU approve** Master Security Agent review
- **YOU approve** final completion

**Master Efficiency Agent** (with permission):

- Removes dead code and unused imports
- Simplifies overly complex logic
- Improves readability
- Ensures KISS and YAGNI principles

**Master Security Agent** (with permission):

- Identifies security vulnerabilities
- Validates input sanitization
- Reviews auth/authorization
- Fixes security issues

### 4. Commit Phase (`/rptc:commit [pr]`)

**Comprehensive Verification**:

- Full test suite (BLOCKS if any fail)
- Coverage validation (80%+ target)
- Code quality checks
- Generates conventional commit message
- Optional PR creation

## Core Principles

### TDD (Non-Negotiable)

1. **Write tests FIRST** - Always, no exceptions
2. **RED → GREEN → REFACTOR** - The sacred cycle
3. **Auto-iteration on failures** - Claude fixes until passing (max 10)
4. **Never commit broken tests** - Enforced by hooks

### PM Approval Gates

1. **Research findings** - Explicit approval before saving
2. **Plan creation** - Approval to delegate to Master Planner
3. **Final plan** - Approval before saving plan
4. **Quality gates** - Approval for Efficiency/Security agents
5. **TDD completion** - Approval before marking complete

### Master Specialist Agents

When you approve delegation, specialized agents provide expert analysis:

- **Master Web Research Agent**: Best practices and implementation patterns
- **Master Feature Planner**: Comprehensive TDD-ready plans
- **Master Efficiency Agent**: Code optimization and simplification
- **Master Security Agent**: Vulnerability assessment and fixes

## Workflow Decision Tree

```text
Is it a bug fix?
  └─ Yes → /rptc:tdd "bug description" (skip research/plan)

Is it a simple feature in familiar code?
  └─ Yes → /rptc:plan "feature" (skip research)

Is it complex or unfamiliar?
  └─ Yes → /rptc:research "topic" → /rptc:plan → /rptc:tdd

Need context first?
  └─ /rptc:helper:catch-up-[quick|med|deep]

Need to update a plan?
  └─ /rptc:helper:update-plan "@plan.md"

Resuming previous work?
  └─ /rptc:helper:resume-plan "@plan.md"
```

## Context Helpers

### `/rptc:helper:catch-up-quick` (2 min)

- Project basics
- Recent commits
- Current branch status
- Use for: Quick questions, small fixes

### `/rptc:helper:catch-up-med` (5-10 min)

- Architecture understanding
- Recent history (15 commits)
- Existing research/plans
- Use for: Implementation work, code understanding

### `/rptc:helper:catch-up-deep` (15-30 min)

- Complete architecture analysis
- Full dependency analysis
- All documentation review
- Code pattern analysis
- Use for: Complex work, unfamiliar projects

## File Organization

### Your Project Structure

```text
your-project/
├── .rptc/                       # RPTC workspace
│   ├── CLAUDE.md                # This file - RPTC workflow instructions
│   ├── research/                # Active research findings
│   │   └── [topic].md
│   ├── plans/                   # Active/completed plans
│   │   └── [feature].md
│   └── archive/                 # Old plans (optional)
│
├── docs/                        # Permanent documentation
│   ├── architecture/            # Auto-created by Doc Specialist
│   ├── patterns/                # Auto-created by Doc Specialist
│   └── api/                     # Auto-created by Doc Specialist
│
├── .claude/
│   ├── settings.json            # Project settings
│   ├── settings.local.json      # Local overrides (gitignored)
│   └── sop/                     # Project SOPs (optional overrides)
│       └── testing-guide.md     # Overrides plugin default
│
├── CLAUDE.md                    # Your project instructions (auto-includes RPTC reference)
└── src/                         # Your application code
```

**Project Root CLAUDE.md**: If you have a project root `CLAUDE.md`, the `/rptc:admin:init` command automatically adds an RPTC reference at the top, preserving your existing content below.

### Plugin Resources (Referenced, Not Copied)

The RPTC plugin provides these resources at the plugin root:

- **Commands**: `${CLAUDE_PLUGIN_ROOT}/commands/` - All `/rptc:*` commands
- **Agents**: `${CLAUDE_PLUGIN_ROOT}/agents/` - Master specialist agents
- **SOPs**: `${CLAUDE_PLUGIN_ROOT}/sop/` - Default SOPs (fallback)
- **Templates**: `${CLAUDE_PLUGIN_ROOT}/templates/` - Plan and research templates

### SOP Fallback Chain

SOPs are resolved in this order (highest priority first):

1. `.rptc/sop/[name].md` - Project-specific overrides
2. `~/.claude/global/sop/[name].md` - User global defaults
3. `${CLAUDE_PLUGIN_ROOT}/sop/[name].md` - Plugin defaults

Use `/rptc:admin:sop-check [name]` to verify which SOP will be loaded.

## Quality Standards

### Testing Requirements

- **Minimum coverage**: 80% overall, 100% critical paths
- **Test types**: Unit, Integration, E2E
- **Test-first**: ALWAYS write tests before implementation

### Code Quality

- No debug code (console.log, debugger) in commits
- No `.env` files committed
- Conventional commit messages required
- All tests must pass before commit

### Security

- Input validation required
- No secrets in code
- Authentication/authorization validated
- Security agent review for sensitive features

## Important Reminders

- **You are the decision maker** - Claude facilitates and executes
- **Always ask for permission** - Master agents require your approval
- **Explicit sign-offs required** - No assumptions, clear approvals
- **Plans are living documents** - Update with `/rptc:helper:update-plan`
- **Tests first, always** - Non-negotiable TDD principle
- **Quality gates matter** - Efficiency and Security reviews catch issues

## Example Complete Workflow

```bash
# 1. Start with context
> /rptc:helper:catch-up-med

# 2. Research phase
> /rptc:research "user authentication"
[Interactive Q&A, codebase exploration]
[Optional web research with approval]
[Present findings, get approval, save]

# 3. Planning phase
> /rptc:plan "@user-authentication.md"
[Create scaffold, clarifying questions]
[Get approval for Master Planner]
[Master Planner creates detailed plan]
[Review, approve, save]

# 4. TDD implementation
> /rptc:tdd "@user-authentication.md"
[Execute each step: RED → GREEN → REFACTOR]
[Get approval for Efficiency Agent]
[Get approval for Security Agent]
[Get approval for completion]

# 5. Commit & ship
> /rptc:commit pr
[Comprehensive verification]
[Create commit and PR]
[Workflow complete!]
```

---

**Remember**: This workflow puts YOU in control while leveraging Claude's capabilities as a collaborative partner and executor.
