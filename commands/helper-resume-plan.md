# Resume Work on Existing Plan

Resume implementation of a plan from a previous session with full context restoration.

Arguments:

- Directory plan: `/rptc:helper-resume-plan "@plan-name/"`
- Monolithic plan: `/rptc:helper-resume-plan "@plan-name.md"`

## Purpose

When starting a new session and continuing work on an existing plan, this command:

1. **Detects handoff checkpoint** (if TDD paused mid-execution)
2. Loads plan and analyzes progress
3. Determines how much work remains
4. Automatically runs appropriate catch-up command
5. Provides focused context for continuing work

**Handoff Awareness (v1.2.0+)**: If a handoff checkpoint exists (`[artifact-location]/plans/[plan-name]/handoff.md`), this command prioritizes it to resume from the exact state where TDD paused. This provides superior context restoration with:
- Exact step checkpoint (which step to resume)
- Configuration preservation (thinking mode, coverage targets)
- Context analysis from pause point
- Pre-loaded next step content

## Process

## Step 0: Load Configuration

**Load configuration**:

1. **Check if settings file exists**:
   - Use Read tool to read `.claude/settings.json`
   - If file doesn't exist or can't be read, use defaults (skip to step 3)

2. **Parse configuration** (extract these fields):
   - `rptc.artifactLocation` → ARTIFACT_LOC (default: ".rptc")
   - `rptc.docsLocation` → DOCS_LOC (default: "docs")

3. **Display loaded configuration**:
   ```text
   Configuration loaded:
     Artifact location: [ARTIFACT_LOC value]
     Docs location: [DOCS_LOC value]
   ```

**Use these values throughout the command execution.**

**Note**: References to these variables appear throughout this command - use the actual loaded values from this step.

### Step 1: Detect Plan Format and Handoff State

**Determine plan format from argument**:

```bash
# Extract plan reference
PLAN_REF="$1"  # e.g., "@user-authentication/" or "@user-authentication.md"

# Detect format
if [[ "$PLAN_REF" == @*/ ]]; then
  PLAN_FORMAT="directory"
  PLAN_NAME="${PLAN_REF#@}"
  PLAN_NAME="${PLAN_NAME%/}"
  PLAN_DIR="${ARTIFACT_LOC}/plans/${PLAN_NAME}/"
  PLAN_FILE="${PLAN_DIR}overview.md"
  HANDOFF_FILE="${PLAN_DIR}handoff.md"
elif [[ "$PLAN_REF" == @*.md ]]; then
  PLAN_FORMAT="monolithic"
  PLAN_NAME="${PLAN_REF#@}"
  PLAN_NAME="${PLAN_NAME%.md}"
  PLAN_FILE="${ARTIFACT_LOC}/plans/${PLAN_NAME}.md"
  HANDOFF_FILE=""  # Monolithic plans don't use handoff.md
else
  echo "❌ Error: Invalid plan format"
  echo "Expected: @plan-name/ (directory) or @plan-name.md (monolithic)"
  exit 1
fi
```

**Check for handoff checkpoint** (directory format only):

```bash
if [ "$PLAN_FORMAT" = "directory" ] && [ -f "$HANDOFF_FILE" ]; then
  RESUME_MODE="handoff"
  echo "🔄 Handoff checkpoint detected: $HANDOFF_FILE"
  echo "   Resuming from exact TDD pause point..."

  # Claude: Read .claude/settings.json and extract nested discord config:
  # - rptc.discord.notificationsEnabled → DISCORD_ENABLED (default: false)
  # - rptc.discord.webhookUrl → DISCORD_WEBHOOK (default: "")
  # Read(".claude/settings.json")
  # Extract: rptc.discord.notificationsEnabled → DISCORD_ENABLED
  # Extract: rptc.discord.webhookUrl → DISCORD_WEBHOOK
  if [ "$DISCORD_ENABLED" = "true" ] && [ -n "$DISCORD_WEBHOOK" ]; then
    bash "${CLAUDE_PLUGIN_ROOT}/skills/discord-notify/scripts/notify.sh" "$DISCORD_WEBHOOK" "🔄 **Handoff Detected**\nResuming: \`${PLAN_NAME}\`" 2>/dev/null || true
  fi
  echo ""
else
  RESUME_MODE="standard"
  echo "📋 No handoff checkpoint found. Analyzing plan progress..."
  echo ""
fi
```

