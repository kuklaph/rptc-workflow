# Git Workflow and Deployment

## Branching Strategies

### Git Flow (Release-Based Projects)

```text
main (production) ← hotfix/*, release/*
develop (integration) ← feature/*, fix/*
```

**Branches**:

- **main**: Production code, tagged with versions
- **develop**: Integration for next release
- **feature/\***: New features (from develop)
- **fix/\***: Bug fixes (from develop)
- **hotfix/\***: Critical production fixes (from main)
- **release/\***: Release preparation (from develop)

**Workflow**: Feature → develop → release → main (tagged)

### GitHub Flow (Continuous Deployment)

```text
main (always deployable) ← feature/*, fix/*, docs/*
```

**Workflow**: Branch from main → PR → Deploy staging → Merge → Auto-deploy production
**Best for**: Continuous deployment, web apps, SaaS

### Trunk-Based Development (High-Velocity Teams)

- Single `main` branch
- Short-lived branches (< 1 day)
- Feature flags for incomplete features
- Multiple merges per day

## Branch Naming

### Prefixes

`feature/`, `fix/`, `hotfix/`, `refactor/`, `docs/`, `test/`, `chore/`, `perf/`, `style/`

### Format

```text
<prefix>/<ticket-id>-<short-description>

Examples:
feature/USER-123-oauth-login
fix/BUG-456-email-validation
refactor/improve-user-service
```

## Commit Message Standards

### Conventional Commits

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`, `revert`

### Examples

```text
feat: add user authentication

Implement JWT-based auth with refresh tokens.
Includes login, logout, and token refresh endpoints.
```

```text
fix(api): handle null values in user profile

Previously caused 500 errors. Now returns defaults.

Fixes #456
```

```text
feat(auth)!: change password hashing algorithm

BREAKING CHANGE: Switch to Argon2. Existing passwords
will need rehashing on next login.
```

### Best Practices

- Atomic commits (one logical change)
- Present tense, imperative mood
- First line < 72 chars
- Explain why, not what
- Reference issues/tickets

## Pull Request Process

### PR Template

```markdown
## Description

Brief description and motivation

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation

## Testing

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Checklist

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests pass locally
```

### Workflow

1. Create PR: `gh pr create --title "feat: ..." --body "..."`
2. Request reviews (minimum one required)
3. Automated checks pass (lint, tests, build, security)
4. Code review and address feedback
5. Approval (minimum one)
6. Merge (squash and merge to main)

### Review Guidelines

**Reviewers**: Review within 24 hours, constructive feedback, check correctness/readability/performance/security
**Authors**: Respond to all comments, explain complex decisions, update based on feedback

## Merging Strategies

### Squash and Merge (Recommended)

**When**: Feature branches to main
**Benefit**: Clean linear history, one commit per feature

### Rebase and Merge

**When**: Keeping feature branch updated with main
**Benefit**: Linear history, preserves commits

```bash
git checkout feature/user-auth
git rebase main
git push --force-with-lease
```

### Merge Commit

**When**: Release branches, preserving branch history

## Versioning (SemVer)

Format: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (v1.0.0 → v2.0.0)
- **MINOR**: New features, backward compatible (v1.0.0 → v1.1.0)
- **PATCH**: Bug fixes (v1.0.0 → v1.0.1)

**Pre-release**: `v1.0.0-alpha.1`, `v1.0.0-beta.2`, `v1.0.0-rc.1`

### Tagging

```bash
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0
```

## CI/CD Pipelines

### GitHub Actions Example

```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm test
      - run: npm run build

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm audit --audit-level=high
```

### Deployment Workflow

```yaml
name: Deploy

on:
  push:
    branches: [main]
    tags: ["v*"]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3
      - run: npm ci && npm run build
      - run: npm test
      - run: ./scripts/deploy.sh production
```

## Deployment Procedures

### Environments

- **Development**: Auto-deploy from develop, latest features, may be unstable
- **Staging**: Mirrors production, pre-release testing, deploy from release branches
- **Production**: Stable code only, deploy from main, tagged releases

### Deployment Checklist

**Pre-deployment**:

- [ ] Tests passing
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Database migrations tested
- [ ] Environment variables configured
- [ ] Backup current production

**Deployment**:

- [ ] Run database migrations
- [ ] Deploy application
- [ ] Verify health checks
- [ ] Run smoke tests
- [ ] Monitor logs

**Post-deployment**:

- [ ] Verify critical functionality
- [ ] Monitor error rates
- [ ] Check performance metrics
- [ ] Update status page

### Deployment Strategies

**Blue-Green**: Two identical environments, switch traffic after verification, easy rollback
**Canary**: Deploy to small subset, gradually increase traffic, rollback if issues
**Rolling**: Deploy to servers incrementally, maintain availability

### Zero-Downtime Deployment

```bash
#!/bin/bash
npm run build
rsync -avz dist/ servers:/app/releases/v1.2.0/
ssh servers "ln -sfn /app/releases/v1.2.0 /app/current"
ssh servers "systemctl reload app"
curl -f https://api.example.com/health || exit 1
```

## Rollback Procedures

### Quick Rollback

```bash
# Revert to previous version
git checkout v1.1.0
npm run deploy

