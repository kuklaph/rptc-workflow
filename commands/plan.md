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

### Phase 5: Incremental Plan Generation with Sub-Agent Delegation (Only After Approval)

**Update TodoWrite**: Mark "Delegate to Master Feature Planner Agent" as in_progress (complex path only)

**Step 1: Determine Final Thinking Mode**:
   - If user specified a mode override (e.g., "yes, use ultrathink"): Use user's choice
   - Else: Use configured mode from Step 0a (THINKING_MODE value)

**Step 2: Analyze Scaffold Complexity**:
   - Count the number of steps in the approved scaffold
   - **Simple Feature**: ≤2 steps → Use Step 3a (Monolithic - Legacy Master Feature Planner)
   - **Complex Feature**: >2 steps → Use Step 3b (Incremental Sub-Agent Delegation)

---

**Step 3a: Monolithic Route - Single Master Feature Planner** (if ≤2 steps):

**Purpose**: For simple features, use traditional monolithic plan generation for simplicity.

Delegate using Task tool to `master-feature-planner-agent`:

**Agent Prompt**:

```text
Use [determined thinking mode] thinking mode for this planning task.

You are the MASTER FEATURE PLANNER - create a comprehensive, TDD-ready implementation plan in MONOLITHIC format.

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

**Output Format**: MONOLITHIC (single document)

Create detailed plan following legacy monolithic structure (see agent documentation for full template).

Focus on TDD-readiness: tests clearly defined BEFORE implementation.
Reference SOPs for standards and patterns.
```

**Wait for agent to complete monolithic plan.**

**After completion, proceed to Phase 6 to present plan to PM.**

---

**Step 3b: Incremental Route - Sub-Agent Delegation with Immediate Persistence** (if >2 steps):

**Purpose**: For complex features, use incremental generation to:
- Create directory structure before content generation
- Generate and save overview immediately
- Generate and save each step incrementally
- Review cohesiveness across all steps
- Prevent timeout on large features
- Enable immediate persistence

**Architecture**: Directory scaffolding → Overview sub-agent → Step sub-agents (sequential) → Cohesiveness reviewer

**Inform PM**:

```text
🏗️ Complex Feature Detected - Using Incremental Plan Generation!

Your feature has [N] steps. I'll use **Incremental Sub-Agent Delegation**:

✅ Create directory structure first
✅ Generate overview (test strategy, acceptance criteria, risks)
✅ Generate each step incrementally with immediate save
✅ Review cohesiveness across all steps

This approach:
- Prevents timeout on large features
- Saves work immediately (recovery if interrupted)
- Enables modular plan structure (TDD-optimized)
- Produces comprehensive, consistent plan

Starting incremental planning...
```

---

**Sub-Step 0: Create Directory Scaffolding**

**Before any content generation**, create the plan directory structure:

1. **Sanitize feature name to slug**:
   - Convert to lowercase
   - Replace spaces, special characters with hyphens
   - Remove multiple consecutive hyphens
   - Example: "User Authentication (OAuth 2.0)" → "user-authentication-oauth-2-0"

2. **Check if plans directory exists**:
   - If `[ARTIFACT_LOC]/plans/` doesn't exist, create it using Bash:
     ```bash
     mkdir -p "[ARTIFACT_LOC value]/plans"
     ```

3. **Check if feature directory already exists**:
   - Path: `[ARTIFACT_LOC]/plans/[feature-slug]/`
   - **If directory exists**, ask PM:
     ```text
     ⚠️ Plan Directory Already Exists

     Directory: [ARTIFACT_LOC]/plans/[feature-slug]/

     Options:
     1. Overwrite - Delete existing directory and create new plan
     2. Abort - Keep existing plan, cancel planning operation

     What would you like to do? (type "overwrite" or "abort")
     ```
   - **If PM says "overwrite"**: Delete existing directory with Bash `rm -rf`, proceed
   - **If PM says "abort"**: Exit Phase 5 without creating plan, inform PM operation cancelled
   - **Wait for PM response before proceeding**

4. **Create feature directory**:
   ```bash
   mkdir -p "[ARTIFACT_LOC]/plans/[feature-slug]/"
   ```

**Report scaffolding success**:

```text
✅ Directory scaffolding complete: [ARTIFACT_LOC]/plans/[feature-slug]/

Proceeding with incremental plan generation...
```

---

**Sub-Step 1: Generate Overview with Overview Generator Sub-Agent**

**Delegate to Overview Generator** (inline sub-agent prompt):

**Agent Configuration**:
- Thinking mode: [determined thinking mode]
- Role: Overview Generator for incremental planning
- Output: Complete overview.md content

**Agent Prompt**:

