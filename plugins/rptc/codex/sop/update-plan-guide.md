# update_plan Integration Guide

**Purpose**: Document `update_plan` patterns for RPTC workflow state tracking in Codex.

**Applies To**: RPTC research, commit, sync-prod-to-tests, verify, feature, and fix intents in Codex.

> **Note**: This is the Codex adapter for RPTC task tracking. It preserves the original TodoWrite guide's intent: explicit phase state, immediate status updates, approval gates, and interruption recovery.

---

## update_plan Structure

### Canonical Format

Use `update_plan` with a short explanation when helpful and a list of plan items:

```text
update_plan:
  explanation: [optional brief context]
  plan:
    - step: [Task description in imperative form]
      status: pending | in_progress | completed
```

### Field Descriptions

**step**:
- Imperative form: "Complete interactive discovery", "Write failing tests"
- Clear, specific, actionable
- Describes what needs to be done

**status**:
- Must be `pending`, `in_progress`, or `completed`
- Only one task may be `in_progress` at a time
- Update immediately when state changes

**explanation**:
- Optional
- Use when the plan changes, a phase begins, or a blocker changes the workflow
- Keep it concise

---

## Codex Phase Hierarchy

Codex `update_plan` is flat. It does not provide nested, blocking task types.
Preserve RPTC hierarchy through step text and ordering.

### Required Pattern

Keep the top-level workflow phases visible. When approved plan work begins, add
phase-prefixed child items immediately after the active phase instead of
replacing the whole plan with bare implementation steps.

```text
update_plan:
  plan:
    - step: Phase 1: Discovery - Understand scope
      status: completed
    - step: Phase 2: Architecture - Approved implementation plan
      status: completed
    - step: Phase 3: Implementation - Parent phase for approved plan steps
      status: pending
    - step: Phase 3.1: RED - Write parser validation tests
      status: in_progress
    - step: Phase 3.2: GREEN - Implement parser validation
      status: pending
    - step: Phase 4: Quality Verification - Agent review and findings
      status: pending
    - step: Phase 5: Complete - Summarize outcome
      status: pending
```

Because only one item can be `in_progress`, the current child item owns
`in_progress`. The parent phase remains in the list as the phase boundary and is
marked `completed` only after all of its `Phase N.x` children complete.

### Rules

- NEVER replace the phase list with unprefixed implementation tasks.
- ALWAYS import approved implementation plan steps as `Phase 3.x` items.
- ALWAYS import verification agent launches, findings, and re-checks as
  `Phase 4.x` items.
- Treat Phase 3 local checks as implementation checks only. They do not satisfy
  Phase 4.
- Phase 4 is report-only agent verification. Main-context self-review is not a
  substitute.

---

## Command-Specific Examples

### Research Intent

```text
update_plan:
  plan:
    - step: Complete interactive discovery
      status: pending
    - step: Complete codebase exploration
      status: pending
    - step: Complete web research if needed
      status: pending
    - step: Present findings to PM
      status: pending
    - step: Get PM sign-off on research
      status: pending
    - step: Save research document
      status: pending
```

### Commit Intent

```text
update_plan:
  plan:
    - step: Run pre-commit verification
      status: pending
    - step: Generate commit message
      status: pending
    - step: Present verification summary
      status: pending
    - step: Run documentation review
      status: pending
    - step: Execute git commit after approval
      status: pending
    - step: Create pull request if requested
      status: pending
    - step: Present final summary
      status: pending
```

Mark "Create pull request if requested" completed immediately when no PR was requested.

---

## State Management Rules

### Rule 1: Single In-Progress Task

Only one task may be `in_progress` at a time.

Good:
```text
- step: Complete discovery
  status: completed
- step: Write failing tests
  status: in_progress
- step: Implement code
  status: pending
```

Bad:
```text
- step: Complete discovery
  status: in_progress
- step: Write failing tests
  status: in_progress
```

**Rationale**: Maintains focus and prevents confusion about current state.

### Rule 2: Immediate Completion Marking

Mark tasks `completed` immediately after finishing.

Good pattern:
1. Mark "Write tests" as `in_progress`
2. Write tests
3. Mark "Write tests" as `completed`
4. Mark "Implement code" as `in_progress`

Bad pattern:
1. Mark "Write tests" as `in_progress`
2. Write tests
3. Implement code
4. Mark both tasks completed later

**Rationale**: Prevents loss of progress if the session is interrupted.

### Rule 3: Status Transition Rules

Valid transitions:
- `pending` -> `in_progress`
- `in_progress` -> `completed`

Avoid:
- `completed` -> any other state
- `pending` -> `completed` unless the step is intentionally skipped or not applicable

### Rule 4: Error Recovery