# Or create revert commit
git revert HEAD
git push origin main

# Switch symlink
ssh servers "ln -sfn /app/releases/v1.1.0 /app/current"
ssh servers "systemctl reload app"
```

### Database Rollback

```bash
npm run migrate:rollback
# Or restore from backup
./scripts/restore-database.sh backup.sql
```

## Hotfix Procedure

1. Create hotfix branch from main: `git checkout -b hotfix/fix-issue`
2. Implement minimal fix
3. Test thoroughly
4. Deploy to staging and verify
5. Create PR and get quick review
6. Tag and deploy: `git tag -a v1.2.1 -m "Hotfix: issue"` → deploy
7. Merge back to develop
8. Post-mortem: Document incident, add tests, improve monitoring

## Release Process

### Release Checklist

**Preparation** (1 week before):

- [ ] Feature freeze on develop
- [ ] Update CHANGELOG.md
- [ ] Update version numbers
- [ ] Prepare release notes

**Release Branch** (3 days before):

```bash
git checkout develop
git checkout -b release/v1.2.0
```

- [ ] Final bug fixes only
- [ ] Deploy to staging
- [ ] QA and performance testing
- [ ] Security audit

**Release Day**:

```bash
git checkout main
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin main --tags

git checkout develop
git merge --no-ff release/v1.2.0
git push origin develop
```

- [ ] Deploy to production
- [ ] Verify deployment
- [ ] Publish release notes
- [ ] Monitor for issues

## Git Best Practices

### Commit Hygiene

- Commit early and often
- Keep commits focused and atomic
- Write meaningful messages
- Review changes before committing
- Use `git add -p` for partial commits

### Branch Hygiene

- Delete merged branches
- Keep branches short-lived
- Sync with main regularly
- Avoid long-running branches

### Collaboration

- Pull before pushing
- Communicate about force pushes
- Use draft PRs for WIP
- Tag teammates for review
- Resolve conflicts promptly

---

## AI Commit Quality Enforcement

### Why AI Code Needs Special Quality Checks

AI-generated code presents unique quality challenges that require explicit enforcement mechanisms:

**Common AI Code Quality Issues:**

1. **Debug Statements** (Highest Frequency)
   - `console.log()` / `console.debug()` in JavaScript/TypeScript
   - `print()` statements in Python
   - `fmt.Println()` in Go
   - `debugger;` statements halting execution
   - **Impact:** Production logs polluted, sensitive data exposed, execution halted

2. **Temporary Code Markers** (High Frequency)
   - `TODO`, `FIXME`, `XXX`, `HACK` comments
   - Placeholder implementations ("implement this later")
   - **Impact:** Incomplete features shipped, technical debt accumulates

3. **Incomplete Implementations** (Medium Frequency)
   - Functions returning mock data
   - Error handling gaps (broad `catch` blocks without handling)
   - Missing edge case handling
   - **Impact:** Silent failures, production bugs, security vulnerabilities

4. **Over-Engineering** (Medium Frequency)
   - Unnecessary abstractions (premature generalization)
   - Complex patterns for simple problems
   - **Impact:** Maintenance burden, reduced readability, longer onboarding

5. **Security Oversights** (Low Frequency, High Impact)
   - Missing input validation
   - Incomplete authentication checks
   - Hardcoded credentials (rare but catastrophic)
   - **Impact:** Security breaches, data leaks, compliance violations

**Quantified Risk:**
- Research shows AI code is **3-5x more likely** to contain debug statements than human code
- **45% of AI-generated commits** require revision for quality issues (internal observation)
- **Debug statements in production** can expose credentials, PII, business logic (SECURITY-CRITICAL)

**Philosophy:**
- **Automated enforcement** catches mechanical issues (debug code, formatting)
- **Manual checkpoints** catch conceptual issues (correctness, simplicity, security)
- **Prevention over cure:** Block issues before commit, not after deployment

---

### Debug Code Detection Patterns

Automated detection patterns for common debug statements across languages.

#### JavaScript/TypeScript Detection

**Pattern Set 1: Console Statements**

```regex
# Regex pattern (for tools like ripgrep, pre-commit hooks)
console\.(log|debug|info|warn|error|trace|table|dir|dirxml|assert|count|group|groupEnd|time|timeEnd)\s*\(
```

**Examples Caught:**
```javascript
// ❌ Blocked by pattern
console.log("User data:", userData);
console.debug("API response:", response);
console.error("Failed:", error);

// ✅ Allowed (production logging via logger)
logger.info("User logged in", { userId: user.id });
logger.error("Payment failed", { error: error.message });
```

**Pattern Set 2: Debugger Statements**

```regex
# Regex pattern
^\s*debugger;?\s*$
```

**Examples Caught:**
```javascript
// ❌ Blocked by pattern
debugger;

function processPayment() {
  debugger; // ❌ Debug statement
  return processTransaction();
}

// ✅ Allowed (no debugger statements)
function processPayment() {
  return processTransaction();
}
```

**Pattern Set 3: Temporary Markers**

```regex
# Regex pattern (comments)
\/\/\s*(TODO|FIXME|XXX|HACK|BUG|NOTE:.*temp)
\/\*\s*(TODO|FIXME|XXX|HACK)\s*.*\*\/
```

**Examples Caught:**
```javascript
// ❌ Blocked by pattern
// TODO: implement error handling
/* FIXME: this is a temporary workaround */
const value = mockData; // XXX: replace with real API

// ✅ Allowed (descriptive comments, not temporary markers)
// Validates user input according to schema
// See RFC-1234 for specification details
```

#### Python Detection

**Pattern Set 1: Print Statements**

```regex
# Regex pattern
^\s*print\s*\(
```

**Context-Aware Exclusions:**
- **Exclude:** Test files (`test_*.py`, `*_test.py`)
- **Exclude:** CLI entry points (files with `if __name__ == "__main__"`)
- **Exclude:** Logging setup (if using `print` for bootstrap before logging configured)

**Examples Caught:**
```python
# ❌ Blocked by pattern (in application code)
def process_user(user):
    print(f"Processing user: {user.id}")  # Debug statement
    return user.save()

# ❌ Blocked by pattern
def calculate_total(items):
    print("Items:", items)  # Debug output
    return sum(item.price for item in items)

# ✅ Allowed (production logging)
import logging
logger = logging.getLogger(__name__)

def process_user(user):
    logger.info("Processing user", extra={"user_id": user.id})
    return user.save()

# ✅ Allowed (CLI script with proper check)
if __name__ == "__main__":
    print("Processing complete")  # CLI output, not debug code
```

**Pattern Set 2: Debugger Statements**

```regex
# Regex pattern
^\s*(pdb\.set_trace\(\)|breakpoint\(\)|import\s+pdb|from\s+pdb\s+import)
```

**Examples Caught:**
```python
# ❌ Blocked by pattern
import pdb; pdb.set_trace()

def complex_logic(data):
    breakpoint()  # ❌ Python 3.7+ debugger
    return process(data)

# ✅ Allowed (no debugger statements)
def complex_logic(data):
    return process(data)
```

**Pattern Set 3: Temporary Markers**

```regex
# Regex pattern (Python comments)
^\s*#\s*(TODO|FIXME|XXX|HACK|BUG|NOTE:.*temp)
```

**Examples Caught:**
```python
# ❌ Blocked by pattern
# TODO: add input validation
def save_user(user_data):
    # FIXME: temporary implementation
    return user_data

# ✅ Allowed (descriptive comments)
# Implements the OAuth 2.0 authorization flow
# See https://tools.ietf.org/html/rfc6749 for specification
```

#### Go Detection

**Pattern Set 1: Debug Output**

```regex
# Regex pattern
fmt\.(Print|Println|Printf)\s*\(
log\.(Print|Println|Printf)\s*\(.*(?:debug|DEBUG|Debug)
```

**Context-Aware Exclusions:**
- **Exclude:** `main` package CLI tools (legitimate terminal output)
- **Exclude:** Test files (`*_test.go`)
- **Allow:** Structured logging via `log/slog` or `logrus`

**Examples Caught:**
```go
// ❌ Blocked by pattern (in library code)
func ProcessOrder(order Order) error {
    fmt.Println("Processing order:", order.ID) // Debug output
    return order.Save()
}

// ❌ Blocked by pattern
func CalculateTotal(items []Item) float64 {
    log.Println("DEBUG: items count:", len(items)) // Debug log
    return sumPrices(items)
}

// ✅ Allowed (structured logging)
import "log/slog"

func ProcessOrder(order Order) error {
    slog.Info("Processing order", "order_id", order.ID)
    return order.Save()
}

// ✅ Allowed (CLI main package)
package main

func main() {
    fmt.Println("Processing complete") // CLI output, not debug
}
```

**Pattern Set 2: Temporary Markers**

```regex
# Regex pattern (Go comments)
^\s*\/\/\s*(TODO|FIXME|XXX|HACK|BUG|NOTE:.*temp)
^\s*\/\*\s*(TODO|FIXME|XXX|HACK)
```

**Examples Caught:**
```go
// ❌ Blocked by pattern
// TODO: implement error handling
func SaveUser(user User) error {
    /* FIXME: temporary workaround */
    return nil // XXX: placeholder
}

// ✅ Allowed (descriptive comments)
// CalculateDiscount computes the discount based on user tier.
// See pricing documentation for tier definitions.
```

#### Generic Patterns (All Languages)

**Pattern Set 1: Commented-Out Code**

```regex
# Detection heuristic: 3+ consecutive commented lines that look like code
# (Requires semantic analysis, regex approximation:)
(^\s*[#\/]\s*\w+\s*[=\(\{].*\n){3,}
```

**Why This Matters:**
- Commented-out code indicates uncertainty ("might need this later")
- Creates confusion ("Is this intentional or forgotten?")
- Version control is the proper place for "might need later" code

**Pattern Set 2: Placeholder Implementations**

```regex
# Common placeholder patterns
(return\s+null|return\s+None|return\s+nil);\s*\/\/\s*(TODO|placeholder|temporary)
throw\s+new\s+Error\(['"]Not implemented['"]\)
raise\s+NotImplementedError
panic\(['"]not implemented['"]\)
```

**Examples Caught:**
```javascript
// ❌ Blocked
function getUserPermissions(userId) {
    return null; // TODO: implement
}

// ❌ Blocked
function calculateDiscount(user) {
    throw new Error("Not implemented");
}
```

```python
# ❌ Blocked
def get_user_permissions(user_id):
    return None  # TODO: implement

# ❌ Blocked
def calculate_discount(user):
    raise NotImplementedError
```

---

### Pre-Commit Checklist (17 Items)

Use this checklist before every commit. Automated checks catch mechanical issues, manual checks catch conceptual issues.

#### Category 1: Code Quality (5 items)

- [ ] **No debug statements** - Run: `rg "console\.(log|debug|info|warn|error)" --type js --type ts`
  - **Check:** No console.* statements in application code (test files excluded)
  - **Why:** Debug statements pollute production logs, may expose sensitive data
  - **Automation:** Pre-commit hook blocks commits with console.* statements

- [ ] **No print statements** (Python) - Run: `rg "^\s*print\s*\(" --type py`
  - **Check:** No print() calls in application code (CLI scripts and tests excluded)
  - **Why:** Print statements bypass logging infrastructure, can't be controlled
  - **Automation:** Pre-commit hook blocks commits with print() in non-CLI files

- [ ] **No debugger statements** - Run: `rg "debugger|pdb\.set_trace|breakpoint\(\)" --type js --type py`
  - **Check:** No debugger/breakpoint statements in any file
  - **Why:** Debugger statements halt execution in production
  - **Automation:** Pre-commit hook blocks commits with debugger statements

- [ ] **Proper formatting** - Run: `npm run format` or `black .` or `gofmt -w .`
  - **Check:** All files formatted per project style guide
  - **Why:** Consistent formatting improves readability, reduces diff noise
  - **Automation:** Pre-commit hook auto-formats on commit (or blocks if not formatted)

- [ ] **No commented-out code**
  - **Check:** Review diff for large blocks of commented code
  - **Why:** Version control stores old code, commented code creates confusion
  - **Automation:** Manual review (heuristic detection possible but high false positive rate)

#### Category 2: Testing (3 items)

- [ ] **Affected tests passing** - Run targeted tests for changed + dependent files
  - **Check:** Affected tests pass (0 failures in changed + dependent files)
  - **Why:** Broken tests indicate broken code or inadequate test coverage
  - **Automation:** Pre-commit hook blocks commits if tests fail (configurable)

- [ ] **Coverage ≥ 80%** - Run: `npm run test:coverage` or `pytest --cov`
  - **Check:** New code meets 80% minimum coverage threshold
  - **Why:** Untested code likely contains bugs, can't be refactored safely
  - **Automation:** CI checks coverage on PR (pre-commit check optional)

- [ ] **No skipped tests without justification**
  - **Check:** No `it.skip()`, `@pytest.mark.skip` without bug reference or explanation
  - **Why:** Skipped tests indicate incomplete work or flaky tests
  - **Automation:** Pre-commit hook can warn on skip patterns

#### Category 3: Security (3 items)

- [ ] **No hardcoded secrets** - Run: `rg "(api_key|password|secret|token)\s*=\s*['\"]" --type js --type py`
  - **Check:** No hardcoded API keys, passwords, tokens in code
  - **Why:** Hardcoded secrets leak to git history, can't be rotated easily
  - **Automation:** Pre-commit hook with secret detection (or use `git-secrets`, `trufflehog`)

- [ ] **Input validation present** (for new endpoints/functions)
  - **Check:** All user inputs validated (type, range, format, authorization)
  - **Why:** Missing input validation leads to injection attacks, crashes
  - **Automation:** Manual review (static analysis can detect some cases)

- [ ] **No SQL injection vulnerabilities** - Check: Parameterized queries used
  - **Check:** All database queries use parameterized queries, not string concatenation
  - **Why:** SQL injection is #1 OWASP vulnerability, trivially exploitable
  - **Automation:** Manual review + static analysis tools (Semgrep, CodeQL)

#### Category 4: Documentation (2 items)

- [ ] **Code comments for complex logic**
  - **Check:** Non-obvious logic has explanatory comments (why, not what)
  - **Why:** Future maintainers need context, AI code often lacks explanatory comments
  - **Automation:** Manual review (AI can assist: "explain this code")

- [ ] **README updated if public API changed**
  - **Check:** If public functions/endpoints added/changed, README reflects changes
  - **Why:** Outdated documentation worse than no documentation
  - **Automation:** Manual review (can be enforced via PR checklist)

#### Category 5: Completeness (4 items)

- [ ] **No TODO comments** - Run: `rg "TODO|FIXME|XXX|HACK" --type js --type py --type go`
  - **Check:** No temporary markers in committed code
  - **Why:** TODOs indicate incomplete work, should be tracked in issue tracker
  - **Automation:** Pre-commit hook blocks commits with TODO/FIXME (with exceptions)

- [ ] **No FIXME markers** - Covered by TODO check above
  - **Check:** No FIXME/XXX/HACK comments in committed code
  - **Why:** FIXME indicates known issues being shipped
  - **Automation:** Pre-commit hook blocks commits with FIXME patterns

- [ ] **No placeholder implementations** - Check: All functions have real implementations
  - **Check:** No `throw new Error("Not implemented")` or `return null // TODO`
  - **Why:** Placeholder code causes runtime failures, indicates incomplete work
  - **Automation:** Pre-commit hook can detect common placeholder patterns

- [ ] **All error cases handled**
  - **Check:** Every error path has explicit handling (no silent failures, no broad `catch` without action)
  - **Why:** Unhandled errors cause silent failures, data corruption
  - **Automation:** Manual review + static analysis (linter rules for empty catch blocks)

**Total: 17 items across 5 categories**

**Usage:**
- **Before every commit:** Review checklist, run automated checks
- **Estimated time:** 3-5 minutes for small commits, 10-15 minutes for large commits
- **Automation:** Pre-commit hooks handle 10/17 checks automatically, 7 require manual review

---

### Code Review Checkpoints for AI-Generated Code

When reviewing AI-generated code (from Claude, Copilot, ChatGPT, etc.), apply these checkpoints in order. Each checkpoint addresses common AI code quality issues.

#### Checkpoint 1: Correctness Review

**Purpose:** Verify the code solves the actual problem, not a similar problem.

**Questions:**
- [ ] **Does this solve the actual requirement?**
  - AI often solves a "nearby" problem that's easier or more common
  - Example: Asked for "sort by date descending", AI provides ascending sort
  - **Action:** Test with real data, verify behavior matches requirement

- [ ] **Are all requirements met?**
  - AI may implement 80% of requirements, omit edge cases
  - Example: Implements success path, omits error handling
  - **Action:** Compare implementation against acceptance criteria line-by-line

- [ ] **Does it handle edge cases?**
  - AI often omits boundary conditions (empty arrays, null values, max limits)
  - Example: Array.sort() without handling empty array, null elements
  - **Action:** Test with: empty inputs, null/undefined, boundary values, concurrent operations

- [ ] **Are there off-by-one errors?**
  - AI sometimes makes fencepost errors (especially in loops, date ranges)
  - Example: `for (i = 0; i <= array.length; i++)` instead of `i < array.length`
  - **Action:** Review loop conditions, array indexing, date range calculations

**Common AI Correctness Issues:**
- Solves similar but different problem
- Implements 80% of requirements (the "obvious" part)
- Omits edge case handling
- Off-by-one errors in loops/ranges
- Assumes happy path only

**Review Time:** 5-10 minutes per feature

---

#### Checkpoint 2: Simplicity Review (KISS/YAGNI)

**Purpose:** Verify this is the simplest solution, not the most "impressive" solution.

**Questions:**
- [ ] **Is this the simplest solution?**
  - AI often over-engineers, adds unnecessary abstractions
  - Example: Factory pattern for single implementation, strategy pattern for 2 cases
  - **Action:** Can you solve this with 1/3 the code? Remove abstractions, test if it still works

- [ ] **Are there unnecessary abstractions?**
  - AI loves interfaces, abstract classes, dependency injection for everything
  - Example: Interface for single implementation, builder pattern for simple constructor
  - **Action:** Remove abstraction, inline the code—if tests still pass, abstraction was premature

- [ ] **Is it readable?**
  - AI sometimes prioritizes "cleverness" over clarity
  - Example: One-liner with 5 chained operations instead of 5 clear lines
  - **Action:** Can junior developer understand this in 30 seconds? If not, simplify

- [ ] **Does it follow YAGNI?**
  - AI implements features "you might need later" (configuration, extensibility, future-proofing)
  - Example: Plugin system when you have 1 plugin, caching when you have 10 users
  - **Action:** Remove features not in requirements, add them when actually needed

**Common AI Simplicity Issues:**
- Premature abstraction (interfaces for single implementation)
- Over-engineering (design patterns for simple problems)
- Premature optimization (caching for low-traffic features)
- Generic solutions for specific problems
- "Clever" code instead of clear code

**Review Time:** 5-15 minutes per feature

**Example:**
```javascript
// ❌ AI Over-Engineering
interface UserRepository {
  findById(id: string): Promise<User>;
}

class DatabaseUserRepository implements UserRepository {
  async findById(id: string): Promise<User> {
    return this.db.query('SELECT * FROM users WHERE id = ?', [id]);
  }
}

class UserService {
  constructor(private repo: UserRepository) {}

  async getUser(id: string): Promise<User> {
    return this.repo.findById(id);
  }
}

// ✅ Simplified (YAGNI - add abstraction when you have 2+ implementations)
async function getUser(id: string): Promise<User> {
  return db.query('SELECT * FROM users WHERE id = ?', [id]);
}
```

---

#### Checkpoint 3: Security Review

**Purpose:** Verify the code doesn't introduce security vulnerabilities.

**Questions:**
- [ ] **Is input validation present?**
  - AI often trusts user input, omits validation
  - Example: Accepts user-provided ID without checking format, authorization
  - **Action:** Every user input must be validated (type, format, range, authorization)

- [ ] **Is authentication/authorization correct?**
  - AI sometimes omits auth checks, implements auth incorrectly
  - Example: Checks authentication but not authorization (logged in ≠ permitted)
  - **Action:** Verify every protected operation checks both authentication AND authorization

- [ ] **Are there injection vulnerabilities?**
  - AI sometimes uses string concatenation for SQL, shell commands, HTML
  - Example: `db.query("SELECT * FROM users WHERE id = " + userId)`
  - **Action:** All queries must use parameterized queries, all shell commands must escape inputs

- [ ] **Are secrets properly managed?**
  - AI occasionally hardcodes API keys, especially in examples
  - Example: `const API_KEY = "sk_live_1234567890"`
  - **Action:** All secrets must come from environment variables or secret manager

- [ ] **Is sensitive data logged?**
  - AI debug statements often log full request/response objects (including credentials, PII)
  - Example: `logger.info("Request:", req)` (logs Authorization header, request body)
  - **Action:** Remove debug logging, ensure production logging redacts sensitive fields

**Common AI Security Issues:**
- Missing input validation
- SQL injection via string concatenation
- Missing authorization checks (authentication only)
- Hardcoded secrets in code
- Sensitive data in logs (credentials, PII, tokens)
- Insufficient error handling (stack traces exposed to users)

**Review Time:** 10-20 minutes per feature (SECURITY-CRITICAL)

**Severity Matrix:**
| Issue | Severity | Action |
|-------|----------|--------|
| SQL injection | CRITICAL | Block merge, fix immediately |
| Missing authz | CRITICAL | Block merge, fix immediately |
| Hardcoded secret | HIGH | Block merge, rotate secret, fix |
| Missing input validation | HIGH | Block merge, add validation |
| Sensitive data logged | MEDIUM | Fix before merge |

---

#### Checkpoint 4: Test Quality Review

**Purpose:** Verify tests actually test behavior, not just achieve coverage.

**Questions:**
- [ ] **Do tests verify behavior, not implementation?**
  - AI often writes tests that verify internal calls, not external behavior
  - Example: `expect(mockFunction).toHaveBeenCalled()` instead of verifying actual output
  - **Action:** Tests should verify observable behavior (return values, side effects, state changes)

- [ ] **Are edge cases covered?**
  - AI often tests only happy path
  - Example: Test with valid input, skip empty array, null, boundary values
  - **Action:** Every test file must include edge case tests (empty, null, min/max, concurrent)

- [ ] **Are error conditions tested?**
  - AI frequently omits error path tests
  - Example: Test successful API call, skip network error, 401/403/500 responses
  - **Action:** Every error condition must have test (network failure, auth failure, invalid input)

- [ ] **Are tests maintainable?**
  - AI sometimes generates brittle tests (hard-coded values, implementation-coupled)
  - Example: `expect(result).toBe('User: John Doe, Age: 30')` instead of testing structure
  - **Action:** Tests should be resilient to minor implementation changes

**Common AI Test Quality Issues:**
- Tests verify mocks were called, not actual behavior
- Only happy path tested
- Error conditions omitted
- Brittle tests (hardcoded values, implementation-coupled)
- Test coverage without test value

**Review Time:** 10-15 minutes per feature

**Example:**
```javascript
// ❌ AI Test (Tests Implementation)
it('should call repository.findById', async () => {
  const mockRepo = { findById: jest.fn().mockResolvedValue(user) };
  await service.getUser('123');
  expect(mockRepo.findById).toHaveBeenCalledWith('123');
});

// ✅ Better Test (Tests Behavior)
it('should return user data for valid ID', async () => {
  const result = await service.getUser('123');
  expect(result).toMatchObject({
    id: '123',
    name: expect.any(String),
    email: expect.any(String),
  });
});

it('should throw NotFoundError for invalid ID', async () => {
  await expect(service.getUser('invalid')).rejects.toThrow(NotFoundError);
});

it('should handle empty ID', async () => {
  await expect(service.getUser('')).rejects.toThrow(ValidationError);
});
```

---

#### Checkpoint 5: Architecture Review

**Purpose:** Verify code follows project patterns and architecture.

**Questions:**
- [ ] **Does it follow project patterns?**
  - AI uses generic patterns, may not match project conventions
  - Example: Project uses repository pattern, AI uses direct database calls
  - **Action:** Review existing similar features, ensure new code matches patterns

- [ ] **Is separation of concerns proper?**
  - AI sometimes mixes concerns (business logic in controllers, database logic in services)
  - Example: API endpoint that does validation + business logic + database call + response formatting
  - **Action:** Each layer should have single responsibility (controller → service → repository)

- [ ] **Are dependencies managed correctly?**
  - AI may introduce circular dependencies, tight coupling
  - Example: Service A imports Service B, Service B imports Service A
  - **Action:** Check dependency graph, ensure unidirectional flow

- [ ] **Does it integrate with existing code?**
  - AI sometimes creates isolated code that doesn't integrate
  - Example: New error handling approach instead of using existing error handling
  - **Action:** New code should reuse existing utilities, follow existing patterns

**Common AI Architecture Issues:**
- Doesn't follow project patterns (uses generic patterns)
- Mixed concerns (business logic in controllers)
- Circular dependencies
- Tight coupling
- Doesn't integrate with existing code

**Review Time:** 5-10 minutes per feature

---

#### Checkpoint 6: Performance Review

**Purpose:** Verify no obvious performance issues.

**Questions:**
- [ ] **Are there N+1 queries?**
  - AI often creates N+1 query patterns (query in loop)
  - Example: `users.forEach(user => db.query('SELECT * FROM orders WHERE user_id = ?', [user.id]))`
  - **Action:** Use JOIN or batch queries, load related data in single query

- [ ] **Are algorithms efficient?**
  - AI sometimes uses O(n²) algorithms when O(n log n) available
  - Example: Nested loop for search instead of hash map lookup
  - **Action:** Review algorithm complexity, optimize if O(n²) or worse

- [ ] **Is resource cleanup proper?**
  - AI sometimes omits cleanup (database connections, file handles, event listeners)
  - Example: Opens database connection, doesn't close on error path
  - **Action:** All resources must have cleanup (try/finally, defer, RAII, using)

**Common AI Performance Issues:**
- N+1 query problems
- Inefficient algorithms (O(n²) instead of O(n log n))
- Missing resource cleanup
- Unnecessary data loading (fetch all when need one)

**Review Time:** 5-10 minutes per feature

---

### Automated Enforcement Tools

#### Pre-Commit Hook Configuration

**Setup:** Create `.git/hooks/pre-commit` with executable permissions

```bash
#!/bin/bash
# Pre-commit hook: AI Commit Quality Enforcement

echo "🔍 Running AI Commit Quality Checks..."

# Initialize error flag
ERRORS=0

# Check 1: Debug statements (JavaScript/TypeScript)
echo "  → Checking for console.* statements..."
if git diff --cached --name-only | grep -E '\.(js|ts|jsx|tsx)$' | xargs grep -n 'console\.\(log\|debug\|info\|warn\|error\)' 2>/dev/null; then
  echo "❌ ERROR: console.* statements found in staged files"
  echo "   Remove debug statements before committing"
  ERRORS=$((ERRORS + 1))
fi

# Check 2: Debugger statements (JavaScript/TypeScript)
echo "  → Checking for debugger statements..."
if git diff --cached --name-only | grep -E '\.(js|ts|jsx|tsx)$' | xargs grep -n 'debugger' 2>/dev/null; then
  echo "❌ ERROR: debugger statements found in staged files"
  echo "   Remove debugger statements before committing"
  ERRORS=$((ERRORS + 1))
fi

# Check 3: Print statements (Python, excluding CLI and tests)
echo "  → Checking for print() statements..."
if git diff --cached --name-only | grep -E '\.py$' | grep -v -E '(test_|_test\.py|cli\.py|__main__\.py)' | xargs grep -n '^\s*print\s*(' 2>/dev/null; then
  echo "❌ ERROR: print() statements found in application code"
  echo "   Use logging instead of print()"
  ERRORS=$((ERRORS + 1))
fi

# Check 4: Python debugger statements
echo "  → Checking for Python debugger statements..."
if git diff --cached --name-only | grep -E '\.py$' | xargs grep -n -E '(pdb\.set_trace|breakpoint\(\)|import pdb)' 2>/dev/null; then
  echo "❌ ERROR: Python debugger statements found"
  echo "   Remove pdb/breakpoint statements before committing"
  ERRORS=$((ERRORS + 1))
fi

# Check 5: TODO/FIXME markers
echo "  → Checking for TODO/FIXME markers..."
if git diff --cached --name-only | xargs grep -n -E '(TODO|FIXME|XXX|HACK):' 2>/dev/null; then
  echo "⚠️  WARNING: TODO/FIXME markers found"
  echo "   Consider creating issues for TODOs instead of committing them"
  # Don't block commit for TODOs, just warn
fi

# Check 6: Hardcoded secrets (basic pattern)
echo "  → Checking for hardcoded secrets..."
if git diff --cached | grep -E '(api_key|password|secret|token)\s*=\s*['\''"][a-zA-Z0-9_-]{20,}['\''"]' 2>/dev/null; then
  echo "❌ ERROR: Potential hardcoded secrets found"
  echo "   Use environment variables for secrets"
  ERRORS=$((ERRORS + 1))
fi

# Check 7: Run tests (if configured)
if [ -f "package.json" ] && grep -q '"test"' package.json; then
  echo "  → Running tests..."
  npm test --silent
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Tests failed"
    ERRORS=$((ERRORS + 1))
  fi
fi

# Check 8: Run linter (if configured)
if [ -f "package.json" ] && grep -q '"lint"' package.json; then
  echo "  → Running linter..."
  npm run lint --silent
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Linter failed"
    ERRORS=$((ERRORS + 1))
  fi
fi

# Final verdict
if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "════════════════════════════════════════════════"
  echo "  ❌ COMMIT BLOCKED ($ERRORS errors found)"
  echo "════════════════════════════════════════════════"
  echo ""
  echo "Fix the errors above and try again."
  exit 1
else
  echo ""
  echo "✅ All AI Commit Quality Checks passed"
  exit 0
fi
```

**Installation:**
```bash
# Make executable
chmod +x .git/hooks/pre-commit

# Test
git add .
git commit -m "test: verify pre-commit hook works"
```

#### Linter Rules (ESLint for JavaScript/TypeScript)

**Add to `.eslintrc.json`:**
```json
{
  "rules": {
    "no-console": "error",
    "no-debugger": "error",
    "no-alert": "error",
    "no-restricted-syntax": [
      "error",
      {
        "selector": "CallExpression[callee.object.name='console']",
        "message": "Use logger instead of console"
      }
    ]
  }
}
```

#### Linter Rules (Pylint for Python)

**Add to `.pylintrc` or `pyproject.toml`:**
```ini
[MESSAGES CONTROL]
disable=
    fixme,  # TODO/FIXME comments

[BASIC]
# Disallow print statements
disable=print-statement
```

#### Static Analysis (Semgrep for Security)

**Create `.semgrep.yml`:**
```yaml
rules:
  - id: no-hardcoded-secrets
    pattern: |
      $SECRET = "..."
    message: "Potential hardcoded secret detected"
    severity: ERROR
    languages: [javascript, typescript, python, go]

  - id: sql-injection
    pattern: |
      db.query("... " + $USER_INPUT + " ...")
    message: "Potential SQL injection vulnerability"
    severity: ERROR
    languages: [javascript, typescript, python]

  - id: debug-statements-js
    pattern: |
      console.$METHOD(...)
    message: "Debug console statement detected"
    severity: ERROR
    languages: [javascript, typescript]

  - id: debug-statements-python
    pattern: |
      print(...)
    message: "Debug print statement detected"
    severity: WARNING
    languages: [python]
```

**Run Semgrep:**
```bash
# Install
pip install semgrep

# Run
semgrep --config .semgrep.yml .
```

---

### Integration with Existing Workflow

**Cross-References:**

1. **Pre-Commit Checklist** ↔ **Testing Guide (TDD Workflow)**
   - Testing checklist items (tests passing, coverage ≥ 80%) reference testing-guide.md
   - TDD workflow includes commit quality gates

2. **Code Review Checkpoints** ↔ **Security and Performance SOP**
   - Security checkpoint references security-and-performance.md for detailed patterns
   - Performance checkpoint links to performance optimization section

3. **Automated Enforcement Tools** ↔ **Git Workflow**
   - Pre-commit hooks integrate with existing branch strategy
   - CI/CD pipeline runs same checks on PR (defense in depth)

**Workflow Integration:**

```text
Developer writes code (AI-assisted)
    ↓
Run pre-commit checklist (17 items)
    ↓
Automated checks (pre-commit hook: 8 checks)
    ↓ (if pass)
Commit created
    ↓
Push to remote
    ↓
CI/CD runs same checks (defense in depth)
    ↓
Code review (6 checkpoints applied)
    ↓
PR approved and merged
```

**Configuration:**

Add to `.claude/settings.json`:
```json
{
  "rptc": {
    "commitQualityEnforcement": {
      "preCommitHookEnabled": true,
      "blockOnDebugStatements": true,
      "blockOnFailedTests": true,
      "blockOnHardcodedSecrets": true,
      "warnOnTodoMarkers": true
    }
  }
}
```

---

## Project-Specific Configuration

Document in `.context/git-workflow.md`:

- Branching strategy choice
- PR approval requirements
- Deployment triggers
- Release schedule
- Hotfix procedures
