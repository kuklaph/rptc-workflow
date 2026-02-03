# Implementation Plan: [Feature Name]

## Status Tracking

- [x] Planned
- [ ] In Progress (TDD Phase)
- [ ] Code Review
- [ ] Security Review
- [ ] Complete

**Created:** [YYYY-MM-DD]
**Last Updated:** [YYYY-MM-DD]
**Steps:** [N total steps]

---

## Configuration

### Quality Gates

**Code Review**: [enabled/disabled]
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

## Implementation Constraints

**File Size**: <500 lines (standard) | <300 lines (security-critical)

**Complexity**:
- Functions: <50 lines, cyclomatic complexity <10
- Classes: <100 lines

**Dependencies**:
- PROHIBITED: [List any prohibited patterns or libraries]
- REQUIRED: [List any required patterns or existing code to reuse]

**Platforms**: [Node.js 18+, Python 3.10+, etc.]

**Performance**: [Response time targets, resource limits, or "No special requirements"]

**Security**: [BLOCKING checkpoints, compliance requirements, or "Standard practices"]

---

## Research References

**Research Document:** [Link to `docs/research/[topic].md` if saved, or "Inline findings below"]

**Key Findings from Discovery Phase:**
- [Finding 1 - relevant pattern or insight]
- [Finding 2 - existing code to reuse]
- [Finding 3 - constraint or consideration]

**External Resources Consulted:**
- [Resource 1 with link if applicable]
- [Resource 2]

---

## Assumptions

**IMPORTANT:** Verify these assumptions before implementation:

- [ ] **Assumption 1:** [Description - e.g., "Existing auth middleware handles token validation"]
- [ ] **Assumption 2:** [Description - e.g., "Database schema allows nullable field X"]
- [ ] **Assumption 3:** [Description - e.g., "API consumers handle 429 rate limit responses"]

**If any assumption is invalid, STOP and request plan modification.**

---

## Plan Maintenance

**This is a living document.**

**During Implementation:**

1. **Small Adjustments:** Update plan inline, note in "Deviations" section below
2. **Major Changes:** Request plan modification before continuing
3. **Blockers:** Document in "Implementation Notes" section below

### Deviations Log

| Date | Step | Deviation | Reason | Impact |
|------|------|-----------|--------|--------|
| [YYYY-MM-DD] | [N] | [What changed] | [Why] | [Low/Medium/High] |

---

## Implementation Notes (Updated During TDD Phase)

**This section filled during implementation by TDD phase.**

### Discoveries
- [Important finding during implementation]

### Decisions Made
- [Decision and rationale]

### Technical Debt Identified
- [Item to address later with justification]

---

## Next Actions

**After Plan Approval:**

1. **For PM:** Review and approve plan
2. **For Developer:** Continue with TDD implementation phase
3. **Quality Gates:** Code Review Agent → Security Agent (parallel execution after TDD)
4. **Completion:** Verify all acceptance criteria met

**Next:** TDD implementation begins automatically after plan approval

---

_Plan overview created by Master Architect_
_Detailed steps in: step-01.md, step-02.md, ..., step-NN.md_
