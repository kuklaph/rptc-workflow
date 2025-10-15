---
description: Test-driven implementation with quality gates (efficiency & security reviews)
---

# RPTC: TDD Phase

**You are the TDD implementation executor, following the plan strictly.**
The user is the **project manager** - they approve quality gates and final completion.

Arguments:

- Plan reference: `/rptc:tdd "@plan-name.md"`
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

Load RPTC configuration from settings.json (with fallbacks):

```bash
# Load RPTC configuration
if [ -f ".claude/settings.json" ] && command -v jq >/dev/null 2>&1; then
  ARTIFACT_LOC=$(jq -r '.rptc.artifactLocation // ".rptc"' .claude/settings.json 2>/dev/null)
  MAX_ATTEMPTS=$(jq -r '.rptc.maxPlanningAttempts // 10' .claude/settings.json 2>/dev/null)
else
  ARTIFACT_LOC=".rptc"
  MAX_ATTEMPTS=10
fi
```

### Phase 0: Load Plan (REQUIRED)

**If plan document provided**:

1. Read `$ARTIFACT_LOC/plans/[plan-name].md`
2. Extract implementation steps (look for checkbox items `- [ ]`)
3. Note test strategy
4. Confirm understanding

**Present Plan Summary**:

**FORMATTING NOTE:** Ensure each list item is on its own line with proper newlines.

```text
📋 Plan Loaded: [Work Item Name]

Steps to implement: [N]
1. [ ] [Step 1] - [Brief description]
2. [ ] [Step 2] - [Brief description]
...

Test Strategy:
- Coverage target: 80%+
- Test files: [list]

Ready to begin TDD implementation.
I will keep the plan synchronized by marking tasks complete `- [x]` as I progress.
```

**If no plan provided** (simple work item):

1. Create quick implementation plan
2. Define test scenarios
3. List steps
4. Proceed with TDD

**CRITICAL - Plan Synchronization**:
Throughout implementation, you MUST keep the plan document synchronized:

- Mark tests complete `- [x]` as they pass
- Mark implementation steps complete `- [x]` as they finish
- Update plan status from "Planned" to "In Progress" when starting
- This keeps the living document in sync with actual progress

### Phase 1: TDD Cycle for Each Step (REQUIRED)

**For EACH implementation step, follow this cycle**:

#### RED Phase: Write Tests First ❌

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

#### GREEN Phase: Minimal Implementation ✅

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

#### REFACTOR Phase: Improve Quality 🔧

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

#### Verify Step Complete & Sync Plan

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

**CRITICAL**: Never skip plan synchronization. The plan is a living document that must reflect actual progress.

### Phase 2: Master Efficiency Agent Review (WITH PERMISSION)

**CRITICAL**: After ALL tests passing, request efficiency review.

**Step 1: Check for Global Thinking Mode Configuration**:

```bash
# Check .claude/settings.json for rptc.defaultThinkingMode
if [ -f ".claude/settings.json" ]; then
  cat .claude/settings.json
fi
```

Extract `rptc.defaultThinkingMode` if it exists (e.g., "think", "think hard", "ultrathink")

**Step 2: Ask PM for Permission**:

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
- Type "skip" to proceed without efficiency review
- To override thinking mode, say: "yes, use ultrathink" (or "think hard")

Available modes: "think" (~4K), "think hard" (~10K), "ultrathink" (~32K)
Configure default in .claude/settings.json: "rptc.defaultThinkingMode"

Waiting for your sign-off...
```

**DO NOT create sub-agent** until PM approves.

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

### Phase 3: Master Security Agent Review (WITH PERMISSION)

**Step 1: Check for Global Thinking Mode Configuration**:

```bash
# Check .claude/settings.json for rptc.defaultThinkingMode
if [ -f ".claude/settings.json" ]; then
  cat .claude/settings.json
fi
```

Extract `rptc.defaultThinkingMode` if it exists (e.g., "think", "think hard", "ultrathink")

**Step 2: Ask PM for Permission**:

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
- Type "skip" to proceed without security review
- To override thinking mode, say: "yes, use ultrathink" (or "think hard")

Available modes: "think" (~4K), "think hard" (~10K), "ultrathink" (~32K)
Configure default in .claude/settings.json: "rptc.defaultThinkingMode"

Waiting for your sign-off...
```

**DO NOT create sub-agent** until PM approves.

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

### Phase 4: Final PM Sign-Off (REQUIRED)

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

```text
User: /rptc:tdd "@user-authentication.md"

Agent: 📋 Plan Loaded: User Authentication System

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
- [ ] PM approved Efficiency Agent review (or skipped)
- [ ] Efficiency improvements applied
- [ ] PM approved Security Agent review (or skipped)
- [ ] Security issues fixed
- [ ] PM gave final sign-off
- [ ] Plan status updated to Complete
- [ ] Ready for commit phase

---

_Remember: TDD is non-negotiable. Tests first, always. PM approves quality gates._