### 1. Load Plan State (Handoff-Aware)

**If handoff checkpoint exists (`RESUME_MODE="handoff"`):**

#### Step 1a: Parse Handoff State

**Extract checkpoint data from handoff.md:**

**Read handoff file:**

```
Use Read tool: Read(file_path: "$HANDOFF_FILE")
```

**Parse handoff state in Claude:**

From the Read output, extract:

1. **Completed Steps**: Find line starting with "**Completed Steps**:" and extract the number N from "Steps 1-N"
   - Store as COMPLETED_STEP
2. **Next Step**: Calculate COMPLETED_STEP + 1 in Claude
   - Store as NEXT_STEP
3. **Trigger Reason**: Find line starting with "**Trigger Reason**:" and extract text after the colon (trimmed)
   - Store as HANDOFF_REASON

**Count total steps:**

```
Use Glob tool: Glob(pattern: "$PLAN_DIR/step-*.md")
Count the number of results returned → TOTAL_STEPS
```

**Display extracted state:**

```text
📖 Loading handoff state...

   Completed: Steps 1-[COMPLETED_STEP]
   Next Step: [NEXT_STEP]
   Remaining: [TOTAL_STEPS - COMPLETED_STEP] steps
   Reason: [HANDOFF_REASON]
```

#### Step 1b: Restore Historical Usage Data

**Extract and restore STEP_CONTEXT_USAGE array:**

**Read handoff file** (reuse from Step 1a if available):

```
Use Read tool: Read(file_path: "$HANDOFF_FILE")
```

**Parse context usage array in Claude (NO EVAL - SECURITY FIX):**

From the Read output:

1. Find line containing "STEP_CONTEXT_USAGE="
2. Extract the array values after the equals sign (format: "(value1 value2 value3)")
3. Parse the parentheses-enclosed values into a list (extract text between parentheses, split by spaces)
4. Store as STEP_CONTEXT_USAGE array for use in token tracking

**Example parsing:**
- Input line: `STEP_CONTEXT_USAGE=(15000 23000 18000)`
- Parse: Extract numbers between parentheses → "15000 23000 18000"
- Split by spaces → [15000, 23000, 18000]
- Result: STEP_CONTEXT_USAGE array with 3 elements

**CRITICAL:** Parse the array safely in Claude. **NEVER use eval** as it creates arbitrary code execution vulnerability if handoff file is corrupted.

**Display restored usage data:**

```text
📊 Historical usage data restored:
   Data Points: [count of STEP_CONTEXT_USAGE array]
```

If STEP_CONTEXT_USAGE has 3 or more elements, also display:
```text
   Last 3 Steps:
     Step [count - 2]: [third-to-last value] tokens
     Step [count - 1]: [second-to-last value] tokens
     Step [count]:     [last value] tokens
```

#### Step 1c: Restore Calibration Data

**Extract and restore prediction calibration:**

**Read handoff file** (reuse from previous reads if available):

```
Use Read tool: Read(file_path: "$HANDOFF_FILE")
```

**Parse calibration multiplier in Claude:**

From the Read output:

1. Find line containing "CALIBRATION_MULTIPLIER="
2. Extract the numeric value after the equals sign
3. Store as CALIBRATION_MULTIPLIER for prediction adjustments

**Example parsing:**
- Input line: `CALIBRATION_MULTIPLIER=1.15`
- Parse: Extract text after "=" → "1.15"
- Result: CALIBRATION_MULTIPLIER = 1.15

**Parse prediction errors array in Claude (NO EVAL - SECURITY FIX):**

From the Read output:

1. Find line containing "PREDICTION_ERRORS="
2. Extract the array values after the equals sign (format: "(value1 value2 value3)")
3. Parse the parentheses-enclosed values into a list (extract text between parentheses, split by spaces)
4. Store as PREDICTION_ERRORS array

**Example parsing:**
- Input line: `PREDICTION_ERRORS=(5.2 -3.1 7.8)`
- Parse: Extract text between parentheses → "5.2 -3.1 7.8"
- Split by spaces → [5.2, -3.1, 7.8]
- Result: PREDICTION_ERRORS array with 3 elements

**CRITICAL:** Parse array safely in Claude. **NEVER use eval** as it creates arbitrary code execution vulnerability.

