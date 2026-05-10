# TDD Phase Procedures

Detailed procedures for each TDD cycle phase. Referenced from the main SKILL.md when executing RED-GREEN-REFACTOR-VERIFY.

---

## Phase 1: RED - Write Failing Tests First

**FILE LOCKOUT**: During RED phase, you may ONLY create or modify test files.

### Step 0: Context Discovery

Before writing any tests:

- Search `tests/` directory for existing test files
- Identify test framework in use (Jest, Vitest, Bun, pytest, etc.)
- Review 2-3 similar test files for naming patterns and structure
- Check test configuration files (jest.config.js, vitest.config.ts, pytest.ini)
- Note coverage baseline if available
- Identify existing tests that need updating for the planned changes

### Step 0.5: Framework Selection (Per-File)

Select the correct test framework based on code context. Do NOT use unit runners for browser-dependent code.

a. **Detect code context** by scanning target file imports and usage:

| Context | Detection Keywords |
|---------|-------------------|
| `utility` | Pure functions, no UI/backend/browser imports |
| `frontend-ui` | `React`, `Vue`, `useState`, `component`, JSX/TSX |
| `backend-api` | `express`, `fastify`, `req`, `res`, `router` |
| `browser-dependent` | `window.`, `document.`, `localStorage`, `navigator` |
| `external-api` | `fetch`, `axios`, `http.request` |

b. **Check available testing tools** (scan package.json):

```bash
grep -E '"@playwright/test"|"vitest"|"jest"|"bun"|"@testing-library"' package.json
```

c. **Apply selection matrix**:

| Code Context | Framework | Test Pattern |
|--------------|-----------|--------------|
| `utility` | Project unit runner (Bun/Jest/Vitest) | `describe/it/expect` |
| `frontend-ui` | RTL for components, Playwright for E2E | Component or page tests |
| `backend-api` | supertest | HTTP request/response |
| `browser-dependent` | **Playwright REQUIRED** | `page.goto`, `page.evaluate` |
| `external-api` | MSW/nock + unit runner | Mocked responses |

d. **If browser-dependent but no Playwright**: Flag for manual review, skip this file.

e. **Store framework decision**:

```text
Framework Selection:
- src/utils/format.ts -> bun (utility)
- src/components/Button.tsx -> rtl (frontend-ui)
- src/analytics/tracker.ts -> FLAGGED (browser-dependent, no Playwright)
```

### Step 1: Review Test Scenarios

From the step file, identify:
- Happy path scenarios (normal usage)
- Edge case scenarios (boundaries, unusual inputs)
- Error condition scenarios (invalid inputs, failures)

### Step 2: Write Comprehensive Tests

Apply discovered patterns. Use **Given-When-Then** or **Arrange-Act-Assert** structure.

**Test Distribution Targets:**

| Category | Target | Focus |
|----------|--------|-------|
| Happy path | 20-30% | Standard inputs, typical use cases |
| Edge cases | 50-60% | Boundary values, empty collections, unicode, concurrency |
| Error conditions | 20-30% | Invalid inputs, auth failures, timeouts |

**Deduplication**: Compare each test with existing tests. Keep variations that add value, remove slight variations with identical logic.

**Framework-Specific Patterns:**

**Unit Runner (Bun/Jest/Vitest)** - for `utility` code:

```typescript
describe('[module]', () => {
  it('should [behavior] when [condition]', () => {
    const result = myFunction(input);
    expect(result).toBe(expected);
  });
});
```

**React Testing Library** - for `frontend-ui` components:

```typescript
import { render, screen, fireEvent } from '@testing-library/react';

describe('Component', () => {
  it('should [behavior] when [action]', () => {
    render(<Component prop={value} />);
    fireEvent.click(screen.getByRole('button'));
    expect(screen.getByText('Result')).toBeInTheDocument();
  });
});
```

**Playwright** - for `browser-dependent` or E2E:

```typescript
import { test, expect } from '@playwright/test';

test('[behavior] when [condition]', async ({ page }) => {
  await page.goto('/path');
  await page.click('button');
  await expect(page.locator('.result')).toBeVisible();
});

// For browser APIs (localStorage, etc.):
test('should persist data to localStorage', async ({ page }) => {
  await page.goto('/app');
  await page.click('#save-button');
  const stored = await page.evaluate(() => localStorage.getItem('key'));
  expect(stored).toBe('expected-value');
});
```

**supertest** - for `backend-api`:

```typescript
import request from 'supertest';

describe('GET /endpoint', () => {
  it('should return 200 for valid request', async () => {
    const res = await request(app).get('/endpoint');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('data');
  });
});
```

### Step 3: Run Tests to Verify They Fail

- Tests MUST fail for the right reasons
- Failure output should clearly indicate what's missing
- If test passes before implementation, test is invalid

### Step 4: RED GATE (verify before proceeding to GREEN)

- [ ] Only test files were created/modified during RED phase
- [ ] All new tests fail for expected reasons (not compile errors)
- [ ] No production source files were touched

