# Test Synchronization Methodology

This SOP defines how to compare production code to tests, verify synchronization, and auto-fix mismatches.

---

## Purpose

Ensure tests accurately reflect production code logic, intent, and coverage requirements. Production code **always takes precedence** - tests must be updated to match production, not vice versa.

---

## Test-Production Matching Algorithm

### Multi-Layer Confidence Scoring

Tests are matched to production files using a 5-layer scoring system. **Minimum threshold: 50 points**.

#### Layer 1: Naming Convention (40 points)

**Highest priority** - Direct filename correlation.

| Production File | Matched Test Patterns | Points |
|-----------------|----------------------|--------|
| `feature.ts` | `feature.test.ts`, `feature.spec.ts` | 40 |
| `utils.py` | `test_utils.py`, `utils_test.py` | 40 |
| `handler.go` | `handler_test.go` | 40 |
| `Service.java` | `ServiceTest.java` | 40 |

**Detection Logic:**
```bash
# Extract base name without extension
BASE_NAME="${PROD_FILE%.*}"
EXT="${PROD_FILE##*.}"

# Check common test patterns
PATTERNS=(
  "${BASE_NAME}.test.${EXT}"
  "${BASE_NAME}.spec.${EXT}"
  "test_${BASE_NAME}.${EXT}"
  "${BASE_NAME}_test.${EXT}"
)
```

#### Layer 2: Directory Structure (30 points)

Mirror relationship between `src/` and `tests/` directories.

| Production Path | Expected Test Path | Points |
|-----------------|-------------------|--------|
| `src/auth/login.ts` | `tests/auth/login.test.ts` | 30 |
| `src/utils/validate.ts` | `__tests__/utils/validate.test.ts` | 28 |
| `lib/parser.py` | `test/lib/test_parser.py` | 28 |

**Directory Mappings:**
- `src/` → `tests/`, `test/`, `__tests__/`, `spec/`
- `lib/` → `test/lib/`, `tests/lib/`
- Root files → `tests/`, `__tests__/`

#### Layer 3: Import Analysis (25 points)

Test file imports the production file.

```typescript
// Test file: tests/auth.test.ts
import { login } from '../src/auth/login';  // +25 points
import { validate } from '../../src/utils/validate';  // +25 points
```

**Detection:**
```bash
# Search for imports matching production file
rg "import.*from.*${PROD_FILE_BASE}" "${TEST_DIR}" -l
```

#### Layer 4: Semantic Analysis (20 points)

Function/class names from production appear in test descriptions.

```typescript
// Production: auth.ts
export function authenticateUser() { ... }
export class UserSession { ... }

// Test: auth.test.ts
describe('authenticateUser', () => { ... })  // +10 points
describe('UserSession', () => { ... })       // +10 points
```

**Scoring:**
- Each matching symbol: +5 points
- Maximum: +20 points (cap)

#### Layer 5: Intent Analysis (15 points)

Test descriptions align with function behavior.

```typescript
// Production: validates password length >= 8
function validatePassword(pwd) {
  if (pwd.length < 8) return false;
  return true;
}

// Test with aligned intent (+5 points each)
it('rejects passwords shorter than 8 characters', ...)  // Matches behavior
it('accepts valid passwords', ...)                      // Matches behavior
```

**Scoring:**
- Each behavior with corresponding test: +5 points
- Maximum: +15 points (cap)

---

## Sync Verification Criteria

A test file is "in sync" when **ALL conditions are met:**

### Level 1: Structural Coverage (Pass/Fail)

Every exported function/class has at least one test case.

```typescript
// Production exports
export function login() { ... }
export function logout() { ... }
export class Session { ... }

// Required in tests
describe('login', ...) or test('login', ...)    // REQUIRED
describe('logout', ...) or test('logout', ...)  // REQUIRED
describe('Session', ...) or test('Session', ...)// REQUIRED
```

### Level 2: Behavioral Coverage (Percentage)

Branch/statement coverage meets threshold (default: 85%).

**Calculation:**
```
Coverage = (Tested Branches / Total Branches) * 100
```

**Must cover:**
- All `if/else` branches
- All `switch` cases
- All `try/catch` paths
- All loop conditions (0, 1, many iterations)

### Level 3: Assertion Accuracy (Pass/Fail)

All tests pass AND assertions match actual production behavior.

