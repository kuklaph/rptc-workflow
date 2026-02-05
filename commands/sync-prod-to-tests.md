---
description: Recursively sync tests to production code with auto-fix and convergence verification
---

# RPTC: Sync Prod to Tests

**You are the test synchronization orchestrator, ensuring all tests match production code.**
The user is the **project manager** - they approve major decisions and final completion.

**Arguments:**
- `[directory]` - Target directory to sync (optional, auto-detected from repo structure)
- `--dry-run` - Analyze only, don't make changes
- `--max-iterations N` - Override max convergence iterations (default: 10)

**Auto-Detection:**
The command automatically discovers:
- Production code locations (src/, lib/, app/, packages/)
- Test locations (tests/, __tests__/, co-located *.test.* files)
- Test framework (jest, vitest, pytest, go, junit)
- Testing tools (Playwright, RTL, supertest, msw, etc.)

**Examples:**
```bash
/rptc:sync-prod-to-tests                    # Auto-detect everything
/rptc:sync-prod-to-tests "src/auth/"        # Target specific subdirectory
/rptc:sync-prod-to-tests --dry-run          # Analyze without changes
/rptc:sync-prod-to-tests --max-iterations 5 # Limit iterations
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
- ✅ Track progress with TodoWrite (per-iteration todos)
- ✅ **SYNC LOOP** (Phase 2):
  - Step 2.1: **Delegate analysis to `rptc:test-sync-agent`** (EXPLORE)
  - Step 2.2: **Check exit condition** (EXIT_CHECK) ← immediately after explore
  - Step 2.3: Obtain PM approval for production changes (PM_APPROVAL)
  - Step 2.4: **Delegate fixes to `rptc:test-fixer-agent`** (FIX)
  - Step 2.5: Run affected test verification (VERIFY)
  - Step 2.6: Increment iteration and loop back
- ✅ **Verify all tests pass** (Phase 3: Final Test Verification)
- ✅ Generate final report with audit trail (Phase 4)

**DO NOT in main context:**
- ❌ Read production or test file contents
- ❌ Analyze code for test matching
- ❌ Write or edit test files
- ❌ Run test commands
- ❌ Attempt sync verification logic

**All analysis and fixing work MUST be delegated to sub-agents using the Task tool.**

---

## Step 0: Validation

### Step 0a: Defaults

- Coverage target: 80%
- Auto-fix: enabled
- Create missing: enabled
- Max iterations: 10
- Confidence threshold: 50

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

### Step 0c: Auto-Detect Repository Structure

**If `TARGET_DIR` is not provided, intelligently explore the repository.**

Use Sequential Thinking MCP (if available) to reason through detection, and Serena MCP (if available) for semantic code understanding.

**Exploration Strategy:**

1. **Read configuration files** for explicit hints:
   - `package.json` → check `main`, `module`, `jest.roots`, `scripts.test`
   - `tsconfig.json` → check `compilerOptions.rootDir`, `include`
   - `pyproject.toml` → check `testpaths`, source directories
   - `go.mod` → module structure

2. **Search with Grep** for import patterns and test configurations:
   - Search for `describe(`, `it(`, `test(` to find test files
   - Search for `@Test`, `def test_` for other frameworks

3. **Use Glob** to discover directory patterns:
   - Production: `src/`, `lib/`, `app/`, `packages/`, `core/`
   - Tests: `tests/`, `test/`, `__tests__/`, `spec/`, `e2e/`
   - Co-located: `**/*.test.{ts,js}` alongside production files

4. **Use Serena** (if available) for semantic understanding:
   - `get_symbols_overview` on candidate directories
   - `find_symbol` to locate test utilities and fixtures
   - Understand module boundaries and dependencies

5. **Determine test pattern type:**
   - `separate` - tests in dedicated directory (tests/, test/)
   - `co-located` - test files next to production (*.test.ts)
   - `__tests__` - Jest-style folders within source

**Store results:**
- `TARGET_DIR` - Primary production code directory
- `TEST_LOCATIONS` - Where tests live
- `TEST_PATTERN_TYPE` - How tests are organized

**Display detection results:**

```text
════════════════════════════════════════════════════════
  REPOSITORY STRUCTURE DETECTED
════════════════════════════════════════════════════════

  Production: src/
  Tests: tests/, src/**/__tests__/
  Pattern: separate + __tests__

════════════════════════════════════════════════════════
```

**Only prompt user if detection is ambiguous** (multiple equally-valid production directories found).

### Step 0d: Validate Directory

Verify `TARGET_DIR` exists and is accessible. If not found, display error and exit.

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

**Initial structure uses phases. Iteration-specific todos are added dynamically in Phase 2.**

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
      "content": "Phase 2: SYNC LOOP",
      "status": "pending",
      "activeForm": "Running sync loop"
    },
    {
      "content": "Phase 3: Final test verification",
      "status": "pending",
      "activeForm": "Verifying all tests pass"
    },
    {
      "content": "Phase 4: Generate report",
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

Use Glob to find production code in `TARGET_DIR`:

| Language | Pattern |
|----------|---------|
| TypeScript/JavaScript | `**/*.{ts,tsx,js,jsx}` |
| Python | `**/*.py` |
| Go | `**/*.go` |
| Java | `**/*.java` |

**Exclude:** `node_modules/`, `vendor/`, `dist/`, `build/`, `generated/`, and test files.

Store results in `PRODUCTION_FILES` list.

### Step 1c: Discover Test Files

**Use the detected `TEST_LOCATIONS` and `TEST_PATTERN_TYPE` from Step 0c.**

Use Glob to find test files based on detected framework:

| Framework | Patterns |
|-----------|----------|
| jest/vitest | `*.test.{ts,tsx,js,jsx}`, `*.spec.*`, `__tests__/**/*` |
| pytest | `test_*.py`, `*_test.py` |
| go | `*_test.go` |
| junit | `*Test.java`, `*Tests.java` |

Search in:
1. Detected `TEST_LOCATIONS` (e.g., `tests/`, `spec/`)
2. Co-located patterns if `TEST_PATTERN_TYPE` includes "co-located"
3. `__tests__/` directories within `TARGET_DIR` if applicable

Store results in `TEST_FILES` list.

### Step 1d: Identify Subdirectories

Group discovered files by subdirectory for staged analysis. For each subdirectory, count production files and matching test files.

This creates `SUBDIRECTORIES` - the list of areas to analyze in Phase 2.

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

Repository Structure:
  Production code: ${TARGET_DIR}
  Test locations: ${TEST_LOCATIONS}
  Test pattern: ${TEST_PATTERN_TYPE:-separate}

Framework: ${FRAMEWORK}
Testing tools: ${TESTING_TOOLS[@]}

Files Found:
  Production files: [N]
  Test files: [M]
  Subdirectories to analyze: [K]

Subdirectory breakdown:
  ${TARGET_DIR}/auth/: 5 prod files, 3 test files
  ${TARGET_DIR}/utils/: 8 prod files, 6 test files
  ${TARGET_DIR}/api/: 12 prod files, 10 test files
  ...

Test Coverage Estimate: [X]% (based on file matching)

═══════════════════════════════════════════════════════
```

**Update TodoWrite:** Mark "Phase 1: Discover files" as `completed`

---

## Phase 2: SYNC LOOP

**This phase consolidates analysis, approval, fixing, and verification into a single iterative loop with clear exit conditions.**

**Update TodoWrite:** Mark "Phase 2: SYNC LOOP" as `in_progress`

---

### Step 2.0: Initialize Iteration State

```bash
# Initialize tracking variables
ITERATION=1
MAX_ITERATIONS=${MAX_ITER_OVERRIDE:-10}
CONVERGED=false
declare -A AREA_STATUS      # Track sync status per subdirectory
declare -A GAPS_FOUND       # Track gaps found THIS iteration (reset each loop)

# Cumulative metrics (persist across iterations)
TOTAL_UPDATED=0
TOTAL_CREATED=0
TOTAL_FAILED=0
TOTAL_MANUAL_REVIEW=0

# Session ID for audit trail
SESSION_ID="sync-$(date +%Y%m%d-%H%M%S)"

echo ""
echo "════════════════════════════════════════════════════════"
echo "  SYNC LOOP INITIALIZED"
echo "════════════════════════════════════════════════════════"
echo "  Max iterations: ${MAX_ITERATIONS}"
echo "  Session ID: ${SESSION_ID}"
echo "  Subdirectories: ${#SUBDIRECTORIES[@]}"
echo "════════════════════════════════════════════════════════"
```

**Add initial iteration todos:**

```json
{
  "tool": "TodoWrite",
  "todos": [
    // ... preserve existing phase todos ...
    {
      "content": "Iter 1: EXPLORE",
      "status": "pending",
      "activeForm": "Iter 1: Exploring sync status"
    },
    {
      "content": "Iter 1: EXIT_CHECK",
      "status": "pending",
      "activeForm": "Iter 1: Checking exit condition"
    },
    {
      "content": "Iter 1: PM_APPROVAL",
      "status": "pending",
      "activeForm": "Iter 1: Processing PM approval"
    },
    {
      "content": "Iter 1: FIX",
      "status": "pending",
      "activeForm": "Iter 1: Applying fixes"
    },
    {
      "content": "Iter 1: VERIFY",
      "status": "pending",
      "activeForm": "Iter 1: Verifying fixes"
    }
  ]
}
```

---

### Step 2.1: EXPLORE (Sync Agent Delegation)

**Update TodoWrite:** Mark "Iter ${ITERATION}: EXPLORE" as `in_progress`

**⚠️ CRITICAL: MANDATORY SUB-AGENT DELEGATION**

**YOU MUST delegate analysis to `rptc:test-sync-agent` using the Task tool.**

**YOU MUST NOT:**
- ❌ Read production file contents in main context
- ❌ Read test file contents in main context
- ❌ Analyze code for test matching in main context
- ❌ Calculate confidence scores in main context
- ❌ Attempt any sync verification logic in main context

**VIOLATION OF THESE RULES BREAKS THE WORKFLOW.**

---

**Reset per-iteration tracking:**

```bash
# CRITICAL: Reset GAPS_FOUND for this iteration
# This ensures we're checking fresh results, not stale data
unset GAPS_FOUND
declare -A GAPS_FOUND

ITERATION_GAPS_TOTAL=0
```

**For EACH subdirectory in SUBDIRECTORIES, execute this delegation:**

Use the Task tool with subagent_type="rptc:test-sync-agent":

Prompt:
## Analysis Context

**Iteration:** ${ITERATION} of ${MAX_ITERATIONS}
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

## SOPs to Reference
- ${CLAUDE_PLUGIN_ROOT}/sop/test-sync-guide.md

## Your Task
1. Match test files to production files using 5-layer confidence scoring
2. Verify sync status for each matched pair (4 levels)
3. Identify mismatches, missing tests, orphaned tests
4. Return structured JSON report

## Output Format
Return JSON with: synced, mismatches, missingTests, orphanedTests, actionRequired

---

**Process sync agent results for EACH subdirectory:**

```bash
# Parse agent output
SYNC_RESULT=$(parse_json "$AGENT_OUTPUT")

# VALIDATION: Check that codeContext is present for all files
MISSING_CONTEXT_COUNT=$(jq '[.synced[], .mismatches[], .missingTests[] | select(.codeContext == null or .codeContext == "")] | length' <<< "$SYNC_RESULT")

if [ "$MISSING_CONTEXT_COUNT" -gt 0 ]; then
  echo "❌ ERROR: Sync agent output missing 'codeContext' for $MISSING_CONTEXT_COUNT files"
  echo "Re-delegating with explicit codeContext requirement..."
  # Re-run delegation for this subdirectory
  continue
fi

# Extract key metrics
SYNCED_COUNT=$(jq '.synced | length' <<< "$SYNC_RESULT")
MISMATCH_COUNT=$(jq '.mismatches | length' <<< "$SYNC_RESULT")
MISSING_COUNT=$(jq '.missingTests | length' <<< "$SYNC_RESULT")
ORPHANED_COUNT=$(jq '.orphanedTests | length' <<< "$SYNC_RESULT")
ACTION_REQUIRED=$(jq -r '.actionRequired' <<< "$SYNC_RESULT")

# CRITICAL: Store gaps for THIS iteration
SUBDIR_GAPS=$((MISMATCH_COUNT + MISSING_COUNT))
GAPS_FOUND["$SUBDIR"]=$SUBDIR_GAPS
AREA_STATUS["$SUBDIR"]="$ACTION_REQUIRED"
ITERATION_GAPS_TOTAL=$((ITERATION_GAPS_TOTAL + SUBDIR_GAPS))

echo "  $SUBDIR: Synced=$SYNCED_COUNT, Mismatches=$MISMATCH_COUNT, Missing=$MISSING_COUNT"
```

**VALIDATION CHECKPOINT (EXPLORE):**
- [ ] Task tool invoked with rptc:test-sync-agent for EACH subdirectory
- [ ] GAPS_FOUND populated from THIS iteration's results (not cached)
- [ ] ITERATION_GAPS_TOTAL calculated from fresh data
- [ ] codeContext present for all analyzed files

**IF ANY UNCHECKED:** STOP. Re-execute Step 2.1.

**Update TodoWrite:** Mark "Iter ${ITERATION}: EXPLORE" as `completed`

---

### Step 2.2: EXIT CHECK (Immediately After EXPLORE)

**Update TodoWrite:** Mark "Iter ${ITERATION}: EXIT_CHECK" as `in_progress`

**⚠️ CRITICAL: This check happens IMMEDIATELY after EXPLORE, before any fixes.**

```bash
echo ""
echo "────────────────────────────────────────────────────────"
echo "  EXIT CHECK (Iteration ${ITERATION})"
echo "────────────────────────────────────────────────────────"
echo "  Total gaps found this iteration: ${ITERATION_GAPS_TOTAL}"
echo "────────────────────────────────────────────────────────"

# Check if ALL gaps are zero
if [ "$ITERATION_GAPS_TOTAL" -eq 0 ]; then
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  ✅ CONVERGENCE ACHIEVED"
  echo "════════════════════════════════════════════════════════"
  echo "  All subdirectories report 0 gaps"
  echo "  Proceeding to Phase 3: Final Test Verification"
  echo "════════════════════════════════════════════════════════"

  CONVERGED=true

  # Mark remaining iteration todos as skipped (not needed)
  # Update TodoWrite to mark EXIT_CHECK completed, skip PM_APPROVAL/FIX/VERIFY

  # ─────────────────────────────────────────────────────────
  # EXIT TO PHASE 3: Final Test Verification
  # ─────────────────────────────────────────────────────────
fi
```

**If gaps remain, continue to Step 2.3:**

```bash
if [ "$ITERATION_GAPS_TOTAL" -gt 0 ]; then
  echo ""
  echo "  Gaps remaining: ${ITERATION_GAPS_TOTAL}"
  echo "  Continuing to PM_APPROVAL and FIX steps..."
  echo ""

  # Display per-subdirectory breakdown
  for SUBDIR in "${!GAPS_FOUND[@]}"; do
    if [ "${GAPS_FOUND[$SUBDIR]}" -gt 0 ]; then
      echo "    ⚠️  $SUBDIR: ${GAPS_FOUND[$SUBDIR]} gaps"
    else
      echo "    ✅ $SUBDIR: 0 gaps"
    fi
  done
fi
```

**VALIDATION CHECKPOINT (EXIT_CHECK):**
- [ ] ITERATION_GAPS_TOTAL evaluated from EXPLORE results (not stale)
- [ ] If gaps=0: Exit to Phase 3 (do NOT proceed to FIX)
- [ ] If gaps>0: Continue to Step 2.3

**IF ANY UNCHECKED:** STOP. Re-evaluate exit condition.

**Update TodoWrite:** Mark "Iter ${ITERATION}: EXIT_CHECK" as `completed`

---

### Step 2.3: PM APPROVAL (Conditional - Production Changes Only)

**Update TodoWrite:** Mark "Iter ${ITERATION}: PM_APPROVAL" as `in_progress`

**This step only executes if production bugs were detected in EXPLORE.**

```bash
# Check if any issues require production changes
REQUIRES_PM_APPROVAL=$(jq -r '.summary.requiresPmApproval // false' <<< "$SYNC_RESULT")
PRODUCTION_BUG_COUNT=$(jq -r '.summary.productionBugs // 0' <<< "$SYNC_RESULT")

if [ "$REQUIRES_PM_APPROVAL" = "false" ] && [ "$PRODUCTION_BUG_COUNT" -eq 0 ]; then
  echo "✓ No production changes detected, skipping PM approval"
  # Continue directly to Step 2.4 FIX
else
  echo "⚠️  ${PRODUCTION_BUG_COUNT} production bug(s) detected requiring PM approval"
fi
```

**If PM approval required, present evidence:**

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

**Proposed Production Change**:
{recommendedFix.productionChanges}

**Risk Assessment**: {evidence.riskAssessment}

---

## Decision Required

For each issue above, you may:
1. **Approve**: Apply the proposed production code change
2. **Reject**: Keep production as-is, adapt the test instead
3. **Defer**: Mark for manual investigation (logged in final report)
```

**Capture PM decisions using AskUserQuestion for EACH production bug:**

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
APPROVAL_DECISIONS='{
  "sessionId": "'$SESSION_ID'",
  "iteration": '$ITERATION',
  "timestamp": "'$(date -Iseconds)'",
  "decisions": {
    "approved": [],
    "rejected": [],
    "deferred": []
  }
}'
```

**VALIDATION CHECKPOINT (PM_APPROVAL):**
- [ ] If no production bugs: Step was skipped correctly
- [ ] If production bugs: Each issue presented to PM with evidence
- [ ] PM decisions captured in APPROVAL_DECISIONS structure
- [ ] Rejected issues converted to test adaptation

**Update TodoWrite:** Mark "Iter ${ITERATION}: PM_APPROVAL" as `completed`

---

### Step 2.4: FIX (Fixer Agent Delegation)

**Update TodoWrite:** Mark "Iter ${ITERATION}: FIX" as `in_progress`

**Skip if `--dry-run` flag is set:**

```bash
if [ "$DRY_RUN" = true ]; then
  echo "🔍 Dry run mode - skipping fixes"
  echo ""
  echo "Issues that would be fixed in iteration ${ITERATION}:"
  for SUBDIR in "${!GAPS_FOUND[@]}"; do
    echo "  $SUBDIR: ${GAPS_FOUND[$SUBDIR]} issues"
  done

  # Mark iteration todos and proceed to report
  # ─────────────────────────────────────────────────────────
  # EXIT TO PHASE 4: Completion Report (dry-run)
  # ─────────────────────────────────────────────────────────
fi
```

**⚠️ CRITICAL: MANDATORY SUB-AGENT DELEGATION**

**YOU MUST delegate fixes to `rptc:test-fixer-agent` using the Task tool.**

**YOU MUST NOT:**
- ❌ Edit test files in main context
- ❌ Write new test code in main context
- ❌ Create test files in main context
- ❌ Run test commands in main context
- ❌ Apply any fix scenario logic in main context

---

**For EACH area where GAPS_FOUND[area] > 0, execute this delegation:**

Use the Task tool with subagent_type="rptc:test-fixer-agent":

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

## PM Approval Decisions (if applicable)
[Include APPROVAL_DECISIONS if any production changes were approved]

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

## Missing Tests to Create
[List from sync report]

## MCP Availability
- Sequential Thinking: ${SEQUENTIAL_THINKING_AVAILABLE} (tool: ${SEQUENTIAL_THINKING_TOOL})
- Serena: ${SERENA_AVAILABLE} (prefix: ${SERENA_TOOL_PREFIX})

## SOPs to Reference
- ${CLAUDE_PLUGIN_ROOT}/sop/testing-guide.md

## Your Task
1. Apply appropriate fix scenario for each issue (A: Update, B: Add, C: Fix assertions, D: Create)
2. Delegate test generation to tdd-agent where appropriate
3. Verify all fixes by running tests
4. Return structured result with success/failure per file

## Constraints
- Auto-fix: ${AUTO_FIX}
- Create missing: ${CREATE_MISSING}
- Max retry attempts per file: 3

---

**Process fixer results:**

```bash
FIX_RESULT=$(parse_json "$FIXER_OUTPUT")

UPDATED_COUNT=$(jq '.updated | length' <<< "$FIX_RESULT")
CREATED_COUNT=$(jq '.created | length' <<< "$FIX_RESULT")
FAILED_COUNT=$(jq '.failed | length' <<< "$FIX_RESULT")
MANUAL_REVIEW_COUNT=$(jq '.manualReview | length' <<< "$FIX_RESULT")

# Update cumulative tracking
TOTAL_UPDATED=$((TOTAL_UPDATED + UPDATED_COUNT))
TOTAL_CREATED=$((TOTAL_CREATED + CREATED_COUNT))
TOTAL_FAILED=$((TOTAL_FAILED + FAILED_COUNT))
TOTAL_MANUAL_REVIEW=$((TOTAL_MANUAL_REVIEW + MANUAL_REVIEW_COUNT))

echo ""
echo "  Iteration ${ITERATION} fixes: Updated=$UPDATED_COUNT, Created=$CREATED_COUNT, Failed=$FAILED_COUNT"
```

**VALIDATION CHECKPOINT (FIX):**
- [ ] Task tool invoked with rptc:test-fixer-agent for each area with gaps
- [ ] FIX_RESULT parsed and metrics extracted
- [ ] Cumulative totals updated

**Update TodoWrite:** Mark "Iter ${ITERATION}: FIX" as `completed`

---

### Step 2.5: VERIFY (Run Tests)

**Update TodoWrite:** Mark "Iter ${ITERATION}: VERIFY" as `in_progress`

**Run affected tests to verify fixes** (only test files modified/created in this iteration):

```bash
# MODIFIED_TEST_FILES: Collect from test-fixer-agent output — all test files
# updated or created during Step 2.4 (FIX) of this iteration.
# MODIFIED_TEST_PACKAGES: Go equivalent — packages containing modified tests.
# MODIFIED_TEST_MODULES/CLASSES: JUnit equivalents for Maven/Gradle.

echo ""
echo "Running affected test verification for iteration ${ITERATION}..."
echo "Test files to verify: ${MODIFIED_TEST_FILES}"

case $FRAMEWORK in
  jest)
    TEST_OUTPUT=$(npx jest ${MODIFIED_TEST_FILES} 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  vitest)
    TEST_OUTPUT=$(npx vitest run ${MODIFIED_TEST_FILES} 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  pytest)
    TEST_OUTPUT=$(pytest ${MODIFIED_TEST_FILES} 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  go)
    TEST_OUTPUT=$(go test ${MODIFIED_TEST_PACKAGES} 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  junit)
    TEST_OUTPUT=$(mvn test -pl ${MODIFIED_TEST_MODULES} 2>&1 || gradle test --tests "${MODIFIED_TEST_CLASSES}" 2>&1)
    TEST_EXIT_CODE=$?
    ;;
esac

if [ $TEST_EXIT_CODE -ne 0 ]; then
  echo "⚠️  Some tests still failing after fixes"
  echo ""
  echo "Failing tests:"
  echo "$TEST_OUTPUT" | grep -E "(FAIL|ERROR|✗)" | head -10
else
  echo "✅ All affected tests passing for this iteration"
fi
```

**VALIDATION CHECKPOINT (VERIFY):**
- [ ] Affected tests executed for appropriate framework
- [ ] TEST_EXIT_CODE captured
- [ ] Failing tests logged (if any)

**Update TodoWrite:** Mark "Iter ${ITERATION}: VERIFY" as `completed`

---

### Step 2.6: INCREMENT & CONTINUE

```bash
echo ""
echo "────────────────────────────────────────────────────────"
echo "  ITERATION ${ITERATION} COMPLETE"
echo "────────────────────────────────────────────────────────"
echo "  Tests status: $([ $TEST_EXIT_CODE -eq 0 ] && echo '✅ PASSING' || echo '⚠️ SOME FAILING')"
echo "  Fixes applied: Updated=$UPDATED_COUNT, Created=$CREATED_COUNT"
echo "────────────────────────────────────────────────────────"

# Increment iteration counter
ITERATION=$((ITERATION + 1))

# Check safety valve
if [ $ITERATION -gt $MAX_ITERATIONS ]; then
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  ⚠️  MAX ITERATIONS REACHED (${MAX_ITERATIONS})"
  echo "════════════════════════════════════════════════════════"
  echo "  Some issues require manual review."
  echo "  Proceeding to Phase 4: Completion Report"
  echo "════════════════════════════════════════════════════════"

  FINAL_STATUS="PARTIAL"

  # ─────────────────────────────────────────────────────────
  # EXIT TO PHASE 4: Completion Report (max iterations)
  # ─────────────────────────────────────────────────────────
fi

# Add todos for next iteration
echo ""
echo "Starting iteration ${ITERATION}..."
```

**Add next iteration todos:**

```json
{
  "tool": "TodoWrite",
  "todos": [
    // ... preserve existing todos ...
    {
      "content": "Iter ${ITERATION}: EXPLORE",
      "status": "pending",
      "activeForm": "Iter ${ITERATION}: Exploring sync status"
    },
    {
      "content": "Iter ${ITERATION}: EXIT_CHECK",
      "status": "pending",
      "activeForm": "Iter ${ITERATION}: Checking exit condition"
    },
    {
      "content": "Iter ${ITERATION}: PM_APPROVAL",
      "status": "pending",
      "activeForm": "Iter ${ITERATION}: Processing PM approval"
    },
    {
      "content": "Iter ${ITERATION}: FIX",
      "status": "pending",
      "activeForm": "Iter ${ITERATION}: Applying fixes"
    },
    {
      "content": "Iter ${ITERATION}: VERIFY",
      "status": "pending",
      "activeForm": "Iter ${ITERATION}: Verifying fixes"
    }
  ]
}
```

**─────────────────────────────────────────────────────────**
**LOOP BACK TO STEP 2.1: EXPLORE**
**─────────────────────────────────────────────────────────**

---

## Phase 3: Final Test Verification

**This phase runs ONLY after convergence is achieved (gaps=0) in Phase 2.**

**Update TodoWrite:** Mark "Phase 3: Final test verification" as `in_progress`

### Step 3a: Run Affected Tests (Final Verification)

```bash
# ALL_MODIFIED_TEST_FILES: Accumulate from all iterations — every test file
# that was updated or created across all Phase 2 iterations.
# ALL_MODIFIED_TEST_PACKAGES: Go equivalent.
# ALL_MODIFIED_TEST_MODULES/CLASSES: JUnit equivalents for Maven/Gradle.

echo ""
echo "════════════════════════════════════════════════════════"
echo "  FINAL TEST VERIFICATION"
echo "════════════════════════════════════════════════════════"
echo "  All sync gaps resolved after ${ITERATION} iteration(s)"
echo "  Running affected tests to confirm all fixes pass..."
echo "  Files to verify: ${ALL_MODIFIED_TEST_FILES}"
echo "════════════════════════════════════════════════════════"

case $FRAMEWORK in
  jest)
    TEST_OUTPUT=$(npx jest ${ALL_MODIFIED_TEST_FILES} 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  vitest)
    TEST_OUTPUT=$(npx vitest run ${ALL_MODIFIED_TEST_FILES} 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  pytest)
    TEST_OUTPUT=$(pytest ${ALL_MODIFIED_TEST_FILES} 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  go)
    TEST_OUTPUT=$(go test ${ALL_MODIFIED_TEST_PACKAGES} 2>&1)
    TEST_EXIT_CODE=$?
    ;;
  junit)
    TEST_OUTPUT=$(mvn test -pl ${ALL_MODIFIED_TEST_MODULES} 2>&1 || gradle test --tests "${ALL_MODIFIED_TEST_CLASSES}" 2>&1)
    TEST_EXIT_CODE=$?
    ;;
esac
```

### Step 3b: Determine Final Status

```bash
if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  ✅ ALL TESTS PASSING"
  echo "════════════════════════════════════════════════════════"
  echo ""
  echo "  Affected tests: PASSED"
  echo "  Total iterations: $((ITERATION - 1))"
  echo "  Total fixes: Updated=$TOTAL_UPDATED, Created=$TOTAL_CREATED"
  echo ""
  echo "════════════════════════════════════════════════════════"

  FINAL_STATUS="CONVERGED"
else
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  ⚠️  TESTS FAILING AFTER SYNC"
  echo "════════════════════════════════════════════════════════"
  echo ""
  echo "Unexpected: Sync reported 0 gaps but tests are failing."
  echo "This may indicate:"
  echo "  - Test infrastructure issues"
  echo "  - Tests affected by execution order"
  echo "  - Environment-specific failures"
  echo ""
  echo "Failing tests:"
  echo "$TEST_OUTPUT" | grep -E "(FAIL|ERROR|✗)" | head -20
  echo ""
  echo "════════════════════════════════════════════════════════"

  FINAL_STATUS="FAILED"
fi
```

**Update TodoWrite:** Mark "Phase 3: Final test verification" as `completed`

---

## Phase 4: Completion Report

**Update TodoWrite:** Mark "Phase 4: Generate report" as `in_progress`

### Step 4a: Generate Inline Report

**Display the report inline to the user (no file saved):**

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
| Sync Loop Iterations | ${ITERATION} |
| Total Analysis Passes | ${ITERATION} |
| Total Fix Passes | ${ITERATION} |
| Max Iterations Allowed | ${MAX_ITERATIONS} |

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

## Test Verification

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

### Step 4b: Display Summary

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

[If issues remain:]
⚠️  Some issues require manual review. See report for details.

═══════════════════════════════════════════════════════
```

### Step 4c: Final TodoWrite Update

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
      "content": "Phase 2: SYNC LOOP",
      "status": "completed",
      "activeForm": "Running sync loop"
    },
    {
      "content": "Phase 3: Final test verification",
      "status": "completed",
      "activeForm": "Verifying all tests pass"
    },
    {
      "content": "Phase 4: Generate report",
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

- **Production code requires PM approval** - test files are changed automatically; production changes need explicit approval
- **Exit condition checked immediately after EXPLORE** - prevents unnecessary fix cycles when no gaps exist
- **Per-iteration TodoWrite tracking** - each loop iteration has distinct progress entries (Iter N: EXPLORE, EXIT_CHECK, FIX, VERIFY)
- **Fresh sync analysis each iteration** - no stale data; GAPS_FOUND reset before each EXPLORE
- **Max iteration safety valve** - prevents infinite loops (default: 10 iterations)
- **MCP integration is optional** - command works without, MCPs enhance analysis
- **Dry-run mode available** - analyze without making changes
- **Inline reporting** - results displayed directly without file persistence
