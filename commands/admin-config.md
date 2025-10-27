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
  echo "    Run: /rptc:admin-init"
fi
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
  echo "    Run: /rptc:admin-init"
fi
```

## Step 5: Plugin Settings

Display current plugin configuration:

```bash
echo ""
echo "Plugin Settings:"
echo "  (from ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json)"
echo ""

# Read actual values from config (with fallback to defaults)
ARTIFACT_LOC=$(jq -r '.rptc.artifactLocation // ".rptc"' .claude/settings.json 2>/dev/null || echo ".rptc")
DOCS_LOC=$(jq -r '.rptc.docsLocation // "docs"' .claude/settings.json 2>/dev/null || echo "docs")
COVERAGE_TARGET=$(jq -r '.rptc.testCoverageTarget // 85' .claude/settings.json 2>/dev/null || echo "85")
MAX_ATTEMPTS=$(jq -r '.rptc.maxPlanningAttempts // 10' .claude/settings.json 2>/dev/null || echo "10")

echo "  Artifact Location:     $ARTIFACT_LOC"
echo "  Docs Location:         $DOCS_LOC"
echo "  Test Coverage Target:  ${COVERAGE_TARGET}%"
echo "  Max Planning Attempts: $MAX_ATTEMPTS"
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
    echo "    Run: /rptc:admin-init (will update .gitignore)"
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
  echo "  • Initialize workspace: /rptc:admin-init"
fi

if [ ! -d ".rptc/sop" ] && [ ! -d "~/.claude/global/sop" ]; then
  echo "  • Copy SOPs for customization: /rptc:admin-init --copy-sops"
  echo "    (or --copy-sops --global for user-wide defaults)"
fi

if [ ! -f ".claude/CLAUDE.md" ] && [ ! -f "CLAUDE.md" ]; then
  echo "  • Create project instructions: /rptc:admin-init"
fi

echo "═══════════════════════════════════════════════════════"
```

## Output Format

- Use clear visual hierarchy with boxes and symbols
- Show both existence (✓/✗) and counts
- Provide file paths so user knows exactly where things are
- Always end with actionable recommendations