```text
Use [determined thinking mode] thinking mode for this planning task.

You are an OVERVIEW GENERATOR SUB-AGENT for incremental plan creation.

**Overall Feature Context**:
- Feature: [feature description]
- Research findings: [if applicable, from [ARTIFACT_LOC]/research/]
- Tech stack: [project tech from CLAUDE.md]
- Scaffold: [initial plan structure with [N] steps]
- PM input: [clarifications from PM]

**Your Task**: Generate ONLY the overview.md content (NOT individual steps).

**SOPs to Reference** (use fallback chain):
1. .rptc/sop/architecture-patterns.md
2. ~/.claude/global/sop/architecture-patterns.md
3. ${CLAUDE_PLUGIN_ROOT}/sop/architecture-patterns.md

Reference: Architecture patterns, Testing guide, Security, Performance

**Project Overrides**: Check `.context/` for project-specific requirements.

**Output Required**: Complete overview.md following this template:

Use template structure from: ${CLAUDE_PLUGIN_ROOT}/templates/plan-overview.md

Include:
- Status Tracking (checkboxes for Planned, In Progress, Reviews, Complete)
- Executive Summary (Feature, Purpose, Approach, Complexity, Timeline, Key Risks)
- Test Strategy (Framework, Coverage Goals, Test Scenarios Summary)
  - Note: "Detailed test scenarios are in each step file (step-01.md, step-02.md, etc.)"
- Acceptance Criteria (Definition of Done for feature)
- Risk Assessment (Top 3-5 risks with Category, Likelihood, Impact, Mitigation, Contingency)
- Dependencies (New Packages, Configuration Changes, External Services)
- File Reference Map (Existing Files to Modify, New Files to Create)
- Coordination Notes (Step Dependencies, Integration Points)
- Next Actions

**Target Token Count**: ~450 tokens (±50)

**Focus on**:
- High-level strategy and approach
- Overall test strategy summary (details in step files)
- Key risks and mitigations
- Feature-level acceptance criteria
- Cross-step coordination needs

**CRITICAL**:
- Do NOT include individual step details (those come from Step Generator sub-agents)
- Reference SOPs rather than duplicating content
- Use checkbox format `- [ ]` for all trackable items
- Keep concise - TDD sub-agent loads this once, not per step

Output the complete overview.md content now.
```

**Wait for Overview Generator sub-agent to complete.**

**Save overview.md immediately**:

1. Capture the sub-agent's output
2. Write to file: `[ARTIFACT_LOC]/plans/[feature-slug]/overview.md`
3. Verify file created successfully

**Report**:

```text
✅ Overview generated and saved: overview.md

Proceeding to generate individual steps...
```

---

**Sub-Step 2: Generate Steps with Step Generator Sub-Agents**

**For each step in the scaffold** (Step 1 through Step N), execute sequentially:

**Inform PM**:

```text
📝 Generating Step [X] of [N]: [Step Name from Scaffold]
```

**Delegate to Step Generator Sub-Agent [X]**:

**Agent Configuration**:
- Thinking mode: [determined thinking mode]
- Role: Step [X] Generator for incremental planning
- Output: Complete step-[0X].md content

**Agent Prompt for Step [X]**:

```text
Use [determined thinking mode] thinking mode for this planning task.

You are a STEP GENERATOR SUB-AGENT for incremental plan creation.

**Overall Feature Context**:
- Feature: [feature description]
- Research findings: [if applicable]
- Tech stack: [project tech from CLAUDE.md]
- Total steps in feature: [N]
- Overview: [Brief summary from overview.md that was just generated]
- PM input: [clarifications]

**Previous Steps Context** (if X > 1):
[Include summaries from Steps 1 through X-1 that were already generated]:

Step [X-1] Summary:
- Purpose: [what Step X-1 accomplishes]
- Files created/modified: [list from step-[X-1].md]
- Key decisions: [major decisions from step-[X-1].md]
- Dependencies introduced: [any new dependencies]
- Tests defined: [count of tests in step-[X-1].md]

[Repeat for all previous steps if needed for context]

**Your Task**: Generate ONLY Step [X] content.

**This Step's Details** (from scaffold):
- Step number: [X]
- Step name: [from scaffold]
- Step description: [from scaffold]

**SOPs to Reference** (use fallback chain):
1. .rptc/sop/testing-guide.md
2. ~/.claude/global/sop/testing-guide.md
3. ${CLAUDE_PLUGIN_ROOT}/sop/testing-guide.md

Reference: Testing guide, Architecture patterns, Languages & style, Security

**Project Overrides**: Check `.context/` for project-specific requirements.

**Output Required**: Complete step-[0X].md following this template:

Use template structure from: ${CLAUDE_PLUGIN_ROOT}/templates/plan-step.md

Include:
- Purpose (What this step accomplishes, why it's in this position)
- Prerequisites (Previous step completion, required dependencies)
- Tests to Write First (Happy Path, Edge Cases, Error Conditions)
  - Use Given-When-Then format
  - Specify test file paths
  - Use `- [ ]` checkbox format
- Files to Create/Modify (exact paths, purposes)
- Implementation Details (RED, GREEN, REFACTOR phases)
- Expected Outcome (what works after this step)
- Acceptance Criteria (step-specific success criteria)
- Dependencies from Other Steps (ONLY if this step depends on previous steps)
- Estimated Time

**Target Token Count**: 150-240 tokens

**Coordination Requirements**:
- If this step uses files/components from previous steps, document in "Dependencies from Other Steps"
- Ensure file paths are consistent with previous steps
- Ensure test strategy aligns with overview's test strategy
- Check for interface compatibility with previous steps

**CRITICAL**:
- All tests MUST use `- [ ]` checkbox format
- Self-contained (TDD sub-agent loads ONLY overview + this step file)
- Reference SOPs rather than duplicating
- Include dependencies from other steps ONLY if actually needed

Output the complete step-[0X].md content now.
```

