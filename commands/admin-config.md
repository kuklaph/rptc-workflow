---
description: Show RPTC workflow configuration and SOP resolution
---

# RPTC Admin: Show Configuration

You are executing the **RPTC Configuration Display** command.

## Purpose

Display the current RPTC workflow configuration, showing where SOPs are being loaded from and what settings are active.

## Step 1: Display Plugin Information

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

## Step 2: Check Workspace Structure

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

## Step 4: Project Instructions

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

## Step 5: Plugin Settings

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
  - rptc.qualityGatesEnabled → QUALITY_GATES (default: "false")
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
  Quality Gates:         ${QUALITY_GATES}
  Discord Notifications: ${DISCORD_ENABLED}
```

## Step 6: Git Integration Status

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

## Step 7: Recommendations

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

## Output Format

- Use clear visual hierarchy with boxes and symbols
- Show both existence (✓/✗) and counts
- Provide file paths so user knows exactly where things are
- Always end with actionable recommendations
