# RPTC Workflow Guide

## Research → Plan → TDD → Commit with PM Collaboration

---

## Quick Start

```bash
# Install the workflow
bash setup-rptc-workflow.sh

# Start using it
/rptc:helper-catch-up-med                    # Get context
/rptc:research "topic to explore"   # Interactive discovery
/rptc:plan "@research.md"             # Collaborative planning
/rptc:tdd "@plan/"                    # TDD implementation (directory format)
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

- ✅ Approving delegation to Master specialist agents
- ✅ Approving plans before implementation
- ✅ Approving quality gate reviews
- ✅ Approving final completion

**Want to understand when to use workflows vs autonomous agents?** See [Workflows vs Agents Decision Tree](#workflows-vs-agents-making-the-right-choice) for guidance on choosing the right approach.

---

## Architecture Overview (v2.0.0+)

### Incremental Sub-Agent Delegation

RPTC uses an **incremental sub-agent architecture** that dramatically improves token efficiency and prevents timeouts:

**Key Benefits:**
- **79% token reduction** in TDD phase
- **Immediate file persistence** (not at end)
- **Better timeout handling** (distributed work)
- **Scalable for complex features** (modular directory structure)
- **No file size limits** (unlimited steps per plan)

**How It Works:**

1. **Planning Phase** - Directory format with sub-agents:
   - Overview Generator → `overview.md`
   - Step Generators (one per step) → `step-01.md`, `step-02.md`, etc.
   - Cohesiveness Reviewer → validates consistency
   - Files saved immediately as generated (recovery if interrupted)

2. **TDD Phase** - Selective context loading:
   - Loads `overview.md` + current `step-NN.md` only
   - **Result**: 79% less context per step
   - Supports unlimited steps with auto-handoff

3. **Research Phase** - Parallel sub-agent execution:
   - Discovery Q&A + Codebase exploration + Web research (if needed)
   - All run concurrently where possible
   - Intelligent web search triggering (unfamiliar topics only)

### Plan Format (v2.0.0+)

All plans use **directory format** with incremental sub-agent delegation:

**Directory Structure:**
```text
.rptc/plans/[feature-name]/
├── overview.md          # Feature context, test strategy, acceptance criteria
├── step-01.md          # First implementation step
├── step-02.md          # Second implementation step
└── step-NN.md          # Additional steps as needed
```

**Benefits:**
- Token-efficient (each step isolated in sub-agent context)
- Scalable (no file size limits)
- Resumable (can pause/resume at any step)
- Clear progress tracking (one file per step)

**Usage Example:**

```bash
# Plan command generates directory format
/rptc:plan "add user authentication"

