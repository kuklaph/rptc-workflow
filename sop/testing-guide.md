# Testing Guide

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
