---
description: Review and cleanup completed plans from .rptc/plans/
---

# RPTC Helper: Cleanup Completed Plans

You are helping the user manage completed plans in their workspace.

## Purpose

Review completed plans in `.rptc/plans/` and help user decide what to do with them:

- Keep for reference
- Archive to `.rptc/archive/`
- Delete if no longer needed
- Promote to `docs/` if architecturally significant

## Step 1: Find Completed Plans

```bash
# Find plans marked as complete
grep -l "Status.*Complete" .rptc/plans/*.md 2>/dev/null
```

If no completed plans found:

```text
ℹ️  No completed plans found in .rptc/plans/

All plans are either in progress or the workspace is empty.
```

## Step 2: Present Completed Plans

For each completed plan found:

```text
📋 Completed Plans Found: [N] plans

1. [plan-name-1.md]
   - Completed: [date from file]
   - Size: [file size]
   - Last modified: [date]

2. [plan-name-2.md]
   - Completed: [date]
   - Size: [file size]
   - Last modified: [date]

...
```

## Step 3: Interactive Review

For each plan, ask user what to do:

```text
📄 Plan: [plan-name].md

[Show first 20 lines as preview]

Options:
1. [k] Keep in .rptc/plans/ (no action)
2. [a] Archive to .rptc/archive/
3. [p] Promote to docs/decisions/
4. [d] Delete (cannot be undone)
5. [s] Skip (review later)

What should we do with this plan? [k/a/p/d/s]:
```

## Step 4: Execute Actions

### Archive (a)

```bash
mkdir -p .rptc/archive
mv .rptc/plans/[name].md .rptc/archive/[name].md

echo "✅ Archived to .rptc/archive/[name].md"
```

### Promote (p)

```bash
mkdir -p docs/decisions
cp .rptc/plans/[name].md docs/decisions/[name].md

echo "✅ Promoted to docs/decisions/[name].md"
echo "   Original kept in .rptc/plans/"
echo ""
echo "   Tip: You may want to archive the original:"
echo "   mv .rptc/plans/[name].md .rptc/archive/"
```

### Delete (d)

```bash
# Ask for confirmation
echo "⚠️  Are you sure? This cannot be undone. [y/N]:"

# If confirmed:
rm .rptc/plans/[name].md
echo "✅ Deleted [name].md"
```

### Keep or Skip

```text
ℹ️  Kept in .rptc/plans/[name].md
```

## Step 5: Summary

After reviewing all plans:

```text
═══════════════════════════════════════════════════════
📋 Cleanup Summary
═══════════════════════════════════════════════════════

Actions taken:
- Kept: [X] plans
- Archived: [Y] plans
- Promoted: [Z] plans
- Deleted: [W] plans
- Skipped: [V] plans

Storage usage:
- .rptc/plans/: [size] ([N] files)
- .rptc/archive/: [size] ([M] files)
- docs/decisions/: [size] ([P] files)

Cleanup complete!
═══════════════════════════════════════════════════════
```

## Smart Suggestions

When reviewing a plan, provide smart suggestions based on content:

**Suggest Archive if**:

- Completed > 30 days ago
- Simple feature (< 100 lines of changes)
- No architectural significance

**Suggest Promote if**:

- Contains "architecture" or "design decision"
- References security or performance changes
- Documents breaking changes
- Contains important "why" rationale

**Suggest Keep if**:

- Completed recently (< 7 days)
- May need reference soon
- Contains useful implementation notes

## Example Interaction

```text
User: /rptc:helper:cleanup

Agent:
📋 Completed Plans Found: 3 plans

1. user-avatar-upload.md
   - Completed: 2 weeks ago
   - Simple feature implementation
   - Suggestion: Archive ✅

2. payment-system-integration.md
   - Completed: 1 month ago
   - Contains architecture decisions
   - Suggestion: Promote to docs/ ✅

3. fix-login-bug.md
   - Completed: 3 days ago
   - Recent bug fix
   - Suggestion: Keep for now

───────────────────────────────────────────────────────

Reviewing plan 1/3: user-avatar-upload.md

[Shows preview...]

Options:
1. [k] Keep
2. [a] Archive (recommended)
3. [p] Promote to docs/
4. [d] Delete
5. [s] Skip

What should we do? [k/a/p/d/s]: a

✅ Archived to .rptc/archive/user-avatar-upload.md

───────────────────────────────────────────────────────

[Continue with remaining plans...]

═══════════════════════════════════════════════════════
📋 Cleanup Summary
═══════════════════════════════════════════════════════

Actions taken:
- Archived: 1 plan (user-avatar-upload.md)
- Promoted: 1 plan (payment-system-integration.md)
- Kept: 1 plan (fix-login-bug.md)

Storage freed: 15KB

Cleanup complete!
═══════════════════════════════════════════════════════
```

## Notes

- **Batch mode**: If user says "archive all" or "promote all", process all plans with that action (but confirm first)
- **Undo**: Remind user that git tracks changes, so accidental deletions can be recovered if committed
- **Frequency**: Suggest running this command monthly or when `.rptc/plans/` has > 10 completed plans
