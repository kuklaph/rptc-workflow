# Step 1: Add TodoWrite to Research Command

## Overview

**Purpose**: Integrate TodoWrite state tracking into the research command to prevent phase skipping during discovery.

**Implementation Location**: `commands/research.md` - After "Step 0a: Load Configuration" section

**Estimated Time**: 2-3 hours

## Research Command Phases

The research command has 6 phases that need TodoWrite tracking:

1. **Phase 1**: Interactive Discovery
2. **Phase 2**: Codebase Exploration
3. **Phase 3**: Web Research (optional, only if needed)
4. **Phase 4**: Findings Presentation
5. **Phase 5**: PM Sign-Off
6. **Phase 6**: Save Research Document

## Implementation Plan

### Step 1.1: Create TodoWrite Initialization Section

**Location**: After "Step 0a: Load Configuration" (currently line ~88)

**Add new section**:

```markdown
## Step 0b: Initialize TODO Tracking

**Initialize TodoWrite to track research progress across all phases.**

Use the TodoWrite tool to create task list:

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

**Important TodoWrite Rules**:
- Mark tasks "in_progress" when starting
- Mark tasks "completed" immediately after finishing
- Only ONE task should be "in_progress" at a time
- Update frequently to prevent system reminders
```

### Step 1.2: Add TodoWrite Updates to Phase 1

**Location**: Beginning of "Phase 1: Interactive Discovery"

**Add instruction**:

```markdown
**Update TodoWrite**: Mark "Complete interactive discovery" as in_progress

[Existing Phase 1 content...]

**Update TodoWrite**: Mark "Complete interactive discovery" as completed
```

### Step 1.3: Add TodoWrite Updates to Phase 2

**Location**: Beginning and end of "Phase 2: Codebase Exploration"

**Add instructions**:

```markdown
**Update TodoWrite**: Mark "Complete codebase exploration" as in_progress

[Existing Phase 2 content...]

**Update TodoWrite**: Mark "Complete codebase exploration" as completed
```

### Step 1.4: Add TodoWrite Updates to Phase 3

**Location**: Beginning and end of "Phase 3: Web Research"

**Add instructions**:

```markdown
**Update TodoWrite**: If web research needed, mark "Complete web research (if needed)" as in_progress

[Existing Phase 3 content...]

**Update TodoWrite**: Mark "Complete web research (if needed)" as completed
```

### Step 1.5: Add TodoWrite Updates to Phase 4

**Location**: Beginning and end of "Phase 4: Findings Presentation"

**Add instructions**:

```markdown
**Update TodoWrite**: Mark "Present findings to PM" as in_progress

[Existing Phase 4 content...]

**Update TodoWrite**: Mark "Present findings to PM" as completed
```

### Step 1.6: Add TodoWrite Updates to Phase 5

**Location**: Beginning and end of "Phase 5: PM Sign-Off"

**Add instructions**:

```markdown
**Update TodoWrite**: Mark "Get PM sign-off on research" as in_progress

**CRITICAL**: You MUST get explicit approval before creating research document.

[Existing Phase 5 content...]

**Update TodoWrite**: After PM approval, mark "Get PM sign-off on research" as completed
```

### Step 1.7: Add TodoWrite Updates to Phase 6

**Location**: Beginning and end of "Phase 6: Save Research Document"

**Add instructions**:

```markdown
**Update TodoWrite**: Mark "Save research document" as in_progress

[Existing Phase 6 content...]

**Update TodoWrite**: Mark "Save research document" as completed

✅ All research phases complete. TodoWrite list should show all tasks completed.
```

### Step 1.8: Manual Workflow Testing

**Test the integration**:

1. Run `/rptc:research "test topic"`
2. Verify TodoWrite creates 6-item list
3. As you progress through phases, verify:
   - Tasks marked "in_progress" when starting
   - Tasks marked "completed" when finishing
   - Only ONE task "in_progress" at a time
4. Complete research and verify all 6 tasks show "completed"

## Acceptance Criteria

- [ ] TodoWrite initializes at command start with 6 phases
- [ ] Each phase marks task "in_progress" before work
- [ ] Each phase marks task "completed" after work
- [ ] Only one task "in_progress" at a time
- [ ] PM approval gate enforced at Phase 5
- [ ] Manual workflow test passes

## Dependencies

- **Requires**: Step 6 (SOP) complete first (defines TodoWrite JSON structure)
- **Enables**: Step 5 (can add blocking validation to research gate)
- **Integrates with**: Step 7 (testing validates research integration)

---

**Next Step**: After completing this step, move to Step 2 (Plan Command) or return to overview.md to review overall progress.
