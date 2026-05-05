# Provider Task Tracking Guide

**Purpose**: Document provider-native task tracking patterns for RPTC workflow state persistence

**Version**: 1.1.0
**Created**: 2025-10-16
**Last Updated**: 2026-05-04

**Applies To**: RPTC support workflows (Claude: `/rptc:research`, `/rptc:commit`, `/rptc:sync-prod-to-tests`, `/rptc:verify`; Codex: matching `rptc-workflow` intents)

> **Provider mapping**: Claude uses `TodoWrite` for older/simple command tracking and `TaskCreate`/`TaskUpdate` for `/rptc:feat` and `/rptc:fix`. Codex uses `update_plan`. When this guide says "task tracker", use the provider-native mechanism.

---

## Table of Contents

1. [Provider Task Tracking Structure](#provider-task-tracking-structure)
2. [State Management Rules](#state-management-rules)
3. [Integration Patterns Per Command](#integration-patterns-per-command)
4. [Phase Transition Blocking](#phase-transition-blocking)
5. [PM-Centric Approval Pattern](#pm-centric-approval-pattern)
6. [Compaction Persistence](#compaction-persistence)
7. [Anti-Patterns and Gotchas](#anti-patterns-and-gotchas)
8. [Testing and Validation](#testing-and-validation)

---

## Provider Task Tracking Structure

### Provider Mapping

| Provider | Task tracking mechanism | Notes |
|----------|-------------------------|-------|
| Claude | `TodoWrite` | Use for research, commit, sync, verify, and simple phase tracking |
| Claude | `TaskCreate` / `TaskUpdate` | Use where Claude commands define structured task dependencies |
| Codex | `update_plan` | One `in_progress` item at a time; update immediately after each phase |

The state discipline below is universal. The JSON shape is the Claude
`TodoWrite` representation retained for Claude command compatibility. For
Codex, use `update_plan` fields only; treat the examples as conceptual task
state, not as a required schema.

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

**activeForm** (Claude `TodoWrite` only):
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

**Plan/TDD command patterns** (Claude-specific historical note):

> Retained for reference. In Claude, see `claude/commands/feat.md` Step 0.5 for the current `TaskCreate`/`TaskUpdate` pattern. In Codex, use `update_plan`.

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
      "content": "Documentation review (provider-mapped)",
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

**Note**: "Create pull request" only applies if `pr` flag passed. If not creating a PR, use the provider-native skipped/not-applicable state if available; otherwise transition it through `in_progress` to `completed` with a no-op/not-applicable note.

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

**Normal transitions**:
- pending → in_progress (starting work)
- in_progress → completed (finishing work)
- NEVER: completed → anything (final state)
- Avoid pending → completed during normal execution; for provider-native recovery,
  skipped/not-applicable phases, or already-approved re-entry, record the
  provider-supported skipped/not-applicable state or transition through a
  documented no-op.

### Rule 4: Error Recovery Patterns

**If interrupted mid-phase**:
1. Check the provider task tracker
2. Find last "completed" task
3. Resume from next "pending" task
4. Don't duplicate work already completed

**If compaction occurs**:
- Claude `TodoWrite`/task state is restored by Claude session mechanics
- Codex `update_plan` remains in the active session transcript; summarize progress before any session handoff or restart
- All pending items remain
- Continue from current in_progress or next pending

---

## Integration Patterns Per Command

### Research Command Pattern

**Initialize** at command start with 6 phases.

**Update pattern**:
```markdown
**Update task tracker**: Mark "Complete interactive discovery" as in_progress
[Execute phase work...]
**Update task tracker**: Mark "Complete interactive discovery" as completed
```

Repeat for all 6 phases sequentially.

### Plan/TDD Phase Patterns (Deprecated for feat/fix)

> In Claude, `/rptc:feat` and `/rptc:fix` use `TaskCreate`/`TaskUpdate` with `addBlockedBy` for phase ordering and batch tracking. In Codex, use `update_plan`. The patterns below are retained for reference only.

### Commit Command Pattern

**Initialize** at command start with 7 phases.

**Update pattern**:
```markdown
**Update task tracker**: Mark "Pre-commit verification" as in_progress
[Run checks...]
**Update task tracker**: Mark "Pre-commit verification" as completed
```

**Conditional phase**: If no `pr` flag, mark "Create pull request" as skipped/not-applicable when the provider supports that state; otherwise transition it through `in_progress` to `completed` with a no-op/not-applicable note.

---

## Phase Transition Blocking

### Blocking Checkpoint Pattern Template

```markdown
---

**CRITICAL VALIDATION CHECKPOINT - [CONSEQUENCE IF SKIPPED]**

Before [NEXT PHASE]:

**Task Tracker Check**: "[TODO ITEM]" MUST be [completed/passed/approved]

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

1. **Research** (`claude/commands/research.md`; Codex: `rptc-workflow` skill): Block save without PM approval
2. **Commit** (`claude/commands/commit.md`; Codex: `rptc-workflow` skill): Block commit if tests failing
3. **Commit** (`claude/commands/commit.md`; Codex: `rptc-workflow` skill): Block commit if code quality issues

> **Note**: `/rptc:feat` and `/rptc:fix` previously used TodoWrite blocking checkpoints for phase ordering. Claude now uses `TaskCreate`/`TaskUpdate` with `addBlockedBy`; Codex uses `update_plan`.

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

> `/rptc:feat` and `/rptc:fix` approval gates are managed through provider-native questions and task tracking: Claude `AskUserQuestion` plus `TaskCreate`/`TaskUpdate`; Codex direct chat questions plus `update_plan`.

### Automatic Checks and Provider-Mapped Reviews

**Quality Verification Agents** (Phase 4):
- Selected/applicable review roles run in report-only mode; Claude may use command-defined agent behavior, while Codex runs reviews in the main session unless provider policy and explicit user approval allow `spawn_agent`
- Review roles operate in **report-only mode** - they don't make changes
- PM reviews findings and decides which to address
- Main context handles fixes via provider-native task tracking
- Rationale: Review roles provide analysis, PM retains decision authority

**Pre-Commit Verification** (Commit phase):
- Tests, linting, coverage checks run automatically
- BLOCKS if failures detected
- No PM approval needed to RUN checks
- Rationale: Automated quality gate

### Approval Pattern Template

For phases requiring approval:

```markdown
**Task Tracker Check**: "[Approval task]" must be in_progress

**Ask PM**:
Ready for [phase name]?

Type "yes" or "approved" to proceed.

**DO NOT PROCEED** without explicit approval.

**After approval**:
- Mark approval task as completed
- Mark execution task as in_progress
```

---

## Compaction and Session Persistence

### Provider Behavior

Claude:
1. `TodoWrite` is built into the Claude Code system prompt
2. System reminders restore the task list if not updated
3. State persists across `/compact` operations

Codex:
1. `update_plan` is the provider-native task tracker
2. State is visible in the active session transcript
3. For handoffs or restarts, summarize current task state explicitly

### Recovery After Compaction or Resume

If task state seems lost:
1. Check the provider task tracker or latest session summary
2. Find the last completed task
3. Continue from the current in-progress task or next pending task
4. Don't recreate duplicate task lists

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
**Consider updating the task tracker**
**Remember to update status**
```

**DO**:
```markdown
**MUST mark this completed**
**MANDATORY: Update task tracker**
**ALWAYS update status**
```

**Why**: Hard imperatives prevent rationalization and skipping.

---

## Testing and Validation

### Success Criteria Checklist

- [ ] All commands create correct provider task lists
- [ ] State updates happen immediately (not batched)
- [ ] Only ONE task in_progress at a time
- [ ] Blocking gates enforce correctly using provider-native task tracking
- [ ] PM approval gates work correctly
- [ ] Documentation review runs in the provider-approved mode
- [ ] Compaction doesn't lose state
- [ ] Recovery after interruption works
- [ ] 60%+ step-skipping reduction validated
- [ ] 100% quality gate enforcement achieved

---

**End of Provider Task Tracking Guide**
