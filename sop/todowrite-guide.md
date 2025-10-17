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

```json
{
  "tool": "TodoWrite",
  "todos": [
    {
      "content": "Complete interactive discovery",
      "status": "pending",
      "activeForm": "Conducting interactive discovery"
    },
    {
      "content": "Complete codebase exploration",
      "status": "pending",
      "activeForm": "Exploring codebase"
    },
    {
      "content": "Complete web research (if needed)",
      "status": "pending",
      "activeForm": "Conducting web research"
    },
    {
      "content": "Present findings to PM",
      "status": "pending",
      "activeForm": "Presenting findings"
    },
    {
      "content": "Get PM sign-off on research",
      "status": "pending",
      "activeForm": "Requesting PM approval"
    },
    {
      "content": "Save research document",
      "status": "pending",
      "activeForm": "Saving research document"
    }
  ]
}
```

**Plan Command - Simple** (4 phases, for features ≤3 steps):

```json
{
  "tool": "TodoWrite",
  "todos": [
    {
      "content": "Load configuration and context",
      "status": "pending",
      "activeForm": "Loading configuration"
    },
    {
      "content": "Create plan scaffold",
      "status": "pending",
      "activeForm": "Creating plan"
    },
    {
      "content": "Get PM approval",
      "status": "pending",
      "activeForm": "Requesting PM approval"
    },
    {
      "content": "Save plan document",
      "status": "pending",
      "activeForm": "Saving plan"
    }
  ]
}
```

**Plan Command - Complex** (9 phases, for features >3 steps):

```json
{
  "tool": "TodoWrite",
  "todos": [
    {
      "content": "Load configuration and context",
      "status": "pending",
      "activeForm": "Loading configuration"
    },
    {
      "content": "Create initial plan scaffold with PM",
      "status": "pending",
      "activeForm": "Creating plan scaffold"
    },
    {
      "content": "Ask clarifying questions to PM",
      "status": "pending",
      "activeForm": "Asking clarifying questions"
    },
    {
      "content": "Get PM approval for Master Feature Planner delegation",
      "status": "pending",
      "activeForm": "Requesting Master Feature Planner approval"
    },
    {
      "content": "Delegate to Master Feature Planner Agent",
      "status": "pending",
      "activeForm": "Delegating to Master Feature Planner"
    },
    {
      "content": "Present comprehensive plan to PM",
      "status": "pending",
      "activeForm": "Presenting plan to PM"
    },
    {
      "content": "Support iterative refinement if needed",
      "status": "pending",
      "activeForm": "Supporting plan refinement"
    },
    {
      "content": "Get final PM sign-off",
      "status": "pending",
      "activeForm": "Getting final PM approval"
    },
    {
      "content": "Save plan document to .rptc/plans/",
      "status": "pending",
      "activeForm": "Saving plan document"
    }
  ]
}
```

**TDD Command** (dynamic: N×4 + 6 phases, example for 3-step plan):

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

**Total TODOs**: (N × 4) + 6, where N = number of implementation steps in plan

**Commit Command** (7 phases):

```json
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
```

**Note**: "Create pull request" only applies if `pr` flag passed. Mark as completed immediately if not creating PR.

---

## State Management Rules

### Rule 1: Single In-Progress Task

**Only ONE task should be "in_progress" at a time.**

Good:
```json
{"content": "Task 1", "status": "completed"},
{"content": "Task 2", "status": "in_progress"},
{"content": "Task 3", "status": "pending"}
```

Bad:
```json
{"content": "Task 1", "status": "in_progress"},
{"content": "Task 2", "status": "in_progress"},
{"content": "Task 3", "status": "pending"}
```

**Rationale**: Maintains focus, prevents confusion about current state.

### Rule 2: Immediate Completion Marking

**Mark tasks "completed" IMMEDIATELY after finishing.**

Good pattern:
1. Mark "Write tests" as in_progress
2. Write tests
3. Mark "Write tests" as completed (immediate)
4. Mark "Implement code" as in_progress

