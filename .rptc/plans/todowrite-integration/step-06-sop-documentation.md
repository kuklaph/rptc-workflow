# Step 6: Create TodoWrite SOP Documentation

## Overview

**Purpose**: Create comprehensive TodoWrite usage guide in `.rptc/sop/todowrite-guide.md` documenting JSON structure, state management, integration patterns, and blocking validation.

**Estimated Time**: 3-4 hours

## SOP Sections

1. **TodoWrite JSON Structure**: Canonical definition (content, status, activeForm)
2. **State Management Rules**: One in_progress, immediate completion, transitions
3. **Integration Patterns Per Command**: Research, Plan, TDD, Commit examples
4. **Phase Transition Blocking**: 8 blocking locations with imperative language
5. **PM-Centric Approval Pattern**: Distinguish automatic vs approval-gated phases
6. **Compaction Persistence**: How TodoWrite survives compaction
7. **Anti-Patterns and Gotchas**: Common mistakes to avoid
8. **Testing & Validation**: How to verify TodoWrite integration

## Implementation Plan

### Step 6.1: Create SOP File Structure

**Create file**: `.rptc/sop/todowrite-guide.md`

**Add metadata**:

```markdown
# TodoWrite Integration Guide

**Purpose**: Document TodoWrite patterns for RPTC workflow state persistence

**Version**: 1.0.0
**Created**: 2025-10-16
**Last Updated**: 2025-10-16

**Applies To**: All RPTC commands (research, plan, tdd, commit)

---

## Table of Contents

1. [TodoWrite JSON Structure](#todowrite-json-structure)
2. [State Management Rules](#state-management-rules)
3. [Integration Patterns Per Command](#integration-patterns-per-command)
4. [Phase Transition Blocking](#phase-transition-blocking)
5. [PM-Centric Approval Pattern](#pm-centric-approval-pattern)
6. [Compaction Persistence](#compaction-persistence)
7. [Anti-Patterns and Gotchas](#anti-patterns-and-gotchas)
8. [Testing and Validation](#testing-and-validation)

---
```

### Step 6.2: Document TodoWrite JSON Structure

**Add section**:

```markdown
## TodoWrite JSON Structure

### Canonical Format

```json
{
  "tool": "TodoWrite",
  "todos": [
    {
      "content": "[Task description in imperative form]",
      "status": "pending" | "in_progress" | "completed",
      "activeForm": "[Human-readable description during work]"
    }
  ]
}
```

### Field Descriptions

**content** (required):
- Imperative form: "Complete interactive discovery", "Write failing tests"
- What needs to be done
- Clear, specific, actionable

**status** (required):
- Must be lowercase: "pending", "in_progress", or "completed"
- Only ONE task should be "in_progress" at a time
- Update immediately when state changes

**activeForm** (required):
- Present continuous form: "Conducting interactive discovery", "Writing tests"
- Shows what's happening NOW
- Provides context during execution

### Command-Specific Examples

**Research Command** (6 phases):
[Include example from Step 1]

**Plan Command - Simple** (4 phases):
[Include example from Step 2]

**Plan Command - Complex** (9 phases):
[Include example from Step 2]

**TDD Command** (dynamic: N×4 + 6):
[Include example from Step 3]

**Commit Command** (7 phases):
[Include example from Step 4]
```

### Step 6.3: Document State Management Rules

**Add section**:

```markdown
## State Management Rules

### Rule 1: Single In-Progress Task

**Only ONE task should be "in_progress" at a time.**

✅ Good:
- Task 1: "completed"
- Task 2: "in_progress"  ← Only one
- Task 3: "pending"

❌ Bad:
- Task 1: "in_progress"  ← Two in-progress!
- Task 2: "in_progress"  ← Violates rule
- Task 3: "pending"

**Rationale**: Maintains focus, prevents confusion about current state.

### Rule 2: Immediate Completion Marking

**Mark tasks "completed" IMMEDIATELY after finishing.**

✅ Good pattern:
1. Mark "Write tests" as in_progress
2. Write tests
3. Mark "Write tests" as completed ← Immediate
4. Mark "Implement code" as in_progress

❌ Bad pattern (batching):
1. Mark "Write tests" as in_progress
2. Write tests
3. Implement code  ← Don't batch!
4. Mark both as completed ← Too late

**Rationale**: Prevents loss of progress if session interrupted.

### Rule 3: Status Transition Rules

**Valid transitions**:
- pending → in_progress (starting work)
- in_progress → completed (finishing work)
- NEVER: completed → anything (final state)
- NEVER: pending → completed (must go through in_progress)

### Rule 4: Error Recovery Patterns

**If interrupted mid-phase**:
1. Check TodoWrite list
2. Find last "completed" task
3. Resume from next "pending" task
4. Don't duplicate work already completed

**If compaction occurs**:
- TodoWrite persists (system prompt protection)
- All pending items remain
- Continue from current in_progress or next pending
```

