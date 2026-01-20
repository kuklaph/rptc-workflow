---
description: Recursively sync tests to production code with auto-fix and convergence verification
---

# RPTC: Sync Tests

**You are the test synchronization orchestrator, ensuring all tests match production code.**
The user is the **project manager** - they approve major decisions and final completion.

**Arguments:**
- `[directory]` - Target directory to sync (optional, prompts if not provided)
- `--dry-run` - Analyze only, don't make changes
- `--max-iterations N` - Override max convergence iterations (default: 10)

**Examples:**
```bash
/rptc:sync-tests "src/"
/rptc:sync-tests "src/auth/" --dry-run
/rptc:sync-tests --max-iterations 5
```

---

## Core Mission

Ensure all production code has synchronized tests by:
1. **Discovering** all production and test files
2. **Matching** tests to production using multi-layer confidence scoring
3. **Verifying** synchronization across 4 levels (structural, behavioral, assertion, intent)
4. **Auto-fixing** mismatches (update, add, create tests)
5. **Iterating** until ALL areas report full synchronization

**Key Principle:** Production code is truth. Tests adapt to production, never vice versa.

---

## Step 0: Configuration & Validation

### Step 0a: Load Configuration

**Load RPTC configuration from `.claude/settings.json`:**

1. **Check if settings file exists:**
   - Use Read tool to read `.claude/settings.json`
   - If file doesn't exist or can't be read, use defaults (skip to step 3)

2. **Parse configuration** (extract these fields):
   - `rptc.defaultThinkingMode` → THINKING_MODE (default: "think")
   - `rptc.artifactLocation` → ARTIFACT_LOC (default: ".rptc")
   - `rptc.testCoverageTarget` → COVERAGE_TARGET (default: 85)
   - `rptc.syncTests.autoFix` → AUTO_FIX (default: true)
   - `rptc.syncTests.createMissing` → CREATE_MISSING (default: true)
   - `rptc.syncTests.maxIterations` → MAX_ITERATIONS (default: 10)
   - `rptc.syncTests.confidenceThreshold` → CONFIDENCE_THRESHOLD (default: 50)
   - `rptc.discord.notificationsEnabled` → DISCORD_ENABLED (default: false)
   - `rptc.discord.webhookUrl` → DISCORD_WEBHOOK (default: "")

3. **Display loaded configuration:**
   ```text
   Configuration loaded:
     Thinking mode: [THINKING_MODE]
     Coverage target: [COVERAGE_TARGET]%
     Auto-fix: [AUTO_FIX]
     Create missing: [CREATE_MISSING]
     Max iterations: [MAX_ITERATIONS]
     Confidence threshold: [CONFIDENCE_THRESHOLD]
   ```

**Use these values throughout command execution.**

### Step 0b: Parse Arguments

```bash
# Initialize variables
TARGET_DIR=""
DRY_RUN=false
MAX_ITER_OVERRIDE=""

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    --max-iterations)
      # Next arg is the value
      EXPECT_VALUE="max-iterations"
      ;;
    *)
      if [ "$EXPECT_VALUE" = "max-iterations" ]; then
        MAX_ITER_OVERRIDE="$arg"
        EXPECT_VALUE=""
      elif [ -z "$TARGET_DIR" ]; then
        TARGET_DIR="$arg"
      fi
      ;;
  esac
done

# Apply override if provided
if [ -n "$MAX_ITER_OVERRIDE" ]; then
  MAX_ITERATIONS="$MAX_ITER_OVERRIDE"
fi
```

### Step 0c: Get Directory (if not provided)

If `TARGET_DIR` is empty, prompt user:

Use the AskUserQuestion tool:

```markdown
AskUserQuestion(
  questions: [{
    question: "Which directory should be analyzed for test synchronization?",
    header: "Directory",
    multiSelect: false,
    options: [
      {
        label: "src/",
        description: "Standard source directory"
      },
      {
        label: "lib/",
        description: "Library source directory"
      },
      {
        label: "Current directory",
        description: "Analyze entire project root"
      }
    ]
  }]
)
```

**Process response:**
- If "src/" selected → `TARGET_DIR="src/"`
- If "lib/" selected → `TARGET_DIR="lib/"`
- If "Current directory" selected → `TARGET_DIR="."`
- If "Other" selected → Use provided custom path

### Step 0d: Validate Directory

