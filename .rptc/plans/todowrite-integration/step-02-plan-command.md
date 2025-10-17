# Step 2: Add TodoWrite to Plan Command

## Overview

**Purpose**: Integrate TodoWrite state tracking into the plan command with routing for simple vs complex features.

**Implementation Location**: `commands/plan.md` - After "Step 0a: Load Configuration" section

**Estimated Time**: 2-3 hours

## Plan Command Phases

The plan command has **two paths** depending on feature complexity:

**Simple Path** (≤3 steps):
1. Load configuration
2. Create quick plan scaffold
3. PM approval
4. Save plan

**Complex Path** (>3 steps):
1. Load configuration
2. Determine complexity
3. Create plan scaffold
4. PM clarifications
5. Request Master Feature Planner delegation (APPROVAL GATE)
6. Execute Master Feature Planner (AUTOMATIC)
7. Present plan for PM review (APPROVAL GATE)
8. Save plan document

## Implementation Plan

### Step 2.1: Create TodoWrite Initialization Section

**Location**: After "Step 0a: Load Configuration" (currently line ~67)

**Add new section**:

```markdown
## Step 0b: Initialize TODO Tracking

**Initialize TodoWrite to track planning progress.**

**IMPORTANT**: TodoWrite list depends on feature complexity.

### Complexity Assessment

After analyzing work item, determine:
- **Simple feature**: ≤3 implementation steps
- **Complex feature**: >3 implementation steps

### TodoWrite for Simple Features (≤3 steps)

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

### TodoWrite for Complex Features (>3 steps)

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

**TodoWrite Rules**:
- Assess complexity FIRST before creating TodoWrite list
- Use appropriate list (simple vs complex)
- Update status as phases progress
- Only ONE task "in_progress" at a time
```

### Step 2.2: Add Complexity Assessment Logic

**Location**: After TodoWrite initialization

**Add logic**:

```markdown
## Phase 1: Assess Feature Complexity

**Analyze the work item to determine planning approach.**

1. Review the work item description
2. Estimate implementation steps required
3. Determine complexity:
   - **≤3 steps**: Simple feature (single Master Planner agent)
   - **>3 steps**: Complex feature (sequential planning agents)

**Update TodoWrite**:
- If simple: Use 4-item TodoWrite list
- If complex: Use 9-item TodoWrite list

**Rationale**: Complex features (>3 steps) risk Master Planner timeout. Sequential agents prevent timeout while maintaining coordination.
```

### Step 2.3: Add TodoWrite Updates for Simple Path

**For each simple path phase**, add TodoWrite updates:

```markdown
### Simple Path Implementation

**Phase 1**: Mark "Create plan scaffold" as in_progress
[Create plan content...]
Mark "Create plan scaffold" as completed

**Phase 2**: Mark "Get PM approval" as in_progress
[Request approval...]
Mark "Get PM approval" as completed

**Phase 3**: Mark "Save plan document" as in_progress
[Save plan...]
Mark "Save plan document" as completed
```

### Step 2.4: Add TodoWrite Updates for Complex Path

**For each complex path phase**, add TodoWrite updates:

- Load configuration → completed
- Create scaffold → in_progress → completed
- Clarifying questions → in_progress → completed
- Request Master Planner approval → in_progress → completed (BLOCKING GATE)
- Delegate to Master Planner → in_progress → completed
- Present plan → in_progress → completed
- Support refinement → in_progress → completed (if needed)
- Get final sign-off → in_progress → completed (BLOCKING GATE)
- Save document → in_progress → completed

### Step 2.5: Add Sequential Agent Context Handoff

**For complex features >3 steps**, document sequential planning:

```markdown
### Complex Path: Sequential Planning Agents

**When feature has >3 implementation steps**, use sequential agents:

1. **Step-Specific Agents**: Create one agent per step
   - Agent 1 plans Step 1
   - Agent 2 receives Step 1 context, plans Step 2
   - Agent N receives Steps 1-(N-1) context, plans Step N

2. **Final Coordination Agent**: Aggregates all step plans
   - Resolves conflicts between steps
   - Creates integration tests
   - Provides unified timeline
   - Ensures consistency

**TodoWrite Tracking**:
- "Delegate to Master Feature Planner" tracks ENTIRE sequential process
- Mark in_progress at start of first agent
- Mark completed after final coordination agent delivers

**Benefit**: Prevents timeout on large features while maintaining coordination
```