# TDD command loads directory with trailing slash
/rptc:tdd "@user-authentication/"
```

**Agentic Patterns Used**: This architecture leverages all 5 of [Anthropic's Agentic Patterns](#anthropics-five-agentic-patterns) - prompt chaining (phase transitions), routing (complexity-based delegation), parallelization (sub-agent delegation), orchestrator-workers (plan generation), and evaluator-optimizer (quality gates).

### Legacy Monolithic Plans (Pre-v2.0.0)

**Deprecated**: Monolithic single-file plans (`.rptc/plans/feature.md`) are no longer generated.

**If you have legacy monolithic plans**:
- Executing them with `/rptc:tdd "@plan.md"` will show a migration error
- Migration options:
  1. **Regenerate**: Run `/rptc:plan` with the same feature description (creates directory format)
  2. **Manual conversion**: Create directory structure and split content into overview.md + step files
  3. **Temporary downgrade**: Use v1.2.0 (deprecated, not recommended)

**Breaking change introduced**: v2.0.0 (October 24, 2025)

---

## Workflows vs Agents: Making the Right Choice

### The Spectrum of AI Orchestration

AI-powered development exists on a spectrum from simple prompts to complex autonomous agents:

**Simple Prompts** → **Workflows** → **Autonomous Agents**

- **Simple Prompts**: Single-turn interactions (e.g., "Fix this bug")
- **Workflows**: Predefined decision paths with clear phases (e.g., RPTC's Research→Plan→TDD→Commit)
- **Autonomous Agents**: Dynamic decision-making with minimal predefined paths (e.g., "Improve the system")

**RPTC is workflow-centric** but uses agent patterns strategically within its workflow structure.

---

### Anthropic's Five Agentic Patterns

Reference: [Anthropic's Agentic Patterns Documentation](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/agentic-patterns)

#### 1. Prompt Chaining

**Definition**: Sequential prompts where output N becomes input N+1

**RPTC Uses This**: Research → Plan → TDD phase transitions
- Research output feeds into plan scaffold
- Plan document drives TDD execution
- Each phase builds on previous results

**Best For**: Well-defined multi-step processes with clear dependencies

---

#### 2. Routing

**Definition**: Single classifier prompt routes to specialized sub-prompts based on input type

**RPTC Uses This**: Complexity-based sub-agent delegation
- Research phase: Routes to web research agent for unfamiliar topics
- Planning phase: Routes to step generators based on complexity
- TDD phase: Routes to quality gate agents (efficiency, security) based on configuration

**Best For**: Varied inputs requiring different handling strategies

---

#### 3. Parallelization

**Definition**: Multiple prompts run concurrently, results aggregated

**RPTC Uses This**: Sub-agent delegation in planning and research
- Research phase: Discovery Q&A + Codebase exploration + Web research run in parallel
- Planning phase: Step generators can run in parallel for independent steps
- Results integrated efficiently

**Best For**: Independent tasks that can execute simultaneously

---

#### 4. Orchestrator-Workers

**Definition**: Central orchestrator delegates to specialized workers dynamically

**RPTC Uses This**: Plan command orchestrates overview + step generators
- Main planning command acts as orchestrator
- Overview Generator creates strategic context
- Step Generators create tactical implementation details
- Cohesiveness Reviewer validates integration

**Best For**: Complex tasks with multiple specialized sub-tasks

---

#### 5. Evaluator-Optimizer

**Definition**: Loop of generate → evaluate → refine until quality threshold met

**RPTC Uses This**: Quality gates and iterative refinement
- Efficiency Agent reviews implementation, suggests improvements
- Security Agent audits and fixes vulnerabilities
- TDD cycle: RED → GREEN → REFACTOR with auto-iteration (max 10 attempts)
- All tests must remain passing after optimization

**Best For**: Quality-critical outputs requiring iteration and validation

---

### When to Use Workflows

✅ **Choose workflows when**:

- Task has clear **start and end states**
- Steps are **well-defined and repeatable**
- **Predictability and cost control** are priorities
- **Human approval points** needed at key decisions
- Want **auditable decision trail** for compliance
- Team needs **consistent execution** across developers

**Examples**:
- CRUD operations (Create, Read, Update, Delete)
- API integrations with known endpoints
- Standard deployments following established procedures
- Feature implementations with clear requirements
- Bug fixes with reproducible test cases

**Advantages**:
- **Predictable costs**: Token usage is consistent
- **Faster execution**: No exploration overhead
- **Easier debugging**: Clear decision trail
- **Better testability**: Repeatable workflows validate easily
- **Team consistency**: Same process for all developers

---

### When to Use Autonomous Agents

✅ **Choose autonomous agents when**:

- Problem space is **open-ended** with unclear solution path
- **Optimal approach unknown** upfront
- Need **adaptive decision-making** based on discoveries
- **Exploration vs exploitation** trade-offs important
- Can tolerate **higher costs and unpredictability**
- Goal clarity more important than path clarity

**Examples**:
- Research synthesis across disparate sources
- Creative problem-solving ("make this better")
- Competitive analysis with evolving landscape
- Strategic planning with multiple valid approaches
- Root cause analysis in complex systems

**Advantages**:
- **Adaptive**: Adjusts strategy based on findings
- **Exploratory**: Discovers non-obvious solutions
- **Flexible**: Handles unexpected scenarios
- **Creative**: Not bound by predefined paths

**Disadvantages**:
- **Unpredictable costs**: Token usage varies widely
- **Slower**: Exploration takes time
- **Harder to debug**: Decision path not predetermined
- **Inconsistent**: Different runs may take different approaches

---

### Why RPTC is Workflow-Centric

RPTC deliberately chooses a **workflow-centric architecture** for these reasons:

#### 1. Predictability
Developers know what to expect at each phase. No surprises, clear mental model.

#### 2. Cost Efficiency
Predefined paths use **79% fewer tokens** than autonomous exploration (measured in TDD phase with directory format).

#### 3. Human Control
PM approval gates prevent unwanted actions. You control when agents run, what they optimize, and when to ship.

#### 4. Testability
Repeatable workflows are easier to validate. TDD workflow ensures tests written before implementation, every time.

#### 5. Debugging
Clear decision trail when issues arise. Know exactly which phase, which agent, which decision caused a problem.

#### 6. Best Practices Enforcement
Systematically enforces TDD, quality gates, security reviews, and efficiency optimization.

#### 7. Team Consistency
All developers follow the same Research→Plan→TDD→Commit flow. Onboarding simplified.

---

### RPTC's Hybrid Approach

**RPTC uses workflows for structure, agents for flexibility**:

- **Workflows**: Phase transitions (Research → Plan → TDD → Commit) are predefined
- **Agent Patterns**: Within phases, RPTC uses all 5 Anthropic patterns strategically
  - Prompt Chaining: Phase output feeds next phase
  - Routing: Complexity-based sub-agent delegation
  - Parallelization: Sub-agent delegation for independent work
  - Orchestrator-Workers: Planning command orchestrates generators
  - Evaluator-Optimizer: Quality gates and TDD iteration

**Result**: Structure + flexibility = predictable costs, human control, adaptive sub-tasks.

---

### Decision Flowchart

```text
START: What are you trying to accomplish?

