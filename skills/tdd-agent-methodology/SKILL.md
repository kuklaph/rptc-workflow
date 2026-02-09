---
name: tdd-agent-methodology
description: TDD execution methodology for the RPTC tdd-agent sub-agent. Covers batch execution mode, FIRST testing principles, test structure patterns, mocking guidelines, strict RED-GREEN-REFACTOR-VERIFY cycle, framework selection matrix (per-file context detection), implementation constraints handling, completion report format, quality standards, and human collaboration boundaries. Distinct from tdd-methodology skill (which is for main context).
---

# TDD Agent Methodology

TDD execution methodology for the RPTC tdd-agent. Executes strict RED-GREEN-REFACTOR-VERIFY cycles for implementation steps.

---

## Core Mission

Execute RED → GREEN → REFACTOR → VERIFY cycle for ONE OR MORE implementation steps (batch mode) within a larger feature plan.

**Philosophy**: Tests MUST be written BEFORE implementation code. Non-negotiable.

**Context received**: Overall feature context, step details, test allocation, cumulative file changes, implementation constraints.

**Output**: Fully tested, working implementation for ALL steps in batch with all tests passing.

---

## Batch Execution Mode

When receiving multiple steps:

1. **Process steps in order** — Maintain dependencies within batch
2. **Per-step TDD cycle** — Complete RED-GREEN-REFACTOR for step N before starting step N+1
3. **Shared context** — Leverage code from earlier batch steps
4. **Respect test allocation**:
   - Simple step (~15 tests): 1 file, <30 lines
   - Medium step (~30 tests): 1-2 files, 30-80 lines
   - Complex step (~50 tests): 3+ files, >80 lines
5. **Single completion report** — Summarize all steps at end of batch

---

## Testing Principles (FIRST)

- **Fast**: Tests run quickly (<1s for unit tests)
- **Independent**: Tests run in any order without dependencies
- **Repeatable**: Same results every time, regardless of environment
- **Self-Validating**: Clear pass/fail (no manual inspection)
- **Timely**: Written before implementation (RED phase enforces this)

---

## Test Structure

Use **Given-When-Then** (BDD) or **Arrange-Act-Assert** (unit test) structure.

**Naming template**: `should [behavior] when [condition]`

**Test Distribution Targets**:

| Category | Target | Focus |
|----------|--------|-------|
| Happy path | 20-30% | Standard inputs, typical use cases |
| Edge cases | 50-60% | Boundary values, empty collections, unicode, concurrency |
| Error conditions | 20-30% | Invalid inputs, auth failures, timeouts |

**Deduplication**: Compare each test with existing tests. Keep variations that add value, remove slight variations with identical logic.

---

## Mocking Guidelines

**What to mock**: External APIs, database connections, file system, time-dependent functions, random number generators.

**What NOT to mock**: The system under test, simple data structures, pure functions, internal implementation details.

---

## Framework Selection (Per-File)

Before writing tests for each file, detect code context and select the correct framework.

### Detection Matrix

| Context | Detection Keywords | Framework | Test Pattern |
|---------|-------------------|-----------|--------------|
| `utility` | Pure functions, no UI/backend imports | Project unit runner (Bun/Jest/Vitest) | `describe/it/expect` |
| `frontend-ui` | React, Vue, useState, component, JSX/TSX | RTL for components, Playwright for E2E | Component or page tests |
| `backend-api` | express, fastify, req, res, router | supertest | HTTP request/response |
| `browser-dependent` | window., document., localStorage, navigator | **Playwright REQUIRED** | `page.goto`, `page.evaluate` |
| `external-api` | fetch, axios, http.request | MSW/nock + unit runner | Mocked responses |

**If browser-dependent but no Playwright**: Flag for manual review. Skip this file and continue.

---

## TDD Cycle

### Phase 1: RED — Write Failing Tests First

**FILE LOCKOUT**: During RED phase, you may ONLY create or modify test files. Editing ANY production/source file is a TDD violation.

**Steps**:

0. **Context Discovery**: Search `tests/` for existing files, identify framework, review 2-3 similar test files, check config, note coverage baseline.

1. **Review test scenarios** from step file (happy path, edge cases, errors).

2. **Write comprehensive tests** applying discovered patterns. Follow project conventions. One assertion per test. Test behavior, not implementation.

3. **Run tests to verify they fail** for the right reasons. If a test passes before implementation, it's invalid.

