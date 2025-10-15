# Update Implementation Plan

Modify an existing implementation plan with PM collaboration.

Arguments:

- Plan reference: `/rptc:helper-update-plan "@plan-name.md"`
- Plan + changes: `/rptc:helper-update-plan "@plan-name.md" "add OAuth support"`

## Process

### 1. Load Existing Plan

Read `.rptc/plans/[plan-name].md`:

- Current status
- Existing steps
- Test strategy
- Acceptance criteria

**Present Current Plan**:

```text
📋 Current Plan: [Feature Name]

Status: [current status]

Existing Steps: [N]
1. [Step 1]
2. [Step 2]
...

Test Strategy: [summary]
Acceptance Criteria: [summary]

What would you like to update?
```

### 2. Understand Changes Needed

**If user provided change description**:

- Parse the requested changes
- Ask clarifying questions

**If no change description**:

- Ask: "What needs to be updated in this plan?"
- Ask: "Why is this change needed?"
- Ask: "Does this affect the test strategy?"

**Clarify scope**:

- Ask: "Should this be new steps or modify existing?"
- Ask: "Any new tests needed?"
- Ask: "Impact on acceptance criteria?"

### 3. Draft Plan Updates

Create modification proposal:

```text
📝 Proposed Plan Updates:

**Changes**:
1. [Change 1]: [Description]
   - Reason: [why]
   - Impact: [what's affected]

2. [Change 2]: [Description]
   - Reason: [why]
   - Impact: [what's affected]

**Updated Steps**:
[Show modified/new steps]

**Updated Test Strategy**:
[If tests affected, show changes]

**Updated Acceptance Criteria**:
[If criteria affected, show changes]

Do these updates look correct?
Type "yes" to apply, or provide modifications.
```

### 4. PM Review & Refinement

**Interactive refinement**:

- If PM says "modify [something]": Make changes
- If PM says "add [something]": Add to plan
- If PM says "remove [something]": Remove from plan
- If PM says "approved": Proceed to save

**Keep iterating until PM approves.**

### 5. PM Sign-Off (REQUIRED)

**Get explicit approval**:

```text
📋 Plan Updates Finalized!

**Summary of Changes**:
- [X] steps modified
- [Y] new steps added
- [Z] tests updated
- Test strategy: [changed/unchanged]
- Acceptance criteria: [changed/unchanged]

**Do you approve these updates?**
Type "yes" or "approved" to save updated plan.
Type "modify" for additional changes.

Waiting for your sign-off...
```

**DO NOT save** until PM approves.

### 6. Save Updated Plan (Only After Approval)

Update `.rptc/plans/[plan-name].md`:

1. Preserve original sections (don't lose context)
2. Update modified sections
3. Add new sections if needed
4. Update status if needed
5. Add update log at bottom:

```markdown
## Update Log

### [Date] - [Update Summary]

**Changed by**: Project Manager
**Reason**: [why update was needed]
**Changes**:

- [Change 1]
- [Change 2]

Status: ✅ Updated and Approved
```

**Confirm save**:

```text
✅ Plan Updated: `.rptc/plans/[plan-name].md`

Changes applied:
- [Change 1]
- [Change 2]

Updated sections:
- [Section 1]
- [Section 2]

Next actions:
- Continue with `/rptc:tdd "@[plan-name].md"` (if implementing)
- Or make more updates with `/rptc:helper-update-plan "@[plan-name].md"`
```

## Use Cases

### Add New Step

```text
/rptc:helper-update-plan "@user-auth.md" "add password strength validation"
```

### Modify Existing Step

```text
/rptc:helper-update-plan "@user-auth.md" "change JWT expiry from 1h to 24h"
```

### Update Test Strategy

```text
/rptc:helper-update-plan "@user-auth.md" "add load testing for 1000 concurrent users"
```

### Change Acceptance Criteria

```text
/rptc:helper-update-plan "@user-auth.md" "coverage must be 90% not 80%"
```

## Success Criteria

- [ ] Existing plan loaded and reviewed
- [ ] Changes clearly defined
- [ ] PM reviewed proposed updates
- [ ] Updates refined based on PM feedback
- [ ] PM explicitly approved changes
- [ ] Plan document updated (original context preserved)
- [ ] Update log added
- [ ] Next steps confirmed

---

_Remember: Plans are living documents. Update as you learn._
