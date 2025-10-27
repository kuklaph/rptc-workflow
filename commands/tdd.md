---
description: Test-driven implementation with quality gates (efficiency & security reviews)
---

# RPTC: TDD Phase

**You are the TDD implementation executor, following the plan strictly.**
The user is the **project manager** - they approve quality gates and final completion.

Arguments:

- Directory plan: `/rptc:tdd "@plan-name/"` (REQUIRED format in v2.0.0+)
- Monolithic plan: `/rptc:tdd "@plan-name.md"` (DEPRECATED - shows migration guide)
- Work item (no plan): `/rptc:tdd "simple calculator"` (generates directory plan on-the-fly)
- With TDG mode: `/rptc:tdd "@plan-name/" --tdg` (AI-accelerated test generation)

**Flags:**
- `--tdg`: Enable Test-Driven Generation mode (AI generates ~50 comprehensive tests per step)

**Note**: All plans must use directory format. Monolithic format deprecated in v2.0.0.

## Core Mission

Execute implementation using strict TDD methodology:

- RED: Write failing tests first
- GREEN: Write minimal code to pass
- REFACTOR: Improve while keeping tests green
- QUALITY: Efficiency and security reviews (with PM approval)
- **SYNC**: Keep plan document synchronized with progress

**Key Principle**: Never write implementation before tests. Never skip quality gates. Always keep plan synchronized.

## TDD Process

### Helper Commands Available

As a Master specialist agent, you have access to helper commands:

- `/rptc:helper-catch-up-quick` - Quick context (2 min)
- `/rptc:helper-catch-up-med` - Medium context (5-10 min)
- `/rptc:helper-catch-up-deep` - Deep analysis (15-30 min)

Use these if you need additional project context during implementation.

### Implementation Constraints (Optional in Plans)

Plans may include an **Implementation Constraints** section that guides TDD execution:

**What are Implementation Constraints?**
- Specific rules and limits that TDD sub-agents must follow during implementation
- Defined in the plan's `overview.md` file (directory format)
- Ensures consistent code quality and adherence to project standards

**Common Constraint Types**:
- **File size limits**: Maximum lines per file (e.g., <500 lines)
- **Simplicity requirements**: No abstractions until 3rd use (Rule of Three)
- **Architectural patterns**: Required patterns for specific functionality
- **Security checkpoints**: BLOCKING gates before sensitive operations
- **Performance budgets**: Response time limits, resource constraints

**Example Constraints Section** (from plan):
```markdown
## Implementation Constraints

- File size: All implementation files must be <500 lines
- Simplicity: No abstractions until pattern appears 3+ times (Rule of Three)
- Security: BLOCKING checkpoint required before any database writes
- Testing: Minimum 85% coverage for new code
```

**How Constraints are Used**:
- Automatically extracted from plan during Step 4d (Phase 0)
- Passed to TDD sub-agents in delegation prompts
- Sub-agents MUST respect constraints or request clarification
- If plan lacks constraints section, defaults to standard best practices (KISS/YAGNI)

**Backward Compatibility**: Plans without constraints section work normally - no errors, just use default best practices.

## Step 0: Load SOPs

Load SOPs using fallback chain (highest priority first):

1. **Check project SOPs**: `.rptc/sop/`
2. **Check user global SOPs**: `~/.claude/global/sop/`
3. **Use plugin defaults**: `${CLAUDE_PLUGIN_ROOT}/sop/`

**SOPs to reference**:

- Testing guide: TDD methodology, test patterns, coverage goals
- Flexible testing guide: Flexible assertions for AI-generated code and non-deterministic outputs
- Languages & style: Language conventions, formatters, linters
- Architecture patterns: Error handling, logging patterns
- Security: Security best practices

**Reference SOPs when**:

- Writing tests (testing guide)
- Writing assertions for AI-generated or non-deterministic code (flexible testing guide)
- Implementing code (languages & style)
- Error handling (architecture patterns)
- Security concerns (security guide)

**Project Overrides** (`.context/`):
Check for project-specific testing strategies or code style overrides.

## Step 0a: Load Configuration

**Load RPTC configuration from `.claude/settings.json`:**

1. **Check if settings file exists**:
   - Use Read tool to read `.claude/settings.json`
   - If file doesn't exist or can't be read, use defaults (skip to step 3)

2. **Parse configuration** (extract these fields):
   - `rptc.defaultThinkingMode` → THINKING_MODE (default: "think")
   - `rptc.artifactLocation` → ARTIFACT_LOC (default: ".rptc")
   - `rptc.maxPlanningAttempts` → MAX_ATTEMPTS (default: 10)
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

**Note**: References to these variables appear throughout this command as `$VARIABLE_NAME` or `[VARIABLE value]` - use the actual loaded values from this step.

## Step 0a2: Parse Command Arguments

**Parse command-line flags and plan reference from user input:**

```bash
# Initialize variables
PLAN_REF=""
TDG_FLAG=false

# Parse all arguments
for arg in "$@"; do
  case "$arg" in
    --tdg)
      TDG_FLAG=true
      ;;
    @*)
      PLAN_REF="$arg"
      ;;
    *)
      # First non-flag argument is plan reference
      if [ -z "$PLAN_REF" ]; then
        PLAN_REF="$arg"
      fi
      ;;
  esac
done

# Validate plan reference provided
if [ -z "$PLAN_REF" ]; then
  echo "❌ Error: Plan reference required"
  echo "   Usage: /rptc:tdd \"@plan-name/\" [--tdg]"
  echo ""
  echo "   Examples:"
  echo "     /rptc:tdd \"@user-authentication/\""
  echo "     /rptc:tdd \"@user-authentication/\" --tdg"
  echo ""
  exit 1
fi

```

**Variables set:**
- `PLAN_REF`: Plan reference (e.g., `"@plan-name/"`)
- `TDG_FLAG`: Boolean indicating if `--tdg` flag was provided

### Phase 0: Load Plan (REQUIRED)

**Step 1: Detect Plan Format**

**Supported Format (v2.0.0+):**
- **Directory format ONLY**: Argument must end with `/` (e.g., `@feature-name/`)
  - Plan stored as directory with `overview.md` + `step-*.md` files
  - Enables token-efficient sub-agent delegation
  - All plans must use this format

**Legacy Format Detection**:

```text
If plan argument ends with "/":
  → Directory format (supported)
  → Load overview + delegate steps to sub-agents

Else if plan argument ends with ".md":
  → Legacy monolithic format (DEPRECATED in v2.0.0)
  → Show migration guide
  → Reject with error

Else:
  → Error: Invalid format
  → Show usage examples
```

**Step 2a: Load Directory Format Plan**

If directory format detected:

1. **Verify overview file exists**: `$ARTIFACT_LOC/plans/[plan-name]/overview.md`

   ```bash
   OVERVIEW_FILE="${ARTIFACT_LOC}/plans/${PLAN_NAME}/overview.md"
   if [ ! -f "$OVERVIEW_FILE" ]; then
     echo "❌ Error: Plan overview not found"
     echo ""
     echo "   Expected file: $OVERVIEW_FILE"
     echo "   Plan reference: @${PLAN_NAME}/"
     echo ""
     echo "   This indicates incomplete or corrupted plan structure."
     echo ""
     echo "   Fix: Run /rptc:plan to regenerate the plan"
     echo "   Or: Check if plan directory exists: ${ARTIFACT_LOC}/plans/${PLAN_NAME}/"
     echo ""
     exit 1
   fi
   ```

2. **Load overview content**:
   - Read overview file using Read tool
   - Extract: Feature summary, test strategy, acceptance criteria

3. **Count step files**:
   - List all `step-*.md` files in directory
   - Count total steps: N

4. **Present Plan Summary** (Directory Format):

**FORMATTING NOTE:** Ensure each list item is on its own line with proper newlines.

```text
📋 Plan Loaded (Directory Format): [Feature Name]

Overview:
[First paragraph of overview.md]

Steps to implement: [N]
(Step details will be loaded per-step during Phase 1)

Test Strategy:
[From overview.md]

Architecture:
Directory-based plan with sub-agent delegation per step.
Quality gates (Efficiency/Security) execute after ALL steps complete.

Ready to begin TDD implementation with sub-agent delegation.
I will delegate each step to a TDD sub-agent that executes RED → GREEN → REFACTOR.
```

**Context Efficiency Strategy** (Directory Format):

For directory-based plans (features >2 steps):
- **Main context loads**: `overview.md` ONLY (~3K tokens)
- **Sub-agents load**: Individual `step-0N.md` files (~10-15K each)

**Why this matters**:
- **70-80% context savings** for large features
- Main context focuses on coordination, not implementation details
- Each step's implementation isolated in sub-agent context
- Enables features with 10-15 steps (vs. 3-5 without optimization)

**Trade-off**:
- Main context has strategic view (overview)
- Sub-agents have tactical view (step details)
- Coordination overhead: ~5K tokens per step (delegation + result processing)

This is an **intentional design choice** to maximize feature complexity capacity.

**Step 2b: Handle Legacy Monolithic Format** (BREAKING CHANGE - v2.0.0)

If monolithic format detected (argument ends with `.md`):

**Show Migration Error**:

```text
═══════════════════════════════════════════════════════════════
  ❌ MONOLITHIC PLAN FORMAT NO LONGER SUPPORTED (v2.0.0)
═══════════════════════════════════════════════════════════════

Your plan reference: @[plan-name].md
Legacy format: Monolithic (single .md file)
Status: DEPRECATED and removed in v2.0.0

═══════════════════════════════════════════════════════════════
  MIGRATION REQUIRED
═══════════════════════════════════════════════════════════════

Monolithic plan format was removed in v2.0.0 for:
✅ 79% token reduction (directory format)
✅ Better timeout handling (distributed sub-agents)
✅ Unlimited feature size (context-aware handoff)
✅ Simpler codebase (single execution path)

OPTION 1: Regenerate Plan (Recommended)
────────────────────────────────────────

  /rptc:plan "[feature description]"

  This creates a new directory-format plan optimized for v2.0.0.
  Your old plan remains at .rptc/plans/[plan-name].md for reference.

OPTION 2: Manual Conversion (Advanced)
────────────────────────────────────────

  1. Create directory: .rptc/plans/[plan-name]/
  2. Split monolithic plan into:
     - overview.md (test strategy, acceptance criteria, risks)
     - step-01.md through step-NN.md (individual steps)
  3. Follow template: ${CLAUDE_PLUGIN_ROOT}/templates/plan-directory/

  See: docs/MIGRATION_GUIDE.md for detailed instructions

OPTION 3: Use Old Version (Temporary)
────────────────────────────────────────

  If you need to complete work using monolithic format:

  1. Downgrade plugin: /plugin install rptc@1.2.0
  2. Complete your work
  3. Upgrade: /plugin install rptc@latest
  4. Regenerate plans in new format

═══════════════════════════════════════════════════════════════

For help: See docs/RPTC_WORKFLOW_GUIDE.md - "Migration from Monolithic Plans"
```

**HALT EXECUTION**: Do not proceed with TDD. User must migrate plan first.

**Step 3: Handle Invalid Format**

If plan argument doesn't match expected patterns (not `/` or `.md`):

```text
❌ Error: Invalid plan argument format

Expected format (v2.0.0+):
- Directory: /rptc:tdd "@plan-name/"

Your input: "@[user's input]"

The plan reference must end with "/" for directory format.
All plans must use directory structure in v2.0.0+.

To create a plan: /rptc:plan "[feature description]"
```

**If no plan provided** (simple work item description):

1. Create quick implementation plan (directory format)
2. Define test scenarios
3. List steps (create step files)
4. Proceed with TDD (sub-agent delegation)

**CRITICAL - Plan Synchronization**:

**For Directory Format**:
- Update step status in individual `step-NN.md` files
- Mark step complete after sub-agent finishes
- Update overview with progress

**For Monolithic Format**:
- Mark tests complete `- [x]` as they pass
- Mark implementation steps complete `- [x]` as they finish
- Update plan status from "Planned" to "In Progress" when starting
- This keeps the living document in sync with actual progress

**Step 4: Parse Plan Configuration** (Optional Quality Gates)

After loading the plan, parse the Configuration section to determine which quality gates are enabled.

1. **Extract quality gate preferences from plan**:
   
   For Directory Format:
   - Read overview.md
   - Look for "## Configuration" section
   - Parse "**Efficiency Review**: [value]" and "**Security Review**: [value]"
   
   For Monolithic Format:
   - Read plan file  
   - Look for "## Configuration" section (if exists)
   - Parse quality gate values

2. **Set configuration variables**:
   ```text
   EFFICIENCY_ENABLED = "enabled"  # default if not specified
   SECURITY_ENABLED = "enabled"    # default if not specified
   
   If Configuration section found:
     If "Efficiency Review" = "disabled": EFFICIENCY_ENABLED = "disabled"
     If "Security Review" = "disabled": SECURITY_ENABLED = "disabled"
   ```

3. **Display configuration**:
   ```text
   Quality Gate Configuration:
     Efficiency Review: [enabled/disabled]
     Security Review: [enabled/disabled]
   
   [If both disabled:]
   Note: Quality gates disabled for this plan. Implementation will proceed directly to final PM sign-off after TDD steps complete.
   
   [If one or both enabled:]
   Note: Quality gates enabled. PM approval required before executing enabled reviews.
   ```

**Use these values throughout command execution** to conditionally generate TODOs and skip/execute quality gate phases.

