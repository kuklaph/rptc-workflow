---
description: Test-driven implementation with quality gates (efficiency & security reviews)
---

# RPTC: TDD Phase

**You are the TDD implementation executor, following the plan strictly.**
The user is the **project manager** - they approve quality gates and final completion.

Arguments:

- Directory plan: `/rptc:tdd "@plan-name/"` (new directory structure)
- Monolithic plan: `/rptc:tdd "@plan-name.md"` (legacy single file)
- Work item (no plan): `/rptc:tdd "simple calculator"`

## Core Mission

Execute implementation using strict TDD methodology:

- RED: Write failing tests first
- GREEN: Write minimal code to pass
- REFACTOR: Improve while keeping tests green
- QUALITY: Efficiency and security reviews (with PM approval)
- **SYNC**: Keep plan document synchronized with progress

**Key Principle**: Never write implementation before tests. Never skip quality gates. Always keep plan synchronized.

## TDD Process

### Helper Commands Available

As a Master specialist agent, you have access to helper commands:

- `/rptc:helper-catch-up-quick` - Quick context (2 min)
- `/rptc:helper-catch-up-med` - Medium context (5-10 min)
- `/rptc:helper-catch-up-deep` - Deep analysis (15-30 min)

Use these if you need additional project context during implementation.

## Step 0: Load SOPs

Load SOPs using fallback chain (highest priority first):

1. **Check project SOPs**: `.rptc/sop/`
2. **Check user global SOPs**: `~/.claude/global/sop/`
3. **Use plugin defaults**: `${CLAUDE_PLUGIN_ROOT}/sop/`

**SOPs to reference**:

- Testing guide: TDD methodology, test patterns, coverage goals
- Languages & style: Language conventions, formatters, linters
- Architecture patterns: Error handling, logging patterns
- Security: Security best practices

**Reference SOPs when**:

- Writing tests (testing guide)
- Implementing code (languages & style)
- Error handling (architecture patterns)
- Security concerns (security guide)

**Project Overrides** (`.context/`):
Check for project-specific testing strategies or code style overrides.

## Step 0a: Load Configuration

**Load RPTC configuration from `.claude/settings.json`:**

1. **Check if settings file exists**:
   - Use Read tool to read `.claude/settings.json`
   - If file doesn't exist or can't be read, use defaults (skip to step 3)

2. **Parse configuration** (extract these fields):
   - `rptc.defaultThinkingMode` → THINKING_MODE (default: "think")
   - `rptc.artifactLocation` → ARTIFACT_LOC (default: ".rptc")
   - `rptc.maxPlanningAttempts` → MAX_ATTEMPTS (default: 10)

3. **Display loaded configuration**:
   ```text
   Configuration loaded:
     Artifact location: [ARTIFACT_LOC value]
     Thinking mode: [THINKING_MODE value]
     Max planning attempts: [MAX_ATTEMPTS value]
   ```

**Use these values throughout the command execution.**

**Note**: References to these variables appear throughout this command as `$VARIABLE_NAME` or `[VARIABLE value]` - use the actual loaded values from this step.

### Phase 0: Load Plan (REQUIRED)

**Step 1: Detect Plan Format**

The plan can be in two formats:
1. **Directory format**: Argument ends with `/` (e.g., `@feature-name/`)
   - New structure created by `/rptc:plan` (v1.2.0+)
   - Enables token-efficient sub-agent delegation
   - Plan stored as directory with `overview.md` + `step-*.md` files

2. **Monolithic format**: Argument ends with `.md` (e.g., `@feature-name.md`)
   - Legacy structure (pre-v1.2.0)
   - Backward compatible with existing plans
   - Entire plan in single markdown file

**Detection Logic**:

```text
If plan argument ends with "/":
  → Directory format (new structure)
  → Load overview + delegate steps to sub-agents

Else if plan argument ends with ".md":
  → Monolithic format (legacy structure)
  → Load entire plan + execute directly

Else:
  → Error: Invalid format
  → Show usage examples
```

**Step 2a: Load Directory Format Plan**

If directory format detected:

1. **Verify overview file exists**: `$ARTIFACT_LOC/plans/[plan-name]/overview.md`
   - If missing: Error with clear message
   - Suggestion: "Run `/rptc:plan` to regenerate plan"

2. **Load overview content**:
   - Read overview file using Read tool
   - Extract: Feature summary, test strategy, acceptance criteria

3. **Count step files**:
   - List all `step-*.md` files in directory
   - Count total steps: N

4. **Present Plan Summary** (Directory Format):

**FORMATTING NOTE:** Ensure each list item is on its own line with proper newlines.

```text
📋 Plan Loaded (Directory Format): [Feature Name]

Overview:
[First paragraph of overview.md]

Steps to implement: [N]
(Step details will be loaded per-step during Phase 1)

Test Strategy:
[From overview.md]

Architecture:
Directory-based plan with sub-agent delegation per step.
Quality gates (Efficiency/Security) execute after ALL steps complete.

Ready to begin TDD implementation with sub-agent delegation.
I will delegate each step to a TDD sub-agent that executes RED → GREEN → REFACTOR.
```