Bad pattern (batching):
1. Mark "Write tests" as in_progress
2. Write tests
3. Implement code (don't batch!)
4. Mark both as completed (too late)

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

---

## Integration Patterns Per Command

### Research Command Pattern

**Initialize** at command start with 6 phases.

**Update pattern**:
```markdown
**Update TodoWrite**: Mark "Complete interactive discovery" as in_progress
[Execute phase work...]
**Update TodoWrite**: Mark "Complete interactive discovery" as completed
```

Repeat for all 6 phases sequentially.

### Plan Command Pattern

**Initialize** based on complexity assessment:
- Simple features (≤3 steps): 4-phase list
- Complex features (>3 steps): 9-phase list

**Update pattern** (same as research):
```markdown
**Update TodoWrite**: Mark "[phase name]" as in_progress
[Execute phase work...]
**Update TodoWrite**: Mark "[phase name]" as completed
```

### TDD Command Pattern

**Initialize** dynamically from plan:
1. Parse plan document to count steps: N
2. Create (N × 4) + 6 TODOs
3. 4 TODOs per step: RED, GREEN, REFACTOR, SYNC
4. 6 quality gate TODOs at end

**Update pattern**:
```markdown
**Update TodoWrite**: Mark "Step X: RED - Write failing tests" as in_progress
[Write tests...]
**Update TodoWrite**: Mark "Step X: RED - Write failing tests" as completed
```

**Auto-iteration**: GREEN phase may iterate up to 10 times without creating separate TODOs.

### Commit Command Pattern

**Initialize** at command start with 7 phases.

**Update pattern**:
```markdown
**Update TodoWrite**: Mark "Pre-commit verification" as in_progress
[Run checks...]
**Update TodoWrite**: Mark "Pre-commit verification" as completed
```

**Conditional phase**: "Create pull request" marked completed immediately if no `pr` flag.

---

## Phase Transition Blocking

### Blocking Checkpoint Pattern Template

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

### All 8 Blocking Locations

1. **Research** (commands/research.md): Block save without PM approval
2. **Plan** (commands/plan.md): Block Master Planner delegation without PM approval
3. **Plan** (commands/plan.md): Block plan save without PM approval
4. **TDD** (commands/tdd.md): Block Efficiency Agent without PM approval
5. **TDD** (commands/tdd.md): Block Security Agent without PM approval
6. **TDD** (commands/tdd.md): Block TDD completion without PM approval
7. **Commit** (commands/commit.md): Block commit if tests failing
8. **Commit** (commands/commit.md): Block commit if code quality issues

### Imperative Language Keywords

**Use these keywords** in blocking checkpoints:

- **CRITICAL**: Highest priority, cannot be ignored
- **MUST**: Required action, no alternatives
- **NEVER**: Prohibited action, never bypass
- **ALWAYS**: Invariant rule, every time
- **NON-NEGOTIABLE**: Not subject to debate
- **MANDATORY**: Required by system design
- **CANNOT PROCEED**: Blocks forward progress

**Avoid soft language**:

- ❌ "should" → ✅ "MUST"
- ❌ "remember to" → ✅ "ALWAYS"
- ❌ "consider" → ✅ "MANDATORY"
- ❌ "recommended" → ✅ "REQUIRED"
- ❌ "try to" → ✅ "MUST"

**Evidence**: Research shows 80% reduction in step-skipping when using imperative language.

---

## PM-Centric Approval Pattern

### Phases Requiring PM Approval

| Command | Phase | Approval Required |
|---------|-------|-------------------|
| Research | Save document | YES |
| Plan | Master Planner delegation | YES |
| Plan | Save plan | YES |
| TDD | Efficiency Agent | YES |
| TDD | Security Agent | YES |
| TDD | Mark complete | YES |
| Commit | Final commit | YES |
| Commit | Documentation Specialist | NO (automatic) |

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

---

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

---

## Anti-Patterns and Gotchas

### Anti-Pattern 1: Batching Completions

**DON'T**:
```markdown
- Finish 3 tasks
- Update all 3 at once
```

**DO**:
```markdown
- Finish task 1 → Mark completed immediately
- Finish task 2 → Mark completed immediately
- Finish task 3 → Mark completed immediately
```

**Why**: Batching risks progress loss if interrupted.

### Anti-Pattern 2: Skipping In-Progress Transition

**DON'T**:
```json
{"content": "Write tests", "status": "completed"}
```
Direct pending → completed without in_progress

**DO**:
```json
// First: Mark in_progress
{"content": "Write tests", "status": "in_progress"}

// Then: Mark completed
{"content": "Write tests", "status": "completed"}
```

**Why**: In-progress transition signals current focus.

### Anti-Pattern 3: Creating Duplicate TODOs

**DON'T**:
```markdown
Original: "Write tests for Step 1"

// Later, don't create:
"Fix failing test in Step 1"
```

**DO**:
```markdown
"Write tests for Step 1" includes all test iterations
// Auto-iteration in GREEN phase aggregates attempts
```

**Why**: Reduces clutter, maintains clarity.

### Anti-Pattern 4: Using Soft Language

**DON'T**:
```markdown
**You should mark this completed**
**Consider updating the TODO list**
**Remember to update status**
```

**DO**:
```markdown
**MUST mark this completed**
**MANDATORY: Update TODO list**
**ALWAYS update status**
```

**Why**: Hard imperatives prevent rationalization and skipping.

---

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

---

**End of TodoWrite Integration Guide**
