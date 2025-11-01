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

3. **Create Discord notification helper function**:

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
- **Complex feature**: >2 implementation steps → Use 6-phase TodoWrite

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
      "content": "Report plan completion",
      "status": "pending",
      "activeForm": "Reporting plan completion"
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
      "content": "Report plan completion",
      "status": "pending",
      "activeForm": "Reporting plan completion"
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

<!-- Architectural Note: This phase delegates to master-simplicity-agent for consistency
     with Phase 5 quality gate pattern and to leverage isolated context for complex validations.
     The agent has autonomous Edit tool access to simplify plans directly.

     Differentiation: This runs PRE-planning (PREVENTION) to validate scaffolds.
     master-efficiency-agent runs POST-TDD (REMEDIATION) to refactor implemented code. -->

**CRITICAL SIMPLICITY GATE - AUTOMATIC ENFORCEMENT**

Before delegating to Master Feature Planner, perform AUTOMATIC simplicity validation using specialized sub-agent.

**Update TodoWrite**: Mark "Perform automatic simplicity gate validation" as in_progress.

---

**Agent Configuration**:
- Thinking mode: [determined thinking mode]
- Sub-agent type: rptc:master-simplicity-agent
- Output: Modified scaffold returned inline (no file writes)

Use the Task tool with subagent_type="rptc:master-simplicity-agent":

**Prompt:**

```text
Use [determined thinking mode] thinking mode for this simplicity gate validation.

You are a SIMPLICITY GATE ANALYZER SUB-AGENT for preventing over-engineering at the design phase.

**Overall Feature Context**:
- Feature: [feature description]
- Research findings: [if applicable, from [ARTIFACT_LOC]/research/]
- Tech stack: [project tech from CLAUDE.md or .context/project-overview.md]
- Scaffold structure: [initial plan structure from Phase 2/3 with step summaries]
- PM input: [clarifications and requirements from Phase 1]

**Your Task**: Validate scaffold against 4 critical simplicity gates and apply autonomous simplifications.

**4-Gate Analysis** (ALL MANDATORY):

**Gate 1: Pattern Search Requirement**
- Use Grep tool to search for 3 similar patterns in existing codebase
- Search for: [relevant pattern keywords from scaffold]
- Analyze found patterns: How does existing code solve similar problems?
- Recommendation: Reuse existing pattern | Adapt pattern X | Justify new approach
- **If existing patterns found**: Use Edit tool to modify scaffold to align with codebase patterns

**Gate 2: Abstraction Justification (Rule of Three)**
- Count concrete use cases for each proposed abstraction (classes, interfaces, factories)
- Apply Rule of Three: 1 use case → inline, 2 → consider, 3+ → abstract
- **If <3 use cases detected**: Use Edit tool to inline abstraction in scaffold

**Gate 3: Complexity Check**
- Layer count check: Flag if >3 layers for simple operations
- File count check: Flag if >5 new files for "simple" feature
- Enterprise pattern detection: Flag Abstract Factory, Builder, Strategy, Observer, Mediator in small projects
- **If red flags detected**: Use Edit tool to simplify scaffold (reduce layers, merge files, remove enterprise patterns)

**Gate 4: Simplicity Principle Validation**
- KISS: Is this the simplest solution (not most clever/flexible)?
- YAGNI: Building for current requirements (not speculative future)?
- Explicit over Clever: Is approach clear and readable (not cryptic)?
- **If principles violated**: Use Edit tool to simplify scaffold

**SOPs to Reference** (use fallback chain):
1. .rptc/sop/architecture-patterns.md
2. ~/.claude/global/sop/architecture-patterns.md
3. ${CLAUDE_PLUGIN_ROOT}/sop/architecture-patterns.md

Reference: AI Over-Engineering Prevention section, Anti-pattern prohibition list, Simplicity checkpoint questions

**Autonomous Modification Authority**:
- You have FULL authority to use Edit tool to modify scaffold
- Apply simplifications directly (no approval needed for pattern alignment, abstraction inlining, complexity reduction)
- Document all modifications in output summary

**Output Requirements**:

Return modified scaffold inline with gate results summary:

```text
✅ Simplicity Gates Completed!

**Gate 1 - Pattern Search**:
[Found N similar patterns: file:line - description]
[Applied modifications: aligned scaffold with pattern X from file.ext]

**Gate 2 - Abstraction Check**:
[Analyzed M abstractions: N justified (3+ use cases), X inlined (1-2 use cases)]
[Applied modifications: inlined abstraction Y, removed premature interface Z]

**Gate 3 - Complexity Check**:
[Layer count: OK | Simplified from X to Y layers]
[File count: OK | Merged A and B files]
[Enterprise patterns: OK | Removed unnecessary pattern C]