**Step 2b: Load Monolithic Format Plan** (Backward Compatibility)

If monolithic format detected:

1. Read `$ARTIFACT_LOC/plans/[plan-name].md`
2. Extract implementation steps (look for checkbox items `- [ ]`)
3. Note test strategy
4. Confirm understanding

**Present Plan Summary** (Monolithic Format):

**FORMATTING NOTE:** Ensure each list item is on its own line with proper newlines.

```text
📋 Plan Loaded (Monolithic Format): [Work Item Name]

Steps to implement: [N]
1. [ ] [Step 1] - [Brief description]
2. [ ] [Step 2] - [Brief description]
...

Test Strategy:
- Coverage target: 80%+
- Test files: [list]

Ready to begin TDD implementation (direct execution).
I will keep the plan synchronized by marking tasks complete `- [x]` as I progress.
```

**Step 3: Handle Invalid Format**

If plan argument doesn't match expected patterns:

```text
❌ Error: Invalid plan argument format

Expected formats:
- Directory: /rptc:tdd "@plan-name/"
- Monolithic: /rptc:tdd "@plan-name.md"

Your input: "@[user's input]"

Please specify plan format explicitly.
```

**If no plan provided** (simple work item):

1. Create quick implementation plan
2. Define test scenarios
3. List steps
4. Proceed with TDD (direct execution, monolithic approach)

**CRITICAL - Plan Synchronization**:

**For Directory Format**:
- Update step status in individual `step-NN.md` files
- Mark step complete after sub-agent finishes
- Update overview with progress

**For Monolithic Format**:
- Mark tests complete `- [x]` as they pass
- Mark implementation steps complete `- [x]` as they finish
- Update plan status from "Planned" to "In Progress" when starting
- This keeps the living document in sync with actual progress

## Step 0b: Initialize TODO Tracking

**Generate TodoWrite list dynamically from plan steps.**

### Parse Plan Document

1. Read plan document specified in command argument
2. Extract all implementation steps (look for numbered steps or checklist items)
3. Count total steps: N

### Generate TodoWrite List

For each of N plan steps, create 4 TODOs:
- Step X: RED phase
- Step X: GREEN phase
- Step X: REFACTOR phase
- Step X: SYNC plan

After all N steps, add quality gate TODOs:
- REQUEST PM: Efficiency Agent approval
- EXECUTE: Efficiency Agent review
- REQUEST PM: Security Agent approval
- EXECUTE: Security Agent review
- REQUEST PM: Final TDD sign-off
- UPDATE: Mark plan status Complete

### Example TodoWrite (3-step plan)

```json
{
  "tool": "TodoWrite",
  "todos": [
    {"content": "Step 1: RED - Write failing tests", "status": "pending", "activeForm": "Writing tests for Step 1"},
    {"content": "Step 1: GREEN - Implement to pass", "status": "pending", "activeForm": "Implementing Step 1"},
    {"content": "Step 1: REFACTOR - Improve quality", "status": "pending", "activeForm": "Refactoring Step 1"},
    {"content": "Step 1: SYNC - Update plan", "status": "pending", "activeForm": "Syncing plan for Step 1"},

    {"content": "Step 2: RED - Write failing tests", "status": "pending", "activeForm": "Writing tests for Step 2"},
    {"content": "Step 2: GREEN - Implement to pass", "status": "pending", "activeForm": "Implementing Step 2"},
    {"content": "Step 2: REFACTOR - Improve quality", "status": "pending", "activeForm": "Refactoring Step 2"},
    {"content": "Step 2: SYNC - Update plan", "status": "pending", "activeForm": "Syncing plan for Step 2"},

    {"content": "Step 3: RED - Write failing tests", "status": "pending", "activeForm": "Writing tests for Step 3"},
    {"content": "Step 3: GREEN - Implement to pass", "status": "pending", "activeForm": "Implementing Step 3"},
    {"content": "Step 3: REFACTOR - Improve quality", "status": "pending", "activeForm": "Refactoring Step 3"},
    {"content": "Step 3: SYNC - Update plan", "status": "pending", "activeForm": "Syncing plan for Step 3"},

    {"content": "REQUEST PM: Efficiency Agent approval", "status": "pending", "activeForm": "Requesting Efficiency Agent approval"},
    {"content": "EXECUTE: Efficiency Agent review", "status": "pending", "activeForm": "Running Efficiency Agent"},
    {"content": "REQUEST PM: Security Agent approval", "status": "pending", "activeForm": "Requesting Security Agent approval"},
    {"content": "EXECUTE: Security Agent review", "status": "pending", "activeForm": "Running Security Agent"},
    {"content": "REQUEST PM: Final TDD sign-off", "status": "pending", "activeForm": "Requesting final sign-off"},
    {"content": "UPDATE: Mark plan status Complete", "status": "pending", "activeForm": "Updating plan status"}
  ]
}
```

**TodoWrite Rules**:
- Parse plan to determine N (number of steps)
- Create 4 TODOs per step (RED/GREEN/REFACTOR/SYNC)
- Add 6 quality gate TODOs at end
- Total TODOs = (N × 4) + 6
- Only ONE task "in_progress" at a time
- Mark tasks "completed" immediately after finishing each phase