### Step 6.4: Document Integration Patterns Per Command

**Add section**: Include all 4 command patterns from Steps 1-4 with full examples.

### Step 6.5: Document Phase Transition Blocking

**Add section**: Include blocking template and all 8 locations from Step 5.

### Step 6.6: Document PM-Centric Approval Pattern

**Add section**:

```markdown
## PM-Centric Approval Pattern

### Phases Requiring PM Approval

| Command | Phase | Approval Required |
|---------|-------|-------------------|
| Research | Save document | ✅ YES |
| Plan | Master Planner delegation | ✅ YES |
| Plan | Save plan | ✅ YES |
| TDD | Efficiency Agent | ✅ YES |
| TDD | Security Agent | ✅ YES |
| TDD | Mark complete | ✅ YES |
| Commit | Final commit | ✅ YES |
| Commit | Documentation Specialist | ❌ NO (automatic) |

### Automatic Phases (No Approval)

**Documentation Specialist** (Commit phase):
- Runs automatically after pre-commit checks
- PM reviews output in final summary
- Doesn't require pre-approval
- Rationale: Operational task, not decision gate

**Pre-Commit Verification** (Commit phase):
- Tests, linting, coverage checks run automatically
- BLOCKS if failures detected
- No PM approval needed to RUN checks
- Rationale: Automated quality gate

### Approval Pattern Template

For phases requiring approval:

```markdown
**TodoWrite Check**: "[Approval task]" must be in_progress

**Ask PM**:
Ready for [phase name]?

Type "yes" or "approved" to proceed.

**DO NOT PROCEED** without explicit approval.

**After approval**:
- Mark approval task as completed
- Mark execution task as in_progress
```
```

### Step 6.7: Document Compaction Persistence & Anti-Patterns

**Add section**:

```markdown
## Compaction Persistence

### How TodoWrite Survives Compaction

TodoWrite is built into Claude Code system prompt:
1. TodoWrite tool is always available
2. System reminders restore TODO list if not updated
3. State persists across `/compact` operations
4. Evidence: Every marketplace workflow uses TodoWrite successfully

### Recovery After Compaction

If TodoWrite state seems lost:
1. Check for system reminder with TODO list
2. Last known state will be restored
3. Continue from last completed task
4. Don't recreate TODOs (causes duplicates)

## Anti-Patterns and Gotchas

### Anti-Pattern 1: Batching Completions

❌ **DON'T**:
```markdown
- Finish 3 tasks
- Update all 3 at once
```

✅ **DO**:
```markdown
- Finish task 1 → Mark completed immediately
- Finish task 2 → Mark completed immediately
- Finish task 3 → Mark completed immediately
```

**Why**: Batching risks progress loss if interrupted.

### Anti-Pattern 2: Skipping In-Progress Transition

❌ **DON'T**:
```json
{"content": "Write tests", "status": "completed"}  // Direct pending → completed
```

✅ **DO**:
```json
// First: Mark in_progress
{"content": "Write tests", "status": "in_progress"}

// Then: Mark completed
{"content": "Write tests", "status": "completed"}
```

**Why**: In-progress transition signals current focus.

### Anti-Pattern 3: Creating Duplicate TODOs

❌ **DON'T**:
```markdown
Original: "Write tests for Step 1"

// Later, don't create:
"Fix failing test in Step 1"  ← Duplicate, confusing
```

✅ **DO**:
```markdown
"Write tests for Step 1" includes all test iterations
// Auto-iteration in GREEN phase aggregates attempts
```

**Why**: Reduces clutter, maintains clarity.

### Anti-Pattern 4: Using Soft Language

❌ **DON'T**:
```markdown
**You should mark this completed**
**Consider updating the TODO list**
**Remember to update status**
```

✅ **DO**:
```markdown
**MUST mark this completed**
**MANDATORY: Update TODO list**
**ALWAYS update status**
```

**Why**: Hard imperatives prevent rationalization/skipping.
```

### Step 6.8: Document Testing & Validation

**Add section**:

```markdown
## Testing and Validation

### Manual Workflow Testing

**Test 1: Complete RPTC Workflow**

1. Run `/rptc:research "test topic"`
   - Verify 6-item TodoWrite list created
   - Progress through all phases
   - Verify state updates correctly
   - Confirm all tasks "completed" at end

2. Run `/rptc:plan "@test-topic.md"`
   - Verify correct list (simple vs complex)
   - Test both PM approval gates
   - Confirm plan saves only after approval

3. Run `/rptc:tdd "@test-plan.md"`
   - Verify dynamic TODO generation (N×4 + 6)
   - Test all 3 PM approval gates (Efficiency, Security, Final)
   - Verify quality gates never skipped

4. Run `/rptc:commit pr`
   - Verify 7-phase tracking
   - Test blocking on test failures
   - Verify Doc Specialist runs automatically
   - Confirm PR creation tracked

**Test 2: Compaction Survival**

1. Start workflow with 10-step plan
2. Complete 2-3 steps
3. Take screenshot of TodoWrite list
4. Execute `/compact`
5. Verify TodoWrite list restored
6. Continue workflow from last completed step

**Test 3: Interruption Recovery**

1. Start workflow
2. Complete several tasks
3. Close session (simulate crash)
4. Restart, check TodoWrite state
5. Resume from last completed task

### Success Criteria Checklist

- [ ] All commands create correct TodoWrite lists
- [ ] State updates happen immediately (not batched)
- [ ] Only ONE task in_progress at a time
- [ ] Blocking gates enforce with imperative language
- [ ] PM approval gates work correctly
- [ ] Doc Specialist runs automatically
- [ ] Compaction doesn't lose state
- [ ] Recovery after interruption works
- [ ] 60%+ step-skipping reduction validated
- [ ] 100% quality gate enforcement achieved
```

## Acceptance Criteria

- [x] All 8 sections present and complete
- [x] JSON examples valid (pass linter)
- [x] All 4 commands documented with integration patterns
- [x] All 8 blocking locations documented
- [x] Anti-patterns with DO/DON'T examples
- [x] Cross-references to command files accurate
- [x] SOP follows existing SOP structure/format

## Dependencies

- **Requires**: None (can be done first in execution sequence)
- **Enables**: Steps 1-4 (commands reference SOP for TodoWrite structure)
- **Integrates with**: Step 5 (blocking pattern documented), Step 7 (testing references SOP)

---

## Implementation Status

**Status**: ✅ COMPLETED

**Completion Date**: 2025-10-17

**File Created**: `sop/todowrite-guide.md` (665 lines, 18.6 KB)

**Sections Implemented**:

1. ✅ **TodoWrite JSON Structure** - Canonical format with 5 complete JSON examples
2. ✅ **State Management Rules** - 4 rules (Single in-progress, Immediate completion, Transition rules, Error recovery)
3. ✅ **Integration Patterns Per Command** - All 4 commands with initialization and update patterns
4. ✅ **Phase Transition Blocking** - Template and all 8 blocking locations documented
5. ✅ **PM-Centric Approval Pattern** - Approval table and templates for 7 approval gates
6. ✅ **Compaction Persistence** - Survival mechanism and recovery procedures
7. ✅ **Anti-Patterns and Gotchas** - 4 anti-patterns with DO/DON'T examples
8. ✅ **Testing and Validation** - 3 test scenarios and 10 success criteria

**Verification Results**:

- ✅ All 8 sections present and complete
- ✅ JSON syntax valid (5 examples: canonical + 4 commands)
- ✅ All 4 commands documented (Research, Plan, TDD, Commit)
- ✅ All 8 blocking locations referenced with correct file paths
- ✅ 4 anti-patterns with clear DO/DON'T examples
- ✅ Cross-references verified (all command files exist)
- ✅ SOP structure consistent with existing SOPs (tested-guide.md format)

**Documentation Highlights**:

- **Canonical JSON format** with field descriptions
- **5 complete JSON examples** for all command types
- **4 state management rules** with rationale
- **8 blocking checkpoint locations** with command file references
- **Imperative language guidelines** for preventing step-skipping
- **PM approval pattern table** distinguishing automatic vs approval-gated phases
- **Compaction survival explanation** with recovery procedures
- **4 anti-patterns** preventing common mistakes
- **3 test scenarios** for validating TodoWrite integration

**Cross-References Verified**:

All command file references accurate:
- ✅ `commands/research.md`
- ✅ `commands/plan.md`
- ✅ `commands/tdd.md`
- ✅ `commands/commit.md`

---

**Next Step**: This SOP is now complete and serves as the canonical reference for TodoWrite integration. Steps 1-4 can reference this SOP during command integration work. Return to `overview.md` to review overall TodoWrite integration project progress.
