# RPTC Workflow Project

> **NOTE**: This is a reference template for projects using RPTC workflow.

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

# RPTC Workflow (v2.8.0+)
/rptc:feat "feature description"     # Complete feature: Discovery → Plan → TDD → Verification
/rptc:research "topic"               # Standalone research (optional)
/rptc:verify [path]                  # Run quality verification agents on demand
/rptc:commit [pr]                    # Verify and ship (optional PR)
/rptc:sync-prod-to-tests "[dir]"     # Sync tests to production code
```

## RPTC Workflow Philosophy

**You are the PROJECT MANAGER. Claude is your collaborative partner.**

The unified `/rptc:feat` command handles the complete workflow:

**DISCOVERY** → Codebase exploration and pattern analysis
**ARCHITECTURE** → User-selected planning approach (Minimal/Clean/Pragmatic)
**TDD** → Test-driven implementation with smart batching
**QUALITY VERIFICATION** → Parallel Code Review, Security, and Documentation agents
**COMPLETE** → Summary and documentation

### Your Role as PM

- Final decision maker on all major choices
- Select planning approach (Minimal, Clean, or Pragmatic)
- Approve plan before implementation
- Review quality gate findings
- Decide what to ship

### Claude's Role

- Codebase exploration and pattern discovery
- Present 3 planning perspectives for your selection
- Execute strict TDD cycles
- Run parallel quality verification
- Summarize work completed

## The `/rptc:feat` Workflow

### Phase 1: Discovery

**Purpose**: Understand what to build and existing patterns.

- Launches 2-3 parallel exploration agents
- Analyzes existing code patterns
- Identifies files to modify and dependencies
- Optional web research for unfamiliar topics

### Phase 2: Architecture

**Purpose**: Design the implementation approach with user approval.

- Enters Claude's native plan mode
- Launches 3 plan agents with different perspectives:
  - **Minimal**: Smallest change, reuses existing code, fast delivery
  - **Clean**: Maintainability-focused, elegant abstractions, long-term value
  - **Pragmatic**: Balanced approach, good enough without over-engineering
- **You select which approach** fits your needs
- Plan saved to `~/.claude/plans/`

### Phase 3: Implementation

**Purpose**: Execute the plan using the appropriate method.

**Route A - Non-Code Tasks** (docs, config, markdown):
- Main context executes steps directly
- No TDD overhead for non-code work

**Route B - Code Tasks** (TDD with Smart Batching):
- Groups related steps into batches for efficiency
- For each step: RED → GREEN → REFACTOR
- Parallel execution of independent batches
- ~40% token reduction vs. sequential execution

### Phase 4: Quality Verification

**Purpose**: Review changes and create fix list (report-only).

- **Code Review Agent**: Complexity, KISS/YAGNI violations, dead code
- **Security Agent**: Input validation, auth checks, injection vulnerabilities
- **Documentation Agent**: README updates, API doc changes
- All three run in parallel, **report findings only**
- Main context handles fixes via TodoWrite

### Phase 5: Complete

**Purpose**: Summarize what was built.

- Files created/modified
- Tests added
- Key implementation decisions
- Ready for `/rptc:commit`

## Core Principles

### TDD (For Code Tasks)

**Note**: TDD applies to code tasks (source files). Non-code tasks (docs, config) execute directly without TDD.

1. **Write tests FIRST** - For all code changes
2. **RED → GREEN → REFACTOR** - The sacred cycle
3. **Auto-iteration on failures** - Agent fixes until passing
4. **Never commit broken tests** - Quality gate enforced

**When handling code changes directly** (not via `/rptc:feat`):
- **Load skill**: `tdd-methodology` - Provides surgical coding approach, context discovery, and detailed TDD phase guidance
- This ensures the same quality standards apply whether work is done by sub-agent or main context

### Planning Approaches

When `/rptc:feat` presents 3 planning approaches, consider:

| Approach | Best For | Trade-off |
|----------|----------|-----------|
| **Minimal** | Bug fixes, hotfixes, time-critical | May accumulate tech debt |
| **Clean** | Core features, long-lived code | Takes longer, more abstraction |
| **Pragmatic** | Most features (recommended default) | Balanced, pragmatic decisions |

### Quality Gates

- **Code Review Gate**: Catches over-engineering, enforces KISS/YAGNI
- **Security Gate**: Prevents vulnerabilities before they ship
- **Documentation Gate**: Ensures docs stay in sync with code
- All three run in parallel for speed
- **Report-only mode**: Agents report findings, main context handles fixes

## AI Coding Assistant Guidelines

**Purpose**: Guardrails for working with AI coding assistants to ensure generated code follows RPTC quality standards.

**Philosophy**: AI assistants are powerful tools but have systematic blind spots. These guidelines help you:
1. **Steer AI toward simplicity** via prompting strategy
2. **Prevent over-engineering** via pre-generation checklist
3. **Catch problematic output** via red flag detection

**When to Use These Guidelines:**
- ALWAYS before requesting AI code generation
- ALWAYS when reviewing AI-generated code before accepting
- ALWAYS when AI proposes architectural decisions

---

### Prompting Strategy (Evidence-Based Techniques)

#### 1. Extended Reasoning ("Think Harder")

**Technique:** Ask AI to use extended thinking modes before generating code

**Example Prompts:**
- "Use ultrathink mode to analyze this requirement"
- "Think step-by-step about the simplest solution"
- "What are 3 different approaches, ranked by simplicity?"

**Why It Works:** Extended reasoning reduces impulsive complexity. Research shows 40% fewer unnecessary abstractions when AI "thinks aloud" first.

---

#### 2. Simplicity Directive ("SIMPLEST Possible")

**Technique:** Explicitly constrain AI to minimal solutions

**Example Prompts:**
- "Write the SIMPLEST possible solution—no abstractions unless 3+ use cases exist"
- "Implement this in the fewest files possible"
- "Prefer duplication over premature abstraction"
- "Follow YAGNI (You Aren't Gonna Need It) strictly"

**Why It Works:** AI models default to "textbook" solutions with layers of abstraction. Explicit simplicity constraints override this bias.

---

#### 3. Context Injection ("Examine Existing Code")

**Technique:** Direct AI to study existing patterns before generating new code

**Example Prompts:**
- "First examine how authentication is handled in existing endpoints, then add auth to this new endpoint"
- "Read the existing user service before creating new user functionality"
- "What patterns exist for error handling in this codebase?"

**Why It Works:** AI generates generic "framework demo" code when lacking context. Examining existing code first ensures consistency and reuse.

---

#### 4. Audience Constraint ("Junior Developer Understanding")

**Technique:** Constrain AI to generate code understandable by less experienced developers

**Example Prompts:**
- "Write this so a junior developer can understand and maintain it"
- "Avoid clever tricks—optimize for readability, not brevity"
- "Explain complex logic with clear variable names, not comments"

**Why It Works:** AI often generates "clever" code with advanced language features. Junior developer constraint prioritizes clarity.

---

### Pre-Generation Checklist

Before accepting AI-generated code, verify:

#### Simplicity Validation
- [ ] Could this be done in fewer files? (Threshold: >3 files for feature = ask to consolidate)
- [ ] Could this be done with less indirection? (Threshold: >2 layers = justify each)
- [ ] Does this use the simplest possible data structures?
- [ ] Are all variables/functions clearly named without comments?

#### Reuse Validation
- [ ] Does this reuse existing code instead of duplicating?
- [ ] Does this follow existing patterns in the codebase?
- [ ] Does this use existing libraries/frameworks instead of reinventing?
- [ ] Does this integrate with existing error handling patterns?

#### Abstraction Justification
- [ ] Are abstractions justified by 3+ actual (not hypothetical) use cases?
- [ ] Do interfaces have multiple implementations RIGHT NOW?
- [ ] Are generics necessary, or could concrete types work?
- [ ] Do design patterns solve actual problems, or add ceremony?

#### Understandability Validation
- [ ] Would a junior developer understand this in 5 minutes?
- [ ] Is the code explicit rather than clever?
- [ ] Are dependencies obvious, not hidden via DI magic?

---

### Red Flags (Reject AI Output Immediately)

#### Complexity Red Flags

- **More than 3 layers of indirection** between request and data
- **Manager/Provider/Handler class name proliferation** (doing similar work)
- **Interfaces with single implementations**
- **Factory patterns for objects with <3 variants**

#### Security Red Flags (SAFETY-CRITICAL)

- **Missing authentication checks** on new endpoints
- **Missing input validation/sanitization**
- **SQL queries using string concatenation**
- **Hardcoded credentials or API keys** in code

#### Over-Engineering Red Flags

- **More than 5 files created** for single feature
- **Generic/reusable components** with only 1 current use case
- **Dependency injection frameworks** for <10 classes
- **Configuration files** with <5 settings

#### Testing Red Flags

- **Tests that mock everything** except the function under test
- **Tests with >5 setup lines** per assertion
- **Comments explaining obvious code** (over-commenting)
- **TODOs or FIXMEs** in production code

---

### When to Override These Guidelines

Override when justified (and document rationale):

**Performance-Critical Code:** Abstraction layers enable critical optimization

**Security-Critical Code:** Additional validation layers prevent vulnerabilities

**Third-Party Integration:** Framework/library requires specific patterns

**Team Consensus:** Architectural Decision Record documents pattern decision

---

## Workflow Decision Tree

```text
Any feature work?
  └─ /rptc:feat "description"
     → Agent handles complexity automatically
     → You select planning approach
     → TDD implementation
     → Quality verification
     → Ready for /rptc:commit

