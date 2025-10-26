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

## When to Use This Workflow vs Autonomous Agents

For guidance on choosing between predefined workflows (like RPTC) and autonomous agent patterns, see [Workflows vs Agents Decision Tree](../docs/RPTC_WORKFLOW_GUIDE.md#workflows-vs-agents-making-the-right-choice).

**Quick Rule**: If your task has a clear start and end with definable steps → Use workflows (RPTC)

## Step 0: Load SOPs

Load SOPs using fallback chain (highest priority first):

1. **Check project SOPs**: `.rptc/sop/`
2. **Check user global SOPs**: `~/.claude/global/sop/`
3. **Use plugin defaults**: `${CLAUDE_PLUGIN_ROOT}/sop/`

**SOPs to reference**:

- Architecture patterns: For design decisions
- Testing guide: For test strategy
- Flexible testing guide: For assertions on AI-generated or non-deterministic outputs
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
   - `rptc.discord.notificationsEnabled` → DISCORD_ENABLED (default: false)
   - `rptc.discord.webhookUrl` → DISCORD_WEBHOOK (default: "")
   - `rptc.discord.verbosity` → DISCORD_VERBOSITY (default: "summary")

3. **Display loaded configuration**:
   ```text
   Configuration loaded:
     Artifact location: [ARTIFACT_LOC value]
     Thinking mode: [THINKING_MODE value]
     Discord notifications: [DISCORD_ENABLED value]
   ```

4. **Create Discord notification helper function**:

```bash
notify_discord() {
  local message="$1"
  local min_verbosity="${2:-summary}"  # summary, detailed, or verbose

  # Check if notifications enabled
  if [ "$DISCORD_ENABLED" != "true" ] || [ -z "$DISCORD_WEBHOOK" ]; then
    return 0  # Silent skip
  fi

  # Check verbosity level
  case "$DISCORD_VERBOSITY" in
    summary)
      if [ "$min_verbosity" != "summary" ]; then
        return 0  # Skip this notification
      fi
      ;;
    detailed)
      if [ "$min_verbosity" = "verbose" ]; then
        return 0  # Skip verbose-only notifications
      fi
      ;;
    verbose)
      # Always send
      ;;
  esac

  # Send notification (fail-safe, never block workflow)
  if ! bash "${CLAUDE_PLUGIN_ROOT}/skills/discord-notify/scripts/notify.sh" \
    "$DISCORD_WEBHOOK" "$message" 2>/dev/null; then
    echo "⚠️  Discord notification failed (continuing workflow)" >&2
  fi
}
```

**Use these values throughout the command execution.**

## Step 0b: Initialize TODO Tracking

**Initialize TodoWrite to track planning progress.**

**IMPORTANT**: TodoWrite list depends on feature complexity determined after initial scaffolding.

### Complexity Assessment

After creating initial plan scaffold (Phase 2), determine:
- **Simple feature**: ≤2 implementation steps → Use 4-phase TodoWrite
- **Complex feature**: >2 implementation steps → Use 9-phase TodoWrite

### TodoWrite for Simple Features (≤2 steps)

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

### TodoWrite for Complex Features (>2 steps)

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

```bash
# Notify planning started
notify_discord "📋 **Planning Started**\nFeature: \`${FEATURE_NAME}\`" "summary"
```

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

4. **Manual Simulation (Optional Validation)**

   Before finalizing scaffold, optionally validate approach through simulation:

   **Ask PM**: "Should we manually simulate this approach with example inputs?"

   **If PM says yes:**

   a. **Use Inputs from Research** (if available):
      - If research phase included simulation: Reference those inputs
      - If no research phase: Create synthetic example inputs now

   b. **Synthetic Input Creation** (when needed):
      ```pseudo
      // Example for [feature name]:
      INPUT_SCENARIO_1: [typical case - describe in pseudo-code]
      INPUT_SCENARIO_2: [edge case - describe in pseudo-code]
      INPUT_SCENARIO_3: [error case - describe in pseudo-code]
      ```

   c. **Walk Through Proposed Steps**:
      - For each step in scaffold: "Given [input], after this step, what's the state?"
      - Verify: "Does this step sequence produce expected output?"
      - Identify: "Any missing steps or unclear transitions?"

   d. **Refine Scaffold Based on Simulation**:
      - Add missing steps discovered during walkthrough
      - Reorder steps if sequence doesn't match simulation
      - Clarify unclear step descriptions

   **Why This Matters**: Catches design flaws in scaffold before detailed planning. 5-10 minute simulation prevents hours of rework.

   **When to Skip**: Very simple features (<2 steps), well-understood patterns, or PM has high confidence in approach.

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

**Initialize TodoWrite** (v2.0.0+ - Directory Format Only):

All features now use incremental sub-agent delegation with directory format:

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

**Update TodoWrite**: Mark "Create initial plan scaffold with PM" as completed

```bash
# Notify scaffold complete
notify_discord "📐 **Scaffold Complete**\nSteps identified: ${TOTAL_STEPS}" "detailed"
```

### Phase 3: Clarifying Questions (REQUIRED)

**Update TodoWrite**: Mark "Ask clarifying questions to PM" as in_progress

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

5. **Specification Emphasis** (Structured Requirements)

   Ask PM to specify requirements across 6 critical areas:

   a. **Input/Output Formats**
      - Ask: "What data structures do we accept/return?"
      - Ask: "What are the API contracts or interface signatures?"
      - Example format: Request/response schemas, function signatures, data models

   b. **Business Rules**
      - Ask: "What validation rules apply to inputs?"
      - Ask: "What business logic constraints exist?"
      - Example format: "Field X must be..." or "When Y happens, then..."

   c. **Edge Cases**
      - Ask: "What boundary conditions should we handle?"
      - Ask: "What unusual but valid inputs could occur?"
      - Example format: Empty arrays, null values, min/max boundaries, concurrent operations

   d. **Integration Constraints**
      - Ask: "What external dependencies or APIs are involved?"
      - Ask: "What rate limits, quotas, or external constraints exist?"
      - Example format: Third-party API limits, database constraints, service dependencies

   e. **Performance Requirements**
      - Ask: "What response time or throughput requirements exist?"
      - Ask: "Are there scalability concerns?"
      - Example format: "<100ms response", "handles 1000 req/sec", "supports 1M records"

   f. **Security Compliance**
      - Ask: "What authentication/authorization is needed?"
      - Ask: "What data protection requirements apply?"
      - Example format: OAuth scopes, RBAC rules, encryption requirements, PII handling

   **Reference**: See architecture-patterns.md and security-and-performance.md SOPs for standards.

   **Note**: Not all sections apply to every feature. Skip if N/A.

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

### Phase 4.5: CRITICAL SIMPLICITY GATE - AUTOMATIC ENFORCEMENT (MANDATORY)

**CRITICAL SIMPLICITY GATE - AUTOMATIC ENFORCEMENT**

Before delegating to Master Feature Planner, perform AUTOMATIC simplicity validation:

**Simplicity Gate Checkpoint - DO NOT SKIP**

This gate PREVENTS over-engineering at the design phase. All checks are MANDATORY.

**Gate 1: Pattern Search Requirement**

Before proposing ANY new abstractions or components:

1. **Search for 3 similar patterns** in the existing codebase:
   ```bash
   # Use Grep to find similar implementations
   Grep "[relevant pattern keywords from scaffold]"
   # Search across relevant file types
   # Document findings: File paths, pattern descriptions
   ```

2. **Analyze found patterns**:
   - How does existing code solve similar problems?
   - What patterns are already established in this codebase?
   - Can existing components be reused or extended?

3. **Present findings to PM**:
   ```text
   🔍 Pattern Search Results:

   Found [N] similar patterns:
   1. [File:line] - [Pattern description]
   2. [File:line] - [Pattern description]
   3. [File:line] - [Pattern description]

   **Recommendation**: [Reuse existing pattern | Adapt pattern X | Justify new approach]
   ```

**ENFORCEMENT**: You CANNOT proceed to Master Feature Planner delegation without completing pattern search and presenting findings to PM.

---

**Gate 2: Abstraction Justification (Rule of Three)**

For ANY proposed abstractions (classes, interfaces, factories, middleware, base classes):

1. **Count use cases**:
   - How many CONCRETE use cases exist RIGHT NOW (not speculative)?
   - Are there 3+ actual implementations that would use this abstraction?

2. **Apply Rule of Three**:
   ```text
   - 1 use case → NEVER abstract (inline implementation)
   - 2 use cases → Consider duplication (maybe abstract if patterns nearly identical)
   - 3+ use cases → Abstraction justified (DRY principle applies)
   ```

3. **Challenge abstractions**:
   - If proposing base class/interface: "Can we inline this for now?"
   - If proposing factory pattern: "Do we have 3+ object types to create?"
   - If proposing middleware: "Is this simple operation being over-architected?"

**ENFORCEMENT**: Flag any abstractions with <3 use cases. Ask PM: "This abstraction has only [N] use cases. Should we inline for now and extract when we have 3+ cases?"

---

**Gate 3: Complexity Check**

Evaluate proposed approach for unnecessary complexity:

1. **Layer count**:
   - How many layers of indirection? (e.g., Controller → Service → Repository → DAO)
   - **RED FLAG**: >3 layers for simple CRUD operations
   - **QUESTION PM**: "Do we need all these layers, or can we simplify?"

2. **File count check**:
   - How many NEW files in the scaffold?
   - **RED FLAG**: >5 new files for a "simple" feature
   - **QUESTION PM**: "Can this be done by modifying 1-2 existing files instead?"

3. **Enterprise pattern detection**:
   - Does scaffold propose: Abstract Factory, Builder, Strategy, Observer, Mediator?
   - **RED FLAG**: Enterprise patterns for small projects or simple features
   - **QUESTION PM**: "Do we need [pattern name], or is there a simpler approach?"

**ENFORCEMENT**: For each RED FLAG, present to PM with simpler alternative.

---

**Gate 4: Simplicity Principle Validation**

Check scaffold against simplicity directives:

1. **KISS Check**:
   - Is this the SIMPLEST solution (not the most clever or flexible)?
   - **ASK PM**: "Could a junior developer understand this approach on first reading?"

2. **YAGNI Check**:
   - Are we building for CURRENT requirements (not speculative future needs)?
   - **ASK PM**: "Are we solving today's problem, or over-engineering for 'maybe later'?"

3. **Explicit over Clever**:
   - Is the approach explicit and readable (not concise but cryptic)?
   - **ASK PM**: "Is this approach clear, or are we being too clever?"

**ENFORCEMENT**: If ANY check fails, propose simpler alternative before proceeding.

---

**Gate Completion**:

After completing all 4 gates, update TodoWrite and inform PM:

```text
✅ Simplicity Gates Passed!

**Pattern Search**: [N] similar patterns found, alignment validated
**Abstraction Check**: [All abstractions justified by 3+ use cases | Simplified X abstractions]
**Complexity Check**: [No red flags | Addressed red flags: simplified Y]
**Simplicity Principles**: KISS, YAGNI, Explicit validated

**Proceeding to Master Feature Planner delegation...**
```

**Update TodoWrite**: Mark "Get PM approval for Master Feature Planner delegation" as in_progress (this was the final gate before delegation).

**PROCEED TO PHASE 5** (Master Feature Planner delegation).

---

### Phase 5: Incremental Plan Generation with Sub-Agent Delegation (Only After Approval)

**Update TodoWrite**: Mark "Delegate to Master Feature Planner Agent" as in_progress (complex path only)

```bash
# Notify Master Planner started
notify_discord "🤖 **Master Planner Started**\nGenerating detailed plan..." "detailed"
```

**Step 1: Determine Final Thinking Mode**:
   - If user specified a mode override (e.g., "yes, use ultrathink"): Use user's choice
   - Else: Use configured mode from Step 0a (THINKING_MODE value)

**Step 2: Incremental Sub-Agent Delegation**:

**Purpose**: Use incremental generation to:
- Create directory structure before content generation
- Generate and save overview immediately
- Generate and save each step incrementally
- Review cohesiveness across all steps
- Prevent timeout on large features
- Enable immediate persistence

**Architecture**: Directory scaffolding → Overview sub-agent → Step sub-agents (sequential) → Cohesiveness reviewer

**Inform PM**:

```text
🏗️ Using Incremental Plan Generation!

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
**Dependency Analysis: Determine Execution Mode**

**Before generating steps, analyze scaffold for dependencies:**

1. **Parse Scaffold Dependencies**:
   - Examine each step in PM-approved scaffold
   - Look for dependency indicators:
     - Explicit: "Depends on Step X"
     - Implicit: "Uses output from Step X"
     - File-based: "Modifies file created in Step X"

2. **Determine Execution Mode**:

   ```text
   **Simple Heuristic** (conservative approach for v1.2.0):

   IF all steps are independent (no dependencies mentioned):
     → PARALLEL MODE (generate all step files simultaneously)

   ELSE IF any step has dependencies:
     → SEQUENTIAL MODE (generate steps one-by-one)

   ELSE (uncertain):
     → SEQUENTIAL MODE (safe default)
   ```

3. **Report Execution Mode to PM**:

   **If PARALLEL:**
   ```text
   📊 Dependency Analysis: PARALLEL MODE

   All [N] steps are independent.
   Step files will be generated simultaneously for efficiency.

   Proceeding with parallel step generation...
   ```

   **If SEQUENTIAL:**
   ```text
   📊 Dependency Analysis: SEQUENTIAL MODE

   Steps have dependencies:
   - Step 2 depends on Step 1 (example)
   - Step 3 depends on Step 2 (example)

   Step files will be generated sequentially with dependency context.

   Proceeding with sequential step generation...
   ```

**NOTE for v1.2.0:**
- **Conservative approach:** Default to SEQUENTIAL unless explicitly confirmed parallel-safe
- **Future enhancement:** Implement phased execution (some parallel, some sequential)
- **Rationale:** Correctness over performance for initial release (PM Decision #4)

---


**Sub-Step 1: Generate Overview with Overview Generator Sub-Agent**

**Delegate to Overview Generator** via Task tool:

**Agent Configuration**:
- Thinking mode: [determined thinking mode]
- Sub-agent type: rptc:master-feature-planner-agent
- Output: overview.md written directly by sub-agent

Use the Task tool with subagent_type="rptc:master-feature-planner-agent":

**Prompt:**

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

---

## CRITICAL - FILE PERSISTENCE REQUIREMENT

You MUST use the Write tool to save this file immediately after generating content.

**Required Write tool invocation:**

Write(
  file_path: "[ARTIFACT_LOC]/plans/[feature-slug]/overview.md",
  content: [your complete overview.md content following the template above]
)

**IMPORTANT:**
- Do NOT just output the content as text
- You must DIRECTLY invoke the Write tool
- The main command will verify the file was created
- Return confirmation: "✅ overview.md written successfully"
- **ONLY create the single file specified above (overview.md)**
- **Do NOT create any other files** (no PLAN_SUMMARY.txt, README.md, or similar)

Output the complete overview.md content AND save it using Write tool now.
```

**Verify overview.md was created by sub-agent:**

1. **Check file exists**: `[ARTIFACT_LOC]/plans/[feature-slug]/overview.md`
2. **If missing**, retry once:
   - Report: "⚠️ overview.md not found, retrying sub-agent..."
   - Invoke Task tool again with same prompt (same thinking mode, same parameters)
   - Re-check file existence after retry
3. **If still missing** after retry:
   - Report error: "❌ Sub-agent failed to write overview.md after retry. Aborting plan generation."
   - Abort command execution
4. **If present**, report success:
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
- Output: Complete step-[0X].md written directly by sub-agent

Use the Task tool with `subagent_type="rptc:master-feature-planner-agent"`:

**Prompt:**

```text
Use [determined thinking mode] thinking mode for this planning task.

You are a STEP GENERATOR SUB-AGENT for incremental plan creation.

**Overall Feature Context**:
- Feature: [FEATURE_DESCRIPTION]
- Research findings: [RESEARCH_SUMMARY if applicable]
- Tech stack: [TECH_STACK]
- Total steps in feature: [N]
- Overview: [Brief summary from overview.md]
- PM input: [PM_CLARIFICATIONS]

**Previous Steps Context**:

[For step-02 through step-0N, include summaries of previous steps:]
Step [X-1] Summary:
- Purpose: [What it accomplished]
- Files modified: [List]
- Key decisions: [Important choices]
- Dependencies introduced: [Any new deps]
- Tests defined: [Count and types]

[Continue for all previous steps...]

**Your Task**: Generate ONLY Step [X] content.

**This Step's Details** (from scaffold):
- Step number: [X]
- Step name: [NAME from scaffold]
- Step description: [DESCRIPTION from scaffold]

**SOPs to Reference** (use fallback chain):
1. .rptc/sop/testing-guide.md
2. ~/.claude/global/sop/testing-guide.md
3. ${CLAUDE_PLUGIN_ROOT}/sop/testing-guide.md

Reference: [Relevant SOPs for this step]

**Project Overrides**: Check CLAUDE.md for project-specific patterns

**Output Required**: Complete step-[0X].md following this template:

[Include full step template structure here - Purpose, Prerequisites, Tests to Write First, Files to Create/Modify, Implementation Details (RED-GREEN-REFACTOR), Expected Outcome, Acceptance Criteria, Dependencies from Other Steps, Estimated Time]

**Target Token Count**: 150-240 tokens per step

**Coordination Requirements**:
- File paths consistent with overview.md
- Test scenarios use `- [ ]` checkbox format
- Reference SOPs rather than duplicating content

**CRITICAL**:
- All tests use `- [ ]` checkbox format
- Self-contained (TDD sub-agent loads ONLY overview + this step file)
- Reference SOPs rather than duplicating
- Be precise with line numbers and code examples

---

## CRITICAL - FILE PERSISTENCE REQUIREMENT

You MUST use the Write tool to save this file immediately after generating content.

**Required Write tool invocation:**

Write(
  file_path: "[ARTIFACT_LOC]/plans/[feature-slug]/step-[0X].md",
  content: [your complete step-[0X].md content following the template above]
)

**IMPORTANT:**
- Do NOT just output the content as text
- You must DIRECTLY invoke the Write tool
- The main command will verify the file was created
- Return confirmation: "✅ step-[0X].md written successfully"
- **ONLY create the single file specified above (step-[0X].md)**
- **Do NOT create any other files** (no PLAN_SUMMARY.txt, README.md, or similar)
- Use exact step number [0X] in filename (e.g., step-01.md, step-02.md)

Output the complete step-[0X].md content AND save it using Write tool now.
```

**Verify step-[0X].md was created by sub-agent:**

1. **Check file exists**: `[ARTIFACT_LOC]/plans/[feature-slug]/step-[0X].md`
2. **If missing**, retry once:
   - Report: "⚠️ step-[0X].md not found, retrying sub-agent..."
   - Invoke Task tool again with same prompt (same thinking mode, same parameters)
   - Re-check file existence after retry
3. **If still missing** after retry:
   - Report error: "❌ Sub-agent failed to write step-[0X].md after retry. Aborting plan generation."
   - Abort command execution
4. **If present**, store brief summary for next step context and report success:

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

```bash
# Notify Master Planner complete
notify_discord "✅ **Master Planner Complete**\nDetailed plan ready for review" "detailed"
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

### Phase 9: Report Plan Status

**Update TodoWrite**: Mark "Save plan document to .rptc/plans/" as in_progress

**Directory Format (v2.0.0+ - All Features)**:

The plan was saved incrementally during Phase 5 (sub-agent delegation), so just report success:

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

**Update TodoWrite**: Mark "Save plan document to .rptc/plans/" as completed

```bash
# Notify plan saved
notify_discord "💾 **Plan Saved**\nPlan: \`${PLAN_NAME}/\`\nReady for TDD" "summary"
```

**END Phase 9** - Plan ready for implementation!

---
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
