---
description: Interactive cleanup of completed plans with batch and smart suggestion modes
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
- Archive to `$ARTIFACT_LOC/complete/`
- Delete if no longer needed
- Promote to `docs/` if architecturally significant

## Step 1: Find Completed Plans

```markdown
# Claude: Use Grep tool to find completed plans
Grep(
  pattern: "Status.*Complete",
  path: "${ARTIFACT_LOC}/plans",
  glob: "*.md",
  output_mode: "files_with_matches"
)
```

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

### Batch Strategy Selection (Opportunity 49)

First, ask user how they want to review completed plans:

Use the AskUserQuestion tool:

```markdown
AskUserQuestion(
  questions: [{
    question: "How would you like to review [N] completed plans?",
    header: "Cleanup",
    multiSelect: false,
    options: [
      {
        label: "Individual",
        description: "Review each plan individually - Decide for each plan"
      },
      {
        label: "ArchiveAll",
        description: "Archive all completed plans - Move all to complete/"
      },
      {
        label: "Smart",
        description: "Use smart suggestions (auto-categorize) - AI categorization"
      },
      {
        label: "Preview",
        description: "Show preview list first - See all plans before deciding"
      }
    ]
  }]
)
```

**Response handling**:

Capture response to variable `BATCH_DECISION`.

**If `ArchiveAll` selected**:

```bash
# Move all plans to complete/ directory
mkdir -p "$ARTIFACT_LOC/complete"

for plan in [COMPLETED_PLANS]; do
  mv "$ARTIFACT_LOC/plans/$plan" "$ARTIFACT_LOC/complete/"
done

echo "✅ Archived [N] plans to $ARTIFACT_LOC/complete/"
```

**STOP EXECUTION** - Skip to Step 5 (Summary)

**If `Smart` selected**:

Analyze each plan and auto-categorize:

- Plans completed > 30 days ago → Archive automatically
- Plans with "architecture"/"design decision" → Prompt to promote
- Plans completed < 7 days ago → Keep automatically
- Edge cases → Prompt user for decision

Then skip to Step 5 (Summary).

**If `Preview` selected**:

Show detailed list of all plans with metadata, then loop back to this menu.

**If `Individual` selected**:

Continue to per-plan review below.

---

### Per-Plan Review (Individual Mode)

For each plan, show preview and ask user what to do:

```text
📄 Plan: [plan-name].md

[Show first 20 lines as preview]
```

Use the AskUserQuestion tool:

```markdown
AskUserQuestion(
  questions: [{
    question: "What should we do with [plan-name].md?",
    header: "Action",
    multiSelect: false,
    options: [
      {
        label: "Keep",
        description: "[k] Keep in plans/ (no action) - Leave in plans directory"
      },
      {
        label: "Archive",
        description: "[a] Archive to complete/ - Move to completed plans"
      },
      {
        label: "Promote",
        description: "[p] Promote to docs/decisions/ - Make permanent documentation"
      },
      {
        label: "Delete",
        description: "[d] Delete permanently - Remove file (cannot undo)"
      },
      {
        label: "Skip",
        description: "[s] Skip (review later) - Decide later"
      }
    ]
  }]
)
```

**Response handling**:

Capture response to variable `PLAN_ACTION`.

**If `Keep` selected**: Continue to next plan (no action)

**If `Archive` selected**: Execute Archive action (Step 4)

**If `Promote` selected**: Execute Promote action (Step 4)

**If `Delete` selected**: Continue to Delete Confirmation (below)

**If `Skip` selected**: Continue to next plan (no action)

## Step 4: Execute Actions

### Archive (a)

```bash
mkdir -p "$ARTIFACT_LOC/complete"
mv $ARTIFACT_LOC/plans/[name].md $ARTIFACT_LOC/complete/[name].md

echo "✅ Archived to $ARTIFACT_LOC/complete/[name].md"
```

### Promote (p)

```bash
mkdir -p "$DOCS_LOC/decisions"
cp $ARTIFACT_LOC/plans/[name].md $DOCS_LOC/decisions/[name].md

echo "✅ Promoted to $DOCS_LOC/decisions/[name].md"
echo "   Original kept in $ARTIFACT_LOC/plans/"
echo ""
echo "   Tip: You may want to archive the original:"
echo "   mv $ARTIFACT_LOC/plans/[name].md $ARTIFACT_LOC/complete/"
```

### Delete (d)

**Delete Confirmation (Opportunity 51 - CRITICAL SAFETY GATE)**:

Use the AskUserQuestion tool:

```markdown
AskUserQuestion(
  questions: [{
    question: "⚠️ Delete [name].md permanently? This cannot be undone.",
    header: "Delete?",
    multiSelect: false,
    options: [
      {
        label: "Confirm",
        description: "Yes, delete permanently - Remove file"
      },
      {
        label: "Cancel",
        description: "No, keep the file - Don't delete"
      }
    ]
  }]
)
```

**Response handling**:

Capture response to variable `DELETE_CONFIRM`.

**If `Confirm` selected**:

```bash
rm "$ARTIFACT_LOC/plans/[name].md"
echo "✅ Deleted [name].md permanently"

# Log deletion for audit trail
echo "$(date): Deleted [name].md" >> "$ARTIFACT_LOC/cleanup.log"
```

**If `Cancel` selected**:

```text
ℹ️  Deletion cancelled - keeping [name].md
```

Continue to next plan.

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
- $ARTIFACT_LOC/complete/: [size] ([M] files)
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

## Notes

- **Batch mode**: Implemented via Step 3 interactive menu (archive all, keep all, smart suggestions, or individual review)
- **Smart suggestions**: AI analyzes content and recommends actions based on plan age, complexity, and significance
- **Undo**: Remind user that git tracks changes, so accidental deletions can be recovered if committed
- **Frequency**: Suggest running this command monthly or when `$ARTIFACT_LOC/plans/` has > 10 completed plans
