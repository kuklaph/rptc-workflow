---
description: Review and cleanup completed plans from $ARTIFACT_LOC/plans/
---

# RPTC Helper: Cleanup Completed Plans

You are helping the user manage completed plans in their workspace.

## Step 0: Load Configuration

**Load configuration**:

1. **Check if settings file exists**:
   - Use Read tool to read `.claude/settings.json`
   - If file doesn't exist or can't be read, use defaults (skip to step 3)

2. **Parse configuration** (extract these fields):
   - `rptc.artifactLocation` → ARTIFACT_LOC (default: ".rptc")
   - `rptc.docsLocation` → DOCS_LOC (default: "docs")

3. **Display loaded configuration**:
   ```text
   Configuration loaded:
     Artifact location: [ARTIFACT_LOC value]
     Docs location: [DOCS_LOC value]
   ```

**Use these values throughout the command execution.**

**Note**: References to these variables appear throughout this command - use the actual loaded values from this step.

## Purpose

Review completed plans in `$ARTIFACT_LOC/plans/` and help user decide what to do with them:

- Keep for reference
- Archive to `$ARTIFACT_LOC/archive/`
- Delete if no longer needed
- Promote to `docs/` if architecturally significant

## Step 1: Find Completed Plans

```bash
# Find plans marked as complete
grep -l "Status.*Complete" $ARTIFACT_LOC/plans/*.md 2>/dev/null
```

If no completed plans found:

```text
ℹ️  No completed plans found in $ARTIFACT_LOC/plans/

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
1. [k] Keep in $ARTIFACT_LOC/plans/ (no action)
2. [a] Archive to $ARTIFACT_LOC/archive/
3. [p] Promote to $DOCS_LOC/decisions/
4. [d] Delete (cannot be undone)
5. [s] Skip (review later)

What should we do with this plan? [k/a/p/d/s]:
```

## Step 4: Execute Actions

### Archive (a)

```bash
mkdir -p "$ARTIFACT_LOC/archive"
mv $ARTIFACT_LOC/plans/[name].md $ARTIFACT_LOC/archive/[name].md

echo "✅ Archived to $ARTIFACT_LOC/archive/[name].md"
```

### Promote (p)

```bash
mkdir -p "$DOCS_LOC/decisions"
cp $ARTIFACT_LOC/plans/[name].md $DOCS_LOC/decisions/[name].md

echo "✅ Promoted to $DOCS_LOC/decisions/[name].md"
echo "   Original kept in $ARTIFACT_LOC/plans/"
echo ""
echo "   Tip: You may want to archive the original:"
echo "   mv $ARTIFACT_LOC/plans/[name].md $ARTIFACT_LOC/archive/"
```

### Delete (d)

```bash
# Ask for confirmation
echo "⚠️  Are you sure? This cannot be undone. [y/N]:"

# If confirmed:
rm $ARTIFACT_LOC/plans/[name].md
echo "✅ Deleted [name].md"
```

### Keep or Skip

```text
ℹ️  Kept in $ARTIFACT_LOC/plans/[name].md
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
- $ARTIFACT_LOC/plans/: [size] ([N] files)
- $ARTIFACT_LOC/archive/: [size] ([M] files)
- $DOCS_LOC/decisions/: [size] ([P] files)

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
User: /rptc:helper-cleanup

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

✅ Archived to $ARTIFACT_LOC/archive/user-avatar-upload.md

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
- **Frequency**: Suggest running this command monthly or when `$ARTIFACT_LOC/plans/` has > 10 completed plans
