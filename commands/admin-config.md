---
description: Show RPTC workflow configuration and SOP resolution
---

# RPTC Admin: Show Configuration

You are executing the **RPTC Configuration Display** command.

## Purpose

Display the current RPTC workflow configuration, showing where SOPs are being loaded from and what settings are active.

## Step 1: Display Options Menu (Opportunity 44)

First, ask the user what configuration information they want to see using AskUserQuestion:

```markdown
Use the AskUserQuestion tool with this configuration:

{
  "questions": [
    {
      "question": "What configuration information would you like to see?",
      "header": "Display",
      "multiSelect": false,
      "options": [
        {
          "label": "Everything - Full configuration and status",
          "description": "Complete overview including plugin info, workspace status, settings, git integration, and recommendations"
        },
        {
          "label": "Settings only - Current RPTC configuration",
          "description": "Just the current RPTC settings values from .claude/settings.json"
        },
        {
          "label": "SOPs only - SOP resolution paths",
          "description": "Just SOP information and fallback chain resolution"
        },
        {
          "label": "Problems only - Issues and recommendations",
          "description": "Only show warnings, errors, and actionable recommendations"
        },
        {
          "label": "Comparison - Compare with defaults",
          "description": "Show current settings compared to plugin defaults"
        }
      ]
    }
  ]
}
```

Capture the response in DISPLAY_MODE variable:
- "Everything - Full configuration and status" → DISPLAY_MODE="everything"
- "Settings only - Current RPTC configuration" → DISPLAY_MODE="settings"
- "SOPs only - SOP resolution paths" → DISPLAY_MODE="sops"
- "Problems only - Issues and recommendations" → DISPLAY_MODE="problems"
- "Comparison - Compare with defaults" → DISPLAY_MODE="comparison"

If user cancels, default to DISPLAY_MODE="everything"

## Step 2: Display Plugin Information (Conditional)

If DISPLAY_MODE is "everything", "comparison", or "problems":

Output the following header directly:

```
═══════════════════════════════════════════════════════
📋 RPTC Workflow Configuration
═══════════════════════════════════════════════════════

Plugin Location:
  ${CLAUDE_PLUGIN_ROOT}

Plugin Version:
```

Then use Read tool to extract version:
- Read(file_path: "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json")
- Extract the "version" field from JSON
- Output: "  X.Y.Z"

## Step 3: Check Workspace Structure (Conditional)

If DISPLAY_MODE is "everything" or "problems":

Check if RPTC workspace is initialized:

```bash
if [ -d ".rptc" ]; then
  WORKSPACE_EXISTS=true
else
  WORKSPACE_EXISTS=false
fi
```

Then output directly:

```

Workspace Status:
```

If WORKSPACE_EXISTS is true:
- Use Glob tool to count files:
  - Glob(pattern: ".rptc/research/**/*") → count results → RESEARCH_COUNT
  - Glob(pattern: ".rptc/plans/**/*") → count results → PLANS_COUNT
  - Glob(pattern: ".rptc/complete/**/*") → count results → COMPLETE_COUNT
- Output:
  ```
    ✓ .rptc/ directory exists
      - research/: ${RESEARCH_COUNT} files
      - plans/:    ${PLANS_COUNT} files
      - complete/:  ${COMPLETE_COUNT} files
  ```

If WORKSPACE_EXISTS is false:
- Output:
  ```
    ✗ .rptc/ not initialized
      Run: /rptc:admin-init
  ```

## Step 4: Project Instructions (Conditional)

If DISPLAY_MODE is "everything" or "problems":

Check for project instructions:

```bash
if [ -f ".claude/CLAUDE.md" ]; then
  CLAUDE_FILE=".claude/CLAUDE.md"
elif [ -f "CLAUDE.md" ]; then
  CLAUDE_FILE="CLAUDE.md"
else
  CLAUDE_FILE=""
fi
```

Then output directly:

```

Project Instructions:
```

If CLAUDE_FILE is ".claude/CLAUDE.md":
- Read(file_path: ".claude/CLAUDE.md")
- Count lines from Read result → LINE_COUNT
- Output:
  ```
    ✓ .claude/CLAUDE.md exists
      Size: ${LINE_COUNT} lines
  ```

Else if CLAUDE_FILE is "CLAUDE.md":
- Read(file_path: "CLAUDE.md")
- Count lines from Read result → LINE_COUNT
- Output:
  ```
    ✓ CLAUDE.md exists (root)
      Size: ${LINE_COUNT} lines
  ```

Else (CLAUDE_FILE is empty):
- Output:
  ```
    ✗ No CLAUDE.md found
      Run: /rptc:admin-init
  ```

