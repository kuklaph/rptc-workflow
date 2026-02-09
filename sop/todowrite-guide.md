# TodoWrite Integration Guide

**Purpose**: Document TodoWrite patterns for RPTC workflow state persistence

**Version**: 1.0.0
**Created**: 2025-10-16
**Last Updated**: 2025-10-16

**Applies To**: `/rptc:research`, `/rptc:commit`, `/rptc:sync-prod-to-tests`, `/rptc:verify`

> **Note**: `/rptc:feat` and `/rptc:fix` no longer use TodoWrite. As of v3.3.0, they use TaskCreate/TaskUpdate with `addBlockedBy` for phase ordering and progress tracking.

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

**Plan/TDD Command patterns** (deprecated — `/rptc:feat` and `/rptc:fix` now use TaskCreate/TaskUpdate as of v3.3.0):

> Retained for reference. See `commands/feat.md` Step 0.5 for the current TaskCreate/TaskUpdate pattern.

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

### Plan/TDD Phase Patterns (Deprecated for feat/fix)

> As of v3.3.0, `/rptc:feat` and `/rptc:fix` use TaskCreate/TaskUpdate with `addBlockedBy` for phase ordering and batch tracking. The patterns below are retained for reference only.

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

### Blocking Locations

1. **Research** (commands/research.md): Block save without PM approval
2. **Commit** (commands/commit.md): Block commit if tests failing
3. **Commit** (commands/commit.md): Block commit if code quality issues

> **Note**: `/rptc:feat` and `/rptc:fix` previously used TodoWrite blocking checkpoints for phase ordering. As of v3.3.0, they use TaskCreate/TaskUpdate with `addBlockedBy` instead. The blocking locations above apply to commands that still use TodoWrite.

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
| Commit | Final commit | YES |

> `/rptc:feat` and `/rptc:fix` approval gates are now managed via AskUserQuestion tool calls and TaskCreate/TaskUpdate, not TodoWrite.

### Automatic Phases (No Approval)

**Quality Verification Agents** (Phase 4):
- All 3 agents (code-review, security, docs) run automatically in parallel
- Agents operate in **report-only mode** - they don't make changes
- PM reviews findings and decides which to address
- Main context handles fixes via TaskCreate/TaskUpdate (feat/fix) or TodoWrite (other commands)
- Rationale: Agents provide analysis, PM retains decision authority

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

2. Run `/rptc:feat "test feature"`
   - Verify 5-phase workflow uses TaskCreate/TaskUpdate (not TodoWrite)
   - This command no longer uses TodoWrite — included here for completeness

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
- [ ] Blocking gates enforce correctly (TodoWrite for research/commit, TaskCreate for feat/fix)
- [ ] PM approval gates work correctly
- [ ] Doc Specialist runs automatically
- [ ] Compaction doesn't lose state
- [ ] Recovery after interruption works
- [ ] 60%+ step-skipping reduction validated
- [ ] 100% quality gate enforcement achieved

---

**End of TodoWrite Integration Guide**
