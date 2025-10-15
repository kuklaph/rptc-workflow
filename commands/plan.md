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

Load RPTC configuration from settings.json (with fallbacks):

```bash
# Load RPTC configuration
if [ -f ".claude/settings.json" ] && command -v jq >/dev/null 2>&1; then
  ARTIFACT_LOC=$(jq -r '.rptc.artifactLocation // ".rptc"' .claude/settings.json 2>/dev/null)
else
  ARTIFACT_LOC=".rptc"
fi
```

## Planning Process

### Phase 1: Context Loading (REQUIRED)

**Load relevant context**:

1. **Check for Research Document**

   - If user provides `@research-doc.md`, check `$ARTIFACT_LOC/research/[name].md`
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

- `/rptc:helper:catch-up-quick` - Quick context (2 min)
- `/rptc:helper:catch-up-med` - Medium context (5-10 min)
- `/rptc:helper:catch-up-deep` - Deep analysis (15-30 min)

**Present Context Summary**:

```text
📚 Context Loaded:

Research: [Summary if research doc provided from $ARTIFACT_LOC/research/]
Tech Stack: [From CLAUDE.md]
Related Files: [Relevant existing code]
Patterns: [Identified patterns from architecture SOP]

Ready to proceed with planning.
```

### Phase 2: Initial Plan Scaffolding (REQUIRED)

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

### Phase 3: Clarifying Questions (REQUIRED)

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

### Phase 4: PM Sign-Off for Master Planner (REQUIRED)

**CRITICAL**: Get explicit permission to delegate to Master Feature Planner.

**Step 1: Check for Global Thinking Mode Configuration**:

```bash
# Check .claude/settings.json for rptc.defaultThinkingMode
if [ -f ".claude/settings.json" ]; then
  cat .claude/settings.json
fi
```

Extract `rptc.defaultThinkingMode` if it exists (e.g., "think", "think hard", "ultrathink")

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

💡 TIP: You can specify a thinking mode for the agent:
- "think" - Basic extended thinking (default, ~4K tokens)
- "think hard" - Medium depth thinking (~10K tokens)
- "ultrathink" - Maximum depth thinking (~32K tokens, best for complex features)

[If global default exists: Currently configured: "[mode]"]

Which thinking mode would you like?
Type "yes"/"approved" to use [global default or "think"], or specify a mode (e.g., "ultrathink").
Type "wait" to refine scaffold further.

Waiting for your sign-off...
```

**DO NOT create agent** until PM gives explicit approval.

### Phase 5: Master Feature Planner Delegation (Only After Approval)

**Step 1: Determine Final Thinking Mode**:
   - If user specified a mode: Use user's choice
   - Else if global default exists: Use global default
   - Else: Use "think"

**Step 2: Delegate** using Task tool to `master-feature-planner-agent`:

**Agent Prompt**:

```text
Use [determined thinking mode] thinking mode for this planning task.

You are the MASTER FEATURE PLANNER - create a comprehensive, TDD-ready implementation plan.

Context:
- Feature: [feature description]
- Research findings: [if applicable, from $ARTIFACT_LOC/research/]
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

Save to: $ARTIFACT_LOC/plans/[name-slug].md

Focus on TDD-readiness: tests clearly defined BEFORE implementation.
Reference SOPs for standards and patterns.
```

**Wait for agent to complete comprehensive plan.**

### Phase 6: Present Plan to PM (REQUIRED)

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

### Phase 7: PM Review & Modifications (INTERACTIVE)

**Support iterative refinement**:

- If PM says "show me step 3": Display step 3 details
- If PM says "modify [something]": Make changes and re-present
- If PM says "add [requirement]": Update plan accordingly
- If PM says "approved": Proceed to save

**Keep iterating until PM explicitly approves.**

### Phase 8: Final PM Sign-Off (REQUIRED)

**Get explicit approval to save**:

```text
📋 Plan Finalized!

All modifications incorporated.

**Do you approve this plan for implementation?**
- Type "yes" or "approved" to save plan document
- Type "modify" to make additional changes
- Provide specific feedback for adjustments

This plan will be saved to: $ARTIFACT_LOC/plans/[name-slug].md

Waiting for your final sign-off...
```

**DO NOT SAVE** until PM gives explicit approval.

### Phase 9: Save Plan Document (Only After Approval)

Check workspace structure first:

```bash
# Ensure directory exists
if [ ! -d "$ARTIFACT_LOC/plans" ]; then
  echo "⚠️  Workspace not initialized. Creating $ARTIFACT_LOC/plans/"
  mkdir -p "$ARTIFACT_LOC/plans"
fi
```

Save to: `$ARTIFACT_LOC/plans/[name-slug].md`

**Use template from plugin**:

```bash
# Load template
TEMPLATE=$(cat "${CLAUDE_PLUGIN_ROOT}/templates/plan.md")

# Fill in with plan content from Master Planner
# Save to $ARTIFACT_LOC/plans/[sanitized-feature-name].md
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

**Related Research**: `$ARTIFACT_LOC/research/[topic].md` (if applicable)

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
✅ Plan saved to $ARTIFACT_LOC/plans/[name-slug].md

Next steps:
- Review: cat $ARTIFACT_LOC/plans/[name-slug].md
- Implement: /rptc:tdd "@[name-slug].md"
```

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
- [ ] Plan document saved to `$ARTIFACT_LOC/plans/`
- [ ] Ready for TDD implementation

---

**Remember**:

- Facilitate planning, but PM has final authority
- Reference SOPs for standards (use fallback chain)
- All tasks use checkbox format `- [ ]`
- Always get explicit approval before saving
