---
name: rptc-sync-prod-to-tests
description: Recursively sync tests to production code with auto-fix and convergence verification. Use when the user asks for /rptc:sync-prod-to-tests or the equivalent RPTC Codex workflow intent.
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

## ⚠️ CRITICAL: Sub-Agent Delegation Required

**This command REQUIRES delegation to specialist sub-agents via the `spawn_agent`.**

**YOU ARE THE ORCHESTRATOR, NOT THE EXECUTOR.**

Your role is to:
- ✅ Discover files and directories (Phase 1)
- ✅ Track progress with update_plan (per-iteration todos)
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

**All analysis and fixing work MUST be delegated to sub-agents using the `spawn_agent`.**

## Custom Agent Availability

Before Phase 1, verify `rptc:test-sync-agent` and `rptc:test-fixer-agent` TOMLs are installed in `.codex/agents/` or the user's Codex agents directory.

If either TOML is missing, use/load `rptc-init` to copy the packaged agents, then re-check. If either agent is still unavailable, STOP and report that sync cannot run because this workflow requires specialist delegation.

## Phase 1: Directory Discovery

**Update update_plan:** Mark "Phase 1: Discover files" as `in_progress`

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

### Step 1e: Update update_plan with Discovered Areas

Dynamically add tasks for each subdirectory:

```json
{
  "tool": "update_plan",
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

**Update update_plan:** Mark "Phase 1: Discover files" as `completed`

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
  "tool": "update_plan",
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

**Reset per-iteration tracking:**

```bash
# CRITICAL: Reset GAPS_FOUND for this iteration
# This ensures we're checking fresh results, not stale data
unset GAPS_FOUND
declare -A GAPS_FOUND

ITERATION_GAPS_TOTAL=0
```

**For EACH subdirectory in SUBDIRECTORIES, execute this delegation:**

Use `spawn_agent` with the RPTC `rptc:test-sync-agent` role when installed:

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
- Serena: ${SERENA_AVAILABLE} (prefix: ${SERENA_TOOL_PREFIX})

## SOPs to Reference
- the RPTC plugin root/sop/test-sync-guide.md

## Your Task
1. Match test files to production files using 5-layer confidence scoring
2. Verify sync status for each matched pair (4 levels)
3. Identify mismatches, missing tests, orphaned tests
4. Return structured JSON report

## Output Format
Return JSON with: synced, mismatches, missingTests, orphanedTests, actionRequired

### Step 2.2: EXIT CHECK (Immediately After EXPLORE)

**Update update_plan:** Mark "Iter ${ITERATION}: EXIT_CHECK" as `in_progress`

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
  # Update update_plan to mark EXIT_CHECK completed, skip PM_APPROVAL/FIX/VERIFY

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

**Update update_plan:** Mark "Iter ${ITERATION}: EXIT_CHECK" as `completed`

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

### Step 2.4: FIX (Fixer Agent Delegation)

**Update update_plan:** Mark "Iter ${ITERATION}: FIX" as `in_progress`

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

**YOU MUST delegate fixes to `rptc:test-fixer-agent` using the `spawn_agent`.**

**YOU MUST NOT:**
- ❌ Edit test files in main context
- ❌ Write new test code in main context
- ❌ Create test files in main context
- ❌ Run test commands in main context
- ❌ Apply any fix scenario logic in main context

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
- [ ] `spawn_agent` invoked with `rptc:test-fixer-agent` for each area with gaps
- [ ] FIX_RESULT parsed and metrics extracted
- [ ] Cumulative totals updated

**Update update_plan:** Mark "Iter ${ITERATION}: FIX" as `completed`

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
  "tool": "update_plan",
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

## Phase 4: Completion Report

**Update update_plan:** Mark "Phase 4: Generate report" as `in_progress`

### Step 4a: Generate Inline Report

**Display the report inline to the user (no file saved):**

```markdown
# Test Sync Report

**Generated:** [timestamp]
**Directory:** ${TARGET_DIR}
**Framework:** ${FRAMEWORK}
**Session ID:** ${SESSION_ID}
**Status:** [CONVERGED/PARTIAL/FAILED]

## Summary

| Metric | Before | After | Delta |
|--------|--------|-------|-------|
| Files Analyzed | [N] | [N] | - |
| Test Coverage | [X]% | [Y]% | +[Z]% |
| Synced Files | [A] | [B] | +[C] |
| Issues Remaining | [D] | [E] | -[F] |

## PM Approval Log

| Issue ID | Classification | Decision | Rationale |
|----------|---------------|----------|-----------|
| [id] | production_bug | Approved/Rejected/Deferred | [PM notes] |

**Total Production Changes:** [N] approved, [M] rejected, [K] deferred

## Convergence Status

[If CONVERGED:]
✅ All production files have synchronized tests
✅ All tests pass
✅ Coverage target (${COVERAGE_TARGET}%) met

[If NOT CONVERGED:]
⚠️ Some issues require manual attention:
[List remaining issues]

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

### Step 4c: Final update_plan Update

```json
{
  "tool": "update_plan",
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

## Important Notes

- **Production code requires PM approval** - test files are changed automatically; production changes need explicit approval
- **Exit condition checked immediately after EXPLORE** - prevents unnecessary fix cycles when no gaps exist
- **Per-iteration update_plan tracking** - each loop iteration has distinct progress entries (Iter N: EXPLORE, EXIT_CHECK, FIX, VERIFY)
- **Fresh sync analysis each iteration** - no stale data; GAPS_FOUND reset before each EXPLORE
- **Max iteration safety valve** - prevents infinite loops (default: 10 iterations)
- **MCP integration is optional** - command works without, MCPs enhance analysis
- **Dry-run mode available** - analyze without making changes
- **Inline reporting** - results displayed directly without file persistence