### Phase 1: TDD Cycle for Each Step (REQUIRED)

**Execution Strategy Based on Plan Format**:

- **Directory Format**: Delegate each step to TDD sub-agent
- **Monolithic Format**: Execute directly (existing workflow)

**For EACH implementation step, choose execution path**:

---

## Phase 1a: Directory Format - Sub-Agent Delegation

**If using directory format, follow this process for each step**:

### For Each Step (1 through N):

#### Step N: Load Step File

**Update TodoWrite**: Mark "Step N: RED - Write failing tests" as in_progress

1. **Load step file**: `$ARTIFACT_LOC/plans/[plan-name]/step-0N.md`
   - If missing: Error with message: "Step N file not found: step-0N.md"
   - Suggestion: "Run `/rptc:helper-update-plan` to regenerate"

2. **Extract step details**:
   - Step name/title
   - Purpose and requirements
   - Test scenarios
   - Expected outcome
   - Acceptance criteria

3. **Prepare sub-agent context**:
   - Overall feature context (from overview.md)
   - Current step details (from step-0N.md)
   - Cumulative file changes (from Steps 1 through N-1)
   - Configuration values (ARTIFACT_LOC, THINKING_MODE, MAX_ATTEMPTS)

#### Step N: Delegate to TDD Sub-Agent

**Create TDD Sub-Agent** with this prompt:

```text
Use $THINKING_MODE thinking mode for this TDD implementation step.

You are a TDD EXECUTION SUB-AGENT for a single implementation step.

Your mission: Execute RED → GREEN → REFACTOR cycle for Step $STEP_NUM ONLY.

## Overall Feature Context (from overview)

[Pass entire OVERVIEW content from overview.md]

## Your Step (Step $STEP_NUM)

[Pass entire STEP_CONTENT from step-0N.md]

## Cumulative File Changes (from prior steps)

Files modified/created in Steps 1 through $STEP_NUM-1:
[Pass list of files with brief description of changes]

If this is Step 1: "No prior changes (first step)"

## Execute TDD Cycle

**CRITICAL**: Follow TDD methodology strictly.

### 1. RED Phase: Write ALL Tests First

**BEFORE any implementation code**:

1. Review test scenarios from step file
2. Write ALL tests for this step:
   - Happy path tests
   - Edge case tests
   - Error condition tests
   - Follow project's test conventions
3. Verify tests FAIL for right reasons
4. Show failure output

**Report RED State**:
```text
🔴 RED Phase Complete - Step $STEP_NUM

Tests written: [X] tests
- ❌ [test 1 name]
- ❌ [test 2 name]
- ❌ [test 3 name]

All tests failing as expected (no implementation yet).
```

### 2. GREEN Phase: Minimal Implementation to Pass Tests

Write ONLY enough code to pass current tests.

1. **Implement minimal solution**:
   - Focus on correctness, not elegance
   - No premature optimization
   - Just make tests pass

2. **Auto-iterate if tests fail** (max $MAX_ATTEMPTS attempts):
   - Each iteration:
     - Analyze specific failure
     - Make targeted fix
     - Re-run tests
     - Report progress

**Report Each Iteration**:
```text
Iteration [N]: [What was fixed]
Tests: [X] passing, [Y] failing
```

**If still failing after $MAX_ATTEMPTS iterations**:
```text
❌ Auto-iteration limit reached ($MAX_ATTEMPTS attempts)

Persistent failure: [test name]
Error: [error message]

Requesting guidance from main TDD executor...
```

**Report GREEN State**:
```text
🟢 GREEN Phase Complete - Step $STEP_NUM

✅ All tests passing ([X] tests)
```

### 3. REFACTOR Phase: Improve Code Quality

Now that tests are green, improve the code.

1. **Code improvements**:
   - Remove duplication
   - Improve naming
   - Extract functions
   - Add clarifying comments
   - Simplify complex logic

2. **Run tests after EACH refactor**:
   - Ensure tests still pass
   - If tests fail, fix and continue

**Report REFACTOR Complete**:
```text
🔧 REFACTOR Phase Complete - Step $STEP_NUM

Improvements made:
- [Improvement 1]
- [Improvement 2]

✅ All tests still passing
✅ Code quality improved
```

## Return Summary

Provide this summary when returning control to main TDD executor:

**Step $STEP_NUM Completion Report**:
- Tests written: [X] tests
- Tests passing: [X] tests (MUST be 100%)
- Files modified: [list with brief descriptions]
- Files created: [list with brief descriptions]
- Coverage for this step: [Y]%
- Refactorings applied: [list]
- Blockers or notes: [any issues or important notes]

**CRITICAL**: All tests MUST pass before returning. If blocked after $MAX_ATTEMPTS iterations, explain blocker and request guidance.
```

#### Step N: Process Sub-Agent Results

1. **Verify completion**:
   - All tests passing? (CRITICAL)
   - Step requirements met?
   - Acceptance criteria satisfied?

