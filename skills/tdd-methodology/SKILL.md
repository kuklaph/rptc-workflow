---
name: tdd-methodology
description: TDD execution methodology for main context. Provides surgical coding approach, context discovery, and strict RED-GREEN-REFACTOR enforcement. Loaded by /rptc:feat and /rptc:fix for main context code changes.
---

# TDD Methodology Skill

**When to use**: This skill is loaded by `/rptc:feat` and `/rptc:fix` for main context code changes. Apply its methodology whenever writing or modifying code directly (not delegating to `rptc:tdd-agent`). This ensures the same quality standards apply whether work is done by a sub-agent or main context.

---

## Pre-Implementation: Surgical Coding Approach

**BEFORE making ANY changes, ALWAYS do this first**:

> Think harder and thoroughly examine similar areas of the codebase to ensure your proposed approach fits seamlessly with the established patterns and architecture. Aim to make only minimal and necessary changes, avoiding any disruption to the existing design.

### Mandatory Pre-Implementation Steps

1. **Search for existing patterns**: Find 3 similar implementations already in this codebase
2. **Analyze pattern alignment**: How does the existing code solve similar problems?
3. **Propose minimal changes**: Can this be done by modifying ONE existing file instead of creating many new ones?

---

## Pre-Implementation: Context Discovery

**CHECK FIRST - before writing any tests**:

1. Search `tests/` directory for existing test files
2. Identify test framework in use (Jest, Vitest, pytest, etc.)
3. Review 2-3 similar test files for naming patterns and structure
4. Check test configuration files (jest.config.js, vitest.config.ts, pytest.ini)
5. Note coverage baseline if available (use for improvement targets)

---

## Explicit Simplicity Directives

**MUST enforce in all implementations**:

- **Write the SIMPLEST possible solution** (not the most clever or flexible)
- **Prefer explicit over clever** (readable code beats concise code)
- **Avoid unnecessary abstractions** (no abstract base classes, factories, or interfaces until 3+ use cases exist)
- **Keep code under reasonable limits** (functions <50 lines, files <500 lines when possible)

**Reject approaches that**:

- Create abstractions for single use cases
- Add middleware/event-driven patterns for simple operations
- Use enterprise patterns in small projects
- Have >3 layers of indirection

---

## Pattern Reuse First (Rule of Three)

- **NEVER abstract on first use**
- **CONSIDER abstraction on second use** (only if patterns nearly identical)
- **REFACTOR to abstraction on third use** (DRY principle applies)

**Before creating new code, verify**:

- [ ] Have I searched for similar patterns in this codebase? (find 3 examples)
- [ ] Can existing code be modified instead of creating new files?
- [ ] Is this abstraction justified by 3+ actual use cases (not speculative)?
- [ ] Would a junior developer understand this on first reading?

---

## Standard Operating Procedures (SOPs)

**MUST consult** relevant SOPs:

1. User: `~/.claude/global/sop/[name].md` (user overrides)
2. Plugin: `${CLAUDE_PLUGIN_ROOT}/sop/[name].md` (defaults)

### Required SOPs to Reference

#### 1. `testing-guide.md` (CRITICAL - Reference First)

**When to consult**: Before writing ANY tests

**Key sections**:
- **TDD Methodology**: RED-GREEN-REFACTOR cycle details
- **AI Testing Blind Spots**: 5 systematic test-skipping patterns to avoid
- **Test Coverage Requirements**: 80%+ critical paths, 100% security-critical
- **Test Organization**: File structure, naming conventions

#### 2. `flexible-testing-guide.md` (AI-Specific)

**When to consult**: When writing assertions for AI-generated or non-deterministic outputs

**Key sections**:
- **Flexible Assertions**: When approximate matching vs exact
- **Non-Deterministic Outputs**: Handling AI-generated text, timestamps, randomness
- **Structural Validation**: Testing shape when exact content varies

**Example scenarios**: AI-generated error messages, markdown output with flexible formatting

#### 3. `architecture-patterns.md` (Code Structure)

