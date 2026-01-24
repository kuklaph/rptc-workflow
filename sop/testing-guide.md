# Testing Guide

**Purpose**: Comprehensive testing strategy and frameworks for TDD-driven development with AI-specific guidance

**Version**: 1.1.0 (Phase 1 Enhancement - AI-Specific Guidance)
**Created**: 2024-01-15
**Last Updated**: 2025-01-21

**Applies To**: All RPTC workflow commands (research, plan, tdd, commit), plan-agent, optimizer-agent

---

## Table of Contents

1. [Test-Driven Development (TDD)](#test-driven-development-tdd)
2. [AI Testing Blind Spots (CRITICAL)](#ai-testing-blind-spots-critical)
3. [Testing Frameworks](#testing-frameworks)
4. [Test Organization](#test-organization)
5. [Test Types](#test-types)
6. [Best Practices](#best-practices)
7. [Continuous Testing](#continuous-testing)
8. [Migration and Refactoring](#migration-and-refactoring)
9. [Project-Specific Testing](#project-specific-testing)

---

## Test-Driven Development (TDD)

### Red-Green-Refactor Cycle

1. **Red**: Write failing test defining desired functionality
2. **Green**: Write minimal code to make test pass
3. **Refactor**: Improve code quality while keeping tests green

### Best Practices

- Write tests first (except exploratory code)
- One test per behavior, not per method
- Independent and isolated tests
- Descriptive test names explaining what's tested
- Keep tests simple and readable

---

## AI Testing Blind Spots (CRITICAL)

**Purpose**: Address systematic test-skipping patterns in AI-generated code

**Version**: 1.0.0 (Phase 1 Enhancement)
**Created**: 2025-01-21
**Based On**: ai-sop-enhancement-pattern.md
**Evidence**: Research shows AI code ships without tests in 60%+ of cases, causing production bugs

---

### When to Use This Section

**ALWAYS verify when**:
- AI generates implementation code without tests
- Tests created after implementation (not test-first)
- "Quick fix" or "simple feature" justification used to skip tests
- Code review shows missing edge case tests
- Coverage reports show <80% on critical paths

**NEVER skip**:
- Even "trivial" features (AI underestimates edge cases)
- Bug fixes (must include regression tests)
- Refactoring work (tests validate behavior preservation)

---

### The 5 AI Testing Blind Spots

AI models frequently skip or inadequately implement these testing practices. MUST verify all 5:

#### 1. Test-First Development (Red-Green-Refactor)

**MANDATORY**: Tests MUST be written BEFORE implementation code

- [ ] Test file created before implementation file exists
- [ ] Test describes expected behavior (Red phase)
- [ ] Implementation written to pass test (Green phase)
- [ ] Refactoring done with tests green

**Anti-Pattern**:
```python
# ❌ AI generates implementation first
def calculate_discount(price, discount_rate):
    return price * (1 - discount_rate)  # Implementation without test
```

**Correct Pattern**:
```python
# ✅ Test FIRST (Red phase)
def test_calculate_discount():
    assert calculate_discount(100, 0.2) == 80  # Fails - function doesn't exist yet

# Then implementation (Green phase)
def calculate_discount(price, discount_rate):
    return price * (1 - discount_rate)  # Now test passes
```

**WHY**: Test-first prevents implementation bias and ensures testable code design. Writing tests after allows AI to create untestable code structures.

#### 2. Edge Case Coverage

**CRITICAL**: Tests MUST cover boundary conditions, not just happy path

- [ ] Null/undefined/None input tests
- [ ] Empty collection tests (empty array, empty string)
- [ ] Boundary values (0, -1, max int, min int)
- [ ] Invalid input types (string when expecting number)
- [ ] Error condition tests (network failure, database timeout)

**Anti-Pattern**:
```javascript
// ❌ AI only tests happy path
describe("fetchUserData", () => {
  it("should return user data", async () => {
    const result = await fetchUserData(123);
    expect(result.name).toBe("John");
  });
  // Missing: null userId, network error, user not found, malformed response
});
```

**Correct Pattern**:
```javascript
// ✅ Comprehensive edge cases
describe("fetchUserData", () => {
  it("should return user data for valid userId", async () => {
    const result = await fetchUserData(123);
    expect(result.name).toBe("John");
  });

  it("should throw error for null userId", async () => {
    await expect(fetchUserData(null)).rejects.toThrow("userId required");
  });

  it("should throw error for non-existent user", async () => {
    await expect(fetchUserData(999)).rejects.toThrow("User not found");
  });

  it("should handle network errors gracefully", async () => {
    mockNetworkFailure();
    await expect(fetchUserData(123)).rejects.toThrow("Network error");
  });
});
```

**WHY**: AI focuses on happy path functionality. Production bugs occur at boundaries. Edge case tests prevent 80%+ of production issues.

#### 3. Assertion Completeness

**MANDATORY**: Tests MUST verify actual behavior, not just "doesn't crash"

- [ ] Assertions verify expected output values
- [ ] Assertions check object state changes
- [ ] Error messages validated (not just error thrown)
- [ ] Side effects verified (database writes, API calls)

**Anti-Pattern**:
```python
# ❌ AI creates incomplete assertions
def test_create_user():
    user = create_user("test@example.com", "password123")
    assert user is not None  # Only checks function doesn't return None
    # Missing: email validation, password hashing, database persistence
```

**Correct Pattern**:
```python
# ✅ Complete assertions
def test_create_user():
    user = create_user("test@example.com", "password123")
    assert user is not None
    assert user.email == "test@example.com"  # Verify email stored
    assert user.password != "password123"    # Verify password hashed
    assert user.password.startswith("$2b$")  # Verify bcrypt used
    assert user.id is not None               # Verify database persisted
```

**WHY**: Weak assertions create false confidence. Tests pass but behavior is wrong. Complete assertions catch implementation bugs.

#### 4. Test Independence

**CRITICAL**: Tests MUST NOT depend on execution order or shared state

- [ ] Each test sets up own data (no reliance on previous tests)
- [ ] Tests clean up after themselves (no side effects)
- [ ] Tests pass when run individually
- [ ] Tests pass when run in any order

**Anti-Pattern**:
```python
# ❌ AI creates dependent tests
class TestUserManagement:
    def test_create_user(self):
        self.user = create_user("test@example.com")  # Stores in instance variable
        assert self.user.id == 1

    def test_update_user(self):
        # Depends on test_create_user running first!
        self.user.name = "Updated"
        update_user(self.user)
        assert get_user(1).name == "Updated"
```

**Correct Pattern**:
```python
# ✅ Independent tests
class TestUserManagement:
    @pytest.fixture
    def sample_user(self):
        user = create_user("test@example.com")
        yield user
        delete_user(user.id)  # Cleanup

    def test_create_user(self):
        user = create_user("test@example.com")
        assert user.id is not None
        delete_user(user.id)  # Cleanup

    def test_update_user(self, sample_user):
        sample_user.name = "Updated"
        update_user(sample_user)
        assert get_user(sample_user.id).name == "Updated"
```

**WHY**: Dependent tests create cascading failures. One broken test breaks entire suite. Independent tests isolate failures to root cause.

#### 5. Coverage Verification

**MANDATORY**: Coverage MUST be measured and meet thresholds (≥80% critical paths)

- [ ] Coverage tool configured (Jest --coverage, pytest --cov)
- [ ] Coverage report generated after test run
- [ ] Critical business logic has ≥80% coverage
- [ ] Coverage gates block commits below threshold

**Anti-Pattern**:
```bash
# ❌ AI runs tests without coverage check
npm test  # No coverage measurement
# Missing: npm test -- --coverage
# Missing: Coverage threshold enforcement
```

**Correct Pattern**:
```json
// package.json - ✅ Coverage enforced
{
  "scripts": {
    "test": "jest --coverage",
    "test:watch": "jest --watch"
  },
  "jest": {
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

**WHY**: Untested code ships bugs. Coverage measurement makes gaps visible. Thresholds prevent coverage regression.

---

### CRITICAL VALIDATION CHECKPOINT - TDD PHASE BLOCKING

**CONSEQUENCE IF SKIPPED**: Untested code reaches production, causing customer-facing bugs

**Before marking TDD step complete, verify**:

**Test-First Verification**:
1. Open git log: `git log --all --oneline -- '*.test.*' '*.spec.*' 'test_*.py'`
2. Verify test commits BEFORE implementation commits
3. Check test file timestamps older than implementation files

**Coverage Verification**:
1. Run coverage tool: `npm test -- --coverage` OR `pytest --cov=src`
2. Check coverage report ≥80% on new/modified code
3. Verify critical paths have ≥80% branch coverage

**Edge Case Verification**:
1. Review test files for null/empty/boundary tests
2. Count edge case tests: MUST have ≥3 per critical function
3. Verify error condition tests present

❌ **TDD STEP BLOCKED** - Cannot proceed if:
- Tests written after implementation
- Coverage <80% on critical paths
- Edge cases missing (null, empty, boundaries)
- Assertions incomplete (only checks "doesn't crash")
- Tests depend on execution order

**Required Action**: Fix failing verification items, re-run verification

**ENFORCEMENT**: If verification NOT passed:
1. TDD workflow MUST halt immediately
2. PM MUST review test gaps
3. **NEVER** mark step complete without passing verification
4. **CANNOT PROCEED** to commit phase

**This is a NON-NEGOTIABLE gate. Research shows AI-generated code ships untested 60%+ of the time without this checkpoint.**

---

### AI Testing Anti-Patterns

#### Anti-Pattern 1: Implementation-First Development

**DON'T**: Write implementation code before tests
```python
# ❌ Code first, tests later (or never)
def process_payment(amount, card_number):
    # 50 lines of implementation
    ...
# Tests written as afterthought (if at all)
```

**DO**: Write tests first (Red-Green-Refactor)
```python
# ✅ Test FIRST
def test_process_payment_success():
    result = process_payment(100.00, "4111111111111111")
    assert result.status == "approved"
    assert result.transaction_id is not None

# Then minimal implementation
def process_payment(amount, card_number):
    # Implementation to pass test
    ...
```

**WHY**: Test-first ensures testable design and prevents implementation bias. Implementation-first creates hard-to-test code and skipped tests.

#### Anti-Pattern 2: Happy-Path-Only Testing

**DON'T**: Only test expected successful cases
```javascript
// ❌ Only tests ideal scenario
test("user login", () => {
  const result = login("user@example.com", "correct_password");
  expect(result.success).toBe(true);
});
// Missing: wrong password, non-existent user, locked account, rate limiting
```

**DO**: Test edge cases, errors, boundaries
```javascript
// ✅ Comprehensive test coverage
describe("user login", () => {
  test("succeeds with valid credentials", () => {
    const result = login("user@example.com", "correct_password");
    expect(result.success).toBe(true);
  });

  test("fails with wrong password", () => {
    const result = login("user@example.com", "wrong_password");
    expect(result.success).toBe(false);
    expect(result.error).toBe("Invalid credentials");
  });

  test("fails for non-existent user", () => {
    const result = login("nonexistent@example.com", "password");
    expect(result.error).toBe("User not found");
  });

  test("blocks locked account", () => {
    lockAccount("user@example.com");
    const result = login("user@example.com", "correct_password");
    expect(result.error).toBe("Account locked");
  });
});
```

**WHY**: Production bugs occur at edge cases, not happy paths. AI focuses on ideal scenarios, missing error conditions.

#### Anti-Pattern 3: Weak Assertions

**DON'T**: Assert only that function doesn't crash
```python
# ❌ Meaningless assertion
def test_generate_report():
    report = generate_report(user_id=123)
    assert report is not None  # Only checks something returned
    # Doesn't verify report contents, format, data accuracy
```

**DO**: Verify actual behavior and output
```python
# ✅ Complete verification
def test_generate_report():
    report = generate_report(user_id=123)
    assert report is not None
    assert report.user_id == 123
    assert report.total_sales > 0
    assert len(report.transactions) == 5
    assert report.generated_at is not None
    assert report.format == "PDF"
```

**WHY**: Weak assertions create false confidence. Tests pass but behavior is wrong. Complete assertions catch bugs.

#### Anti-Pattern 4: Test Interdependencies

**DON'T**: Create tests that depend on execution order
```javascript
// ❌ Tests depend on shared state
describe("shopping cart", () => {
  let cart; // Shared variable

  test("add item", () => {
    cart = new ShoppingCart();
    cart.addItem("product1");
    expect(cart.items.length).toBe(1);
  });

  test("remove item", () => {
    // Assumes previous test ran first!
    cart.removeItem("product1");
    expect(cart.items.length).toBe(0);
  });
});
```

**DO**: Make each test independent with setup/teardown
```javascript
// ✅ Independent tests
describe("shopping cart", () => {
  let cart;

  beforeEach(() => {
    cart = new ShoppingCart(); // Fresh cart for each test
  });

  test("add item", () => {
    cart.addItem("product1");
    expect(cart.items.length).toBe(1);
  });

  test("remove item", () => {
    cart.addItem("product1"); // Setup within test
    cart.removeItem("product1");
    expect(cart.items.length).toBe(0);
  });
});
```

**WHY**: Dependent tests create cascading failures. Debugging requires running multiple tests. Independent tests isolate failures.

---

### Evidence-Based Rationale

**Research Finding**: AI-generated code ships without tests in 60%+ of cases

**Why This Matters**:
- AI prioritizes functionality over test coverage
- AI skips "obvious" test cases that cause production bugs
- AI writes weak assertions that provide false confidence
- AI creates implementation-first code that's hard to test

**Validation**: TDD-first workflow with coverage gates prevents 80%+ of AI-introduced bugs

---

### Coverage Thresholds by Code Criticality

**CRITICAL (≥90% coverage REQUIRED)**:
- Authentication and authorization logic
- Payment processing
- Data validation and sanitization
- Security-critical functions

**HIGH (≥80% coverage REQUIRED)**:
- Core business logic
- API endpoints
- Database operations
- User-facing features

**MEDIUM (≥70% coverage RECOMMENDED)**:
- Utility functions
- Formatters and converters
- Configuration logic

**LOW (≥50% coverage ACCEPTABLE)**:
- Boilerplate code
- Simple getters/setters
- Constants and enums

**NEVER SKIP TESTS**:
- Bug fixes (MUST include regression test)
- Security patches (MUST include vulnerability test)
- Data migrations (MUST include validation test)

---

## Testing Frameworks

### JavaScript/TypeScript

- **Unit**: Jest, Vitest, Mocha
- **Assertions**: Chai, Jest built-in
- **Mocking**: Jest, Sinon, MSW
- **E2E**: Playwright, Cypress, Puppeteer

```javascript
describe("calculateTotalPrice", () => {
  it("should calculate price with tax correctly", () => {
    expect(calculateTotalPrice(100, 0.08)).toBe(108);
  });

  it("should throw error for negative price", () => {
    expect(() => calculateTotalPrice(-100, 0.08)).toThrow("Price and tax rate must be non-negative");
  });
});
```

### Python

- **Unit**: pytest, unittest, doctest
- **Mocking**: unittest.mock, pytest-mock, responses
- **E2E**: Selenium, Playwright

```python
def test_calculate_price_with_tax():
    assert calculate_total_price(100, 0.08) == 108.0

def test_negative_price_raises_error():
    with pytest.raises(ValueError, match="Price and tax rate must be non-negative"):
        calculate_total_price(-100, 0.08)

@pytest.mark.parametrize("price,tax_rate,expected", [
    (100, 0.08, 108),
    (50, 0.10, 55),
])
def test_various_calculations(price, tax_rate, expected):
    assert calculate_total_price(price, tax_rate) == expected
```

### Java

- **Unit**: JUnit 5, TestNG
- **Mocking**: Mockito, PowerMock, EasyMock
- **Assertions**: AssertJ, Hamcrest

### C#/.NET

- **Unit**: xUnit, NUnit, MSTest
- **Mocking**: Moq, NSubstitute

### Go

- **Testing**: Built-in `testing` package
- **Assertions**: testify
- **Mocking**: testify/mock, gomock

### Rust

- **Testing**: Built-in test framework
- **Mocking**: mockall, mockito

## Test Organization

### Directory Structure

```text
src/
├── features/
│   ├── user_management/
│   │   ├── handlers.py
│   │   └── tests/
│   │       └── test_handlers.py
tests/
├── unit/              # Pure unit tests
├── integration/       # Integration tests
├── e2e/              # End-to-end tests
├── fixtures/         # Test data
└── helpers/          # Test utilities
```

### Naming Conventions

**Files**: `test_*.py`, `*.test.js`, `*Test.java`, `*Tests.cs`, `*_test.go`

**Test Functions**: Descriptive names like `test_calculate_price_with_valid_inputs`, `should_`, `it_`

## Test Types

### Unit Tests

**Purpose**: Test individual functions/methods in isolation
**Characteristics**: Fast, isolated, no external dependencies
**Coverage target**: 80%+ for critical business logic

```python
def test_calculate_discount():
    result = calculate_discount(price=100, discount_rate=0.2)
    assert result == 80
```

### Integration Tests

**Purpose**: Test interactions between components
**Characteristics**: Slower, may use test databases/APIs
**Coverage target**: Critical integration points

```python
def test_user_registration_flow():
    user = create_user(email="test@example.com", password="secure123")
    assert user.id is not None
    assert email_sent(user.email)
```

### End-to-End (E2E) Tests

**Purpose**: Test complete user workflows
**Characteristics**: Slowest, uses real browser/environment
**Coverage target**: Critical user paths only

```javascript
test("user can complete checkout", async ({ page }) => {
  await page.goto("/products");
  await page.click('[data-testid="add-to-cart"]');
  await page.click('[data-testid="checkout"]');
  await expect(page.locator('[data-testid="order-confirmation"]')).toBeVisible();
});
```

### Performance Tests

**Tools**: k6, JMeter, Locust, Artillery

### Security Tests

**Types**: Dependency scanning (npm audit, Snyk), SAST, DAST, penetration testing

## Best Practices

### AAA Pattern (Arrange-Act-Assert)

```python
def test_user_creation():
    # Arrange: Set up test data
    email = "test@example.com"
    password = "secure123"

    # Act: Execute functionality
    user = create_user(email, password)

    # Assert: Verify results
    assert user.email == email
    assert user.password != password  # Should be hashed
```

### Focused Assertions

- Prefer one assertion per test when practical
- Multiple related assertions OK for object state
- Use descriptive failure messages

### Test Independence

- Each test runs independently
- Use fixtures/setup for shared state
- Clean up after tests
- Don't rely on test execution order

### Mocking

**When to Mock**: External services, slow operations, non-deterministic behavior

**When NOT to Mock**: Simple functions, internal logic, integration tests

```python
from unittest.mock import patch

def test_fetch_user_data():
    with patch('api_client.get') as mock_get:
        mock_get.return_value = {'id': 1, 'name': 'John'}
        result = fetch_user_data(user_id=1)
        assert result['name'] == 'John'
        mock_get.assert_called_once_with('/users/1')
```

### Coverage

**Aim for 80%+ on critical code**:

- Focus on business logic, not boilerplate
- Skip trivial getters/setters
- Test edge cases and error paths

**Measure coverage**:

```bash
npx jest --coverage           # JavaScript
pytest --cov=src              # Python
mvn test jacoco:report        # Java
go test -coverprofile=coverage.out  # Go
```

### Test Data

**Fixtures**:

```python
@pytest.fixture
def sample_user():
    return {'email': 'test@example.com', 'name': 'Test User'}

def test_user_validation(sample_user):
    assert validate_user(sample_user) is True
```

**Factories**:

```python
class UserFactory:
    @staticmethod
    def create_user(**kwargs):
        defaults = {'email': 'test@example.com', 'active': True}
        return User(**{**defaults, **kwargs})
```

## Continuous Testing

### CI/CD Integration

Run tests on:

- Pull requests
- Commits to main/develop
- Scheduled (nightly) for full suite

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm test
```

### Test Pyramid

Maintain healthy ratio:

- **70%** Unit tests (fast, isolated)
- **20%** Integration tests (medium speed)
- **10%** E2E tests (slow, brittle)

### Flaky Tests

**Causes**: Race conditions, external dependencies, time-based logic, insufficient waits

**Solutions**: Add proper waits, mock dependencies, use fixed time, quarantine until fixed

## Migration and Refactoring

When adding tests to legacy code:

1. **Create checklist** in `.context/testing-migration.md`:

```markdown
## Testing Migration Checklist

### Phase 1: Critical Paths

- [ ] User authentication
- [ ] Payment processing

### Phase 2: Core Business Logic

- [ ] Order calculation
- [ ] Inventory management
```

2. **Fix incrementally**: One module/feature at a time
3. **Track progress**: Update checklist as tests added
4. **Document coverage**: Note areas lacking tests

## Project-Specific Testing

Document in `.context/testing-strategy.md`:

- Required coverage thresholds
- Critical test scenarios
- Testing environment setup
- CI/CD pipeline details
- Known testing challenges

---

## Advanced Topics

### Testing AI-Generated Code and Non-Deterministic Systems

Traditional TDD assumes deterministic outputs: `same_input → same_output`. This assumption breaks when testing:

- **AI-generated code**: AI produces valid variations for identical inputs
- **AI agents**: Non-deterministic decision-making and outputs
- **ML models**: Probabilistic predictions, temperature-based sampling
- **Non-deterministic algorithms**: Randomized algorithms, concurrent operations

**Problem**: Exact-match assertions fail for valid variations, creating brittle tests and false failures.

**Solution**: Use **flexible assertions** that verify semantic correctness while accepting acceptable variations.

**When to Use Flexible Assertions**:
- AI-generated text (comments, documentation, summaries)
- Code variations (variable naming, formatting, equivalent implementations)
- Reasoning explanations (where exact wording isn't critical)
- Multiple valid solution paths (when several approaches are equally correct)

**When NOT to Use** (Always Exact):
- Security-critical operations (authentication, authorization, input validation)
- API contracts and file formats (external integrations depend on exactness)
- Performance SLAs (response times, throughput benchmarks)
- Regulatory compliance (financial calculations, medical data)
- Cryptographic operations (hashing, encryption, signing)

**Four Flexible Assertion Patterns**:
1. **Semantic Similarity Evaluation**: Compare meaning, not exact strings (cosine similarity, embeddings)
2. **Behavioral Correctness Assessment**: Verify outputs and side effects, ignore implementation details
3. **Quality of Reasoning Verification**: Assess logical coherence and correctness of explanations
4. **Multiple Valid Solution Path Support**: Accept any solution from predefined valid set

**Comprehensive Guide**: See `flexible-testing-guide.md` (SOP) for:
- Detailed explanation of AI non-determinism and why traditional assertions fail
- Complete decision tree for choosing flexible vs exact assertions
- Implementation details for all four patterns with language-specific examples
- Safety mechanisms preventing abuse and quality erosion
- Integration with RPTC TDD workflow (`/rptc:feat`)

**Key Principle**: Flexible assertions are a **precision tool** for inherent non-determinism, not a quality compromise. Security, compliance, and contracts ALWAYS require exact assertions.

---

_Testing Guide last updated: 2025-01-25_
_Version: 1.1.0 (Phase 1 Enhancement) + Advanced Topics (Phase 5)_