2. **Update cumulative file list**:
   - Add files modified in this step
   - Add files created in this step
   - Track for next step's context

3. **Mark step complete**:
   - Update TodoWrite: "Step N: RED" → completed
   - Update TodoWrite: "Step N: GREEN" → completed
   - Update TodoWrite: "Step N: REFACTOR" → completed

4. **Sync plan**:
   - Update TodoWrite: Mark "Step N: SYNC - Update plan" as in_progress
   - Mark step complete in step-0N.md file (if using checklist format)
   - Update overview.md progress section (if exists)
   - Update TodoWrite: Mark "Step N: SYNC - Update plan" as completed

5. **Report step completion**:

```text
✅ Step $STEP_NUM Complete: [Step Name]

Tests: [X] passing
Files modified: [list]
Files created: [list]
Coverage: [Y]% (for this step)

📝 Plan synchronized: Step $STEP_NUM marked complete

[If more steps remaining:]
Next: Step [N+1] - [Next step name]

[If all steps complete:]
All implementation steps complete! Proceeding to quality gates...
```

**Repeat for all N steps**, then proceed to Phase 2 (Quality Gates).

---

## Phase 1b: Monolithic Format - Direct Execution (Backward Compatibility)

**If using monolithic format, follow this process for each step**:

#### RED Phase: Write Tests First ❌

**Update TodoWrite**: Mark "Step X: RED - Write failing tests" as in_progress

**CRITICAL**: Write tests BEFORE any implementation code.

1. **Review step's test requirements**

   - Read "Tests to Write First" from plan
   - Understand expected behavior
   - Identify edge cases

2. **Write ALL tests for this step**

   - Use descriptive test names
   - Cover happy path
   - Cover edge cases
   - Cover error conditions
   - Follow project's test conventions

3. **Verify tests FAIL**
   - Run tests
   - Confirm they fail for the RIGHT reasons
   - Show failure output

**Report RED State**:

**FORMATTING NOTE:** Each list item MUST be on its own line with proper newlines.

```text
🔴 RED Phase Complete - Step [N]: [Step Name]

Tests written: [X] tests
- ❌ [test 1 name]
- ❌ [test 2 name]
- ❌ [test 3 name]

All tests failing as expected (no implementation yet).

Proceeding to GREEN phase...
```

**Update TodoWrite**: Mark "Step X: RED - Write failing tests" as completed

#### GREEN Phase: Minimal Implementation ✅

**Update TodoWrite**: Mark "Step X: GREEN - Implement to pass" as in_progress

**Write ONLY enough code to pass current tests.**

1. **Implement minimal solution**

   - Focus on correctness, not elegance
   - No premature optimization
   - No extra features
   - Just make tests pass

2. **Run tests**

   - Execute test suite
   - Check results

3. **Auto-Iteration (if tests fail)**
   - Maximum $MAX_ATTEMPTS iterations per step
   - Each iteration:
     - Analyze specific failure
     - Make targeted fix
     - Re-run tests
     - Report progress
   - **DO NOT create separate TODOs per iteration** (aggregate in GREEN phase)

**Report Each Iteration**:

**FORMATTING NOTE:** Ensure each status line is on its own line.

```text
Iteration [N]: [What was fixed]
Tests: [X] passing, [Y] failing
[If not all passing, continue iteration...]
```

**Report GREEN State**:

**FORMATTING NOTE:** Keep all status items on separate lines.

```text
🟢 GREEN Phase Complete - Step [N]: [Step Name]

✅ All tests passing ([X] tests)

Proceeding to REFACTOR phase...
```

**Update TodoWrite**: Mark "Step X: GREEN - Implement to pass" as completed

#### REFACTOR Phase: Improve Quality 🔧

**Update TodoWrite**: Mark "Step X: REFACTOR - Improve quality" as in_progress

**Now that tests are green, improve the code.**

1. **Code improvements**

   - Remove duplication
   - Improve naming
   - Extract functions
   - Add clarifying comments
   - Simplify complex logic

2. **Run tests after EACH refactor**

   - Ensure tests still pass
   - If tests fail, fix and continue
   - Keep iterating until tests green

3. **Final verification**
   - Run full test suite
   - Check for regressions
   - Verify code quality

**Report REFACTOR Complete**:

**FORMATTING NOTE:** Each improvement and status line must be on its own line.

```text
🔧 REFACTOR Phase Complete - Step [N]: [Step Name]

Improvements made:
- [Improvement 1]
- [Improvement 2]

✅ All tests still passing
✅ Code quality improved

Step [N] complete!
```

**Update TodoWrite**: Mark "Step X: REFACTOR - Improve quality" as completed

#### Verify Step Complete & Sync Plan

**Update TodoWrite**: Mark "Step X: SYNC - Update plan" as in_progress

**After each step**:

1. **Update plan document** (`$ARTIFACT_LOC/plans/[plan-name].md`):

   - Mark step complete: Change `- [ ]` to `- [x]` for this step
   - Mark all tests for this step complete
   - Save updated plan

2. **Report completion**:

**FORMATTING NOTE:** Each status line (Tests, Files, Coverage) must be on separate lines with proper newlines.

```text
✅ Step [N] Complete: [Step Name]

Tests: [X] passing
Files modified: [list]
Coverage: [Y]% (for new code)

📝 Plan synchronized: Step [N] marked complete in `$ARTIFACT_LOC/plans/[plan-name].md`

[If more steps remaining:]
Next: Step [N+1] - [Next step name]

[If all steps complete:]
All implementation steps complete! Proceeding to quality gates...
```

**Update TodoWrite**: Mark "Step X: SYNC - Update plan" as completed

**CRITICAL**: Never skip plan synchronization. The plan is a living document that must reflect actual progress.

---

**CRITICAL VALIDATION CHECKPOINT - NON-NEGOTIABLE QUALITY GATE**

Before executing Master Efficiency Agent:

**TodoWrite Check**: "REQUEST PM: Efficiency Agent approval" MUST be completed

**Verification**:
1. All implementation steps MUST be completed
2. All tests MUST be passing
3. PM approval MUST be obtained

❌ **QUALITY GATE BLOCKED** - Cannot proceed to Efficiency review without PM approval

**Required**: PM must explicitly approve efficiency review

**ENFORCEMENT**: If PM has NOT approved:
1. Verify all tests passing
2. Present implementation summary
3. Ask: "Ready for Master Efficiency Agent review?"
4. Explain: "MUST get PM approval - CANNOT PROCEED without efficiency review"
5. Wait for explicit "yes" or "approved"
6. NEVER skip this gate without explicit override

**Override Phrase**: PM may say "SKIP EFFICIENCY REVIEW - I ACCEPT THE RISKS"

**This is a NON-NEGOTIABLE quality gate. Efficiency review ensures code maintainability and follows KISS/YAGNI principles.**

---

### Phase 2: Master Efficiency Agent Review (WITH PERMISSION)

**CRITICAL - NON-NEGOTIABLE QUALITY GATE**

**TodoWrite Check**: All implementation steps must be completed before requesting Efficiency Agent

**CRITICAL**: After ALL tests passing, request efficiency review.

**Step 1: Use Configured Thinking Mode**:

Thinking mode already loaded in Step 0a configuration: `$THINKING_MODE`

**Step 2: Ask PM for Permission**:

**Update TodoWrite**: Mark "REQUEST PM: Efficiency Agent approval" as in_progress

**FORMATTING NOTE:** Each list item must be on its own line with proper newlines.

```text
✅ Implementation Complete - All Tests Passing!

All [N] steps implemented successfully.
- Total tests: [X] passing
- Overall coverage: [Y]%
- Files changed: [Z]

**Ready for Master Efficiency Agent review?**

The Master Efficiency Agent will:
- Remove unused imports/variables/code
- Simplify overly complex logic
- Improve code readability
- Identify over-engineering
- Ensure KISS and YAGNI principles

💡 Thinking Mode:
[If global default exists: Will use configured mode: "[mode]" (~[X]K tokens)]
[If no global default: Will use default mode: "think" (~4K tokens)]

Ready to delegate to Master Efficiency Agent?
- Type "yes" or "approved" to proceed with configured mode
- To override thinking mode, say: "yes, use ultrathink" (or "think hard")

Available modes: "think" (~4K), "think hard" (~10K), "ultrathink" (~32K)
Configure default in .claude/settings.json: "rptc.defaultThinkingMode"

**IMPORTANT**: Efficiency review is a NON-NEGOTIABLE quality gate.

Waiting for your sign-off...
```

**DO NOT create sub-agent** until PM approves.

**After PM approval**:
- Mark "REQUEST PM: Efficiency Agent approval" as completed
- Mark "EXECUTE: Efficiency Agent review" as in_progress

#### Efficiency Agent Delegation (If Approved)

**Step 1: Determine Final Thinking Mode**:
   - If user specified a mode override (e.g., "yes, use ultrathink"): Use user's choice
   - Else if global default exists in .claude/settings.json: Use that mode
   - Else: Use default "think" mode

**Step 2: Create Sub-Agent**:

**Sub-Agent Prompt**:

```text
Use [determined thinking mode] thinking mode for this efficiency review.

You are a MASTER EFFICIENCY AGENT - a world-class expert in code optimization and simplicity.

Your mission: Improve code efficiency, readability, and simplicity WITHOUT changing functionality.

Context:
- Work item: [work item name]
- Files: [list of modified files]
- Tests: [X] tests passing (DO NOT break these)

**Reference for Standards** (use fallback chain):
Load via fallback (project → user → plugin):
1. .rptc/sop/languages-and-style.md
2. ~/.claude/global/sop/languages-and-style.md
3. ${CLAUDE_PLUGIN_ROOT}/sop/languages-and-style.md

Same for architecture-patterns.md

Apply KISS and YAGNI principles from SOPs.

Review and improve:

## 1. Dead Code Removal
- Unused imports
- Unused variables/functions
- Commented-out code
- Unreachable code

## 2. Simplification
- Over-engineered solutions
- Unnecessary abstractions
- Complex logic that can be simplified
- Redundant code

## 3. Readability
- Unclear variable/function names
- Missing or unclear comments
- Inconsistent formatting
- Hard-to-follow logic flow

## 4. KISS & YAGNI Violations
- Features not in requirements
- Premature optimizations
- Unnecessary future-proofing
- Over-generalization

For EACH improvement:
- Make the change
- Run tests to verify nothing breaks
- Document what was improved

Return summary:
- Changes made (categorized)
- Tests status (must all pass)
- Code quality improvement metrics

CRITICAL: All tests must remain passing. If any test fails, revert that change.
```