```bash
# Check directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ Error: Directory not found: $TARGET_DIR"
  echo ""
  echo "Please check the path and try again."
  exit 1
fi

# Check directory is readable
if [ ! -r "$TARGET_DIR" ]; then
  echo "❌ Error: Directory not readable: $TARGET_DIR"
  exit 1
fi

echo "✅ Target directory validated: $TARGET_DIR"
```

### Step 0e: Detect MCP Availability

**Check for Sequential Thinking MCP (both Docker and non-Docker):**

```bash
# Check for available MCP tools
SEQUENTIAL_THINKING_AVAILABLE=false
SEQUENTIAL_THINKING_TOOL=""

# Check Docker version
if tool_exists "mcp__MCP_DOCKER__sequentialthinking"; then
  SEQUENTIAL_THINKING_AVAILABLE=true
  SEQUENTIAL_THINKING_TOOL="mcp__MCP_DOCKER__sequentialthinking"
  echo "✅ Sequential Thinking MCP detected (Docker)"
fi

# Check non-Docker version patterns
if tool_exists "mcp__sequentialthinking__*"; then
  SEQUENTIAL_THINKING_AVAILABLE=true
  SEQUENTIAL_THINKING_TOOL="mcp__sequentialthinking"
  echo "✅ Sequential Thinking MCP detected"
fi
```

**Check for Serena MCP (both Docker and non-Docker):**

```bash
SERENA_AVAILABLE=false
SERENA_TOOL_PREFIX=""

# Check for Serena tools
if tool_exists "mcp__serena__activate_project"; then
  SERENA_AVAILABLE=true
  SERENA_TOOL_PREFIX="mcp__serena__"
  echo "✅ Serena MCP detected"
fi
```

**Display MCP status:**

```text
MCP Integration Status:
  Sequential Thinking: [Available/Not available]
  Serena: [Available/Not available]

[If both unavailable:]
Note: Proceeding with standard analysis (MCPs enhance but aren't required)
```

### Step 0f: Initialize TodoWrite

```json
{
  "tool": "TodoWrite",
  "todos": [
    {
      "content": "Sync tests for ${TARGET_DIR}",
      "status": "in_progress",
      "activeForm": "Syncing tests for ${TARGET_DIR}"
    },
    {
      "content": "Phase 1: Discover files",
      "status": "pending",
      "activeForm": "Discovering files"
    },
    {
      "content": "Phase 2: Analyze sync status",
      "status": "pending",
      "activeForm": "Analyzing sync status"
    },
    {
      "content": "Phase 3: Apply fixes",
      "status": "pending",
      "activeForm": "Applying fixes"
    },
    {
      "content": "Phase 4: Verify convergence",
      "status": "pending",
      "activeForm": "Verifying convergence"
    },
    {
      "content": "Phase 5: Generate report",
      "status": "pending",
      "activeForm": "Generating report"
    }
  ]
}
```

---

## Phase 1: Directory Discovery

**Update TodoWrite:** Mark "Phase 1: Discover files" as `in_progress`

### Step 1a: Detect Test Framework

```bash
# Check for framework configuration files
FRAMEWORK="unknown"

[ -f "jest.config.js" ] || [ -f "jest.config.ts" ] && FRAMEWORK="jest"
[ -f "vitest.config.js" ] || [ -f "vitest.config.ts" ] && FRAMEWORK="vitest"
[ -f "pytest.ini" ] || [ -f "pyproject.toml" ] && FRAMEWORK="pytest"
[ -f "go.mod" ] && FRAMEWORK="go"
[ -f "pom.xml" ] || [ -f "build.gradle" ] && FRAMEWORK="junit"

echo "Detected test framework: $FRAMEWORK"
```

### Step 1b: Discover Production Files

Use Glob tool to find production code:

```bash
# Language-specific patterns
Glob(pattern="${TARGET_DIR}/**/*.{ts,tsx,js,jsx}")  # TypeScript/JavaScript
Glob(pattern="${TARGET_DIR}/**/*.py")                # Python
Glob(pattern="${TARGET_DIR}/**/*.go")                # Go
Glob(pattern="${TARGET_DIR}/**/*.java")              # Java

# Exclude patterns (filter results):
# - **/node_modules/**
# - **/vendor/**
# - **/.git/**
# - **/dist/**
# - **/build/**
# - **/generated/**
# - **/*.test.* , **/*.spec.* , **/test_* , **/*_test.*
```