**Gate 4 - Simplicity Principles**:
[KISS: validated | simplified approach to X]
[YAGNI: validated | removed speculative feature Y]
[Explicit: validated | replaced clever pattern Z with explicit code]

**Modified Scaffold**:
[Return complete scaffold structure with all simplifications applied]

**Recommendation**: [Proceed to Master Feature Planner | Additional PM review needed for concern X]
```

**CRITICAL**:
- Use Grep tool for pattern search (required for Gate 1)
- Use Edit tool autonomously to apply simplifications (no approval needed)
- Return modified scaffold inline (do NOT write any files)
- If major architectural concerns detected: flag for PM review before proceeding
```

**End of delegation prompt**

---

**After sub-agent completes:**

**Verification and Retry Logic:**

```bash
# Step 1: Parse sub-agent response for required sections
GATE1_FOUND=$(echo "$SUBAGENT_RESPONSE" | grep -c "Gate 1 - Pattern Search" || echo "0")
GATE2_FOUND=$(echo "$SUBAGENT_RESPONSE" | grep -c "Gate 2 - Abstraction Check" || echo "0")
GATE3_FOUND=$(echo "$SUBAGENT_RESPONSE" | grep -c "Gate 3 - Complexity Check" || echo "0")
GATE4_FOUND=$(echo "$SUBAGENT_RESPONSE" | grep -c "Gate 4 - Simplicity Principles" || echo "0")

VERIFICATION_PASSED=false
if [ "$GATE1_FOUND" -gt 0 ] && [ "$GATE2_FOUND" -gt 0 ] && \
   [ "$GATE3_FOUND" -gt 0 ] && [ "$GATE4_FOUND" -gt 0 ]; then
  VERIFICATION_PASSED=true
fi

# Step 2: Retry logic (if verification fails)
RETRY_ATTEMPT=0
MAX_RETRIES=1
FALLBACK_TRIGGERED=false

while [ "$VERIFICATION_PASSED" = false ] && [ "$RETRY_ATTEMPT" -lt "$MAX_RETRIES" ]; do
  echo ""
  echo "⚠️ Simplicity Gate sub-agent returned incomplete response."
  echo "   Missing required gate analysis sections."
  echo "   Retrying... (Attempt $((RETRY_ATTEMPT + 1)) of $MAX_RETRIES)"
  echo ""

  # Retry Task tool delegation (same prompt as original - lines 552-644)
  # [Task tool invocation would be repeated here with same parameters]

  # Re-verify retry response
  GATE1_FOUND=$(echo "$SUBAGENT_RESPONSE" | grep -c "Gate 1 - Pattern Search" || echo "0")
  GATE2_FOUND=$(echo "$SUBAGENT_RESPONSE" | grep -c "Gate 2 - Abstraction Check" || echo "0")
  GATE3_FOUND=$(echo "$SUBAGENT_RESPONSE" | grep -c "Gate 3 - Complexity Check" || echo "0")
  GATE4_FOUND=$(echo "$SUBAGENT_RESPONSE" | grep -c "Gate 4 - Simplicity Principles" || echo "0")

  if [ "$GATE1_FOUND" -gt 0 ] && [ "$GATE2_FOUND" -gt 0 ] && \
     [ "$GATE3_FOUND" -gt 0 ] && [ "$GATE4_FOUND" -gt 0 ]; then
    VERIFICATION_PASSED=true
    echo "✅ Retry successful - complete response received"
  fi

  RETRY_ATTEMPT=$((RETRY_ATTEMPT + 1))
done

# Step 3: Fallback to inline validation (if retry also fails)
if [ "$VERIFICATION_PASSED" = false ]; then
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  ⚠️ FALLBACK: Using Inline Simplicity Validation"
  echo "════════════════════════════════════════════════════════"
  echo ""
  echo "The Simplicity Gate sub-agent is currently unavailable"
  echo "or returned incomplete results after retry."
  echo ""
  echo "Falling back to basic inline validation."
  echo ""

  FALLBACK_TRIGGERED=true

  # INLINE FALLBACK: Basic simplicity checks without sub-agent
  # (Simplified version of 4-gate analysis performed inline)

  INLINE_FINDINGS=""

  # Gate 1 - Pattern Search (basic check)
  INLINE_FINDINGS="${INLINE_FINDINGS}Gate 1 - Pattern Search: SKIPPED (requires sub-agent)\n"
  INLINE_FINDINGS="${INLINE_FINDINGS}Recommendation: Review codebase manually for similar patterns.\n\n"

  # Gate 2 - Abstraction Check (basic heuristics)
  ABSTRACTION_COUNT=$(echo "$PLAN_SCAFFOLD" | grep -c "interface\|abstract\|factory\|builder" || echo "0")
  if [ "$ABSTRACTION_COUNT" -gt 3 ]; then
    INLINE_FINDINGS="${INLINE_FINDINGS}Gate 2 - Abstraction Check: ⚠️ WARNING\n"
    INLINE_FINDINGS="${INLINE_FINDINGS}Found ${ABSTRACTION_COUNT} potential abstractions. Verify each has 3+ use cases.\n\n"
  else
    INLINE_FINDINGS="${INLINE_FINDINGS}Gate 2 - Abstraction Check: ✅ PASSED\n"
    INLINE_FINDINGS="${INLINE_FINDINGS}Abstraction count appears reasonable.\n\n"
  fi

  # Gate 3 - Complexity Check (step count heuristic)
  STEP_COUNT=$(echo "$PLAN_SCAFFOLD" | grep -c "^## Step" || echo "0")
  if [ "$STEP_COUNT" -gt 10 ]; then
    INLINE_FINDINGS="${INLINE_FINDINGS}Gate 3 - Complexity Check: ⚠️ WARNING\n"
    INLINE_FINDINGS="${INLINE_FINDINGS}Plan has ${STEP_COUNT} steps. Consider breaking into smaller features.\n\n"
  else
    INLINE_FINDINGS="${INLINE_FINDINGS}Gate 3 - Complexity Check: ✅ PASSED\n"
    INLINE_FINDINGS="${INLINE_FINDINGS}Step count (${STEP_COUNT}) is manageable.\n\n"
  fi

  # Gate 4 - Simplicity Principles (reminder)
  INLINE_FINDINGS="${INLINE_FINDINGS}Gate 4 - Simplicity Principles: ⚠️ MANUAL REVIEW NEEDED\n"
  INLINE_FINDINGS="${INLINE_FINDINGS}Review plan against KISS, YAGNI, and explicit-over-clever principles.\n\n"

  INLINE_FINDINGS="${INLINE_FINDINGS}RECOMMENDATION: Sub-agent unavailable. Manual review recommended before proceeding.\n"

  SUBAGENT_RESPONSE="$INLINE_FINDINGS"
fi
```

