---
description: Recursively sync tests to production code with auto-fix and convergence verification
---

# RPTC: Sync Prod to Tests

**You are the test synchronization orchestrator, ensuring all tests match production code.**
The user is the **project manager** - they approve major decisions and final completion.

**Arguments:**
- `[directory]` - Target directory to sync (optional, prompts if not provided)
- `--dry-run` - Analyze only, don't make changes
- `--max-iterations N` - Override max convergence iterations (default: 10)

**Examples:**
```bash
/rptc:sync-prod-to-tests "src/"
/rptc:sync-prod-to-tests "src/auth/" --dry-run
/rptc:sync-prod-to-tests --max-iterations 5
```

---

## Core Mission

Ensure all production code has synchronized tests by:
1. **Discovering** all production and test files
2. **Matching** tests to production using multi-layer confidence scoring
3. **Verifying** synchronization across 4 levels (structural, behavioral, assertion, intent)
4. **Auto-fixing** mismatches (update, add, create tests)
5. **Iterating** until ALL areas report full synchronization

**Key Principle:** Production code is the source of truth. Tests adapt to production. However, if analysis reveals production code bugs (tests correctly failing), **PM approval is required** before modifying production code.

---

## ⚠️ CRITICAL: Broken Tests MUST Be Fixed

**This command does NOT skip broken tests.** Every failing test must either:
1. Be fixed to match production behavior (test was wrong)
2. Trigger a production fix request with PM approval (production was wrong)
3. Be explicitly marked for manual review with documented reason

**The sync loop continues until ALL tests pass, not just coverage targets.**

---

## ⚠️ CRITICAL: Sub-Agent Delegation Required

**This command REQUIRES delegation to specialist sub-agents via the Task tool.**

**YOU ARE THE ORCHESTRATOR, NOT THE EXECUTOR.**

Your role is to:
- ✅ Discover files and directories (Phase 1)
- ✅ Track progress with TodoWrite
- ✅ **Delegate analysis to `rptc:master-test-sync-agent`** (Phase 2)
- ✅ Obtain PM approval for production changes (Phase 3)
- ✅ **Delegate fixes to `rptc:master-test-fixer-agent`** (Phase 4)
- ✅ Check convergence based on agent results (Phase 5)
- ✅ **Verify all tests pass** (Phase 6)
- ✅ Generate final report with audit trail (Phase 7)

**DO NOT in main context:**
- ❌ Read production or test file contents
- ❌ Analyze code for test matching
- ❌ Write or edit test files
- ❌ Run test commands
- ❌ Attempt sync verification logic

**All analysis and fixing work MUST be delegated to sub-agents using the Task tool.**

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

Examine the available tools in your context to determine MCP availability:

1. **Sequential Thinking MCP:**
   - Look for `mcp__MCP_DOCKER__sequentialthinking` (Docker version)
   - Look for `mcp__sequentialthinking__sequentialthinking` (non-Docker version)
   - Set `SEQUENTIAL_THINKING_AVAILABLE=true` if either tool is present
   - Set `SEQUENTIAL_THINKING_TOOL` to the available tool name

