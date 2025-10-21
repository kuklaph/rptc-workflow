# Implementation Plan: [Work Item Name]

**Date**: [YYYY-MM-DD]
**Author**: [Your Name]
**Status**: Not Started | In Progress | Complete | Blocked

---

## Overview

Brief description of what you're implementing and why.

**Related Research**: `.rptc/research/[topic].md` (if applicable)

---

## Goals

- [ ] Goal 1
- [ ] Goal 2
- [ ] Goal 3

---

## Implementation Steps

### Step 1: [Step Title]

**What**: [Description of what this step accomplishes]

**Tests to Write**:

- [ ] Happy path: [description]
- [ ] Edge case: [description]
- [ ] Error handling: [description]

**Files to Create/Modify**:

- `path/to/file1.ts` - [Changes needed]
- `path/to/file2.ts` - [Changes needed]

**Implementation Notes**:

- [Note 1]
- [Note 2]

---

### Step 2: [Step Title]

**What**: [Description]

**Tests to Write**:

- [ ] Test 1
- [ ] Test 2

**Files to Create/Modify**:

- `path/to/file.ts` - [Changes]

**Implementation Notes**:

- [Note]

---

## Test Strategy

### Unit Tests

- [ ] Test 1: [description]
- [ ] Test 2: [description]

### Integration Tests

- [ ] Test 1: [description]
- [ ] Test 2: [description]

### E2E Tests (if applicable)

- [ ] Test 1: [description]

### Coverage Target

- **Overall**: 80%+
- **Critical paths**: 100%

---

## Dependencies

### External Dependencies

- [Package name] - [Why needed]

### Internal Dependencies

- [Module/service] - [Why needed]

---

## Risks & Considerations

### Technical Risks

1. **[Risk 1]**: [Description]
   - Mitigation: [How to address]

### Security Considerations

- [Security concern 1]
- [Security concern 2]

### Performance Considerations

- [Performance concern 1]

---

## Acceptance Criteria

- [ ] All tests pass
- [ ] Coverage meets target (80%+)
- [ ] No debug code or console.logs
- [ ] Code follows project style guide
- [ ] Documentation updated if needed
- [ ] Security review passed (if applicable)
- [ ] Performance acceptable

---

## Rollback Plan

If something goes wrong:

1. [Step 1]
2. [Step 2]

---

## Update Log

### [Date] - [Update Summary]

**Changed by**: [Name]
**Reason**: [Why update was needed]
**Changes**:

- [Change 1]
- [Change 2]

---

## Next Steps

After implementation:

- [ ] Run `/rptc:tdd "@this-plan.md"`
- [ ] Complete quality gates (Efficiency & Security)
- [ ] Run `/rptc:commit pr`
