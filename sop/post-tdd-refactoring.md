# Post-TDD Refactoring Checklist

## Purpose

Comprehensive 5-phase refactoring workflow for efficiency optimization after all tests passing. Integrates Code Simplicity research (60-80% reduction, Rule of Three, AI over-engineering detection).

## Evidence-Based Foundation

**Research Findings:**
- 60-80% code reduction: Surgical coding + simplicity directives
- 8× duplication decrease: Explicit guidance reduces duplication 800% → 100%
- 322% vulnerability reduction: Security SOP prevents AI-introduced gaps

**References:**
- `.rptc/research/code-simplicity-research.md` (Phase 1 foundation)
- `architecture-patterns.md` → AI Over-Engineering Prevention
- `security-and-performance.md` → AI Security Verification Checklist

---

## Phase 1: Pre-Analysis (Required Before Changes)

### 1.1 Verify Test Status

**BLOCKING CHECK:** All tests must pass before refactoring begins.

```bash
# Run project test command
[test_runner] test

# Confirm 100% passing
✅ Expected: All tests green, no warnings
```

### 1.2 Baseline Metrics

Capture current state for comparison:

**Quantitative Metrics:**
- Cyclomatic complexity (avg and max per function)
- Cognitive complexity (avg and max)
- Maintainability Index (per file and project avg)
- Lines of Code (total and per file)
- Test coverage (overall %)
- Duplication ratio (% of duplicate code)

**Tools by Language:**
- TypeScript: `ts-complexity`, SonarQube
- Python: `radon cc`, `radon mi`, `pylint --reports=y`
- Go: `gocyclo`, `gocognit`
- Java: PMD, SonarQube
- .NET: NDepend, Visual Studio metrics

**Code Simplicity Metrics (NEW - Phase 1 Integration):**
- Abstraction count (classes, interfaces, base classes)
- Single-use abstraction count (abstractions with 1 implementation)
- AI anti-pattern violations (5 patterns from architecture-patterns.md)
- Pattern reuse ratio (actual use cases ÷ abstractions)

### 1.3 Review Context

**SOPs to Load (Fallback Chain):**
1. `.rptc/sop/languages-and-style.md` (or fallback to user/plugin)
2. `.rptc/sop/architecture-patterns.md` (or fallback)

**Project Context:**
- `.context/testing-strategy.md` (if exists)
- `.context/architecture-decisions.md` (if exists)
- Implementation plan (if referenced)

**Surgical Coding Approach (Phase 1):**
- [ ] Search for 3 similar patterns in codebase
- [ ] Analyze how existing code solves similar problems
- [ ] Verify minimal changes possible (modify 1 file vs. create many)

---

## Phase 2: Dead Code Sweep (Incremental)

### 2.1 Identify Dead Code Categories

**Targets:**
- Unused imports/dependencies
- Unused variables, parameters, functions, classes
- Unreachable code paths (after return, inside `if (false)`)
- Commented-out code blocks
- Deprecated/replaced functionality still present

### 2.2 Detection Tools by Language

**TypeScript/JavaScript:**
```bash
eslint --ext .ts,.js src/
# Focus on @typescript-eslint/no-unused-vars
```

**Python:**
```bash
vulture src/ --min-confidence=80
pylint src/ --disable=all --enable=W0611,W0612,W0613
```

**Go:**
```bash
go vet ./...
staticcheck ./...
```

**Java:**
```bash
# IntelliJ: Analyze > Run Inspection by Name > "Unused declaration"
# Or use PMD with UnusedPrivateField, UnusedLocalVariable rules
```

**.NET:**
```bash
# ReSharper: Code Inspection > "Unused member" category
# Or use NDepend with dead code query rules
```

### 2.3 Removal Protocol

**CRITICAL:** Remove incrementally, test after EACH category.

**Order:**
1. Unused imports → Run tests ✅
2. Unused variables → Run tests ✅
3. Unused private functions/methods → Run tests ✅
4. Unreachable code → Run tests ✅
5. Commented-out code → Run tests ✅

**Safety Check for Dynamic Code:**
```bash
# Before removing, grep for dynamic references
rg "functionName" --type-not test
rg "getattr|hasattr" --type py  # Python reflection
rg "reflect\." --type go         # Go reflection
```

### 2.4 Document Removal

**Track in report:**
- Total lines removed
- Categories removed (imports, variables, functions, classes)
- Examples of removed code
- Tests still passing ✅