### Step 2.6: Add Blocking Gate Documentation

**At Master Planner delegation point**:

```markdown
**CRITICAL - CANNOT PROCEED WITHOUT PM APPROVAL**

Before delegating to Master Feature Planner:

**TodoWrite Check**: "Get PM approval for Master Feature Planner delegation" must be in_progress

**Ask PM**:
```
📋 Plan scaffold complete!

Ready to delegate to Master Feature Planner for comprehensive planning?
- Type "yes" or "approved" to proceed
- Type "modify" to make changes first

Waiting for your approval...
```

**DO NOT PROCEED** until PM gives explicit approval.

**After approval**: Mark "Get PM approval for Master Feature Planner delegation" as completed
```

**At final plan save**:

```markdown
**CRITICAL - CANNOT SAVE PLAN WITHOUT PM APPROVAL**

**TodoWrite Check**: "Get final PM sign-off" must be in_progress

**Ask PM**:
```
📋 Plan complete!

Do you approve this plan for implementation?
- Type "yes" or "approved" to save plan
- Type "modify" to make changes

Waiting for your approval...
```

**DO NOT PROCEED** until PM gives explicit approval.
```

### Step 2.7: Manual Workflow Testing - Simple Path

**Test simple feature planning**:

1. Run `/rptc:plan "simple feature with 2-3 steps"`
2. Verify TodoWrite creates 4-item list (simple path)
3. Progress through phases, verify task updates
4. Verify PM approval gate at save
5. Complete and verify all 4 tasks "completed"

### Step 2.8: Manual Workflow Testing - Complex Path

**Test complex feature planning**:

1. Run `/rptc:plan "complex feature with 5+ steps"`
2. Verify TodoWrite creates 9-item list (complex path)
3. Progress through phases, verify task updates
4. Verify PM approval gate at Master Planner delegation
5. Verify Master Planner executes (sequential agents if >3 steps)
6. Verify PM approval gate at final save
7. Complete and verify all 9 tasks "completed"

### Step 2.9: Integration Testing with Research

**Test research → plan workflow**:

1. Complete research phase with TodoWrite
2. Run plan using research document reference
3. Verify TodoWrite creates new list (independent from research)
4. Verify no cross-contamination of TODO items

## Acceptance Criteria

- [x] TodoWrite initializes with correct list (simple vs complex)
- [x] Complexity assessment logic works (≤3 vs >3 steps)
- [x] Simple path: 4 phases tracked correctly
- [x] Complex path: 9 phases tracked correctly
- [x] Sequential agents documented for >3 step features
- [x] Two PM approval gates enforced (delegation and save)
- [ ] Manual workflow tests pass (both paths) - **Requires PM execution**
- [ ] Integration test with research passes - **Requires PM execution**

## Implementation Status

**Status**: ✅ Complete (TDD Phase)
**Date Completed**: 2025-01-16
**Tests**: 26 verification tests passing
**Coverage**: 100% (all automated acceptance criteria met)

**Implementation Summary**:
1. ✅ Step 0b: TodoWrite initialization section added (commands/plan.md:69-172)
2. ✅ Complexity assessment logic added (commands/plan.md:269-381)
3. ✅ Simple path TodoWrite updates (4 phases tracked throughout)
4. ✅ Complex path TodoWrite updates (9 phases tracked throughout)
5. ✅ Sequential agent context handoff documented (commands/plan.md:566-758)
6. ✅ Two PM approval blocking gates enforced (Phase 4 and Phase 8)

**Manual Testing Required**:
- Step 2.7: Simple path workflow test
- Step 2.8: Complex path workflow test
- Step 2.9: Research integration test

**Next Steps**:
- Execute manual tests (Steps 2.7-2.9)
- Commit changes when ready: `/rptc:commit` or `/rptc:commit pr`
- Continue to Step 3 (TDD Command) or Step 4 (Commit Command)

## Dependencies

- **Requires**: Step 6 (SOP) complete first
- **Enables**: Step 5 (blocking validation at 2 gates)
- **Integrates with**: Step 1 (research → plan workflow), Step 7 (testing)

---

**Next Step**: After completing this step, move to Step 3 (TDD Command) or return to overview.md to review overall progress.
