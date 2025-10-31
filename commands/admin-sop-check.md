---
description: Verify SOP resolution and show which file will be used
---

# RPTC Admin: SOP Resolution Check

You are executing the **SOP Resolution Verification** command.

## Purpose

Show exactly which SOP file will be loaded for a given SOP name, demonstrating the fallback chain in action.

## Arguments

Accept optional SOP name to check. If not provided, check all SOPs.

## Step 1: Resolve Plugin Root

Use the CLAUDE_PLUGIN_ROOT environment variable (provided by Claude Code plugin system):

```bash
# Step 1: Resolve plugin root
if [ -z "${CLAUDE_PLUGIN_ROOT}" ]; then
  # Output error directly
  exit 1
fi
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
```

If CLAUDE_PLUGIN_ROOT is not set:

❌ Error: CLAUDE_PLUGIN_ROOT not set. Plugin may not be installed correctly.

## Step 2: Parse Arguments

```bash
# Check if user provided SOP name
if [ -z "$1" ]; then
  # No argument provided - show interactive menu
  NO_ARG=true
else
  # Argument provided - use it
  NO_ARG=false
  SOP_NAME="$1"
fi
```

If NO_ARG is true, use AskUserQuestion to let user choose:

Use the AskUserQuestion tool:

```markdown
Question: "Which SOP resolution do you want to check?"
Header: "SOP Check"
Options:
- All: "Check all SOPs"
  Description: "Show resolution for all 9 SOPs"
- Specific: "Check specific SOP"
  Description: "Choose one SOP to check"
MultiSelect: false
```

Capture response to variable: `SOP_CHECK_MODE`

If SOP_CHECK_MODE is "Specific", show second menu:

Use the AskUserQuestion tool:

```markdown
Question: "Which SOP do you want to check?"
Header: "SOP"
Options:
- testing-guide: "testing-guide"
  Description: "TDD practices and testing strategy"
- architecture-patterns: "architecture-patterns"
  Description: "Architecture and design patterns"
- frontend-guidelines: "frontend-guidelines"
  Description: "Frontend design and components"
- git-and-deployment: "git-and-deployment"
  Description: "Git workflow and CI/CD"
- languages-and-style: "languages-and-style"
  Description: "Language conventions and style"
- security-and-performance: "security-and-performance"
  Description: "Security practices and optimization"
- flexible-testing-guide: "flexible-testing-guide"
  Description: "Alternative testing approaches"
- post-tdd-refactoring: "post-tdd-refactoring"
  Description: "Refactoring after TDD"
- todowrite-guide: "todowrite-guide"
  Description: "TodoWrite tool usage"
MultiSelect: false
```

Capture response to variable: `SOP_NAME`

If SOP_CHECK_MODE is "All", proceed to Step 5 (Check All SOPs).
If SOP_CHECK_MODE is "Specific", proceed to Step 4 (Check Specific SOP) with selected SOP_NAME.

## Step 3: Define SOP Resolution Function

For each SOP, check in priority order:

```bash
# Resolution logic using file existence checks
# Priority order:
# 1. .rptc/sop/${SOP_NAME}.md (project level)
# 2. ~/.claude/global/sop/${SOP_NAME}.md (user global)
# 3. ${PLUGIN_ROOT}/sop/${SOP_NAME}.md (plugin default)
#
# Use [ -f ] checks for each location
# Output results directly in markdown (no echo)
```

## Step 4: Check Specific SOP (If Provided)

If user provided a SOP name:

```bash
# Store SOP name from argument
SOP_NAME="$1"
```

Output header:

═══════════════════════════════════════════════════════
🔍 SOP Resolution Check: ${SOP_NAME}
═══════════════════════════════════════════════════════

Checking in priority order:

**1. Project level (.rptc/sop/):**

```bash
# Check project SOP
if [ -f ".rptc/sop/${SOP_NAME}.md" ]; then
  # Found at project level - highest priority
  PROJECT_SOP_FOUND=true
else
  PROJECT_SOP_FOUND=false
fi
```

If PROJECT_SOP_FOUND is true:

   ✓ FOUND: .rptc/sop/${SOP_NAME}.md
   ⚡ This file will be used (highest priority)

   Use Read tool to verify file:
   Read(file_path: ".rptc/sop/${SOP_NAME}.md")
   📍 File exists and is readable

   Preview (first 5 lines):

Use Read tool with limit:
Read(file_path: ".rptc/sop/${SOP_NAME}.md", limit: 5)