**When to consult**: During GREEN and REFACTOR phases

**Key sections**:
- **AI Over-Engineering Prevention**: Anti-pattern prohibition list
- **Code Organization**: File structure, module boundaries
- **Error Handling Patterns**: Language-specific patterns

#### 4. `security-and-performance.md` (Critical Code)

**When to consult**: When implementing security-sensitive or performance-critical code

**Key sections**:
- **AI Security Verification Checklist**: 7 blind spots AI frequently misses
- **Input Validation**: Sanitization, type checking, boundary validation
- **Authentication/Authorization**: Token handling, permission checks

**BLOCKING Checkpoint**: For security-critical code (auth, payments, data access), MUST verify security checklist BEFORE proceeding.

### When to Reference SOPs

| Phase | SOPs to Consult |
|-------|-----------------|
| **RED (Writing Tests)** | `testing-guide.md`, `flexible-testing-guide.md` |
| **GREEN (Implementation)** | `architecture-patterns.md`, `security-and-performance.md` |
| **REFACTOR (Quality)** | `architecture-patterns.md`, `security-and-performance.md` |

---

## Implementation Constraints Awareness

When working in main context, constraints may come from:
- User instructions in the conversation
- Plan files (if referenced)
- Project configuration (`.claude/settings.json`)
- CLAUDE.md project guidelines

### What Are Implementation Constraints?

Specific rules and limits that guide your implementation approach:

- **File size limits**: Maximum lines per file (e.g., <500 lines)
- **Simplicity requirements**: No abstractions until 3rd use (Rule of Three)
- **Architectural patterns**: Required patterns for specific functionality
- **Security checkpoints**: BLOCKING gates before sensitive operations
- **Performance budgets**: Response time limits, resource constraints

### Your Responsibility

**MUST respect constraints during implementation**:

- [ ] Review any stated constraints before starting RED phase
- [ ] Verify approach aligns with constraints
- [ ] If constraints conflict with intended approach, STOP and request clarification
- [ ] Document any constraint violations with justification

### Default Constraints (When None Specified)

Apply standard best practices:

| Constraint | Default Value |
|------------|---------------|
| File size | <500 lines |
| Function size | <50 lines |
| Cyclomatic complexity | <10 per function |
| Abstraction threshold | 3+ use cases (Rule of Three) |
| Coverage target | 80%+ (from project config or default) |

### Handling Constraint Conflicts

If constraints conflict with your intended approach:

1. **STOP** - Do not proceed with conflicting implementation
2. **Document** - State the conflict clearly
3. **Request clarification** - Ask user which constraint takes priority
4. **Proceed only** after clarification received

---

## TDD Cycle: Overview

```
RED    → Write failing tests FIRST (defines desired behavior)
GREEN  → Write MINIMAL code to pass tests (no more, no less)
REFACTOR → Improve code quality (while keeping tests green)
VERIFY → Run affected tests, check coverage, no regressions
```

---

## Phase 1: RED - Write Failing Tests First

**CRITICAL**: Write ALL tests BEFORE any implementation code.

### Steps

1. **Review what needs to be tested**:
   - Happy path scenarios (normal usage)
   - Edge case scenarios (boundaries, unusual inputs)
   - Error condition scenarios (invalid inputs, failures)

2. **Write comprehensive tests** (applying discovered patterns from Context Discovery):
   - Use **Given-When-Then** OR **Arrange-Act-Assert** structure
   - Follow project's existing test naming conventions
   - **Naming template**: `should [behavior] when [condition]`
   - **One assertion per test** (or one logical group of related assertions)
   - Test behavior, not implementation details
   - Mock external dependencies only, never the system under test

3. **Run tests to verify they fail**:
   - Tests MUST fail for the right reasons
   - Failure output should clearly indicate what's missing
   - If test passes before implementation, test is invalid

4. **Report RED state**:
   ```
   RED Phase Complete
   Tests written: [X] tests
   All tests failing as expected (no implementation yet)
   ```

