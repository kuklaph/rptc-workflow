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
  # Notify handoff detected (inline fail-safe)
  DISCORD_ENABLED=$(jq -r '.rptc.discord.notificationsEnabled // false' .claude/settings.json 2>/dev/null || echo "false")
  DISCORD_WEBHOOK=$(jq -r '.rptc.discord.webhookUrl // ""' .claude/settings.json 2>/dev/null || echo "")
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

```bash
# Extract key information from handoff.md
COMPLETED_STEP=$(grep "^\*\*Completed Steps\*\*:" "$HANDOFF_FILE" | sed 's/.*Steps 1-\([0-9]*\).*/\1/')
NEXT_STEP=$((COMPLETED_STEP + 1))

# Extract total steps by counting step files
TOTAL_STEPS=$(find "$PLAN_DIR" -name "step-*.md" | wc -l)

HANDOFF_REASON=$(grep "^\*\*Trigger Reason\*\*:" "$HANDOFF_FILE" | cut -d: -f2- | xargs)

echo "📖 Loading handoff state..."
echo ""
echo "   Completed: Steps 1-${COMPLETED_STEP}"
echo "   Next Step: ${NEXT_STEP}"
echo "   Remaining: $((TOTAL_STEPS - COMPLETED_STEP)) steps"
echo "   Reason: ${HANDOFF_REASON}"
echo ""
```

#### Step 1b: Restore Historical Usage Data

**Extract and restore STEP_CONTEXT_USAGE array:**

```bash
# Extract historical usage array from handoff.md
HISTORICAL_USAGE=$(sed -n '/STEP_CONTEXT_USAGE=/p' "$HANDOFF_FILE" | sed 's/STEP_CONTEXT_USAGE=//')

# Convert to array
declare -a STEP_CONTEXT_USAGE
eval "STEP_CONTEXT_USAGE=$HISTORICAL_USAGE"

echo "📊 Historical usage data restored:"
echo "   Data Points: ${#STEP_CONTEXT_USAGE[@]}"
if [ "${#STEP_CONTEXT_USAGE[@]}" -ge 3 ]; then
  echo "   Last 3 Steps:"
  echo "     Step $((${#STEP_CONTEXT_USAGE[@]} - 2)): ${STEP_CONTEXT_USAGE[-3]} tokens"
  echo "     Step $((${#STEP_CONTEXT_USAGE[@]} - 1)): ${STEP_CONTEXT_USAGE[-2]} tokens"
  echo "     Step ${#STEP_CONTEXT_USAGE[@]}:         ${STEP_CONTEXT_USAGE[-1]} tokens"
fi
echo ""
```

#### Step 1c: Restore Calibration Data

**Extract and restore prediction calibration:**

```bash
# Extract calibration multiplier
CALIBRATION_MULTIPLIER=$(sed -n '/CALIBRATION_MULTIPLIER=/p' "$HANDOFF_FILE" | awk -F'=' '{print $2}')

echo "🎯 Calibration restored:"
echo "   Multiplier: ${CALIBRATION_MULTIPLIER}×"
echo ""

# Extract prediction errors array
PREDICTION_ERRORS_STR=$(sed -n '/PREDICTION_ERRORS=/p' "$HANDOFF_FILE" | sed 's/PREDICTION_ERRORS=//')
declare -a PREDICTION_ERRORS
eval "PREDICTION_ERRORS=$PREDICTION_ERRORS_STR"

echo "   Prediction Errors: ${#PREDICTION_ERRORS[@]}" data points"
if [ "${#PREDICTION_ERRORS[@]}" -gt 0 ]; then
  # Calculate average error
  ERROR_SUM=0
  for error in "${PREDICTION_ERRORS[@]}"; do
    ERROR_SUM=$(awk "BEGIN {printf \"%.1f\", $ERROR_SUM + $error}")
  done
  AVG_ERROR=$(awk "BEGIN {printf \"%.1f\", $ERROR_SUM / ${#PREDICTION_ERRORS[@]}}")
  echo "   Average Error: ${AVG_ERROR}%"
fi
echo ""
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
# Notify resume complete (inline fail-safe)
DISCORD_ENABLED=$(jq -r '.rptc.discord.notificationsEnabled // false' .claude/settings.json 2>/dev/null || echo "false")
DISCORD_WEBHOOK=$(jq -r '.rptc.discord.webhookUrl // ""' .claude/settings.json 2>/dev/null || echo "")
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

If handoff.md is >7 days old:

```text
⚠️  Stale Handoff Checkpoint Detected

Handoff created: [X] days ago
Recommendation: Deep catch-up for safety

The codebase may have changed significantly since checkpoint.
Upgrading catch-up depth: Quick → Deep

Reason: Long gap may cause context drift
```

**Resolution**: Override catch-up depth to "deep" regardless of handoff presence.

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
