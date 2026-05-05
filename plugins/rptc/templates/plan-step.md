# Step [N]: [Clear, Action-Oriented Name]

## Purpose

[What this step accomplishes and why it's in this position]

**Relation to Feature:** [How this step contributes to overall feature]

---

## Prerequisites

- [ ] [Previous step completed OR initial setup requirement]
- [ ] [Required dependency installed OR file exists]

---

## Tests to Write First

**Step Complexity**: [Simple/Medium/Complex]

**Test Allocation** (based on complexity):
| Complexity | Files | Lines | Target Tests |
|------------|-------|-------|--------------|
| Simple | 1 file | <30 lines | ~15 tests |
| Medium | 1-2 files | 30-80 lines | ~30 tests |
| Complex | 3+ files | >80 lines | ~50 tests |

**Framework Selection**: Determine test framework per file based on code context:
- `utility` code → Project unit runner (Bun/Jest/Vitest)
- `frontend-ui` → React Testing Library or Playwright
- `backend-api` → supertest
- `browser-dependent` → Playwright REQUIRED

### Happy Path Tests

- [ ] **Test:** [Test name and description]
  - **Given:** [Setup conditions]
  - **When:** [Action performed]
  - **Then:** [Expected outcome]
  - **File:** `tests/[path]/[name].test.[ext]`

### Edge Case Tests

- [ ] **Test:** [Boundary condition description]
  - **Given:** [Edge case setup]
  - **When:** [Action]
  - **Then:** [Expected handling]
  - **File:** `tests/[path]/[name].test.[ext]`

### Error Condition Tests

- [ ] **Test:** [Error scenario]
  - **Given:** [Error setup]
  - **When:** [Action that triggers error]
  - **Then:** [Expected error handling]
  - **File:** `tests/[path]/[name].test.[ext]`

---

## Files to Create/Modify

- [ ] `src/[path]/[file].[ext]` - [Purpose and what to implement]
- [ ] `src/[path]/[another-file].[ext]` - [Purpose]

---

## Implementation Details

### RED Phase (Write failing tests first)

```[language]
// Test structure example
describe('[component]', () => {
  it('should [behavior]', () => {
    // Arrange: Set up test data
    const input = [...]

    // Act: Execute the code
    const result = [...]

    // Assert: Verify expectations
    expect(result).toBe([...])
  });
});
```

### GREEN Phase (Minimal implementation to pass tests)

1. Create `src/[path]/[file].[ext]`
2. Implement [specific function/class with signature]
3. Write minimal code to pass tests
4. Focus on correctness, not optimization

### REFACTOR Phase (Improve while keeping tests green)

1. Extract [common logic if applicable]
2. Improve [naming/structure]
3. Ensure [KISS/YAGNI principles]
4. Re-run tests to ensure still passing

---

## Expected Outcome

- [Specific functionality now works]
- [Tests passing: X unit, Y integration]
- [What can be demonstrated/verified]

---

## Acceptance Criteria

- [ ] All tests passing for this step
- [ ] Code follows project style guide
- [ ] No debug code (console.log, debugger)
- [ ] Coverage ≥ 80% for new code in this step

---

## Dependencies from Other Steps

[ONLY include if this step depends on previous steps]

- **Uses output from Step [N]:** [What component/data is used]
- **Modifies files from Step [N]:** [Which files are extended]

---

**Estimated Time:** [X hours]
