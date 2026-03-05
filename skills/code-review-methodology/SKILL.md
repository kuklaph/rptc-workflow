---
name: code-review-methodology
description: Code review methodology for the RPTC code-review agent. Covers hierarchical review framework (4 tiers), over-engineering checklist, integration completeness check, behavioral testing checklist, assertion quality checklist, false positive guidance, confidence scoring (>=80 threshold), domain-specific checks, and structured output format. Report-only mode.
---

# Code Review Methodology

Code review execution patterns for the RPTC code-review agent. **Report-only** — never edit files.

---

## Review Philosophy

**Net Positive > Perfection**: Primary objective is determining if the change improves overall code health. Do not block on imperfections if the change is a net improvement.

**Signal Intent**:
- Prefix minor polish suggestions with "**Nit:**" (Tier 4)
- All findings are actionable — nits included for completeness

---

## Scope

**Flexible scope** — select based on context:

| Mode | When to Use | Input |
|------|-------------|-------|
| **PR Review** | Feature branch vs base | `git diff main...HEAD` |
| **Change Review** | Pre-commit check (default) | `git diff` or `git diff --cached` |
| **Directory Review** | Targeted cleanup | Specified directory path |
| **Codebase Sweep** | Full cleanup (explicit request only) | Entire project |

**Selection Logic:**
1. PR context provided -> PR Review
2. Directory specified -> Directory Review
3. "Sweep" or "cleanup" explicitly requested -> Codebase Sweep
4. Default -> Change Review

**Use git blame** when helpful to understand why code was written this way originally.

---

## Hierarchical Review Framework

Analyze in this priority order:

### Tier 1: Critical (Must Address)

**Architectural Integrity**
- System boundary violations (mixing layers)
- Modularity issues (tight coupling, circular dependencies)
- Single Responsibility violations at module/class level
- AI over-engineering patterns:
  - Abstract base class with only 1 implementation
  - Factory/Builder for simple constructor
  - Interface with only 1 implementation
  - Middleware layer for <5 operations
  - Event bus within same module

**Functionality & Correctness**
- Logic flaws and off-by-one errors
- Race conditions and state management issues
- Null/undefined handling gaps
- Error handling that swallows important information

**Integration Completeness** (Orphan Code Detection)
- New exported functions/classes with no callers outside test files
- New UI components defined but not rendered/mounted anywhere
- New API endpoints defined but not registered in router
- Event handlers defined but not attached to triggers
- **Detection**: Use `find_referencing_symbols`, filter out test file references
- **Threshold**: Flag if 0 non-test references found for new exported code

### Tier 2: High Priority

**Maintainability & Readability**
- Unclear naming (variables, functions, classes)
- Deep nesting (>3 levels)
- Clever one-liners that sacrifice readability
- Missing or misleading comments on complex logic
- Inconsistent patterns within the codebase

**Dead Code** (flag obvious cases)
- Unused imports and dependencies
- Unused private variables and functions
- Unreachable code after return/throw/break

**Testing Strategy** (when tests are in scope)
- Coverage gaps on critical paths
- Missing edge case tests
- Poor test isolation
- Tests that don't actually verify behavior
- **Behavioral testing violations** (see checklist below)
- **Assertion quality issues** (see checklist below)

### Tier 3: Important

**Performance** (flag only obvious issues)
- N+1 query patterns (backend)
- Unnecessary re-renders (frontend)
- O(n^2) or worse algorithms on large datasets
- Missing caching for expensive repeated operations
- Bundle size impact from large imports (frontend)

**Dependencies** (when new dependencies added)
- Is the dependency necessary? Could stdlib suffice?
- Is it actively maintained?
- License compatibility concerns
- Size impact (especially frontend)

### Tier 4: Nits (Minor Polish)

**Code Style & Clarity**
- Variable names that could be more descriptive
- Inconsistent formatting not caught by linter
- Minor naming convention deviations
- Slightly awkward code structure
- Missing optional type annotations

---

## Behavioral Testing Checklist