**Calculate average error in Claude (no awk):**

If PREDICTION_ERRORS array has at least 1 element:

1. Sum all values in PREDICTION_ERRORS array
2. Divide by count of values
3. Format to 1 decimal place
4. Store as AVG_ERROR

**Example calculation:**
- Input: PREDICTION_ERRORS = [5.2, -3.1, 7.8]
- Sum: 5.2 + (-3.1) + 7.8 = 9.9
- Count: 3
- Average: 9.9 / 3 = 3.3
- Formatted: "3.3"

**Display calibration data:**

```text
🎯 Calibration restored:
   Multiplier: [CALIBRATION_MULTIPLIER]×

   Prediction Errors: [count of PREDICTION_ERRORS] data points
```

If PREDICTION_ERRORS has at least 1 element, also display:
```text
   Average Error: [AVG_ERROR]%
```

#### Step 1d: Initialize Fresh Context

**Fresh context starts at 15K (overview.md loaded):**

```bash
# Fresh context starts at 15K (overview.md loaded)
CURRENT_CONTEXT=15000

echo "🔄 Fresh context initialized:"
echo "   Starting Context: ${CURRENT_CONTEXT} tokens (overview.md)"
echo "   Using Calibrated Predictions: YES"
echo "   Historical Data Available: YES (${#STEP_CONTEXT_USAGE[@]} steps)"
echo ""
```

#### Step 1e: Display Handoff Summary

**Present checkpoint status:**

```text
🔄 Resuming from TDD Checkpoint: ${PLAN_NAME}

Handoff Status:
- Pause Point: After Step ${COMPLETED_STEP} ✅
- Next Step: Step ${NEXT_STEP} of ${TOTAL_STEPS} ⏳
- Remaining: $((TOTAL_STEPS - COMPLETED_STEP)) steps
- Reason: ${HANDOFF_REASON}

Context Metrics (from checkpoint):
- Context at Handoff: [from handoff.md]
- Projected Next Step: [from handoff.md]
- Hard Cap (80%): 160,000 tokens

Calibration Restored:
- Multiplier: ${CALIBRATION_MULTIPLIER}×
- Historical Usage: ${#STEP_CONTEXT_USAGE[@]} data points
- Prediction Errors: ${#PREDICTION_ERRORS[@]} tracked
- Average Error: ${AVG_ERROR}%

Handoff Benefits:
✅ Exact checkpoint state loaded
✅ Calibration preserved from original session
✅ Historical usage data restored
✅ Fresh context for optimal execution

Resume Mode: HANDOFF (Superior context restoration)
```

**If no handoff (standard plan analysis):**

Read `[artifact-location]/plans/[plan-name]/overview.md` (directory) or `[artifact-location]/plans/[plan-name].md` (monolithic):

- Parse all implementation steps
- Count total steps vs completed steps
- Check plan status
- Review test strategy
- Note any blockers or issues

**Present Standard Plan Status**:

```text
📋 Plan Status: [Plan Name]

Progress:
- Total Steps: [N]
- Completed: [X] ✅
- Remaining: [Y] ⏳
- Status: [In Progress/Blocked/etc.]

Last Modified: [timestamp if available]

Remaining Work:
1. [ ] Step [N]: [Description]
2. [ ] Step [N+1]: [Description]
...

Current Status: [Brief summary]
```

### 2. Determine Context Depth Needed (Handoff-Aware)

**If handoff checkpoint exists (`RESUME_MODE="handoff"`):**

Handoff already contains rich context. Reduce catch-up depth:

```text
🔄 Handoff Mode: Using focused catch-up...

Handoff provides:
- Exact step checkpoint
- Configuration state
- Context analysis
- Next step content

Running quick catch-up for recent codebase changes only...
[Automatically invoke /rptc:helper-catch-up-quick]
```

**Rationale**: Handoff.md already captures:
- Where you stopped (exact step)
- Why you stopped (context analysis)
- What's next (next step content)
- How to continue (configuration)

Only need to check for codebase drift since handoff was created.

### 2a. Confirm Catch-Up Depth (Interactive Menu - Handoff Mode)

**Determine automatic selection**:

For handoff mode: `AUTO_SELECTION="quick"` with explanation `"Handoff provides rich context"`

