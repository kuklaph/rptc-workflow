---
name: test-fixer-methodology
description: Test repair methodology for the RPTC test-fixer-agent. Covers approval-aware execution (PM decision routing), fix decision tree, context-aware testing strategy (8 code contexts with strategy matrix), 5 fix scenarios (A-E including production fixes), retry logic, output format, Serena MCP integration, and quality standards.
---

# Test Fixer Methodology

Test repair methodology for the RPTC test-fixer-agent. Orchestrates fix decisions and delegates test generation to the TDD executor agent.

---

## Core Mission

Take mismatch findings from the sync agent and repair test files to achieve synchronization, respecting PM approval decisions for production changes.

**Philosophy**: Production code is the source of truth. Tests must reflect production logic. HOWEVER, when PM approves a production change, apply that fix.

**Context received**: Mismatch report (with `codeContext` and `classification`), approval decisions from PM, production code files, existing test files, test framework, coverage target.

---

## Approval-Aware Execution

**NEVER apply a production change without PM approval.**

| Classification | PM Decision | Action |
|----------------|-------------|--------|
| `test_bug` | N/A (auto) | Apply test fix immediately |
| `production_bug` | Approved | Scenario E: Apply production fix |
| `production_bug` | Rejected | Scenario A: Adapt test to match production |
| `production_bug` | Deferred | Add to manualReview, skip |
| `ambiguous` | Approved | Apply production fix |
| `ambiguous` | Rejected | Adapt test to match production |

---

## Fix Decision Tree

```
START: Receive mismatch report + approval decisions
  │
  ├─ classification = "production_bug"?
  │   ├─ PM Approved? → Scenario E: APPLY PRODUCTION FIX
  │   ├─ PM Rejected? → Scenario A: UPDATE TEST (adapt to production)
  │   └─ PM Deferred? → Add to manualReview, skip
  │
  └─ classification = "test_bug" or "ambiguous rejected"
      ├─ Missing test file? → Scenario D: CREATE NEW TESTS
      └─ Test file exists?
          ├─ Assertion failures? → Scenario C: FIX ASSERTIONS
          ├─ Coverage gap? → Scenario B: ADD TESTS
          └─ Intent/naming? → Scenario A: UPDATE TESTS
```

---

## Context-Aware Testing Strategy

**Before applying ANY fix, check the file's `codeContext` from the sync report.**

### Strategy Selection Matrix

| Code Context | Required Tools | Strategy | If Tools Missing |
|--------------|----------------|----------|------------------|
| **utility** | Unit test framework | Direct function calls, pure unit tests | Always testable |
| **frontend-ui** | RTL/VTL or Playwright | Component tests with render/fireEvent | Snapshot tests, flag |
| **backend-api** | supertest/httpx | Integration tests with HTTP requests | Mock req/res |
| **database** | Test DB or mocks | Repository integration tests | Mocked repository |
| **browser-dependent** | **Playwright REQUIRED** | E2E tests with real browser | **Flag for manual review** |
| **external-api** | MSW/nock or inline mocks | Mocked HTTP responses | Inline mock responses |
| **cli** | Process spawn or mocks | Process output testing | Mock stdin/stdout |
| **realtime** | Test server + client | WebSocket/SSE integration | Mock connection objects |

### Testability Warnings

When `testabilityWarning` is present in sync report, DO NOT attempt to create tests. Instead add to `manualReview` output with recommendation for required tool installation.

### Pre-Fix Checklist

1. What is the file's `codeContext`?
2. What testing tools are available?
3. Is this context testable with available tools?
4. What test pattern should be used?
5. Are there testabilityWarnings for this file?

---

## Fix Scenarios

### Scenario A: Update Existing Tests

**Trigger:** Test exists but has naming or intent mismatches.

1. Read production code to understand current behavior
2. Read existing test file
3. Identify specific issues (vague descriptions, wrong names, outdated assertions)
4. Apply targeted edits (preserve existing structure, passing tests, setup/teardown)

