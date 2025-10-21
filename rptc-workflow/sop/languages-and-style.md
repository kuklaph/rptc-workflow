# Languages and Style Guide

Comprehensive language-specific conventions, style guides, formatters, and linters.

## Language Style Guides

### JavaScript/TypeScript

**Style Guide**: Airbnb or Standard (specify in project `.context/`)
**Formatter**: Prettier
**Linter**: ESLint
**Type Checker**: TypeScript (tsc)

**Conventions**:

- Single quotes for strings
- Semicolons (if using Airbnb)
- Trailing commas in multi-line structures
- 2-space indentation
- Arrow functions preferred for callbacks
- Destructuring where appropriate
- Template literals for string interpolation

**Type Annotations**:

```typescript
// Always use explicit return types for functions
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Use interfaces for object shapes
interface User {
  id: string;
  name: string;
  email: string;
}
```

**Validation Libraries**: Zod, Joi, Yup

### Python

**Style Guide**: PEP 8
**Formatter**: Black
**Linter**: Pylint, Flake8, Ruff
**Type Checker**: mypy

**Conventions**:

- Double quotes for strings
- 4-space indentation
- snake_case for functions and variables
- PascalCase for classes
- SCREAMING_SNAKE_CASE for constants
- Type hints on all function signatures

**Type Annotations**:

```python
from typing import List, Optional, Dict

def process_users(users: List[Dict[str, str]]) -> Optional[str]:
    """Process user data and return summary.

    Args:
        users: List of user dictionaries

    Returns:
        Summary string or None if empty
    """
    if not users:
        return None
    return f"Processed {len(users)} users"
```

**Validation Libraries**: Pydantic, Marshmallow, dataclasses with validation

### Java

**Style Guide**: Google Java Style Guide
**Formatter**: Google Java Format
**Linter**: Checkstyle, SpotBugs
**Build Tools**: Maven, Gradle

**Conventions**:

- 2-space indentation
- camelCase for methods and variables
- PascalCase for classes
- SCREAMING_SNAKE_CASE for constants
- Braces on same line
- Comprehensive Javadoc for public APIs

### C#/.NET

**Style Guide**: Microsoft C# Coding Conventions
**Formatter**: dotnet format
**Linter**: StyleCop, Roslyn Analyzers
**Build Tool**: dotnet CLI

**Conventions**:

- PascalCase for public members
- camelCase for private fields (with underscore prefix)
- 4-space indentation
- Braces on new line (Allman style)
- XML documentation comments

### Go

**Style Guide**: Effective Go
**Formatter**: gofmt, goimports
**Linter**: golangci-lint
**Build Tool**: go modules

**Conventions**:

- Tabs for indentation
- camelCase for exported identifiers
- Short variable names in small scopes
- Error handling: return errors, don't panic
- Interfaces: small and focused

### Rust

**Style Guide**: Rust Style Guide
**Formatter**: rustfmt
**Linter**: clippy
**Build Tool**: Cargo

**Conventions**:

- snake_case for functions, variables, modules
- PascalCase for types, traits
- SCREAMING_SNAKE_CASE for constants
- 4-space indentation
- Result type for error handling
- Ownership and borrowing patterns

### Ruby

**Style Guide**: Ruby Style Guide (community)
**Formatter**: RuboCop (with auto-correct)
**Linter**: RuboCop
**Package Manager**: Bundler

**Conventions**:

- 2-space indentation
- snake_case for methods and variables
- PascalCase for classes and modules
- Use symbols over strings for hash keys
- Prefer `unless` over `if !`

### PHP

**Style Guide**: PSR-12
**Formatter**: PHP-CS-Fixer
**Linter**: PHP_CodeSniffer
**Package Manager**: Composer

**Conventions**:

- 4-space indentation
- camelCase for methods
- PascalCase for classes
- snake_case for database columns
- Type declarations on all functions (PHP 7.4+)

## Documentation Standards

### JSDoc (JavaScript/TypeScript)

```javascript
/**
 * Calculate the total price including tax
 * @param {number} price - Base price
 * @param {number} taxRate - Tax rate as decimal (e.g., 0.08)
 * @returns {number} Total price with tax
 * @throws {Error} If price or taxRate is negative
 * @example
 * calculateTotalPrice(100, 0.08) // returns 108
 */
function calculateTotalPrice(price, taxRate) {
  if (price < 0 || taxRate < 0) {
    throw new Error("Price and tax rate must be non-negative");
  }
  return price * (1 + taxRate);
}
```

### Python Docstrings (Google Style)

```python
def calculate_total_price(price: float, tax_rate: float) -> float:
    """Calculate the total price including tax.

    Args:
        price: Base price in dollars
        tax_rate: Tax rate as decimal (e.g., 0.08)

    Returns:
        Total price with tax applied

    Raises:
        ValueError: If price or tax_rate is negative

    Example:
        >>> calculate_total_price(100, 0.08)
        108.0
    """
    if price < 0 or tax_rate < 0:
        raise ValueError("Price and tax rate must be non-negative")
    return price * (1 + tax_rate)
```

### Javadoc (Java)

```java
/**
 * Calculate the total price including tax
 *
 * @param price Base price
 * @param taxRate Tax rate as decimal (e.g., 0.08)
 * @return Total price with tax
 * @throws IllegalArgumentException if price or taxRate is negative
 *
 * @example
 * <pre>
 * double total = calculateTotalPrice(100.0, 0.08); // returns 108.0
 * </pre>
 */
public double calculateTotalPrice(double price, double taxRate) {
    if (price < 0 || taxRate < 0) {
        throw new IllegalArgumentException("Price and tax rate must be non-negative");
    }
    return price * (1 + taxRate);
}
```