---

## Phase 2: GREEN - Minimal Implementation

**CRITICAL**: Write ONLY enough code to make tests pass. No more, no less.

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
   - Each iteration: targeted fix, re-run, verify
   - If still failing after 10 attempts, STOP and reassess approach

4. **Report GREEN state**:
   ```
   GREEN Phase Complete
   All tests passing ([X] tests)
   ```

---

## Phase 3: REFACTOR - Improve Code Quality

**CRITICAL**: Improve code WHILE keeping tests green. Run tests after EACH change.

### Steps

1. **Identify refactoring opportunities**:
   - Remove code duplication (DRY after 3rd occurrence)
   - Improve naming (variables, functions, classes)
   - Extract functions (if >50 lines or complex logic)
   - Simplify complex logic
   - Add clarifying comments (for non-obvious "why")

2. **Apply refactorings incrementally**:
   - One refactoring at a time
   - Run tests after each change
   - If tests fail, revert and fix

3. **Verify simplicity principles**:
   - [ ] Is this the simplest solution?
   - [ ] Would a junior developer understand this?
   - [ ] Are abstractions justified by 3+ use cases?
   - [ ] Are file/function sizes within limits?

4. **Report REFACTOR state**:
   ```
   REFACTOR Phase Complete
   Improvements made: [list]
   All tests still passing
   ```

---

## Phase 4: VERIFY - Affected Tests and Coverage

**CRITICAL**: Ensure no regressions and coverage targets met.

### Steps

1. **Run affected tests** (changed files + files that import/reference them):
   - Identify test files for modified production files
   - Include tests that import or reference changed modules
   - All affected tests must pass
   - If any existing tests fail, fix before proceeding
   - If project is small (<50 test files) or change touches shared utilities, run the full suite instead

2. **Check test coverage**:
   - Overall coverage >= 80% (or project target)
   - Critical paths: 100%
   - New code: >= 80%

3. **Verify no debug code**:
   - No `console.log`, `debugger`, `print()` statements
   - No commented-out code
   - No TODO comments without tracking

4. **Report verification complete**:
   ```
   VERIFICATION Complete
   Affected tests: [X]/[Y total] passing
   Coverage: [Y]% (target: [Z]%)
   No regressions detected
   ```

---

## Testing Principles: FIRST

- **Fast**: Tests run quickly (<1s for unit tests)
- **Independent**: Tests run in any order without dependencies
- **Repeatable**: Same results every time, regardless of environment
- **Self-Validating**: Clear pass/fail (no manual inspection)
- **Timely**: Written before implementation (RED phase enforces this)

---

## Test Structure Templates

### Given-When-Then (BDD style)

```javascript
describe('UserService', () => {
  it('should return user when valid ID provided', () => {
    // Given
    const userId = '123';
    const expectedUser = { id: '123', name: 'Test' };
    mockRepository.findById.mockReturnValue(expectedUser);

    // When
    const result = userService.getUser(userId);

    // Then
    expect(result).toEqual(expectedUser);
  });
});
```

### Arrange-Act-Assert (unit test style)

```python
def test_calculate_discount_applies_percentage():
    # Arrange
    price = 100.0
    discount_rate = 0.2

    # Act
    result = calculate_discount(price, discount_rate)

    # Assert
    assert result == 80.0
```

---

## Mocking Guidelines

### What to Mock

- External APIs and services (network calls)
- Database connections and queries
- File system operations
- Time-dependent functions (Date.now(), timers)
- Random number generators (for deterministic tests)

### What NOT to Mock

- The system under test itself
- Simple data structures or models
- Pure functions with no side effects
- Internal implementation details

---

## Test Allocation by Complexity

When determining how many tests to write:

| Complexity | Files Affected | Est. Lines | Test Count |
|------------|---------------|------------|------------|
| Simple     | 1 file        | <30 lines  | ~15 tests  |
| Medium     | 1-2 files     | 30-80 lines| ~30 tests  |
| Complex    | 3+ files      | >80 lines  | ~50 tests  |

