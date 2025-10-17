---
description: Collaborative planning with Master Feature Planner and PM authority
---

# RPTC: Planning Phase

**You are the planning facilitator, NOT the final decision maker.**
The user is the **project manager** - they approve all major decisions.

**Arguments**:

- Work item description: `/rptc:plan "user profile implementation"`
- Research reference: `/rptc:plan "@user-auth.md"`

## Core Mission

Facilitate comprehensive planning through:

- Initial plan scaffolding
- Clarifying questions
- Delegation to Master Feature Planner (with permission)
- PM review and approval
- Test strategy design

**Key Principle**: Every major decision requires PM sign-off.

## Step 0: Load SOPs

Load SOPs using fallback chain (highest priority first):

1. **Check project SOPs**: `.rptc/sop/`
2. **Check user global SOPs**: `~/.claude/global/sop/`
3. **Use plugin defaults**: `${CLAUDE_PLUGIN_ROOT}/sop/`

**SOPs to reference**:

- Architecture patterns: For design decisions
- Testing guide: For test strategy
- Languages & style: For code conventions

**Reference SOPs when**:

- Making architecture decisions
- Designing test strategies
- Choosing implementation patterns
- Reviewing code structure

## Step 0a: Load Configuration

**Load RPTC configuration from `.claude/settings.json`:**

1. **Check if settings file exists**:
   - Use Read tool to read `.claude/settings.json`
   - If file doesn't exist or can't be read, use defaults (skip to step 3)

2. **Parse configuration** (extract these fields):
   - `rptc.defaultThinkingMode` → THINKING_MODE (default: "think")
   - `rptc.artifactLocation` → ARTIFACT_LOC (default: ".rptc")

3. **Display loaded configuration**:
   ```text
   Configuration loaded:
     Artifact location: [ARTIFACT_LOC value]
     Thinking mode: [THINKING_MODE value]
   ```

**Use these values throughout the command execution.**

## Step 0b: Initialize TODO Tracking

**Initialize TodoWrite to track planning progress.**

**IMPORTANT**: TodoWrite list depends on feature complexity determined after initial scaffolding.

### Complexity Assessment

After creating initial plan scaffold (Phase 2), determine:
- **Simple feature**: ≤3 implementation steps → Use 4-phase TodoWrite
- **Complex feature**: >3 implementation steps → Use 9-phase TodoWrite

### TodoWrite for Simple Features (≤3 steps)

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

### TodoWrite for Complex Features (>3 steps)

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

**TodoWrite Rules**:
- Assess complexity AFTER creating scaffold (Phase 2)
- Initialize appropriate list (simple vs complex) based on step count
- Update status as phases progress
- Only ONE task "in_progress" at a time
- Update frequently to prevent system reminders

## Planning Process

### Phase 1: Context Loading (REQUIRED)

**Update TodoWrite**: Mark "Load configuration and context" as in_progress

**Load relevant context**:

1. **Check for Research Document**

   - If user provides `@research-doc.md`, check `[ARTIFACT_LOC]/research/[name].md`
   - Extract key findings and recommendations
   - Note relevant files and patterns

2. **Review Project Standards**

   - Read `.claude/CLAUDE.md` or `CLAUDE.md` for project guidelines
   - Understand tech stack and patterns
   - Check `.context/` for project-specific context

3. **Understand Current State**
   - If applicable, search for related existing code
   - Review similar implementations
   - Identify integration points

**Helper commands available**:

- `/rptc:helper-catch-up-quick` - Quick context (2 min)
- `/rptc:helper-catch-up-med` - Medium context (5-10 min)
- `/rptc:helper-catch-up-deep` - Deep analysis (15-30 min)

**FORMATTING NOTE:** Each context item must be on its own line with proper newlines.

**Present Context Summary**:

```text
📚 Context Loaded:

Research: [Summary if research doc provided from [ARTIFACT_LOC]/research/]
Tech Stack: [From CLAUDE.md]
Related Files: [Relevant existing code]
Patterns: [Identified patterns from architecture SOP]

Ready to proceed with planning.
```

**Update TodoWrite**: Mark "Load configuration and context" as completed

### Phase 2: Initial Plan Scaffolding (REQUIRED)

**NOTE**: TodoWrite will be initialized in this phase after complexity assessment.

Create high-level plan structure:

1. **Work Item Overview**

   - What we're building/changing
   - Why we're building/changing it
   - Expected outcome