**Mismatch Example:**
```typescript
// Production gives 10% discount
function getDiscount(tier) {
  return tier === 'silver' ? 0.10 : 0;
}

// MISMATCH: Test expects 15%
expect(getDiscount('silver')).toBe(0.15); // FAILS
```

### Level 4: Intent Alignment (Percentage)

Test descriptions accurately describe what's being tested.

**Poor intent (misaligned):**
```typescript
it('works correctly', () => { ... })           // Too vague
it('does the thing', () => { ... })            // Meaningless
```

**Good intent (aligned):**
```typescript
it('returns 401 when token is expired', () => { ... })
it('validates email format per RFC 5322', () => { ... })
```

**Scoring:** Aligned tests / Total tests >= 80%

---

## Fix Strategies

### Mismatch Type: Naming Issue

**Symptoms:** Test exists but name doesn't match production function.

**Fix:** Rename test `describe`/`it` blocks to match production names.

```typescript
// Before
describe('auth validation', () => { ... })

// After
describe('validateCredentials', () => { ... })
```

### Mismatch Type: Logic Gap

**Symptoms:** Missing test cases for conditional branches.

**Fix:** Add test cases for uncovered branches.

```typescript
// Add missing edge case
it('throws error when input is null', () => {
  expect(() => processInput(null)).toThrow('Input required');
});
```

### Mismatch Type: Intent Mismatch

**Symptoms:** Test description doesn't match what's tested.

**Fix:** Rewrite test description to accurately describe behavior.

```typescript
// Before (vague)
it('validates input', () => {
  expect(validate('test')).toBe(false);
});

// After (specific)
it('rejects input shorter than 5 characters', () => {
  expect(validate('test')).toBe(false);  // 4 chars < 5
});
```

### Mismatch Type: Assertion Wrong

**Symptoms:** Tests fail because assertions don't match production behavior.

**Fix:** Update assertion to match actual production output.

```typescript
// Before (wrong expectation)
expect(calculateTax(100)).toBe(7);

// After (matches production: 8% tax)
expect(calculateTax(100)).toBe(8);
```

### Missing Tests

**Symptoms:** Production file has no matched test file.

**Fix:** Create new test file with:
1. Framework boilerplate (imports, describe block)
2. Test cases for all exported functions/classes
3. Happy path + edge case coverage
4. Aligned test descriptions

---

## Edge Cases

### Generated Files

**Detection:**
- File header contains `AUTO-GENERATED`, `DO NOT EDIT`
- Located in `generated/`, `dist/`, `build/` directories
- Listed in `.gitignore`

**Action:** Skip sync verification (tests not needed).

### Test Utilities

**Detection:**
- No test cases (`describe`, `it`, `test`)
- Located in `helpers/`, `fixtures/`, `mocks/`
- Only exports (no test execution)

**Action:** Exclude from sync verification.

### Multiple Test Files

**Scenario:** One production file has multiple test files (unit, integration, e2e).

**Action:**
- Use highest confidence match as primary
- Aggregate coverage across all matched tests
- Report supplementary tests separately

### Ambiguous Matches

**Scenario:** Multiple tests match with similar confidence (<10 point difference).

**Action:**
- Flag for manual review
- Allow user override via configuration

### Monorepo Packages

**Detection:**
- `package.json` in subdirectory
- Workspace configuration (Lerna, Nx, pnpm)

**Action:** Never match across package boundaries.

---

## Code Context Detection

Understanding **what type of code** is being tested is critical for selecting the appropriate testing strategy.

### Context Categories

| Category | Indicators | Primary Testing Approach |
|----------|------------|-------------------------|
| **Frontend UI** | React/Vue/Angular components, JSX/TSX, DOM manipulation | Component tests, E2E (Playwright) |
| **Backend API** | Express/Fastify routes, HTTP handlers, middleware | Integration tests, API tests |
| **Database/ORM** | Prisma/Sequelize/TypeORM, SQL queries, migrations | Integration tests with test DB |
| **Pure Utilities** | No I/O, no side effects, pure functions | Unit tests |
| **CLI/Scripts** | Process.argv, commander/yargs, file system ops | Integration tests, snapshot tests |
| **Browser-Dependent** | window/document access, localStorage, cookies | E2E (Playwright), JSDOM mocks |
| **External Services** | API calls, webhooks, third-party SDKs | Mocked unit tests, contract tests |
| **Real-time** | WebSockets, Server-Sent Events, subscriptions | Integration tests with test server |

