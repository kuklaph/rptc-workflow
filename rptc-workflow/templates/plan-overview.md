# Implementation Plan: [Feature Name]

## Status Tracking

- [x] Planned
- [ ] In Progress (TDD Phase)
- [ ] Efficiency Review
- [ ] Security Review
- [ ] Complete

**Created:** [YYYY-MM-DD]
**Last Updated:** [YYYY-MM-DD]
**Steps:** [N total steps]

---

## Configuration

### Quality Gates

**Efficiency Review**: [enabled/disabled]
**Security Review**: [enabled/disabled]

**Note**: Quality gates are optional. Set to "enabled" to run automated reviews after TDD implementation, or "disabled" to skip. Default is "enabled" for both if not specified.

---

## Executive Summary

**Feature:** [1-sentence description]

**Purpose:** [Why we're building this - business value]

**Approach:** [High-level strategy - architectural decisions]

**Estimated Complexity:** [Simple/Medium/Complex]

**Estimated Timeline:** [X-Y hours/days]

**Key Risks:** [Top 2-3 risks identified]

---

## Test Strategy

### Testing Approach

- **Framework:** [Test framework name]
- **Coverage Goal:** 85% overall, 100% critical paths
- **Test Distribution:** Unit (70%), Integration (25%), E2E (5%)

### Test Scenarios Summary

**Happy Path:** [Brief summary of main success scenarios]

**Edge Cases:** [Brief summary of boundary conditions to test]

**Error Conditions:** [Brief summary of error scenarios to test]

**Detailed test scenarios are in each step file** (step-01.md, step-02.md, etc.)

### Coverage Goals

**Overall Target:** 85%

**Component Breakdown:**

- `[component-1]`: 95% (critical business logic)
- `[component-2]`: 90% (core functionality)
- `[component-3]`: 85% (standard coverage)

---

## Acceptance Criteria

**Definition of Done for this feature:**

- [ ] **Functionality:** All user stories/requirements implemented
- [ ] **Testing:** All tests passing (unit, integration, E2E)
- [ ] **Coverage:** Overall coverage ≥ 85%, critical paths 100%
- [ ] **Code Quality:** Passes linter, no debug code, follows style guide
- [ ] **Documentation:** Code comments, README updated if needed
- [ ] **Security:** No security vulnerabilities identified
- [ ] **Performance:** Meets performance requirements [specify if applicable]
- [ ] **Error Handling:** All error conditions handled gracefully

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
- **Contingency Plan:** [What to do if risk materializes]

### Risk 2: [Another Risk]

[Repeat structure for top 3-5 risks...]

---

## Dependencies

### New Packages to Install

- [ ] **Package:** `package-name@^version`
  - **Purpose:** [Why this is needed]
  - **Risk:** [Low/Medium/High]

### Configuration Changes

- [ ] **Config:** [Configuration file]
  - **Changes:** [What settings to add/modify]
  - **Environment:** [All environments or specific?]

### External Service Integrations

- [ ] **Service:** [Service name]
  - **Purpose:** [Why integrating]
  - **Setup Required:** [API keys, configuration, etc.]

---

## File Reference Map

### Existing Files (To Modify)

- `src/[path]/[file].[ext]` - [Current purpose, what will change]
- `src/[path]/[file].[ext]` - [Current purpose, what will change]

### New Files (To Create)

- `src/[path]/[new-file].[ext]` - [Purpose and what it will contain]
- `tests/unit/[feature]/[component].test.[ext]` - [What tests]

**Total Files:** [X modified, Y created]

---

## Coordination Notes

**Step Dependencies:**

- Step 2 depends on Step 1: [Reason]
- Step 5 integrates Step 3 + Step 4: [How they connect]

**Integration Points:**

- [Component A] interfaces with [Component B] via [method/API]
- [System X] consumes data from [System Y]

---

## Next Actions

**After Plan Approval:**

1. **For PM:** Review and approve plan
2. **For Developer:** Execute with `/rptc:tdd "@[plan-directory-name]"`
3. **Quality Gates:** Efficiency Agent → Security Agent (after all steps complete)
4. **Completion:** Verify all acceptance criteria met

**First Step:** Run `/rptc:tdd "@[plan-directory-name]"` to begin TDD implementation

---

_Plan overview created by Master Feature Planner_
_Detailed steps in: step-01.md, step-02.md, ..., step-NN.md_
