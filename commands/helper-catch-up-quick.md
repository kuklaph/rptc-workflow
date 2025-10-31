# Quick Context Catch-Up

Get rapid context overview for immediate task execution.

Arguments: None

## Process

Gather essential context in under 2 minutes:

### 1. Project Basics

- Read `CLAUDE.md` (if exists)
- Read `package.json` or equivalent (tech stack)
- Read `README.md` (project overview)

### 2. Current State

```bash
git status           # Current changes
git branch          # Current branch
git log -5 --oneline # Recent commits
```

### 3. Recent Activity

- Last 5 commit messages (what's been done)
- Current branch name (what's being worked on)
- Staged/unstaged changes (current progress)

### 4. Depth Override (Optional)

After quick catch-up completes, offer depth adjustment:

```markdown
AskUserQuestion(
  question: "Quick catch-up complete. Adjust depth?",
  header: "Depth",
  options: [
    {
      label: "Show quick summary (current)",
      description: "Display quick summary report and complete",
      value: "quick"
    },
    {
      label: "Upgrade to medium catch-up (5-10 min more)",
      description: "Continue with architecture analysis and detailed history",
      value: "medium"
    },
    {
      label: "Upgrade to deep catch-up (15-30 min more)",
      description: "Run full comprehensive analysis with complexity assessment",
      value: "deep"
    }
  ],
  multiSelect: false
)
```

Capture response in `DEPTH_CHOICE` variable.

**Handle Selection:**

```bash
if [ "$DEPTH_CHOICE" == "quick" ]; then
  # Continue to Step 5 (Summary Report) - existing behavior
  echo "Displaying quick summary..."

elif [ "$DEPTH_CHOICE" == "medium" ]; then
  echo ""
  echo "⏫ Upgrading to medium catch-up..."
  echo ""

  # Execute medium catch-up Steps 4-6
  # Step 4: Dependencies & Config (from helper-catch-up-med.md)
  # Step 5: Research & Plans
  # Step 6: Medium Summary Report

elif [ "$DEPTH_CHOICE" == "deep" ]; then
  echo ""
  echo "⏫ Upgrading to deep catch-up..."
  echo ""

  # Execute ALL additional steps (medium + deep)
  # Full comprehensive analysis from helper-catch-up-deep.md
fi
```

### 5. Summary Report

```text
📋 Quick Context Catch-Up

**Project**: [name from package.json/README]
**Tech Stack**: [languages/frameworks]
**Current Branch**: [branch-name]

**Recent Work** (last 5 commits):
1. [commit 1]
2. [commit 2]
3. [commit 3]
4. [commit 4]
5. [commit 5]

**Current Status**:
- Staged files: [N]
- Modified files: [N]
- Branch: [branch-name]

**Ready to assist with**: [based on current context]
```

**Use when**: Quick question, small fix, or immediate task.