If ANY check fails: STOP. Fix before continuing. Do NOT proceed to GREEN.

**Reference**: `testing-guide.md` Section 1 (TDD), Section 2 (AI Testing Blind Spots)

---

## Phase 2: GREEN - Minimal Implementation

Write ONLY enough code to make tests pass. No more, no less.

### Steps

1. **Implement minimal solution**:
   - Focus on correctness, not elegance
   - No premature optimization
   - Just make tests pass
   - Follow existing code patterns (from surgical coding search)

2. **Run tests after each change**:
   - Verify tests are passing
   - If tests fail, analyze and fix iteratively

3. **Auto-iteration on failures** (max 10 attempts):
   - **Iteration N**: [What was fixed]
   - **Tests**: [X] passing, [Y] failing
   - If still failing after 10 attempts, STOP and request guidance

**Reference**: `testing-guide.md` Section 1 (TDD Green Phase)

---

## Phase 3: REFACTOR - Improve Code Quality

Improve code WHILE keeping tests green. Run tests after EACH change.

### Steps

1. **Identify refactoring opportunities**:
   - Remove code duplication (DRY after 3rd occurrence)
   - Improve naming (variables, functions, classes)
   - Extract functions (if >50 lines or complex logic)
   - Simplify complex logic
   - Add clarifying comments

2. **Apply refactorings incrementally**:
   - One refactoring at a time
   - Run tests after each change
   - If tests fail, revert and fix

3. **Verify simplicity principles**:
   - [ ] Is this the simplest solution?
   - [ ] Would a junior developer understand this?
   - [ ] Are abstractions justified by 3+ use cases?
   - [ ] Are file/function sizes within limits?

**Reference**: `architecture-patterns.md` (Simplicity checkpoints, anti-patterns)

---

## Phase 4: VERIFY - Run Affected Tests and Check Coverage

Ensure no regressions, coverage targets met, and implementation fulfills intent.

### Steps

1. **Run affected tests** (changed files + files that import/reference them):
   - Identify test files for modified production files
   - Include tests that import or reference changed modules
   - All affected tests must pass
   - If any existing tests fail, fix before proceeding
   - Run ONLY affected tests (full suite reserved for `/rptc:commit`)

2. **Check test coverage**:
   - Overall coverage >= 80% (or plan's target)
   - Critical paths: 100%
   - New code: >= 80%

3. **Verify no debug code**:
   - No `console.log`, `debugger`, `print()` statements
   - No commented-out code
   - No TODO comments without tracking

4. **Intent Fulfillment Check**:
   - Does implementation fulfill the step's stated purpose?
   - Review step purpose from plan vs actual implementation
   - If intent gap detected: Document specific gaps before proceeding

5. **Overfitting Detection** (catch test gaming):

   Red Flags:
   - Functions returning exact test expected values without real logic
   - Switch statements mapping test inputs directly to expected outputs
   - Commented-out logic with hardcoded returns
   - Tests pass but implementation lacks business logic

   If detected:
   ```text
   OVERFITTING DETECTED

   File: [path]
   Issue: [Description]
   Evidence: [Code snippet showing the problem]

   Action: Rewrite implementation with proper logic.
   ```

6. **Coverage Gap Detection**:
   - Compare planned test scenarios vs implemented tests
   - Identify any planned scenarios not yet covered

---

## Context Provided by TDD Command

### 1. Overall Feature Context

**Source**: Plan's `overview.md`

Contains: Feature description, test strategy, acceptance criteria, risk assessment, file reference map.

Use to understand the step's role in the overall feature.

### 2. Current Step Details

**Source**: Plan's `step-NN.md`

Contains: Step purpose, prerequisites, tests to write first, files to create/modify, implementation details, expected outcome, acceptance criteria.

### 3. Cumulative File Changes

**Source**: TDD command tracks changes from previous steps

Contains: Files modified/created in Steps 1 through (N-1).

Use to understand what has already been implemented and avoid duplicate work.

### 4. Implementation Constraints

**Source**: Plan's `overview.md` (if defined)

Contains: File size limits, complexity constraints, dependency rules, platform constraints, performance requirements.

**Defaults** (when none specified):
- KISS, YAGNI, DRY after 3rd occurrence
- Files <500 lines, functions <50 lines
- Cyclomatic complexity <10

**Example Minimal Constraints:**

```markdown
- File Size: <500 lines (standard)
- Complexity: <50 lines/function, <10 cyclomatic
- Dependencies: Reuse existing patterns only
- Platforms: Node.js 18+
```

**Example Strict Constraints** (security-critical):

```markdown
- File Size: <300 lines (critical code)
- Complexity: <30 lines/function, <5 cyclomatic
- Dependencies:
  - PROHIBITED: Direct database access (use repository pattern)
  - REQUIRED: All auth code uses project's secure context
- Performance: <100ms response time (p95)
- Security: BLOCKING checkpoint before database writes
```

If constraints are unclear or contradictory: STOP and request PM guidance.