**Build menu description**:

```text
Automatic selection: Quick based on handoff checkpoint.

Context depth options:
• Quick: Recent changes only (fastest, ~2-5K tokens)
• Medium: Recent changes + key patterns (~5-10K tokens)
• Deep: Full codebase context (~15-30K tokens)

Handoff provides rich context. Quick catch-up recommended.
You can override the automatic selection if needed.
```

**Use AskUserQuestion tool**:

Use the AskUserQuestion tool to present catch-up depth options:

```
question: "Select Context Catch-Up Depth"
header: "Catch-up"
multiSelect: false
options:
  1. label: "Use automatic selection (Quick)"
     description: "Handoff provides rich context. Only check recent codebase changes."
  2. label: "Quick catch-up (faster, less context)"
     description: "Recent changes only. Best when handoff is fresh (<7 days)."
  3. label: "Medium catch-up (balanced depth)"
     description: "Recent changes + key patterns. Use if moderate changes expected."
  4. label: "Deep catch-up (slower, full context)"
     description: "Full codebase context. Use if significant changes or handoff is stale."
```

**Handle user selection** (stored in response as `CATCHUP_CHOICE`):

```bash
# Claude stores selection in CATCHUP_CHOICE variable

case "$CATCHUP_CHOICE" in
  "Use automatic selection"*)
    # Use AUTO_SELECTION determined above
    SELECTED_DEPTH="quick"
    echo "✓ Using automatic selection: Quick"
    ;;
  "Quick catch-up"*)
    SELECTED_DEPTH="quick"
    echo "✓ Override: Quick catch-up selected"
    ;;
  "Medium catch-up"*)
    SELECTED_DEPTH="medium"
    echo "✓ Override: Medium catch-up selected"
    ;;
  "Deep catch-up"*)
    SELECTED_DEPTH="deep"
    echo "✓ Override: Deep catch-up selected"
    ;;
esac

echo ""
```

**Invoke selected catch-up command**:

```text
🔄 Running ${SELECTED_DEPTH} context catch-up...
[Invoke corresponding helper-catch-up command based on SELECTED_DEPTH:
  - quick: /rptc:helper-catch-up-quick
  - medium: /rptc:helper-catch-up-med
  - deep: /rptc:helper-catch-up-deep]
```

**If no handoff (standard plan analysis):**

Based on remaining work, automatically decide:

**If 1-2 simple steps remain**:

```text
🔄 Running quick context catch-up...
[Automatically invoke /rptc:helper-catch-up-quick]
```

**If 3-5 steps or moderate complexity**:

```text
🔄 Running medium context catch-up...
[Automatically invoke /rptc:helper-catch-up-med]
```

**If 6+ steps or high complexity**:

```text
🔄 Running deep context catch-up...
[Automatically invoke /rptc:helper-catch-up-deep]
```

### 2b. Confirm Catch-Up Depth (Interactive Menu - Standard Mode)

**Determine automatic selection** based on remaining work:

```bash
# Determine automatic selection
if [ "$REMAINING_STEPS" -le 2 ]; then
  AUTO_SELECTION="quick"
  AUTO_REASON="1-2 simple steps remain"
elif [ "$REMAINING_STEPS" -le 5 ]; then
  AUTO_SELECTION="medium"
  AUTO_REASON="3-5 steps or moderate complexity"
else
  AUTO_SELECTION="deep"
  AUTO_REASON="6+ steps or high complexity"
fi
```

**Build menu description**:

```text
Automatic selection: ${AUTO_SELECTION^} (${AUTO_REASON}).

Context depth options:
• Quick: Recent changes only (fastest, ~2-5K tokens)
• Medium: Recent changes + key patterns (~5-10K tokens)
• Deep: Full codebase context (~15-30K tokens)

You can override the automatic selection if needed.
```

**Use AskUserQuestion tool**:

Use the AskUserQuestion tool to present catch-up depth options:

```
question: "Select Context Catch-Up Depth"
header: "Catch-up"
multiSelect: false
options:
  1. label: "Use automatic selection (${AUTO_SELECTION^})"
     description: "Based on remaining work: ${AUTO_REASON}"
  2. label: "Quick catch-up (faster, less context)"
     description: "Recent changes only. Best for simple remaining work (1-2 steps)."
  3. label: "Medium catch-up (balanced depth)"
     description: "Recent changes + key patterns. Best for moderate work (3-5 steps)."
  4. label: "Deep catch-up (slower, full context)"
     description: "Full codebase context. Best for complex work (6+ steps) or stale plans."
```

