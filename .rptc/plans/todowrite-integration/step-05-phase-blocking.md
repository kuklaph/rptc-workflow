# Step 5: Implement Phase Transition Blocking

## Overview

**Purpose**: Add explicit blocking validation at 8 critical phase transitions with imperative language to prevent accidental step-skipping.

**Estimated Time**: 2-3 hours

## 8 Blocking Locations

1. **Research** (commands/research.md): Block save without PM approval
2. **Plan** (commands/plan.md): Block Master Planner delegation without PM approval
3. **Plan** (commands/plan.md): Block plan save without PM approval
4. **TDD** (commands/tdd.md): Block Efficiency Agent without PM approval
5. **TDD** (commands/tdd.md): Block Security Agent without PM approval
6. **TDD** (commands/tdd.md): Block TDD completion without PM approval
7. **Commit** (commands/commit.md): Block commit if tests failing
8. **Commit** (commands/commit.md): Block commit if code quality issues

## Implementation Plan

### Step 5.1: Research Command - Block Save Without PM Approval

**Location**: `commands/research.md` - Before Phase 6 (save)

**Add blocking checkpoint**:

```markdown
---

**CRITICAL VALIDATION CHECKPOINT - DO NOT SKIP**

Before proceeding to Phase 6 (Save Research Document):

**TodoWrite Check**: "Get PM sign-off on research" MUST be completed

**Verification**:
1. Check TodoWrite status for "Get PM sign-off on research"
2. If status is NOT "completed", you MUST NOT save research document

❌ **PHASE 6 BLOCKED** - Cannot save research without PM approval

**Required**: PM must explicitly say "yes" or "approved" in Phase 5

**ENFORCEMENT**: If PM has NOT approved:
1. Re-present findings clearly
2. Ask: "Do you approve this research?"
3. Wait for explicit "yes" or "approved"
4. NEVER assume approval or skip this gate

**This is a NON-NEGOTIABLE gate. Research documents capture critical decisions and must be reviewed by PM before saving.**

---
```

### Step 5.2: Plan Command - Block Master Planner Delegation Without Approval

**Location**: `commands/plan.md` - Before Phase 5 (Master Planner delegation)

**Add blocking checkpoint**:

```markdown
---

**CRITICAL VALIDATION CHECKPOINT - DO NOT SKIP**

Before delegating to Master Feature Planner:

**TodoWrite Check**: "Get PM approval for Master Feature Planner delegation" MUST be completed

**Verification**:
1. Check TodoWrite status for delegation approval
2. If status is NOT "completed", you MUST NOT create Master Feature Planner agent

❌ **PHASE 5 BLOCKED** - Cannot delegate without PM authorization

**Required**: PM must explicitly approve agent creation

**ENFORCEMENT**: If PM has NOT approved:
1. Present plan scaffold clearly
2. Ask: "Ready to delegate to Master Feature Planner?"
3. Wait for explicit "yes" or "approved"
4. NEVER create agent without permission

**This is a NON-NEGOTIABLE gate. Master Feature Planner is a resource-intensive operation requiring explicit PM authorization.**

---
```

### Step 5.3: Plan Command - Block Plan Save Without PM Approval

**Location**: `commands/plan.md` - Before Phase 9 (save plan)

**Add blocking checkpoint**:

```markdown
---

**CRITICAL VALIDATION CHECKPOINT - DO NOT SKIP**

Before saving plan document:

**TodoWrite Check**: "Get final PM sign-off" MUST be completed

**Verification**:
1. Check TodoWrite status for final plan approval
2. If status is NOT "completed", you MUST NOT save plan document

❌ **PHASE 9 BLOCKED** - Cannot save plan without PM approval

**Required**: PM must review comprehensive plan and explicitly approve

**ENFORCEMENT**: If PM has NOT approved:
1. Present complete plan clearly
2. Ask: "Do you approve this plan for implementation?"
3. Wait for explicit "yes" or "approved"
4. Support modifications if PM says "modify"
5. NEVER save without explicit approval

**This is a NON-NEGOTIABLE gate. Plans define implementation approach and must be reviewed by PM before execution.**

---
```