**Present Efficiency Results**:

**FORMATTING NOTE:** Ensure each list item is on its own line with proper newlines between items.

```text
🎯 Master Efficiency Agent Complete!

Improvements made:
- Removed [X] unused imports
- Simplified [Y] complex functions
- Improved [Z] variable names
- Removed [W] lines of dead code

Code quality metrics:
- Readability: ⬆️ Improved
- Complexity: ⬇️ Reduced
- Maintainability: ⬆️ Improved

✅ All tests still passing ([X] tests)

Proceeding to security review...
```

**Update TodoWrite**: Mark "EXECUTE: Efficiency Agent review" as completed

---

**CRITICAL VALIDATION CHECKPOINT - NON-NEGOTIABLE QUALITY GATE**

Before executing Master Security Agent:

**TodoWrite Check**: "REQUEST PM: Security Agent approval" MUST be completed

**Verification**:
1. Efficiency review MUST be completed
2. PM approval MUST be obtained for Security review

❌ **QUALITY GATE BLOCKED** - Cannot proceed to Security review without PM approval

**Required**: PM must explicitly approve security review

**ENFORCEMENT**: If PM has NOT approved:
1. Verify Efficiency review complete
2. Present implementation summary
3. Ask: "Ready for Master Security Agent review?"
4. Explain: "MUST get PM approval - CANNOT PROCEED without security review"
5. Wait for explicit "yes" or "approved"
6. NEVER skip this gate without explicit override

**Override Phrase**: PM may say "SKIP SECURITY REVIEW - I ACCEPT THE RISKS"

**This is a NON-NEGOTIABLE quality gate. Security review identifies vulnerabilities and ensures OWASP compliance.**

---

### Phase 3: Master Security Agent Review (WITH PERMISSION)

**CRITICAL - NON-NEGOTIABLE QUALITY GATE**

**TodoWrite Check**: Efficiency review must be completed before requesting Security Agent

**Step 1: Use Configured Thinking Mode**:

Thinking mode already loaded in Step 0a configuration: `$THINKING_MODE`

**Step 2: Ask PM for Permission**:

**Update TodoWrite**: Mark "REQUEST PM: Security Agent approval" as in_progress

**FORMATTING NOTE:** Keep all list items on separate lines.

```text
🎯 Efficiency Review Complete!

**Ready for Master Security Agent review?**

The Master Security Agent will:
- Check for security vulnerabilities
- Validate input sanitization
- Review authentication/authorization
- Identify potential exploits
- Ensure security best practices

💡 Thinking Mode:
[If global default exists: Will use configured mode: "[mode]" (~[X]K tokens)]
[If no global default: Will use default mode: "think" (~4K tokens)]

Ready to delegate to Master Security Agent?
- Type "yes" or "approved" to proceed with configured mode
- To override thinking mode, say: "yes, use ultrathink" (or "think hard")

Available modes: "think" (~4K), "think hard" (~10K), "ultrathink" (~32K)
Configure default in .claude/settings.json: "rptc.defaultThinkingMode"

**IMPORTANT**: Security review is a NON-NEGOTIABLE quality gate.

Waiting for your sign-off...
```

**DO NOT create sub-agent** until PM approves.

**After PM approval**:
- Mark "REQUEST PM: Security Agent approval" as completed
- Mark "EXECUTE: Security Agent review" as in_progress

#### Security Agent Delegation (If Approved)

**Step 1: Determine Final Thinking Mode**:
   - If user specified a mode override (e.g., "yes, use ultrathink"): Use user's choice
   - Else if global default exists in .claude/settings.json: Use that mode
   - Else: Use default "think" mode

**Step 2: Create Sub-Agent**:

**Sub-Agent Prompt**:

```text
Use [determined thinking mode] thinking mode for this security audit.

You are a MASTER SECURITY AGENT - a world-class expert in application security and vulnerability assessment.

Your mission: Identify and fix security vulnerabilities in the implementation.

Context:
- Work item: [work item name]
- Files: [list of modified files]
- Tests: [X] tests passing

**Reference for Standards** (use fallback chain):
Load security SOP via fallback:
1. .rptc/sop/security-and-performance.md
2. ~/.claude/global/sop/security-and-performance.md
3. ${CLAUDE_PLUGIN_ROOT}/sop/security-and-performance.md

Follow OWASP Top 10 guidelines from SOPs.
Check `.context/` for project-specific security requirements.

Security audit areas:

## 1. Input Validation & Sanitization
- User inputs properly validated?
- SQL injection prevention?
- XSS prevention?
- Command injection risks?

## 2. Authentication & Authorization
- Auth checks in place?
- Permission validation?
- Session management secure?
- Token handling correct?

## 3. Data Protection
- Sensitive data encrypted?
- Secrets not exposed?
- PII handled correctly?
- Secure communication (HTTPS)?

## 4. Common Vulnerabilities (OWASP Top 10)
- Injection flaws
- Broken authentication
- Sensitive data exposure
- XML external entities
- Broken access control
- Security misconfiguration
- Cross-site scripting
- Insecure deserialization
- Using components with known vulnerabilities
- Insufficient logging & monitoring

## 5. Best Practices
- Rate limiting where needed?
- Error messages don't leak info?
- Dependencies up to date?
- Secure defaults configured?

For EACH security issue found:
- Severity: [Critical/High/Medium/Low]
- Description: [What's the issue]
- Fix: [How to fix it]
- Implement fix if possible

For EACH fix applied:
- Make the change
- Add security test if needed
- Run all tests to verify
- Document the fix

Return summary:
- Security issues found (by severity)
- Fixes applied
- New security tests added
- Tests status (must all pass)
- Security posture improvement

CRITICAL: All existing tests must pass. Add security tests where needed.
```

**Present Security Results**:

**FORMATTING NOTE:** Ensure each list item is on its own line with proper newlines between items.

```text
🔒 Master Security Agent Complete!

Security audit results:
- Critical issues: [X] (all fixed ✅)
- High issues: [Y] (all fixed ✅)
- Medium issues: [Z] (all fixed ✅)
- Low issues: [W] (noted for future)

Fixes applied:
- [Fix 1 description]
- [Fix 2 description]

New security tests added: [N]

✅ All tests passing ([X] tests)
🔒 Security posture: Improved

TDD implementation complete with quality gates passed!
```

**Update TodoWrite**: Mark "EXECUTE: Security Agent review" as completed

---

**CRITICAL VALIDATION CHECKPOINT - CANNOT MARK COMPLETE WITHOUT PM APPROVAL**

Before marking TDD phase complete:

**TodoWrite Check**: "REQUEST PM: Final TDD sign-off" MUST be completed

**Verification**:
1. All implementation steps completed
2. Efficiency review completed
3. Security review completed
4. All tests passing

❌ **COMPLETION BLOCKED** - Cannot mark TDD complete without PM sign-off

**Required**: PM must confirm implementation is ready for commit

**ENFORCEMENT**: If PM has NOT approved:
1. Present completion summary (all checks passed)
2. Ask: "TDD Phase Complete - Ready for commit?"
3. Wait for explicit "yes" or "approved"
4. NEVER update plan status without PM confirmation

**This is a NON-NEGOTIABLE gate. TDD completion marks implementation ready for commit - PM must verify this.**

---

### Phase 4: Final PM Sign-Off (REQUIRED)

**CRITICAL - CANNOT MARK TDD COMPLETE WITHOUT PM APPROVAL**

**TodoWrite Check**: Both quality gates must be completed

**Update TodoWrite**: Mark "REQUEST PM: Final TDD sign-off" as in_progress

**Get explicit approval to complete TDD phase**:

**FORMATTING NOTE:** Ensure each list item is on its own line. Never concatenate items (e.g., `- Item 1- Item 2` is WRONG).

```text
✅ TDD Implementation Complete with Quality Gates!

Summary:
- Implementation: ✅ All [N] steps complete
- Tests: ✅ [X] tests passing
- Coverage: ✅ [Y]%
- Efficiency Review: ✅ Complete
- Security Review: ✅ Complete

Files changed: [Z]
- [file 1]
- [file 2]
...

**TDD Phase Complete - Ready for commit?**

Type "yes" or "approved" to mark TDD complete and proceed to commit phase.
Type "modify" if changes needed.

Waiting for your final sign-off...
```

**DO NOT update plan status** until PM approves.

**After PM approval**:
- Mark "REQUEST PM: Final TDD sign-off" as completed
- Mark "UPDATE: Mark plan status Complete" as in_progress

### Phase 5: Update Plan Status (Only After Approval)

Once approved:

1. Update plan document (`$ARTIFACT_LOC/plans/[plan-name].md`):

   - Change status from "In Progress" to "Complete"
   - Mark all remaining checkboxes as complete
   - Add completion notes
   - Add final test count and coverage

2. **Confirm next step**:

**FORMATTING NOTE:** Each status item must be on its own line.

```text
✅ TDD Phase Approved by Project Manager!

Plan updated: `$ARTIFACT_LOC/plans/[plan-name].md`
- Status: ✅ Complete
- All steps: ✅ Marked complete
- Tests: [X] passing
- Coverage: [Y]%

Next step: `/rptc:commit` or `/rptc:commit pr` to verify and ship!
```

**Update TodoWrite**: Mark "UPDATE: Mark plan status Complete" as completed

✅ All TDD phases complete. TodoWrite list should show all tasks completed.

## Auto-Iteration Rules

**When tests fail during GREEN phase**:

