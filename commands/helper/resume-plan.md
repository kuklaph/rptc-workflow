# Resume Work on Existing Plan

Resume implementation of a plan from a previous session with full context restoration.

Arguments:

- Plan reference: `/rptc:helper:resume-plan "@plan-name.md"`

## Purpose

When starting a new session and continuing work on an existing plan, this command:

1. Loads the plan and analyzes progress
2. Determines how much work remains
3. Automatically runs appropriate catch-up command
4. Provides focused context for continuing work

## Process

### 1. Load and Analyze Plan

Read `.rptc/plans/[plan-name].md`:

- Parse all implementation steps
- Count total steps vs completed steps
- Check plan status
- Review test strategy
- Note any blockers or issues

**Present Plan Status**:

```text
📋 Plan Status: [Plan Name]

Progress:
- Total Steps: [N]
- Completed: [X] ✅
- Remaining: [Y] ⏳
- Status: [In Progress/Blocked/etc.]

Last Modified: [timestamp if available]

Remaining Work:
1. [ ] Step [N]: [Description]
2. [ ] Step [N+1]: [Description]
...

Current Status: [Brief summary]
```

### 2. Determine Context Depth Needed

Based on remaining work, automatically decide:

**If 1-2 simple steps remain**:

```text
🔄 Running quick context catch-up...
[Automatically invoke /rptc:helper:catch-up-quick]
```

**If 3-5 steps or moderate complexity**:

```text
🔄 Running medium context catch-up...
[Automatically invoke /rptc:helper:catch-up-med]
```

**If 6+ steps or high complexity**:

```text
🔄 Running deep context catch-up...
[Automatically invoke /rptc:helper:catch-up-deep]
```

### 3. Load Related Research (If Exists)

Check if plan references research document:

- If found in plan frontmatter, read `.rptc/research/[topic].md`
- Summarize key findings relevant to remaining work

**Present Research Summary** (if applicable):

```text
📚 Related Research: [topic]

Key Points for Remaining Work:
- [Relevant finding 1]
- [Relevant finding 2]
- [Relevant consideration 3]
```

### 4. Review Recent Changes (Git)

Check git history for activity on files mentioned in plan:

```bash
git log --oneline --all --grep="[plan-topic]" | head -10
git diff --name-status main..HEAD -- [files-from-plan]
```

**Present Recent Activity**:

```text
📝 Recent Changes:
- [X] commits related to this work
- [Y] files modified
- Last commit: [commit message]
```

### 5. Check Test Status

If plan includes test files:

- Check if test files exist
- Count tests (if possible)
- Note testing progress

**Present Test Status**:

```text
🧪 Test Status:
- Test files: [exist/missing]
- Tests written: [N] (estimated)
- Coverage: [if available]
```

### 6. Provide Resumption Guidance

Based on all context gathered:

```text
═══════════════════════════════════════════════════════════════
  READY TO RESUME: [Plan Name]
═══════════════════════════════════════════════════════════════

Context Level: [Quick/Medium/Deep] ✅
Plan Progress: [X/N] steps complete
Related Research: [loaded/not found]
Git Activity: [active/stale]
Tests: [on track/needs attention]

NEXT STEP:
Step [N]: [Next step description]

Tests to Write First:
- [ ] [Test 1]
- [ ] [Test 2]

Files to Modify:
- [file1.ts]
- [file2.ts]

═══════════════════════════════════════════════════════════════
READY TO CONTINUE
═══════════════════════════════════════════════════════════════

To continue implementation:
  /rptc:tdd "@[plan-name].md"

To modify plan first:
  /rptc:helper:update-plan "@[plan-name].md" "changes"

To start fresh research:
  /rptc:research "[topic]"
```

## Intelligence Features

### Smart Context Selection

The command intelligently determines context depth:

```text
Remaining Work Assessment:
- Simple (1-2 steps, < 200 lines): quick catch-up
- Medium (3-5 steps, 200-500 lines): medium catch-up
- Complex (6+ steps, > 500 lines): deep catch-up
- Blocked/Stale: deep catch-up (need full understanding)
```

### Staleness Detection

If plan hasn't been touched in a while:

- Check last git commit related to plan
- If > 7 days: Recommend deep catch-up
- If > 30 days: Warn about potential drift

```text
⚠️  Plan Staleness Warning:
Last activity: [X] days ago

The codebase may have changed significantly.
Recommending deep catch-up for safety.
```

### Blocker Detection

If plan mentions blockers or issues:

```text
🚨 Blockers Detected:
- [Blocker 1 from plan notes]
- [Blocker 2 from plan notes]

Address these before continuing implementation.
```

## Use Cases

### Resume After Break

```text
# You worked on auth feature yesterday, continuing today
/rptc:helper:resume-plan "@user-authentication.md"

# Output:
# - Loads plan (5 steps, 3 complete)
# - Runs medium catch-up automatically
# - Shows next step is "JWT token validation"
# - Ready to continue with /rptc:tdd
```

### Resume After Long Gap

```text
# Haven't touched plan in 2 weeks
/rptc:helper:resume-plan "@payment-processing.md"

# Output:
# - Loads plan (8 steps, 2 complete)
# - Detects staleness (14 days)
# - Runs deep catch-up automatically
# - Shows what changed in codebase
# - Recommends reviewing plan for drift
```

### Resume After Context Switch

```text
# Switched to urgent bug, now back to feature
/rptc:helper:resume-plan "@analytics-dashboard.md"

# Output:
# - Loads plan (7 steps, 6 complete)
# - Runs quick catch-up (almost done)
# - Shows final step: "Add export functionality"
# - Ready to finish quickly
```

## Success Criteria

- [ ] Plan loaded and progress analyzed
- [ ] Appropriate catch-up command ran automatically
- [ ] Related research loaded (if exists)
- [ ] Recent git activity reviewed
- [ ] Test status checked
- [ ] Clear next step identified
- [ ] Ready to continue with /rptc:tdd

---

_Remember: Context is key. This command ensures you're never lost when resuming work._