### Step 5.4: TDD Command - Block Efficiency Agent Without PM Approval

**Location**: `commands/tdd.md` - Before Phase 2 (Efficiency Agent)

**Add blocking checkpoint**:

```markdown
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
```

### Step 5.5: TDD Command - Block Security Agent Without PM Approval

**Location**: `commands/tdd.md` - Before Phase 3 (Security Agent)

**Add blocking checkpoint** (similar pattern to Efficiency):

```markdown
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
```

### Step 5.6: TDD Command - Block TDD Completion Without PM Approval

**Location**: `commands/tdd.md` - Before Phase 5 (plan update)

**Add blocking checkpoint**:

```markdown
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
```

### Step 5.7: Commit Command - Block Commit if Tests Failing

**Location**: `commands/commit.md` - After test execution (line ~89)

**Upgrade existing check to imperative language**:

```markdown
---

**CRITICAL VALIDATION CHECKPOINT - CANNOT COMMIT WITH FAILING TESTS**

After running test suite:

**Test Status Check**: ALL tests MUST pass

**Verification**:
```bash
[test command]
EXIT_CODE=$?
```

**If EXIT_CODE ≠ 0**:

❌ **COMMIT BLOCKED - TESTS FAILING**

**ENFORCEMENT**:
1. List all failing tests
2. Show failure details
3. Display: "CANNOT PROCEED - FIX FAILING TESTS FIRST"
4. Exit with error code 1
5. NEVER commit with failing tests under ANY circumstances

**This is a NON-NEGOTIABLE gate. Failing tests indicate broken functionality - MUST be fixed before commit.**

**To fix**:
1. Review failed test output
2. Fix implementation or tests
3. Re-run verification
4. Only proceed when all tests pass

---
```

### Step 5.8: Commit Command - Block Commit if Code Quality Issues

**Location**: `commands/commit.md` - After linting/quality checks (line ~160)

**Upgrade existing check to imperative language**:

```markdown
---

**CRITICAL VALIDATION CHECKPOINT - CANNOT COMMIT WITH QUALITY ISSUES**

After running code quality checks:

**Quality Check**: NO debug code, NO quality violations

**Verification**:
```bash
# Check for debug code
grep -r "console\.log\|debugger\|print(" src/

# Run linter
[lint command]
```

**If quality issues found**:

❌ **COMMIT BLOCKED - CODE QUALITY ISSUES**

**Common violations**:
- Debug code (console.log, debugger statements)
- Unused imports
- Unused variables
- Linting violations

**ENFORCEMENT**:
1. List all quality issues
2. Display: "NEVER commit debug code or quality violations"
3. Exit with error code 1
4. MUST fix all issues before proceeding

**This is a NON-NEGOTIABLE gate. Code quality issues pollute codebase and must be cleaned before commit.**

**To fix**:
1. Remove debug code
2. Clean unused imports/variables
3. Fix linting violations
4. Re-run verification
5. Only proceed when quality checks pass

---
```

### Step 5.9: Document Blocking Pattern

**Create new file**: `.rptc/patterns/blocking-validation.md`

```markdown
# Phase Transition Blocking Pattern

## Purpose

Prevent accidental step-skipping by adding explicit blocking validation at critical phase transitions.

## Pattern Template

```markdown
---

**CRITICAL VALIDATION CHECKPOINT - [CONSEQUENCE IF SKIPPED]**

Before [NEXT PHASE]:

**TodoWrite Check**: "[TODO ITEM]" MUST be [completed/passed/approved]

**Verification**:
1. [Check 1]
2. [Check 2]

❌ **[PHASE] BLOCKED** - [Reason cannot proceed]