If interrupted mid-phase:
1. Review the current plan.
2. Find the last `completed` task.
3. Resume from the current `in_progress` task or next `pending` task.
4. Do not duplicate completed work.

---

## Integration Patterns

### Research Intent

Initialize at start with the research phases.

Update pattern:
```text
Mark "Complete interactive discovery" as in_progress.
Execute phase work.
Mark "Complete interactive discovery" as completed.
```

Repeat sequentially for each phase.

### Feature and Fix Intents

Use `update_plan` for visible phase tracking:
- Discovery or reproduction
- Planning or root cause analysis
- TDD implementation
- Quality verification
- Completion summary

Feature workflows import approved implementation steps as `Phase 3.x`; fix
workflows import approved or direct fix steps as `Phase 3.x`. Both import
verification agent launches, findings, and re-checks as `Phase 4.x`.

When the workflow delegates to Codex custom agents, the parent session owns the plan. Child agents report status and findings back to the parent session.

Parent-session requirements during delegation:
- Keep the delegated `Phase 3.x` implementation/fix item or `Phase 4.1`
  verification item `in_progress` while the parent waits for the agent result.
- While a delegated agent owns the work, wait for its result. Do not start
  independent research, implementation, or verification in the same scope.
- Allowed parent work while waiting is coordination only: maintain plan state,
  prepare the next already-known prompt, and process returned results.
- After the agent returns, update the matching child item before starting the
  next child item.

### Commit Intent

Initialize at start with commit phases. Keep commit execution blocked until explicit user approval.

Conditional phase:
- Mark PR creation completed immediately when no PR was requested.

---

## Phase Transition Blocking

### Blocking Checkpoint Template

```text
CRITICAL VALIDATION CHECKPOINT - [CONSEQUENCE IF SKIPPED]

Before [NEXT PHASE]:

Plan check: "[PLAN ITEM]" MUST be completed, passed, or approved.

Verification:
1. [Check 1]
2. [Check 2]

[PHASE] BLOCKED - [Reason cannot proceed]

Required: [What PM must do]

ENFORCEMENT: If [condition NOT met]:
1. [Action 1]
2. [Action 2]
3. [Never do this]

This is a NON-NEGOTIABLE gate. [Rationale explaining why this gate exists]
```

### Blocking Locations

1. Research: block save without PM approval.
2. Commit: block commit if tests fail.
3. Commit: block commit if code quality issues remain.
4. Feature and fix: block implementation or completion when plan approval, regression tests, or verification gates are missing.

### Imperative Language

Use:
- CRITICAL
- MUST
- NEVER
- ALWAYS
- NON-NEGOTIABLE
- MANDATORY
- CANNOT PROCEED

Avoid:
- "should"
- "remember to"
- "consider"
- "recommended"
- "try to"

---

## PM-Centric Approval Pattern

### Approval Required

| Intent | Phase | Approval Required |
| --- | --- | --- |
| Research | Save document | YES |
| Feature | Implementation plan | YES when plan changes are material |
| Fix | Risky fix path or ambiguous root cause | YES |
| Commit | Final commit | YES |

### Automatic Phases

Quality verification agents may run automatically in report-only mode after implementation when the workflow calls for them. They do not make changes. The parent session reports findings and applies approved fixes.

### Approval Template

```text
Plan check: "[Approval task]" must be in_progress.

Ask PM:
Ready for [phase name]?

Do not proceed without explicit approval.

After approval:
- Mark approval task as completed.
- Mark execution task as in_progress.
```

---

## Compaction and Interruption Recovery

Codex plan state is conversation state, not a permanent project database. Treat it as operational state for the current session.

If context changes, compaction occurs, or the session resumes:
1. Reconstruct the active plan from the latest visible plan and recent work evidence.
2. Verify completed work from files, tests, and command output before marking steps completed.
3. Resume from the current `in_progress` task or next `pending` task.
4. Do not recreate duplicate plan items.

---

## Anti-Patterns

### Batching Completions

Do not finish several tasks and update all statuses at once. Mark each task completed immediately.

### Skipping In-Progress Transition

Do not mark a task completed without first showing it as in progress unless the task is intentionally skipped or not applicable.

### Creating Duplicate Tasks

Keep iterations inside the existing task unless the work becomes a distinct phase or blocker.

### Soft Language

Use direct imperatives for gates. Soft language makes gates easier to skip.

---

## Success Criteria

- All long RPTC workflows create a visible plan.
- Only one task is `in_progress`.
- Status updates happen immediately.
- Approval gates block forward progress.
- Report-only agents do not make changes.
- Parent session owns plan state when using Codex agents.
- Recovery after interruption avoids duplicate work.

---

**End of update_plan Integration Guide**