**Present Findings to PM:**

```text
═══════════════════════════════════════════════════════════
  📋 CRITICAL SIMPLICITY GATE - FINDINGS
═══════════════════════════════════════════════════════════

Analysis Method: [if FALLBACK_TRIGGERED=true: "Inline validation (sub-agent unavailable)", else: "AI Sub-agent (master-simplicity-agent)"]

[Display SUBAGENT_RESPONSE content]

═══════════════════════════════════════════════════════════
```

**Update TodoWrite**: Mark "Perform automatic simplicity gate validation" as complete

**Decision point**:
1. **Review gate results**: Check if sub-agent (or inline fallback) flagged major concerns requiring PM review
2. If recommendation = "Proceed": Continue to Phase 5 (Master Feature Planner delegation)
3. If recommendation = "PM review needed": Present concerns to PM, get approval, then continue to Phase 5
4. **Use modified scaffold**: Pass sub-agent's modified scaffold (or original if fallback) to Master Feature Planner in Phase 5

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
Starting incremental plan generation...
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

1. **Attempt to read file using Read tool**: `[ARTIFACT_LOC]/plans/[feature-slug]/overview.md`
2. **If Read fails** (file not found), retry once:
   - Report: "⚠️ overview.md not found, retrying sub-agent..."
   - Invoke Task tool again with same prompt (same thinking mode, same parameters)
   - Attempt Read again after retry
3. **If Read still fails** after retry:
   - Report error: "❌ Sub-agent failed to write overview.md after retry. Aborting plan generation."
   - Abort command execution
4. **If Read succeeds**, extract strategic context and report success:
   - Parse "Step Breakdown" or "Implementation Steps" section from overview
   - Count steps: Extract step numbers (e.g., "Step 1:", "Step 2:", etc.)
   - Store step count as N for next phase
   ```text
   ✅ Overview generated and saved: overview.md

   Detected [N] implementation steps.

   Proceeding to generate individual step files...
   ```

**Note**: No bash file checks needed. Read tool returns error if file doesn't exist.

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

1. **Attempt to read file using Read tool**: `[ARTIFACT_LOC]/plans/[feature-slug]/step-[0X].md`
2. **If Read fails** (file not found), retry once:
   - Report: "⚠️ step-[0X].md not found, retrying sub-agent..."
   - Invoke Task tool again with same prompt (same thinking mode, same parameters)
   - Attempt Read again after retry
3. **If Read still fails** after retry:
   - Report error: "❌ Sub-agent failed to write step-[0X].md after retry. Aborting plan generation."
   - Abort command execution