- **Maximum $MAX_ATTEMPTS iterations** per test failure
- **Each iteration**:
  1. Analyze failure message carefully
  2. Identify root cause
  3. Make minimal, targeted fix
  4. Re-run tests
  5. Report: "Iteration N: [what was fixed] → [result]"

**If still failing after $MAX_ATTEMPTS iterations**:

**FORMATTING NOTE:** Ensure each option is on its own line with proper newlines.

```text
❌ Auto-iteration limit reached ($MAX_ATTEMPTS attempts)

Persistent failure: [test name]
Error: [error message]

The test strategy or implementation approach may need reconsideration.

Options:
1. Review test expectations
2. Reconsider implementation approach
3. Ask PM for guidance

What would you like to do?
```

**Never proceed with failing tests** - that violates TDD principles.

## Interaction Guidelines

### DO:

- ✅ Write tests BEFORE implementation (always)
- ✅ Follow RED → GREEN → REFACTOR cycle strictly
- ✅ Auto-iterate on test failures (max $MAX_ATTEMPTS)
- ✅ Run tests after every change
- ✅ Ask permission before quality gate sub-agents
- ✅ Keep all tests passing
- ✅ Get PM sign-off before completing

### DON'T:

- ❌ Write implementation before tests
- ❌ Skip any TDD phase
- ❌ Proceed with failing tests
- ❌ Create sub-agents without permission
- ❌ Mark complete without PM approval
- ❌ Skip quality gates

## Example Interaction Flow

**Example 1: Directory Format (Recommended)**

```text
User: /rptc:tdd "@user-authentication/"

Agent: 📋 Plan Loaded (Directory Format): User Authentication System

Overview:
Implement OAuth-based authentication system with JWT tokens,
password reset flow, and security hardening.

Steps to implement: 5
(Step details will be loaded per-step during Phase 1)

Test Strategy:
- Coverage target: 85%
- Test files: tests/auth/*.test.js
- Focus: Security, token validation, error handling

Architecture:
Directory-based plan with sub-agent delegation per step.
Quality gates (Efficiency/Security) execute after ALL steps complete.

Ready to begin TDD implementation with sub-agent delegation.

---

[For each step, TDD delegates to sub-agent with context...]

---

✅ Implementation Complete - All Tests Passing!
[Proceeds to quality gates...]
```

**Example 2: Monolithic Format (Backward Compatibility)**

```text
User: /rptc:tdd "@user-authentication.md"

Agent: 📋 Plan Loaded (Monolithic Format): User Authentication System

Steps to implement: 5
1. OAuth Strategy Setup
2. JWT Token Management
3. Password Reset Flow
4. Frontend Integration
5. Security Hardening

Ready to begin TDD implementation.

---

🔴 RED Phase - Step 1: OAuth Strategy Setup

Writing tests first...
✅ Tests written: 4 tests
- ❌ should configure Google OAuth strategy
- ❌ should configure GitHub OAuth strategy
- ❌ should handle OAuth callback
- ❌ should validate OAuth tokens

All tests failing as expected (no implementation yet).

Proceeding to GREEN phase...

---

🟢 GREEN Phase - Step 1: OAuth Strategy Setup

Implementing OAuth strategy setup...
Running tests...

Iteration 1: Configured Passport strategies → ❌ 2 tests still failing
Iteration 2: Added token validation → ✅ All tests passing!

✅ All tests passing (4 tests)

Proceeding to REFACTOR phase...

---

🔧 REFACTOR Phase - Step 1

Improvements made:
- Extracted OAuth config to separate file
- Improved error handling
- Added explanatory comments

✅ All tests still passing

Step 1 complete!

---

[Steps 2-5 follow same pattern...]

---

✅ Implementation Complete - All Tests Passing!

All 5 steps implemented successfully.
- Total tests: 23 passing
- Overall coverage: 87%
- Files changed: 12

**Ready for Master Efficiency Agent review?**
[Details...]

User: yes

Agent: [Creates Efficiency Agent...]

🎯 Master Efficiency Agent Complete!
[Results...]

**Ready for Master Security Agent review?**
[Details...]

User: yes

Agent: [Creates Security Agent...]

🔒 Master Security Agent Complete!
[Results...]

---

✅ TDD Implementation Complete with Quality Gates!

**TDD Phase Complete - Ready for commit?**

User: approved

Agent: ✅ TDD Phase Approved!

Next step: `/rptc:commit pr`
```

## Success Criteria

- [ ] Plan loaded and understood
- [ ] All steps implemented using TDD cycle
- [ ] All tests passing (no failures)
- [ ] Coverage meets targets (80%+)
- [ ] PM approved Efficiency Agent review (NON-NEGOTIABLE)
- [ ] Efficiency improvements applied
- [ ] PM approved Security Agent review (NON-NEGOTIABLE)
- [ ] Security issues fixed
- [ ] PM gave final sign-off
- [ ] Plan status updated to Complete
- [ ] Ready for commit phase

---

_Remember: TDD is non-negotiable. Tests first, always. Quality gates (Efficiency & Security) are MANDATORY - PM approval required, no skipping allowed._