### Detection Logic

```typescript
// Context detection algorithm
function detectCodeContext(file: string, ast: AST): CodeContext {
  const indicators = {
    frontend: ['React', 'Vue', 'jsx', 'tsx', 'component', 'useState', 'useEffect'],
    backend: ['express', 'fastify', 'koa', 'req', 'res', 'middleware', 'router'],
    database: ['prisma', 'sequelize', 'typeorm', 'mongoose', 'query', 'schema'],
    utility: ['export function', 'export const', no imports from above categories],
    cli: ['process.argv', 'commander', 'yargs', 'inquirer', 'chalk'],
    browser: ['window.', 'document.', 'localStorage', 'sessionStorage', 'navigator'],
    external: ['fetch', 'axios', 'http.request', 'sdk', 'client'],
    realtime: ['WebSocket', 'socket.io', 'EventSource', 'subscribe']
  };

  // Score each category based on indicators found
  // Return highest scoring category with confidence
}
```

### Project Testing Tools Detection

Before selecting a strategy, detect what testing tools are available:

```bash
# Check package.json / pyproject.toml / go.mod for testing dependencies

# JavaScript/TypeScript
JEST=$(grep -q '"jest"' package.json && echo "true")
VITEST=$(grep -q '"vitest"' package.json && echo "true")
PLAYWRIGHT=$(grep -q '"@playwright/test"' package.json && echo "true")
CYPRESS=$(grep -q '"cypress"' package.json && echo "true")
RTL=$(grep -q '"@testing-library/react"' package.json && echo "true")

# Python
PYTEST=$(grep -q 'pytest' pyproject.toml && echo "true")
PLAYWRIGHT_PY=$(grep -q 'playwright' pyproject.toml && echo "true")

# Go
GO_TEST="true"  # Built-in
```

### Testing Strategy Selection Matrix

| Code Context | If Playwright Available | If Only Unit Test Framework | Fallback Strategy |
|--------------|------------------------|----------------------------|-------------------|
| **Frontend UI** | E2E component tests via Playwright | Mock DOM with JSDOM, use RTL | Snapshot tests + shallow render |
| **Backend API** | Full integration via Playwright API testing | Supertest/httptest integration | Mock request/response objects |
| **Database** | Test DB with migrations | In-memory SQLite / mocked repository | Repository pattern mocks |
| **Pure Utility** | Not needed | Direct unit tests | Direct unit tests |
| **Browser-Dependent** | **REQUIRED** - must use Playwright | JSDOM mocks (limited) | Flag for manual review |
| **External Services** | Contract tests with real endpoints | Mocked responses (MSW, nock) | Mocked responses |
| **CLI** | Process spawn tests | Mock stdin/stdout | Snapshot output tests |

### Context-Specific Test Patterns

#### Frontend Components (React Example)

```typescript
// Production: LoginForm.tsx
export function LoginForm({ onSubmit }) {
  const [email, setEmail] = useState('');
  return (
    <form onSubmit={() => onSubmit(email)}>
      <input value={email} onChange={e => setEmail(e.target.value)} />
      <button type="submit">Login</button>
    </form>
  );
}

// Test: LoginForm.test.tsx (with RTL)
import { render, screen, fireEvent } from '@testing-library/react';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  it('calls onSubmit with email when form is submitted', () => {
    const handleSubmit = vi.fn();
    render(<LoginForm onSubmit={handleSubmit} />);

    fireEvent.change(screen.getByRole('textbox'), { target: { value: 'test@example.com' } });
    fireEvent.click(screen.getByRole('button', { name: /login/i }));

    expect(handleSubmit).toHaveBeenCalledWith('test@example.com');
  });
});

// OR with Playwright (E2E)
test('login form submits email', async ({ page }) => {
  await page.goto('/login');
  await page.fill('input[type="email"]', 'test@example.com');
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL('/dashboard');
});
```

#### Backend API (Express Example)

```typescript
// Production: routes/users.ts
router.get('/users/:id', async (req, res) => {
  const user = await db.users.findById(req.params.id);
  if (!user) return res.status(404).json({ error: 'Not found' });
  res.json(user);
});

// Test: users.test.ts (Integration)
import request from 'supertest';
import { app } from '../app';

describe('GET /users/:id', () => {
  it('returns user when found', async () => {
    const res = await request(app).get('/users/123');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('id', '123');
  });

  it('returns 404 when user not found', async () => {
    const res = await request(app).get('/users/nonexistent');
    expect(res.status).toBe(404);
  });
});
```