4. **If Read succeeds**, extract brief summary for next step context:
   - Parse "## Summary" or "## Overview" section (first 3-5 lines)
   - Store summary for cumulative context in step [X+1]
   - Report success:

```text
✅ Step [X] generated and saved: step-[0X].md
```

**Note**: No bash file checks needed. Read tool handles file existence validation automatically.

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
- Output: Review report with fixes applied autonomously

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

**Fix Application Protocol** (CRITICAL - You MUST Apply Fixes):

When you identify issues, you MUST apply fixes directly using the Edit tool:

1. **For ALL severity levels** (Critical, Medium, Low):
   - Read the affected file using Read tool
   - Apply the fix using Edit tool (old_string → new_string)
   - If Edit fails, retry up to 3 times with slight variations
   - Mark "Fix Applied: YES" if successful, "Fix Applied: NO" if all retries fail

2. **Retry Logic for Edit Failures**:
   ```
   For EACH issue requiring a fix:

   1. Attempt Edit Tool with exact old_string/new_string from analysis
   2. If Edit fails:
      - Log failure reason clearly: "Edit failed (attempt 1/3): [reason]"
      - Retry up to 2 more times (3 total attempts)
      - On each retry, verify old_string still matches file state
   3. If all retries exhausted:
      - Document unfixed issue in final summary
      - Log: "Unable to apply fix after 3 attempts: [issue description]"
      - Continue to next issue (do not block plan generation)
   4. If Edit succeeds:
      - Mark issue as resolved
      - Proceed to next issue
   ```

3. **Re-Verification After All Fixes** (CRITICAL - Single Pass Only):

   After ALL fixes attempted (successful or failed):

   1. **Run cohesiveness analysis ONE MORE TIME** on all modified files
   2. **Report verification results:**
      - Issues successfully fixed
      - Issues still present (if any)
      - New issues introduced (if any)
   3. **Do NOT recursively re-fix** - single re-verification pass only

   **Error Handling Requirements:**
   - Clear retry logging: "Edit failed (attempt 1/3): [reason]"
   - Exhaustion messaging: "Unable to apply fix after 3 attempts: [issue description]"
   - Partial success handling: "Applied 4/5 fixes successfully, 1 unfixed: [details]"
   - Never block plan: If fixes fail, document and proceed

**IMPORTANT**: Do NOT suggest fixes for main context to apply. YOU apply them using Edit tool.

**Output Format**:

For EACH issue found, provide:

```markdown
## Issue [N]: [Issue Title]

- **Severity**: [Critical/Medium/Low]
- **Category**: [Conflicting Approaches/Missing Dependencies/File Consistency/Test Alignment/Integration Points/Token Budget]
- **Location**: [Which file(s) affected]
- **Description**: [What's wrong and why it matters]
- **Impact**: [How this affects plan quality/execution]
- **Fix Applied**: [YES/NO]
- **Fix Details**: [What was changed - old_string → new_string summary]
- **Fix Status**: [Success/Failed after 3 retries/Not applicable]
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

**Fixes Applied**: [count of successful fixes / total issues]

**Re-Verification Results** (after applying fixes):
- Initial cohesiveness score: [X]/10
- Post-fix cohesiveness score: [Y]/10
- Score improvement: [+N points or "No change - see explanation"]

**Files Modified**:
- [list of files edited with Edit tool]
- [example: overview.md - fixed inconsistent file path reference]
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

   Plan is cohesive and ready for completion.
   ```

2. **If Overall Cohesiveness Score < 8** (after sub-agent applied fixes):
   ```text
   ℹ️ Cohesiveness Issues Detected and Fixed by Reviewer

   Initial score: [X]/10
   Post-fix score: [Y]/10
   Fixes applied: [count successful / total issues]

   Files modified by reviewer:
   - [list from reviewer's output]

   Plan is now cohesive and ready for completion.
   ```

   **Note**: Fixes already applied by cohesiveness reviewer sub-agent. No main context action needed.

```bash
# Notify Master Planner complete
notify_discord "✅ **Master Planner Complete**\nDetailed plan ready for completion" "detailed"
```

**Update TodoWrite**: Mark "Delegate to Master Feature Planner Agent" as completed (complex path only)

**Proceed to Phase 6 (Final Output Generation).**

---

### Phase 6: Final Output Generation (REQUIRED)

**Update TodoWrite**: Mark "Report plan completion" as in_progress

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

**Update TodoWrite**: Mark "Report plan completion" as completed

```bash
# Notify plan saved
notify_discord "💾 **Plan Saved**\nPlan: \`${PLAN_NAME}/\`\nReady for TDD" "summary"
```

**END Phase 6** - Plan ready for implementation!

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