---

## Phase 3: Complexity Reduction (Targeted Refactoring)

### 3.1 Identify High-Complexity Areas

**Thresholds (Research-Backed):**
- Cyclomatic Complexity: >10 per function (NIST recommendation)
- Cognitive Complexity: >15 (SonarQube default)
- Function Length: >50 lines
- Nesting Depth: >3 levels
- Parameter Count: >3-4 parameters

**Tools:**
- Run complexity analysis (see Phase 1 tools)
- Sort by worst offenders
- Prioritize high-impact areas (most changed, critical paths)

### 3.2 Refactoring Patterns (Martin Fowler Catalog)

#### Pattern 1: Extract Method (Long Functions)

**Before:**
```typescript
function processOrder(order: Order) {
  // 80 lines of mixed validation, calculation, persistence
}
```

**After:**
```typescript
function processOrder(order: Order) {
  validateOrder(order);
  const total = calculateTotal(order);
  persistOrder(order, total);
}
```

**Test after refactoring ✅**

#### Pattern 2: Decompose Conditional (Complex Logic)

**Before:**
```python
if user.age >= 18 and user.has_license and not user.has_violations:
    allow_rental()
```

**After:**
```python
if is_eligible_for_rental(user):
    allow_rental()

def is_eligible_for_rental(user):
    return user.age >= 18 and user.has_license and not user.has_violations
```

**Test after refactoring ✅**

#### Pattern 3: Replace Nested Conditional with Guard Clauses

**Before:**
```java
if (user != null) {
    if (user.isActive()) {
        if (user.hasPermission()) {
            doAction();
        }
    }
}
```

**After:**
```java
if (user == null) return;
if (!user.isActive()) return;
if (!user.hasPermission()) return;

doAction();
```

**Test after refactoring ✅**

#### Pattern 4: Introduce Parameter Object (Long Parameter Lists)

**Before:**
```go
func CreateUser(name, email, phone, address, city, zip, country string) User
```

**After:**
```go
type UserInfo struct {
    Name, Email, Phone string
    Address AddressInfo
}

func CreateUser(info UserInfo) User
```

**Test after refactoring ✅**

### 3.3 Re-Measure Complexity

After each refactoring:
- Run complexity analysis
- Verify reduction
- Document improvement in report

---

## Phase 4: Readability Pass (Human-Centric)

### 4.1 Naming Audit

**Red Flags:**
- Generic names: `temp`, `data`, `x`, `foo`, `thing`, `info`
- Misleading names (function does more than name implies)
- Inconsistent conventions (camelCase + snake_case mixed)
- Overly long names (>30 characters questionable)
- Unexplained abbreviations (`usrMgr` vs `userManager`)

**Fixes:**
- Rename for intent: `temp` → `userSessionData`
- Follow language conventions:
  - TypeScript: camelCase (variables/functions), PascalCase (classes)
  - Python: snake_case (variables/functions), PascalCase (classes)
  - Go: MixedCase (exported), mixedCase (unexported)
- Run tests after batch rename ✅

### 4.2 Comment Audit

**REMOVE:**
- Redundant: `// Increment counter` above `counter++`
- Outdated: Comment describes old behavior
- WHAT comments: Code should explain WHAT via naming

**KEEP/ADD:**
- WHY comments: Business logic rationale
- Complex algorithms: Brief explanation of approach
- Edge case handling: Why this check exists
- Bug fix context: Reference to issue/ticket
- Unidiomatic code: Why standard approach not used

### 4.3 Formatting

**Auto-format with language tools:**
```bash
# TypeScript/JavaScript
prettier --write src/

# Python
black src/

# Go (always format)
gofmt -w .
go fmt ./...

# Java
# Use IDE formatter (IntelliJ, Eclipse)

# C#
dotnet format
```

**Manual adjustments:**
- Vertical whitespace: Separate logical sections
- Line length: Follow language conventions (80-120 chars)
- Consistent indentation: Verify after format

**Test after formatting ✅**

---

## Phase 5: KISS & YAGNI Audit (Simplicity Enforcement)

### 5.1 AI Over-Engineering Detection (Phase 1 Integration)

**5 Anti-Patterns to Eliminate** (from architecture-patterns.md):

#### Anti-Pattern 1: Abstract Base Classes for Single Implementation

**Detect:**
```bash
# Find abstractions with single implementation
rg "abstract class|interface" --type ts | while read line; do
  # Manual check: Does this have 2+ implementations?
done
```