Tests should verify **behavior** (what the code does from the caller's perspective), not **implementation** (how it does it internally). Flag tests that violate this principle.

**Flag when**:

| Signal | Example | Why It's a Problem |
|--------|---------|-------------------|
| Mocking internal collaborators | Mocking a private helper or an internal service method that isn't an external boundary | Couples test to implementation; refactoring breaks tests without changing behavior |
| Interaction verification on internals | `.toHaveBeenCalledWith()` or `assert_called_once_with()` on methods that are not external API calls | Asserts *how* code works, not *what* it produces |
| Test names reference implementation details | `"should call _validateInput"`, `"should set internal state to X"` | Tests should describe observable outcomes, not internal steps |
| Mocking the system under test | `jest.spyOn(service, 'privateMethod')` on the class being tested | Tests should exercise the real code path |

**Do NOT flag**:

- Mocking external boundaries (databases, HTTP clients, file system, third-party APIs) — this is correct practice
- Verifying that an external API was called with correct arguments — this is boundary verification, not internal coupling
- Spying on event emissions or callbacks that are part of the public contract

**Confidence**: Score 85+ when the mock target is clearly internal (same module, private method, helper function). Score 75 (skip) when uncertain whether the dependency is internal or external.

---

## Assertion Quality Checklist

Tests with weak or missing assertions provide false confidence. Flag these patterns:

| Pattern | Example | Fix |
|---------|---------|-----|
| **Zero assertions** | Test body calls functions but never asserts | Add assertions verifying return values or side effects |
| **Truthiness-only** | `assert result is not None` or `expect(x).toBeTruthy()` as sole assertion | Assert specific values, types, or properties |
| **Mock-only assertions** | Assertions only on mock call counts, never on actual output | Add assertions on the return value or observable state change |
| **No SUT reference** | Assertions don't reference the function's return value or the object's state after calling it | Ensure at least one assertion checks the system under test's output |

**Scoring guidance**:
- Zero-assertion test: confidence 95 (always a bug)
- Truthiness-only as sole assertion: confidence 90
- Mock-only assertions with no output check: confidence 85
- Assertions present but weak (e.g., only checks type, not value): confidence 75 (skip — judgment call)

---

## Domain-Specific Checks

### Frontend (when applicable)
- Bundle size impact from new imports
- Rendering performance (unnecessary re-renders, missing keys)
- Core Web Vitals impact (LCP, CLS, INP)
- Accessibility gaps (missing ARIA, keyboard navigation)
- State management complexity

### Backend (when applicable)
- N+1 query patterns
- Missing database indexes for queried fields
- Inefficient algorithms on large datasets
- Missing caching opportunities
- Resource exhaustion risks (unbounded queries, memory leaks)

---

## Over-Engineering Checklist

**Benchmark**: Would a junior engineer's straightforward solution work here?

| Pattern | Red Flag | Keep If... |
|---------|----------|------------|
| Abstract base class | Only 1 implementation | 3+ implementations exist |
| Factory/Builder | Simple constructor works | Complex initialization logic required |
| Interface | Only 1 implementation | 2+ implementations exist |
| Middleware layer | <5 operations | Dynamic composition needed |
| Event bus | Same module only | Cross-module communication required |

**Rule of Three**: Don't abstract until you have 3 actual use cases.

---

## False Positive Guidance

**Do NOT report these:**

- Issues a linter/formatter would catch
- Pedantic nitpicks a senior engineer would ignore
- Issues explicitly silenced via lint ignore comments with justification
- Intentional tradeoffs documented in comments
- Style preferences not established in project conventions

**Scope boundary for pre-existing issues:**

- **Skip** pre-existing issues in files or functions unrelated to the current change
- **Report** pre-existing issues when they are in the same function, class, or logical unit as changed code — these are related and the developer is already working in this area
- **Report** pre-existing issues that interact with, depend on, or could be affected by the current change (e.g., a caller that doesn't handle the new error case)
- When in doubt about relatedness, report it — let the main context decide whether to address it

---

## Confidence Scoring

Score each finding 0-100:

| Score | Meaning | Report? |
|-------|---------|---------|
| 90-100 | Certain issue, obvious fix | Yes |
| 80-89 | Real issue, clear improvement | Yes |
| 60-79 | Likely issue, needs context | Skip |
| <60 | Uncertain, possible false positive | Skip |

**Only report issues >=80 confidence.**

---

## Issue Tags

- **ARCHITECTURE**: System boundaries, modularity, coupling
- **CORRECTNESS**: Logic flaws, race conditions, error handling
- **COMPLEXITY**: Deep nesting, cyclomatic/cognitive complexity
- **STRUCTURE**: Abstractions, duplication, AI anti-patterns
- **PERFORMANCE**: Algorithms, queries, caching, bundle size
- **MAINTAINABILITY**: Naming, readability, documentation
- **TESTING**: Coverage, isolation, assertions
- **DEPENDENCY**: New dependencies, licensing, maintenance
- **INTEGRATION**: Orphan code, missing entry point wiring, unregistered routes

---

## Execution Flow

### Phase 1: Determine Scope
1. Check if git diff is available and appropriate
2. Otherwise use explicitly provided files
3. Note: file count, approximate lines changed

### Phase 2: Hierarchical Analysis
For each file, analyze in tier order:
1. **Tier 1 (Critical)**: Architecture, correctness
2. **Tier 2 (High)**: Maintainability, testing
3. **Tier 3 (Important)**: Performance, dependencies

For each potential finding:
- Calculate confidence (0-100)
- Check against false positive guidance
- Skip if <80 confidence or false positive
- Categorize by tag and tier

### Phase 2.5: Integration Completeness Check

**When**: New functions/classes/components were created (detected from git diff)

**Process**:
1. Identify new exported symbols from git diff
2. For each new symbol, use `find_referencing_symbols`, filter out test files
3. If 0 production callers found, flag as Tier 1 orphan code

**Skip conditions**: No new exported symbols, or Serena MCP unavailable

### Phase 3: Report
Output findings grouped by tier with confidence scores, locations, and suggestions.

---

## Output Format

Return structured findings:

```json
{
  "findings": [
    {
      "tier": 1,
      "confidence": 95,
      "category": "ARCHITECTURE",
      "description": "Service directly accesses database, bypassing repository layer",
      "location": "src/services/user.ts:45",
      "suggestion": "Use UserRepository for data access",
      "principle": "Layer separation"
    }
  ],
  "contextNeeded": [
    {
      "confidence": 75,
      "description": "LegacyAdapter class appears unused",
      "location": "src/adapters/legacy.ts:1",
      "risk": "May be used via dynamic import"
    }
  ],
  "summary": {
    "filesReviewed": 5,
    "tier1Critical": 2,
    "tier2High": 3,
    "tier3Important": 1,
    "tier4Nits": 2,
    "contextNeeded": 1,
    "netPositive": true
  }
}
```

---

## Final Checklist

Before returning findings:
- [ ] All Tier 1 issues identified? (these are blockers)
- [ ] Integration completeness checked? (new exports have production callers)
- [ ] Behavioral testing checklist applied? (internal mocking, interaction verification)
- [ ] Assertion quality checklist applied? (zero-assertion, truthiness-only, mock-only)
- [ ] False positive guidance applied?
- [ ] Confidence >=80 for all reported issues?
- [ ] Nits included as Tier 4 findings?
- [ ] Context-needed items flagged appropriately?
- [ ] Overall assessment: Is this change net positive?
