---
name: test-sync-methodology
description: Test sync analysis methodology for the RPTC test-sync-agent. Covers 5-phase analysis process (directory discovery, code context detection, file pairing with multi-layer confidence scoring, sync verification at 4 levels, categorization and report generation), classification decision tree (test_bug/production_bug/ambiguous), output format with required fields, and edge case handling.
---

# Test Sync Methodology

Test sync analysis methodology for the RPTC test-sync-agent. Matches test files to production code and verifies synchronization.

---

## Core Mission

Analyze a directory to identify test-production file pairs and verify their synchronization status.

**Philosophy**: Production code is the source of truth. Tests must accurately reflect production logic, intent, and coverage requirements.

**Context received**: Directory path, sync configuration, test framework detection hints, coverage target.

**Output**: Structured sync status report with actionable findings.

---

## Analysis Process

### Phase 1: Directory Discovery

1. **Detect test framework** from config files (jest.config.js, vitest.config.ts, pytest.ini, go.mod)
2. **Glob production files** (exclude node_modules, dist, build, generated, .next, test files)
3. **Glob test files** by framework patterns (*.test.*, *.spec.*, test_*.py, *_test.go)
4. **Build file inventory** with framework metadata

### Phase 1.5: Code Context Detection

For EACH production file, detect its code context to inform testing strategy.

| Category | Indicators |
|----------|-----------|
| **browser-dependent** | window., document., localStorage, navigator (highest priority) |
| **frontend-ui** | React, Vue, Angular imports; JSX/TSX; useState, component |
| **backend-api** | express, fastify, koa; req, res, router, middleware |
| **database** | prisma, sequelize, typeorm, mongoose; query, schema, model |
| **external-api** | fetch, axios, http.request; external URLs; SDK clients |
| **realtime** | WebSocket, socket.io, EventSource, subscribe |
| **cli** | process.argv, commander, yargs, inquirer |
| **utility** | Pure exports with no I/O imports (default) |

Store context per file. Flag testability issues (e.g., browser-dependent code without Playwright available).

### Phase 2: File Pairing (Multi-Layer Matching)

Match each production file to its test file(s) using 5-layer confidence scoring:

#### Layer 1: Naming Convention (40 points)
- Exact name match: `foo.ts` → `foo.test.ts` / `foo.spec.ts`
- Prefix match: `utils.py` → `test_utils.py`
- Suffix match: `utils.go` → `utils_test.go`

#### Layer 2: Directory Structure (30 points)
- Map production directory to expected test directories
- `src/auth/` → `tests/auth/`, `__tests__/auth/`

#### Layer 3: Import Analysis (25 points)
- Check if test file imports from production file

#### Layer 4: Semantic Symbol Matching (20 points)
- Match exported symbols from production to describe/test blocks in tests
- +5 per matching symbol, max 20

#### Layer 5: Intent Analysis (15 points)
- Read production behavior and check if test descriptions match

**Confidence Threshold:** 50 points minimum for valid match.

### Phase 3: Sync Verification (4 Levels)

For each matched pair:

#### Level 1: Structural Coverage
Count production exports vs test blocks covering those exports.

#### Level 2: Behavioral Coverage
Run tests with coverage. Check against target percentage.

#### Level 3: Assertion Accuracy
Run tests and check for failures. Parse failure details.

#### Level 4: Intent Alignment
Extract test descriptions. Analyze for vague/generic patterns ("works correctly", "does the thing"). Score alignment ≥80% as passing.

### Phase 4: Categorization

Sort findings into categories:
1. **Synced**: All 4 verification levels pass
2. **Mismatched**: Has match but verification fails
3. **Missing Tests**: No test file found (confidence < 50)
4. **Orphaned Tests**: Test file with no production match

### Phase 5: Report Generation

Generate structured output for the sync-prod-to-tests command.

---

## Classification Decision Tree

For EACH broken test or mismatch, determine classification:

### Step 1: Identify What Changed
Check recent production changes via `git log`.

### Step 2: Evaluate Test Validity

**`test_bug`** if:
- Test expects outdated API signature or behavior
- Test validates deprecated functionality
- Test has incorrect assertion logic
- Production change was intentional and test didn't adapt
- Missing test coverage (needs to be created)

**`production_bug`** if:
- Test validates a specification/standard (RFC, API contract, OWASP)
- Production behavior violates documented contract
- Production change introduced regression
- Test correctly identifies missing validation
- Security issue in production

**`ambiguous`** if:
- Specification is unclear or contradictory
- Both test and production logic seem reasonable
- Requires product/design decision

### Step 3: Gather Evidence (for production_bug ONLY)

```json
{
  "evidence": {
    "testBehavior": "What the test expects",
    "productionBehavior": "What production actually does",
    "standardsReference": "RFC/OWASP/API contract reference",
    "riskAssessment": "Low|Medium|High|Critical"
  }
}
```

**Risk Assessment Guide:**
- **Low**: Cosmetic issue, no functional impact
- **Medium**: Could cause bugs in edge cases
- **High**: Security vulnerability, data integrity risk
- **Critical**: Active exploit possible, data loss risk

---

## Output Format

**Required fields for EVERY issue**: `codeContext`, `classification`, `recommendedFix.target`

The orchestrator validates these fields. Output without them is rejected.

```json
{
  "directory": "[analyzed path]",
  "framework": "[detected framework]",
  "timestamp": "[ISO timestamp]",
  "availableTools": { "e2e": true, "component": true, "apiTesting": false, "mocking": true },
  "summary": {
    "filesAnalyzed": 42,
    "testCoverage": 78.5,
    "syncedCount": 35,
    "mismatchCount": 4,
    "missingCount": 2,
    "orphanedCount": 1,
    "testabilityWarnings": 1,
    "requiresPmApproval": true
  },
  "synced": [{ "production": "...", "test": "...", "confidence": 85, "coverage": 92.3, "codeContext": "..." }],
  "mismatches": [{
    "issueId": "...",
    "production": "...",
    "test": "...",
    "confidence": 70,
    "codeContext": "utility",
    "classification": "test_bug",
    "issues": [{ "level": "behavioral", "description": "...", "details": [...] }],
    "rootCause": "...",
    "recommendedFix": { "target": "test", "rationale": "...", "testChanges": "...", "productionChanges": null }
  }],
  "missingTests": [{
    "issueId": "...",
    "production": "...",
    "codeContext": "utility",
    "classification": "test_bug",
    "exports": [...],
    "suggestedTestPath": "...",
    "recommendedFix": { "target": "test", "rationale": "...", "testChanges": "...", "productionChanges": null }
  }],
  "orphanedTests": [{ "test": "...", "reason": "...", "importedFrom": "..." }],
  "testabilityWarnings": [{ "production": "...", "codeContext": "browser-dependent", "issue": "...", "toolAvailable": false }],
  "actionRequired": true
}
```

---

## Edge Case Handling

### Generated Files
Check file headers for `AUTO-GENERATED` or `DO NOT EDIT` markers. Skip files in `generated/`, `dist/`, `build/` directories.

### Test Utilities
Detect utility files without test cases (helpers, fixtures, mocks). Exclude from sync verification.

### Monorepo Boundaries
Find nearest package.json for each file. Only match tests within the same package.

---

## Quality Standards

1. **Complete Discovery**: All production and test files found
2. **Accurate Matching**: Confidence scores reflect actual relationships
3. **Thorough Verification**: All 4 sync levels checked
4. **Clear Categorization**: Every file in exactly one category
5. **Actionable Output**: Issues include specific remediation guidance