**Decision:**
- <3 implementations → Inline abstraction, use concrete class
- ≥3 implementations → Keep abstraction (Rule of Three)

**Test after removal ✅**

#### Anti-Pattern 2: Factory/Builder for Simple Instantiation

**Detect:**
```bash
rg "Factory|Builder" --type py
# Check: Is constructor complex enough to justify factory?
```

**Decision:**
- Simple constructor → Direct instantiation
- Complex initialization (5+ params, conditional logic) → Keep factory

**Test after removal ✅**

#### Anti-Pattern 3: Middleware for Direct Operations

**Detect:**
```bash
rg "middleware|pipeline" --type js
# Check: Are there 5+ operations needing composition?
```

**Decision:**
- <5 operations → Direct function calls
- ≥5 operations + dynamic composition → Keep middleware

**Test after removal ✅**

#### Anti-Pattern 4: Event-Driven for Tightly Coupled Code

**Detect:**
```bash
rg "eventBus|EventEmitter" --type java
# Check: Are components loosely coupled?
```

**Decision:**
- Tight coupling (same module) → Direct method calls
- Loose coupling (cross-module, async) → Keep events

**Test after removal ✅**

#### Anti-Pattern 5: Interfaces with Single Implementation

**Detect:**
```bash
rg "interface I[A-Z]" --type cs
# Check: Does interface have 2+ implementations?
```

**Decision:**
- Single implementation → Concrete class
- 2+ implementations → Keep interface

**Test after removal ✅**

### 5.2 YAGNI Violations (Speculative Features)

**Identify:**
- Features not in current requirements
- "Future-proofing" without concrete use case
- Over-generalization (flexibility never used)
- Premature optimizations
- Configuration for scenarios that don't exist

**Decision Framework:**
- Remove if: No current use + Adds complexity + Easy to re-implement later
- Keep if: Actually used + Reduces complexity + Hard to add later
- Uncertain? Apply **Rule of Three**: Wait for 3rd instance before abstracting

**Test after removal ✅**

### 5.3 Rule of Three Enforcement

**For each abstraction in codebase:**

**Count actual use cases:**
- 1 use case → **Remove abstraction**, use concrete implementation
- 2 use cases → **Evaluate**: Nearly identical patterns? Keep duplication or refactor
- 3+ use cases → **Keep abstraction** (DRY principle applies)

**Document in report:**
- Abstractions removed (single-use)
- Abstractions kept (3+ uses justified)
- Duplication preserved (waiting for 3rd instance)

### 5.4 Code Simplicity Metrics (NEW - Phase 1 Validation)

**Calculate and report:**

1. **Code Reduction %:**
   ```
   Reduction = ((Baseline LOC - Final LOC) / Baseline LOC) × 100%
   Target: 5-15% reduction (research shows 60-80% possible with AI guidance)
   ```

2. **Duplication Ratio:**
   ```
   Ratio = (Duplicate LOC / Total LOC) × 100%
   Target: <5% (research shows AI without guidance: 40%+)
   ```

3. **AI Anti-Pattern Count:**
   ```
   Count = Number of 5 anti-patterns detected and removed
   Target: 0 remaining (all violations fixed)
   ```

4. **Pattern Reuse Efficiency:**
   ```
   Efficiency = (Total use cases / Total abstractions)
   Target: ≥2.0 (avg 2+ uses per abstraction = Rule of Three followed)
   ```

**Include in final report under "Code Simplicity Validation" section**

---

## Phase 6: Final Verification & Reporting

### 6.1 Test Verification (BLOCKING)

```bash
# Full test suite
[test_runner] test

✅ MUST: 100% tests passing
✅ MUST: Coverage ≥ baseline
✅ MUST: No new warnings
```

### 6.2 Static Analysis

```bash
# Linter
[linter] check .

✅ MUST: Linter passing
✅ SHOULD: Fewer issues than baseline
```

### 6.3 Final Metrics

Re-measure all Phase 1 baseline metrics:
- Cyclomatic complexity (should be ≤ baseline)
- Cognitive complexity (should be ≤ baseline)
- Maintainability Index (should be ≥ baseline)
- LOC (likely reduced)
- Test coverage (should be ≥ baseline)

### 6.4 Generate Report

**Format:** See agent prompt for complete template