2. **Serena MCP:**
   - Look for `mcp__serena__activate_project` and related tools
   - Set `SERENA_AVAILABLE=true` if Serena tools are present
   - Set `SERENA_TOOL_PREFIX="mcp__serena__"`

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
      "content": "Phase 3: PM approval gateway",
      "status": "pending",
      "activeForm": "Processing PM approval"
    },
    {
      "content": "Phase 4: Apply fixes",
      "status": "pending",
      "activeForm": "Applying fixes"
    },
    {
      "content": "Phase 5: Verify convergence",
      "status": "pending",
      "activeForm": "Verifying convergence"
    },
    {
      "content": "Phase 6: Test suite verification",
      "status": "pending",
      "activeForm": "Verifying all tests pass"
    },
    {
      "content": "Phase 7: Generate report",
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

### Step 1a.1: Detect Available Testing Tools

**CRITICAL: Detect ALL available testing tools to inform context-aware test generation.**

Use Grep tool to check package.json, pyproject.toml, or equivalent:

```bash
# Initialize capabilities
TESTING_TOOLS=()

# JavaScript/TypeScript ecosystem
if [ -f "package.json" ]; then
  grep -q '"@playwright/test"' package.json && TESTING_TOOLS+=("playwright")
  grep -q '"cypress"' package.json && TESTING_TOOLS+=("cypress")
  grep -q '"@testing-library/react"' package.json && TESTING_TOOLS+=("rtl")
  grep -q '"@testing-library/vue"' package.json && TESTING_TOOLS+=("vtl")
  grep -q '"supertest"' package.json && TESTING_TOOLS+=("supertest")
  grep -q '"msw"' package.json && TESTING_TOOLS+=("msw")
  grep -q '"nock"' package.json && TESTING_TOOLS+=("nock")
  grep -q '"jsdom"' package.json && TESTING_TOOLS+=("jsdom")
  grep -q '"happy-dom"' package.json && TESTING_TOOLS+=("happy-dom")
fi

# Python ecosystem
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
  grep -q 'playwright' pyproject.toml requirements.txt 2>/dev/null && TESTING_TOOLS+=("playwright-py")
  grep -q 'pytest-asyncio' pyproject.toml requirements.txt 2>/dev/null && TESTING_TOOLS+=("pytest-asyncio")
  grep -q 'httpx' pyproject.toml requirements.txt 2>/dev/null && TESTING_TOOLS+=("httpx")
  grep -q 'responses' pyproject.toml requirements.txt 2>/dev/null && TESTING_TOOLS+=("responses")
fi

# Determine testing capabilities
HAS_E2E=$(echo "${TESTING_TOOLS[@]}" | grep -qE "playwright|cypress" && echo "true" || echo "false")
HAS_COMPONENT=$(echo "${TESTING_TOOLS[@]}" | grep -qE "rtl|vtl" && echo "true" || echo "false")
HAS_API_TESTING=$(echo "${TESTING_TOOLS[@]}" | grep -qE "supertest|httpx" && echo "true" || echo "false")
HAS_MOCKING=$(echo "${TESTING_TOOLS[@]}" | grep -qE "msw|nock|responses" && echo "true" || echo "false")
HAS_DOM_MOCK=$(echo "${TESTING_TOOLS[@]}" | grep -qE "jsdom|happy-dom" && echo "true" || echo "false")
```

**Display detected capabilities:**

```text
Testing Tools Detected:
  Framework: ${FRAMEWORK}
  Tools: ${TESTING_TOOLS[@]}

Testing Capabilities:
  E2E Testing (Playwright/Cypress): ${HAS_E2E}
  Component Testing (RTL/VTL): ${HAS_COMPONENT}
  API Testing (Supertest/httpx): ${HAS_API_TESTING}
  HTTP Mocking (MSW/nock): ${HAS_MOCKING}
  DOM Simulation (jsdom): ${HAS_DOM_MOCK}

[If HAS_E2E=false and frontend code exists:]
⚠️  WARNING: No E2E test runner detected. Browser-dependent code may require Playwright setup.
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

**⚠️ CRITICAL: MANDATORY SUB-AGENT DELEGATION**

**YOU MUST delegate analysis to `rptc:master-test-sync-agent` using the Task tool.**

**YOU MUST NOT:**
- ❌ Read production file contents in main context
- ❌ Read test file contents in main context
- ❌ Analyze code for test matching in main context
- ❌ Calculate confidence scores in main context
- ❌ Attempt any sync verification logic in main context

**VIOLATION OF THESE RULES BREAKS THE WORKFLOW.**

If you find yourself reading file contents or analyzing code, STOP IMMEDIATELY and use the Task tool delegation below instead.

---

**For EACH subdirectory in SUBDIRECTORIES, execute this delegation:**

Use the Task tool with subagent_type="rptc:master-test-sync-agent":

Prompt:
## Analysis Context

**Directory to analyze:** ${SUBDIR}
**Test framework:** ${FRAMEWORK}
**Coverage target:** ${COVERAGE_TARGET}%
**Confidence threshold:** ${CONFIDENCE_THRESHOLD}

## Production Files in This Area
[List of production files in this subdirectory]

## Test Files Candidates
[List of test files that might match]

## Available Testing Tools & Capabilities
**Tools installed:** ${TESTING_TOOLS[@]}
**Capabilities:**
- E2E Testing (Playwright/Cypress): ${HAS_E2E}
- Component Testing (RTL/VTL): ${HAS_COMPONENT}
- API Testing (Supertest/httpx): ${HAS_API_TESTING}
- HTTP Mocking (MSW/nock): ${HAS_MOCKING}
- DOM Simulation (jsdom): ${HAS_DOM_MOCK}

## CRITICAL: Code Context Detection Required

For EACH production file, you MUST detect its code context:
- **Frontend UI**: React/Vue/Angular components, JSX/TSX, DOM manipulation
- **Backend API**: Express/Fastify routes, HTTP handlers, middleware
- **Database/ORM**: Prisma/Sequelize/TypeORM, SQL queries
- **Pure Utilities**: No I/O, no side effects, pure functions
- **Browser-Dependent**: window/document access, localStorage, cookies
- **External Services**: API calls, webhooks, third-party SDKs

Include detected context in your output for each file so the fixer agent knows the appropriate testing strategy.

**IMPORTANT:** If browser-dependent code is found and HAS_E2E=false, flag it as requiring Playwright setup.

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

---

**VALIDATION CHECKPOINT:** Verify the Task tool was invoked and returned results before proceeding. If no Task tool result exists, STOP and re-execute the delegation above.

### Step 2c: Process Sync Agent Results

```bash
# Parse agent output
SYNC_RESULT=$(parse_json "$AGENT_OUTPUT")

# VALIDATION: Check that codeContext is present for all files
# This is REQUIRED - reject results that don't include it
MISSING_CONTEXT_COUNT=$(jq '[.synced[], .mismatches[], .missingTests[] | select(.codeContext == null or .codeContext == "")] | length' <<< "$SYNC_RESULT")

if [ "$MISSING_CONTEXT_COUNT" -gt 0 ]; then
  echo "❌ ERROR: Sync agent output missing required 'codeContext' field for $MISSING_CONTEXT_COUNT files"
  echo "Re-delegating with explicit codeContext requirement..."
  # Re-run Step 2b delegation with emphasis on codeContext
  continue
fi

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

## Phase 3: PM Approval Gateway (Production Changes)

**Purpose**: Request explicit PM approval for any production code modifications before execution.

### Step 3a: Check if PM Approval Required

```bash
# Check if any issues require production changes
REQUIRES_PM_APPROVAL=$(jq -r '.summary.requiresPmApproval // false' <<< "$SYNC_RESULT")
PRODUCTION_BUG_COUNT=$(jq -r '.summary.productionBugs // 0' <<< "$SYNC_RESULT")
AMBIGUOUS_COUNT=$(jq -r '.summary.ambiguous // 0' <<< "$SYNC_RESULT")

if [ "$REQUIRES_PM_APPROVAL" = "false" ] && [ "$PRODUCTION_BUG_COUNT" -eq 0 ]; then
  echo "✓ No production changes detected, proceeding to fix phase"
  # Skip to Phase 4
else
  echo "⚠️  ${PRODUCTION_BUG_COUNT} production bug(s) detected requiring PM approval"
  # Continue to Step 3b
fi
```

### Step 3b: Extract Production Change Requests

```bash
# Extract issues classified as production_bug or ambiguous
PRODUCTION_ISSUES=$(jq '[.mismatches[] | select(.classification == "production_bug" or .classification == "ambiguous")]' <<< "$SYNC_RESULT")
```

### Step 3c: Present Evidence to PM

**Generate human-readable approval request and present to user:**

```markdown
═══════════════════════════════════════════════════════
  ⚠️  PRODUCTION CODE CHANGE APPROVAL REQUIRED
═══════════════════════════════════════════════════════

The test sync analysis has identified **{N} issue(s)** that may require changes to production code.

## Philosophy Check
⚠️ **Default stance**: "Production is truth, tests adapt"

However, the analysis suggests these tests may have correctly identified bugs in production code.

---

{For each production_bug issue:}

### Issue {issueId}: {classification}

**Affected Files**:
- Production: `{production}` (line {location})
- Test: `{test}`

**What the Test Expects**:
{evidence.testBehavior}

**What Production Actually Does**:
{evidence.productionBehavior}

**Root Cause**:
{rootCause}

**Standards/Specification Reference**:
{evidence.standardsReference}

**Proposed Production Change**:
{recommendedFix.productionChanges}

**Risk Assessment**: {evidence.riskAssessment}

**Rationale for Production Change**:
{recommendedFix.rationale}

---

## Decision Required

For each issue above, you may:
1. **Approve**: Apply the proposed production code change
2. **Reject**: Keep production as-is, adapt the test instead
3. **Defer**: Mark for manual investigation (logged in final report)
```

### Step 3d: Capture PM Decisions

Use AskUserQuestion tool for EACH production bug:

```markdown
AskUserQuestion(
  questions: [{
    question: "Issue {issueId}: {rootCause}\n\nProposed fix: {recommendedFix.productionChanges}\n\nRisk: {evidence.riskAssessment}\n\nApprove this production change?",
    header: "{issueId}",
    multiSelect: false,
    options: [
      {
        label: "Approve",
        description: "Apply production fix (PM takes responsibility)"
      },
      {
        label: "Reject",
        description: "Keep production as-is, adapt test instead"
      },
      {
        label: "Defer",
        description: "Mark for manual review later"
      }
    ]
  }]
)
```

**Store decisions:**

```bash
# Create approval decisions structure
APPROVAL_DECISIONS='{
  "sessionId": "sync-'$(date +%Y%m%d-%H%M%S)'",
  "timestamp": "'$(date -Iseconds)'",
  "decisions": {
    "approved": [],
    "rejected": [],
    "deferred": []
  },
  "pmNotes": ""
}'

# Add each decision based on PM response
# If Approve: add issueId to decisions.approved
# If Reject: add issueId to decisions.rejected
# If Defer: add issueId to decisions.deferred
```

### Step 3e: Handle Rejected Production Bugs

**For rejected production changes, the test must be adapted instead:**

```bash
# For each rejected issue, modify the sync result to target test instead
for ISSUE_ID in $(jq -r '.decisions.rejected[]' <<< "$APPROVAL_DECISIONS"); do
  echo "Converting ${ISSUE_ID} from production fix to test adaptation..."
  # The fixer agent will adapt the test to match production behavior
done
```

### Step 3f: Audit Trail

**Append to audit trail for accountability:**

```bash
# Log all PM decisions
echo '{"timestamp":"'$(date -Iseconds)'","type":"pm_approval_session","sessionId":"'${SESSION_ID}'","productionBugs":'${PRODUCTION_BUG_COUNT}',"approved":'$(jq '.decisions.approved | length' <<< "$APPROVAL_DECISIONS")',"rejected":'$(jq '.decisions.rejected | length' <<< "$APPROVAL_DECISIONS")',"deferred":'$(jq '.decisions.deferred | length' <<< "$APPROVAL_DECISIONS")'}' >> "${ARTIFACT_LOC}/sync-prod-to-tests/audit-trail.jsonl"
```

**Update TodoWrite:** Add task "PM approved {N} production changes" as `completed`

---

## Phase 4: Auto-Fix Execution

**Skip if `--dry-run` flag is set:**

```bash
if [ "$DRY_RUN" = true ]; then
  echo "🔍 Dry run mode - skipping fixes"
  echo ""
  echo "Issues found that would be fixed:"
  # Display summary of what would be fixed
  goto Phase 7  # Skip directly to report in dry-run mode
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

**⚠️ CRITICAL: MANDATORY SUB-AGENT DELEGATION**

**YOU MUST delegate fixes to `rptc:master-test-fixer-agent` using the Task tool.**

**YOU MUST NOT:**
- ❌ Edit test files in main context (use Edit tool)
- ❌ Write new test code in main context
- ❌ Create test files in main context (use Write tool)
- ❌ Run test commands in main context (use Bash tool)
- ❌ Apply any fix scenario logic in main context

**VIOLATION OF THESE RULES BREAKS THE WORKFLOW.**

If you find yourself about to edit a test file or write test code, STOP IMMEDIATELY and use the Task tool delegation below instead.

---

**For EACH area where AREA_STATUS[area]=true, execute this delegation:**

Use the Task tool with subagent_type="rptc:master-test-fixer-agent":

Prompt:
## Fix Context

**Iteration:** ${ITERATION} of ${MAX_ITERATIONS}
**Thinking mode:** ${THINKING_MODE}
**Test framework:** ${FRAMEWORK}
**Coverage target:** ${COVERAGE_TARGET}%

## Available Testing Tools & Capabilities
**Tools installed:** ${TESTING_TOOLS[@]}
**Capabilities:**
- E2E Testing (Playwright/Cypress): ${HAS_E2E}
- Component Testing (RTL/VTL): ${HAS_COMPONENT}
- API Testing (Supertest/httpx): ${HAS_API_TESTING}
- HTTP Mocking (MSW/nock): ${HAS_MOCKING}
- DOM Simulation (jsdom): ${HAS_DOM_MOCK}

## Sync Report for This Area
[Insert sync agent output for this area - MUST include code context per file]

## Mismatches to Fix
[List from sync report - include detected codeContext for each file]

## CRITICAL: Context-Aware Testing Strategy

You MUST select the appropriate testing approach based on each file's code context:

| Code Context | Strategy (if tools available) | Fallback (if tools missing) |
|--------------|------------------------------|----------------------------|
| **Frontend UI** | Component tests (RTL/VTL) or Playwright E2E | Snapshot tests, flag limitation |
| **Backend API** | Integration tests (supertest/httpx) | Mock req/res objects |
| **Database/ORM** | Test DB integration | Repository mocks |
| **Pure Utilities** | Direct unit tests | Direct unit tests |
| **Browser-Dependent** | **Playwright REQUIRED** | Flag for manual review |
| **External Services** | MSW/nock mocked tests | Mock responses inline |

**IMPORTANT:**
- If codeContext is "browser-dependent" AND HAS_E2E=false, DO NOT attempt to create tests. Instead, add to manualReview with reason "Requires Playwright setup".
- If codeContext is "frontend" AND HAS_COMPONENT=false AND HAS_E2E=false, flag for manual review.
- Always match test style to existing tests in the project for consistency.

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

---

**VALIDATION CHECKPOINT:** Verify the Task tool was invoked and returned results before proceeding. If no Task tool result exists, STOP and re-execute the delegation above.

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

## Phase 5: Verification Loop (Inner Loop Convergence Check)

**Update TodoWrite:** Mark "Phase 5: Verify convergence" as `in_progress`

### Step 5a: Re-run Sync Analysis

**CRITICAL: You MUST re-delegate to the sync agent for verification. DO NOT skip this step or check convergence without fresh analysis.**

**Re-execute Step 2b delegation for EACH subdirectory** with the following additional context in the prompt:

Use the Task tool with subagent_type="rptc:master-test-sync-agent":

Prompt:
[Include all context from Step 2b prompt, PLUS:]

## Verification Context
**Iteration:** ${ITERATION} (verification pass)
**Previous issues fixed:** [summary from fixer results]
**Expected outcome:** All previously flagged issues should now be resolved

---

**VALIDATION CHECKPOINT:** Verify the Task tool was invoked for EACH subdirectory before proceeding to convergence check.

### Step 5a.1: Update AREA_STATUS with Fresh Results (CRITICAL)

**YOU MUST update AREA_STATUS with the NEW sync agent results. Failure to do this causes stale data and infinite loops.**

For EACH subdirectory that was re-analyzed in Step 5a:

```bash
# Parse the FRESH sync agent output (not cached from Phase 2)
FRESH_SYNC_RESULT=$(parse_json "$FRESH_AGENT_OUTPUT")

# Extract actionRequired from the NEW results
FRESH_ACTION_REQUIRED=$(jq -r '.actionRequired' <<< "$FRESH_SYNC_RESULT")

# UPDATE AREA_STATUS with fresh data (overwrites old value)
AREA_STATUS["$SUBDIR"]="$FRESH_ACTION_REQUIRED"

echo "  $SUBDIR: actionRequired=$FRESH_ACTION_REQUIRED (updated from fresh analysis)"
```

**VALIDATION:** Before proceeding to Step 5b, verify that AREA_STATUS contains results from Step 5a (this iteration), NOT cached results from Phase 2.

### Step 5b: Check Convergence

```bash
# Check if ALL areas report actionRequired=false (using FRESH data from Step 5a.1)
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

### Step 5c: Loop or Complete

```bash
if [ "$CONVERGED" = true ]; then
  echo "Proceeding to quality gate analysis..."
  goto Phase 6  # Quality gates before final report
fi

ITERATION=$((ITERATION + 1))

if [ $ITERATION -ge $MAX_ITERATIONS ]; then
  echo ""
  echo "⚠️  Max iterations ($MAX_ITERATIONS) reached"
  echo "Some issues require manual review."
  goto Phase 7  # Skip to report with failures documented
fi

echo ""
echo "Starting iteration $ITERATION..."
goto Phase 2  # Re-analyze and fix
```

**Update TodoWrite:** Mark "Phase 5: Verify convergence" as `completed`

---

## Phase 6: Test Suite Verification (Post-Convergence)

**Purpose**: After inner loop convergence (all tests sync), verify all tests actually pass. If any fail, return to inner loop to fix them.

**Update TodoWrite:** Mark "Phase 6: Test suite verification" as `in_progress`

### Step 6a: Run Full Test Suite

**Run the complete test suite to ensure all synced tests pass:**

```bash
echo "Running full test suite verification..."

# Run test suite based on framework
case $FRAMEWORK in
  jest)
    TEST_OUTPUT=$(npm test 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  vitest)
    TEST_OUTPUT=$(npx vitest run 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  pytest)
    TEST_OUTPUT=$(pytest 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  go)
    TEST_OUTPUT=$(go test ./... 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  junit)
    TEST_OUTPUT=$(mvn test 2>&1 || gradle test 2>&1)
    TEST_EXIT_CODE=$?
    ;;
esac
```

### Step 6b: Handle Test Results

```bash
if [ $TEST_EXIT_CODE -ne 0 ]; then
  echo "❌ Test suite failed after sync"
  echo ""
  echo "Failing tests:"
  echo "$TEST_OUTPUT" | grep -E "(FAIL|ERROR|✗)" | head -20
  echo ""

  OUTER_ITERATION=$((OUTER_ITERATION + 1))

  if [ $OUTER_ITERATION -ge $MAX_OUTER_ITERATIONS ]; then
    echo "⚠️  Max outer iterations ($MAX_OUTER_ITERATIONS) reached with failing tests"
    echo "Proceeding to report with failures documented"
    FINAL_STATUS="FAILED"
    goto Phase 7
  else
    echo "Returning to analysis phase to fix failing tests..."
    goto Phase 2  # Re-analyze failing tests
  fi
else
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  ✅ ALL TESTS PASSING"
  echo "════════════════════════════════════════════════════════"
  echo ""
  echo "  Test suite: PASSED"
  echo "  Outer iterations: $OUTER_ITERATION"
  echo "  Inner iterations: $ITERATION"
  echo ""
  echo "════════════════════════════════════════════════════════"

  FINAL_STATUS="CONVERGED"
fi
```

### Step 6c: Audit Trail

```bash
# Log test verification results to audit trail
echo '{"timestamp":"'$(date -Iseconds)'","type":"test_verification","outerIteration":'$OUTER_ITERATION',"innerIterations":'$ITERATION',"testsPassed":'$([ $TEST_EXIT_CODE -eq 0 ] && echo "true" || echo "false")',"status":"'$FINAL_STATUS'"}' >> "${ARTIFACT_LOC}/sync-prod-to-tests/audit-trail.jsonl"
```

**Update TodoWrite:** Mark "Phase 6: Test suite verification" as `completed`

---

## Phase 7: Completion Report

**Update TodoWrite:** Mark "Phase 7: Generate report" as `in_progress`

### Step 7a: Generate Report File

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
**Session ID:** ${SESSION_ID}
**Status:** [CONVERGED/PARTIAL/FAILED]

---

## Convergence Metrics

| Metric | Value |
|--------|-------|
| Inner Loop Iterations | ${ITERATION} |
| Outer Loop Iterations | ${OUTER_ITERATION} |
| Total Analysis Passes | [calculated] |
| Total Fix Passes | [calculated] |

---

## Summary

| Metric | Before | After | Delta |
|--------|--------|-------|-------|
| Files Analyzed | [N] | [N] | - |
| Test Coverage | [X]% | [Y]% | +[Z]% |
| Synced Files | [A] | [B] | +[C] |
| Issues Remaining | [D] | [E] | -[F] |

---

## Fixes Applied

### Tests Updated ([count])
[List of updated test files with change descriptions]

### Tests Created ([count])
[List of new test files with coverage metrics]

### Production Changes Applied ([count])
[List of production files modified with PM approval IDs]

### Manual Review Required ([count])
[List of files that couldn't be auto-fixed with reasons]

---

## PM Approval Log

| Issue ID | Classification | Decision | Rationale |
|----------|---------------|----------|-----------|
| [id] | production_bug | Approved/Rejected/Deferred | [PM notes] |

**Total Production Changes:** [N] approved, [M] rejected, [K] deferred

---

## Test Suite Verification

- Status: ✅ PASSED / ❌ FAILED
- Failing tests: [count if failed]
- Coverage achieved: [X]%

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

## Audit Trail Summary

Full audit trail available at: `${ARTIFACT_LOC}/sync-prod-to-tests/audit-trail.jsonl`

### Key Events
| Timestamp | Event Type | Details |
|-----------|-----------|---------|
| [time] | sync_started | Directory: ${TARGET_DIR} |
| [time] | pm_approval_session | Approved: N, Rejected: M, Deferred: K |
| [time] | test_verification | Tests: ✅ PASSED / ❌ FAILED |
| [time] | sync_completed | Status: ${FINAL_STATUS} |

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

### Step 7b: Write Report

```bash
Write(file_path="$REPORT_FILE", content="$REPORT_CONTENT")
echo "📄 Report saved: $REPORT_FILE"
```

### Step 7c: Display Summary

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

### Step 7d: Final TodoWrite Update

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
      "content": "Phase 3: PM approval gateway",
      "status": "completed",
      "activeForm": "Processing PM approval"
    },
    {
      "content": "Phase 4: Apply fixes",
      "status": "completed",
      "activeForm": "Applying fixes"
    },
    {
      "content": "Phase 5: Verify convergence",
      "status": "completed",
      "activeForm": "Verifying convergence"
    },
    {
      "content": "Phase 6: Test suite verification",
      "status": "completed",
      "activeForm": "Verifying all tests pass"
    },
    {
      "content": "Phase 7: Generate report",
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
  echo "  3. Abort sync-prod-to-tests"
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