**Handle user selection** (stored in response as `CATCHUP_CHOICE`):

```bash
# Claude stores selection in CATCHUP_CHOICE variable

case "$CATCHUP_CHOICE" in
  "Use automatic selection"*)
    # Use AUTO_SELECTION determined above
    SELECTED_DEPTH="$AUTO_SELECTION"
    echo "✓ Using automatic selection: ${SELECTED_DEPTH^}"
    ;;
  "Quick catch-up"*)
    SELECTED_DEPTH="quick"
    echo "✓ Override: Quick catch-up selected"
    ;;
  "Medium catch-up"*)
    SELECTED_DEPTH="medium"
    echo "✓ Override: Medium catch-up selected"
    ;;
  "Deep catch-up"*)
    SELECTED_DEPTH="deep"
    echo "✓ Override: Deep catch-up selected"
    ;;
esac

echo ""
```

**Invoke selected catch-up command**:

```text
🔄 Running ${SELECTED_DEPTH} context catch-up...
[Invoke corresponding helper-catch-up command based on SELECTED_DEPTH:
  - quick: /rptc:helper-catch-up-quick
  - medium: /rptc:helper-catch-up-med
  - deep: /rptc:helper-catch-up-deep]
```

### 3. Load Related Research (If Exists)

Check if plan references research document:

- If found in plan frontmatter, read `${ARTIFACT_LOC}/research/[topic].md`
- Summarize key findings relevant to remaining work

**Present Research Summary** (if applicable):

```text
📚 Related Research: [topic]

Key Points for Remaining Work:
- [Relevant finding 1]
- [Relevant finding 2]
- [Relevant consideration 3]
```

### 4. Review Recent Changes (Git)

Check git history for activity on files mentioned in plan:

```bash
git log --oneline --all --grep="[plan-topic]" | head -10
git diff --name-status main..HEAD -- [files-from-plan]
```

**Present Recent Activity**:

```text
📝 Recent Changes:
- [X] commits related to this work
- [Y] files modified
- Last commit: [commit message]
```

### 5. Check Test Status

If plan includes test files:

- Check if test files exist
- Count tests (if possible)
- Note testing progress

**Present Test Status**:

```text
🧪 Test Status:
- Test files: [exist/missing]
- Tests written: [N] (estimated)
- Coverage: [if available]
```

### 6. Provide Resumption Guidance (Handoff-Aware)

**If resuming from handoff checkpoint:**

```text
═══════════════════════════════════════════════════════════════
  READY TO RESUME FROM CHECKPOINT: [Plan Name]
═══════════════════════════════════════════════════════════════

Resume Mode: 🔄 HANDOFF (Checkpoint-based restoration)
Checkpoint Step: Step [COMPLETED_STEPS] completed ✅
Next Step: Step [CURRENT_STEP] of [TOTAL_STEPS] ⏳
Handoff Reason: [HANDOFF_REASON]

Configuration Restored:
- Thinking Mode: [THINKING_MODE]
- Coverage Target: [COVERAGE_TARGET]%
- Context: Preserved from original session

Context Level: Quick ✅ (Handoff provides rich context)
Related Research: [loaded/not found]
Git Activity: [active/stale]
Tests: [on track/needs attention]

NEXT STEP (from handoff):
Step [CURRENT_STEP]: [Next step description from handoff.md]

Tests to Write First:
[Extract from handoff.md next step section]

Files to Modify:
[Extract from handoff.md next step section]

═══════════════════════════════════════════════════════════════
READY TO CONTINUE FROM CHECKPOINT
═══════════════════════════════════════════════════════════════

To continue from checkpoint:
  /rptc:tdd "@[plan-name]/"

Note: TDD command will auto-detect handoff.md and resume from Step [CURRENT_STEP]

To review handoff details:
  cat ${ARTIFACT_LOC}/plans/[plan-name]/handoff.md

To modify plan first:
  /rptc:helper-update-plan "@[plan-name]/" "changes"
```

**If resuming from standard plan analysis:**