**Required Sections:**
1. Context (work item, files, tests)
2. Changes Made (dead code, complexity, readability, KISS/YAGNI)
3. Code Quality Metrics (before/after table)
4. **Code Simplicity Validation (NEW):**
   - Code reduction %
   - Duplication ratio
   - AI anti-pattern count
   - Pattern reuse efficiency
5. Test Verification (all passing)
6. Files Modified (with descriptions)
7. Summary (achievements, code health status)

---

## Tools Reference

### Static Analysis Tools by Language

**TypeScript/JavaScript:**
- ESLint: `npm install --save-dev eslint @typescript-eslint/eslint-plugin`
- Complexity: `npm install --save-dev ts-complexity`
- Formatter: `npm install --save-dev prettier`

**Python:**
- Dead Code: `pip install vulture`
- Linter: `pip install pylint flake8`
- Complexity: `pip install radon`
- Formatter: `pip install black`

**Go:**
- Built-in: `go vet`, `gofmt`
- Static Check: `go install honnef.co/go/tools/cmd/staticcheck@latest`
- Complexity: `go install github.com/fzipp/gocyclo/cmd/gocyclo@latest`

**Java:**
- PMD: Static analysis with rulesets
- SonarQube: Comprehensive metrics
- Checkstyle: Style enforcement

**.NET/C#:**
- ReSharper: Visual Studio extension
- NDepend: Comprehensive analysis
- SonarLint: Real-time feedback

### Configuration Examples

**ESLint (.eslintrc.json):**
```json
{
  "rules": {
    "@typescript-eslint/no-unused-vars": ["error", {
      "argsIgnorePattern": "^_"
    }],
    "complexity": ["warn", 10],
    "max-lines-per-function": ["warn", 50],
    "max-depth": ["warn", 3]
  }
}
```

**Vulture (vulture.cfg):**
```ini
[vulture]
min_confidence = 80
paths = src/
exclude = */tests/*,*/migrations/*
```

---

## Decision Framework (6 Questions)

For every optimization, ask:

### 1. Is it dead code?
- ✅ YES → Remove incrementally, test after each
- ❌ NO → Next question
- ❓ UNSURE → Grep for dynamic references

### 2. Is it complex? (>10 cyclomatic OR >15 cognitive)
- ✅ YES → Apply refactoring patterns
- ❌ NO → Next question
- ❓ INHERENTLY COMPLEX → Add comments, don't force simplification

### 3. Does it violate KISS/YAGNI?
- ✅ YES → Check: Used? 3+ implementations? Required?
  - If NO to any → Remove
- ❌ NO → Next question

### 4. Is naming unclear?
- ✅ YES → Rename for intent, test
- ❌ NO → Next question

### 5. Are there redundant comments?
- ✅ YES → Remove WHAT, keep WHY
- ❌ NO → Next question

### 6. Can abstraction be simplified?
- ✅ YES → Apply Rule of Three:
  - <3 uses → Inline
  - ≥3 uses → Keep
- ❌ NO → Move to next file

---

## Industry Best Practices

### Google (Continuous Improvement)
- "Good enough" > perfect
- Incremental improvements compound
- Automate what can be automated

### Microsoft (Human Focus)
- Automate nits (formatting, imports)
- Humans review logic and design
- Metrics inform, don't dictate

### Netflix (Ownership)
- Teams own code quality
- Freedom with responsibility
- Shared standards, flexible implementation

### Spotify (Fail Fast)
- Small experiments
- Learn from mistakes quickly
- Psychological safety for refactoring

---

## References

**Research Foundation:**
- `.rptc/research/code-simplicity-research.md` (Phase 1)
- `.rptc/research/master-efficiency-agent-research.md` (30+ sources)

**SOPs:**
- `architecture-patterns.md` → AI Over-Engineering Prevention (5 anti-patterns)
- `security-and-performance.md` → AI Security Checklist
- `languages-and-style.md` → Language conventions
- `testing-guide.md` → TDD methodology

**Academic Research:**
- Cyclomatic Complexity: McCabe (1976)
- Cognitive Complexity: SonarSource (2016)
- Maintainability Index: SEI/Microsoft

**Industry Thought Leaders:**
- Martin Fowler: Refactoring catalog
- Robert C. Martin: SOLID principles
- Kent Beck: Simplicity rules

---

_This SOP is referenced by Master Efficiency Agent via fallback chain_
_Project-specific overrides: `.rptc/sop/post-tdd-refactoring.md`_
