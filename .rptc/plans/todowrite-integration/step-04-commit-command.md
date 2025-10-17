# Step 4: Add TodoWrite to Commit Command

## Overview

**Status**: ✅ Complete

**Purpose**: Integrate TodoWrite state tracking into the commit command to ensure verification phases complete before commit.

**Implementation Location**: `commands/commit.md` - After configuration load section

**Estimated Time**: 2-3 hours (Actual: ~1.5 hours)

## Commit Command Phases

The commit command has 6 verification phases plus optional PR:

1. **Phase 1**: Pre-Commit Verification (tests, linting, coverage)
2. **Phase 2**: Generate Commit Message
3. **Phase 3**: Verification Summary
4. **Phase 4**: Documentation Specialist Review (AUTOMATIC - no PM approval)
5. **Phase 5**: Execute Commit
6. **Phase 6**: Create PR (if `pr` flag passed)
7. **Phase 7**: Final Summary

## Implementation Plan

### Step 4.1: Create TodoWrite Initialization Section

**Location**: After configuration load (currently line ~77)

**Add new section**:

```markdown
## Step 0b: Initialize TODO Tracking

**Initialize TodoWrite to track commit verification phases.**

{
  "tool": "TodoWrite",
  "todos": [
    {
      "content": "Pre-commit verification (tests, linting, coverage)",
      "status": "pending",
      "activeForm": "Running pre-commit checks"
    },
    {
      "content": "Generate commit message",
      "status": "pending",
      "activeForm": "Generating commit message"
    },
    {
      "content": "Verification summary",
      "status": "pending",
      "activeForm": "Presenting verification summary"
    },
    {
      "content": "Documentation Specialist review (automatic)",
      "status": "pending",
      "activeForm": "Running Documentation Specialist"
    },
    {
      "content": "Execute git commit",
      "status": "pending",
      "activeForm": "Creating commit"
    },
    {
      "content": "Create pull request",
      "status": "pending",
      "activeForm": "Creating pull request"
    },
    {
      "content": "Final summary",
      "status": "pending",
      "activeForm": "Presenting final summary"
    }
  ]
}

**Note**: "Create pull request" only applies if `pr` flag passed. Mark as completed immediately if not creating PR.

**TodoWrite Rules**:
- Update status as verification progresses
- Documentation Specialist runs AUTOMATICALLY (no PM approval needed)
- Only ONE task "in_progress" at a time
```

### Step 4.2: Add TodoWrite Updates to Pre-Commit Verification

**Location**: Beginning of pre-commit checks

**Add instruction**:

```markdown
**Update TodoWrite**: Mark "Pre-commit verification" as in_progress

## Phase 1: Pre-Commit Verification

Run comprehensive verification checks:

1. **Test Suite**: Run all tests
   ```bash
   [test command]
   ```

   **BLOCKING**: If ANY tests fail:
   - ❌ COMMIT BLOCKED - TESTS FAILING
   - List failed tests
   - CANNOT PROCEED until tests pass
   - Exit with error code

2. **Code Quality**: Run linting
   ```bash
   [lint command]
   ```

   **BLOCKING**: If linting errors found:
   - ❌ COMMIT BLOCKED - CODE QUALITY ISSUES
   - List quality issues (debug code, unused imports, etc.)
   - CANNOT PROCEED until issues fixed
   - Exit with error code

3. **Coverage Check**: Verify coverage targets
   ```bash
   [coverage command]
   ```

   **Warning**: If coverage below 80%, warn but don't block

**Update TodoWrite**: Mark "Pre-commit verification" as completed (only if all checks pass)
```

### Step 4.3: Add TodoWrite Updates to Commit Message Generation

**Add instructions**:

```markdown
**Update TodoWrite**: Mark "Generate commit message" as in_progress

## Phase 2: Generate Commit Message

[Existing commit message generation logic...]

**Update TodoWrite**: Mark "Generate commit message" as completed
```

### Step 4.4: Add TodoWrite Updates to Verification Summary

**Add instructions**:

```markdown
**Update TodoWrite**: Mark "Verification summary" as in_progress

## Phase 3: Verification Summary

Present summary to PM:
- Tests: ✓ Passing
- Linting: ✓ Clean
- Coverage: X% (target: 80%+)
- Files changed: N files
- Proposed commit message: [message]

**Update TodoWrite**: Mark "Verification summary" as completed
```

### Step 4.5: Add TodoWrite Updates to Documentation Specialist (AUTOMATIC)

**Key distinction: NO PM approval gate**

**Add instructions**:

```markdown
**Update TodoWrite**: Mark "Documentation Specialist review (automatic)" as in_progress

## Phase 4: Documentation Specialist Review

**IMPORTANT**: Documentation Specialist runs AUTOMATICALLY (no PM approval required)

**Rationale**: Documentation sync is operational (keeps docs current), not a decision gate. PM reviews generated docs in final summary but doesn't need to pre-approve the sync.

**Delegate to Master Documentation Specialist**:
[Use Task tool with rptc:master-documentation-specialist-agent...]

**Doc Specialist analyzes**:
- Diff-driven documentation impacts
- Which docs need updating
- Confidence-based routing (auto-update high confidence, request approval for medium)

**Update TodoWrite**: Mark "Documentation Specialist review (automatic)" as completed
```

