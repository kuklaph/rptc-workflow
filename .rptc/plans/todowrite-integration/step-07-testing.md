# Step 7: Testing & Validation

## Overview

**Purpose**: Comprehensive manual testing of TodoWrite integration across all 4 commands to validate 60% step-skipping reduction and 100% quality gate enforcement.

**Estimated Time**: 4-6 hours (includes test execution and documentation)

## Test Categories

1. **Unit Tests** (4): Individual command TodoWrite creation
2. **Integration Tests** (3): Complete workflow end-to-end
3. **Compaction Tests** (3): TodoWrite survival
4. **Blocking Tests** (8): All 8 gates enforce correctly
5. **Performance Tests** (3): Step-skipping reduction, quality gate compliance

**Total**: 21+ test cases

## Implementation Plan

### Step 7.1: Create Test Documentation Structure

**Create directory**: `.rptc/tests/`

**Create files**:
- `todowrite-integration-tests.md` - Master test checklist
- `compaction-survival-tests.md` - Compaction-specific tests
- `blocking-validation-tests.md` - Blocking checkpoint tests
- `performance-measurement.md` - Performance metrics

**Master Test Checklist Template** (`todowrite-integration-tests.md`):

```markdown
# TodoWrite Integration Tests

**Date**: 2025-10-16
**Version**: Priority 1.1
**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

---

## Unit Tests - Command Level

### Test 1.1: Research Command TodoWrite Initialization

**Objective**: Verify research command creates 6-item TodoWrite list

**Steps**:
1. Run `/rptc:research "test authentication patterns"`
2. Verify TodoWrite initializes immediately
3. Count TODO items: Expected 6

**Expected TodoWrite Structure**:
- [ ] "Complete interactive discovery" (pending)
- [ ] "Complete codebase exploration" (pending)
- [ ] "Complete web research (if needed)" (pending)
- [ ] "Present findings to PM" (pending)
- [ ] "Get PM sign-off on research" (pending)
- [ ] "Save research document" (pending)

**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

### Test 1.2: Plan Command TodoWrite Initialization - Simple Path

**Objective**: Verify plan command creates 4-item list for simple features

**Steps**:
1. Run `/rptc:plan "add login button to homepage"` (simple, ≤3 steps)
2. Verify TodoWrite initializes with simple path
3. Count TODO items: Expected 4

**Expected TodoWrite Structure**:
- [ ] "Load configuration and context" (pending)
- [ ] "Create plan scaffold" (pending)
- [ ] "Get PM approval" (pending)
- [ ] "Save plan document" (pending)

**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

### Test 1.3: Plan Command TodoWrite Initialization - Complex Path

**Objective**: Verify plan command creates 9-item list for complex features

**Steps**:
1. Run `/rptc:plan "implement multi-factor authentication system"` (complex, >3 steps)
2. Verify TodoWrite initializes with complex path
3. Count TODO items: Expected 9

**Expected TodoWrite Structure**:
- [ ] "Load configuration and context" (pending)
- [ ] "Create initial plan scaffold with PM" (pending)
- [ ] "Ask clarifying questions to PM" (pending)
- [ ] "Get PM approval for Master Feature Planner delegation" (pending)
- [ ] "Delegate to Master Feature Planner Agent" (pending)
- [ ] "Present comprehensive plan to PM" (pending)
- [ ] "Support iterative refinement if needed" (pending)
- [ ] "Get final PM sign-off" (pending)
- [ ] "Save plan document to .rptc/plans/" (pending)

**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

### Test 1.4: TDD Command TodoWrite Dynamic Generation

**Objective**: Verify TDD command generates dynamic list from plan steps

**Steps**:
1. Create test plan with exactly 3 steps
2. Run `/rptc:tdd "@test-plan.md"`
3. Count TODO items: Expected (3×4) + 6 = 18

**Expected TodoWrite Structure**:
- [ ] 12 step TODOs (3 steps × 4 phases each: RED/GREEN/REFACTOR/SYNC)
- [ ] 6 quality gate TODOs

**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

### Test 1.5: Commit Command TodoWrite Initialization

**Objective**: Verify commit command creates 7-item list

**Steps**:
1. Run `/rptc:commit pr`
2. Verify TodoWrite initializes
3. Count TODO items: Expected 7

**Expected TodoWrite Structure**:
- [ ] "Pre-commit verification" (pending)
- [ ] "Generate commit message" (pending)
- [ ] "Verification summary" (pending)
- [ ] "Documentation Specialist review (automatic)" (pending)
- [ ] "Execute git commit" (pending)
- [ ] "Create pull request" (pending)
- [ ] "Final summary" (pending)

**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

## Integration Tests - Cross-Command

### Test 2.1: Complete RPTC Workflow

**Objective**: Validate TodoWrite state across full workflow

**Steps**:
1. Run `/rptc:research "user session management"`
2. Verify research TodoWrite complete (all 6 tasks "completed")
3. Run `/rptc:plan "@user-session-management.md"`
4. Verify plan TodoWrite creates NEW list (independent from research)
5. Complete plan, verify all tasks "completed"
6. Run `/rptc:tdd "@user-session-management-plan.md"`
7. Verify TDD TodoWrite creates NEW list with dynamic steps
8. Complete implementation, verify all tasks "completed"
9. Run `/rptc:commit`
10. Verify commit TodoWrite creates NEW list
11. Complete commit, verify all tasks "completed"

**Verification Points**:
- [ ] No cross-contamination between command TODO lists
- [ ] Each command initializes fresh TodoWrite
- [ ] State persists within each command
- [ ] All tasks reach "completed" state

**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

### Test 2.2: Phase Transition Tracking

**Objective**: Verify "in_progress" → "completed" transitions work correctly

**Steps**:
1. Start any command
2. At each phase:
   - Verify ONE task marked "in_progress"
   - Complete phase work
   - Verify task marked "completed" immediately
   - Verify next task marked "in_progress"

**Verification**:
- [ ] Only ONE "in_progress" at any time
- [ ] Immediate completion marking (no batching)
- [ ] Sequential progression through tasks

**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

### Test 2.3: PM Approval Gate Integration

**Objective**: Verify PM approval gates integrate with TodoWrite

**Steps**:
1. Run plan command to Master Planner delegation gate
2. Verify TodoWrite shows "Get PM approval for Master Feature Planner delegation" as "in_progress"
3. Provide approval: "yes"
4. Verify task marked "completed"
5. Verify next task ("Delegate to Master Feature Planner") marked "in_progress"

**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

## Compaction Tests

### Test 3.1: TodoWrite Survival After Compaction

**Objective**: Verify TodoWrite state persists across `/compact`

**Steps**:
1. Start workflow with 10-step TDD plan
2. Complete first 3 steps (12 TODOs completed)
3. Take screenshot showing TodoWrite state
4. Execute `/compact`
5. Take screenshot after compaction
6. Compare TODO lists

**Verification**:
- [ ] All "completed" tasks preserved
- [ ] All "pending" tasks preserved
- [ ] Current "in_progress" task preserved
- [ ] No duplicate TODOs created
- [ ] No data loss

**Result**: [ ] PASS | [ ] FAIL
**Screenshots**: Before: _____ After: _____
**Notes**: _______________

---

[Additional compaction tests 3.2 and 3.3...]

---

## Blocking Tests

### Test 4.1: Research Save Blocking

**Location**: `commands/research.md` - Before Phase 6

**Objective**: Verify cannot save research without PM approval

**Steps**:
1. Run research command
2. Complete all phases except PM sign-off
3. Attempt to proceed to save WITHOUT saying "yes"
4. Verify blocking checkpoint appears
5. Provide approval: "yes"
6. Verify save proceeds

**Expected Blocking Message**:
```
❌ PHASE 6 BLOCKED - Cannot save research without PM approval
```

**Verification**:
- [ ] Blocking message appears
- [ ] Command STOPS without approval
- [ ] Imperative language used (CRITICAL, MUST, NEVER)
- [ ] Save proceeds after approval

**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

[Tests 4.2 through 4.8 for remaining blocking locations...]

---

## Performance Tests

### Test 5.1: Step-Skipping Reduction Measurement

**Objective**: Validate 60%+ reduction in step-skipping

**Baseline** (historical, without TodoWrite):
- Workflow sessions with step-skipping: _____ times
- Total workflow sessions: _____
- Baseline skip rate: _____%

**With TodoWrite** (3 complete workflows):

**Workflow 1**:
- Steps skipped: _____
- Total steps: _____
- Skip rate: _____%

**Workflow 2**:
- Steps skipped: _____
- Total steps: _____
- Skip rate: _____%

**Workflow 3**:
- Steps skipped: _____
- Total steps: _____
- Skip rate: _____%

**Average skip rate with TodoWrite**: _____%

**Reduction**: ((Baseline - WithTodoWrite) / Baseline) × 100 = _____%

**Target**: ≥60% reduction
**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

### Test 5.2: Quality Gate Enforcement Compliance

**Objective**: Validate 100% quality gate compliance

**Test Procedure**:
1. Run 5 complete TDD workflows
2. For each, verify:
   - Efficiency Agent invoked: YES/NO
   - Security Agent invoked: YES/NO

**Results**:

| Workflow | Efficiency Agent | Security Agent |
|----------|------------------|----------------|
| 1        | [ ] YES [ ] NO   | [ ] YES [ ] NO |
| 2        | [ ] YES [ ] NO   | [ ] YES [ ] NO |
| 3        | [ ] YES [ ] NO   | [ ] YES [ ] NO |
| 4        | [ ] YES [ ] NO   | [ ] YES [ ] NO |
| 5        | [ ] YES [ ] NO   | [ ] YES [ ] NO |

**Compliance Rate**:
- Efficiency: _____ / 5 (target: 5/5 = 100%)
- Security: _____ / 5 (target: 5/5 = 100%)

**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

### Test 5.3: Token Efficiency Validation

**Objective**: Verify directory-based plan loading saves tokens

**Steps**:
1. Create 10-step feature plan (monolithic: `test-feature.md`)
2. Measure token count: _____ tokens
3. Split into directory structure (overview + step files)
4. During TDD, measure tokens loaded per step:
   - Overview: _____ tokens
   - Step file: _____ tokens
   - Total per step: _____ tokens
5. Compare to loading full monolithic plan: _____ tokens

**Token Savings**: ((Monolithic - PerStep) / Monolithic) × 100 = _____%

**Target**: 75-85% reduction
**Result**: [ ] PASS | [ ] FAIL
**Notes**: _______________

---

## Test Summary

**Date Completed**: _____
**Total Tests**: 21+
**Passed**: _____ / _____
**Failed**: _____ / _____
**Pass Rate**: _____%

**Critical Failures** (must fix):
-

**Non-Critical Issues** (nice to fix):
-

**Recommendations**:
-

---
```