Need standalone research first?
  └─ /rptc:research "topic"
     → Then /rptc:feat when ready

Tests out of sync?
  └─ /rptc:sync-prod-to-tests "src/"

Ready to ship?
  └─ /rptc:commit [pr]
```

## Project Structure

### Your Project (No Setup Required)

RPTC uses Claude's native plan mode. No special directories needed.

```text
your-project/
├── docs/research/               # Optional: saved research documents
├── CLAUDE.md                    # Optional: project context (recommended)
└── [your project files]
```

**Plans are stored in**: `~/.claude/plans/` (Claude's native location)

### Optional: Research Documents

If you save research to files (via `/rptc:research`), they go to `docs/research/`:

```text
docs/research/
└── [topic-slug]/
    ├── research.html           # Professional dark-theme report
    └── research.md             # Editable markdown (optional)
```

## Quality Standards

### Testing Requirements

- **Minimum coverage**: 80% overall, 100% critical paths
- **Test types**: Unit, Integration, E2E
- **Test-first for code**: Write tests before implementation (code tasks only)

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

- **You are the decision maker** - Select planning approach, approve plans
- **One command for features** - `/rptc:feat` handles the workflow
- **TDD for code tasks** - Tests first for source file changes
- **Direct execution for non-code** - Docs and config skip TDD
- **Report-only quality gates** - Agents report, you decide what to fix
- **Native plan mode** - Plans in `~/.claude/plans/`, no `.rptc/` needed

## Example Complete Workflow

```bash
# 1. Start feature development
> /rptc:feat "add user authentication with OAuth2"

# Phase 1: Discovery
[Agent explores codebase, identifies patterns]
[Presents findings: files to modify, dependencies]

# Phase 2: Architecture
[3 planning approaches presented]
[You select: "Pragmatic (Recommended)"]
[Plan written, you approve]

# Phase 3: TDD Implementation
[Smart batching groups related steps]
[RED → GREEN → REFACTOR per step]
[Progress shown via todos]

# Phase 4: Quality Verification
[Code Review and Security agents run in parallel]
[You review findings, approve fixes]

# Phase 5: Complete
[Summary: 8 files modified, 47 tests added]

# 2. Ship it
> /rptc:commit pr
[Tests pass, coverage verified]
[PR created]
```

---

**Remember**: The unified `/rptc:feat` command puts YOU in control while handling the complexity of research, planning, TDD, and quality verification.
