---
description: Verify SOP resolution and show which file will be used
---

# RPTC Admin: SOP Resolution Check

You are executing the **SOP Resolution Verification** command.

## Purpose

Show exactly which SOP file will be loaded for a given SOP name, demonstrating the fallback chain in action.

## Arguments

Accept optional SOP name to check. If not provided, check all SOPs.

## Step 1: Parse Arguments

```text
If user provides SOP name (e.g., "testing-guide"):
  - Check resolution for that specific SOP

If no argument provided:
  - Check resolution for all standard SOPs
```

## Step 2: Define SOP Resolution Function

For each SOP, check in priority order:

```bash
# Pseudo-code for resolution logic
function resolve_sop() {
  local sop_name=$1
  local locations=(
    ".claude/sop/${sop_name}.md"
    "~/.claude/global/sop/${sop_name}.md"
    "${CLAUDE_PLUGIN_ROOT}/sop/${sop_name}.md"
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

## Step 3: Check Specific SOP (If Provided)

If user provided a SOP name:

```bash
echo "═══════════════════════════════════════════════════════"
echo "🔍 SOP Resolution Check: ${SOP_NAME}"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Checking in priority order:"
echo ""

# Check each location
echo "1. Project level (.claude/sop/):"
if [ -f ".claude/sop/${SOP_NAME}.md" ]; then
  echo "   ✓ FOUND: .claude/sop/${SOP_NAME}.md"
  echo "   ⚡ This file will be used (highest priority)"

  # Show file info
  FILE_SIZE=$(wc -c < ".claude/sop/${SOP_NAME}.md")
  LAST_MODIFIED=$(stat -c %y ".claude/sop/${SOP_NAME}.md" 2>/dev/null || stat -f %Sm ".claude/sop/${SOP_NAME}.md")
  echo "   📊 Size: ${FILE_SIZE} bytes"
  echo "   📅 Last modified: ${LAST_MODIFIED}"

  # Show first few lines as preview
  echo ""
  echo "   Preview (first 5 lines):"
  head -5 ".claude/sop/${SOP_NAME}.md" | sed 's/^/   │ /'

  exit 0  # Found, no need to check further
else
  echo "   ✗ Not found"
fi

echo ""
echo "2. User global level (~/.claude/global/sop/):"
if [ -f "~/.claude/global/sop/${SOP_NAME}.md" ]; then
  echo "   ✓ FOUND: ~/.claude/global/sop/${SOP_NAME}.md"
  echo "   ⚡ This file will be used (user default)"

  # Show file info
  FILE_SIZE=$(wc -c < "~/.claude/global/sop/${SOP_NAME}.md")
  LAST_MODIFIED=$(stat -c %y "~/.claude/global/sop/${SOP_NAME}.md" 2>/dev/null || stat -f %Sm "~/.claude/global/sop/${SOP_NAME}.md")
  echo "   📊 Size: ${FILE_SIZE} bytes"
  echo "   📅 Last modified: ${LAST_MODIFIED}"

  exit 0  # Found
else
  echo "   ✗ Not found"
fi

echo ""
echo "3. Plugin default level (${CLAUDE_PLUGIN_ROOT}/sop/):"
if [ -f "${CLAUDE_PLUGIN_ROOT}/sop/${SOP_NAME}.md" ]; then
  echo "   ✓ FOUND: ${CLAUDE_PLUGIN_ROOT}/sop/${SOP_NAME}.md"
  echo "   ⚡ This file will be used (plugin default)"

  # Show file info
  FILE_SIZE=$(wc -c < "${CLAUDE_PLUGIN_ROOT}/sop/${SOP_NAME}.md")
  echo "   📊 Size: ${FILE_SIZE} bytes"
  echo "   📅 Plugin version"
else
  echo "   ✗ ERROR: SOP not found in plugin!"
  echo "   ⚠️  This may indicate a plugin issue"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
```

## Step 4: Check All SOPs (If No Argument)

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
)

for sop in "${SOPS[@]}"; do
  echo "• ${sop}.md"

  # Check resolution
  if [ -f ".claude/sop/${sop}.md" ]; then
    echo "  ⚡ Project (.claude/sop/)"
  elif [ -f "~/.claude/global/sop/${sop}.md" ]; then
    echo "  ⚡ User (~/.claude/global/sop/)"
  elif [ -f "${CLAUDE_PLUGIN_ROOT}/sop/${sop}.md" ]; then
    echo "  ⚡ Plugin (default)"
  else
    echo "  ✗ NOT FOUND (ERROR)"
  fi

  echo ""
done

echo "═══════════════════════════════════════════════════════"
```

## Step 5: Provide Override Instructions

```bash
echo ""
echo "💡 To override SOPs:"
echo ""
echo "For this project only:"
echo "  /rptc:admin:init --copy-sops"
echo "  # Copies SOPs to .claude/sop/ for customization"
echo ""
echo "For all your projects:"
echo "  /rptc:admin:init --copy-sops --global"
echo "  # Copies SOPs to ~/.claude/global/sop/ as defaults"
echo ""
echo "Manual copy:"
echo "  mkdir -p .claude/sop"
echo "  cp \"\${CLAUDE_PLUGIN_ROOT}/sop/testing-guide.md\" .claude/sop/"
echo "  # Edit .claude/sop/testing-guide.md"
echo ""
```

## Step 6: Compare Versions (Advanced)

If multiple versions exist (project + user or user + plugin):

```bash
echo "⚙️  Multiple Versions Detected:"
echo ""
echo "Showing differences between versions:"
echo ""

# If both project and user/plugin exist, show diff summary
if [ -f ".claude/sop/${SOP_NAME}.md" ] && [ -f "~/.claude/global/sop/${SOP_NAME}.md" ]; then
  echo "Comparing:"
  echo "  Active:   .claude/sop/${SOP_NAME}.md"
  echo "  Fallback: ~/.claude/global/sop/${SOP_NAME}.md"
  echo ""

  # Show brief diff stats
  LINES_DIFF=$(diff .claude/sop/${SOP_NAME}.md ~/.claude/global/sop/${SOP_NAME}.md 2>/dev/null | grep -c "^[<>]")

  if [ "$LINES_DIFF" -gt 0 ]; then
    echo "  📊 ${LINES_DIFF} lines differ between versions"
    echo "  💡 Run 'diff .claude/sop/${SOP_NAME}.md ~/.claude/global/sop/${SOP_NAME}.md' to see details"
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