┌─────────────────────────────────────────────────┐
│ Can you define the steps upfront?              │
│ Do you know the expected deliverable format?   │
└───────────┬─────────────────────────────────────┘
            │
    ┌───────┴────────┐
    │                │
   YES              NO
    │                │
    ▼                ▼
┌──────────────┐  ┌──────────────────────────────┐
│  WORKFLOW    │  │  AUTONOMOUS AGENT or HYBRID  │
│  (RPTC)      │  │                              │
└──────────────┘  └──────────────────────────────┘
    │                │
    │                │
    ▼                ▼
Examples:           Examples:
• Add feature      • "Make it better"
• Fix bug          • Open-ended research
• Refactor X       • Creative design
• Deploy to Y      • Competitive analysis
• Test Z           • Strategic planning
• API integration  • Root cause analysis

┌──────────────────────────────────────────────────┐
│  HYBRID APPROACH (RPTC's Model):                 │
│  ✅ Use workflow for phase structure             │
│  ✅ Use agent patterns within phases             │
│  ✅ Best of both worlds                          │
│                                                  │
│  Example: RPTC uses Research→Plan→TDD workflow,  │
│  but delegates to specialist agents within       │
│  phases (Master Feature Planner, Efficiency      │
│  Agent, Security Agent, etc.)                    │
└──────────────────────────────────────────────────┘
```

---

### Quick Decision Questions

Ask yourself:

**Workflow Indicators** (RPTC is right):
- ✅ Do I know the final deliverable format?
- ✅ Can I list the major steps upfront?
- ✅ Do I need approval gates for control?
- ✅ Is cost predictability important?
- ✅ Do I want a repeatable process?

**Agent Indicators** (Autonomous agent or hybrid):
- ✅ Am I exploring unknowns?
- ✅ Is the optimal path unclear?
- ✅ Do I need adaptive behavior?
- ✅ Is creative problem-solving required?
- ✅ Can I tolerate unpredictable costs?

**When in doubt, start with workflows** (KISS principle). Upgrade to agent patterns only when workflows prove insufficient.

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

3. **Optional Web Research** (v1.2.0+ intelligent triggering):

   **Intelligent decision-making:**
   - Automatically triggered for unfamiliar topics
   - Skipped for well-known patterns (e.g., "add button to homepage")
   - You approve delegation to Master Web Research Agent

   **Parallel execution:**
   - Discovery Q&A runs concurrently with codebase exploration
   - Web research (if needed) runs in parallel
   - Results integrated efficiently

4. **Inline Results & Optional Save**: Findings presented immediately, followed by optional non-blocking save prompt (skip/html/md/both/auto)

**Output**: `.rptc/research/[topic-slug]/research.{html,md}` (based on format choice)

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

5. **Master Feature Planner**: Creates comprehensive TDD-ready plan (v2.0.0+ directory format only)

   **Directory format with sub-agent delegation:**
   - Incremental sub-agent delegation
   - `overview.md` (test strategy, acceptance criteria, risks)
   - `step-01.md` through `step-NN.md` (individual step details)
   - Files saved immediately as generated (recovery if interrupted)
   - Saved as `.rptc/plans/[name]/` directory

   **All plans include:**
   - Detailed steps with tests defined first
   - Complete test strategy (happy path, edge cases, errors)
   - File creation/modification list
   - Dependencies and risks
   - Acceptance criteria
   - Implementation constraints

6. **Plan Review**: You review, request modifications, and approve

7. **PM Sign-Off**: Explicit approval before plan is saved

**Output**: `.rptc/plans/[name]/` (overview.md + step-NN.md files)

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

### 3. TDD Phase: `/rptc:tdd "@plan-dir/"`

**Purpose**: Test-driven implementation with quality gates

**What happens**:

1. **Load Plan**: Reads implementation plan directory

   **Directory format** - **79% token reduction:**
   - Loads `overview.md` once (test strategy, acceptance criteria)
   - For each step: loads only `step-NN.md` (not entire plan)
   - Dramatically reduces context size per step
   - Supports unlimited steps with auto-handoff

2. **TDD Cycle for Each Step**:

   - **RED**: Write tests FIRST (happy path, edge cases, errors)
   - **GREEN**: Minimal implementation + auto-iteration (max 10 attempts)
   - **REFACTOR**: Improve code while keeping tests green
   - **VERIFY**: Run full suite, check coverage

3. **After All Tests Passing** (Optional Quality Gates):

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

   **Documentation Specialist** (automatically invoked):

   - Analyzes changes for documentation significance
   - Creates permanent docs in `docs/` if warranted
   - You review and approve before commit

4. **Final PM Sign-Off**: You explicitly approve TDD completion

5. **Plan Update**: Status changed to Complete (only after approval)

**Output**: Fully tested implementation with quality gates passed

**Key Principle**: Tests are ALWAYS written before implementation

---

### Phase 3 Enhanced: TDD Execution Optimization (v1.2.0+)

**New Capabilities**: 5 enhancements for unlimited feature size

#### What's New

**1. Implementation Constraints** - Quality Gate Specifications

- **What**: Plans include structured constraints (file size, complexity, dependencies, platform, performance)
- **When**: Always - required in every plan template
- **How**: Agent generates constraints from project context
- **Benefit**: Prevents over-engineering at generation time
- **Example**:
  ```
  ## Implementation Constraints
  - File Size: <500 lines
  - Complexity: <50 lines/function, <10 cyclomatic
  - Dependencies: Reuse patterns, prohibit factories for single use
  - Platforms: Node.js 18+
  - Performance: <100ms response (p95)
  ```

**2. Seven-Step TDD Workflow** - Structured Implementation

- **What**: Explicit 7-step TDD cycle from Anthropic research
- **When**: Applied to every step in TDD phase
- **How**: Auto-enforced in tdd.md workflow
- **Steps**:
  1. Understand the Requirement
  2. Design Test Scenarios (Pre-Validation Checkpoint)
  3. Write Failing Test (RED Phase)
  4. Minimal Implementation (GREEN Phase)
  5. Refactor for Quality
  6. Verify No Regressions (Phase 1d: Independent Verification)
  7. Document and Commit

**Phase 1d: Independent Verification** - Catch Test Overfitting

**Purpose:** Catch test overfitting and validate intent fulfillment after GREEN phase, before refactoring begins.

**When:** After tests pass (GREEN), before documentation and PM review

**Configuration:** `.claude/settings.json` → `rptc.verificationMode`

**Verification Scope (Focused Mode):**
1. **Intent Fulfillment:** Does implementation match step purpose from plan?
2. **Coverage Gaps:** Are all planned test scenarios actually implemented?
3. **Overfitting Detection:** Any hardcoded test gaming (returning expected values without logic)?

**Time Limit:** <5 minutes per step (goal, not hard timeout)

**Verification Results:**
- **PASS:** All checks passed, proceed to refactoring
- **FAIL:** Gaps identified, implementation requires rework before proceeding
- **NEEDS_CLARIFICATION:** Ambiguities detected, PM review required

**Example Output:**

```bash
# After GREEN phase completes
════════════════════════════════════════════════════════
  PHASE 3.75: INDEPENDENT VERIFICATION
════════════════════════════════════════════════════════

Mode: focused
Purpose: Catch test overfitting and validate intent fulfillment
Time Limit: <5 minutes per step

🔍 Delegating to Verification Sub-Agent...

Verification checks:
  1. Intent Fulfillment (does implementation match plan purpose?)
  2. Coverage Gaps (are all planned tests implemented?)
  3. Overfitting Detection (any hardcoded test gaming?)

## Verification Result: PASS

### 1. Intent Fulfillment: ✅ PASS
Implementation correctly validates user input and throws error on invalid email format.
Matches step purpose: "Implement email validation with format and domain checks"

### 2. Coverage Gaps: ✅ PASS
All planned tests implemented:
- Happy path: valid email formats
- Edge cases: empty string, missing @, invalid domain
- Error conditions: null input, malformed format

### 3. Overfitting Detection: ✅ PASS
No hardcoded test gaming detected. Implementation uses regex validation logic.
Code review: validateEmail() function implements real validation, not test-specific returns.

## Recommendation
Proceed to REFACTOR phase

## Time Spent: 3 minutes

✅ Verification: PASS
✅ All verification checks passed. Proceeding to documentation phase...
```

**Disabling Verification:**

If you prefer to skip independent verification (backward compatibility):

```json
{
  "rptc": {
    "verificationMode": "disabled"
  }
}
```

**When to Disable:**
- Simple refactoring work (low overfitting risk)
- Hot fixes with time pressure
- Exploratory/prototype work
- Trust in implementation quality

**When to Keep Enabled (Recommended):**
- Complex business logic
- Security-critical code
- AI-heavy implementation (higher overfitting risk)
- New team members or unfamiliar codebases

**Phase 0b: Test-Driven Generation (TDG Mode)** - AI-Accelerated Test Generation (v2.0.0+)

**Purpose:** AI-accelerated comprehensive test generation from plan specifications to dramatically reduce TDD overhead.

**When:** After plan load (Phase 0), before RED phase (Phase 1), ONLY if `--tdg` flag OR config `tdgMode: "enabled"`

**Strategy:** AUGMENTATION (planned scenarios + ~50 AI-generated tests)

**Benefits:**
- **80% overhead reduction:** ~50 tests in <5 minutes vs. 10-20 min manually
- **Comprehensive coverage:** Diverse edge cases and error conditions
- **Plan-driven:** Respects specifications and implementation constraints
- **Augmentation:** Keeps planned tests, adds AI-generated tests (not replacement)

**Example Output:**

```bash
════════════════════════════════════════════════════════
  PHASE 0b: TEST-DRIVEN GENERATION (TDG MODE)
════════════════════════════════════════════════════════

Strategy: AUGMENTATION (planned scenarios + ~50 AI-generated tests)
Target: Comprehensive coverage in <5 minutes
Integration: Generated tests augment plan, not replace

🧪 TDG Mode: Generating comprehensive test suite...

📋 Step 2: Delegating to TDG Sub-Agent...
   Planned tests: 5
   Target: ~50 additional tests

✅ TDG Complete

📊 Test Suite Summary:
   Planned tests (from plan): 5
   Generated tests (TDG): 47
   Total tests: 52

✅ Augmented test suite saved: step-02-tests-augmented.md

Proceeding to RED phase with comprehensive test suite...

✅ Phase 0b Complete: Test-Driven Generation
   Generated: 47 tests
   Total: 52 tests (planned + generated)
   Time: 2025-01-24 14:32:15
```

**Configuration:**

**Opt-in (default):**
```json
{
  "rptc": {
    "tdgMode": "disabled"
  }
}
```

Use `--tdg` flag to enable per-execution:
```bash
/rptc:tdd "@plan-name/" --tdg
```

**Always-on:**
```json
{
  "rptc": {
    "tdgMode": "enabled"
  }
}
```

TDG runs automatically for all TDD executions (no flag needed).

**When to Use TDG:**
- Complex features with many edge cases
- New implementations requiring comprehensive coverage
- Security-critical code (thorough error condition testing)
- Unfamiliar domains (AI suggests test scenarios you might miss)

**When to Skip TDG:**
- Simple CRUD operations (planned tests sufficient)
- Refactoring with existing test coverage
- Hot fixes (time pressure, manual tests faster)
- Exploratory work (test strategy unclear)

**Deduplication:**

TDG sub-agent deduplicates generated tests against planned scenarios automatically. Post-processing adds secondary duplicate detection (name matching). If duplicate count high (>10%), review generated tests manually.

**Troubleshooting:**

**Problem:** TDG generates too many tests (>100 total)
**Solution:** Warning shown, option to continue or pause. Review augmented test file, manually remove low-value tests.

**Problem:** TDG timeout (>10 min)
**Solution:** Graceful degradation, uses planned tests only. Check specification clarity (incomplete specs cause longer generation time).

**Problem:** Generated tests have syntax errors
**Solution:** Validation checkpoint catches errors, fallback to planned tests. Report issue (may indicate TDG template needs adjustment).

**3. Constraint-Aware Execution** - Respecting Project Boundaries

- **What**: TDD sub-agents receive Implementation Constraints in context
- **When**: Every step when using directory-format plans
- **Benefit**: Reduces over-engineering, ensures simplicity

**4. Simplicity Enforcement** - REFACTOR Phase Validation

- **What**: REFACTOR phase includes explicit simplicity checks
- **Checks**:
  - Abstraction count (no single-use abstractions)
  - Indirection layers (≤3)
  - Enterprise pattern misuse check
  - Code size compliance
  - YAGNI violations
- **Benefit**: Prevents architecture complexity creep

**5. Auto-Handoff with Dynamic Prediction (Roadmap #22)** - Unlimited Feature Size

**Problem Solved:** Large features (>15 steps) previously hit context limits, requiring manual plan splitting.

**Solution:** Dynamic context prediction with automatic checkpoint/resume.

**Always Enabled:** No configuration needed - automatic protection prevents plan size limitations.

**How to Use:**

**1. Write large plan (no size restrictions):**
```bash
/rptc:plan "Implement complete user authentication system with OAuth, MFA, and session management" --complexity complex
```

Plan generates 20+ steps - no problem!

**2. Execute with TDD:**
```bash
/rptc:tdd "@user-authentication/"
```

**3. System monitors context automatically:**

After each step:
- Measures actual context usage
- Predicts next step impact (hybrid model)
- Checks if safe to proceed (<160K projected total)

**4. Handoff triggers when needed:**

```
Step 13 Complete ✅
Predicting Step 14...
⛔ HANDOFF TRIGGERED: Would exceed 80% capacity
📝 Checkpoint: .rptc/plans/user-authentication/handoff.md
📍 Resume with: /rptc:helper-resume-plan "@user-authentication/"
```

**5. Resume in fresh context:**

```bash
/rptc:helper-resume-plan "@user-authentication/"
```

Continues from Step 14, uses calibrated predictions from first session.

**Multiple Handoffs:**

Large plans (30+ steps) may require 2-3 handoff cycles:
- Session 1: Steps 1-13 (handoff at 156K)
- Session 2: Steps 14-26 (handoff at 158K)
- Session 3: Steps 27-30 (completes at 45K)

Each session preserves context from previous, no work lost.

**Prediction Improves Over Time:**

- **Steps 1-3:** Conservative (±20% error, uses 25K floor)
- **Steps 4-10:** Calibrating (±10-15% error, adjusts multiplier)
- **Steps 11+:** Accurate (±5-10% error, stable)

**Diagnostic Log:**

Check prediction details:
```bash
cat .rptc/tdd-prediction.log
```

Shows: predicted vs actual for each step, calibration adjustments, errors.

**When NOT to Worry:**

- Handoff after 5 steps with 30-step plan (normal for complex features)
- Prediction errors <15% (acceptable range)
- Multiple handoff cycles (expected for large features)

**When to Investigate:**

- Handoff after 2 steps (steps may be too large - split plan)
- Prediction errors >25% consistently (check MCP overhead)
- Handoff triggers mid-step (shouldn't happen - report bug)

**Troubleshooting:**

**Q: Handoff triggered after only 5 steps?**
A: Large step files or high complexity. Review `.rptc/tdd-prediction.log` for per-step usage. Consider splitting steps if >30K each.

**Q: Prediction consistently inaccurate?**
A: System detects this (3+ errors >20%) and switches to conservative mode. Check if MCP servers adding unexpected overhead.

**Q: Can I disable auto-handoff?**
A: No - it's always enabled. This prevents plan size limitations. Trust the prediction system or split plan manually if needed.

#### Configuration Options

```json
{
  "rptc": {
    "defaultThinkingMode": "think",
    "simplifyEnforcement": "enabled",
    "constraintGeneration": "enabled"
  }
}
```

#### Troubleshooting

**Problem: "Simplicity validation flagging valid patterns"**
- Solution: Override using Implementation Constraints
- Add justified exception to constraints section

**Problem: "Want to disable handoff checkpoint?"**
- Solution: PM can choose PROCEED at checkpoint
- Handoff is not automatic

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

#### `/rptc:helper-catch-up-quick` (2 minutes)

- Project basics (CLAUDE.md, package.json, README)
- Recent 5 commits
- Current branch status

**Use when**: Quick questions, small fixes, immediate tasks

#### `/rptc:helper-catch-up-med` (5-10 minutes)

- Architecture understanding
- Recent 15 commits with context
- Existing research/plans review
- Dependencies overview

**Use when**: Implementation work, understanding existing code

#### `/rptc:helper-catch-up-deep` (15-30 minutes)

- Complete architecture analysis
- Full git history review
- All documentation inventory
- Complete dependency analysis
- Code pattern analysis

**Use when**: Complex work, unfamiliar projects, major changes

### Plan Updates

#### `/rptc:helper-update-plan "@plan.md" "changes"`

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

### Master Research Agent

**Purpose**: Research best practices through web search and codebase exploration

**Definition:** `${CLAUDE_PLUGIN_ROOT}/agents/master-research-agent.md`

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
# - Presents comprehensive plan (directory format)
# - You approve plan

> /rptc:tdd "@user-avatar-upload/"

# Claude executes with quality gates (with your approval)

> /rptc:commit pr
```

**When**: Medium work items, familiar codebase, clear requirements

---

### Pattern 3: Complex Work (Full Workflow)

```bash
# Get context first
> /rptc:helper-catch-up-med

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
# - Presents detailed plan (directory format)
# - You approve plan

# TDD implementation
> /rptc:tdd "@payment-processing/"

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
> /rptc:helper-update-plan "@payment-processing/" "add PayPal support"

# Claude:
# - Loads current plan
# - Asks clarifying questions about changes
# - Drafts updates
# - You review and approve

# Continue implementation with updated plan
> /rptc:tdd "@payment-processing/"
```

**When**: Requirements evolve, new considerations discovered

---

## Decision Tree: Which Commands?

```text
Need context first?
├─ Quick context (2 min) → /rptc:helper-catch-up-quick
├─ Medium context (5-10 min) → /rptc:helper-catch-up-med
└─ Deep analysis (15-30 min) → /rptc:helper-catch-up-deep

Is it a bug fix?
└─ Yes → /rptc:tdd "bug description"

Is it a simple change in familiar code?
└─ Yes → /rptc:plan "description" → /rptc:tdd "@plan/"

Is it complex or unfamiliar?
└─ Yes → /rptc:research "topic" → /rptc:plan "@research.md" → /rptc:tdd "@plan/"

Need to modify existing plan?
└─ Yes → /rptc:helper-update-plan "@plan/" "changes"

Resuming previous work?
└─ Yes → /rptc:helper-resume-plan "@plan/"

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

- Update as you learn (/rptc:helper-update-plan)
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
│   ├── plans/                 # Implementation plans (directory format only, v2.0.0+)
│   │   ├── user-authentication/                 # Directory format
│   │   │   ├── overview.md                      # Test strategy, risks, acceptance
│   │   │   ├── step-01.md                       # Step 1 details
│   │   │   ├── step-02.md                       # Step 2 details
│   │   │   └── step-03.md                       # Step 3 details
│   │   └── payment-processing/
│   │       ├── overview.md
│   │       └── step-01.md
│   └── complete/              # Completed work (v1.1.0+, was 'archive')
│
├── .claude/
│   ├── sop/                   # Project SOP overrides (optional)
│   ├── settings.json
│   └── CLAUDE.md
│
├── docs/                      # Permanent documentation
│   ├── architecture/          # Auto-created by Doc Specialist
│   ├── api/                   # Auto-created by Doc Specialist
│   └── patterns/              # Auto-created by Doc Specialist
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

**A**: Use `/rptc:helper-update-plan "@plan/" "your changes"`

### Q: Forgot what we researched

**A**: Read `.rptc/research/[topic].md` or use `/rptc:helper-catch-up-med`

### Q: Resuming work after a break

**A**: Use `/rptc:helper-resume-plan "@plan/"` for smart context restoration

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
   /rptc:tdd "@calculator-functionality/"
   /rptc:commit
   ```

3. **Try a complex flow**:

   ```bash
   /rptc:helper-catch-up-med
   /rptc:research "complex topic"
   /rptc:plan "@complex-topic.md"
   /rptc:tdd "@complex-topic/"
   /rptc:commit pr
   ```

4. **Read the command files**:
   - See detailed workflows in `${CLAUDE_PLUGIN_ROOT}/commands/*.md`
   - Understand Master agent prompts
   - Customize if needed

---

**Welcome to systematic, PM-controlled development with Claude as your collaborative partner!** 🚀