4. **RED GATE** (verify before GREEN):
   - [ ] Only test files were created/modified
   - [ ] All new tests fail for expected reasons (not compile errors)
   - [ ] No production source files were touched

   If ANY check fails → STOP. Fix before continuing.

### Phase 2: GREEN — Minimal Implementation

Write ONLY enough code to make tests pass. No more, no less.

- Focus on correctness, not elegance
- No premature optimization
- Follow existing code patterns
- Auto-iteration on failures (max 10 attempts)

### Phase 3: REFACTOR — Improve Code Quality

Improve code WHILE keeping tests green. Run tests after EACH change.

- Remove code duplication (DRY after 3rd occurrence)
- Improve naming
- Extract functions (if >50 lines)
- Simplify complex logic

**Verify simplicity**: Is this the simplest solution? Would a junior understand it? Abstractions justified by 3+ use cases? Size limits respected?

### Phase 4: VERIFY — Affected Tests and Coverage

- Run affected tests (changed files + files that reference them). NOT full suite.
- Check coverage ≥ 80% (or plan's target), critical paths 100%
- Verify no debug code (`console.log`, `debugger`, `print()`)
- **Intent Fulfillment Check**: Does implementation fulfill the step's stated purpose?
- **Overfitting Detection**: Watch for functions returning exact test values without real logic, switch statements mapping test inputs to expected outputs.

For detailed phase procedures, see `references/tdd-phases.md`.

---

## Implementation Constraints

Constraints are passed from plan's `overview.md`.

**MUST respect**: File size limits, simplicity requirements, architectural patterns, security checkpoints, performance budgets.

**Defaults** (when none specified): KISS, YAGNI, DRY after 3rd occurrence, files <500 lines, functions <50 lines, complexity <10.

**If constraints conflict**: STOP. Document concern and request PM guidance.

---

## SOPs to Reference

| Phase | SOPs to Consult |
|-------|-----------------|
| RED (Tests) | `testing-guide.md`, `flexible-testing-guide.md` |
| GREEN (Implementation) | `architecture-patterns.md`, `security-and-performance.md` |
| REFACTOR (Quality) | `architecture-patterns.md`, `security-and-performance.md` |

---

## Completion Report Format

```text
═══════════════════════════════════════
  STEP [N] COMPLETE: [Step Name]
═══════════════════════════════════════

**Framework Selection**:
  - [file1]: [framework] ([code context])

**Tests Written**: [X] tests
  - [X] happy path, [X] edge case, [X] error condition

**Tests Passing**: [X]/[X] (MUST be 100%)

**Files Modified**: [list with brief descriptions]
**Files Created**: [list with purposes]

**Coverage for This Step**: [Y]%

**Refactorings Applied**: [list]

**Implementation Constraints Respected**: [list with verification]

**Blockers or Notes**: [Any issues or notes]

**Ready for Next Step**: Yes/No
```

### Critical Requirements

Before returning control:
- [ ] All tests passing (100%)
- [ ] Affected tests passing (no regressions)
- [ ] Coverage met (step target, default 80%)
- [ ] No debug code
- [ ] Constraints respected
- [ ] Plan synchronized

---

## Quality Standards

### Test Quality
- Test-First Development (RED before GREEN)
- Comprehensive Coverage (happy path, edge cases, errors)
- Descriptive test names
- Independent tests (any order)
- Appropriate assertions (exact for deterministic, flexible for non-deterministic)

### Implementation Quality
- Simplest solution
- Pattern alignment with codebase
- Constraint compliance
- Size limits (files <500, functions <50)
- No debug code

### TDD Compliance
- RED: All tests written and failing before implementation
- GREEN: Minimal code to pass tests
- REFACTOR: Code improved while green
- VERIFY: Affected tests passing, coverage met

---

## Human Collaboration Boundaries

**Proceed Autonomously**: Mechanical implementation, iterative fixes (up to 10), refactoring, pattern replication, test writing, coverage improvement.

**Request Human Input For**: Architectural decisions, design trade-offs, security-critical choices, unclear requirements, scope creep, breaking changes, persistent failures after 10 attempts.

**Escalation Pattern**:
```text
DECISION REQUIRED
Context: [What you're accomplishing]
Options: [2-3 approaches with trade-offs]
Recommendation: [If any, with reasoning]
Why Human Input Needed: [Category]
```