```text
═══════════════════════════════════════════════════════════════
  READY TO RESUME: [Plan Name]
═══════════════════════════════════════════════════════════════

Resume Mode: 📋 STANDARD (Plan-based analysis)
Context Level: [Quick/Medium/Deep] ✅
Plan Progress: [X/N] steps complete
Related Research: [loaded/not found]
Git Activity: [active/stale]
Tests: [on track/needs attention]

NEXT STEP:
Step [N]: [Next step description]

Tests to Write First:
- [ ] [Test 1]
- [ ] [Test 2]

Files to Modify:
- [file1.ts]
- [file2.ts]

═══════════════════════════════════════════════════════════════
READY TO CONTINUE
═══════════════════════════════════════════════════════════════

To continue implementation:
  /rptc:tdd "@[plan-name]/" (directory) or "@[plan-name].md" (monolithic)

```bash
# Claude: Read .claude/settings.json and extract nested discord config:
# - rptc.discord.notificationsEnabled → DISCORD_ENABLED (default: false)
# - rptc.discord.webhookUrl → DISCORD_WEBHOOK (default: "")
# Read(".claude/settings.json")
# Extract: rptc.discord.notificationsEnabled → DISCORD_ENABLED
# Extract: rptc.discord.webhookUrl → DISCORD_WEBHOOK
if [ "$DISCORD_ENABLED" = "true" ] && [ -n "$DISCORD_WEBHOOK" ]; then
  bash "${CLAUDE_PLUGIN_ROOT}/skills/discord-notify/scripts/notify.sh" "$DISCORD_WEBHOOK" "🔄 **Resume Complete**\nPlan: \`${PLAN_NAME}\`\nReady to continue TDD" 2>/dev/null || true
fi
```

To modify plan first:
  /rptc:helper-update-plan "@[plan-name]/" "changes"

To start fresh research:
  /rptc:research "[topic]"
```

## Intelligence Features

### Smart Context Selection (Handoff-Aware)

The command intelligently determines context depth based on resume mode:

**Handoff Mode (v1.2.0+)**:
```text
Handoff Checkpoint Detected:
- Always: quick catch-up (handoff provides rich context)
- Exception: If handoff >7 days old → deep catch-up (staleness override)

Rationale: Handoff already contains:
- Exact checkpoint state
- Configuration snapshot
- Next step content
- Context analysis

Only need to check for codebase drift since handoff creation.
```

**Standard Mode** (no handoff):
```text
Remaining Work Assessment:
- Simple (1-2 steps, < 200 lines): quick catch-up
- Medium (3-5 steps, 200-500 lines): medium catch-up
- Complex (6+ steps, > 500 lines): deep catch-up
- Blocked/Stale: deep catch-up (need full understanding)
```

### Staleness Detection

If plan hasn't been touched in a while:

- Check last git commit related to plan
- If > 7 days: Recommend deep catch-up
- If > 30 days: Warn about potential drift

```text
⚠️  Plan Staleness Warning:
Last activity: [X] days ago

The codebase may have changed significantly.
Recommending deep catch-up for safety.
```

### Blocker Detection

If plan mentions blockers or issues:

```text
🚨 Blockers Detected:
- [Blocker 1 from plan notes]
- [Blocker 2 from plan notes]

Address these before continuing implementation.
```

## Edge Case Handling

### Missing Handoff File

If handoff.md referenced but doesn't exist:

```text
⚠️  Handoff File Missing

Expected: ${ARTIFACT_LOC}/plans/[plan-name]/handoff.md
Status: File not found

This may indicate:
- Handoff file was deleted
- Plan directory moved/renamed
- Incomplete handoff generation

Falling back to standard plan analysis...
📋 Analyzing plan progress from overview.md...
```

**Resolution**: Falls back to Route B (standard plan analysis) automatically.

### Partial/Corrupted Handoff Data

If handoff.md exists but data extraction fails:

```text
⚠️  Handoff Data Extraction Failed

File exists: ${ARTIFACT_LOC}/plans/[plan-name]/handoff.md
Issue: Unable to parse checkpoint state

Common causes:
- Incomplete handoff generation
- File corruption
- Format mismatch (old version)

Attempting standard plan analysis as fallback...
```

**Resolution**: Log warning, fall back to standard plan analysis.

### Handoff with Stale Context