### Step 7.2: Execute Unit Tests (Command-Level)

Run tests 1.1 through 1.5, document results in checklist.

### Step 7.3: Execute Integration Tests (Cross-Command)

Run tests 2.1 through 2.3, verify workflow integration.

### Step 7.4: Execute Compaction Survival Tests

Run test 3.1 (and additional compaction tests), capture screenshots.

### Step 7.5: Execute Blocking Validation Tests

Run all 8 blocking tests (4.1 through 4.8), verify enforcement.

### Step 7.6: Execute Performance & Reliability Tests

Run tests 5.1 through 5.3, measure and record metrics.

### Step 7.7: Create Bug Reporting Template

**Create file**: `.rptc/tests/bug-report-template.md`

```markdown
# Bug Report - TodoWrite Integration

**Date**: _____
**Reported By**: _____

## Bug Description

**What happened**:
**Expected behavior**:
**Actual behavior**:

## Reproduction Steps

1.
2.
3.

## Environment

- Command: `/rptc:___`
- Phase: _____
- TodoWrite state before bug: _____

## Evidence

**Screenshots**:
**Logs**:
**TodoWrite JSON**:

## Impact

**Severity**: [ ] Critical | [ ] High | [ ] Medium | [ ] Low
**Affects**: [ ] All commands | [ ] Specific command: _____

## Root Cause Analysis

**Suspected cause**:
**Related code**:

## Fix Proposal

**Proposed solution**:
**Files to modify**:
```