**Coverage targets**:
- Happy paths: 100%
- Edge cases: At least 3 per function
- Error conditions: All error paths tested

---

## Quality Checklist (Before Completing)

### Test Quality
- [ ] Tests written BEFORE implementation (RED phase complete before GREEN)
- [ ] Comprehensive coverage: happy path, edge cases, error conditions
- [ ] Descriptive test names explaining what's tested
- [ ] Independent tests (can run in any order)
- [ ] Appropriate mocking (external deps only)

### Implementation Quality
- [ ] Simplest solution (no unnecessary complexity)
- [ ] Pattern alignment (follows existing codebase patterns)
- [ ] Size limits respected (files <500, functions <50 lines)
- [ ] No debug code (console.log, debugger, print removed)

### TDD Compliance
- [ ] RED: All tests written and failing before implementation
- [ ] GREEN: Minimal code to pass tests
- [ ] REFACTOR: Code improved while maintaining green tests
- [ ] VERIFY: Affected tests passing, coverage met, no regressions

---

## Human Collaboration Boundaries

**Community Best Practice**: "The human fixes quality barriers and defines design while AI handles mechanical implementation."

### Proceed Autonomously

- Mechanical implementation following tests
- Iterative fixes for failing tests (up to 10 attempts)
- Refactoring with green tests (within simplicity constraints)
- Pattern replication from existing code
- Test writing based on clear scenarios
- Coverage improvement to meet targets

### Request Human Input For

- **Architectural decisions** (new patterns, major restructures, choosing between design approaches)
- **Design trade-offs** (performance vs readability, complexity vs maintainability)
- **Security-critical implementation choices** (authentication flows, data encryption methods)
- **Unclear or conflicting requirements** (ambiguous acceptance criteria, contradictory constraints)
- **Scope creep** (feature additions beyond original request)
- **Breaking changes** (API modifications, backward-incompatible changes)
- **Persistent failures** after 10 iteration attempts

### Escalation Pattern

When human input is needed, use this format:

```text
DECISION REQUIRED

**Context**: [What you're trying to accomplish]
**Options**: [List 2-3 approaches with trade-offs]
**Your Recommendation**: [If you have one, with reasoning]
**Why Human Input Needed**: [Architectural/Security/Design decision]

Awaiting guidance before proceeding.
```

### Why This Matters

AI excels at mechanical execution but lacks business context, user empathy, and strategic vision. Human oversight at decision points prevents technically correct but strategically wrong implementations.

---

## Progress Reporting

After completing each TDD phase, provide a concise status report:

### Phase Completion Format

```text
[PHASE] Complete

Tests: [X] written/passing
Files: [list affected files]
Coverage: [Y]% (target: [Z]%)
Next: [what happens next]
```

### Example Reports

**RED Complete**:
```text
RED Complete

Tests: 8 written (all failing as expected)
Files: tests/user-service.test.ts (new)
Coverage: N/A (no implementation yet)
Next: GREEN phase - implement minimal code
```

**GREEN Complete**:
```text
GREEN Complete

Tests: 8/8 passing
Files: src/user-service.ts (new), tests/user-service.test.ts
Coverage: 85% (target: 80%)
Next: REFACTOR phase - improve code quality
```

**VERIFY Complete**:
```text
VERIFY Complete

Affected tests: 12/47 passing (3 files changed)
Files: src/user-service.ts, tests/user-service.test.ts
Coverage: 87% overall, 100% critical paths
Status: Ready for review/commit
```

---

## Quick Reference

```
1. SURGICAL CODING: Search for 3 similar patterns first
2. CONTEXT DISCOVERY: Check existing tests before writing
3. RED: Write failing tests (behavior, not implementation)
4. GREEN: Minimal code to pass (no premature optimization)
5. REFACTOR: Improve while green (one change at a time)
6. VERIFY: Affected tests, coverage, no debug code
```

**Remember**: Tests FIRST, simplicity ALWAYS, patterns from CODEBASE.