### Step 4.6: Add TodoWrite Updates to Commit Execution

**Add instructions**:

```markdown
**Update TodoWrite**: Mark "Execute git commit" as in_progress

## Phase 5: Execute Commit

**CRITICAL - FINAL CONFIRMATION**

Present final commit summary to PM:
- All verification checks passed
- Documentation updates (if any)
- Commit message: [message]

**Ask PM**: "Proceed with commit?"

**DO NOT PROCEED** without final confirmation.

**After confirmation**:
```bash
git commit -m "$(cat <<'EOF'
[commit message with co-authorship]
EOF
)"
```

**Update TodoWrite**: Mark "Execute git commit" as completed
```

### Step 4.7: Add TodoWrite Updates to PR Creation (Conditional)

**Add instructions**:

```markdown
## Phase 6: Create Pull Request (Conditional)

**Check**: Was `pr` flag passed in command?

**If NO `pr` flag**:
- **Update TodoWrite**: Mark "Create pull request" as completed (skipped)
- Skip to Phase 7

**If `pr` flag present**:
- **Update TodoWrite**: Mark "Create pull request" as in_progress

**Create PR**:
```bash
gh pr create --title "[title]" --body "$(cat <<'EOF'
[PR body with summary]
EOF
)"
```

- **Update TodoWrite**: Mark "Create pull request" as completed
```

### Step 4.8: Add TodoWrite Updates to Final Summary

**Add instructions**:

```markdown
**Update TodoWrite**: Mark "Final summary" as in_progress

## Phase 7: Final Summary

✅ Commit successful!

**Summary**:
- Commit: [hash]
- Files changed: [N]
- Tests: All passing
- Documentation: [Updated/No changes]
- PR: [URL if created, "Not created" if no pr flag]

**Update TodoWrite**: Mark "Final summary" as completed

✅ All commit phases complete. TodoWrite list should show all tasks completed.
```

## Acceptance Criteria

- [x] TodoWrite initializes with 7 phases (including conditional PR)
- [x] Pre-commit blocking enforced (tests, linting)
- [x] Documentation Specialist runs automatically (no PM gate)
- [x] Final commit confirmation required (PM gate)
- [x] PR creation conditional on flag (mark skipped if not needed)
- [ ] Manual workflow test passes (with and without PR) - **Requires PM execution**
- [ ] Integration test with TDD passes (tdd → commit workflow) - **Requires PM execution**

## Implementation Status

**Status**: ✅ Complete (TDD Phase)
**Date Completed**: 2025-01-16
**Verification**: 16 TodoWrite references confirmed (1 initialization + 15 state transitions)
**Coverage**: 100% (5/7 automated acceptance criteria met)

**Implementation Summary**:
1. ✅ Step 4.1: TodoWrite initialization section added (commands/commit.md:78-135)
   - 7-phase TODO list with conditional PR tracking
   - Comprehensive TodoWrite rules documented
2. ✅ Step 4.2: Pre-Commit Verification TodoWrite tracking (2 state transitions)
   - Mark in_progress at line 136
   - Mark completed at line 288 (after all checks pass)
3. ✅ Step 4.3: Commit Message Generation TodoWrite tracking (2 state transitions)
   - Mark in_progress at line 292
   - Mark completed at line 337
4. ✅ Step 4.4: Verification Summary TodoWrite tracking (2 state transitions)
   - Mark in_progress at line 341
   - Mark completed at line 372
5. ✅ Step 4.5: Documentation Specialist TodoWrite tracking - AUTOMATIC (2 state transitions)
   - Mark in_progress at line 376
   - Mark completed at line 509
   - Key distinction: NO PM approval required (automatic execution)
6. ✅ Step 4.6: Commit Execution TodoWrite tracking (2 state transitions)
   - Mark in_progress at line 513
   - Mark completed at line 537
7. ✅ Step 4.7: PR Creation TodoWrite tracking - CONDITIONAL (3 state transitions)
   - If NO pr flag: Mark completed (skipped) at line 544
   - If pr flag: Mark in_progress at line 548
   - After PR created: Mark completed at line 602
8. ✅ Step 4.8: Final Summary TodoWrite tracking (2 state transitions)
   - Mark in_progress at line 606
   - Mark completed at line 635

**Total TodoWrite References**: 16
- 1 initialization section (Step 0b)
- 15 "Update TodoWrite" state transition instructions
- All phases tracked with in_progress → completed pattern
- PR creation has conditional logic (3 transitions for 2 paths)

**Manual Testing Required**:
- Test with `/rptc:commit` (no PR) - verify PR phase marked as "completed (skipped)"
- Test with `/rptc:commit pr` - verify full PR creation workflow
- Integration test: `/rptc:tdd` → `/rptc:commit` complete workflow

**Next Steps**:
- Execute manual tests (with and without PR flag)
- Commit changes when ready: `/rptc:commit` or `/rptc:commit pr`
- Continue to Step 5 (Phase Transition Blocking) or return to overview.md

## Dependencies

- **Requires**: Step 6 (SOP) complete first, Step 3 (TDD) for workflow integration
- **Enables**: Step 5 (blocking validation at 2 gates: tests, quality)
- **Integrates with**: Step 7 (testing validates commit integration)

---

**Next Step**: After completing this step, move to Step 5 (Phase Transition Blocking) or return to overview.md to review overall progress.