#### Browser-Dependent Code (Playwright Required)

```typescript
// Production: analytics.ts
export function trackPageView() {
  if (typeof window === 'undefined') return;
  const path = window.location.pathname;
  localStorage.setItem('lastVisit', Date.now().toString());
  // Send to analytics...
}

// Test: analytics.spec.ts (Playwright - REQUIRED for real browser context)
import { test, expect } from '@playwright/test';

test('trackPageView stores timestamp in localStorage', async ({ page }) => {
  await page.goto('/some-page');
  await page.evaluate(() => window.trackPageView());

  const lastVisit = await page.evaluate(() => localStorage.getItem('lastVisit'));
  expect(Number(lastVisit)).toBeGreaterThan(Date.now() - 1000);
});
```

#### External API (Mocked)

```typescript
// Production: github.ts
export async function getUser(username: string) {
  const res = await fetch(`https://api.github.com/users/${username}`);
  if (!res.ok) throw new Error('User not found');
  return res.json();
}

// Test: github.test.ts (MSW mocking)
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import { getUser } from './github';

const server = setupServer(
  rest.get('https://api.github.com/users/:username', (req, res, ctx) => {
    return res(ctx.json({ login: req.params.username, id: 123 }));
  })
);

beforeAll(() => server.listen());
afterAll(() => server.close());

describe('getUser', () => {
  it('returns user data from GitHub API', async () => {
    const user = await getUser('octocat');
    expect(user.login).toBe('octocat');
  });
});
```

### When Context Cannot Be Tested

Some scenarios require special handling:

| Scenario | Detection | Action |
|----------|-----------|--------|
| No browser test runner available | Browser-dependent code + no Playwright/Cypress | Flag for manual review, suggest Playwright setup |
| Database tests with no test DB config | DB code + no test connection string | Create mocked repository tests, flag limitation |
| Secrets/credentials required | Environment variable checks, API keys | Use stub values, test error paths, flag for CI setup |
| Hardware dependencies | USB, Bluetooth, serial port APIs | Mock interfaces, flag as untestable in CI |

### Context Inheritance

Child modules often inherit context from parent:

```
src/
├── components/          # Frontend context
│   ├── Button.tsx      # → Component tests
│   └── Modal.tsx       # → Component tests
├── api/                # Backend context
│   ├── routes.ts       # → Integration tests
│   └── middleware.ts   # → Integration tests
└── utils/              # Utility context
    ├── format.ts       # → Unit tests
    └── validate.ts     # → Unit tests
```

**Rule:** If file context is ambiguous, inherit from nearest parent directory with clear context.

---

## Coverage Calculation

### Formula

```
File Coverage = (Functions Tested / Total Functions) * 100

Where:
- Functions Tested = Functions with ≥1 passing test case
- Total Functions = All exported/public functions
```

### Directory Aggregation

```
Directory Coverage = Σ(File Coverage) / File Count

Overall Coverage = Σ(Directory Coverage * File Count) / Total Files
```

---

## Convergence Criteria

The sync-prod-to-tests command runs iteratively until convergence:

```
CONVERGED = TRUE when ALL of:
  1. Every production file has matched test file (confidence ≥50)
  2. All tests pass
  3. Coverage ≥ target for all files
  4. No intent misalignments detected
  5. No orphaned tests remain
```

**Maximum iterations:** 10 (configurable)

If not converged after max iterations, report failures and request manual review.

---

## Configuration Reference

```json
{
  "rptc": {
    "syncTests": {
      "autoFix": true,
      "createMissing": true,
      "matchMethods": ["naming", "location", "logic", "intent"],
      "maxIterations": 10,
      "confidenceThreshold": 50
    },
    "testCoverageTarget": 85
  }
}
```

| Field | Default | Description |
|-------|---------|-------------|
| `autoFix` | `true` | Automatically fix mismatches |
| `createMissing` | `true` | Create tests for untested files |
| `matchMethods` | all | Which layers to use for matching |
| `maxIterations` | `10` | Maximum convergence loop iterations |
| `confidenceThreshold` | `50` | Minimum points for valid match |
| `testCoverageTarget` | `85` | Required coverage percentage |