**Wait for Step Generator sub-agent [X] to complete.**

**Save step-[0X].md immediately**:

1. Capture the sub-agent's output
2. Format step number with zero-padding (step-01.md, step-02.md, etc.)
3. Write to file: `[ARTIFACT_LOC]/plans/[feature-slug]/step-[0X].md`
4. Verify file created successfully
5. Store step summary for context in next step generation

**Report**:

```text
✅ Step [X] generated and saved: step-[0X].md
```

**Repeat for all N steps.**

**After all steps generated**:

```text
✅ All [N] steps generated and saved!

Files created:
- overview.md
- step-01.md through step-[0N].md

Proceeding to cohesiveness review...
```

---

**Sub-Step 3: Cohesiveness Review with Reviewer Sub-Agent**

**Purpose**: Validate that all generated files work together cohesively without conflicts.

**Delegate to Cohesiveness Reviewer Sub-Agent**:

**Agent Configuration**:
- Thinking mode: [determined thinking mode]
- Role: Plan Cohesiveness Reviewer
- Input: All generated plan files
- Output: Review report with issues and suggested fixes

**Agent Prompt**:

```text
Use [determined thinking mode] thinking mode for this review task.

You are a PLAN COHESIVENESS REVIEWER SUB-AGENT.

**Your Mission**: Ensure all plan files work together without conflicts or gaps.

**Files to Review**:

Read these files from `[ARTIFACT_LOC]/plans/[feature-slug]/`:
- overview.md
- step-01.md
- step-02.md
- ... (through step-[0N].md)

**Review Criteria**:

1. **Conflicting Approaches**
   - Do steps contradict each other in implementation approach?
   - Are there inconsistent architectural decisions?
   - Do steps use different patterns for similar problems?

2. **Missing Dependencies**
   - Are step prerequisites clearly stated?
   - If Step Y uses output from Step X, is this documented in Step Y?
   - Are dependency chains complete and valid?

3. **File Reference Consistency**
   - Do multiple steps reference the same files consistently?
   - Are file paths uniform across steps?
   - Are file modification sequences logical (create before modify)?

4. **Test Strategy Alignment**
   - Do step-level tests align with overview test strategy?
   - Are there gaps in test coverage across steps?
   - Do integration points between steps have integration tests?

5. **Integration Points**
   - Are cross-step integration points clearly defined?
   - Where steps interact, are interfaces specified?
   - Are there missing integration scenarios?

6. **Token Budget Compliance**
   - Overview: ~450 tokens (±50)
   - Each step: 150-240 tokens
   - Flag any files significantly over budget

**Output Format**:

For EACH issue found, provide:

```markdown
## Issue [N]: [Issue Title]