Store results in `PRODUCTION_FILES` list.

### Step 1c: Discover Test Files

Use Glob tool to find test files:

```bash
# Test file patterns by framework
case $FRAMEWORK in
  jest|vitest)
    Glob(pattern="**/*.test.{ts,tsx,js,jsx}")
    Glob(pattern="**/*.spec.{ts,tsx,js,jsx}")
    Glob(pattern="**/__tests__/**/*.{ts,tsx,js,jsx}")
    ;;
  pytest)
    Glob(pattern="**/test_*.py")
    Glob(pattern="**/*_test.py")
    ;;
  go)
    Glob(pattern="**/*_test.go")
    ;;
  junit)
    Glob(pattern="**/src/test/**/*Test.java")
    ;;
esac
```

Store results in `TEST_FILES` list.

### Step 1d: Identify Subdirectories

```bash
# Group files by subdirectory for staged analysis
SUBDIRECTORIES=$(echo "$PRODUCTION_FILES" | xargs -n1 dirname | sort -u)

# Count files per subdirectory
for SUBDIR in $SUBDIRECTORIES; do
  FILE_COUNT=$(echo "$PRODUCTION_FILES" | grep "^${SUBDIR}/" | wc -l)
  echo "  $SUBDIR: $FILE_COUNT production files"
done
```

### Step 1e: Update TodoWrite with Discovered Areas

Dynamically add tasks for each subdirectory:

```json
{
  "tool": "TodoWrite",
  "todos": [
    // ... existing todos ...
    {
      "content": "Analyze ${SUBDIR_1}",
      "status": "pending",
      "activeForm": "Analyzing ${SUBDIR_1}"
    },
    {
      "content": "Analyze ${SUBDIR_2}",
      "status": "pending",
      "activeForm": "Analyzing ${SUBDIR_2}"
    }
    // ... for each subdirectory
  ]
}
```

**Display discovery summary:**

```text
═══════════════════════════════════════════════════════
  DISCOVERY COMPLETE
═══════════════════════════════════════════════════════

Directory: ${TARGET_DIR}
Framework: ${FRAMEWORK}

Production files found: [N]
Test files found: [M]
Subdirectories to analyze: [K]

Subdirectory breakdown:
  src/auth/: 5 files
  src/utils/: 8 files
  src/api/: 12 files
  ...

═══════════════════════════════════════════════════════
```

**Update TodoWrite:** Mark "Phase 1: Discover files" as `completed`

---

## Phase 2: Analysis Loop

**Update TodoWrite:** Mark "Phase 2: Analyze sync status" as `in_progress`

### Step 2a: Initialize Convergence Tracking

```bash
ITERATION=0
CONVERGED=false
declare -A AREA_STATUS  # Track status per subdirectory
```

### Step 2b: Delegate Analysis to Sync Agent

For each subdirectory, delegate to the sync agent:

```markdown
Use the Task tool with subagent_type="rptc:master-test-sync-agent":

**Prompt:**

## Analysis Context

**Directory to analyze:** ${SUBDIR}
**Test framework:** ${FRAMEWORK}
**Coverage target:** ${COVERAGE_TARGET}%
**Confidence threshold:** ${CONFIDENCE_THRESHOLD}

## Production Files in This Area
[List of production files in this subdirectory]

## Test Files Candidates
[List of test files that might match]

## MCP Availability
- Sequential Thinking: ${SEQUENTIAL_THINKING_AVAILABLE} (tool: ${SEQUENTIAL_THINKING_TOOL})
- Serena: ${SERENA_AVAILABLE} (prefix: ${SERENA_TOOL_PREFIX})

## SOPs to Reference (fallback chain)
1. .rptc/sop/test-sync-guide.md
2. ~/.claude/global/sop/test-sync-guide.md
3. ${CLAUDE_PLUGIN_ROOT}/sop/test-sync-guide.md

## Your Task
1. Match test files to production files using 5-layer confidence scoring
2. Verify sync status for each matched pair (4 levels)
3. Identify mismatches, missing tests, orphaned tests
4. Return structured JSON report

## Output Format
Return JSON with: synced, mismatches, missingTests, orphanedTests, actionRequired
```

### Step 2c: Process Sync Agent Results

