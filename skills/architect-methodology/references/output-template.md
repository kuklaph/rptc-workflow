# Plan Output Template

Follow this template EXACTLY when generating implementation plans. Use checkbox format `- [ ]` for all tasks.

---

````markdown
# Implementation Plan: [Feature Name]

## Status Tracking

- [x] Planned
- [ ] In Progress (TDD Phase)
- [ ] Code Review
- [ ] Security Review
- [ ] Complete

**Created:** [Date]
**Last Updated:** [Date]

---

## Executive Summary

**Feature:** [1-sentence description]

**Purpose:** [Why we're building this]

**Approach:** [High-level strategy]

**Estimated Complexity:** [Simple/Medium/Complex]

**Estimated Timeline:** [X-Y hours/days]

**Key Risks:** [Top 2-3 risks identified]

---

## Research References (If Applicable)

**Research Document:** `docs/research/[topic].md` (if saved) or inline findings

**Key Findings:**

- [Finding 1]
- [Finding 2]
- [Finding 3]

**Relevant Files Identified:**

- `[path]/[file].[ext]` - [Purpose]

---

## Test Strategy

### Testing Approach

- **Framework:** [Test framework name]
- **Coverage Goal:** 85% overall, 100% critical paths
- **Test Distribution:** Unit (70%), Integration (25%), E2E (5%)

### Happy Path Scenarios

#### Scenario 1: [Scenario Name]

- [ ] **Test:** [Test description]
  - **Given:** [Setup conditions]
  - **When:** [Action performed]
  - **Then:** [Expected outcome]
  - **File:** `tests/[path]/[name].test.[ext]`

#### Scenario 2: [Another Scenario]

[...]

### Edge Case Scenarios

#### Edge Case 1: [Boundary Condition]

- [ ] **Test:** [Test description]
  - **Given:** [Edge case setup]
  - **When:** [Action]
  - **Then:** [Expected handling]
  - **File:** `tests/[path]/[name].test.[ext]`

#### Edge Case 2: [Another Edge Case]

[...]

### Error Condition Scenarios

#### Error 1: [Error Type]

- [ ] **Test:** [Test description]
  - **Given:** [Error condition setup]
  - **When:** [Action that triggers error]
  - **Then:** [Expected error handling]
  - **File:** `tests/[path]/[name].test.[ext]`

#### Error 2: [Another Error]

[...]

### Coverage Goals

**Overall Target:** 85%

**Component Breakdown:**

- `[component-1]`: 95% (critical business logic)
- `[component-2]`: 90% (core functionality)
- `[component-3]`: 85% (standard coverage)
- `[component-4]`: 0% (configuration/constants)

**Excluded from Coverage:**

- Type definitions
- Configuration files
- Test utilities

---

## Implementation Steps

### Step 1: [Step Name]

**Purpose:** [What this accomplishes and why it's first]

**Prerequisites:**

- [ ] [Requirement 1]
- [ ] [Requirement 2]

**Tests to Write First:**

- [ ] Test: [Test name]

  - **Given:** [Setup]
  - **When:** [Action]
  - **Then:** [Expected]
  - **File:** `tests/[path]/[name].test.[ext]`

- [ ] Test: [Another test]
      [...]

**Files to Create/Modify:**

- [ ] `src/[path]/[file].[ext]` - [Purpose and what to implement]

**Implementation Details:**

**RED Phase** (Write failing tests first):

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

**GREEN Phase** (Minimal implementation to pass tests):

1. Create `src/[path]/[file].[ext]`
2. Implement [specific function/class]
3. Write minimal code to pass tests
4. Verify all tests pass

**REFACTOR Phase** (Improve while keeping tests green):

1. Extract [common logic if applicable]
2. Improve [naming/structure]
3. Ensure [KISS/YAGNI principles]
4. Re-run tests to ensure still passing

**Expected Outcome:**

- [Specific functionality now works]
- [Tests passing: X unit, Y integration]
- [What can be demonstrated]

**Acceptance Criteria:**

- [ ] All tests passing for this step
- [ ] Code follows project style guide
- [ ] No debug code (console.log, debugger)
- [ ] Coverage >= 80% for new code

**Estimated Time:** [X hours]

---

### Step 2: [Next Step Name]

[Repeat structure...]

---

## Dependencies

### New Packages to Install

- [ ] **Package:** `package-name@^version`
  - **Purpose:** [Why this is needed]
  - **Risk:** [Low/Medium/High]
  - **Alternatives Considered:** [Other options]
  - **Installation:** `npm install package-name` (or equivalent)
  - **Documentation:** [Link to docs]

### Database Migrations

- [ ] **Migration:** [Migration name]
  - **Description:** [What changes]
  - **Impact:** [Which tables/data affected]
  - **Rollback Plan:** [How to revert if needed]
  - **File:** `migrations/[timestamp]_[name].[ext]`

### Configuration Changes

- [ ] **Config:** [Configuration file]
  - **Changes:** [What settings to add/modify]
  - **Environment:** [All environments or specific?]
  - **Secrets:** [Any new secrets to add to .env]

### External Service Integrations

- [ ] **Service:** [Service name]
  - **Purpose:** [Why integrating]
  - **Setup Required:** [API keys, configuration, etc.]
  - **Error Handling:** [How to handle service downtime]

---

## Acceptance Criteria

**Definition of Done for this feature:**

- [ ] **Functionality:** All user stories/requirements implemented
- [ ] **Testing:** All tests passing (unit, integration, E2E)
- [ ] **Coverage:** Overall coverage >= 85%, critical paths 100%
- [ ] **Code Quality:** Passes linter, no debug code, follows style guide
- [ ] **Documentation:** Code comments, README updated if needed
- [ ] **Security:** No security vulnerabilities identified
- [ ] **Performance:** Meets performance requirements [specify if applicable]
- [ ] **Accessibility:** WCAG 2.1 AA compliance [if frontend]
- [ ] **Error Handling:** All error conditions handled gracefully
- [ ] **Review:** Code review completed and approved

**Feature-Specific Criteria:**

- [ ] [Specific criterion 1 related to this feature]
- [ ] [Specific criterion 2]
- [ ] [Specific criterion 3]

---

## Risk Assessment

### Risk 1: [Risk Name]

- **Category:** [Technical/Security/Performance/Schedule/Dependency]
- **Likelihood:** [High/Medium/Low]
- **Impact:** [High/Medium/Low]
- **Priority:** [Critical/High/Medium/Low]
- **Description:** [Detailed explanation of the risk]
- **Mitigation:**
  1. [Specific action to prevent/reduce risk]
  2. [Another mitigation step]
  3. [Monitoring strategy]
- **Contingency Plan:** [What to do if risk materializes]
- **Owner:** [Who monitors this risk]

### Risk 2: [Another Risk]

[Repeat structure...]

---

## File Reference Map

### Existing Files (To Modify)

**Core Files:**

- `src/[path]/[file].[ext]` - [Current purpose, what will change]
- `src/[path]/[file].[ext]` - [Current purpose, what will change]

**Test Files:**

- `tests/[path]/[file].test.[ext]` - [Current tests, what will be added]

**Configuration Files:**

- `[config-file]` - [What config changes needed]

### New Files (To Create)

**Implementation Files:**

- `src/[path]/[new-file].[ext]` - [Purpose and what it will contain]
- `src/[path]/[new-file].[ext]` - [Purpose]

**Test Files:**

- `tests/unit/[feature]/[component].test.[ext]` - [What tests]
- `tests/integration/[feature]/[flow].test.[ext]` - [What tests]
- `tests/e2e/[feature]/[journey].test.[ext]` - [What tests]

**Total Files:** [X modified, Y created]

---

## Assumptions

**Verify these assumptions before implementation:**

- [ ] **Assumption 1:** [Description]

  - **Source:** [FROM: research doc / ASSUMED based on standard practice]
  - **Impact if Wrong:** [What happens if this is incorrect]

- [ ] **Assumption 2:** [Description]
  - **Source:** [FROM: .context/project-overview.md]
  - **Impact if Wrong:** [Consequences]

---

## Plan Maintenance

**This is a living document.**

### How to Handle Changes During Implementation

1. **Small Adjustments:** Update plan inline, note in "Deviations" section
2. **Major Changes:** Request plan modification before continuing
3. **Blockers:** Document in "Implementation Notes" section

### Deviations Log

**Format:**

```markdown
- **Date:** [YYYY-MM-DD]
- **Change:** [What changed from original plan]
- **Reason:** [Why the change was needed]
- **Impact:** [How this affects other steps]
```

### When to Request Replanning

Request full replan if:

- Core requirements change significantly
- Technical blockers require fundamental redesign
- Security/compliance issues discovered
- Estimated effort > 2x original estimate

---

## Implementation Notes (Updated During TDD Phase)

**This section filled during implementation by TDD phase.**

### Completed Steps

- [x] Step 1: [Name] - Completed [date]
  - Tests passing: [X unit, Y integration]
  - Actual time: [X hours] (estimated: [Y hours])
  - Notes: [Any important notes]

### In Progress

- [ ] Step 2: [Name] - Started [date]
  - Current status: [RED/GREEN/REFACTOR phase]
  - Blockers: [Any issues encountered]

### Pending

- [ ] Step 3: [Name]
- [ ] Step 4: [Name]

---

## Next Actions

**After Plan Complete:**

1. **For Developer:** Continue with TDD implementation phase
2. **Quality Gates:** Code Review Agent + Security Agent (parallel execution)
3. **Completion:** Verify all acceptance criteria met

**Next:** TDD implementation begins automatically in `/rptc:feat` workflow

---

_Plan created by Master Architect_
_Status: Ready for TDD Implementation_

````
