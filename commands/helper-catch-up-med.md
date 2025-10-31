# Medium Context Catch-Up

Get comprehensive project understanding for feature work.

Arguments: None

## Process

Gather thorough context in 5-10 minutes:

### 1. Project Foundation (Quick)

- Read `CLAUDE.md`
- Read `package.json` or equivalent
- Read `README.md`
- Check `.context/` files if exist

### 2. Architecture Understanding

- Scan project structure:

  ```bash
  find . -type f -name "*.ts" -o -name "*.js" -o -name "*.py" | head -20
  ```

- Identify main directories (src, lib, app, etc.)
- Read main entry point (index.ts, main.py, etc.)

### 3. Recent Context (Detailed)

```bash
git log -15 --oneline --graph  # Recent history
git diff main..HEAD --stat      # Changes from main
```

### 4. Research & Plans

- List existing research docs: `ls .rptc/research/`
- List existing plans: `ls .rptc/plans/`
- Read most recent research/plan if exists

### 5. Dependencies & Config

- Check installed dependencies
- Review main config files
- Note test framework setup

### 6. Summary Check

Before displaying summary, prepare comprehensive context

### 7. Depth Override (Optional)

After medium catch-up completes, offer depth adjustment:

```markdown
AskUserQuestion(
  question: "Medium catch-up complete. Adjust depth?",
  header: "Depth",
  options: [
    {
      label: "Show medium summary (current)",
      description: "Display comprehensive medium summary and complete",
      value: "medium"
    },
    {
      label: "Quick summary instead (condensed)",
      description: "Show simplified summary of key points only",
      value: "quick"
    },
    {
      label: "Upgrade to deep catch-up (15-30 min more)",
      description: "Run full deep analysis with complexity assessment",
      value: "deep"
    }
  ],
  multiSelect: false
)
```

Capture response in `DEPTH_CHOICE` variable.

**Handle Selection:**

```bash
if [ "$DEPTH_CHOICE" == "medium" ]; then
  # Continue to Step 8 (Summary Report) - existing behavior
  echo "Displaying medium summary..."

elif [ "$DEPTH_CHOICE" == "quick" ]; then
  echo ""
  echo "⏬ Showing condensed quick summary..."
  echo ""

  # Display simplified summary (extract key points from medium analysis)
  echo "📋 Quick Context Summary"
  echo ""
  echo "**Project**: [name from medium analysis]"
  echo "**Tech Stack**: [from medium analysis]"
  echo "**Current Branch**: [from git status]"
  echo ""
  echo "**Recent Work** (last 15 commits):"
  echo "[Condensed list from medium analysis]"
  echo ""
  echo "**Ready for**: [Quick recommendation based on medium context]"

elif [ "$DEPTH_CHOICE" == "deep" ]; then
  echo ""
  echo "⏫ Upgrading to deep catch-up..."
  echo ""

  # Execute deep analysis Steps 7-11 (from helper-catch-up-deep.md)
fi
```

### 8. Summary Report

```text
📋 Medium Context Catch-Up

**Project**: [name]
**Tech Stack**: [detailed list]
**Architecture**: [structure overview]

**Project Structure**:
- `src/` - [purpose]
- `tests/` - [test setup]
- `docs/` - [documentation]

**Recent History** (last 15 commits):
[List with context]

**Active Work**:
- Current branch: [name]
- Changes from main: [summary]
- Files modified: [list]

**Existing Research**:
- [research doc 1]
- [research doc 2]

**Existing Plans**:
- [plan 1]: [status]
- [plan 2]: [status]

**Dependencies**:
- [key dependency 1]: [version]
- [key dependency 2]: [version]

**Ready for**: [specific recommendations based on context]
```

**Use when**: Starting feature work, understanding existing code, or planning changes.