```bash
# Parse agent output
SYNC_RESULT=$(parse_json "$AGENT_OUTPUT")

# Extract key metrics
SYNCED_COUNT=$(jq '.synced | length' <<< "$SYNC_RESULT")
MISMATCH_COUNT=$(jq '.mismatches | length' <<< "$SYNC_RESULT")
MISSING_COUNT=$(jq '.missingTests | length' <<< "$SYNC_RESULT")
ORPHANED_COUNT=$(jq '.orphanedTests | length' <<< "$SYNC_RESULT")
ACTION_REQUIRED=$(jq -r '.actionRequired' <<< "$SYNC_RESULT")

# Update area status
AREA_STATUS["$SUBDIR"]="$ACTION_REQUIRED"

# Display progress
echo "  $SUBDIR: Synced=$SYNCED_COUNT, Mismatches=$MISMATCH_COUNT, Missing=$MISSING_COUNT"
```

### Step 2d: Update TodoWrite with Findings

For each area with issues, add specific fix tasks:

```json
{
  "tool": "TodoWrite",
  "todos": [
    // Update area analysis task
    {
      "content": "Analyze ${SUBDIR}",
      "status": "completed",
      "activeForm": "Analyzing ${SUBDIR}"
    },
    // Add fix tasks for mismatches
    {
      "content": "Fix ${MISMATCH_FILE} tests",
      "status": "pending",
      "activeForm": "Fixing ${MISMATCH_FILE} tests"
    },
    // Add create tasks for missing
    {
      "content": "Create tests for ${MISSING_FILE}",
      "status": "pending",
      "activeForm": "Creating tests for ${MISSING_FILE}"
    }
  ]
}
```

**Update TodoWrite:** Mark "Phase 2: Analyze sync status" as `completed`

---

## Phase 3: Auto-Fix Execution

**Skip if `--dry-run` flag is set:**

```bash
if [ "$DRY_RUN" = true ]; then
  echo "🔍 Dry run mode - skipping fixes"
  echo ""
  echo "Issues found that would be fixed:"
  # Display summary of what would be fixed
  goto Phase 5
fi
```

**Update TodoWrite:** Mark "Phase 3: Apply fixes" as `in_progress`

### Step 3a: Confirm Fix Execution

Use AskUserQuestion tool:

```markdown
AskUserQuestion(
  questions: [{
    question: "Found [N] issues to fix. Proceed with auto-fix?",
    header: "Fix",
    multiSelect: false,
    options: [
      {
        label: "Yes, fix all",
        description: "Auto-fix all [N] issues (recommended)"
      },
      {
        label: "Review first",
        description: "Show detailed breakdown before fixing"
      },
      {
        label: "Skip",
        description: "Generate report only, don't fix"
      }
    ]
  }]
)
```

**Process response:**
- "Yes, fix all" → Proceed to Step 3b
- "Review first" → Display detailed breakdown, then re-ask
- "Skip" → Skip to Phase 5

### Step 3b: Delegate Fixes to Fixer Agent

For each area with `actionRequired=true`:

```markdown
Use the Task tool with subagent_type="rptc:master-test-fixer-agent":

**Prompt:**

## Fix Context

**Iteration:** ${ITERATION} of ${MAX_ITERATIONS}
**Thinking mode:** ${THINKING_MODE}
**Test framework:** ${FRAMEWORK}
**Coverage target:** ${COVERAGE_TARGET}%

## Sync Report for This Area
[Insert sync agent output for this area]

## Mismatches to Fix
[List from sync report]

## Missing Tests to Create
[List from sync report]

## MCP Availability
- Sequential Thinking: ${SEQUENTIAL_THINKING_AVAILABLE} (tool: ${SEQUENTIAL_THINKING_TOOL})
- Serena: ${SERENA_AVAILABLE} (prefix: ${SERENA_TOOL_PREFIX})

## SOPs to Reference
1. .rptc/sop/testing-guide.md
2. .rptc/sop/test-sync-guide.md
3. ~/.claude/global/sop/testing-guide.md
4. ${CLAUDE_PLUGIN_ROOT}/sop/testing-guide.md

## Your Task
1. Apply appropriate fix scenario for each issue (A: Update, B: Add, C: Fix assertions, D: Create)
2. Delegate test generation to master-tdd-executor-agent where appropriate
3. Verify all fixes by running tests
4. Return structured result with success/failure per file

## Constraints
- Auto-fix: ${AUTO_FIX}
- Create missing: ${CREATE_MISSING}
- Max retry attempts per file: 3
```