- **Severity**: [Critical/Medium/Low]
- **Category**: [Conflicting Approaches/Missing Dependencies/File Consistency/Test Alignment/Integration Points/Token Budget]
- **Location**: [Which file(s) affected]
- **Description**: [What's wrong and why it matters]
- **Impact**: [How this affects plan quality/execution]
- **Suggested Fix**: [Specific changes to make - exact file edits if possible]
```

**Summary Section**:

```markdown
## Review Summary

**Issues Found**: [Total count by severity]
- Critical: [count]
- Medium: [count]
- Low: [count]

**Overall Cohesiveness Score**: [0-10]

**Recommendation**:
- Score ≥ 8: Plan is cohesive, ready for PM review
- Score 6-7: Minor issues, fix before PM review
- Score < 6: Significant issues, requires revision

**Top Priority Fixes** (if score < 8):
1. [Fix 1]
2. [Fix 2]
3. [Fix 3]
```

Perform comprehensive review now and output your findings.
```

**Wait for Cohesiveness Reviewer to complete.**

**Process Review Results**:

1. **If Overall Cohesiveness Score ≥ 8**:
   ```text
   ✅ Cohesiveness Review Passed!

   Score: [X]/10
   Issues found: [count by severity]

   Plan is cohesive and ready for PM review.
   ```

   Proceed to Phase 6 (Present Plan to PM)

2. **If Overall Cohesiveness Score < 8**:
   ```text
   ⚠️ Cohesiveness Issues Detected!

   Score: [X]/10
   Critical issues: [count]
   Medium issues: [count]

   Applying fixes automatically...
   ```

   **Apply suggested fixes**:
   - For each Critical or Medium issue with a specific fix
   - Read the affected file
   - Apply the suggested edit using Edit tool
   - Save the updated file
   - Report fix applied

   **After applying fixes**:
   ```text
   ✅ Cohesiveness issues resolved!

   Updated files:
   - [list of files modified]

   Plan is now cohesive and ready for PM review.
   ```

**Update TodoWrite**: Mark "Delegate to Master Feature Planner Agent" as completed (complex path only)

**Proceed to Phase 6.**
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

### Phase 9: Report Plan Status (Plan May Already Be Saved)

**Update TodoWrite**: Mark appropriate task as in_progress (complex: "Save plan document to .rptc/plans/", simple: "Save plan document")

**Determine Planning Route Used**:

Check which route was used in Phase 5:

- **If Incremental Route (>2 steps)**: Plan files already saved during Phase 5 → Report success
- **If Monolithic Route (≤2 steps)**: Plan not yet saved → Save now

---

**Route A: Incremental Plan Already Saved** (if >2 steps):

**The plan was saved incrementally during Phase 5, so just report success**:

```text
✅ Plan Generation Complete!

The plan was saved incrementally during generation in Phase 5.

Location: [ARTIFACT_LOC]/plans/[feature-slug]/

Files created:
- overview.md (test strategy, acceptance criteria, risks)
- step-01.md through step-[0N].md ([N] implementation steps)

Total: [1 overview + N steps] files

✨ All files passed cohesiveness review!

Next steps:
- Review plan: ls -la [ARTIFACT_LOC]/plans/[feature-slug]/
- Start implementation: /rptc:tdd "@[feature-slug]"

Note: TDD command will automatically load directory-based plan structure.
```

**Update TodoWrite**: Mark appropriate task as completed

**END Phase 9** - Plan ready for implementation!

---

**Route B: Save Monolithic Plan** (if ≤2 steps):

**The monolithic plan needs to be saved now**:

1. **Check if plans directory exists**:
   - If `[ARTIFACT_LOC]/plans/` doesn't exist, create it using Bash:
     ```bash
     mkdir -p "[ARTIFACT_LOC value]/plans"
     ```

2. **Sanitize feature name to slug**:
   - Convert to lowercase
   - Replace spaces, special characters with hyphens
   - Remove multiple consecutive hyphens
   - Example: "User Authentication" → "user-authentication"

3. **Check if file already exists**:
   - Path: `[ARTIFACT_LOC]/plans/[feature-slug].md`
   - **If file exists**, ask PM:
     ```text
     ⚠️ Plan File Already Exists

     File: [ARTIFACT_LOC]/plans/[feature-slug].md

     Options:
     1. Overwrite - Replace existing file with new plan
     2. Abort - Keep existing plan, cancel save operation

     What would you like to do? (type "overwrite" or "abort")
     ```
   - **If PM says "overwrite"**: Delete existing file, proceed with save
   - **If PM says "abort"**: Exit Phase 9 without saving, inform PM operation cancelled
   - **Wait for PM response before proceeding**

4. **Save document to**: `[ARTIFACT_LOC]/plans/[feature-slug].md`

**Use legacy monolithic template format**:

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

- [ ] Run `/rptc:tdd "@[feature-slug].md"` to begin TDD implementation

---

_Plan created with Master Feature Planner_
_Status: ✅ Approved by Project Manager_
_SOP References: [List SOPs consulted]_
```

**Report Success**:

```text
✅ Plan saved to [ARTIFACT_LOC]/plans/[feature-slug].md

Next steps:
- Review: cat [ARTIFACT_LOC]/plans/[feature-slug].md
- Implement: /rptc:tdd "@[feature-slug].md"
```

**Update TodoWrite**: Mark appropriate task as completed
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
