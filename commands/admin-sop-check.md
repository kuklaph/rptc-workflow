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
  echo "❌ Error: CLAUDE_PLUGIN_ROOT not set. Plugin may not be installed correctly."
  exit 1
fi
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
```

## Step 2: Parse Arguments

```text
If user provides SOP name (e.g., "testing-guide"):
  - Check resolution for that specific SOP

If no argument provided:
  - Check resolution for all standard SOPs
```

## Step 3: Define SOP Resolution Function

For each SOP, check in priority order:

```bash
# Pseudo-code for resolution logic
function resolve_sop() {
  local sop_name=$1
  local locations=(
    ".rptc/sop/${sop_name}.md"
    "$HOME/.claude/global/sop/${sop_name}.md"
    "$PLUGIN_ROOT/sop/${sop_name}.md"
  )

  for location in "${locations[@]}"; do
    if [ -f "$location" ]; then
      echo "FOUND: $location"
      return 0
    fi
  done

  echo "NOT FOUND"
  return 1
}
```

## Step 4: Check Specific SOP (If Provided)

If user provided a SOP name:

```bash
echo "═══════════════════════════════════════════════════════"
echo "🔍 SOP Resolution Check: ${SOP_NAME}"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Checking in priority order:"
echo ""

# Check each location
echo "1. Project level (.rptc/sop/):"
if [ -f ".rptc/sop/${SOP_NAME}.md" ]; then
  echo "   ✓ FOUND: .rptc/sop/${SOP_NAME}.md"
  echo "   ⚡ This file will be used (highest priority)"

  # Show file info using Read tool (cross-platform compatible)
  echo ""
  echo "   Use Read tool to verify file:"
  echo "   Read(file_path: \".rptc/sop/${SOP_NAME}.md\")"
  echo "   📍 File exists and is readable"

  # Show first few lines as preview
  echo ""
  echo "   Preview (first 5 lines):"
  # Claude: Use Read tool with limit parameter
  # Read(file_path: ".rptc/sop/${SOP_NAME}.md", limit: 5)
  # Prefix each line with "   │ " in output

  exit 0  # Found, no need to check further
else
  echo "   ✗ Not found"
fi

echo ""
echo "2. User global level (~/.claude/global/sop/):"
if [ -f "$HOME/.claude/global/sop/${SOP_NAME}.md" ]; then
  echo "   ✓ FOUND: $HOME/.claude/global/sop/${SOP_NAME}.md"
  echo "   ⚡ This file will be used (user default)"

  # Show file info using Read tool (cross-platform compatible)
  echo ""
  echo "   Use Read tool to verify file:"
  echo "   Read(file_path: \"$HOME/.claude/global/sop/${SOP_NAME}.md\")"
  echo "   📍 File exists and is readable"

  exit 0  # Found
else
  echo "   ✗ Not found"
fi

echo ""
echo "3. Plugin default level ($PLUGIN_ROOT/sop/):"
if [ -f "$PLUGIN_ROOT/sop/${SOP_NAME}.md" ]; then
  echo "   ✓ FOUND: $PLUGIN_ROOT/sop/${SOP_NAME}.md"
  echo "   ⚡ This file will be used (plugin default)"

  # Show file info (simplified for cross-platform compatibility)
  echo "   📍 File exists and is readable"
  echo "   📦 Plugin version"
else
  echo "   ✗ ERROR: SOP not found in plugin!"
  echo "   ⚠️  This may indicate a plugin issue"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
```

## Step 5: Check All SOPs (If No Argument)

If user didn't provide a specific SOP:

```bash
echo "═══════════════════════════════════════════════════════"
echo "🔍 SOP Resolution Check: All SOPs"
echo "═══════════════════════════════════════════════════════"
echo ""

# List of standard SOPs
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

# Claude: Use Read tool for SOP resolution (file existence)
# For each SOP in SOPS array:
# 1. Try Read(".rptc/sop/${sop}.md") → if succeeds: echo "  ⚡ Project (.rptc/sop/)"
# 2. Else try Read("~/.claude/global/sop/${sop}.md") → if succeeds: echo "  ⚡ User (~/.claude/global/sop/)"
# 3. Else try Read("${PLUGIN_ROOT}/sop/${sop}.md") → if succeeds: echo "  ⚡ Plugin (default)"
# 4. Else: echo "  ✗ NOT FOUND (ERROR)"
#
# Output format for each SOP:
# • ${sop}.md
#   ⚡ [Resolution location]
#
# (Process all 9 SOPs: testing-guide, architecture-patterns, frontend-guidelines,
#  git-and-deployment, languages-and-style, security-and-performance,
#  flexible-testing-guide, post-tdd-refactoring, todowrite-guide)

echo "═══════════════════════════════════════════════════════"
```

## Step 6: Provide Override Instructions

```bash
echo ""
echo "💡 To override SOPs:"
echo ""
echo "For this project only:"
echo "  /rptc:admin-init --copy-sops"
echo "  # Copies SOPs to .rptc/sop/ for customization"
echo ""
echo "For all your projects:"
echo "  /rptc:admin-init --copy-sops --global"
echo "  # Copies SOPs to ~/.claude/global/sop/ as defaults"
echo ""
echo "Manual copy:"
echo "  mkdir -p .rptc/sop"
echo "  cp \"$PLUGIN_ROOT/sop/testing-guide.md\" .rptc/sop/"
echo "  # Edit .rptc/sop/testing-guide.md"
echo ""
```

## Step 7: Compare Versions (Advanced)

If multiple versions exist (project + user or user + plugin):

```bash
echo "⚙️  Multiple Versions Detected:"
echo ""
echo "Showing differences between versions:"
echo ""

# If both project and user/plugin exist, show diff summary
if [ -f ".rptc/sop/${SOP_NAME}.md" ] && [ -f "$HOME/.claude/global/sop/${SOP_NAME}.md" ]; then
  echo "Comparing:"
  echo "  Active:   .rptc/sop/${SOP_NAME}.md"
  echo "  Fallback: $HOME/.claude/global/sop/${SOP_NAME}.md"
  echo ""

  # Show brief diff stats
  LINES_DIFF=$(diff .rptc/sop/${SOP_NAME}.md "$HOME/.claude/global/sop/${SOP_NAME}.md" 2>/dev/null | grep -c "^[<>]")

  if [ "$LINES_DIFF" -gt 0 ]; then
    echo "  📊 ${LINES_DIFF} lines differ between versions"
    echo "  💡 Run 'diff .rptc/sop/${SOP_NAME}.md ~/.claude/global/sop/${SOP_NAME}.md' to see details"
  else
    echo "  ✓ Files are identical"
  fi
fi
```

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