## Step 5: Plugin Settings (Always Display)

For all DISPLAY_MODE values, show settings (with different detail levels):

Output directly:

```

Plugin Settings:
  (from .claude/settings.json)

```

Then read configuration:
- Read(file_path: ".claude/settings.json")
- Extract the following fields from the JSON (use defaults if field missing or file doesn't exist):
  - rptc._rptcVersion → RPTC_VERSION (default: "unknown")
  - rptc.defaultThinkingMode → THINKING_MODE (default: "think")
  - rptc.artifactLocation → ARTIFACT_LOC (default: ".rptc")
  - rptc.docsLocation → DOCS_LOC (default: "docs")
  - rptc.testCoverageTarget → COVERAGE_TARGET (default: "85")
  - rptc.maxPlanningAttempts → MAX_ATTEMPTS (default: "10")
  - rptc.customSopPath → CUSTOM_SOP (default: ".rptc/sop")
  - rptc.researchOutputFormat → RESEARCH_FORMAT (default: "html")
  - rptc.htmlReportTheme → HTML_THEME (default: "dark")
  - rptc.verificationMode → VERIFICATION_MODE (default: "focused")
  - rptc.tdgMode → TDG_MODE (default: "disabled")
  - rptc.discord.notificationsEnabled → DISCORD_ENABLED (default: "false")

After extracting values, output directly:

```
Current Configuration:
  RPTC Version:          ${RPTC_VERSION}
  Default Thinking Mode: ${THINKING_MODE}
  Artifact Location:     ${ARTIFACT_LOC}
  Docs Location:         ${DOCS_LOC}
  Test Coverage Target:  ${COVERAGE_TARGET}%
  Max Planning Attempts: ${MAX_ATTEMPTS}
  Custom SOP Path:       ${CUSTOM_SOP}
  Research Output:       ${RESEARCH_FORMAT}
  HTML Report Theme:     ${HTML_THEME}
  Verification Mode:     ${VERIFICATION_MODE}
  TDG Mode:              ${TDG_MODE}
  Discord Notifications: ${DISCORD_ENABLED}
```

## Step 6: SOP Information (Conditional)

If DISPLAY_MODE is "everything" or "sops":

Output directly:

```

SOP Resolution Paths:
  (Fallback chain order)

```

For each SOP, check resolution:
- testing-guide.md
- architecture-patterns.md
- frontend-guidelines.md
- git-and-deployment.md
- languages-and-style.md
- security-and-performance.md
- todowrite-guide.md

For each SOP, use this resolution logic:

```bash
SOP_NAME="testing-guide"  # Example

# Check project SOPs first
if [ -f ".rptc/sop/${SOP_NAME}.md" ]; then
  RESOLVED_PATH=".rptc/sop/${SOP_NAME}.md"
  SOURCE="Project"
# Then check user global SOPs
elif [ -f "$HOME/.claude/global/sop/${SOP_NAME}.md" ]; then
  RESOLVED_PATH="$HOME/.claude/global/sop/${SOP_NAME}.md"
  SOURCE="User Global"
# Finally use plugin default
else
  RESOLVED_PATH="${CLAUDE_PLUGIN_ROOT}/sop/${SOP_NAME}.md"
  SOURCE="Plugin Default"
fi
```

Output for each SOP:
```
  ${SOP_NAME}:
    ✓ ${SOURCE}: ${RESOLVED_PATH}
```

## Step 7: Comparison Mode (Conditional)

If DISPLAY_MODE is "comparison":

Output directly:

```

Configuration Comparison:
  (Current vs Plugin Defaults)

```

Compare current settings with plugin defaults:

| Setting | Current Value | Plugin Default | Match |
|---------|---------------|----------------|-------|
| defaultThinkingMode | ${THINKING_MODE} | think | ✓/✗ |
| artifactLocation | ${ARTIFACT_LOC} | .rptc | ✓/✗ |
| docsLocation | ${DOCS_LOC} | docs | ✓/✗ |
| testCoverageTarget | ${COVERAGE_TARGET} | 85 | ✓/✗ |
| maxPlanningAttempts | ${MAX_ATTEMPTS} | 10 | ✓/✗ |
| customSopPath | ${CUSTOM_SOP} | .rptc/sop | ✓/✗ |
| researchOutputFormat | ${RESEARCH_FORMAT} | html | ✓/✗ |
| htmlReportTheme | ${HTML_THEME} | dark | ✓/✗ |
| verificationMode | ${VERIFICATION_MODE} | focused | ✓/✗ |
| tdgMode | ${TDG_MODE} | disabled | ✓/✗ |

Output each row with appropriate match indicator (✓ if matches default, ✗ if customized)

## Step 8: Git Integration Status (Conditional)

If DISPLAY_MODE is "everything" or "problems":

Check git configuration:

```bash
if [ -d ".git" ]; then
  IS_GIT_REPO=true
  BRANCH=$(git branch --show-current 2>/dev/null)
else
  IS_GIT_REPO=false
fi
```

Then output directly:

```

Git Integration:
```

If IS_GIT_REPO is true:
- Output: "  ✓ Git repository detected"
- Use Grep tool to check .gitignore:
  - Grep(pattern: "\.rptc/complete", path: ".gitignore", output_mode: "files_with_matches")
  - If result non-empty:
    - Output: "  ✓ .gitignore contains RPTC entries"
  - Else:
    - Output:
      ```
        ⚠️  .gitignore missing RPTC entries
          Run: /rptc:admin-init (will update .gitignore)
      ```
- Output: "  Current branch: ${BRANCH}"

If IS_GIT_REPO is false:
- Output: "  ✗ Not a git repository"

## Step 9: Recommendations (Conditional)

If DISPLAY_MODE is "everything" or "problems":

Check what recommendations to provide:

```bash
if [ ! -d ".rptc" ]; then
  NEED_INIT=true
else
  NEED_INIT=false
fi

if [ ! -d ".rptc/sop" ] && [ ! -d "~/.claude/global/sop" ]; then
  NEED_SOPS=true
else
  NEED_SOPS=false
fi

if [ ! -f ".claude/CLAUDE.md" ] && [ ! -f "CLAUDE.md" ]; then
  NEED_CLAUDE_MD=true
else
  NEED_CLAUDE_MD=false
fi
```

Then output directly:

```

═══════════════════════════════════════════════════════
💡 Recommendations:
```

If NEED_INIT is true:
- Output: "  • Initialize workspace: /rptc:admin-init"

If NEED_SOPS is true:
- Output:
  ```
    • Copy SOPs for customization: /rptc:admin-init --copy-sops
      (or --copy-sops --global for user-wide defaults)
  ```

If NEED_CLAUDE_MD is true:
- Output: "  • Create project instructions: /rptc:admin-init"

Finally output:
```
═══════════════════════════════════════════════════════
```

## Step 10: Export Configuration Menu (Opportunity 45)

After displaying the configuration, ask if user wants to export using AskUserQuestion:

```markdown
Use the AskUserQuestion tool with this configuration:

{
  "questions": [
    {
      "question": "Would you like to export this configuration?",
      "header": "Export",
      "multiSelect": false,
      "options": [
        {
          "label": "No - Just display",
          "description": "No export needed, just showing the information"
        },
        {
          "label": "Export as JSON - Save to file",
          "description": "Save a copy of .claude/settings.json to a specified location"
        },
        {
          "label": "Copy to clipboard - For sharing",
          "description": "Copy configuration summary to clipboard for sharing"
        },
        {
          "label": "Generate shareable config",
          "description": "Create a sanitized config template (removes sensitive values)"
        }
      ]
    }
  ]
}
```

Capture the response in EXPORT_MODE variable:
- "No - Just display" → EXPORT_MODE="skip"
- "Export as JSON - Save to file" → EXPORT_MODE="json"
- "Copy to clipboard - For sharing" → EXPORT_MODE="clipboard"
- "Generate shareable config" → EXPORT_MODE="template"

If user cancels, default to EXPORT_MODE="skip"

### Handle Export Actions

If EXPORT_MODE is "json":
- Ask user for export file path (default: "rptc-config-export.json")
- Use Write tool to copy .claude/settings.json to specified location
- Output: "✅ Configuration exported to: [file_path]"

If EXPORT_MODE is "clipboard":
- Format configuration as readable text summary
- Output: "✅ Configuration summary copied to clipboard (use Ctrl+V to paste)"
- Note: Actual clipboard copy would require system integration

If EXPORT_MODE is "template":
- Read .claude/settings.json
- Create sanitized version (remove sensitive fields like webhookUrl)
- Save to "rptc-config-template.json"
- Output: "✅ Shareable config template created: rptc-config-template.json"

If EXPORT_MODE is "skip":
- No action needed
- Output: "ℹ️  Configuration display complete"

## Output Format

- Use clear visual hierarchy with boxes and symbols
- Show both existence (✓/✗) and counts
- Provide file paths so user knows exactly where things are
- Always end with actionable recommendations or export confirmation
