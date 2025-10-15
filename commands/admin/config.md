---
description: Show RPTC workflow configuration and SOP resolution
---

# RPTC Admin: Show Configuration

You are executing the **RPTC Configuration Display** command.

## Purpose

Display the current RPTC workflow configuration, showing where SOPs are being loaded from and what settings are active.

## Step 1: Display Plugin Information

```bash
echo "═══════════════════════════════════════════════════════"
echo "📋 RPTC Workflow Configuration"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Plugin Location:"
echo "  ${CLAUDE_PLUGIN_ROOT}"
echo ""
echo "Plugin Version:"
# Read from plugin.json
cat "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" | grep '"version"' | head -1
```

## Step 2: Check Workspace Structure

Check if RPTC workspace is initialized:

```bash
echo ""
echo "Workspace Status:"
if [ -d ".rptc" ]; then
  echo "  ✓ .rptc/ directory exists"
  echo "    - research/: $(find .rptc/research -type f 2>/dev/null | wc -l) files"
  echo "    - plans/:    $(find .rptc/plans -type f 2>/dev/null | wc -l) files"
  echo "    - complete/:  $(find .rptc/complete -type f 2>/dev/null | wc -l) files"
else
  echo "  ✗ .rptc/ not initialized"
  echo "    Run: /rptc:admin:init"
fi
```

## Step 3: SOP Resolution Status

Show where SOPs are being loaded from:

```bash
echo ""
echo "SOP Configuration:"
echo "  Resolution order (highest priority first):"
echo "  1. Project:  .rptc/sop/"
echo "  2. User:     ~/.claude/global/sop/"
echo "  3. Plugin:   ${CLAUDE_PLUGIN_ROOT}/sop/"
echo ""

# Check project SOPs
if [ -d ".rptc/sop" ]; then
  SOP_COUNT=$(find .rptc/sop -name "*.md" 2>/dev/null | wc -l)
  echo "  ✓ Project SOPs: ${SOP_COUNT} files in .rptc/sop/"
  find .rptc/sop -name "*.md" -exec basename {} \; 2>/dev/null | sed 's/^/    - /'
else
  echo "  ✗ No project SOPs (.rptc/sop/ not found)"
fi

echo ""

# Check user global SOPs
if [ -d "~/.claude/global/sop" ]; then
  SOP_COUNT=$(find ~/.claude/global/sop -name "*.md" 2>/dev/null | wc -l)
  echo "  ✓ User Global SOPs: ${SOP_COUNT} files in ~/.claude/global/sop/"
else
  echo "  ✗ No user global SOPs (~/.claude/global/sop/ not found)"
fi

echo ""

# Plugin SOPs (always available)
SOP_COUNT=$(find "${CLAUDE_PLUGIN_ROOT}/sop" -name "*.md" 2>/dev/null | wc -l)
echo "  ✓ Plugin SOPs: ${SOP_COUNT} files (default fallback)"
find "${CLAUDE_PLUGIN_ROOT}/sop" -name "*.md" -exec basename {} \; | sed 's/^/    - /'
```

## Step 4: Project Instructions

Check for project instructions:

```bash
echo ""
echo "Project Instructions:"
if [ -f ".claude/CLAUDE.md" ]; then
  echo "  ✓ .claude/CLAUDE.md exists"
  LINE_COUNT=$(wc -l < .claude/CLAUDE.md)
  echo "    Size: ${LINE_COUNT} lines"
elif [ -f "CLAUDE.md" ]; then
  echo "  ✓ CLAUDE.md exists (root)"
  LINE_COUNT=$(wc -l < CLAUDE.md)
  echo "    Size: ${LINE_COUNT} lines"
else
  echo "  ✗ No CLAUDE.md found"
  echo "    Run: /rptc:admin:init"
fi
```

## Step 5: Plugin Settings

Display current plugin configuration:

```bash
echo ""
echo "Plugin Settings:"
echo "  (from ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json)"
echo ""

# Parse and display key settings from plugin.json
echo "  Artifact Location:     .rptc/"
echo "  Docs Location:         docs/"
echo "  Test Coverage Target:  80%"
echo "  Max Planning Attempts: 10"
```

## Step 6: Git Integration Status

Check git configuration:

```bash
echo ""
echo "Git Integration:"
if [ -d ".git" ]; then
  echo "  ✓ Git repository detected"

  # Check .gitignore
  if grep -q ".rptc/complete" .gitignore 2>/dev/null; then
    echo "  ✓ .gitignore contains RPTC entries"
  else
    echo "  ⚠️  .gitignore missing RPTC entries"
    echo "    Run: /rptc:admin:init (will update .gitignore)"
  fi

  # Check current branch
  BRANCH=$(git branch --show-current 2>/dev/null)
  echo "  Current branch: ${BRANCH}"
else
  echo "  ✗ Not a git repository"
fi
```

## Step 7: Recommendations

Provide actionable recommendations:

```bash
echo ""
echo "═══════════════════════════════════════════════════════"
echo "💡 Recommendations:"

if [ ! -d ".rptc" ]; then
  echo "  • Initialize workspace: /rptc:admin:init"
fi

if [ ! -d ".rptc/sop" ] && [ ! -d "~/.claude/global/sop" ]; then
  echo "  • Copy SOPs for customization: /rptc:admin:init --copy-sops"
  echo "    (or --copy-sops --global for user-wide defaults)"
fi

if [ ! -f ".claude/CLAUDE.md" ] && [ ! -f "CLAUDE.md" ]; then
  echo "  • Create project instructions: /rptc:admin:init"
fi

echo "═══════════════════════════════════════════════════════"
```

## Output Format

- Use clear visual hierarchy with boxes and symbols
- Show both existence (✓/✗) and counts
- Provide file paths so user knows exactly where things are
- Always end with actionable recommendations
