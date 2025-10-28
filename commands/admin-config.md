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
# Claude: Use Read tool to extract version from plugin.json
# Read("${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json")
# Extract and display line containing: "version": "X.Y.Z"
```

## Step 2: Check Workspace Structure

Check if RPTC workspace is initialized:

```bash
echo ""
echo "Workspace Status:"
if [ -d ".rptc" ]; then
  echo "  ✓ .rptc/ directory exists"
  # Claude: Use Glob tool to count files in each directory
  # Glob(pattern: ".rptc/research/**/*") → count results → RESEARCH_COUNT
  # Glob(pattern: ".rptc/plans/**/*") → count results → PLANS_COUNT
  # Glob(pattern: ".rptc/complete/**/*") → count results → COMPLETE_COUNT
  echo "    - research/: ${RESEARCH_COUNT} files"
  echo "    - plans/:    ${PLANS_COUNT} files"
  echo "    - complete/:  ${COMPLETE_COUNT} files"
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
echo "  (from .claude/settings.json)"
echo ""

# Read configuration values from .claude/settings.json using Read tool
# Delegate to Claude to extract these values (Read tool pattern - no jq dependency)

echo "Loading configuration from .claude/settings.json..."

# Request Claude to read .claude/settings.json and extract these fields:
# - rptc._rptcVersion → RPTC_VERSION (default: "unknown")
# - rptc.defaultThinkingMode → THINKING_MODE (default: "think")
# - rptc.artifactLocation → ARTIFACT_LOC (default: ".rptc")
# - rptc.docsLocation → DOCS_LOC (default: "docs")
# - rptc.testCoverageTarget → COVERAGE_TARGET (default: "85")
# - rptc.maxPlanningAttempts → MAX_ATTEMPTS (default: "10")
# - rptc.customSopPath → CUSTOM_SOP (default: ".rptc/sop")
# - rptc.researchOutputFormat → RESEARCH_FORMAT (default: "html")
# - rptc.htmlReportTheme → HTML_THEME (default: "dark")
# - rptc.verificationMode → VERIFICATION_MODE (default: "focused")
# - rptc.tdgMode → TDG_MODE (default: "disabled")
# - rptc.qualityGatesEnabled → QUALITY_GATES (default: "false")
# - rptc.discord.notificationsEnabled → DISCORD_ENABLED (default: "false")

# Claude will use Read tool on .claude/settings.json and set these variables
# If Read fails or field is missing, use the default values shown above
```

After Claude extracts the values, display them:

```bash
echo ""
echo "Current Configuration:"
echo "  RPTC Version:          $RPTC_VERSION"
echo "  Default Thinking Mode: $THINKING_MODE"
echo "  Artifact Location:     $ARTIFACT_LOC"
echo "  Docs Location:         $DOCS_LOC"
echo "  Test Coverage Target:  ${COVERAGE_TARGET}%"
echo "  Max Planning Attempts: $MAX_ATTEMPTS"
echo "  Custom SOP Path:       $CUSTOM_SOP"
echo "  Research Output:       $RESEARCH_FORMAT"
echo "  HTML Report Theme:     $HTML_THEME"
echo "  Verification Mode:     $VERIFICATION_MODE"
echo "  TDG Mode:              $TDG_MODE"
echo "  Quality Gates:         $QUALITY_GATES"
echo "  Discord Notifications: $DISCORD_ENABLED"
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
