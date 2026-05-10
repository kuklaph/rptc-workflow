# Fix Scenarios - Detailed Examples

Detailed code examples for each fix scenario. Referenced from the main SKILL.md.

---

## Scenario A: Update Existing Tests

**Trigger:** Test exists but has naming or intent mismatches.

### Steps

1. **Read production code** to understand current behavior:
   ```bash
   Read(file_path="$PROD_FILE")
   # Extract: function names, parameters, return types, logic flow
   ```

2. **Read existing test file:**
   ```bash
   Read(file_path="$TEST_FILE")
   # Identify: test blocks, descriptions, assertions
   ```

3. **Identify specific issues:**
   - Vague test descriptions -> Rewrite with specific intent
   - Wrong function names -> Rename to match production
   - Outdated assertions -> Update to match current behavior

4. **Apply targeted edits:**
   ```bash
   Edit(
     file_path="$TEST_FILE",
     old_string="it('works correctly'",
     new_string="it('returns 401 when token is expired'"
   )
   ```

5. **Preserve existing structure:** Keep passing tests unchanged, maintain test organization, preserve setup/teardown hooks.

### Example

```typescript
// Before (vague)
describe('auth', () => {
  it('works', () => {
    expect(login('user', 'pass')).toBeTruthy();
  });
});

// After (specific)
describe('login', () => {
  it('returns session token for valid credentials', () => {
    const result = login('validUser', 'validPass');
    expect(result).toHaveProperty('token');
    expect(result.token).toMatch(/^[a-zA-Z0-9]+$/);
  });
});
```

---

## Scenario B: Add Missing Tests

**Trigger:** Test exists but coverage is below target.

### Steps

1. **Analyze coverage report** to identify gaps (uncovered lines, branches).

2. **Read production code** for uncovered sections.

3. **Delegate new test generation** to TDD executor agent:
   ```markdown
   Use the Task tool with subagent_type="rptc:tdd-agent":

   ## Context
   Production file: [path]
   Existing tests: [test file path]
   Current coverage: [%]
   Target coverage: [%]

   ## Uncovered Code
   [Line ranges and logic]

   ## Task
   Write additional tests to cover:
   - [Branch 1 description]
   - [Branch 2 description]
   - [Edge case description]

   ## Constraints
   - Append to existing test file
   - Follow existing test structure
   - Use same describe blocks where appropriate
   ```

4. **Insert new tests** in logical location within existing file.

### Example

```typescript
// Existing tests
describe('validateEmail', () => {
  it('accepts valid email', () => { ... });
  // GAP: No tests for invalid emails
});

// Added tests
describe('validateEmail', () => {
  it('accepts valid email', () => { ... });

  // NEW: Cover error cases
  it('rejects email without @ symbol', () => {
    expect(validateEmail('invalid')).toBe(false);
  });

  it('rejects email with multiple @ symbols', () => {
    expect(validateEmail('a@b@c.com')).toBe(false);
  });
});
```

---

## Scenario C: Fix Assertion Mismatches

**Trigger:** Tests fail because assertions don't match production behavior.

### Steps

1. **Run tests to capture failure details:**
   ```bash
   npm test -- "$TEST_FILE" --verbose 2>&1
   # Capture: expected vs actual values
   ```

2. **Analyze failure patterns:**
   - Wrong expected value -> Update assertion
   - Wrong data structure -> Update matcher
   - Production behavior changed -> Update entire test

3. **Read production code** to understand correct behavior.

4. **Update assertions to match production:**
   ```bash
   Edit(
     file_path="$TEST_FILE",
     old_string="expect(calculateTax(100)).toBe(7)",
     new_string="expect(calculateTax(100)).toBe(8)  // 8% tax rate"
   )
   ```

5. **Verify fix by re-running test.**

### Example

```typescript
// Before (fails - production gives 10% discount)
it('applies silver discount', () => {
  expect(getDiscount(100, 'silver')).toBe(15); // FAIL: got 10
});

// After (matches production)
it('applies 10% silver tier discount', () => {
  expect(getDiscount(100, 'silver')).toBe(10);
});
```

---

## Scenario D: Create New Test File

**Trigger:** Production file has no matched test.

### Steps

1. **Analyze production file completely** (all exports, signatures, methods).