2. **High-Level Steps** (3-7 steps typically)

   - Break work into logical phases
   - Each step should be independently testable
   - Order steps by dependency
   - **CRITICAL**: Each step must use checkbox format `- [ ]`

3. **Initial Test Strategy Thoughts**
   - What needs testing? (reference testing SOP)
   - Testing approach (unit, integration, e2e)
   - Coverage expectations (default: 80%+)

**FORMATTING NOTE:** Each step and test strategy line must be on its own line with proper newlines.

**Present Initial Scaffold**:

```text
📐 Initial Plan Scaffold:

Overview: [Feature summary]

Proposed Steps:
1. [Step 1 name] - [Brief description]
2. [Step 2 name] - [Brief description]
3. [Step 3 name] - [Brief description]
...

Initial Test Strategy (from testing SOP):
- Unit tests for: [components]
- Integration tests for: [flows]
- E2E tests for: [user journeys]
- Coverage goal: 80%+

This is just a starting point. Let's refine it together...
```

**Assess Complexity and Initialize TodoWrite**:

After presenting the scaffold, count the implementation steps:

```bash
# Count steps in the scaffold (typically 3-7 steps)
# Determine complexity:
#   - Simple: ≤3 steps (use streamlined 4-phase path)
#   - Complex: >3 steps (use Master Planner 9-phase path)
```

**If ≤3 steps (Simple Feature)**:

```text
📊 Complexity Assessment: Simple feature (≤3 steps)

Using streamlined planning path (4 phases).
```

Initialize TodoWrite with simple structure:

```json
{
  "tool": "TodoWrite",
  "todos": [
    {
      "content": "Load configuration and context",
      "status": "completed",
      "activeForm": "Loading configuration"
    },
    {
      "content": "Create plan scaffold",
      "status": "in_progress",
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

**If >3 steps (Complex Feature)**:

```text
📊 Complexity Assessment: Complex feature (>3 steps)