Display each line prefixed with "   │ "

Exit after displaying (found at highest priority).

If PROJECT_SOP_FOUND is false:

   ✗ Not found

**2. User global level (~/.claude/global/sop/):**

```bash
# Check user global SOP
if [ -f "$HOME/.claude/global/sop/${SOP_NAME}.md" ]; then
  USER_SOP_FOUND=true
else
  USER_SOP_FOUND=false
fi
```

If USER_SOP_FOUND is true:

   ✓ FOUND: $HOME/.claude/global/sop/${SOP_NAME}.md
   ⚡ This file will be used (user default)

   Use Read tool to verify file:
   Read(file_path: "$HOME/.claude/global/sop/${SOP_NAME}.md")
   📍 File exists and is readable

Exit after displaying (found at user level).

If USER_SOP_FOUND is false:

   ✗ Not found

**3. Plugin default level ($PLUGIN_ROOT/sop/):**

```bash
# Check plugin SOP
if [ -f "$PLUGIN_ROOT/sop/${SOP_NAME}.md" ]; then
  PLUGIN_SOP_FOUND=true
else
  PLUGIN_SOP_FOUND=false
fi
```

If PLUGIN_SOP_FOUND is true:

   ✓ FOUND: $PLUGIN_ROOT/sop/${SOP_NAME}.md
   ⚡ This file will be used (plugin default)

   📍 File exists and is readable
   📦 Plugin version

If PLUGIN_SOP_FOUND is false:

   ✗ ERROR: SOP not found in plugin!
   ⚠️  This may indicate a plugin issue

═══════════════════════════════════════════════════════

## Step 4a: Resolution Action Menu

After showing SOP resolution, ask what user wants to do:

Use the AskUserQuestion tool:

```markdown
Question: "What would you like to do with this SOP?"
Header: "Action"
Options:
- View: "View full content"
  Description: "Read complete SOP file"
- Override: "Create project override"
  Description: "Copy to .rptc/sop/ for customization"
- Compare: "Compare versions (if multiple exist)"
  Description: "See differences between locations"
- Done: "Done"
  Description: "Nothing more needed"
MultiSelect: false
```

Capture response to variable: `RESOLUTION_ACTION`

Handle response:

```bash
case "$RESOLUTION_ACTION" in
  View)
    # Use Read tool to display complete file
    # Read(file_path: [resolved SOP path])
    # Display all content
    ;;
  Override)
    # Copy to .rptc/sop/ if not already there
    # If already at project level, inform user
    if [ -f ".rptc/sop/${SOP_NAME}.md" ]; then
      echo "✓ Project override already exists: .rptc/sop/${SOP_NAME}.md"
    else
      mkdir -p .rptc/sop
      cp "${RESOLVED_PATH}" ".rptc/sop/${SOP_NAME}.md"
      echo "✓ Created project override: .rptc/sop/${SOP_NAME}.md"
      echo "  Edit this file to customize for your project"
    fi
    ;;
  Compare)
    # Only if multiple versions exist
    # Jump to Step 7 (Compare Versions)
    ;;
  Done)
    # Exit
    exit 0
    ;;
esac
```

## Step 5: Check All SOPs (If No Argument)

If user didn't provide a specific SOP:

```bash
# List of standard SOPs to check
SOPS=(
  "testing-guide"
  "architecture-patterns"
  "frontend-guidelines"
  "git-and-deployment"
  "languages-and-style"
  "security-and-performance"
  "flexible-testing-guide"
  "post-tdd-refactoring"
  "todowrite-guide"
)
```

Output header:

═══════════════════════════════════════════════════════
🔍 SOP Resolution Check: All SOPs
═══════════════════════════════════════════════════════

For each SOP in SOPS array:

```bash
# Check resolution for this SOP
if [ -f ".rptc/sop/${sop}.md" ]; then
  LOCATION="Project (.rptc/sop/)"
elif [ -f "$HOME/.claude/global/sop/${sop}.md" ]; then
  LOCATION="User (~/.claude/global/sop/)"
elif [ -f "${PLUGIN_ROOT}/sop/${sop}.md" ]; then
  LOCATION="Plugin (default)"
else
  LOCATION="NOT FOUND (ERROR)"
fi
```

For each SOP, output:

• ${sop}.md
  ⚡ ${LOCATION}

After processing all 9 SOPs:

═══════════════════════════════════════════════════════