### Step 3c: Process Fixer Results

```bash
# Parse fixer output
FIX_RESULT=$(parse_json "$FIXER_OUTPUT")

# Extract metrics
UPDATED_COUNT=$(jq '.updated | length' <<< "$FIX_RESULT")
CREATED_COUNT=$(jq '.created | length' <<< "$FIX_RESULT")
FAILED_COUNT=$(jq '.failed | length' <<< "$FIX_RESULT")

# Update cumulative tracking
TOTAL_UPDATED=$((TOTAL_UPDATED + UPDATED_COUNT))
TOTAL_CREATED=$((TOTAL_CREATED + CREATED_COUNT))
TOTAL_FAILED=$((TOTAL_FAILED + FAILED_COUNT))

echo "  Fixes applied: Updated=$UPDATED_COUNT, Created=$CREATED_COUNT, Failed=$FAILED_COUNT"
```

### Step 3d: Update TodoWrite with Fix Progress

```json
{
  "tool": "TodoWrite",
  "todos": [
    // Mark individual fix tasks as completed
    {
      "content": "Fix ${MISMATCH_FILE} tests",
      "status": "completed",
      "activeForm": "Fixing ${MISMATCH_FILE} tests"
    }
  ]
}
```

**Update TodoWrite:** Mark "Phase 3: Apply fixes" as `completed`

---

## Phase 4: Verification Loop

**Update TodoWrite:** Mark "Phase 4: Verify convergence" as `in_progress`

### Step 4a: Re-run Sync Analysis

Repeat Phase 2 analysis on all areas:

```markdown
# For each subdirectory, re-delegate to sync agent
# (Same prompt as Step 2b, but with iteration context)

**Additional context:**
Iteration: ${ITERATION} (verification pass)
Previous issues: [summary from fixer results]
```

### Step 4b: Check Convergence

```bash
# Check if ALL areas report actionRequired=false
ALL_SYNCED=true

for SUBDIR in "${!AREA_STATUS[@]}"; do
  if [ "${AREA_STATUS[$SUBDIR]}" = "true" ]; then
    ALL_SYNCED=false
    echo "  ⚠️  $SUBDIR still needs fixes"
  else
    echo "  ✅ $SUBDIR fully synced"
  fi
done

if [ "$ALL_SYNCED" = true ]; then
  CONVERGED=true
  echo ""
  echo "✅ CONVERGENCE ACHIEVED - All areas synced!"
fi
```

### Step 4c: Loop or Complete

```bash
if [ "$CONVERGED" = true ]; then
  echo "Proceeding to report generation..."
  goto Phase 5
fi

ITERATION=$((ITERATION + 1))

if [ $ITERATION -ge $MAX_ITERATIONS ]; then
  echo ""
  echo "⚠️  Max iterations ($MAX_ITERATIONS) reached"
  echo "Some issues require manual review."
  goto Phase 5
fi

echo ""
echo "Starting iteration $ITERATION..."
goto Phase 2  # Re-analyze and fix
```

**Update TodoWrite:** Mark "Phase 4: Verify convergence" as `completed`

---

## Phase 5: Completion Report

**Update TodoWrite:** Mark "Phase 5: Generate report" as `in_progress`

### Step 5a: Generate Report File

```bash
REPORT_FILE="${ARTIFACT_LOC}/reports/test-sync-$(date +%Y%m%d-%H%M%S).md"
mkdir -p "${ARTIFACT_LOC}/reports"
```

Generate report content:

```markdown
# Test Sync Report

**Generated:** [timestamp]
**Directory:** ${TARGET_DIR}
**Framework:** ${FRAMEWORK}
**Iterations:** ${ITERATION}
**Status:** [CONVERGED/PARTIAL/FAILED]

---

## Summary

| Metric | Before | After |
|--------|--------|-------|
| Files Analyzed | [N] | [N] |
| Test Coverage | [X]% | [Y]% |
| Synced Files | [A] | [B] |
| Issues Remaining | [C] | [D] |

---

## Fixes Applied

### Tests Updated ([count])
[List of updated test files with change descriptions]

### Tests Created ([count])
[List of new test files with coverage metrics]

### Manual Review Required ([count])
[List of files that couldn't be auto-fixed with reasons]

---

## Convergence Status

[If CONVERGED:]
✅ All production files have synchronized tests
✅ All tests pass
✅ Coverage target (${COVERAGE_TARGET}%) met

[If NOT CONVERGED:]
⚠️ Some issues require manual attention:
[List remaining issues]

---

## Next Steps

[Contextual recommendations based on results]

---

## Configuration Used

- Coverage target: ${COVERAGE_TARGET}%
- Auto-fix: ${AUTO_FIX}
- Create missing: ${CREATE_MISSING}
- Max iterations: ${MAX_ITERATIONS}
- Confidence threshold: ${CONFIDENCE_THRESHOLD}
```

### Step 5b: Write Report

```bash
Write(file_path="$REPORT_FILE", content="$REPORT_CONTENT")
echo "📄 Report saved: $REPORT_FILE"
```

### Step 5c: Display Summary

```text
═══════════════════════════════════════════════════════
  TEST SYNC COMPLETE
═══════════════════════════════════════════════════════

Directory: ${TARGET_DIR}
Status: [CONVERGED ✅ / PARTIAL ⚠️ / FAILED ❌]
Iterations: ${ITERATION}

Results:
  - Files analyzed: [N]
  - Tests updated: [X]
  - Tests created: [Y]
  - Manual review: [Z]

Coverage: [before]% → [after]%

Report saved: ${REPORT_FILE}

[If issues remain:]
⚠️  Some issues require manual review. See report for details.

═══════════════════════════════════════════════════════
```

### Step 5d: Final TodoWrite Update

```json
{
  "tool": "TodoWrite",
  "todos": [
    {
      "content": "Sync tests for ${TARGET_DIR}",
      "status": "completed",
      "activeForm": "Syncing tests for ${TARGET_DIR}"
    },
    {
      "content": "Phase 1: Discover files",
      "status": "completed",
      "activeForm": "Discovering files"
    },
    {
      "content": "Phase 2: Analyze sync status",
      "status": "completed",
      "activeForm": "Analyzing sync status"
    },
    {
      "content": "Phase 3: Apply fixes",
      "status": "completed",
      "activeForm": "Applying fixes"
    },
    {
      "content": "Phase 4: Verify convergence",
      "status": "completed",
      "activeForm": "Verifying convergence"
    },
    {
      "content": "Phase 5: Generate report",
      "status": "completed",
      "activeForm": "Generating report"
    }
  ]
}
```

---

## Error Handling

### Agent Failure

```bash
if [ $? -ne 0 ]; then
  echo "❌ Agent failed: $AGENT_TYPE"
  echo "Error: $AGENT_ERROR"
  echo ""
  echo "Options:"
  echo "  1. Retry with same parameters"
  echo "  2. Skip this area and continue"
  echo "  3. Abort sync-tests"
  # Use AskUserQuestion to get user decision
fi
```

### Test Execution Failure

```bash
if [ "$TEST_PASS" = false ]; then
  echo "⚠️  Tests failing after fix attempt"
  if [ $RETRY_COUNT -lt 3 ]; then
    echo "Retrying with failure context..."
    # Include failure details in next fix attempt
  else
    echo "Max retries reached - marking for manual review"
  fi
fi
```

### Max Iterations Exceeded

```bash
if [ $ITERATION -ge $MAX_ITERATIONS ]; then
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  ⚠️  CONVERGENCE NOT ACHIEVED"
  echo "════════════════════════════════════════════════════════"
  echo ""
  echo "After $MAX_ITERATIONS iterations, some issues remain:"
  echo ""
  for SUBDIR in "${!AREA_STATUS[@]}"; do
    if [ "${AREA_STATUS[$SUBDIR]}" = "true" ]; then
      echo "  - $SUBDIR"
    fi
  done
  echo ""
  echo "These require manual review. See report for details."
  echo ""
fi
```

---

## Important Notes

- **Production code is never modified** - only test files are changed
- **Convergence loop prevents incomplete sync** - continues until all areas report success
- **MCP integration is optional** - command works without, MCPs enhance analysis
- **TodoWrite provides visibility** - user can track progress in real-time
- **Dry-run mode available** - analyze without making changes
- **Report preserves history** - timestamped reports for audit trail