### Step 7.8: Create Regression Prevention Strategy

**Create file**: `.rptc/tests/regression-prevention.md`

```markdown
# Regression Prevention Strategy

## Cross-Command Impact Matrix

| Change Type | Affects Research | Affects Plan | Affects TDD | Affects Commit |
|-------------|------------------|--------------|-------------|----------------|
| TodoWrite JSON structure | ✅ High | ✅ High | ✅ High | ✅ High |
| Blocking checkpoints | ⚠️ Medium | ⚠️ Medium | ⚠️ Medium | ⚠️ Medium |
| SOP content | ❌ Low | ❌ Low | ❌ Low | ❌ Low |

## When to Run Regression Tests

**Always run full test suite** when modifying:
- TodoWrite JSON structure (affects all 4 commands)
- Blocking checkpoint template (affects 8 locations)
- State management rules (affects all workflows)

**Run targeted tests** when modifying:
- Single command file → Test that command only
- SOP documentation → Spot check one command
- Test documentation → No regression testing needed

## Known Integration Points

1. **Research → Plan**: Research document passed to plan command
2. **Plan → TDD**: Plan document loaded by TDD command
3. **TDD → Commit**: Implementation verification in commit
4. **TodoWrite → All**: JSON structure must match across all commands

## Rollback Procedures

**If critical bug found post-deployment**:
1. Document bug using bug report template
2. Revert to last known good commit
3. Fix in isolation with full test suite
4. Re-deploy with verification

**Rollback command**:
```bash
git revert [commit-hash]
git push origin main
```
```

## Acceptance Criteria

- [ ] All 4 test files created
- [ ] All 21+ tests executed
- [ ] 100% unit test pass rate (4/4)
- [ ] 100% integration test pass rate (3/3)
- [ ] 100% compaction survival (3/3)
- [ ] 100% blocking validation (8/8)
- [ ] 60%+ step-skipping reduction validated
- [ ] Bug template and regression strategy documented
- [ ] All results recorded in test checklists

## Dependencies

- **Requires**: Steps 1-6 complete (full TodoWrite integration implemented)
- **Validates**: All previous steps working correctly as integrated system

---

**Next Step**: After completing all tests, review results and move to final coordination validation or return to overview.md.