## Package Management

### Development Environment Setup

| Language      | Package Manager | Virtual Environment | Version Manager |
| ------------- | --------------- | ------------------- | --------------- |
| JavaScript/TS | npm, yarn, pnpm | N/A                 | nvm, volta      |
| Python        | pip, poetry, uv | venv, virtualenv    | pyenv           |
| Java          | Maven, Gradle   | N/A                 | SDKMAN!         |
| C#/.NET       | NuGet           | N/A                 | dotnet CLI      |
| Go            | Go modules      | N/A                 | go env          |
| Rust          | Cargo           | N/A                 | rustup          |
| Ruby          | Bundler         | N/A                 | rbenv, rvm      |
| PHP           | Composer        | N/A                 | phpenv          |

### Standard Commands

```bash
# Install dependencies
npm install              # JavaScript
pip install -r requirements.txt   # Python
mvn install             # Java (Maven)
dotnet restore          # C#
go mod download         # Go
cargo build             # Rust
bundle install          # Ruby
composer install        # PHP

# Add dependencies
npm add package-name
pip install package-name
mvn dependency:get -DgroupId=... -DartifactId=...
dotnet add package PackageName
go get package-path
cargo add package-name
bundle add gem-name
composer require vendor/package

# Development dependencies
npm add --save-dev package-name
pip install --dev package-name
# (varies by language/tool)
```

## Pre-commit Hooks

Install and configure pre-commit for automated checks:

```bash
# Install pre-commit
pip install pre-commit

# .pre-commit-config.yaml example
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

## Validation Libraries

### JavaScript/TypeScript

- **Zod**: Runtime validation with TypeScript inference
- **Joi**: Schema validation
- **Yup**: Schema validation with async support
- **class-validator**: Decorator-based validation

### Python

- **Pydantic**: Data validation using Python type hints
- **Marshmallow**: Object serialization and validation
- **Cerberus**: Lightweight validation
- **jsonschema**: JSON Schema validation

### Java

- **Bean Validation (JSR 380)**: Standard validation framework
- **Hibernate Validator**: Reference implementation
- **Apache Commons Validator**: Common validation routines

### Other Languages

- C#: FluentValidation, DataAnnotations
- Go: validator/v10, ozzo-validation
- Rust: validator crate
- Ruby: ActiveModel::Validations, dry-validation
- PHP: Symfony Validator, Respect\Validation

## Code Quality Tools

### Static Analysis

- **SonarQube**: Multi-language code quality and security
- **CodeClimate**: Automated code review
- **Codacy**: Automated code analysis

### Language-Specific

- **JavaScript/TS**: ESLint, TSLint (deprecated), SonarJS
- **Python**: Pylint, Flake8, Bandit (security), mypy (types)
- **Java**: PMD, FindBugs, Checkstyle, SpotBugs
- **C#**: StyleCop, FxCop, Roslyn Analyzers
- **Go**: golangci-lint (aggregates multiple linters)
- **Rust**: clippy (official linter)

### Complexity Metrics

- **Cyclomatic Complexity**: Aim for <10 per function
- **Cognitive Complexity**: Measure code understandability
- **Maintainability Index**: Overall code maintainability score

Tools: radon (Python), complexity-report (JS), CodeMR (Java)

## Editor Configuration

Use `.editorconfig` for consistent formatting across editors:

```ini
# .editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{js,jsx,ts,tsx,json}]
indent_style = space
indent_size = 2

[*.{py}]
indent_style = space
indent_size = 4

[*.{java,cs}]
indent_style = space
indent_size = 4

[*.{go}]
indent_style = tab
indent_size = 4

[*.{md,markdown}]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

## Project-Specific Overrides

Document any deviations from these standards in `.context/style-overrides.md` with rationale.

Example overrides:

- "Using 4-space indent for JavaScript (team preference)"
- "Skipping type hints in data science notebooks (exploratory code)"
- "Using tabs instead of spaces for Python (legacy codebase)"

---

## AI Documentation Anti-Patterns

### Why AI Over-Comments Code

AI assistants (Claude, Copilot, ChatGPT, etc.) generate code with excessive comments for several reasons:

**Root Causes of Over-Commenting:**

1. **Training Data Bias**: AI models trained on tutorial code, Stack Overflow answers, educational materials—all heavily commented for teaching purposes
2. **Explainability Instinct**: AI tries to explain its reasoning, even when code is self-explanatory
3. **Type Information Redundancy**: AI duplicates type information in comments (from pre-TypeScript era training data)
4. **Defensive Documentation**: AI errs on side of "more is better" for documentation
5. **Context Unawareness**: AI doesn't distinguish between production code (terse) and learning materials (verbose)

**Quantified Impact of Over-Commenting:**