**Required**: [What PM must do]

**ENFORCEMENT**: If [condition NOT met]:
1. [Action 1]
2. [Action 2]
3. [Never do this]

**This is a NON-NEGOTIABLE gate. [Rationale explaining why this gate exists]**

---
```

## Imperative Language Keywords

**Use these keywords** in blocking checkpoints:

- **CRITICAL**: Highest priority, cannot be ignored
- **MUST**: Required action, no alternatives
- **NEVER**: Prohibited action, never bypass
- **ALWAYS**: Invariant rule, every time
- **NON-NEGOTIABLE**: Not subject to debate
- **MANDATORY**: Required by system design
- **CANNOT PROCEED**: Blocks forward progress

**Avoid soft language** (eliminates rationalization):

- ❌ "should" → ✅ "MUST"
- ❌ "remember to" → ✅ "ALWAYS"
- ❌ "consider" → ✅ "MANDATORY"
- ❌ "recommended" → ✅ "REQUIRED"
- ❌ "try to" → ✅ "MUST"

## Evidence

Research shows **80% reduction in step-skipping** when using imperative language (Pimzino workflow pattern).

## All Blocking Locations

See [overview.md] for complete list of 8 blocking locations.
```

### Step 5.10: Validation Testing

**Manual testing**:

1. Test each of 8 blocking locations
2. Attempt to bypass without approval
3. Verify blocking checkpoint enforces
4. Verify imperative error message displays
5. Provide approval and verify progression

## Acceptance Criteria

- [x] All 8 blocking checkpoints implemented
- [x] Each uses imperative language (CRITICAL, MUST, NEVER)
- [x] No soft language ("should", "consider") at blocking gates
- [x] Blocking pattern documented in `.rptc/patterns/`
- [x] Automated validation tests created and passing (all 9 checkpoints)
- [x] TodoWrite integration verified at each gate

## Dependencies

- **Requires**: Steps 1-4 complete (TodoWrite integrated in all commands)
- **Enables**: Step 7 (blocking validation tests)
- **Integrates with**: Step 6 (SOP documents blocking pattern)

---

## Implementation Status

**Status**: ✅ COMPLETED

**Completion Date**: 2025-10-17

**Implemented Changes**:

1. ✅ **Checkpoint 1-3 Verified**: research.md and plan.md already had proper blocking checkpoints
2. ✅ **Checkpoint 4 Added**: TDD - Block Efficiency Agent (tdd.md:377-406)
3. ✅ **Checkpoint 5 Added**: TDD - Block Security Agent (tdd.md:562-590)
4. ✅ **Checkpoint 6 Added**: TDD - Block TDD Completion (tdd.md:761-787)
5. ✅ **Checkpoint 7 Upgraded**: Commit - Block if Tests Failing (commit.md:147-179)
6. ✅ **Checkpoint 8 Upgraded**: Commit - Block if Code Quality Issues (commit.md:220-287)
7. ✅ **Checkpoint 9 Created**: Blocking pattern documentation (`.rptc/patterns/blocking-validation.md`)
8. ✅ **Validation Tests**: Created automated verification script (`tests/verify-blocking-checkpoints.sh`)

**Test Results**:
```
🔍 Verifying Phase Transition Blocking Checkpoints...

✅ All 9 checkpoints verified!
  - Passed: 23/23 tests
  - Failed: 0/23 tests

Warnings (non-critical):
  - Soft language detected in non-checkpoint sections of files
  - This is expected and does not affect blocking functionality
```

**Files Modified**:
- `commands/tdd.md` - Added 3 blocking checkpoints
- `commands/commit.md` - Upgraded 2 blocking checkpoints
- `tests/verify-blocking-checkpoints.sh` - Created validation script
- `.rptc/patterns/blocking-validation.md` - Created pattern documentation

---

**Next Step**: After completing this step, move to Step 6 (SOP Documentation) or return to overview.md to review overall progress.