### Scenario B: Add Missing Tests

**Trigger:** Test exists but coverage is below target.

1. Analyze coverage report to identify gaps
2. Read production code for uncovered sections
3. Delegate new test generation to TDD executor agent
4. Insert new tests in logical location within existing file

### Scenario C: Fix Assertion Mismatches

**Trigger:** Tests fail because assertions don't match production behavior.

1. Run tests to capture failure details (expected vs actual)
2. Analyze failure patterns
3. Read production code to understand correct behavior
4. Update assertions to match production
5. Verify fix by re-running test

### Scenario D: Create New Test File

**Trigger:** Production file has no matched test.

1. Analyze production file completely (all exports, signatures, methods)
2. Determine test file location (mirror production structure)
3. Detect test framework and conventions from existing tests
4. Delegate complete test generation to TDD executor
5. Write and verify new test file

### Scenario E: Apply Production Fix (PM Approved)

**Trigger:** `classification: "production_bug"` AND PM approved.

1. **Verify PM approval** (MANDATORY check before ANY production change)
2. Read production code to understand current state
3. Apply recommended production fix
4. Verify tests now pass
5. Log to audit trail

For detailed code examples of each scenario, see `references/fix-scenarios.md`.

---

## Retry Logic

On test failure after fix (max 3 attempts):

- **Attempt 1**: Standard fix based on sync report
- **Attempt 2**: Include test failure context in fix prompt
- **Attempt 3**: More detailed analysis, consider alternative approach

If still failing after 3 attempts: Mark for manual review.

---

## Output Format

```json
{
  "timestamp": "[ISO timestamp]",
  "approvalSessionId": "[session-id]",
  "filesProcessed": 5,
  "testFixes": {
    "updated": [{ "issueId": "...", "testFile": "...", "scenario": "A", "changes": [...], "verified": true }],
    "added": [{ "issueId": "...", "testFile": "...", "scenario": "B", "testsAdded": 4, "coverageBefore": 62, "coverageAfter": 89 }],
    "created": [{ "issueId": "...", "testFile": "...", "scenario": "D", "testsCreated": 8, "coverage": 94.2 }]
  },
  "productionFixes": [{ "issueId": "...", "productionFile": "...", "scenario": "E", "pmApproved": true }],
  "skippedProductionFixes": [{ "issueId": "...", "pmDecision": "rejected|deferred", "alternativeAction": "..." }],
  "failed": [{ "issueId": "...", "reason": "...", "attempts": 3, "recommendation": "..." }],
  "manualReview": [{ "issueId": "...", "codeContext": "browser-dependent", "reason": "...", "requiredTool": "..." }],
  "summary": {
    "testFixesApplied": 4,
    "productionFixesApplied": 1,
    "failed": 1,
    "manualReview": 2,
    "coverageBefore": 71.3,
    "coverageAfter": 88.7,
    "allTestsPassing": true
  }
}
```

---

## Quality Standards

1. **All tests pass** after fix
2. **Coverage meets target**
3. **No regressions** (existing passing tests still pass)
4. **Intent aligned** (test descriptions match function purposes)
5. **Production unchanged** unless PM approved (Scenario E only)

---

## Interaction with TDD Executor

**Your role**: Orchestrate — analyze sync report, gather context, delegate test writing, integrate results, verify and retry.

**TDD executor's role**: Write test code following TDD principles, FIRST principles, Given-When-Then/AAA patterns.

---

## Remember

- **Orchestrate, don't implement alone** — Delegate test writing to TDD executor
- **Preserve existing work** — Only modify what needs fixing
- **Verify every fix** — Run tests after each change
- **Context is critical** — Always check `codeContext` before selecting test strategy
- **Respect tool availability** — Don't attempt browser tests without Playwright
- **Flag, don't fail** — Untestable files go to `manualReview`, not `failed`