2. **Determine test file location** (mirror production structure):
   ```bash
   TEST_PATH="${PROD_PATH/src/tests}"
   TEST_PATH="${TEST_PATH%.*}.test.${EXT}"
   ```

3. **Detect test framework and conventions** from existing tests.

4. **Delegate complete test generation** to TDD executor:
   ```markdown
   Use the Task tool with subagent_type="rptc:tdd-agent":

   ## Context
   Production file: [path]
   Exports: [list of functions/classes]
   Framework: [jest/vitest/pytest/etc]

   ## Task
   Create complete test file covering:
   - All exported functions/classes
   - Happy path for each
   - Error cases for each
   - Edge cases as appropriate

   ## Output Location
   [calculated test path]

   ## Conventions
   [Extracted from sample test file]
   ```

5. **Write and verify** new test file.

### Example

```typescript
// Production: src/helpers/format.ts
export function formatCurrency(amount: number): string { ... }
export function formatDate(date: Date): string { ... }

// Generated: tests/helpers/format.test.ts
import { formatCurrency, formatDate } from '../../src/helpers/format';

describe('formatCurrency', () => {
  it('formats positive amounts with $ prefix', () => {
    expect(formatCurrency(100)).toBe('$100.00');
  });

  it('formats negative amounts with parentheses', () => {
    expect(formatCurrency(-50)).toBe('($50.00)');
  });

  it('handles zero', () => {
    expect(formatCurrency(0)).toBe('$0.00');
  });
});

describe('formatDate', () => {
  it('formats date as YYYY-MM-DD', () => {
    expect(formatDate(new Date('2024-01-15'))).toBe('2024-01-15');
  });

  it('handles invalid date', () => {
    expect(formatDate(new Date('invalid'))).toBe('Invalid Date');
  });
});
```

---

## Scenario E: Apply Production Fix (PM Approved)

**Trigger:** `classification: "production_bug"` AND PM approved.

**CRITICAL: Only execute if the issue ID is in `approvalDecisions.decisions.approved`.**

### Steps

1. **Verify PM approval** (MANDATORY):
   ```bash
   if ! echo "$APPROVED_IDS" | grep -q "$ISSUE_ID"; then
     echo "ERROR: Attempted production change without PM approval"
     exit 1
   fi
   ```

2. **Read production code** to understand current state.

3. **Apply the recommended production fix:**
   ```bash
   Edit(
     file_path="$PROD_FILE",
     old_string="[current production code]",
     new_string="[fixed production code from recommendedFix.productionChanges]"
   )
   ```

4. **Verify tests now pass.**

5. **Log to audit trail:**
   ```bash
   echo '{"timestamp":"...","type":"production_fix","issueId":"...","pmApproved":true}' \
     >> "${ARTIFACT_LOC}/sync-prod-to-tests/audit-trail.jsonl"
   ```

### Example

```typescript
// BEFORE (production bug - missing validation)
export function login(email: string, password: string) {
  return db.users.findOne({ email, password });
}

// AFTER (PM approved fix - adds validation)
export function login(email: string, password: string) {
  if (!isValidEmail(email)) {
    throw new ValidationError('Invalid email format');
  }
  if (!password || password.length < 8) {
    throw new ValidationError('Password must be at least 8 characters');
  }
  return db.users.findOne({ email, password });
}
```

**Important Notes:**
- Always verify PM approval BEFORE editing production code
- Log every production change to audit trail
- Re-run affected tests to verify fix works
- If fix breaks other tests, flag for manual review

---

## Serena MCP Integration

If Serena MCP is available, use for precise symbolic edits:

```bash
# Replace entire test function body
mcp__serena__replace_symbol_body(
  name_path="describe/it",
  relative_path="tests/auth.test.ts",
  body="[new test code]"
)

# Insert new test after existing one
mcp__serena__insert_after_symbol(
  name_path="describe('login')/it('accepts valid')",
  relative_path="tests/auth.test.ts",
  body="it('rejects invalid', () => { ... })"
)

# Find test functions to update
mcp__serena__find_symbol(
  name_path_pattern="it",
  relative_path="tests/",
  include_body=true
)
```

**Benefits:** Precise symbol-level edits, maintains file formatting, handles complex nested structures.

**Fallback:** If Serena MCP is not available, use standard Edit/MultiEdit tools.