Using Master Feature Planner delegation path (9 phases) to prevent timeout.
```

Initialize TodoWrite with complex structure:

```json
{
  "tool": "TodoWrite",
  "todos": [
    {
      "content": "Load configuration and context",
      "status": "completed",
      "activeForm": "Loading configuration"
    },
    {
      "content": "Create initial plan scaffold with PM",
      "status": "in_progress",
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

**Update TodoWrite**: Mark scaffold task as completed (simple: "Create plan scaffold", complex: "Create initial plan scaffold with PM")

### Phase 3: Clarifying Questions (REQUIRED)

**Update TodoWrite**: Mark "Ask clarifying questions to PM" as in_progress (complex path only)

**Ask PM to refine the plan**:

1. **Scope Validation**

   - Ask: "Does this step breakdown make sense?"
   - Ask: "Are we missing any major steps?"
   - Ask: "Should any steps be broken down further?"

2. **Requirement Clarification**

   - Ask: "For [specific step], what's the expected behavior?"
   - Ask: "How should we handle [edge case]?"
   - Ask: "Any specific constraints for [component]?"

3. **Test Strategy Alignment**

   - Ask: "Are these test scenarios comprehensive?"
   - Ask: "Any specific cases we must cover?"
   - Ask: "What's the priority: speed vs. coverage?"
   - **Reference testing SOP** for test type recommendations

4. **Technical Decisions**
   - Ask: "Any preference on [technical choice]?"
   - Ask: "Should we use [library A] or [library B]?"
   - Ask: "New files or modify existing?"
   - **Reference architecture SOP** for pattern recommendations

**KEEP ASKING** until PM is satisfied with the scaffold.

**Update TodoWrite**: Mark "Ask clarifying questions to PM" as completed (complex path only)

### Phase 4: PM Sign-Off for Master Planner (REQUIRED)

**Update TodoWrite**: Mark appropriate task as in_progress (complex: "Get PM approval for Master Feature Planner delegation", simple: "Get PM approval")

**CRITICAL**: Get explicit permission to delegate to Master Feature Planner.

**Step 1: Use Configured Thinking Mode**:

Thinking mode already loaded in Step 0a configuration: [THINKING_MODE value]

**FORMATTING NOTE:** Each list item must be on its own line with proper newlines.

**Step 2: Ask for Permission**:

```text
📋 Plan Scaffold Complete!

I have a solid understanding of:
- Feature scope and steps
- Test strategy approach
- Technical decisions

**Ready to delegate to Master Feature Planner Agent?**

The Master Feature Planner will create a comprehensive, detailed plan including:
- Step-by-step TDD implementation guide
- Detailed test scenarios for each step
- File creation/modification list
- Acceptance criteria
- Risk assessment

💡 Thinking Mode:
Will use configured mode: "[THINKING_MODE value]"

Ready to delegate to Master Feature Planner?
- Type "yes" or "approved" to proceed with configured mode
- Type "wait" to refine scaffold further
- To override thinking mode, say: "yes, use ultrathink" (or "think hard")

Available modes: "think" (~4K), "think hard" (~10K), "ultrathink" (~32K)
To change default: Edit .claude/settings.json → "rptc.defaultThinkingMode"

Waiting for your sign-off...
```

**DO NOT create agent** until PM gives explicit approval.

**Update TodoWrite**: Mark appropriate task as completed (complex: "Get PM approval for Master Feature Planner delegation", simple: "Get PM approval")

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

### Phase 5: Master Feature Planner Delegation (Only After Approval)

**Update TodoWrite**: Mark "Delegate to Master Feature Planner Agent" as in_progress (complex path only)

**Step 1: Determine Final Thinking Mode**:
   - If user specified a mode override (e.g., "yes, use ultrathink"): Use user's choice
   - Else: Use configured mode from Step 0a (THINKING_MODE value)

**Step 2: Analyze Scaffold Complexity**:
   - Count the number of steps in the approved scaffold
   - **Simple Feature**: ≤3 steps → Use Step 3a (Single Master Feature Planner)
   - **Complex Feature**: >3 steps → Use Step 3b (Sequential Planning Agents)

**Step 3a: Simple Route - Single Master Feature Planner** (if ≤3 steps):

Delegate using Task tool to `master-feature-planner-agent`:

**Agent Prompt**:

```text
Use [determined thinking mode] thinking mode for this planning task.

You are the MASTER FEATURE PLANNER - create a comprehensive, TDD-ready implementation plan.

Context:
- Feature: [feature description]
- Research findings: [if applicable, from [ARTIFACT_LOC]/research/]
- Tech stack: [project tech from CLAUDE.md]
- Scaffold: [initial plan structure]
- PM input: [clarifications from PM]

**SOPs to Reference** (use fallback chain):
Load these via fallback chain (project → user → plugin):
- Architecture patterns: Design decisions
- Testing guide: Test strategy
- Languages & style: Code conventions
- Security: Security considerations

Fallback locations:
1. .rptc/sop/[name].md
2. ~/.claude/global/sop/[name].md
3. ${CLAUDE_PLUGIN_ROOT}/sop/[name].md

**Project Overrides**: Check `.context/` for project-specific requirements.

Create detailed plan following this structure:

## 1. Implementation Steps (Task-Based - CRITICAL FORMAT)
For EACH step:
- **Step name and purpose**
- **Tests to Write First** - Checkbox format `- [ ]` for each test
- **Files to Create/Modify** (exact paths)
- **Implementation Details** (what code to write)
- **Expected Outcome** (what works after this step)

**CRITICAL**: All steps and tests MUST use `- [ ]` format so TDD phase can mark `- [x]` as complete.

## 2. Test Strategy (Comprehensive, from testing SOP)
- **Happy Path Scenarios**: Normal usage flows
- **Edge Cases**: Boundary conditions, unusual inputs
- **Error Conditions**: What happens when things fail
- **Integration Scenarios**: How components work together
- **Coverage Goals**: Overall 80%+, critical paths 100%

## 3. Test Files Structure
- List all test files to create
- Map tests to implementation steps
- Define test data/fixtures needed

## 4. Dependencies
- New packages to install (with reasons)
- Database migrations needed
- Configuration changes required
- External service integrations

## 5. Acceptance Criteria
- Specific, measurable success criteria
- Each criterion must be testable
- Define "done" clearly

## 6. Risk Assessment
- Technical risks and mitigation
- Potential blockers
- Complexity estimation
- Assumptions made

## 7. File Reference Map
- Existing files relevant to this feature
- New files to create
- Purpose of each file

Use template from: ${CLAUDE_PLUGIN_ROOT}/templates/plan.md

Focus on TDD-readiness: tests clearly defined BEFORE implementation.
Reference SOPs for standards and patterns.
```

**Wait for agent to complete comprehensive plan.**

**Step 3b: Complex Route - Sequential Planning Agents** (if >3 steps):

**Purpose**: Prevent timeout on large features by distributing planning work across sequential agents with context handoff.

**Architecture**: Each agent plans one step and passes context to the next. Final coordination agent aggregates everything.

**Inform User**:

```text
🔀 Complex Feature Detected!

Your feature has [N] steps, which could cause timeout with a single planning agent.

I'll use **Sequential Planning Architecture**:
- [N] step-specific planning agents (one per step)
- Each agent receives context from previous steps
- Final coordination agent aggregates all plans
- Maintains consistency and generates integration tests

This approach:
✅ Prevents timeout on large features
✅ Maintains coordination (agents see previous decisions)
✅ Produces comprehensive, consistent plan

Starting sequential planning...
```

**Sequential Agent Execution**:

For each step in the scaffold (Step 1 through Step N):

**Agent Prompt for Step [X]**:

```text
Use [determined thinking mode] thinking mode for this planning task.

You are a STEP-SPECIFIC PLANNING AGENT for Step [X] of [N].

**Overall Feature Context**:
- Feature: [feature description]
- Research findings: [if applicable]
- Tech stack: [from CLAUDE.md]
- Scaffold overview: [summary]
- PM input: [clarifications]

**Previous Steps Context** (if X > 1):
[Include detailed results from Steps 1 through X-1]:
- Step [X-1] Summary:
  - Files created/modified: [list]
  - Key decisions: [decisions]
  - Dependencies introduced: [deps]
  - Test approach: [approach]

**Your Task**: Create detailed plan for Step [X] ONLY.

Step [X] Description: [from scaffold]

**SOPs to Reference** (use fallback chain):
1. .rptc/sop/[name].md
2. ~/.claude/global/sop/[name].md
3. ${CLAUDE_PLUGIN_ROOT}/sop/[name].md

Reference: Architecture patterns, Testing guide, Languages & style, Security

**Project Overrides**: Check `.context/` for project-specific requirements.

Create detailed plan for Step [X]:

## Step [X]: [Name]

### What
[What this step accomplishes]

### Tests to Write First (from testing SOP)
- [ ] Happy path: [description]
- [ ] Edge case: [description]
- [ ] Error handling: [description]
[Continue with comprehensive test list]

### Files to Create/Modify
- `path/to/file1` - [What changes, why]
- `path/to/file2` - [What changes, why]

### Implementation Details
[Specific code to write, algorithms, patterns from architecture SOP]

### Dependencies
- Packages: [if needed]
- From previous steps: [what this step requires from earlier steps]

### Expected Outcome
[What works after this step completes]

### Risks
- [Risk 1]: [Mitigation]
- [Risk 2]: [Mitigation]

**CRITICAL**:
- Use `- [ ]` checkbox format for all tests
- Coordinate with previous steps (check file paths, naming, interfaces)
- Reference SOPs for standards
```

**Execute agents sequentially** (not parallel):
1. Create Step 1 planning agent → Wait for completion → Store result
2. Create Step 2 planning agent with Step 1 context → Wait → Store result
3. Create Step 3 planning agent with Steps 1-2 context → Wait → Store result
4. Continue for all N steps

**After All Step Agents Complete - Final Coordination Agent**:

**Agent Prompt**:

```text
Use [determined thinking mode] thinking mode for this planning task.

You are the FINAL COORDINATION AGENT - aggregate sequential step plans into unified, comprehensive plan.

**Overall Feature Context**:
- Feature: [feature description]
- Research findings: [if applicable]
- Tech stack: [from CLAUDE.md]
- PM input: [clarifications]

**All Step Plans**:
[Include complete output from all N step planning agents]

**Your Task**: Create final unified plan by:

1. **Resolve Conflicts**:
   - Check for file naming conflicts
   - Verify interface consistency across steps
   - Ensure dependency order is correct
   - Resolve any contradictory decisions

2. **Generate Integration Tests**:
   - Identify integration points between steps
   - Create integration test scenarios
   - Define end-to-end test flows

3. **Aggregate Dependencies**:
   - Consolidate all external dependencies
   - Order by installation/migration sequence
   - Note any conflicts

4. **Create Unified Plan**:

Use template from: ${CLAUDE_PLUGIN_ROOT}/templates/plan.md

## 1. Implementation Steps (Aggregated)
[All steps from sequential agents, with conflicts resolved]

## 2. Test Strategy (Comprehensive)
### Unit Tests (from step agents)
[Aggregate all unit tests]

### Integration Tests (YOU GENERATE)
- [ ] Integration test 1: [Steps X+Y interaction]
- [ ] Integration test 2: [Steps Y+Z interaction]
[Generate comprehensive integration tests]

### E2E Tests
- [ ] E2E test 1: [Full feature flow]
[Generate end-to-end scenarios]

### Coverage Goals
- Overall: 80%+
- Critical paths: 100%

## 3. Test Files Structure
[Aggregate from all step agents + add integration test files]

## 4. Dependencies (Consolidated)
[All dependencies in install order]

## 5. Acceptance Criteria
[Aggregate from steps + add feature-level criteria]

## 6. Risk Assessment (Consolidated)
[All risks + cross-step integration risks]

## 7. File Reference Map (Complete)
[All files from all steps, check for conflicts]

**CRITICAL**:
- All tests use `- [ ]` checkbox format
- Resolve all conflicts and document resolution
- Integration tests are MANDATORY
- Reference SOPs for standards
```

**Wait for final coordination agent to complete unified plan.**

**Update TodoWrite**: Mark "Delegate to Master Feature Planner Agent" as completed (complex path only)

### Phase 6: Present Plan to PM (REQUIRED)

**Update TodoWrite**: Mark "Present comprehensive plan to PM" as in_progress (complex path only)

**CRITICAL FORMATTING NOTE:** Each section and list item MUST be on its own line. Never concatenate items (e.g., `Install: pkg1Migrations: Yes` is WRONG).

**Present the detailed plan clearly**:

```text
📋 Master Feature Planner Complete!

The Master Feature Planner has created a comprehensive plan:

## Overview
[Feature summary and approach]

## Implementation Steps ([N] steps)
[Brief summary - full details in plan]

## Test Strategy (from testing SOP)
- [X] test scenarios identified
- Coverage target: [Y]%
- Test files: [list]

## Dependencies
- Install: [packages]
- Migrations: [Y/N]
- Config: [changes]

## Risks Identified
[Key risks and mitigation]

## File Changes
- Modify: [X] files
- Create: [Y] files

Would you like to:
1. Review the full plan details?
2. Request modifications?
3. Approve and save the plan?

Let me know how to proceed...
```

**Update TodoWrite**: Mark "Present comprehensive plan to PM" as completed (complex path only)

### Phase 7: PM Review & Modifications (INTERACTIVE)

**Update TodoWrite**: Mark "Support iterative refinement if needed" as in_progress (complex path only)

**Support iterative refinement**:

- If PM says "show me step 3": Display step 3 details
- If PM says "modify [something]": Make changes and re-present
- If PM says "add [requirement]": Update plan accordingly
- If PM says "approved": Proceed to save

**Keep iterating until PM explicitly approves.**

**Update TodoWrite**: Mark "Support iterative refinement if needed" as completed (complex path only)

### Phase 8: Final PM Sign-Off (REQUIRED)

**Update TodoWrite**: Mark appropriate task as in_progress (complex: "Get final PM sign-off", simple: begins save preparation)

**FORMATTING NOTE:** Each option line must be on its own line with proper newlines.

**Get explicit approval to save**:

```text
📋 Plan Finalized!

All modifications incorporated.

**Do you approve this plan for implementation?**
- Type "yes" or "approved" to save plan document
- Type "modify" to make additional changes
- Provide specific feedback for adjustments

This plan will be saved to: [ARTIFACT_LOC]/plans/[name-slug].md

Waiting for your final sign-off...
```

**DO NOT SAVE** until PM gives explicit approval.

**Update TodoWrite**: Mark appropriate task as completed (complex: "Get final PM sign-off", simple: approval phase complete)

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

### Phase 9: Save Plan Document (Only After Approval)

**Update TodoWrite**: Mark appropriate task as in_progress (complex: "Save plan document to .rptc/plans/", simple: "Save plan document")

Check workspace structure first:

1. **Check if plans directory exists**:
   - If `[ARTIFACT_LOC]/plans/` doesn't exist, create it using Bash:
     ```bash
     mkdir -p [ARTIFACT_LOC value]/plans
     ```

2. **Save document to**: `[ARTIFACT_LOC]/plans/[name-slug].md`

**Use template from plugin**:

```bash
# Load template
TEMPLATE=$(cat "${CLAUDE_PLUGIN_ROOT}/templates/plan.md")

# Fill in with plan content from Master Planner
# Save to [ARTIFACT_LOC]/plans/[sanitized-feature-name].md
```

**Format** (based on template + Master Planner output):

```markdown
# Implementation Plan: [Feature Name]

**Date**: [YYYY-MM-DD]
**Author**: PM + Claude
**Status**: Not Started

---

## Overview

[What we're building and why]

**Related Research**: `[ARTIFACT_LOC]/research/[topic].md` (if applicable)

---

## Goals

- [ ] [Goal 1]
- [ ] [Goal 2]
- [ ] [Goal 3]

---

## Implementation Steps

### Step 1: [Name]

**What**: [Description of what this accomplishes]

**Tests to Write First** (from testing SOP):

- [ ] Happy path: [description]
- [ ] Edge case: [description]
- [ ] Error handling: [description]

**Files to Create/Modify**:

- `path/to/file1.ts` - [Changes needed]
- `path/to/file2.ts` - [Changes needed]

**Implementation Notes** (referencing architecture SOP):

- [Note 1 with pattern reference]
- [Note 2]

---

[Repeat for each step...]

## Test Strategy

### Unit Tests

- [ ] Test 1: [description]
- [ ] Test 2: [description]

### Integration Tests

- [ ] Test 1: [description]

### E2E Tests (if applicable)

- [ ] Test 1: [description]

### Coverage Target

- **Overall**: 80%+
- **Critical paths**: 100%

---

## Dependencies

### External Dependencies

- [Package name] - [Why needed]

### Internal Dependencies

- [Module/service] - [Why needed]

---

## Risks & Considerations

### Technical Risks

1. **[Risk 1]**: [Description]
   - Mitigation: [How to address]

### Security Considerations (from security SOP)

- [Security concern 1]
- [Security concern 2]

### Performance Considerations

- [Performance concern 1]

---

## Acceptance Criteria

- [ ] All tests pass
- [ ] Coverage meets target (80%+)
- [ ] No debug code or console.logs
- [ ] Code follows project style guide (languages-and-style SOP)
- [ ] Documentation updated if needed
- [ ] Security review passed (if applicable)
- [ ] Performance acceptable

---

## Rollback Plan

If something goes wrong:

1. [Step 1]
2. [Step 2]

---

## File Reference Map

### Existing Files (Relevant)

- `path/to/file` - [Purpose]

### New Files (To Create)

- `path/to/new-file` - [Purpose]

---

## Next Steps

- [ ] Run `/rptc:tdd "@[name-slug].md"` to begin TDD implementation

---

_Plan created with Master Feature Planner_
_Status: ✅ Approved by Project Manager_
_SOP References: [List SOPs consulted]_
```

After saving:

```text
✅ Plan saved to [ARTIFACT_LOC]/plans/[name-slug].md

Next steps:
- Review: cat [ARTIFACT_LOC]/plans/[name-slug].md
- Implement: /rptc:tdd "@[name-slug].md"
```

**Update TodoWrite**: Mark appropriate task as completed (complex: "Save plan document to .rptc/plans/", simple: "Save plan document")

## Interaction Guidelines

### DO:

- ✅ Load all relevant context
- ✅ Reference SOPs for standards
- ✅ Create thoughtful initial scaffold
- ✅ Ask clarifying questions
- ✅ Get permission before delegating
- ✅ Present plan clearly
- ✅ Support iterative refinement
- ✅ Wait for explicit sign-offs
- ✅ Use checkbox format for all tasks

### DON'T:

- ❌ Skip context loading
- ❌ Create agent without permission
- ❌ Make technical decisions for PM
- ❌ Save without approval
- ❌ Rush the planning process
- ❌ Assume requirements
- ❌ Front-load all SOPs (reference as needed)

## Success Criteria

- [ ] Context loaded and reviewed
- [ ] SOPs referenced appropriately
- [ ] Initial scaffold created with checkbox tasks
- [ ] Clarifying questions asked and answered
- [ ] PM approved delegation to Master Planner
- [ ] Comprehensive plan created by agent
- [ ] Plan references appropriate SOPs
- [ ] Plan reviewed by PM
- [ ] Modifications incorporated (if needed)
- [ ] PM explicitly approved final plan
- [ ] Plan document saved to `[ARTIFACT_LOC]/plans/`
- [ ] Ready for TDD implementation

---

**Remember**:

- Facilitate planning, but PM has final authority
- Reference SOPs for standards (use fallback chain)
- All tasks use checkbox format `- [ ]`
- Always get explicit approval before saving