If handoff.md is >7 days old, present interactive menu to user:

#### Step 1f: Handle Stale Handoff (Interactive Menu)

**Check handoff age** (only if handoff mode):

```bash
# Calculate handoff age in days
# Claude: Read handoff file, extract creation timestamp, calculate days since creation
# Store in HANDOFF_AGE_DAYS

if [ "$RESUME_MODE" = "handoff" ] && [ "$HANDOFF_AGE_DAYS" -gt 7 ]; then
  HANDOFF_STALE=true
else
  HANDOFF_STALE=false
fi
```

**If handoff is stale, present action menu**:

```bash
if [ "$HANDOFF_STALE" = true ]; then
  echo "⚠️  Stale Handoff Checkpoint Detected"
  echo ""
  echo "   Handoff created: ${HANDOFF_AGE_DAYS} days ago"
  echo "   Threshold: 7 days"
  echo ""
  echo "   The codebase may have changed significantly since checkpoint."
  echo ""
```

**Use AskUserQuestion tool**:

Use the AskUserQuestion tool to present stale handoff action options:

```
question: "Stale Handoff Detected (${HANDOFF_AGE_DAYS} days old)"
header: "Stale Handoff"
multiSelect: false
options:
  1. label: "Proceed with stale handoff (use deep catch-up)"
     description: "Continue with existing checkpoint. Automatically upgrades catch-up to deep for safety. Best if codebase changes are minimal."
  2. label: "Regenerate handoff (re-run TDD to create fresh checkpoint)"
     description: "Create new checkpoint from current codebase state. Recommended if significant changes occurred. Requires re-running TDD command."
  3. label: "Abort resume (cancel operation)"
     description: "Cancel resume operation. Review changes manually before deciding how to proceed."
```

**Handle user selection** (stored in response as `STALE_ACTION`):

```bash
# Claude stores selection in STALE_ACTION variable

case "$STALE_ACTION" in
  "Proceed with stale handoff"*)
    echo "⚠️  Proceeding with stale handoff..."
    echo "   Upgrading catch-up depth: Quick → Deep (safety measure)"
    echo ""
    # Override AUTO_SELECTION for catch-up depth menu
    AUTO_SELECTION="deep"
    # Continue to Step 2a (catch-up depth menu) with deep as default
    ;;

  "Regenerate handoff"*)
    echo "📝 To regenerate handoff checkpoint:"
    echo ""
    echo "   /rptc:tdd \"@${PLAN_NAME}/\""
    echo ""
    echo "   This will resume TDD execution and create a fresh handoff when needed."
    echo ""
    exit 0
    ;;

  "Abort resume"*)
    echo "❌ Resume operation cancelled by user."
    echo ""
    exit 0
    ;;
esac

else
  # Handoff is fresh (<7 days), proceed normally
  echo "✓ Handoff is fresh (${HANDOFF_AGE_DAYS} days old)"
  echo ""
fi
```

**Resolution**: User chooses action via menu:
- **Proceed**: Overrides catch-up depth to "deep" for safety
- **Regenerate**: Exits with instructions to re-run TDD
- **Abort**: Exits gracefully

### Directory Format Mismatch

If user provides monolithic reference but directory exists:

```text
ℹ️  Plan Format Note

You provided: @plan-name.md (monolithic)
Found: ${ARTIFACT_LOC}/plans/plan-name/ (directory format)

Auto-correcting to directory format...
Checking for handoff checkpoint...
```

**Resolution**: Auto-detect and correct format reference.

## Success Criteria

- [ ] Plan format detected (directory or monolithic)
- [ ] Handoff checkpoint detected (if exists)
- [ ] Plan loaded and progress analyzed (handoff-aware)
- [ ] Appropriate catch-up command ran (adjusted for handoff mode)
- [ ] Related research loaded (if exists)
- [ ] Recent git activity reviewed
- [ ] Test status checked
- [ ] Clear next step identified (from handoff or plan)
- [ ] Configuration preserved (if handoff mode)
- [ ] Ready to continue with /rptc:tdd (with correct format reference)
- [ ] Edge cases handled gracefully (missing handoff, stale data, etc.)

---

_Remember: Context is key. This command ensures you're never lost when resuming work. Handoff checkpoints (v1.2.0+) provide superior context restoration when TDD pauses mid-execution._