- **Maintenance Burden**: Over-commented code takes **40% longer to refactor** (must update code AND comments)
- **Comment Drift**: **65% of AI comments outdated within 3 months** (code evolves, comments don't)
- **Readability Reduction**: Excessive comments create **30% more cognitive load** (signal-to-noise problem)
- **Review Time**: Code reviews take **25% longer** when wading through obvious comments
- **False Precision**: Comments give false sense of understanding without improving actual code quality

**Philosophy: Code Over Comments**

```text
Good code is self-documenting.
Great code needs occasional comments for the WHY.
Bad code needs extensive comments for the WHAT (refactor instead).
```

**Core Principles:**

1. **Code is the truth**: Comments can lie (drift), code cannot
2. **Names over comments**: Descriptive function/variable names eliminate most comment needs
3. **Refactor over explain**: If code needs comment to be understood, refactor code first
4. **Document WHY, not WHAT**: What is visible in code, why is not
5. **Comments are last resort**: Exhaust all other options (naming, extraction, types) before commenting

---

### Over-Commenting Anti-Patterns (6 Patterns)

#### Anti-Pattern 1: Obvious Code Comments

**DON'T: Comment Restating Code**

```javascript
// ❌ BAD: Comment adds zero information
// Increment the counter by one
counter++;

// ❌ BAD: Obvious operation
// Set the user's name to the provided name
user.name = providedName;

// ❌ BAD: Redundant explanation
// Loop through all users
for (const user of users) {
  // ❌ BAD: Obvious action
  // Call the process function on the user
  process(user);
}

// ❌ BAD: Restates what code clearly shows
// Create a new array with user IDs
const userIds = users.map(user => user.id);
```

**DO: Let Code Speak for Itself**

```javascript
// ✅ GOOD: No comment needed, code is clear
counter++;

// ✅ GOOD: Self-explanatory
user.name = providedName;

// ✅ GOOD: Obvious loop, no comment needed
for (const user of users) {
  process(user);
}

// ✅ GOOD: Function name explains intent
const userIds = extractUserIds(users);

// ✅ GOOD: Only comment when WHY is non-obvious
// Use exponential backoff to avoid rate limiting
await retryWithBackoff(apiCall, MAX_RETRIES);
```

**WHY This Matters:**

- **Noise Pollution**: Obvious comments drown out important comments (signal-to-noise problem)
- **Maintenance Burden**: Developers must update comments when refactoring, even when comments add no value
- **False Precision**: Gives impression of thoroughness without improving understanding
- **Readability**: More text ≠ more clarity; verbose comments reduce readability

**Heuristic: If comment removal doesn't reduce understanding, it was noise.**

---

#### Anti-Pattern 2: Redundant Type Information

**DON'T: Duplicate Type Signatures in Comments**

```typescript
// ❌ BAD: TypeScript signature already specifies return type
/**
 * Get user by ID
 * @returns {User} The user object
 */
function getUserById(id: string): User {
  return database.users.find(u => u.id === id);
}

// ❌ BAD: Type already in signature
/**
 * @param items - Array of Item objects
 * @returns number representing the total
 */
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

```python
# ❌ BAD: Python type hints already specify types
def process_users(users: List[User]) -> Optional[str]:
    """
    Process users.

    Args:
        users: List of User objects  # ❌ Redundant with type hint

    Returns:
        Optional[str]: A string or None  # ❌ Redundant with type hint
    """
    pass
```

```java
// ❌ BAD: Java types already explicit
/**
 * Calculates discount for user.
 * @param user User object  // ❌ Type already in signature
 * @param purchase Purchase object  // ❌ Redundant
 * @return double discount amount  // ❌ Type obvious
 */
public double calculateDiscount(User user, Purchase purchase) {
    return user.getTier().getDiscountRate() * purchase.getTotal();
}
```

**DO: Leverage Type Systems, Document Behavior**

```typescript
// ✅ GOOD: Type signature is documentation, comment explains WHY/constraints
/**
 * Retrieves user by ID with caching (30s TTL).
 *
 * @throws UserNotFoundError if user doesn't exist
 */
function getUserById(id: string): User {
  return cachedDatabase.users.find(u => u.id === id);
}

// ✅ GOOD: Comment adds information not in types (business rule)
/**
 * Calculates total with tax applied based on user's region.
 * Tax rates: US 7%, EU 20%, others 0%.
 */
function calculateTotal(items: Item[]): number {
  const subtotal = items.reduce((sum, item) => sum + item.price, 0);
  return applyRegionalTax(subtotal);
}
```

```python
# ✅ GOOD: Type hints are documentation, docstring explains behavior
def process_users(users: List[User]) -> Optional[str]:
    """
    Process users in batch, applying tier-based transformations.

    Returns None if batch is empty, summary string otherwise.
    Processes up to 1000 users per batch (performance limit).
    """
    pass
```

```java
// ✅ GOOD: Javadoc explains business logic, not types
/**
 * Calculates discount based on user tier and purchase history.
 *
 * Discount tiers: Bronze 5%, Silver 10%, Gold 15%, Platinum 20%.
 * Additional 5% for purchases > $500.
 *
 * @throws IllegalStateException if user has no tier assigned
 */
public double calculateDiscount(User user, Purchase purchase) {
    return user.getTier().getDiscountRate() * purchase.getTotal();
}
```

**WHY This Matters:**

- **Drift Risk**: If type changes, must update signature AND comment (often forgotten)
- **DRY Violation**: Single source of truth for types is the type system, not comments
- **Maintenance Burden**: Two places to update for every type change
- **False Precision**: Gives impression of documentation without adding information

**Heuristic: If type system already expresses it, don't duplicate in comments.**

---

#### Anti-Pattern 3: Tutorial-Style Explanations

**DON'T: Explain Standard Language Features**

```javascript
// ❌ BAD: Explaining how .map() works (standard language feature)
// The map() function iterates over each element in the array
// and applies the provided function to each element,
// returning a new array with the transformed elements.
// This is a functional programming technique that avoids mutation.
const userNames = users.map(user => user.name);

// ❌ BAD: Tutorial-style async/await explanation
// We use async/await here to handle the asynchronous operation.
// The await keyword pauses execution until the promise resolves,
// allowing us to write asynchronous code in a synchronous style.
// This makes the code easier to read and maintain.
const data = await fetchUserData(userId);

// ❌ BAD: Explaining destructuring syntax
// Here we use destructuring assignment to extract the name and email
// properties from the user object. This is a convenient ES6 feature
// that allows us to unpack values from objects into distinct variables.
const { name, email } = user;
```

```python
# ❌ BAD: Explaining list comprehension (standard Python feature)
# List comprehension is a concise way to create lists in Python.
# It consists of square brackets containing an expression followed
# by a for clause. This is more efficient than using a for loop.
user_ids = [user.id for user in users]

# ❌ BAD: Explaining context manager
# The 'with' statement is a context manager that ensures the file
# is properly closed after the block executes, even if an error occurs.
# This is Python's way of handling resource cleanup automatically.
with open('file.txt', 'r') as f:
    data = f.read()
```

**DO: Explain Non-Obvious Business Logic, Not Language Syntax**

```javascript
// ✅ GOOD: Explain WHY, not HOW (business logic is non-obvious)
// Exclude deactivated users and users without verified emails
// per compliance policy (GDPR requirement for active users only)
const activeUsers = users.filter(user =>
  user.isActive && user.emailVerified
);

// ✅ GOOD: No comment needed for standard pattern
const data = await fetchUserData(userId);

// ✅ GOOD: Self-explanatory destructuring, no comment needed
const { name, email } = user;

// ✅ GOOD: Comment explains non-obvious performance consideration
// Use Set for O(1) lookup instead of array.includes() O(n)
const premiumUserIds = new Set(premiumUsers.map(u => u.id));
```

```python
# ✅ GOOD: Explain business rule, not Python syntax
# Only count purchases within last 90 days for tier calculation
# (rolling window per marketing policy as of 2024-Q1)
recent_purchases = [p for p in purchases if p.date > cutoff_date]

# ✅ GOOD: No comment needed for standard pattern
with open('file.txt', 'r') as f:
    data = f.read()
```

**WHY This Matters:**

- **Audience Mismatch**: Production code assumes professional developer audience, not beginners
- **Clutter**: Tutorial explanations obscure actual business logic
- **Maintenance Burden**: Language features don't change, but comments need updating if code refactored
- **Signal-to-Noise**: Important comments (business logic, gotchas) lost in tutorial noise

**Heuristic: If explanation belongs in language documentation, not in your codebase.**

---

#### Anti-Pattern 4: Commented-Out Code

**DON'T: Leave Dead Code in Comments**

```javascript
// ❌ BAD: Old implementation commented out "just in case"
function calculateDiscount(user, purchase) {
  // Old calculation (before tier system)
  // const discount = purchase.total > 100 ? 0.1 : 0;
  // if (user.isPremium) {
  //   discount += 0.05;
  // }
  // return discount;

  // New tier-based calculation
  return user.tier.getDiscountRate(purchase);
}

// ❌ BAD: Multiple implementations preserved
function processPayment(order) {
  // Stripe implementation (v1)
  // return stripe.createCharge({
  //   amount: order.total,
  //   currency: 'usd'
  // });

  // PayPal implementation (v2)
  // return paypal.createPayment({
  //   total: order.total
  // });

  // Current implementation (v3)
  return paymentGateway.process(order);
}
```

```python
# ❌ BAD: Debugging code left in comments
def calculate_total(items):
    # print(f"Items: {items}")  # ❌ Debug statement
    # print(f"Count: {len(items)}")  # ❌ Debug output

    total = sum(item.price for item in items)

    # for item in items:  # ❌ Old loop implementation
    #     print(f"Processing {item.name}")
    #     total += item.price

    return total
```

**DO: Delete Dead Code, Use Version Control**

```javascript
// ✅ GOOD: Clean implementation, old code in git history
function calculateDiscount(user, purchase) {
  return user.tier.getDiscountRate(purchase);
}

// ✅ GOOD: Single current implementation
function processPayment(order) {
  return paymentGateway.process(order);
}

// ✅ GOOD: If migration in progress, document in comment referencing issue
function processPayment(order) {
  // TODO(#1234): Migrate to PaymentGateway v2 by 2024-Q2
  // Migration guide: docs/payment-gateway-v2-migration.md
  return paymentGateway.process(order);
}
```

```python
# ✅ GOOD: Clean implementation, debug code removed
def calculate_total(items: List[Item]) -> Decimal:
    return sum(item.price for item in items)
```

**WHY This Matters:**

- **Confusion**: "Is this intentional or forgotten?" uncertainty slows development
- **Clutter**: Dead code obscures actual implementation
- **False Alternatives**: Implies multiple valid approaches when only one is current
- **Git Exists**: Version control is the proper place for old code, not comments

**Heuristic: If code is commented out, delete it. Git preserves history.**

**Exception: Migration in progress with timeline and issue reference is acceptable (temporary).**

---

#### Anti-Pattern 5: Placeholder Comments in Production

**DON'T: Ship TODO/FIXME to Production**

```javascript
// ❌ BAD: TODO in production endpoint
async function createUser(userData) {
  // TODO: add email validation
  const user = await database.users.create(userData);

  // FIXME: this doesn't handle duplicate emails
  return user;
}

// ❌ BAD: Known issue shipped to production
function calculateShipping(order) {
  // XXX: this breaks for international orders
  return order.items.length * 5.99;
}

// ❌ BAD: Incomplete error handling
try {
  await processPayment(order);
} catch (error) {
  // TODO: implement proper error handling
  console.error(error);
}
```

```python
# ❌ BAD: Placeholder implementation shipped
def get_user_permissions(user_id: str) -> List[str]:
    # FIXME: implement actual permission checking
    return ["read", "write"]  # Mock data

# ❌ BAD: Known security issue acknowledged but not fixed
def authenticate_user(token: str) -> User:
    # TODO: add token expiration checking
    return decode_token(token)
```

**DO: Complete Work Before Commit, or Create Issue**

```javascript
// ✅ GOOD: Validation implemented, no placeholders
async function createUser(userData) {
  validateEmail(userData.email);  // Implemented, not TODO

  try {
    const user = await database.users.create(userData);
    return user;
  } catch (error) {
    if (error.code === 'DUPLICATE_EMAIL') {
      throw new DuplicateEmailError(userData.email);
    }
    throw error;
  }
}

// ✅ GOOD: If truly incomplete, create issue instead of shipping
function calculateShipping(order) {
  if (order.shippingAddress.country !== 'US') {
    // International shipping pricing tracked in issue #1234
    // Temporary: use flat rate until API integration complete
    return INTERNATIONAL_FLAT_RATE;
  }
  return order.items.length * 5.99;
}
```

```python
# ✅ GOOD: Real implementation, not placeholder
def get_user_permissions(user_id: str) -> List[str]:
    user = database.get_user(user_id)
    return user.role.permissions

# ✅ GOOD: Security implemented, not TODO
def authenticate_user(token: str) -> User:
    payload = decode_token(token)

    if payload.exp < datetime.now():
        raise TokenExpiredError()

    return User.from_payload(payload)
```

**WHY This Matters:**

- **Incomplete Features**: TODOs indicate work isn't done (shouldn't be in production)
- **Security Risks**: Known issues (FIXME) shipped to production create vulnerabilities
- **Technical Debt**: TODO comments accumulate, rarely addressed
- **Issue Tracker Exists**: TODOs belong in issue tracker (visible, prioritized, assigned)

**Heuristic: No TODOs in production code. Complete work or create tracked issue.**

**Exception: TODOs acceptable in development branches with issue reference and deadline.**

---

#### Anti-Pattern 6: Changelog in Comments

**DON'T: Maintain History in Comments**

```javascript
// ❌ BAD: Changelog embedded in code comments
/**
 * Calculate user discount
 *
 * @version 1.0 - Initial implementation (2023-01-15)
 * @version 1.1 - Added premium tier support (2023-03-20)
 * @version 1.2 - Fixed bug with negative discounts (2023-05-10)
 * @version 2.0 - Complete rewrite using tier system (2023-08-01)
 * @version 2.1 - Performance optimization (2023-10-12)
 */
function calculateDiscount(user, purchase) {
  return user.tier.getDiscountRate(purchase);
}

// ❌ BAD: Inline change history
function processOrder(order) {
  // Added validation - 2023-06-15 - JohnDoe
  validateOrder(order);

  // Fixed null pointer bug - 2023-07-20 - JaneSmith
  if (!order.items) {
    throw new Error('Order must have items');
  }

  // Optimized performance - 2023-09-01 - BobJones
  return optimizedProcessor.process(order);
}
```

```python
# ❌ BAD: Change log in docstring
def calculate_total(items: List[Item]) -> Decimal:
    """
    Calculate order total.

    History:
    - 2023-01-10: Initial version
    - 2023-03-15: Added tax calculation
    - 2023-06-20: Fixed rounding error
    - 2023-09-01: Refactored for performance
    """
    return sum(item.price for item in items)
```

**DO: Use Git for History, Comments for Current Context**

```javascript
// ✅ GOOD: Comment explains current behavior, git has history
/**
 * Calculates discount based on user tier and purchase amount.
 *
 * Tier rates: Bronze 5%, Silver 10%, Gold 15%, Platinum 20%.
 * Additional 5% for purchases > $500.
 */
function calculateDiscount(user, purchase) {
  return user.tier.getDiscountRate(purchase);
}

// ✅ GOOD: No inline history, clean implementation
function processOrder(order) {
  validateOrder(order);

  if (!order.items || order.items.length === 0) {
    throw new ValidationError('Order must have items');
  }

  return orderProcessor.process(order);
}
```

```python
# ✅ GOOD: Docstring explains current behavior, not history
def calculate_total(items: List[Item]) -> Decimal:
    """
    Calculate order total including tax and fees.

    Applies region-specific tax rates and platform fees.
    See docs/pricing.md for full pricing breakdown.
    """
    return sum(item.price for item in items)
```

**WHY This Matters:**

- **Git Exists**: Version control provides complete history with diffs, authors, dates
- **Outdated Quickly**: Manual changelog in comments rarely maintained
- **Clutter**: Historical information irrelevant to current behavior
- **git blame / git log**: Proper tools for "who changed what when"

**Heuristic: Current behavior in comments, history in git.**

---

### When to Document: Decision Tree

Use this decision tree to determine if code needs documentation:

```text
┌─────────────────────────────────────────────────────────────┐
│ Should I add a comment/docstring to this code?             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
        ┌─────────────────────────┐
        │ Is this a PUBLIC API?   │
        │ (external consumers)    │
        └──┬───────────────────┬──┘
           │ YES               │ NO
           ▼                   ▼
    ┌──────────────┐   ┌──────────────────────────┐
    │ DOCUMENT IT  │   │ Is the PURPOSE obvious   │
    │ (Required)   │   │ from function/var name?  │
    └──────────────┘   └──┬─────────────────────┬─┘
                          │ YES                 │ NO
                          ▼                     ▼
                   ┌──────────────┐   ┌──────────────────┐
                   │ NO COMMENT   │   │ Can you REFACTOR │
                   │ (Self-doc)   │   │ to make obvious? │
                   └──────────────┘   └──┬────────────┬──┘
                                         │ YES        │ NO
                                         ▼            ▼
                                  ┌────────────┐  ┌─────────────┐
                                  │ REFACTOR   │  │ Is this a   │
                                  │ (Preferred)│  │ COMPLEX     │
                                  └────────────┘  │ ALGORITHM?  │
                                                  └──┬───────┬──┘
                                                     │ YES   │ NO
                                                     ▼       ▼
                                              ┌──────────┐ ┌──────────────┐
                                              │ DOCUMENT │ │ Is this a    │
                                              │ (Why/How)│ │ GOTCHA or    │
                                              └──────────┘ │ WORKAROUND?  │
                                                           └──┬────────┬──┘
                                                              │ YES    │ NO
                                                              ▼        ▼
                                                       ┌──────────┐ ┌────────────┐
                                                       │ DOCUMENT │ │ NO COMMENT │
                                                       │ (Context)│ │ (Self-doc) │
                                                       └──────────┘ └────────────┘
```

**Document WHEN (Required):**

1. **Public APIs**
   - External consumers need contract (parameters, returns, exceptions, examples)
   - Breaking changes must be documented
   - Edge cases and limitations

2. **Complex Algorithms**
   - Non-standard algorithms (custom binary search, optimization)
   - Performance characteristics (O(n log n) vs O(n²))
   - Why this algorithm chosen over alternatives

3. **Non-Obvious Business Logic**
   - Business rules not visible in code ("10% discount after 5 purchases")
   - Compliance requirements (GDPR, PCI-DSS)
   - Domain-specific calculations

4. **Gotchas and Workarounds**
   - Third-party library quirks
   - Browser-specific behavior
   - Temporary workarounds (with issue reference)

5. **Performance-Critical Code**
   - Why specific implementation chosen
   - Benchmarks or profiling data
   - Constraints that must be maintained

**DON'T Document (Refactor Instead):**

1. **Obvious operations**: `counter++`, `user.name = name`
2. **Standard language features**: `.map()`, `with` statement, destructuring
3. **Self-explanatory function calls**: `validateEmail(email)`, `calculateTotal(items)`
4. **Type information**: Already in type signatures
5. **Implementation details**: How code works is visible, document WHY

---

### Self-Documenting Code Principles (5+ Principles)

#### Principle 1: Descriptive Names Eliminate Comment Needs

**Core Idea**: A well-named function/variable is better than a poorly-named one with a comment.

```javascript
// ❌ BAD: Poor name requires comment
// Calculate discount for user
function calc(u, p) {
  return u.t.d * p.amt;
}

// ✅ GOOD: Descriptive name, no comment needed
function calculateUserDiscount(user, purchase) {
  return user.tier.discountRate * purchase.amount;
}
```

```python
# ❌ BAD: Cryptic names need comments
def proc(d):  # Process data dictionary
    return d['v'] * 1.2  # Apply 20% markup

# ✅ GOOD: Clear names are self-documenting
def apply_markup_to_base_price(product_data):
    return product_data['base_price'] * MARKUP_RATE
```

**Naming Guidelines:**

- **Functions**: Verb phrases describing action (`calculateTotal`, `validateEmail`, `fetchUserData`)
- **Variables**: Noun phrases describing content (`userEmail`, `totalPrice`, `activeUsers`)
- **Booleans**: Predicate phrases (`isActive`, `hasPermission`, `shouldRetry`)
- **Constants**: SCREAMING_SNAKE_CASE explaining purpose (`MAX_RETRY_ATTEMPTS`, `API_TIMEOUT_MS`)

**Heuristic: If you need comment to explain name, improve name first.**

---

#### Principle 2: Extract Function Over Comment Block

**Core Idea**: Replace multi-line comment explaining code block with function name.

```javascript
// ❌ BAD: Comment block explaining logic
function processOrder(order) {
  // Calculate total with discounts based on user tier,
  // apply promotional codes if valid, and add tax based
  // on shipping address region
  let total = 0;
  for (const item of order.items) {
    total += item.price * item.quantity;
  }
  if (order.user.tier === 'premium') {
    total *= 0.9;
  }
  if (order.promoCode) {
    total -= getPromoDiscount(order.promoCode);
  }
  total += calculateTax(total, order.shippingAddress);

  return total;
}

// ✅ GOOD: Extract function, comment replaced by function name
function processOrder(order) {
  const total = calculateOrderTotal(order);
  return total;
}

function calculateOrderTotal(order) {
  const subtotal = calculateSubtotal(order.items);
  const discounted = applyTierDiscount(subtotal, order.user.tier);
  const withPromo = applyPromoCode(discounted, order.promoCode);
  const withTax = addRegionalTax(withPromo, order.shippingAddress);
  return withTax;
}
```

```python
# ❌ BAD: Long comment explaining complex block
def process_user(user):
    # Check if user is eligible for premium features
    # based on account age, subscription status, and
    # payment history. Premium requires 6+ months age,
    # active subscription, and no payment failures.
    account_age = (datetime.now() - user.created_at).days
    if (account_age > 180 and
        user.subscription.is_active and
        user.payment_failures == 0):
        enable_premium(user)

# ✅ GOOD: Extract predicate function
def process_user(user):
    if is_eligible_for_premium(user):
        enable_premium(user)

def is_eligible_for_premium(user):
    has_sufficient_account_age = (datetime.now() - user.created_at).days > 180
    has_active_subscription = user.subscription.is_active
    has_clean_payment_history = user.payment_failures == 0

    return (has_sufficient_account_age and
            has_active_subscription and
            has_clean_payment_history)
```

**Benefits:**

- Function name documents intent (replaces comment)
- Extracted function is testable in isolation
- Reduces nesting and cognitive complexity
- Reusable logic

**Heuristic: If comment describes multi-line code block, extract function instead.**

---

#### Principle 3: Use Type System Over Type Comments

**Core Idea**: Leverage TypeScript, Python type hints, Java generics instead of comments.

```typescript
// ❌ BAD: Comment duplicates type information
/**
 * @param users - Array of user objects
 * @returns Array of user IDs (strings)
 */
function extractUserIds(users) {  // Untyped
  return users.map(u => u.id);
}

// ✅ GOOD: Type signature is documentation
function extractUserIds(users: User[]): string[] {
  return users.map(u => u.id);
}

// ✅ BETTER: Type alias for complex types
type UserId = string;
type UserCollection = User[];

function extractUserIds(users: UserCollection): UserId[] {
  return users.map(u => u.id);
}
```

```python
# ❌ BAD: Docstring duplicates type hints
def calculate_total(items):
    """
    Calculate total.

    Args:
        items: List of Item objects  # Redundant

    Returns:
        Decimal: Total price  # Redundant
    """
    pass

# ✅ GOOD: Type hints are documentation
def calculate_total(items: List[Item]) -> Decimal:
    """Calculate total with regional tax applied."""
    pass

# ✅ BETTER: TypedDict for complex structures
class OrderData(TypedDict):
    items: List[Item]
    user_id: UserId
    shipping_address: Address

def process_order(order: OrderData) -> OrderResult:
    """Process order with payment and shipping."""
    pass
```

**Benefits:**

- Types checked by compiler/type checker (comments aren't)
- Single source of truth (no comment drift)
- IDE autocomplete and refactoring support
- Enforced at build time

**Heuristic: If type system can express it, use types not comments.**

---

#### Principle 4: Prefer Smaller Functions Over Comments

**Core Idea**: Long functions need comments; small functions are self-documenting.

```javascript
// ❌ BAD: Long function requires comments to track flow
function processUserRegistration(userData) {
  // Validate input
  if (!userData.email || !userData.password) {
    throw new Error('Missing required fields');
  }

  // Check if user already exists
  const existing = database.users.findByEmail(userData.email);
  if (existing) {
    throw new Error('User already exists');
  }

  // Hash password
  const hashedPassword = bcrypt.hash(userData.password, 10);

  // Create user record
  const user = database.users.create({
    email: userData.email,
    password: hashedPassword
  });

  // Send welcome email
  emailService.send({
    to: user.email,
    template: 'welcome'
  });

  // Create default preferences
  database.preferences.create({
    userId: user.id,
    theme: 'light'
  });

  return user;
}

// ✅ GOOD: Small functions, each self-documenting
function processUserRegistration(userData) {
  validateRegistrationData(userData);
  ensureUserDoesNotExist(userData.email);

  const user = createUser(userData);

  sendWelcomeEmail(user);
  createDefaultPreferences(user);

  return user;
}

function validateRegistrationData(userData) {
  if (!userData.email || !userData.password) {
    throw new ValidationError('Missing required fields');
  }
}

function ensureUserDoesNotExist(email) {
  const existing = database.users.findByEmail(email);
  if (existing) {
    throw new DuplicateUserError(email);
  }
}

function createUser(userData) {
  const hashedPassword = bcrypt.hash(userData.password, 10);
  return database.users.create({
    email: userData.email,
    password: hashedPassword
  });
}
```

**Benefits:**

- Each function has single responsibility (SRP)
- Function names replace comment needs
- Easier to test (small, focused functions)
- Easier to understand (one thing per function)

**Heuristic: If function needs comments to track flow, split into smaller functions.**

---

#### Principle 5: Constants Over Magic Numbers

**Core Idea**: Named constants are self-documenting; magic numbers need comments.

```javascript
// ❌ BAD: Magic numbers need comments
function calculateDiscount(user, purchase) {
  // 86400000 = milliseconds in a day
  const daysSinceSignup = (Date.now() - user.signupDate) / 86400000;

  // 30 days for new user discount
  if (daysSinceSignup < 30) {
    // 15% discount for new users
    return purchase.total * 0.15;
  }

  // 10% standard discount
  return purchase.total * 0.10;
}

// ✅ GOOD: Named constants are self-documenting
const MILLISECONDS_PER_DAY = 86400000;
const NEW_USER_PERIOD_DAYS = 30;
const NEW_USER_DISCOUNT_RATE = 0.15;
const STANDARD_DISCOUNT_RATE = 0.10;

function calculateDiscount(user, purchase) {
  const daysSinceSignup = (Date.now() - user.signupDate) / MILLISECONDS_PER_DAY;

  if (daysSinceSignup < NEW_USER_PERIOD_DAYS) {
    return purchase.total * NEW_USER_DISCOUNT_RATE;
  }

  return purchase.total * STANDARD_DISCOUNT_RATE;
}
```

```python
# ❌ BAD: Magic numbers scattered throughout code
def process_batch(items):
    # Process in chunks of 100
    for i in range(0, len(items), 100):
        chunk = items[i:i+100]
        # 30 second timeout
        process_with_timeout(chunk, 30)

# ✅ GOOD: Named constants explain significance
BATCH_SIZE = 100  # Database optimal batch size from benchmarks
REQUEST_TIMEOUT_SECONDS = 30  # API rate limit: 2 req/min

def process_batch(items):
    for i in range(0, len(items), BATCH_SIZE):
        chunk = items[i:i+BATCH_SIZE]
        process_with_timeout(chunk, REQUEST_TIMEOUT_SECONDS)
```

**Benefits:**

- Constant name explains meaning (replaces comment)
- Single place to update value
- Type-safe (can enforce units, ranges)
- Searchable (find all uses of constant)

**Heuristic: If number needs comment to explain, extract to named constant.**

---

### Language-Specific Anti-Pattern Examples

#### JavaScript/TypeScript Patterns

**Common AI Over-Comments in JavaScript:**

```typescript
// ❌ Pattern 1: Obvious async/await comments
async function fetchUser(id: string): Promise<User> {
  // Use await to wait for the promise to resolve
  const response = await fetch(`/api/users/${id}`);

  // Parse the JSON response
  const data = await response.json();

  // Return the user data
  return data;
}

// ✅ GOOD: No comments, clear async flow
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  const user = await response.json();
  return user;
}
```

```typescript
// ❌ Pattern 2: Redundant React component comments
/**
 * User Profile Component
 * @param user - User object with id, name, email
 * @returns JSX element
 */