**Step 4d: Extract Implementation Constraints** (Phase 3B - Roadmap Item #5)

After loading the plan, extract implementation constraints to guide TDD execution.

1. **Extract constraints from plan** (Directory Format Only):

   ```bash
   # Directory format - always load from overview.md
   CONSTRAINTS=$(sed -n '/^## Implementation Constraints/,/^## /p' "${PLAN_DIR}/overview.md" | head -n -1)

   # Graceful degradation: default if section missing
   [ -z "$CONSTRAINTS" ] && CONSTRAINTS="No specific constraints defined."
   ```

2. **Purpose of Implementation Constraints**:

   Implementation Constraints ensure sub-agents respect:
   - File size limits (e.g., <500 lines per file)
   - Simplicity directives (KISS/YAGNI principles)
   - Pattern reuse requirements (Rule of Three)
   - Security checkpoints (from security-and-performance.md)
   - Project-specific architectural decisions

3. **Usage During Execution**:

   - Constraints are passed to TDD sub-agents in their delegation prompt
   - Sub-agents MUST respect constraints during implementation
   - If constraints conflict with approach, sub-agent should STOP and request clarification
   - Graceful handling: Plans without constraints section default to standard best practices

4. **Display constraints** (if present):
   ```text
   Implementation Constraints Loaded:
   [Display extracted constraints or "No specific constraints defined."]

   Sub-agents will respect these constraints during TDD execution.
   ```

**Note**: For Monolithic Format (legacy), constraints extraction can be added if needed, but directory format is recommended for constraint-aware execution.

**Step 4e: Validate Implementation Constraints** (Roadmap #14 - Quality Assurance)

After extracting constraints, validate they are readable and complete:

```bash
# Validate constraints are readable (not empty or corrupted)
if [ "$CONSTRAINTS" = "No specific constraints defined." ]; then
  echo "⚠️  No implementation constraints found in overview.md"
  echo "   Sub-agents will use standard best practices (KISS/YAGNI)"
else
  echo "✅ Implementation Constraints Loaded:"
  echo "$CONSTRAINTS" | head -n 5  # Show first 5 lines
  echo ""
fi
```

**Purpose**: Provide clear feedback about constraint availability for debugging and transparency.

## Phase 0e: Validation Utilities (Roadmap #14 - Reusable Logic)

**Purpose**: Centralized validation functions for plan structure integrity checks.

### Function: Validate Step File Exists

```bash
# Validates step file exists and provides helpful error if missing
# Usage: validate_step_file STEP_NUM PLAN_DIR TOTAL_STEPS
# Returns: 0 if valid, exits with error if invalid
validate_step_file() {
  local STEP_NUM=$1
  local PLAN_DIR=$2
  local TOTAL_STEPS=$3

  STEP_FILE="${PLAN_DIR}step-$(printf '%02d' $STEP_NUM).md"

  if [ ! -f "$STEP_FILE" ]; then
    echo "❌ Error: Step $STEP_NUM file not found"
    echo "   Expected: $STEP_FILE"
    echo "   Total steps in plan: $TOTAL_STEPS"
    echo ""
    echo "   Possible causes:"
    echo "   - Plan was modified after generation"
    echo "   - Step file was deleted"
    echo "   - Step numbering gap exists"
    echo ""
    echo "   Fix: Run /rptc:helper-update-plan to regenerate plan"
    exit 1
  fi

  return 0
}
```

### Function: Validate Step Sequence

```bash
# Validates no gaps in step numbering
# Usage: validate_step_sequence PLAN_DIR EXPECTED_STEPS
# Returns: 0 always (warnings only, not fatal)
validate_step_sequence() {
  local PLAN_DIR=$1
  local EXPECTED_STEPS=$2

  ACTUAL_STEPS=$(find "$PLAN_DIR" -name "step-*.md" 2>/dev/null | wc -l)

  if [ "$ACTUAL_STEPS" -ne "$EXPECTED_STEPS" ]; then
    echo "⚠️  Warning: Step count mismatch"
    echo "   Overview declares: $EXPECTED_STEPS steps"
    echo "   Step files found: $ACTUAL_STEPS"
    echo ""
    echo "   Proceeding with available steps (fail-safe mode)..."
    echo ""
  fi

  return 0
}
```

**Usage**: These functions are called during Phase 1 execution to ensure plan integrity before delegating to sub-agents.

## Step 0c: Check for Resume State

**Purpose**: Detect existing handoff checkpoint and offer auto-resume or restart options. This enables seamless continuation after interruptions by preserving context and progress state.

**Determine handoff path** (directory format only):

```bash
# Directory format - handoff in plan directory
if [ "$PLAN_FORMAT" = "directory" ]; then
  HANDOFF_PATH="${PLAN_DIR}handoff.md"
else
  HANDOFF_PATH=""  # Monolithic plans don't use handoff (legacy)
fi
```

**Check for existing handoff and offer resume**:

```bash
if [ -n "$HANDOFF_PATH" ] && [ -f "$HANDOFF_PATH" ]; then
  echo "🔄 **Interrupted Session Detected**"
  echo ""
  cat "$HANDOFF_PATH"
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  RESUME OPTIONS"
  echo "════════════════════════════════════════════════════════"
  echo ""
  echo "**Option 1: Resume from Checkpoint (Recommended)**"
  echo "- TDD will start from the checkpoint step"
  echo "- Previous step results are preserved"
  echo "- Configuration from original session is restored"
  echo "- Cumulative context maintained"
  echo ""
  echo "**Option 2: Restart from Beginning**"
  echo "- Handoff file will be deleted"
  echo "- TDD starts fresh from Step 1"
  echo "- All progress since checkpoint lost"
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo ""

  # Prompt user for decision
  echo "**Choose an option:**"
  echo "- Type 'resume' to continue from checkpoint"
  echo "- Type 'restart' to begin fresh"
  echo "- Type 'review' to check handoff details with /rptc:helper-resume-plan first"
  echo ""

  # Claude interprets user response and sets appropriate mode:

  # If user says "resume":
  # 1. Parse handoff.md for "**Current Step**: Step N"
  #    RESUME_STEP=$(grep "^\*\*Current Step\*\*:" "$HANDOFF_PATH" | sed 's/.*Step \([0-9]*\).*/\1/')
  # 2. Validate step number is valid (1 <= N <= TOTAL_STEPS)
  # 3. Set RESUME_MODE=true
  # 4. In Phase 1 execution, start step loop from RESUME_STEP instead of 1
  # 5. Load configuration from handoff.md JSON block
  # 6. Skip completed steps in TODO list (mark as completed)

  # If user says "restart":
  # 1. Confirm deletion: "This will delete handoff and restart. Confirm? (yes/no)"
  # 2. If confirmed: rm "$HANDOFF_PATH"
  # 3. Set RESUME_MODE=false
  # 4. Continue normal flow from Step 1
  # 5. Echo: "✅ Handoff deleted. Starting fresh from Step 1..."

  # If user says "review":
  # 1. Echo: "Run: /rptc:helper-resume-plan \"${PLAN_REF}\""
  # 2. Echo: "Then restart this TDD command with your decision."
  # 3. Exit gracefully (exit 0)
fi
```

**Edge Case Handling**:

```bash
# Corrupted handoff detection
if [ -n "$HANDOFF_PATH" ] && [ -f "$HANDOFF_PATH" ]; then
  # Attempt to parse step number
  RESUME_STEP=$(grep "^\*\*Current Step\*\*:" "$HANDOFF_PATH" | sed 's/.*Step \([0-9]*\).*/\1/' 2>/dev/null)

  # If parsing fails (empty or invalid)
  if [ -z "$RESUME_STEP" ]; then
    echo "⚠️  **Handoff File Corrupted**"
    echo ""
    echo "Unable to parse checkpoint state from: $HANDOFF_PATH"
    echo ""
    echo "This may indicate:"
    echo "- Incomplete handoff generation"
    echo "- File corruption"
    echo "- Format mismatch (old version)"
    echo ""
    echo "**Recommendation**: Delete handoff and restart fresh"
    echo "  rm \"$HANDOFF_PATH\""
    echo "  /rptc:tdd \"${PLAN_REF}\""
    echo ""
    exit 1
  fi

  # Validate step number is within bounds
  TOTAL_STEPS=$(find "$PLAN_DIR" -name "step-*.md" 2>/dev/null | wc -l)
  if [ "$RESUME_STEP" -lt 1 ] || [ "$RESUME_STEP" -gt "$TOTAL_STEPS" ]; then
    echo "⚠️  **Invalid Handoff Step Number**"
    echo ""
    echo "Handoff references Step $RESUME_STEP, but plan has $TOTAL_STEPS steps."
    echo ""
    echo "This may indicate:"
    echo "- Plan was modified after handoff"
    echo "- Handoff file corruption"
    echo "- Step renumbering"
    echo ""
    echo "**Recommendation**: Regenerate plan or restart fresh"
    echo "  Option A: /rptc:plan (regenerate)"
    echo "  Option B: rm \"$HANDOFF_PATH\" && /rptc:tdd \"${PLAN_REF}\" (restart)"
    echo ""
    exit 1
  fi
fi
```

**Developer Notes**:

- **Handoff Format Dependency**: Handoff.md format defined in Step 3b (handoff generation, lines 551-680)
- **Location Strategy**: Handoff.md belongs in plan directory (`${PLAN_DIR}handoff.md`) for easy discovery alongside step files
- **Resume Logic**: Allows mid-feature interruption without progress loss - critical for large features (10+ steps)
- **State Preservation**: Configuration (thinking mode, coverage targets) restored from handoff JSON block
- **Future Enhancement**: Auto-cleanup handoff on successful completion (not implemented in this step - would go in Phase 5)

**Integration with helper-resume-plan**:

Users can run `/rptc:helper-resume-plan "@plan-name/"` to review handoff details before deciding whether to resume or restart. The helper command provides detailed context analysis and resumption guidance.


## Phase 0g: Auto-Handoff Utility Functions (Roadmap #22)

**Purpose:** Reusable prediction and handoff generation functions.

---

### Function: Calculate File-Based Estimate

**Estimate tokens from step file size:**

```bash
calculate_file_estimate() {
  local STEP_FILE=$1

  if [ ! -f "$STEP_FILE" ]; then
    echo "$COLD_START_FLOOR"
    return
  fi

  local CHARS=$(wc -m < "$STEP_FILE" 2>/dev/null || echo "0")
  local ESTIMATE=$(awk "BEGIN {printf \"%.0f\", ($CHARS / 4) * 1.25}")

  echo "$ESTIMATE"
}
```

### Function: Calculate Historical Average

**Average of last 3 completed steps:**

```bash
calculate_historical_average() {
  local COMPLETED=$1

  if [ "$COMPLETED" -lt 3 ]; then
    echo "$COLD_START_FLOOR"
    return
  fi

  local LAST_3=("${STEP_CONTEXT_USAGE[@]: -3}")
  local SUM=0
  for usage in "${LAST_3[@]}"; do
    SUM=$((SUM + usage))
  done

  echo "$((SUM / 3))"
}
```

### Function: Calculate Growth Estimate

**Extrapolate from recent trend:**

```bash
calculate_growth_estimate() {
  local COMPLETED=$1

  if [ "$COMPLETED" -lt 2 ]; then
    echo "0"
    return
  fi

  # Calculate deltas
  declare -a DELTAS=()
  for ((i=1; i<${#STEP_CONTEXT_USAGE[@]}; i++)); do
    DELTAS+=($((${STEP_CONTEXT_USAGE[$i]} - ${STEP_CONTEXT_USAGE[$((i-1))]})))
  done

  # Average growth
  local SUM=0
  for delta in "${DELTAS[@]}"; do
    SUM=$((SUM + delta))
  done
  local AVG=$((SUM / ${#DELTAS[@]}))

  # Extrapolate
  local LAST=${STEP_CONTEXT_USAGE[-1]}
  echo "$((LAST + AVG))"
}
```

### Function: Apply Safety Factors

**Apply 1.5× multiplier + 3% margin + calibration:**

```bash
apply_safety_factors() {
  local BASE_ESTIMATE=$1

  # 1.5× multiplier
  local AFTER_MULT=$(awk "BEGIN {printf \"%.0f\", $BASE_ESTIMATE * $SAFETY_MULTIPLIER}")

  # 3% margin
  local MARGIN=$(awk "BEGIN {printf \"%.0f\", $AFTER_MULT * $SAFETY_MARGIN_PCT}")
  local TOTAL=$((AFTER_MULT + MARGIN))

  # Calibration
  local CALIBRATED=$(awk "BEGIN {printf \"%.0f\", $TOTAL * $CALIBRATION_MULTIPLIER}")

  echo "$CALIBRATED"
}
```

### Function: Calculate Average Prediction Error

**For handoff and calibration reporting:**

```bash
calculate_average_error() {
  if [ "${#PREDICTION_ERRORS[@]}" -eq 0 ]; then
    echo "N/A"
    return
  fi

  local ERROR_SUM=0
  for error in "${PREDICTION_ERRORS[@]}"; do
    ERROR_SUM=$(awk "BEGIN {printf \"%.1f\", $ERROR_SUM + $error}")
  done

  local AVG=$(awk "BEGIN {printf \"%.1f\", $ERROR_SUM / ${#PREDICTION_ERRORS[@]}}")
  echo "$AVG"
}
```

### Function: Generate Step Summaries for Handoff

**Extract step purposes for handoff.md:**

```bash
generate_step_summaries() {
  local COMPLETED_STEP=$1
  local SUMMARIES=""

  for ((i=1; i<=COMPLETED_STEP; i++)); do
    local STEP_FILE="${PLAN_DIR}step-$(printf '%02d' $i).md"
    if [ -f "$STEP_FILE" ]; then
      local STEP_PURPOSE=$(sed -n '/^## Purpose/,/^## /p' "$STEP_FILE" | head -n -1 | tail -n +2)
      SUMMARIES+="#### Step ${i}\n\n"
      SUMMARIES+="${STEP_PURPOSE}\n\n"
      SUMMARIES+="**Status:** ✅ Complete\n\n"
    fi
  done

  echo -e "$SUMMARIES"
}
```

### Function: Generate Usage Table for Handoff

**Create token usage table:**

```bash
generate_usage_table() {
  local COMPLETED_STEP=$1
  local TABLE=""
  local CUMULATIVE=15000  # Start with overview.md

  for ((i=0; i<${#STEP_CONTEXT_USAGE[@]}; i++)); do
    local STEP_NUM=$((i + 1))
    local USAGE=${STEP_CONTEXT_USAGE[$i]}
    CUMULATIVE=$((CUMULATIVE + USAGE))
    local PCT=$(( (CUMULATIVE * 100) / TOTAL_CONTEXT_CAPACITY ))

    TABLE+="${STEP_NUM} | ${USAGE} | ${CUMULATIVE} | ${PCT}%\n"
  done

  echo -e "$TABLE"
}
```

### Function: Generate Enhanced Handoff Checkpoint

**Creates handoff.md with complete prediction state:**

```bash
generate_handoff_checkpoint() {
  local COMPLETED_STEP=$1
  local PROJECTED_TOTAL=$2
  local TRIGGER_REASON=$3

  local HANDOFF_FILE="${PLAN_DIR}handoff.md"

  echo "📝 Generating enhanced handoff checkpoint..."
  echo ""

  # Calculate progress percentage
  local PROGRESS_PCT=$(( (COMPLETED_STEP * 100) / TOTAL_STEPS ))

  # Collect files modified (across all completed steps)
  local FILES_MODIFIED=$(git diff --name-only HEAD~$COMPLETED_STEP 2>/dev/null || echo "Unable to detect")

  # Count tests passing
  local TESTS_STATUS="[Run test suite to verify]"

  # Create enhanced handoff template
  cat > "$HANDOFF_FILE" <<EOF
# TDD Handoff Checkpoint

**Feature:** ${PLAN_NAME}
**Checkpoint Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Trigger Reason:** ${TRIGGER_REASON}

---

## Status Summary

**Progress:** ${COMPLETED_STEP} of ${TOTAL_STEPS} steps completed (${PROGRESS_PCT}%)

**Completed Steps:** 1 through ${COMPLETED_STEP}

**Next Step:** $((COMPLETED_STEP + 1)) ($(printf 'step-%02d.md' $((COMPLETED_STEP + 1))))

**Tests Status:** ${TESTS_STATUS}

---

## Context Metrics

**Current Context Usage:** ${CURRENT_CONTEXT} tokens ($(( (CURRENT_CONTEXT * 100) / TOTAL_CONTEXT_CAPACITY ))% of capacity)

**Projected with Next Step:** ${PROJECTED_TOTAL} tokens ($(( (PROJECTED_TOTAL * 100) / TOTAL_CONTEXT_CAPACITY ))% of capacity)

**Hard Cap (80%):** ${HARD_CAP_TOKENS} tokens

**Why Handoff Triggered:**
- Next step predicted at ${FINAL_PREDICTION} tokens (with safety factors)
- Would push total to ${PROJECTED_TOTAL} tokens
- Exceeds ${HARD_CAP_TOKENS} hard cap (80% of ${TOTAL_CONTEXT_CAPACITY})

---

## Completed Work Summary

### Files Modified

\`\`\`
${FILES_MODIFIED}
\`\`\`

### Step Summaries

$(generate_step_summaries "$COMPLETED_STEP")

---

## Historical Context Usage

**Per-Step Token Deltas:**

| Step | Actual Usage | Cumulative | % of Capacity |
|------|--------------|------------|---------------|
$(generate_usage_table "$COMPLETED_STEP")

**Prediction Accuracy:**
- Average Error: $(calculate_average_error)%
- Calibration Multiplier: ${CALIBRATION_MULTIPLIER}×

---

## Calibration Data (for Resume)

**Historical Usage Array:**
\`\`\`bash
STEP_CONTEXT_USAGE=(${STEP_CONTEXT_USAGE[@]})
\`\`\`

**Prediction Errors Array:**
\`\`\`bash
PREDICTION_ERRORS=(${PREDICTION_ERRORS[@]})
\`\`\`

**Calibration Multiplier:**
\`\`\`bash
CALIBRATION_MULTIPLIER=${CALIBRATION_MULTIPLIER}
\`\`\`

**Current Context:**
\`\`\`bash
CURRENT_CONTEXT=${CURRENT_CONTEXT}
\`\`\`

---

## Resume Instructions

**To continue in fresh context:**

\`\`\`bash
/rptc:helper-resume-plan "@${PLAN_NAME}/"
\`\`\`

**What will happen:**
1. Helper loads this handoff checkpoint
2. Restores historical usage data and calibration
3. Initializes fresh context (15K starting point)
4. Continues from Step $((COMPLETED_STEP + 1))
5. Uses calibrated prediction for remaining steps

**Important:**
- Tests must still be passing before resume
- Review completed work summary above
- Verify files modified are correct
- Check that next step is appropriate to continue

---

_Generated by RPTC Auto-Handoff (Roadmap #22)_
_Research: dynamic-context-prediction.md (25 sources)_
EOF

  echo "✅ Handoff checkpoint created: ${HANDOFF_FILE}"
  echo ""
}
```

---

## Step 0b: Initialize TODO Tracking

**Generate TodoWrite list dynamically from plan steps and quality gate configuration.**

### Parse Plan Document

1. Read plan document specified in command argument
2. Extract all implementation steps (look for numbered steps or checklist items)
3. Count total steps: N
4. Use quality gate configuration from Step 4 (EFFICIENCY_ENABLED, SECURITY_ENABLED)

### Generate TodoWrite List

For each of N plan steps, create 4 TODOs:
- Step X: RED phase
- Step X: GREEN phase
- Step X: REFACTOR phase
- Step X: SYNC plan

After all N steps, add quality gate TODOs **conditionally based on configuration**:

**If EFFICIENCY_ENABLED = "enabled":**
- REQUEST PM: Efficiency Agent approval
- EXECUTE: Efficiency Agent review

**If SECURITY_ENABLED = "enabled":**
- REQUEST PM: Security Agent approval
- EXECUTE: Security Agent review

**Always add** (regardless of quality gate config):
- Documentation Specialist review (automatic)
- REQUEST PM: Final TDD sign-off
- UPDATE: Mark plan status Complete

**Total TODOs calculation:**
- Base: (N × 4) implementation step TODOs
- Quality gates: +2 if Efficiency enabled, +2 if Security enabled, +0 if both disabled
- Always: +3 (Doc Specialist, PM sign-off, Plan update)
- **Total: (N × 4) + [0-4 quality gate] + 3**

### Example TodoWrite (3-step plan, both quality gates enabled)

```json
{
  "tool": "TodoWrite",
  "todos": [
    {"content": "Step 1: RED - Write failing tests", "status": "pending", "activeForm": "Writing tests for Step 1"},
    {"content": "Step 1: GREEN - Implement to pass", "status": "pending", "activeForm": "Implementing Step 1"},
    {"content": "Step 1: REFACTOR - Improve quality", "status": "pending", "activeForm": "Refactoring Step 1"},
    {"content": "Step 1: SYNC - Update plan", "status": "pending", "activeForm": "Syncing plan for Step 1"},

    {"content": "Step 2: RED - Write failing tests", "status": "pending", "activeForm": "Writing tests for Step 2"},
    {"content": "Step 2: GREEN - Implement to pass", "status": "pending", "activeForm": "Implementing Step 2"},
    {"content": "Step 2: REFACTOR - Improve quality", "status": "pending", "activeForm": "Refactoring Step 2"},
    {"content": "Step 2: SYNC - Update plan", "status": "pending", "activeForm": "Syncing plan for Step 2"},

    {"content": "Step 3: RED - Write failing tests", "status": "pending", "activeForm": "Writing tests for Step 3"},
    {"content": "Step 3: GREEN - Implement to pass", "status": "pending", "activeForm": "Implementing Step 3"},
    {"content": "Step 3: REFACTOR - Improve quality", "status": "pending", "activeForm": "Refactoring Step 3"},
    {"content": "Step 3: SYNC - Update plan", "status": "pending", "activeForm": "Syncing plan for Step 3"},

    {"content": "REQUEST PM: Efficiency Agent approval", "status": "pending", "activeForm": "Requesting Efficiency Agent approval"},
    {"content": "EXECUTE: Efficiency Agent review", "status": "pending", "activeForm": "Running Efficiency Agent"},
    {"content": "REQUEST PM: Security Agent approval", "status": "pending", "activeForm": "Requesting Security Agent approval"},
    {"content": "EXECUTE: Security Agent review", "status": "pending", "activeForm": "Running Security Agent"},
    {"content": "Documentation Specialist review (automatic)", "status": "pending", "activeForm": "Running Documentation Specialist"},
    {"content": "REQUEST PM: Final TDD sign-off", "status": "pending", "activeForm": "Requesting final sign-off"},
    {"content": "UPDATE: Mark plan status Complete", "status": "pending", "activeForm": "Updating plan status"}
  ]
}
```

### Example TodoWrite (3-step plan, quality gates disabled)

```json
{
  "tool": "TodoWrite",
  "todos": [
    {"content": "Step 1: RED - Write failing tests", "status": "pending", "activeForm": "Writing tests for Step 1"},
    {"content": "Step 1: GREEN - Implement to pass", "status": "pending", "activeForm": "Implementing Step 1"},
    {"content": "Step 1: REFACTOR - Improve quality", "status": "pending", "activeForm": "Refactoring Step 1"},
    {"content": "Step 1: SYNC - Update plan", "status": "pending", "activeForm": "Syncing plan for Step 1"},

    {"content": "Step 2: RED - Write failing tests", "status": "pending", "activeForm": "Writing tests for Step 2"},
    {"content": "Step 2: GREEN - Implement to pass", "status": "pending", "activeForm": "Implementing Step 2"},
    {"content": "Step 2: REFACTOR - Improve quality", "status": "pending", "activeForm": "Refactoring Step 2"},
    {"content": "Step 2: SYNC - Update plan", "status": "pending", "activeForm": "Syncing plan for Step 2"},

    {"content": "Step 3: RED - Write failing tests", "status": "pending", "activeForm": "Writing tests for Step 3"},
    {"content": "Step 3: GREEN - Implement to pass", "status": "pending", "activeForm": "Implementing Step 3"},
    {"content": "Step 3: REFACTOR - Improve quality", "status": "pending", "activeForm": "Refactoring Step 3"},
    {"content": "Step 3: SYNC - Update plan", "status": "pending", "activeForm": "Syncing plan for Step 3"},

    {"content": "Documentation Specialist review (automatic)", "status": "pending", "activeForm": "Running Documentation Specialist"},
    {"content": "REQUEST PM: Final TDD sign-off", "status": "pending", "activeForm": "Requesting final sign-off"},
    {"content": "UPDATE: Mark plan status Complete", "status": "pending", "activeForm": "Updating plan status"}
  ]
}
```

**TodoWrite Rules**:
- Parse plan to determine N (number of steps)
- Parse quality gate configuration (EFFICIENCY_ENABLED, SECURITY_ENABLED)
- Create 4 TODOs per step (RED/GREEN/REFACTOR/SYNC)
- Add quality gate TODOs only if enabled in plan configuration
- Always add: Doc Specialist, Final PM sign-off, Plan update
- Total TODOs = (N × 4) + [0-4 quality gates] + 3
- Only ONE task "in_progress" at a time
- Mark tasks "completed" immediately after finishing each phase

## Phase 0c: Test-Driven Generation Setup (Roadmap #16 - TDG Mode)

**Purpose**: Configure AI-accelerated comprehensive test generation from plan specifications to reduce TDD overhead by ~80%.

**When Executed**: During Phase 0 (setup), before Phase 1 (TDD implementation). Actual test generation happens per-step in Phase 1.

**Configuration**: Controlled by `--tdg` flag OR `.claude/settings.json` → `rptc.tdgMode`

**Research Context**: TDG eliminates ~80% of TDD overhead (~50 tests in <5 min per research findings)

**PM Decision**: AUGMENTATION mode (planned scenarios + AI-generated tests, not replacement)

---

### Step 1: Check TDG Mode Configuration

**Determine if TDG mode should be enabled:**

```bash
# Load TDG configuration from settings.json
TDG_CONFIG=$(jq -r '.rptc.tdgMode // "disabled"' .claude/settings.json 2>/dev/null || echo "disabled")

# Determine if TDG should run
RUN_TDG=false

# Priority 1: --tdg flag (explicit user request)
if [ "$TDG_FLAG" = "true" ]; then
  RUN_TDG=true
  echo "✅ TDG Mode: Enabled via --tdg flag"

# Priority 2: Configuration setting
elif [ "$TDG_CONFIG" = "enabled" ]; then
  RUN_TDG=true
  echo "✅ TDG Mode: Enabled via configuration (tdgMode: enabled)"

# Default: Disabled
else
  echo "⏩ TDG Mode: Disabled"
  echo "   Use --tdg flag or set tdgMode: \"enabled\" in .claude/settings.json"
  echo "   Continuing with manual test writing in RED phase"
fi

echo ""
```

**Configuration Options:**
- `"disabled"` (default): Require explicit `--tdg` flag
- `"enabled"`: Always use TDG mode (no flag needed)
- `"auto"`: Future enhancement - use heuristics to decide

---

### Step 2: Validate Plan Format (TDG Requirement)

**TDG mode requires directory format plans:**

```bash
if [ "$RUN_TDG" = "true" ]; then
  # Check plan format (PLAN_FORMAT set in Phase 0 Step 1)
  if [ "$PLAN_FORMAT" != "directory" ]; then
    echo "════════════════════════════════════════════════════════"
    echo "  ❌ TDG MODE REQUIRES DIRECTORY PLAN FORMAT"
    echo "════════════════════════════════════════════════════════"
    echo ""
    echo "Current plan: @${PLAN_NAME} (${PLAN_FORMAT} format)"
    echo "Required: @${PLAN_NAME}/ (directory format)"
    echo ""
    echo "Reason: TDG generates per-step test suites, requiring"
    echo "        directory structure with step-0N.md files"
    echo ""
    echo "Monolithic plans deprecated in v2.0.0."
    echo ""
    echo "Fix: Run /rptc:plan to regenerate plan in directory format"
    echo "════════════════════════════════════════════════════════"
    echo ""
    exit 1
  fi

  echo "✅ Plan format validated: Directory format (compatible with TDG)"
  echo ""
fi
```

---

### Step 3: Load TDG Template

**Verify TDG template exists and is accessible:**

```bash
if [ "$RUN_TDG" = "true" ]; then
  # Locate TDG template from plugin
  TDG_TEMPLATE="${CLAUDE_PLUGIN_ROOT}/templates/tdg-prompt.md"

  if [ ! -f "$TDG_TEMPLATE" ]; then
    echo "⚠️  Warning: TDG template not found"
    echo "   Expected: $TDG_TEMPLATE"
    echo "   Falling back to manual test writing"
    echo ""
    RUN_TDG=false
  else
    echo "✅ TDG template loaded: ${CLAUDE_PLUGIN_ROOT}/templates/tdg-prompt.md"
    echo ""
  fi
fi
```

---

### Step 4: TDG Phase Summary

**Display TDG configuration for user awareness:**

```bash
if [ "$RUN_TDG" = "true" ]; then
  echo "════════════════════════════════════════════════════════"
  echo "  PHASE 0c: TEST-DRIVEN GENERATION (TDG MODE)"
  echo "════════════════════════════════════════════════════════"
  echo ""
  echo "Strategy: AUGMENTATION (planned scenarios + ~50 AI-generated tests)"
  echo "Target: Comprehensive coverage in <5 minutes per step"
  echo "Integration: Generated tests augment plan, not replace"
  echo ""
  echo "TDG will run during Phase 1 for EACH step:"
  echo "  1. Load step specifications and planned test scenarios"
  echo "  2. Delegate to TDG sub-agent for test generation"
  echo "  3. Merge AI-generated tests with planned tests"
  echo "  4. Validate test suite (deduplication, syntax check)"
  echo "  5. Save augmented test suite: step-0N-tests-augmented.md"
  echo "  6. Proceed to RED phase with comprehensive test suite"
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo ""
fi
```

---

**Note:** The actual TDG sub-agent delegation happens in **Phase 1** (per-step execution), not in Phase 0. Phase 0c only validates configuration and prepares infrastructure.

**Integration Point:** When `RUN_TDG=true`, Phase 1 will include a TDG sub-step AFTER loading each step file and BEFORE the RED phase.

**Variables set in Phase 0c:**
- `RUN_TDG`: Boolean (`true` or `false`)
- `TDG_TEMPLATE`: Path to TDG prompt template (if TDG enabled)
- `TDG_CONFIG`: Configuration value from settings.json

**Phase 0c Complete** - Ready to proceed to Phase 1 with TDG infrastructure prepared.

---

### Phase 1: TDD Cycle for Each Step (REQUIRED)

```bash
# Notify TDD execution start
notify_discord "🚀 **TDD Execution Started**\nPlan: \`${PLAN_NAME}\`\nSteps: ${TOTAL_STEPS}" "summary"
```

**Execution Strategy Based on Plan Format**:

- **Directory Format**: Delegate each step to TDD sub-agent
- **Monolithic Format**: Execute directly (existing workflow)

**For EACH implementation step, choose execution path**:

---

## Phase 1a: Directory Format - Sub-Agent Delegation

**If using directory format, follow this process for each step**:

### Step 3a: Self-Assessment Checkpoint (Before Each Step)

**Purpose**: Intelligently assess whether main context can handle next step coordination without quality degradation.

**Context Needs Calculation** (Main Context Focus):

```bash
# Main context handles coordination, NOT implementation (sub-agents do that)
OVERVIEW_SIZE=3000  # Already loaded
COORDINATION_OVERHEAD=5000  # Step delegation, result processing
STEP_RESULT_PROCESSING=3000  # Parsing sub-agent outputs
CUMULATIVE_STATE=$((COMPLETED_STEPS * 1000))  # Tracking progress
TODOWRITE_UPDATES=1000  # Plan synchronization
SAFETY_BUFFER=10000  # Middle-ground conservativeness

ESTIMATED_NEED=$((OVERVIEW_SIZE + COORDINATION_OVERHEAD + STEP_RESULT_PROCESSING + CUMULATIVE_STATE + TODOWRITE_UPDATES + SAFETY_BUFFER))

# Dynamic context check (not static 80%)
CONTEXT_WINDOW=200000
# Note: Current usage determined by Claude state (cannot be directly queried in bash)
# MCP overhead varies (1K-5K typically)

echo ""
echo "📊 Self-Assessment for Step $CURRENT_STEP:"
echo "   Estimated main context needs: ${ESTIMATED_NEED} tokens"
echo "   (Coordination overhead only - sub-agents handle implementation)"
echo ""
```

**Decision Logic**:

```bash
# PM must assess current context state and decide
# This is a CHECKPOINT for explicit decision-making, not automatic

echo "⚠️  CHECKPOINT: Assess Main Context Capacity"
echo ""
echo "Current Step: $CURRENT_STEP of $TOTAL_STEPS"
echo "Estimated Need: ${ESTIMATED_NEED}K tokens (coordination only)"
echo ""
echo "Review current conversation length and MCP tool usage."
echo "Consider handoff if context feels constrained."
echo ""
echo "Options:"
echo "  1. PROCEED - Continue with this step (sufficient context)"
echo "  2. HANDOFF - Generate handoff.md and resume in fresh context"
echo ""

# PM makes explicit decision
# If HANDOFF chosen, proceed to handoff generation
```

**Logging** (After Decision):

```bash
# If PROCEED chosen
echo "✅ Self-Assessment Decision: PROCEED"
echo ""
echo "   Context Budget:"
echo "   - Estimated coordination needs: ${ESTIMATED_NEED}K"
echo "   - Safety buffer included: 10K"
echo "   - Main context focus: Coordination, not implementation"
echo ""
```

### Step 3b: Generate Handoff Checkpoint (When Needed)

**Purpose**: Create resume point with full context for continuation in fresh conversation.

**Handoff File Path Determination**:

```bash
# Function to generate handoff
generate_handoff() {
  local CURRENT_STEP=$1
  local COMPLETED_STEPS=$((CURRENT_STEP - 1))

  # Directory-only format
  HANDOFF_FILE="${PLAN_DIR}handoff.md"

  echo "📝 Generating handoff checkpoint: $HANDOFF_FILE"

  # Generate handoff content
  cat > "$HANDOFF_FILE" <<EOF
# TDD Handoff Checkpoint

**Feature**: ${PLAN_NAME}
**Plan Reference**: ${PLAN_REF}
**Current Step**: Step ${CURRENT_STEP} (next to execute)
**Completed Steps**: Steps 1-${COMPLETED_STEPS} ✅
**Handoff Reason**: Context capacity management

---

## Configuration

\`\`\`json
{
  "thinkingMode": "${THINKING_MODE}",
  "coverageTarget": ${COVERAGE_TARGET},
  "artifactLocation": "${ARTIFACT_LOC}"
}
\`\`\`

---

## Cumulative File Changes (Steps 1-${COMPLETED_STEPS})

<!-- TODO: Extract from completed step summaries -->
<!-- This will be populated by Step 2 (resume capability) -->

---

## Step Summaries (Steps 1-${COMPLETED_STEPS})

<!-- TODO: Extract from TodoWrite entries -->
<!-- This will be populated by Step 2 (resume capability) -->

---

## Next Step: Step ${CURRENT_STEP}

EOF

  # Append next step content
  NEXT_STEP_FILE="${PLAN_DIR}step-$(printf '%02d' $CURRENT_STEP).md"
  if [ -f "$NEXT_STEP_FILE" ]; then
    cat "$NEXT_STEP_FILE" >> "$HANDOFF_FILE"
  else
    echo "⚠️  Warning: Next step file not found: $NEXT_STEP_FILE" >> "$HANDOFF_FILE"
  fi

  # Add resume instructions
  cat >> "$HANDOFF_FILE" <<EOF

---

## Resume Instructions

**To continue TDD execution from this checkpoint**:

1. **Review this handoff file** to understand context
2. **Run TDD command**: \`/rptc:tdd "${PLAN_REF}"\`
3. **TDD will auto-detect** handoff and resume from Step ${CURRENT_STEP}

**Note**: The TDD command will load this handoff file automatically when it detects completion through Step ${COMPLETED_STEPS}.

---

## Context Analysis (Why Handoff Triggered)

**Main Context Focus**: Coordination overhead (step delegation, result processing, state tracking)

**Estimated Needs**:
- Overview content: ~3K tokens (already loaded)
- Coordination per step: ~5K tokens
- Result processing: ~3K tokens per step
- Cumulative state: ${CUMULATIVE_STATE} tokens
- Safety buffer: 10K tokens
- **Total Estimated**: ${ESTIMATED_NEED}K tokens

**Decision**: Handoff triggered to preserve execution quality and prevent context degradation.

**Benefits of Fresh Context**:
- Full context window available for remaining steps
- Clean slate for complex implementation work
- Maintained quality gates and verification rigor

---

_Generated by RPTC TDD v1.2.0 - Phase 3A Context Efficiency_
EOF

  echo "✅ Handoff checkpoint created: $HANDOFF_FILE"
  echo ""
  echo "📋 Next Steps:"
  echo "   1. Review handoff file for completeness"
  echo "   2. In fresh conversation, run: /rptc:tdd \"${PLAN_REF}\""
  echo "   3. TDD will resume from Step ${CURRENT_STEP}"
  echo ""

  # Exit TDD execution gracefully
  exit 0
}
```

**Handoff Trigger Integration**:

```bash
# In self-assessment checkpoint, if PM chooses HANDOFF:
if [ "$DECISION" = "HANDOFF" ]; then
  generate_handoff "$CURRENT_STEP"
fi
```

---

## Anthropic's 7-Step TDD Workflow

This command follows a rigorous 7-step Test-Driven Development workflow:

### Step 1: Understand the Requirement
- Load plan overview and current step details
- Review acceptance criteria and dependencies
- Confirm technical approach aligns with architecture

### Step 2: Design Test Scenarios (Pre-Validation Checkpoint)
- Review test scenarios from plan (Given-When-Then format)
- Validate scenarios cover: happy path, edge cases, error conditions
- **CHECKPOINT**: Ensure test design quality before proceeding to RED phase
- **Questions to validate**:
  - [ ] Are all acceptance criteria covered by test scenarios?
  - [ ] Do scenarios test boundaries and edge cases?
  - [ ] Are error conditions handled?
  - [ ] Is test data realistic and representative?

**Handoff to RED Phase**: If test scenarios are well-designed, proceed. If gaps found, update plan or refine scenarios before continuing.

### Step 3: Write Failing Test (RED Phase)
- Implement test scenarios as actual test code
- Run tests to confirm they fail for the right reasons
- Verify test output clearly indicates what's missing

**Example**:
```javascript
// Test for user authentication feature
describe('UserAuth', () => {
  it('should reject invalid credentials', () => {
    // Given: Invalid credentials
    const credentials = { username: 'user', password: 'wrong' };

    // When: Attempting login
    const result = auth.login(credentials);

    // Then: Returns error
    expect(result.success).toBe(false);
    expect(result.error).toBe('Invalid credentials');
  });
});
```

**Expected Output**: Test fails because `auth.login()` not yet implemented.

### Step 4: Minimal Implementation (GREEN Phase)
- Write simplest code to make tests pass
- Focus on correctness, not optimization
- Run tests to confirm GREEN state

### Step 5: Refactor for Quality
- Improve code structure while keeping tests green
- Extract common logic, improve naming
- Ensure KISS and YAGNI principles
- Re-run tests after each refactor

### Step 6: Verify No Regressions
- Run full test suite (not just current step)
- Check test coverage meets targets
- Verify no existing tests broken

### Step 7: Document and Commit
- Update plan with completion status
- Document deviations or learnings
- Prepare for next step or quality gates

**Integration with Self-Assessment**: Step 1's self-assessment checkpoint determines if directory format is beneficial. Steps 2-7 execute the TDD cycle with context-appropriate loading strategy.

---

## Workflow Integration Points

The following diagram shows how checkpoints integrate with the TDD workflow:

```
Self-Assessment (Step 3a)
         ↓
   [Assess Context Needs]
         ↓
    ┌─────────────┐
    │ Continue?   │ → YES → Continue with current context
    └─────────────┘
         ↓ NO
  [Handoff beneficial]
         ↓
  Generate handoff.md (Step 3b)
         ↓
  Resume in fresh context
         ↓
Load Step File (Step N)
         ↓
Test Scenario Pre-Validation (Step 1b)
         ↓
   [Validate Scenarios]
         ↓
    ┌──────────────┐
    │ Gaps found?  │ → YES → Report to PM, refine scenarios
    └──────────────┘
         ↓ NO
  Proceed to RED phase (Step 3)
         ↓
   [7-step TDD cycle]
         ↓
  RED → GREEN → REFACTOR → VERIFY → DOCUMENT
```

**See Also**:
- Self-assessment checkpoint (Step 3a) - Context loading decision
- Test scenario pre-validation (Step 1b) - Quality gate before RED phase
- Handoff generation (Step 3b) - Documentation for next session

---

## Important Notes

> **⚠️ IMPORTANT**: Test scenario pre-validation (Step 1b) is a BLOCKING checkpoint. If scenarios are incomplete or poorly designed, STOP and request plan updates before proceeding to RED phase. Poor test scenarios lead to rework and wasted implementation time.

> **💡 TIP**: Well-designed test scenarios (Step 2 of 7-step workflow) save significant refactoring time later. Invest 5-10 minutes validating scenarios to save hours of rework. The test scenario pre-validation checkpoint (Step 1b) enforces this quality gate.

> **🔄 WORKFLOW NOTE**: Steps 3-6 of the 7-step workflow (RED → GREEN → REFACTOR → VERIFY) may iterate multiple times per acceptance criterion. This is normal and expected in TDD. Each iteration strengthens code quality and test coverage.

---

### For Each Step (1 through N):

**Before starting Phase 1 loop, log execution strategy:**

```bash
echo ""
echo "════════════════════════════════════════════════════════"
echo "  PHASE 1: TDD IMPLEMENTATION (Step-by-Step Execution)"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Execution Strategy: Sub-agent delegation per step"
echo "Dependency Validation: Sequential (conservative approach)"
echo "Total Steps: $TOTAL_STEPS"
echo ""

# Validate step sequence once before starting
validate_step_sequence "$PLAN_DIR" "$TOTAL_STEPS"
```

**Note**: This logging provides visibility into the TDD execution approach and validates plan integrity before proceeding.

#### Step N: Validate Execution Order (NEW - Roadmap #14)

**Purpose**: Conservative dependency validation to prevent execution order violations.

**Approach**: For Step 1, this implements fail-safe sequential execution. Future enhancements will add explicit dependency parsing.

**Validation Logic**:

1. **Check step file exists**:
   ```bash
   STEP_FILE="${PLAN_DIR}step-$(printf '%02d' $STEP_NUM).md"
   if [ ! -f "$STEP_FILE" ]; then
     echo "❌ Error: Step $STEP_NUM file not found"
     echo "   Expected: $STEP_FILE"
     echo "   Available steps: $(find "$PLAN_DIR" -name "step-*.md" | wc -l)"
     echo ""
     echo "   Possible causes:"
     echo "   - Plan was modified after generation"
     echo "   - Step file was deleted"
     echo "   - Step numbering gap exists"
     echo ""
     echo "   Fix: Run /rptc:helper-update-plan to regenerate plan"
     exit 1
   fi
   ```

2. **Fail-safe default** (for Step 1 implementation):
   ```bash
   # Conservative approach: Execute steps sequentially
   # Future enhancement: Parse "Dependencies from Other Steps" section
   echo "📋 Step $STEP_NUM: Sequential execution (dependency validation: basic)"
   ```

**Note**: This conservative approach ensures safe execution. Future enhancements will add intelligent dependency graph parsing for optimized execution order.

#### Step N: Load Step File

**Update TodoWrite**: Mark "Step N: RED - Write failing tests" as in_progress

1. **Load step file**: `$ARTIFACT_LOC/plans/[plan-name]/step-0N.md`
   - If missing: Error with message: "Step N file not found: step-0N.md"
   - Suggestion: "Run `/rptc:helper-update-plan` to regenerate"

2. **Extract step details**:
   - Step name/title
   - Purpose and requirements
   - Test scenarios
   - Expected outcome
   - Acceptance criteria

3. **Prepare sub-agent context**:
   - Overall feature context (from overview.md)
   - Current step details (from step-0N.md)
   - Cumulative file changes (from Steps 1 through N-1)
   - Configuration values (ARTIFACT_LOC, THINKING_MODE, MAX_ATTEMPTS)

#### Step 1b: Test Scenario Pre-Validation

**Purpose**: Validate test scenario quality before implementing tests (Roadmap #7).

Review test scenarios from current step plan:

**Validation Checklist**:
- [ ] **Coverage**: All acceptance criteria have corresponding test scenarios
- [ ] **Happy Path**: Normal usage flows tested
- [ ] **Edge Cases**: Boundaries, empty inputs, unusual conditions covered
- [ ] **Error Handling**: Invalid inputs, failures, exceptions tested
- [ ] **Test Data**: Realistic and representative inputs
- [ ] **Clarity**: Given-When-Then format clear and unambiguous

**Decision Point**:
- ✅ **All checks pass**: Proceed to RED phase (delegate to TDD sub-agent)
- ⚠️ **Gaps identified**: Document gaps, suggest plan updates, await PM approval

**If gaps identified**:

```text
⚠️  Test Scenario Quality Issues Detected - Step $STEP_NUM

Validation results:
- [Issue 1: Description]
- [Issue 2: Description]

Recommendations:
- [Recommendation 1]
- [Recommendation 2]

Options:
1. Update test scenarios in step file and retry
2. Proceed with current scenarios (PM override)
3. Skip to next step (not recommended)

Waiting for PM decision...
```

**If scenarios validated successfully**:

```text
✅ Test Scenario Pre-Validation Complete - Step $STEP_NUM

All validation checks passed:
- Coverage: ✅ All acceptance criteria covered
- Happy Path: ✅ Normal flows included
- Edge Cases: ✅ Boundaries tested
- Error Handling: ✅ Failure scenarios covered
- Test Data: ✅ Realistic inputs defined
- Clarity: ✅ Given-When-Then format clear

Proceeding to delegate step to TDD sub-agent for RED → GREEN → REFACTOR execution...
```

---

## Phase 4b: Dynamic Context Prediction (Roadmap #22)

**Purpose:** Predict if next step can safely execute within 80% capacity using hybrid estimation.

**Timing:** BEFORE delegating to sub-agent (prevents mid-step handoff)

---

### PREDICTION Step 1: File-Based Estimation

**Method 1: Estimate from step file size:**

```bash
# Load next step file for analysis
STEP_FILE="${PLAN_DIR}step-$(printf '%02d' $STEP_NUM).md"

FILE_ESTIMATE=$(calculate_file_estimate "$STEP_FILE")
```

### PREDICTION Step 2: Historical Average Estimation

**Method 2: Average of last 3 completed steps:**

```bash
# Check if we have enough history (3+ completed steps)
COMPLETED_STEPS=$((STEP_NUM - 1))

HISTORICAL_AVG=$(calculate_historical_average "$COMPLETED_STEPS")

if [ "$COMPLETED_STEPS" -lt 3 ]; then
  echo "🌱 Historical Average: COLD START (${COMPLETED_STEPS}/3 steps completed)"
  echo "   Using conservative floor: ${HISTORICAL_AVG} tokens"
  USING_COLD_START=true
else
  LAST_3_STEPS=("${STEP_CONTEXT_USAGE[@]: -3}")
  echo "📊 Historical Average (last 3 steps):"
  echo "   Step $((COMPLETED_STEPS - 2)): ${LAST_3_STEPS[0]} tokens"
  echo "   Step $((COMPLETED_STEPS - 1)): ${LAST_3_STEPS[1]} tokens"
  echo "   Step $((COMPLETED_STEPS)):     ${LAST_3_STEPS[2]} tokens"
  echo "   Average: ${HISTORICAL_AVG} tokens"
  USING_COLD_START=false
fi
echo ""
```

### PREDICTION Step 3: Growth Rate Estimation

**Method 3: Extrapolate from recent trend:**

```bash
GROWTH_ESTIMATE=$(calculate_growth_estimate "$COMPLETED_STEPS")

if [ "$GROWTH_ESTIMATE" = "0" ]; then
  echo "📈 Growth Rate: INSUFFICIENT DATA (need 2+ steps)"
  echo "   Skipping growth estimate"
  HAS_GROWTH_ESTIMATE=false
else
  # Calculate average growth for display
  declare -a GROWTH_DELTAS=()
  for ((i=1; i<${#STEP_CONTEXT_USAGE[@]}; i++)); do
    PREV=${STEP_CONTEXT_USAGE[$((i-1))]}
    CURR=${STEP_CONTEXT_USAGE[$i]}
    DELTA=$((CURR - PREV))
    GROWTH_DELTAS+=("$DELTA")
  done

  GROWTH_SUM=0
  for delta in "${GROWTH_DELTAS[@]}"; do
    GROWTH_SUM=$((GROWTH_SUM + delta))
  done
  AVG_GROWTH=$((GROWTH_SUM / ${#GROWTH_DELTAS[@]}))

  LAST_STEP_USAGE=${STEP_CONTEXT_USAGE[-1]}

  echo "📈 Growth Rate Estimate:"
  echo "   Average Growth: ${AVG_GROWTH} tokens/step"
  echo "   Last Step Usage: ${LAST_STEP_USAGE} tokens"
  echo "   Projected Next: ${GROWTH_ESTIMATE} tokens"
  HAS_GROWTH_ESTIMATE=true
fi
echo ""
```

### PREDICTION Step 4: Hybrid Maximum (Most Conservative)

**Take maximum of all three methods:**

```bash
echo "🔀 Hybrid Prediction (take most conservative):"
echo ""

# Collect all estimates
declare -a ALL_ESTIMATES=()
ALL_ESTIMATES+=("$FILE_ESTIMATE")
ALL_ESTIMATES+=("$HISTORICAL_AVG")
if [ "$HAS_GROWTH_ESTIMATE" = true ]; then
  ALL_ESTIMATES+=("$GROWTH_ESTIMATE")
fi

# Find maximum (most conservative)
MAX_ESTIMATE=0
for estimate in "${ALL_ESTIMATES[@]}"; do
  if [ "$estimate" -gt "$MAX_ESTIMATE" ]; then
    MAX_ESTIMATE=$estimate
  fi
done

echo "   File-Based:     ${FILE_ESTIMATE} tokens"
echo "   Historical Avg: ${HISTORICAL_AVG} tokens"
if [ "$HAS_GROWTH_ESTIMATE" = true ]; then
  echo "   Growth Rate:    ${GROWTH_ESTIMATE} tokens"
fi
echo "   ─────────────────────────────────────────"
echo "   Maximum (used): ${MAX_ESTIMATE} tokens"
echo ""
```

### PREDICTION Step 5: Add Overhead Components

**Add known per-step overhead:**

```bash
echo "➕ Adding Overhead Components:"
echo ""
echo "   Base Estimate:   ${MAX_ESTIMATE} tokens"
echo "   + Delegation:    ${DELEGATION_OVERHEAD} tokens"
echo "   + System:        ${SYSTEM_OVERHEAD} tokens"
echo "   ─────────────────────────────────────────"

ESTIMATE_WITH_OVERHEAD=$((MAX_ESTIMATE + BASE_OVERHEAD))

echo "   Subtotal:        ${ESTIMATE_WITH_OVERHEAD} tokens"
echo ""
```

### PREDICTION Step 6: Apply Safety Factors

**Apply 1.5× multiplier + 3% margin:**

```bash
echo "🛡️  Applying Safety Factors:"
echo ""

# Step 6a: Safety multiplier (1.5×)
AFTER_MULTIPLIER=$(awk "BEGIN {printf \"%.0f\", $ESTIMATE_WITH_OVERHEAD * $SAFETY_MULTIPLIER}")

echo "   Before Safety:    ${ESTIMATE_WITH_OVERHEAD} tokens"
echo "   × Safety (1.5×):  ${AFTER_MULTIPLIER} tokens"

# Step 6b: Safety margin (3%)
SAFETY_MARGIN_TOKENS=$(awk "BEGIN {printf \"%.0f\", $AFTER_MULTIPLIER * $SAFETY_MARGIN_PCT}")
FINAL_PREDICTION=$((AFTER_MULTIPLIER + SAFETY_MARGIN_TOKENS))

echo "   + Margin (3%):    +${SAFETY_MARGIN_TOKENS} tokens"
echo "   ─────────────────────────────────────────"
echo "   Final Prediction: ${FINAL_PREDICTION} tokens"
echo ""

# Step 6c: Apply calibration adjustment
if [ "$USING_COLD_START" = false ]; then
  CALIBRATED_PREDICTION=$(awk "BEGIN {printf \"%.0f\", $FINAL_PREDICTION * $CALIBRATION_MULTIPLIER}")
  if [ "$CALIBRATION_MULTIPLIER" != "1.0" ]; then
    echo "   × Calibration:    ${CALIBRATION_MULTIPLIER}× → ${CALIBRATED_PREDICTION} tokens"
    FINAL_PREDICTION=$CALIBRATED_PREDICTION
  fi
fi
echo ""
```

### PREDICTION Step 7: Decision Logic (80% Hard Cap Check)

**Determine if safe to proceed:**

```bash
echo "🎯 Handoff Decision:"
echo ""
echo "   Current Context:  ${CURRENT_CONTEXT} tokens"
echo "   + Predicted Step: ${FINAL_PREDICTION} tokens"
echo "   ─────────────────────────────────────────"

PROJECTED_TOTAL=$((CURRENT_CONTEXT + FINAL_PREDICTION))

echo "   Projected Total:  ${PROJECTED_TOTAL} tokens"
echo "   Hard Cap (80%):   ${HARD_CAP_TOKENS} tokens"
echo "   Remaining Budget: $((HARD_CAP_TOKENS - PROJECTED_TOTAL)) tokens"
echo ""

# Check if would exceed hard cap
if [ "$PROJECTED_TOTAL" -ge "$HARD_CAP_TOKENS" ]; then
  echo "⛔ HANDOFF TRIGGERED: Would exceed 80% capacity"
  echo ""
  echo "   Reason: Next step would push context to ${PROJECTED_TOTAL} tokens"
  echo "           (exceeds ${HARD_CAP_TOKENS} hard cap)"
  echo ""

  # Generate handoff checkpoint
  generate_handoff_checkpoint "$((STEP_NUM - 1))" "$PROJECTED_TOTAL" "capacity_exceeded"

  # Exit with resume instructions
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  CHECKPOINT CREATED - RESUME IN FRESH CONTEXT"
  echo "════════════════════════════════════════════════════════"
  echo ""
  echo "✅ Completed: Steps 1-$((STEP_NUM - 1)) ($(((STEP_NUM - 1) * 100 / TOTAL_STEPS))% of plan)"
  echo "📝 Checkpoint: ${PLAN_DIR}handoff.md"
  echo ""
  echo "📍 Resume with:"
  echo "   /rptc:helper-resume-plan \"@${PLAN_NAME}/\""
  echo ""
  exit 0
else
  echo "✅ SAFE TO PROCEED: Within capacity budget"
  echo ""
  echo "   Headroom: $((HARD_CAP_TOKENS - PROJECTED_TOTAL)) tokens ($((100 * (HARD_CAP_TOKENS - PROJECTED_TOTAL) / HARD_CAP_TOKENS))%)"
  echo ""
fi
```

### PREDICTION Step 8: Log Prediction Details

**Append to prediction log:**

```bash
# Log row: Step | File Est | Hist | Growth | Max | Overhead | Safety | Final | Current | Decision | [Actual filled in Phase 5]
echo -n "${STEP_NUM} | ${FILE_ESTIMATE} | ${HISTORICAL_AVG} | " >> "$PREDICTION_LOG"
if [ "$HAS_GROWTH_ESTIMATE" = true ]; then
  echo -n "${GROWTH_ESTIMATE} | " >> "$PREDICTION_LOG"
else
  echo -n "N/A | " >> "$PREDICTION_LOG"
fi
echo -n "${MAX_ESTIMATE} | ${BASE_OVERHEAD} | " >> "$PREDICTION_LOG"
echo -n "×${SAFETY_MULTIPLIER}+${SAFETY_MARGIN_PCT}% | ${FINAL_PREDICTION} | " >> "$PREDICTION_LOG"
echo -n "${CURRENT_CONTEXT} | PROCEED | " >> "$PREDICTION_LOG"
echo "[measuring...]" >> "$PREDICTION_LOG"

echo "📝 Logged to: ${PREDICTION_LOG}"
echo ""
```

---

#### Step N: Delegate to TDD Sub-Agent

**Create TDD Sub-Agent** with this prompt:

```text
Use $THINKING_MODE thinking mode for this TDD implementation step.

You are a TDD EXECUTION SUB-AGENT for a single implementation step.

Your mission: Execute RED → GREEN → REFACTOR cycle for Step $STEP_NUM ONLY.

## Overall Feature Context (from overview)

[Pass entire OVERVIEW content from overview.md]

## Your Step (Step $STEP_NUM)

[Pass entire STEP_CONTENT from step-0N.md]

## Cumulative File Changes (from prior steps)

Files modified/created in Steps 1 through $STEP_NUM-1:
[Pass list of files with brief description of changes]

If this is Step 1: "No prior changes (first step)"

## Implementation Constraints

${CONSTRAINTS}

**CRITICAL**: These constraints MUST be respected during implementation.
- If constraints conflict with your intended approach, STOP and request clarification from main TDD executor
- Constraints ensure code quality, maintainability, and adherence to project standards
- Violating constraints may result in implementation rejection during refactoring phase
- If constraints are unclear or contradictory, document concern and request PM guidance before proceeding

**Graceful Handling**: If constraints section shows "No specific constraints defined," apply standard best practices:
- KISS (Keep It Simple) principle
- YAGNI (You Aren't Gonna Need It)
- DRY (Don't Repeat Yourself) after 3rd occurrence
- File size < 500 lines when practical
- Function size < 50 lines when practical

## Execute TDD Cycle

**CRITICAL**: Follow TDD methodology strictly.

### 1. RED Phase: Write ALL Tests First

**BEFORE any implementation code**:

1. Review test scenarios from step file
2. Write ALL tests for this step:
   - Happy path tests
   - Edge case tests
   - Error condition tests
   - Follow project's test conventions
3. Verify tests FAIL for right reasons
4. Show failure output

**Report RED State**:
```text
🔴 RED Phase Complete - Step $STEP_NUM

Tests written: [X] tests
- ❌ [test 1 name]
- ❌ [test 2 name]
- ❌ [test 3 name]

All tests failing as expected (no implementation yet).
```

### 2. GREEN Phase: Minimal Implementation to Pass Tests

Write ONLY enough code to pass current tests.

1. **Implement minimal solution**:
   - Focus on correctness, not elegance
   - No premature optimization
   - Just make tests pass

2. **Auto-iterate if tests fail** (max $MAX_ATTEMPTS attempts):
   - Each iteration:
     - Analyze specific failure
     - Make targeted fix
     - Re-run tests
     - Report progress

**Report Each Iteration**:
```text
Iteration [N]: [What was fixed]
Tests: [X] passing, [Y] failing
```

**If still failing after $MAX_ATTEMPTS iterations**:
```text
❌ Auto-iteration limit reached ($MAX_ATTEMPTS attempts)

Persistent failure: [test name]
Error: [error message]

Requesting guidance from main TDD executor...
```

**Report GREEN State**:
```text
🟢 GREEN Phase Complete - Step $STEP_NUM

✅ All tests passing ([X] tests)
```

### 3. REFACTOR Phase: Improve Code Quality

Now that tests are green, improve the code.

1. **Code improvements**:
   - Remove duplication
   - Improve naming
   - Extract functions
   - Add clarifying comments
   - Simplify complex logic

2. **Run tests after EACH refactor**:
   - Ensure tests still pass
   - If tests fail, fix and continue

**Report REFACTOR Complete**:
```text
🔧 REFACTOR Phase Complete - Step $STEP_NUM

Improvements made:
- [Improvement 1]
- [Improvement 2]

✅ All tests still passing
✅ Code quality improved
```

## Return Summary

Provide this summary when returning control to main TDD executor:

**Step $STEP_NUM Completion Report**:
- Tests written: [X] tests
- Tests passing: [X] tests (MUST be 100%)
- Files modified: [list with brief descriptions]
- Files created: [list with brief descriptions]
- Coverage for this step: [Y]%
- Refactorings applied: [list]
- Blockers or notes: [any issues or important notes]

**CRITICAL**: All tests MUST pass before returning. If blocked after $MAX_ATTEMPTS iterations, explain blocker and request guidance.
```

#### Step N: Process Sub-Agent Results

1. **Verify completion**:
   - All tests passing? (CRITICAL)
   - Step requirements met?
   - Acceptance criteria satisfied?

2. **Update cumulative file list**:
   - Add files modified in this step
   - Add files created in this step
   - Track for next step's context

3. **Mark step complete**:
   - Update TodoWrite: "Step N: RED" → completed
   - Update TodoWrite: "Step N: GREEN" → completed
   - Update TodoWrite: "Step N: REFACTOR" → completed

4. **Sync plan**:
   - Update TodoWrite: Mark "Step N: SYNC - Update plan" as in_progress
   - Mark step complete in step-0N.md file (if using checklist format)
   - Update overview.md progress section (if exists)
   - Update TodoWrite: Mark "Step N: SYNC - Update plan" as completed

5. **Report step completion**:

```text
✅ Step $STEP_NUM Complete: [Step Name]

Tests: [X] passing
Files modified: [list]
Files created: [list]
Coverage: [Y]% (for this step)

📝 Plan synchronized: Step $STEP_NUM marked complete
```

```bash
# Notify step completion
notify_discord "✅ **Step ${STEP_NUM} Complete**\n\`${STEP_NAME}\`" "detailed"
```

```text
📊 Context Status After Step $STEP_NUM:
   Coordination overhead used: ~8K tokens (delegation + result processing)
   Cumulative state tracking: $((STEP_NUM * 1000)) tokens
   Main context preserved for: $((TOTAL_STEPS - STEP_NUM)) remaining steps

[If more steps remaining:]
Next: Step [N+1] - [Next step name]

[If all steps complete:]
All implementation steps complete! Proceeding to quality gates...
```

---

## Phase 5: Context Usage Tracking (Roadmap #22 - Post-Step Analysis)

**Purpose:** Measure actual context usage, calculate prediction accuracy, adjust calibration.

**Timing:** AFTER step completes (tests pass, plan synced)

---

### TRACKING Step 1: Estimate Current Context Usage

**Heuristic approach (no direct API access):**

```bash
echo ""
echo "════════════════════════════════════════════════════════"
echo "  PHASE 5: CONTEXT TRACKING"
echo "════════════════════════════════════════════════════════"
echo ""
echo "📏 Measuring actual context usage..."
echo ""

# Method: Estimate based on files changed + summary size
# This is heuristic (±15% accuracy) but sufficient for calibration

# Get files modified in this step
MODIFIED_FILES=$(git diff --name-only HEAD~1 2>/dev/null | wc -l)
MODIFIED_LINES=$(git diff --stat HEAD~1 2>/dev/null | tail -1 | awk '{print $4}')

# Estimate summary size (cumulative summaries grow ~2-3K per step)
SUMMARY_SIZE=2500  # Conservative average

# Estimate actual step impact
# Formula: (modified lines × 2) + summary + overhead (already counted)
if [ -n "$MODIFIED_LINES" ] && [ "$MODIFIED_LINES" != "0" ]; then
  IMPLEMENTATION_TOKENS=$((MODIFIED_LINES * 2))
else
  IMPLEMENTATION_TOKENS=5000  # Fallback if git diff unavailable
fi

ACTUAL_STEP_DELTA=$((IMPLEMENTATION_TOKENS + SUMMARY_SIZE + BASE_OVERHEAD))

# Update current context tracker
PREVIOUS_CONTEXT=$CURRENT_CONTEXT
CURRENT_CONTEXT=$((CURRENT_CONTEXT + ACTUAL_STEP_DELTA))

echo "   Modified Files: ${MODIFIED_FILES}"
echo "   Modified Lines: ${MODIFIED_LINES}"
echo "   Estimated Implementation: ${IMPLEMENTATION_TOKENS} tokens"
echo "   Cumulative Summary: ${SUMMARY_SIZE} tokens"
echo "   Overhead: ${BASE_OVERHEAD} tokens"
echo "   ─────────────────────────────────────────"
echo "   Step Delta: ${ACTUAL_STEP_DELTA} tokens"
echo ""
echo "   Context Before: ${PREVIOUS_CONTEXT} tokens"
echo "   Context After:  ${CURRENT_CONTEXT} tokens"
echo ""
```

### TRACKING Step 2: Store in Historical Array

**Add to STEP_CONTEXT_USAGE for future predictions:**

```bash
# Append actual usage to history
STEP_CONTEXT_USAGE+=("$ACTUAL_STEP_DELTA")

echo "📊 Historical Data Updated:"
echo "   Total Steps Tracked: ${#STEP_CONTEXT_USAGE[@]}"
echo "   Recent Usage:"
if [ "${#STEP_CONTEXT_USAGE[@]}" -ge 3 ]; then
  echo "     Step $((${#STEP_CONTEXT_USAGE[@]} - 2)): ${STEP_CONTEXT_USAGE[-3]} tokens"
  echo "     Step $((${#STEP_CONTEXT_USAGE[@]} - 1)): ${STEP_CONTEXT_USAGE[-2]} tokens"
  echo "     Step ${#STEP_CONTEXT_USAGE[@]}:         ${STEP_CONTEXT_USAGE[-1]} tokens"
else
  for ((i=0; i<${#STEP_CONTEXT_USAGE[@]}; i++)); do
    echo "     Step $((i + 1)): ${STEP_CONTEXT_USAGE[$i]} tokens"
  done
fi
echo ""
```

### TRACKING Step 3: Calculate Prediction Error

**Compare predicted vs actual:**

```bash
echo "🎯 Prediction Accuracy:"
echo ""

# Retrieve predicted value from Phase 4b
echo "   Predicted: ${FINAL_PREDICTION} tokens"
echo "   Actual:    ${ACTUAL_STEP_DELTA} tokens"

# Calculate error percentage
PREDICTION_ERROR=$(awk "BEGIN {printf \"%.1f\", abs($ACTUAL_STEP_DELTA - $FINAL_PREDICTION) / $FINAL_PREDICTION * 100}")

echo "   Error:     ${PREDICTION_ERROR}%"
echo ""

# Store error for calibration analysis
PREDICTION_ERRORS+=("$PREDICTION_ERROR")
```

### TRACKING Step 4: Calibration Adjustment

**Adjust multiplier if errors consistently high:**

```bash
# Only calibrate after 3+ steps (enough data)
if [ "${#PREDICTION_ERRORS[@]}" -ge 3 ]; then
  # Calculate average error over last 3 steps
  LAST_3_ERRORS=("${PREDICTION_ERRORS[@]: -3}")
  ERROR_SUM=0
  for error in "${LAST_3_ERRORS[@]}"; do
    ERROR_SUM=$(awk "BEGIN {printf \"%.1f\", $ERROR_SUM + $error}")
  done
  AVG_ERROR=$(awk "BEGIN {printf \"%.1f\", $ERROR_SUM / 3}")

  echo "📐 Calibration Analysis:"
  echo "   Average Error (last 3): ${AVG_ERROR}%"
  echo "   Target: <15% (acceptable), <10% (excellent)"
  echo ""

  # Adjust calibration multiplier if error >15%
  if (( $(awk "BEGIN {print ($AVG_ERROR > 15)}") )); then
    # Check if consistently over or under predicting
    OVER_PREDICT=0
    UNDER_PREDICT=0

    for ((i=${#STEP_CONTEXT_USAGE[@]}-3; i<${#STEP_CONTEXT_USAGE[@]}; i++)); do
      # Compare actual vs final prediction (need to recalculate for each)
      STEP_ACTUAL=${STEP_CONTEXT_USAGE[$i]}
      # This is simplified - in production would need to track predictions
      if [ "$STEP_ACTUAL" -gt "$FINAL_PREDICTION" ]; then
        UNDER_PREDICT=$((UNDER_PREDICT + 1))
      else
        OVER_PREDICT=$((OVER_PREDICT + 1))
      fi
    done

    if [ "$UNDER_PREDICT" -ge 2 ]; then
      # Consistently under-predicting: Increase multiplier by 10%
      OLD_CALIBRATION=$CALIBRATION_MULTIPLIER
      CALIBRATION_MULTIPLIER=$(awk "BEGIN {printf \"%.2f\", $CALIBRATION_MULTIPLIER * 1.1}")
      echo "   ⚠️  Consistently UNDER-predicting (${UNDER_PREDICT}/3 steps)"
      echo "   Adjusting calibration: ${OLD_CALIBRATION}× → ${CALIBRATION_MULTIPLIER}×"
      echo "   (Increases future predictions by 10%)"
    elif [ "$OVER_PREDICT" -ge 2 ]; then
      # Consistently over-predicting: Decrease multiplier by 5%
      OLD_CALIBRATION=$CALIBRATION_MULTIPLIER
      CALIBRATION_MULTIPLIER=$(awk "BEGIN {printf \"%.2f\", $CALIBRATION_MULTIPLIER * 0.95}")
      echo "   ℹ️  Consistently OVER-predicting (${OVER_PREDICT}/3 steps)"
      echo "   Adjusting calibration: ${OLD_CALIBRATION}× → ${CALIBRATION_MULTIPLIER}×"
      echo "   (Decreases future predictions by 5%)"
    else
      echo "   ⚠️  High error but inconsistent direction - no adjustment"
    fi
    echo ""
  else
    echo "   ✅ Error within acceptable range (no adjustment needed)"
    echo ""
  fi
else
  echo "📐 Calibration: Insufficient data (${#PREDICTION_ERRORS[@]}/3 steps)"
  echo "   Need 3+ steps for calibration analysis"
  echo ""
fi
```

### TRACKING Step 5: Update Prediction Log

**Fill in actual value and error:**

```bash
# Update last line of prediction log with actual data
sed -i "$ s/\[measuring...\]/${ACTUAL_STEP_DELTA} | ${PREDICTION_ERROR}%/" "$PREDICTION_LOG"

echo "📝 Prediction log updated: ${PREDICTION_LOG}"
echo ""
```

---

**Repeat for all N steps**, then proceed to Phase 2 (Quality Gates).

---

### Phase 2: Master Efficiency Agent Review (WITH PERMISSION)

**CRITICAL - NON-NEGOTIABLE QUALITY GATE**

**TodoWrite Check**: All implementation steps must be completed before requesting Efficiency Agent

**CRITICAL**: After ALL tests passing, request efficiency review.

**Step 1: Use Configured Thinking Mode**:

Thinking mode already loaded in Step 0a configuration: `$THINKING_MODE`

**Step 2: Ask PM for Permission**:

**Update TodoWrite**: Mark "REQUEST PM: Efficiency Agent approval" as in_progress

**FORMATTING NOTE:** Each list item must be on its own line with proper newlines.

```text
✅ Implementation Complete - All Tests Passing!

All [N] steps implemented successfully.
- Total tests: [X] passing
- Overall coverage: [Y]%
- Files changed: [Z]

**Ready for Master Efficiency Agent review?**

The Master Efficiency Agent will:
- Remove unused imports/variables/code
- Simplify overly complex logic
- Improve code readability
- Identify over-engineering
- Ensure KISS and YAGNI principles

💡 Thinking Mode:
[If global default exists: Will use configured mode: "[mode]" (~[X]K tokens)]
[If no global default: Will use default mode: "think" (~4K tokens)]

Ready to delegate to Master Efficiency Agent?
- Type "yes" or "approved" to proceed with configured mode
- To override thinking mode, say: "yes, use ultrathink" (or "think hard")

Available modes: "think" (~4K), "think hard" (~10K), "ultrathink" (~32K)
Configure default in .claude/settings.json: "rptc.defaultThinkingMode"

**IMPORTANT**: Efficiency review is a NON-NEGOTIABLE quality gate.

Waiting for your sign-off...
```

**DO NOT create sub-agent** until PM approves.

**After PM approval**:
- Mark "REQUEST PM: Efficiency Agent approval" as completed
- Mark "EXECUTE: Efficiency Agent review" as in_progress

#### Efficiency Agent Delegation (If Approved)

**Step 1: Determine Final Thinking Mode**:
   - If user specified a mode override (e.g., "yes, use ultrathink"): Use user's choice
   - Else if global default exists in .claude/settings.json: Use that mode
   - Else: Use default "think" mode

**Step 2: Create Sub-Agent**:

```bash
# Notify Efficiency Agent start
notify_discord "🔍 **Quality Gate: Efficiency Review**\nAnalyzing code quality..." "detailed"
```

**Sub-Agent Prompt**:

```text
Use [determined thinking mode] thinking mode for this efficiency review.

You are a MASTER EFFICIENCY AGENT - a world-class expert in code optimization and simplicity.

Your mission: Improve code efficiency, readability, and simplicity WITHOUT changing functionality.

Context:
- Work item: [work item name]
- Files: [list of modified files]
- Tests: [X] tests passing (DO NOT break these)

**Reference for Standards** (use fallback chain):
Load via fallback (project → user → plugin):
1. .rptc/sop/languages-and-style.md
2. ~/.claude/global/sop/languages-and-style.md
3. ${CLAUDE_PLUGIN_ROOT}/sop/languages-and-style.md

Same for architecture-patterns.md

Apply KISS and YAGNI principles from SOPs.

Review and improve:

## 1. Dead Code Removal
- Unused imports
- Unused variables/functions
- Commented-out code
- Unreachable code

## 2. Simplification
- Over-engineered solutions
- Unnecessary abstractions
- Complex logic that can be simplified
- Redundant code

## 3. Readability
- Unclear variable/function names
- Missing or unclear comments
- Inconsistent formatting
- Hard-to-follow logic flow

## 4. KISS & YAGNI Violations
- Features not in requirements
- Premature optimizations
- Unnecessary future-proofing
- Over-generalization

For EACH improvement:
- Make the change
- Run tests to verify nothing breaks
- Document what was improved

Return summary:
- Changes made (categorized)
- Tests status (must all pass)
- Code quality improvement metrics

CRITICAL: All tests must remain passing. If any test fails, revert that change.
```

**Present Efficiency Results**:

**FORMATTING NOTE:** Ensure each list item is on its own line with proper newlines between items.

```text
🎯 Master Efficiency Agent Complete!

Improvements made:
- Removed [X] unused imports
- Simplified [Y] complex functions
- Improved [Z] variable names
- Removed [W] lines of dead code

Code quality metrics:
- Readability: ⬆️ Improved
- Complexity: ⬇️ Reduced
- Maintainability: ⬆️ Improved

✅ All tests still passing ([X] tests)

Proceeding to security review...
```

**Update TodoWrite**: Mark "EXECUTE: Efficiency Agent review" as completed

---

**CRITICAL VALIDATION CHECKPOINT - NON-NEGOTIABLE QUALITY GATE**

Before executing Master Security Agent:

**TodoWrite Check**: "REQUEST PM: Security Agent approval" MUST be completed

**Verification**:
1. Efficiency review MUST be completed
2. PM approval MUST be obtained for Security review

❌ **QUALITY GATE BLOCKED** - Cannot proceed to Security review without PM approval

**Required**: PM must explicitly approve security review

**ENFORCEMENT**: If PM has NOT approved:
1. Verify Efficiency review complete
2. Present implementation summary
3. Ask: "Ready for Master Security Agent review?"
4. Explain: "MUST get PM approval - CANNOT PROCEED without security review"
5. Wait for explicit "yes" or "approved"
6. NEVER skip this gate without explicit override

**Override Phrase**: PM may say "SKIP SECURITY REVIEW - I ACCEPT THE RISKS"

**This is a NON-NEGOTIABLE quality gate. Security review identifies vulnerabilities and ensures OWASP compliance.**

---

### Phase 3: Master Security Agent Review (WITH PERMISSION)

**CRITICAL - NON-NEGOTIABLE QUALITY GATE**

**TodoWrite Check**: Efficiency review must be completed before requesting Security Agent

**Step 1: Use Configured Thinking Mode**:

Thinking mode already loaded in Step 0a configuration: `$THINKING_MODE`

**Step 2: Ask PM for Permission**:

**Update TodoWrite**: Mark "REQUEST PM: Security Agent approval" as in_progress

**FORMATTING NOTE:** Keep all list items on separate lines.

```text
🎯 Efficiency Review Complete!

**Ready for Master Security Agent review?**

The Master Security Agent will:
- Check for security vulnerabilities
- Validate input sanitization
- Review authentication/authorization
- Identify potential exploits
- Ensure security best practices

💡 Thinking Mode:
[If global default exists: Will use configured mode: "[mode]" (~[X]K tokens)]
[If no global default: Will use default mode: "think" (~4K tokens)]

Ready to delegate to Master Security Agent?
- Type "yes" or "approved" to proceed with configured mode
- To override thinking mode, say: "yes, use ultrathink" (or "think hard")

Available modes: "think" (~4K), "think hard" (~10K), "ultrathink" (~32K)
Configure default in .claude/settings.json: "rptc.defaultThinkingMode"

**IMPORTANT**: Security review is a NON-NEGOTIABLE quality gate.

Waiting for your sign-off...
```

**DO NOT create sub-agent** until PM approves.

**After PM approval**:
- Mark "REQUEST PM: Security Agent approval" as completed
- Mark "EXECUTE: Security Agent review" as in_progress

#### Security Agent Delegation (If Approved)

**Step 1: Determine Final Thinking Mode**:
   - If user specified a mode override (e.g., "yes, use ultrathink"): Use user's choice
   - Else if global default exists in .claude/settings.json: Use that mode
   - Else: Use default "think" mode

**Step 2: Create Sub-Agent**:

```bash
# Notify Security Agent start
notify_discord "🔒 **Quality Gate: Security Review**\nScanning for vulnerabilities..." "detailed"
```

**Sub-Agent Prompt**:

```text
Use [determined thinking mode] thinking mode for this security audit.

You are a MASTER SECURITY AGENT - a world-class expert in application security and vulnerability assessment.

Your mission: Identify and fix security vulnerabilities in the implementation.

Context:
- Work item: [work item name]
- Files: [list of modified files]
- Tests: [X] tests passing

**Reference for Standards** (use fallback chain):
Load security SOP via fallback:
1. .rptc/sop/security-and-performance.md
2. ~/.claude/global/sop/security-and-performance.md
3. ${CLAUDE_PLUGIN_ROOT}/sop/security-and-performance.md

Follow OWASP Top 10 guidelines from SOPs.
Check `.context/` for project-specific security requirements.

Security audit areas:

## 1. Input Validation & Sanitization
- User inputs properly validated?
- SQL injection prevention?
- XSS prevention?
- Command injection risks?

## 2. Authentication & Authorization
- Auth checks in place?
- Permission validation?
- Session management secure?
- Token handling correct?

## 3. Data Protection
- Sensitive data encrypted?
- Secrets not exposed?
- PII handled correctly?
- Secure communication (HTTPS)?

## 4. Common Vulnerabilities (OWASP Top 10)
- Injection flaws
- Broken authentication
- Sensitive data exposure
- XML external entities
- Broken access control
- Security misconfiguration
- Cross-site scripting
- Insecure deserialization
- Using components with known vulnerabilities
- Insufficient logging & monitoring

## 5. Best Practices
- Rate limiting where needed?
- Error messages don't leak info?
- Dependencies up to date?
- Secure defaults configured?

For EACH security issue found:
- Severity: [Critical/High/Medium/Low]
- Description: [What's the issue]
- Fix: [How to fix it]
- Implement fix if possible

For EACH fix applied:
- Make the change
- Add security test if needed
- Run all tests to verify
- Document the fix

Return summary:
- Security issues found (by severity)
- Fixes applied
- New security tests added
- Tests status (must all pass)
- Security posture improvement

CRITICAL: All existing tests must pass. Add security tests where needed.
```

**Present Security Results**:

**FORMATTING NOTE:** Ensure each list item is on its own line with proper newlines between items.

```text
🔒 Master Security Agent Complete!

Security audit results:
- Critical issues: [X] (all fixed ✅)
- High issues: [Y] (all fixed ✅)
- Medium issues: [Z] (all fixed ✅)
- Low issues: [W] (noted for future)

Fixes applied:
- [Fix 1 description]
- [Fix 2 description]

New security tests added: [N]

✅ All tests passing ([X] tests)
🔒 Security posture: Improved

TDD implementation complete with quality gates passed!
```

```bash
# Notify TDD completion
notify_discord "✨ **TDD Execution Complete**\nPlan: \`${PLAN_NAME}\`\nAll tests passing ✅" "summary"
```

**Update TodoWrite**: Mark "EXECUTE: Security Agent review" as completed

---

### Phase 3.75: Independent Verification (Roadmap #18)

**Purpose**: Catch test overfitting and validate intent fulfillment before proceeding to refactoring.

**When Executed**: After GREEN phase (tests pass), before documentation and PM review

**Configuration**: Controlled by `.claude/settings.json` → `rptc.verificationMode`
- `"focused"` (default): Verify intent/coverage/overfitting only (<5 min)
- `"disabled"`: Skip verification (backward compatibility)
- `"exhaustive"`: Full verification (future enhancement, not yet implemented)

**Anthropic 7-Step Workflow Integration**: This implements Step 6 (Verify Before Refactoring)

---

#### Step 1: Check Verification Mode

```bash
# Load verification configuration
VERIFICATION_MODE=$(jq -r '.rptc.verificationMode // "focused"' .claude/settings.json 2>/dev/null || echo "focused")

if [ "$VERIFICATION_MODE" = "disabled" ]; then
  echo ""
  echo "⏩ Verification: Disabled (config: verificationMode='disabled')"
  echo "   Proceeding directly to documentation phase..."
  echo ""
  # Skip to next phase
  continue
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "  PHASE 3.75: INDEPENDENT VERIFICATION"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Mode: $VERIFICATION_MODE"
echo "Purpose: Catch test overfitting and validate intent fulfillment"
echo "Time Limit: <5 minutes per step"
echo ""
```

#### Step 2: Prepare Verification Context

```bash
# Collect context for verification sub-agent
VERIFICATION_CONTEXT=$(cat <<EOF
## Step Context

**Step Number:** $STEP_NUM
**Step Purpose:** $(sed -n '/^## Purpose/,/^## /p' "$STEP_FILE" | head -n -1)

## Planned Test Scenarios

$(sed -n '/^## Tests to Write First/,/^## Files/p' "$STEP_FILE" | head -n -1)

## Implementation Summary

**Files Modified:**
$(git diff --name-only HEAD 2>/dev/null || echo "Unable to detect changes")

**Tests Passing:**
[Test results from Phase 3 GREEN - all tests passed]

## Verification Task

Please complete the verification checklist:

$(cat "${CLAUDE_PLUGIN_ROOT}/templates/verification-checklist.md")

**Note on Test Assertions**: When reviewing tests, consider whether flexible assertions are appropriate for AI-generated or non-deterministic outputs:

- **Use exact assertions** for: Security logic, API contracts, performance benchmarks, compliance requirements
- **Consider flexible assertions** for: AI-generated text, code variations, reasoning explanations, multiple valid solution paths
- **Decision framework**: See \`flexible-testing-guide.md\` (SOP) for guidance on when to use semantic similarity, behavioral testing, or exact assertions

**Key Principle**: Exact assertions are the default. Flexible assertions require explicit justification and documentation.

---

Review ONLY:
1. Intent fulfillment (does implementation match step purpose?)
2. Coverage gaps (are all planned tests implemented?)
3. Overfitting detection (any hardcoded test gaming?)

Time limit: 5 minutes
EOF
)
```

#### Step 3: Delegate to Verification Sub-Agent

```bash
# Use Task tool with focused verification sub-agent
echo "🔍 Delegating to Verification Sub-Agent..."
echo ""
echo "Verification checks:"
echo "  1. Intent Fulfillment (does implementation match plan purpose?)"
echo "  2. Coverage Gaps (are all planned tests implemented?)"
echo "  3. Overfitting Detection (any hardcoded test gaming?)"
echo ""

# Delegate using Task tool
# In actual execution, this uses:
# Task(prompt: VERIFICATION_CONTEXT, type: "verification", thinking_mode: "think")
#
# For documentation purposes, we describe expected behavior:
# - Sub-agent receives full context (step purpose, planned tests, implementation files)
# - Sub-agent completes verification checklist
# - Returns structured result (PASS/FAIL/NEEDS_CLARIFICATION)

# Simulate sub-agent call (actual implementation uses Task tool)
# VERIFICATION_RESULT=$(task_delegation "$VERIFICATION_CONTEXT" "verification" "think")
```

#### Step 4: Process Verification Result

```bash
# Parse verification result
VERIFICATION_STATUS=$(echo "$VERIFICATION_RESULT" | grep "Verification Result:" | awk '{print $NF}')

case "$VERIFICATION_STATUS" in
  PASS)
    echo "✅ Verification: PASS"
    echo ""
    echo "$VERIFICATION_RESULT"
    echo ""
    echo "✅ All verification checks passed. Proceeding to documentation phase..."
    echo ""
    ;;

  FAIL)
    echo "❌ Verification: FAIL"
    echo ""
    echo "$VERIFICATION_RESULT"
    echo ""
    echo "❌ Verification identified gaps. Implementation requires rework."
    echo ""
    echo "Please review verification feedback above and address issues:"
    echo "  1. Fix intent fulfillment gaps"
    echo "  2. Add missing test scenarios"
    echo "  3. Remove hardcoded test gaming"
    echo ""
    read -p "Continue after fixes? (y/n): " CONTINUE_VERIFY
    if [ "$CONTINUE_VERIFY" != "y" ]; then
      echo ""
      echo "Pausing for implementation rework."
      echo "Resume with: /rptc:helper-resume-plan"
      echo ""
      exit 0
    fi
    ;;

  NEEDS_CLARIFICATION)
    echo "⚠️  Verification: Needs Clarification"
    echo ""
    echo "$VERIFICATION_RESULT"
    echo ""
    echo "Verification sub-agent flagged ambiguities. PM review required."
    echo ""
    read -p "Proceed with manual PM review? (y/n): " PM_REVIEW
    if [ "$PM_REVIEW" != "y" ]; then
      echo ""
      echo "Pausing for PM clarification."
      echo "Resume with: /rptc:helper-resume-plan"
      echo ""
      exit 0
    fi
    echo ""
    echo "Manual PM review approved. Proceeding..."
    echo ""
    ;;

  *)
    echo "⚠️  Verification: Unknown Result"
    echo ""
    echo "Verification sub-agent returned unexpected status: $VERIFICATION_STATUS"
    echo ""
    echo "Verification output:"
    echo "$VERIFICATION_RESULT"
    echo ""
    echo "Falling back to manual PM review..."
    echo ""
    read -p "Manual review complete? (y/n): " MANUAL_REVIEW
    if [ "$MANUAL_REVIEW" != "y" ]; then
      echo ""
      echo "Pausing for manual review."
      echo "Resume with: /rptc:helper-resume-plan"
      echo ""
      exit 0
    fi
    ;;
esac
```

#### Step 5: Log Verification Completion

```bash
echo ""
echo "✅ Phase 3.75 Complete: Independent Verification"
echo "   Status: $VERIFICATION_STATUS"
echo "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Proceeding to Documentation Phase..."
echo ""
```

---

### Phase 3.5: Master Documentation Specialist Agent (AUTOMATIC)

**CRITICAL - RUNS AUTOMATICALLY AFTER QUALITY GATES**

**TodoWrite Check**: Both quality gates (Efficiency + Security) must be completed before Documentation Specialist

**Purpose**: Ensure existing documentation remains accurate and synchronized with code changes made during TDD implementation.

**Update TodoWrite**: Mark "Documentation Specialist review (automatic)" as in_progress

**Review and update documentation to stay in sync with code changes.**

**When to run**: For ANY change that would make documentation out of sync - not just features, but refactors, architecture changes, API updates, etc.

#### Check Documentation Sync

**Analyze changes**:

```bash
git diff
```

**Ask**: Do these changes affect existing documentation?

**Check for**:

- New files/modules documented in README?
- API changes affecting API docs?
- Architecture changes affecting CLAUDE.md or docs?
- New dependencies affecting setup instructions?
- Changed workflows affecting contribution guides?
- Security changes affecting security docs?

**If documentation needs updating**:

**Step 1: Use Configured Thinking Mode**:

Thinking mode already loaded in Step 0a configuration: `$THINKING_MODE`

**Step 2: Delegate to Documentation Specialist**:

**FORMATTING NOTE:** Each change line must be on its own line with proper newlines.

```text
📚 Documentation Update Needed

Changes detected that affect documentation:
- [Change 1] affects [doc 1]
- [Change 2] affects [doc 2]

Delegating to Master Documentation Specialist with $THINKING_MODE mode...
```

#### Documentation Specialist Sub-Agent

**Sub-Agent Prompt**:

```text
Use $THINKING_MODE thinking mode for this documentation review.

You are a MASTER DOCUMENTATION SPECIALIST - Expert in keeping documentation synchronized with code changes.

Your mission: Update EXISTING documentation to reflect code changes. DO NOT create new documentation unless explicitly needed.

Context:
- Changes made: [summary from git diff]
- Files modified: [list]
- Work item: [if available from plan]

**Documentation to Review**:
- `CLAUDE.md` - Project guidelines, commands, workflow
- `README.md` - Setup, usage, overview
- `.context/` files - Project-specific context
- `$DOCS_LOC/` folder - If exists, check for affected docs
- `CONTRIBUTING.md` - If contribution process changed
- API docs - If API endpoints changed

**For EACH document**:

1. **Read current content**
2. **Identify outdated sections** based on code changes
3. **Update ONLY what's out of sync**:
   - Update examples if code changed
   - Update API signatures if endpoints changed
   - Update setup steps if dependencies changed
   - Update architecture diagrams if structure changed
   - Update command references if commands changed

4. **DO NOT**:
   - Create new documentation files
   - Add documentation that wasn't requested
   - Remove existing documentation
   - Change documentation style/format unnecessarily

5. **Report changes**:
   - Which docs updated
   - What was changed in each
   - Why it needed updating

Return summary:
- Documents updated: [list]
- Changes made: [by document]
- Documentation sync status: ✅ In sync

CRITICAL: Only update existing docs. Ask before creating new docs.
```

**Present Documentation Results**:

**FORMATTING NOTE:** Ensure each documentation update and summary item is on its own line with proper newlines.

```text
📚 Master Documentation Specialist Complete!

Documentation updated:
- `README.md`: Updated API examples for new endpoints
- `CLAUDE.md`: Updated helper command references
- `.context/project-overview.md`: Updated architecture section

Changes summary:
- 3 files updated
- 12 lines changed
- Documentation now in sync with code

✅ All documentation synchronized with changes

Proceeding to final PM sign-off...
```

**If no documentation changes needed**:

```text
📚 Documentation Sync Check: ✅ No updates needed

Code changes don't affect existing documentation.

Proceeding to final PM sign-off...
```

**Update TodoWrite**: Mark "Documentation Specialist review (automatic)" as completed

---

**CRITICAL VALIDATION CHECKPOINT - CANNOT MARK COMPLETE WITHOUT PM APPROVAL**

Before marking TDD phase complete:

**TodoWrite Check**: "REQUEST PM: Final TDD sign-off" MUST be completed

**Verification**:
1. All implementation steps completed
2. Efficiency review completed
3. Security review completed
4. Documentation review completed
5. All tests passing

❌ **COMPLETION BLOCKED** - Cannot mark TDD complete without PM sign-off

**Required**: PM must confirm implementation is ready for commit

**ENFORCEMENT**: If PM has NOT approved:
1. Present completion summary (all checks passed)
2. Ask: "TDD Phase Complete - Ready for commit?"
3. Wait for explicit "yes" or "approved"
4. NEVER update plan status without PM confirmation

**This is a NON-NEGOTIABLE gate. TDD completion marks implementation ready for commit - PM must verify this.**

---

### Phase 4: Final PM Sign-Off (REQUIRED)

**CRITICAL - CANNOT MARK TDD COMPLETE WITHOUT PM APPROVAL**

**TodoWrite Check**: Both quality gates must be completed

**Update TodoWrite**: Mark "REQUEST PM: Final TDD sign-off" as in_progress

**Get explicit approval to complete TDD phase**:

**FORMATTING NOTE:** Ensure each list item is on its own line. Never concatenate items (e.g., `- Item 1- Item 2` is WRONG).

```text
✅ TDD Implementation Complete with Quality Gates!

Summary:
- Implementation: ✅ All [N] steps complete
- Tests: ✅ [X] tests passing
- Coverage: ✅ [Y]%
- Efficiency Review: ✅ Complete
- Security Review: ✅ Complete

Files changed: [Z]
- [file 1]
- [file 2]
...

**TDD Phase Complete - Ready for commit?**

Type "yes" or "approved" to mark TDD complete and proceed to commit phase.
Type "modify" if changes needed.

Waiting for your final sign-off...
```

**DO NOT update plan status** until PM approves.

**After PM approval**:
- Mark "REQUEST PM: Final TDD sign-off" as completed
- Mark "UPDATE: Mark plan status Complete" as in_progress

### Phase 5: Update Plan Status (Only After Approval)

Once approved:

1. Update plan document (`$ARTIFACT_LOC/plans/[plan-name].md`):

   - Change status from "In Progress" to "Complete"
   - Mark all remaining checkboxes as complete
   - Add completion notes
   - Add final test count and coverage

2. **Confirm next step**:

**FORMATTING NOTE:** Each status item must be on its own line.

```text
✅ TDD Phase Approved by Project Manager!

Plan updated: `$ARTIFACT_LOC/plans/[plan-name].md`
- Status: ✅ Complete
- All steps: ✅ Marked complete
- Tests: [X] passing
- Coverage: [Y]%

Next step: `/rptc:commit` or `/rptc:commit pr` to verify and ship!
```

**Update TodoWrite**: Mark "UPDATE: Mark plan status Complete" as completed

✅ All TDD phases complete. TodoWrite list should show all tasks completed.

## Auto-Iteration Rules

**When tests fail during GREEN phase**:

- **Maximum $MAX_ATTEMPTS iterations** per test failure
- **Each iteration**:
  1. Analyze failure message carefully
  2. Identify root cause
  3. Make minimal, targeted fix
  4. Re-run tests
  5. Report: "Iteration N: [what was fixed] → [result]"

**If still failing after $MAX_ATTEMPTS iterations**:

**FORMATTING NOTE:** Ensure each option is on its own line with proper newlines.

```text
❌ Auto-iteration limit reached ($MAX_ATTEMPTS attempts)

Persistent failure: [test name]
Error: [error message]

The test strategy or implementation approach may need reconsideration.

Options:
1. Review test expectations
2. Reconsider implementation approach
3. Ask PM for guidance

What would you like to do?
```

```bash
# Notify test failure
notify_discord "❌ **TDD Execution Failed**\nPlan: \`${PLAN_NAME}\`\nStep: ${STEP_NUM}\nReason: Tests failing after max attempts" "summary"
```

**Never proceed with failing tests** - that violates TDD principles.

## Interaction Guidelines

### DO:

- ✅ Write tests BEFORE implementation (always)
- ✅ Follow RED → GREEN → REFACTOR cycle strictly
- ✅ Auto-iterate on test failures (max $MAX_ATTEMPTS)
- ✅ Run tests after every change
- ✅ Ask permission before quality gate sub-agents
- ✅ Keep all tests passing
- ✅ Get PM sign-off before completing

### DON'T:

- ❌ Write implementation before tests
- ❌ Skip any TDD phase
- ❌ Proceed with failing tests
- ❌ Create sub-agents without permission
- ❌ Mark complete without PM approval
- ❌ Skip quality gates

## Example Interaction Flow

**Example 1: Directory Format (Recommended)**

```text
User: /rptc:tdd "@user-authentication/"

Agent: 📋 Plan Loaded (Directory Format): User Authentication System

Overview:
Implement OAuth-based authentication system with JWT tokens,
password reset flow, and security hardening.

Steps to implement: 5
(Step details will be loaded per-step during Phase 1)

Test Strategy:
- Coverage target: 85%
- Test files: tests/auth/*.test.js
- Focus: Security, token validation, error handling

Architecture:
Directory-based plan with sub-agent delegation per step.
Quality gates (Efficiency/Security) execute after ALL steps complete.

Ready to begin TDD implementation with sub-agent delegation.

---

[For each step, TDD delegates to sub-agent with context...]

---

✅ Implementation Complete - All Tests Passing!
[Proceeds to quality gates...]
```

**Example 2: Monolithic Format (Backward Compatibility)**

```text
User: /rptc:tdd "@user-authentication.md"

Agent: 📋 Plan Loaded (Monolithic Format): User Authentication System

Steps to implement: 5
1. OAuth Strategy Setup
2. JWT Token Management
3. Password Reset Flow
4. Frontend Integration
5. Security Hardening

Ready to begin TDD implementation.

---

🔴 RED Phase - Step 1: OAuth Strategy Setup

Writing tests first...
✅ Tests written: 4 tests
- ❌ should configure Google OAuth strategy
- ❌ should configure GitHub OAuth strategy
- ❌ should handle OAuth callback
- ❌ should validate OAuth tokens

All tests failing as expected (no implementation yet).

Proceeding to GREEN phase...

---

🟢 GREEN Phase - Step 1: OAuth Strategy Setup

Implementing OAuth strategy setup...
Running tests...

Iteration 1: Configured Passport strategies → ❌ 2 tests still failing
Iteration 2: Added token validation → ✅ All tests passing!

✅ All tests passing (4 tests)

Proceeding to REFACTOR phase...

---

🔧 REFACTOR Phase - Step 1

Improvements made:
- Extracted OAuth config to separate file
- Improved error handling
- Added explanatory comments

✅ All tests still passing

Step 1 complete!

---

[Steps 2-5 follow same pattern...]

---

✅ Implementation Complete - All Tests Passing!

All 5 steps implemented successfully.
- Total tests: 23 passing
- Overall coverage: 87%
- Files changed: 12

**Ready for Master Efficiency Agent review?**
[Details...]

User: yes

Agent: [Creates Efficiency Agent...]

🎯 Master Efficiency Agent Complete!
[Results...]

**Ready for Master Security Agent review?**
[Details...]

User: yes

Agent: [Creates Security Agent...]

🔒 Master Security Agent Complete!
[Results...]

---

✅ TDD Implementation Complete with Quality Gates!

**TDD Phase Complete - Ready for commit?**

User: approved

Agent: ✅ TDD Phase Approved!

Next step: `/rptc:commit pr`
```

## Success Criteria

- [ ] Plan loaded and understood
- [ ] All steps implemented using TDD cycle
- [ ] All tests passing (no failures)
- [ ] Coverage meets targets (80%+)
- [ ] PM approved Efficiency Agent review (NON-NEGOTIABLE)
- [ ] Efficiency improvements applied
- [ ] PM approved Security Agent review (NON-NEGOTIABLE)
- [ ] Security issues fixed
- [ ] PM gave final sign-off
- [ ] Plan status updated to Complete
- [ ] Ready for commit phase

---

_Remember: TDD is non-negotiable. Tests first, always. Quality gates (Efficiency & Security) are MANDATORY - PM approval required, no skipping allowed._