## Step 6: Provide Override Instructions

Output override instructions:

💡 To override SOPs:

For this project only:
  /rptc:admin-init --copy-sops
  # Copies SOPs to .rptc/sop/ for customization

For all your projects:
  /rptc:admin-init --copy-sops --global
  # Copies SOPs to ~/.claude/global/sop/ as defaults

Manual copy:
  mkdir -p .rptc/sop
  cp "$PLUGIN_ROOT/sop/testing-guide.md" .rptc/sop/
  # Edit .rptc/sop/testing-guide.md

## Step 7: Compare Versions (Advanced)

If multiple versions exist (project + user or user + plugin):

```bash
# Check if both project and user global SOPs exist
if [ -f ".rptc/sop/${SOP_NAME}.md" ] && [ -f "$HOME/.claude/global/sop/${SOP_NAME}.md" ]; then
  BOTH_EXIST=true
else
  BOTH_EXIST=false
fi
```

If BOTH_EXIST is true:

⚙️  Multiple Versions Detected:

Showing differences between versions:

Comparing:
  Active:   .rptc/sop/${SOP_NAME}.md
  Fallback: $HOME/.claude/global/sop/${SOP_NAME}.md

Use Read tool to compare:

```
Read(file_path: ".rptc/sop/${SOP_NAME}.md") → PROJECT_CONTENT
Read(file_path: "$HOME/.claude/global/sop/${SOP_NAME}.md") → GLOBAL_CONTENT
```

Compare PROJECT_CONTENT and GLOBAL_CONTENT:
- Count differing lines between the two versions
- Store count → LINES_DIFF

If LINES_DIFF > 0:

  📊 ${LINES_DIFF} lines differ between versions

After showing differences, use AskUserQuestion to ask what to do:

Use the AskUserQuestion tool:

```markdown
Question: "Multiple SOP versions exist with differences. What to do?"
Header: "Versions"
Options:
- KeepProject: "Keep project version (current)"
  Description: "Use .rptc/sop/ (already active)"
- UseGlobal: "Switch to user global version"
  Description: "Delete project override, use ~/.claude/global/sop/"
- ViewDiff: "View detailed differences"
  Description: "Show side-by-side comparison"
- MergeManual: "I'll merge manually"
  Description: "Keep both, handle myself"
MultiSelect: false
```

Capture response to variable: `VERSION_ACTION`

Handle response:

```bash
case "$VERSION_ACTION" in
  KeepProject)
    echo "✓ Keeping project version: .rptc/sop/${SOP_NAME}.md"
    echo "  This file will continue to be used"
    ;;
  UseGlobal)
    # Delete project override to use global fallback
    rm ".rptc/sop/${SOP_NAME}.md"
    echo "✓ Deleted project override"
    echo "  Now using user global: ~/.claude/global/sop/${SOP_NAME}.md"
    ;;
  ViewDiff)
    echo "=== Project Version (.rptc/sop/${SOP_NAME}.md) ==="
    # Use Read tool to display project version
    Read(file_path: ".rptc/sop/${SOP_NAME}.md")
    echo ""
    echo "=== User Global Version (~/.claude/global/sop/${SOP_NAME}.md) ==="
    # Use Read tool to display global version
    Read(file_path: "$HOME/.claude/global/sop/${SOP_NAME}.md")
    echo ""
    # Re-show menu after displaying
    ;;
  MergeManual)
    echo "📝 Manual merge instructions:"
    echo "  Project:  .rptc/sop/${SOP_NAME}.md (currently active)"
    echo "  Global:   ~/.claude/global/sop/${SOP_NAME}.md"
    echo ""
    echo "  Edit .rptc/sop/${SOP_NAME}.md to merge changes"
    ;;
esac
```

If LINES_DIFF == 0:

  ✓ Files are identical

  💡 Consider deleting project override to reduce duplication:
     rm .rptc/sop/${SOP_NAME}.md

## Output Guidelines

- **Be explicit** about which file will actually be used
- **Show file paths** (full paths, not just filenames)
- **Provide context** (file size, last modified date)
- **Include preview** for found files (first few lines)
- **Give clear instructions** on how to override
- **Handle errors gracefully** if files don't exist where expected

## Use Cases

1. **Debugging**: "Why is my project using the wrong SOP?"
2. **Verification**: "Did my SOP override work?"
3. **Documentation**: "Where do I put my custom SOP?"
4. **Troubleshooting**: "Is the plugin installed correctly?"