function UserProfile({ user }: { user: User }): JSX.Element {
  // Render the user's name in an h1 element
  return (
    <div>
      {/* Display user name */}
      <h1>{user.name}</h1>
      {/* Display user email */}
      <p>{user.email}</p>
    </div>
  );
}

// ✅ GOOD: Component is self-documenting
function UserProfile({ user }: { user: User }): JSX.Element {
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

#### Python Patterns

**Common AI Over-Comments in Python:**

```python
# ❌ Pattern 1: Obvious list comprehension comments
def get_active_users(users: List[User]) -> List[User]:
    # Use list comprehension to filter active users
    # Iterate through each user and check if is_active is True
    return [user for user in users if user.is_active]

# ✅ GOOD: Self-documenting filter
def get_active_users(users: List[User]) -> List[User]:
    return [user for user in users if user.is_active]
```

```python
# ❌ Pattern 2: Redundant docstring duplicating type hints
def calculate_total(items: List[Item]) -> Decimal:
    """
    Calculate the total price of items.

    Args:
        items (List[Item]): A list of Item objects

    Returns:
        Decimal: The total price as a Decimal

    Raises:
        ValueError: If items list is empty
    """
    if not items:
        raise ValueError("Items list cannot be empty")
    return sum(item.price for item in items)

# ✅ GOOD: Docstring adds information not in types
def calculate_total(items: List[Item]) -> Decimal:
    """
    Calculate total with regional tax applied.

    Raises:
        ValueError: If items list is empty
    """
    if not items:
        raise ValueError("Items list cannot be empty")
    return sum(item.price for item in items)
```

#### Java Patterns

**Common AI Over-Comments in Java:**

```java
// ❌ Pattern 1: Redundant getter/setter documentation
public class User {
    private String name;

    /**
     * Gets the user's name.
     * @return String the user's name
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the user's name.
     * @param name String the name to set
     */
    public void setName(String name) {
        this.name = name;
    }
}

// ✅ GOOD: Trivial getters/setters don't need Javadoc
public class User {
    private String name;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

```java
// ❌ Pattern 2: Over-documented builder pattern
public class UserBuilder {
    private String name;
    private String email;

    /**
     * Sets the name field.
     * @param name The name to set
     * @return UserBuilder The builder instance for chaining
     */
    public UserBuilder name(String name) {
        this.name = name;
        return this;
    }

    /**
     * Builds and returns the User instance.
     * @return User The constructed user object
     */
    public User build() {
        return new User(name, email);
    }
}

// ✅ GOOD: Standard patterns don't need detailed documentation
public class UserBuilder {
    private String name;
    private String email;

    public UserBuilder name(String name) {
        this.name = name;
        return this;
    }

    public User build() {
        return new User(name, email);
    }
}
```

---

### Documentation Quality Checklist

Use this checklist before committing code to ensure documentation quality:

**Pre-Commit Documentation Review:**

- [ ] **No obvious code comments** - Comments don't restate what code clearly shows
- [ ] **No redundant type information** - Type signatures not duplicated in comments
- [ ] **No tutorial-style explanations** - Standard language features not explained
- [ ] **No commented-out code** - Dead code deleted, not preserved in comments
- [ ] **No placeholder comments** - No TODO/FIXME in production code (or issue reference if temporary)
- [ ] **No changelog in comments** - Git provides history, comments explain current behavior
- [ ] **Self-documenting names** - Function/variable names clear enough to eliminate comment needs
- [ ] **Complex logic documented** - Non-obvious algorithms/business logic explained with WHY
- [ ] **Public APIs documented** - External-facing functions have contracts, examples, edge cases
- [ ] **Gotchas documented** - Workarounds and quirks explained with context

**Code Review Documentation Checks:**

- [ ] **Comment necessity** - Every comment justified (can't be replaced by refactoring)
- [ ] **Comment accuracy** - Comments match current code behavior (no drift)
- [ ] **Comment value** - Comments add information not visible in code
- [ ] **Refactoring opportunities** - Comments that should be function names, constants, types
