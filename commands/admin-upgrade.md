---
description: Comprehensive workspace verification, repair, and upgrade
---

# RPTC Admin: Upgrade & Verify Workspace

You are executing the **RPTC Workspace Upgrade & Verification** command.

## Purpose

**Comprehensive workspace health check** that:
1. Verifies all required files and directories exist
2. Detects user customizations and asks before changing them
3. Upgrades configuration to match plugin version
4. Repairs missing/broken components
5. Shows changelog for new features

**Philosophy**: Respect user customizations. Only auto-fix clearly internal system state.

---

## Step 0: Resolve Plugin Root

Use the CLAUDE_PLUGIN_ROOT environment variable (provided by Claude Code plugin system):

```bash
# Step 0: Resolve plugin root
if [ -z "${CLAUDE_PLUGIN_ROOT}" ]; then
  exit 1
fi
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
```

If CLAUDE_PLUGIN_ROOT is not set:

❌ Error: CLAUDE_PLUGIN_ROOT not set. Plugin may not be installed correctly.

## Step 1: Initial Health Check

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 RPTC Workspace Verification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Plugin location: ${PLUGIN_ROOT}

Checking workspace health...

**Check if workspace is initialized:**

```bash
# Check if workspace is initialized at all
if [ ! -f ".claude/settings.json" ]; then
  exit 1
fi
```

If .claude/settings.json doesn't exist:

❌ ERROR: Workspace not initialized

This directory hasn't been set up for RPTC.

Run: /rptc:admin-init

**Verify RPTC configuration exists:**

Use Read tool to parse JSON:
Read(".claude/settings.json")

Check if "rptc" key exists in the JSON.

If "rptc" key is missing:

❌ ERROR: No RPTC configuration found in .claude/settings.json

This workspace has Claude settings but no RPTC config.

Run: /rptc:admin-init

If valid workspace found:

✓ Workspace is initialized

## Step 2: Load Current State

```bash
# Plugin version (update this with each release)
PLUGIN_VERSION="2.2.4"
```

**Configuration Extraction** (replaced jq dependency with Read tool + Claude parsing):

# Claude: Use Read tool to parse JSON
# Read(".claude/settings.json")
# Extract the following configuration values (use defaults if fields missing):
# - rptc._rptcVersion → WORKSPACE_VERSION (default: "1.0.0")
# - rptc.artifactLocation → ARTIFACT_LOC (default: ".rptc")
# - rptc.docsLocation → DOCS_LOC (default: "docs")
# - rptc.testCoverageTarget → COVERAGE_TARGET (default: 85)
# - rptc.maxPlanningAttempts → MAX_ATTEMPTS (default: 10)
# - rptc.customSopPath → CUSTOM_SOP_PATH (default: ".rptc/sop")
# - rptc.defaultThinkingMode → THINKING_MODE (default: "think")
# - rptc.researchOutputFormat → RESEARCH_OUTPUT_FORMAT (default: "html")
# - rptc.htmlReportTheme → HTML_REPORT_THEME (default: "dark")
# - rptc.verificationMode → VERIFICATION_MODE (default: "focused")
# - rptc.tdgMode → TDD_MODE (default: "disabled")
# - rptc.discord.notificationsEnabled → DISCORD_ENABLED (default: false)
# Store these values for use in subsequent steps.

```

Workspace version: v${WORKSPACE_VERSION}
Plugin version:    v${PLUGIN_VERSION}

## Step 3: Version Check & Changelog

```bash
if [ "$WORKSPACE_VERSION" = "$PLUGIN_VERSION" ]; then
  VERSION_CURRENT=1
else
  VERSION_CURRENT=0
fi
```

**Display version status:**

If versions match (VERSION_CURRENT=1):

✓ Workspace version is current (v${WORKSPACE_VERSION})

Running comprehensive verification anyway...

If upgrade available (VERSION_CURRENT=0):

🔄 Upgrade available: v${WORKSPACE_VERSION} → v${PLUGIN_VERSION}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 What's New
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Show relevant changelogs based on WORKSPACE_VERSION:**

```bash
case "$WORKSPACE_VERSION" in
  "1.0."*|"1.0.0"|"1.0.1"|"1.0.2"|"1.0.3"|"1.0.4"|"1.0.5"|"1.0.6")
    CHANGELOG="v1.0.7 - v1.0.9: Configuration system, thinking modes
v1.1.0: Version tracking, SOP path migration, upgrade command
v1.1.1: Fixed Windows backslash issue, shortened plugin name"
    ;;
  "1.0.7"|"1.0.8"|"1.0.9")
    CHANGELOG="v1.1.0: Version tracking, SOP path migration, upgrade command
v1.1.1: Fixed Windows backslash issue, shortened plugin name"
    ;;
  "1.1.0")
    CHANGELOG="v1.1.1: Fixed Windows backslash issue, shortened plugin name"
    ;;
  "1.1.1"|"1.1.2"|"1.1.3"|"1.1.4"|"1.1.5"|"1.1.6"|"1.1.7"|"1.1.8"|"1.1.9"|"1.1.10")
    CHANGELOG="v1.2.0: TodoWrite integration, blocking validation checkpoints, comprehensive quality gates
v2.0.0: Efficiency agent rewrite, post-TDD refactoring SOP, Discord notifications"
    ;;
  "1.2.0")
    CHANGELOG="v2.0.0: Efficiency agent rewrite, post-TDD refactoring SOP, Discord notifications"
    ;;
  "2.0.0")
    CHANGELOG="v2.0.1: Security agent streamlined, admin config display enhanced
v2.1.0: BREAKING: Simplified research workflow, GitHub URL installation
v2.1.1: Windows compatibility fixes, context window efficiency"
    ;;
  "2.0.1")
    CHANGELOG="v2.1.0: BREAKING: Simplified research workflow, GitHub URL installation
v2.1.1: Windows compatibility fixes, context window efficiency"
    ;;
  "2.1.0"|"2.1.1")
    CHANGELOG="v2.2.0: Bug fixes and cohesiveness improvements"
    ;;
esac
```

Output changelog (if VERSION_CURRENT=0):

${CHANGELOG}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Step 4: Comprehensive Workspace Verification

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Verifying Workspace Structure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```bash
# Track issues
ISSUES_FOUND=0
FIXES_TO_APPLY=()
USER_DECISIONS=()

# Expected directories based on user config
EXPECTED_ARTIFACT_DIRS=(
  "${ARTIFACT_LOC}/research"
  "${ARTIFACT_LOC}/plans"
  "${ARTIFACT_LOC}/complete"
  "${ARTIFACT_LOC}/sop"
)

EXPECTED_DOC_DIRS=(
  "${DOCS_LOC}/research"
  "${DOCS_LOC}/plans"
  "${DOCS_LOC}/architecture"
  "${DOCS_LOC}/patterns"
  "${DOCS_LOC}/api"
)
```

**1. Check directory structure:**

📁 Directory Structure:

```bash
for dir in "${EXPECTED_ARTIFACT_DIRS[@]}" "${EXPECTED_DOC_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    DIR_STATUS="✓"
  else
    DIR_STATUS="✗"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    FIXES_TO_APPLY+=("mkdir:$dir")
  fi
done
```

For each directory, output:
- If exists: `  ✓ ${dir}`
- If missing: `  ✗ ${dir} (missing)`

**2. Check for non-standard directory names:**

🔍 Checking for customized directory names:

```bash
CUSTOM_DIRS_FOUND=0

# Check if user renamed 'complete' to something else
if [ "$ARTIFACT_LOC" = ".rptc" ]; then
  # Only check if using default artifact location
  if [ ! -d ".rptc/complete" ]; then
    # Look for alternative names
    if [ -d ".rptc/archive" ]; then
      CUSTOM_DIRS_FOUND=1
      USER_DECISIONS+=("rename_archive_to_complete")
    elif [ -d ".rptc/archived" ]; then
      CUSTOM_DIRS_FOUND=1
      USER_DECISIONS+=("rename_archived_to_complete")
    elif [ -d ".rptc/done" ]; then
      CUSTOM_DIRS_FOUND=1
      USER_DECISIONS+=("rename_done_to_complete")
    fi
  fi
fi
```

For each alternative directory found, output:
- If .rptc/archive exists: `  ⚠️  Found: .rptc/archive (expected: .rptc/complete)\n      This might be an intentional customization.`
- If .rptc/archived exists: `  ⚠️  Found: .rptc/archived (expected: .rptc/complete)\n      This might be an intentional customization.`
- If .rptc/done exists: `  ⚠️  Found: .rptc/done (expected: .rptc/complete)\n      This might be an intentional customization.`

If CUSTOM_DIRS_FOUND=0, output:
`  ✓ No directory name customizations detected`

**3. Check configuration file completeness:**

⚙️  Configuration Verification:

**Field Existence Check** (use Read tool + Claude parsing):

Use Read tool to parse JSON:
Read(".claude/settings.json")

Check which of these fields are missing in the rptc configuration:
- rptc._rptcVersion
- rptc.defaultThinkingMode
- rptc.artifactLocation
- rptc.docsLocation
- rptc.testCoverageTarget
- rptc.maxPlanningAttempts
- rptc.customSopPath
- rptc.qualityGatesEnabled
- rptc.researchOutputFormat
- rptc.htmlReportTheme
- rptc.verificationMode
- rptc.tdgMode
- rptc.discord (object with webhookUrl, notificationsEnabled, verbosity)

For each missing field, add to MISSING_FIELDS array.

```bash
if [ ${#MISSING_FIELDS[@]} -gt 0 ]; then
  ISSUES_FOUND=$((ISSUES_FOUND + ${#MISSING_FIELDS[@]}))
  FIXES_TO_APPLY+=("add_missing_config_fields")
fi
```

If missing fields found, output:
`  ✗ Missing config fields: ${MISSING_FIELDS[*]}`

If all fields present, output:
`  ✓ All configuration fields present`

Then output current configuration:

  Current configuration:
    • artifactLocation: ${ARTIFACT_LOC}
    • docsLocation: ${DOCS_LOC}
    • testCoverageTarget: ${COVERAGE_TARGET}
    • maxPlanningAttempts: ${MAX_ATTEMPTS}
    • customSopPath: ${CUSTOM_SOP_PATH}
    • defaultThinkingMode: ${THINKING_MODE}
    • researchOutputFormat: ${RESEARCH_OUTPUT_FORMAT}
    • htmlReportTheme: ${HTML_REPORT_THEME}
    • verificationMode: ${VERIFICATION_MODE}
    • tdgMode: ${TDD_MODE}
    • discord.notificationsEnabled: ${DISCORD_ENABLED}

**4. Check for important files:**

📄 Important Files:

```bash
# Check .rptc/CLAUDE.md
if [ -f "${ARTIFACT_LOC}/CLAUDE.md" ]; then
  CLAUDE_MD_EXISTS=1
else
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
  USER_DECISIONS+=("create_rptc_claude_md")
  CLAUDE_MD_EXISTS=0
fi
```

If CLAUDE_MD_EXISTS=1, output:
`  ✓ ${ARTIFACT_LOC}/CLAUDE.md`

If CLAUDE_MD_EXISTS=0, output:
`  ✗ ${ARTIFACT_LOC}/CLAUDE.md (missing)`

**Check .gitignore:**

Use Grep tool to check .gitignore:
Grep(pattern: ".claude/settings.local.json", path: ".gitignore", output_mode: "files_with_matches")

```bash
if [ -f ".gitignore" ]; then
  # Use grep result from above
  if [ -n "$GREP_RESULT" ]; then
    GITIGNORE_OK=1
  else
    USER_DECISIONS+=("add_gitignore_entries")
    GITIGNORE_OK=0
  fi
else
  GITIGNORE_MISSING=1
fi
```

If GITIGNORE_OK=1, output:
`  ✓ .gitignore has Claude entries`

If GITIGNORE_OK=0, output:
`  ⚠️  .gitignore missing Claude entries`

If GITIGNORE_MISSING=1, output:
`  ℹ️  No .gitignore found (optional)`

**Special migration check:**

```bash
# Special migration check for v1.0.x users
if [ -d ".claude/sop" ] && [ "$CUSTOM_SOP_PATH" != ".claude/sop" ]; then
  SOP_ISSUES=1
  USER_DECISIONS+=("migrate_sop_location")
fi
```

If SOP_ISSUES=1, output:

  ⚠️  Legacy SOP location detected: .claude/sop/
      Plugin now defaults to: .rptc/sop/

**5. Summary:**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Verification Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```bash
if [ $ISSUES_FOUND -eq 0 ] && [ ${#USER_DECISIONS[@]} -eq 0 ]; then
  WORKSPACE_HEALTHY=1
  # Still need to update version if behind
  if [ "$WORKSPACE_VERSION" != "$PLUGIN_VERSION" ]; then
    FIXES_TO_APPLY+=("update_version_only")
    VERSION_ONLY=1
  else
    exit 0
  fi
else
  WORKSPACE_HEALTHY=0
fi
```

If WORKSPACE_HEALTHY=1 and VERSION_ONLY=0, output:
`✅ Workspace is healthy!\n\nNo issues found. Everything is up to date.`
Then exit.

If WORKSPACE_HEALTHY=1 and VERSION_ONLY=1, output:
`✅ Workspace is healthy!\n\nOnly version update needed.`

If WORKSPACE_HEALTHY=0, output:
`Found ${ISSUES_FOUND} issue(s) that can be auto-fixed\nFound ${#USER_DECISIONS[@]} item(s) that need your decision`

## Step 5: Handle User Decisions (Conversational)

```bash
if [ ${#USER_DECISIONS[@]} -gt 0 ]; then
  NEED_USER_INPUT=1
else
  NEED_USER_INPUT=0
fi
```

If NEED_USER_INPUT=1, present ALL issues in a single conversational response:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👤 User Decisions Required
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

I've analyzed your workspace and found items that may need attention. These might be intentional customizations.

**Build issue list from USER_DECISIONS array:**

For each decision in USER_DECISIONS, format as follows:

**If "rename_archive_to_complete":**
Issue 1: Directory Name
  • Current: .rptc/archive
  • Standard: .rptc/complete
  • Recommendation: Rename for consistency

**If "rename_archived_to_complete":**
Issue 1: Directory Name
  • Current: .rptc/archived
  • Standard: .rptc/complete
  • Recommendation: Rename for consistency

**If "rename_done_to_complete":**
Issue 1: Directory Name
  • Current: .rptc/done
  • Standard: .rptc/complete
  • Recommendation: Rename for consistency

**If "create_rptc_claude_md":**
Issue 2: Missing File
  • File: ${ARTIFACT_LOC}/CLAUDE.md
  • Purpose: RPTC workflow instructions
  • Recommendation: Create from template

**If "add_gitignore_entries":**
Issue 3: .gitignore Entries
  • Missing: .claude/settings.local.json, .claude/.env*
  • Purpose: Protect sensitive Claude settings
  • Recommendation: Add entries

**If "migrate_sop_location":**
Issue 4: SOP Location Migration
  • Current: .claude/sop/
  • Standard: .rptc/sop/
  • Note: v1.1.0 changed default location
  • Options:
    - [move] Move .claude/sop/ → .rptc/sop/ (recommended)
    - [keep] Keep .claude/sop/ and update config
    - [skip] Handle manually later

**Present options:**

Please choose how to handle these items:

1. Reply 'auto-fix' to apply all recommended changes
2. Reply 'skip-all' to keep current configuration
3. Reply with specific choices for each issue (comma-separated):
   - Directory: [rename] or [keep]
   - CLAUDE.md: [create] or [skip]
   - .gitignore: [add] or [skip]
   - SOP location: [move], [keep], or [skip]

   Example: "rename, create, add, move"

**Wait for user response** (conversational, not bash read)

**After receiving user's response, parse it:**

```bash
# Parse user response and populate FIXES_TO_APPLY
# This bash runs after you've received and interpreted the user's choice

case "$USER_RESPONSE" in
  *auto-fix*|*auto*|*fix*)
    # Apply all recommended fixes
    for decision in "${USER_DECISIONS[@]}"; do
      case "$decision" in
        rename_archive_to_complete)
          FIXES_TO_APPLY+=("mv:.rptc/archive:.rptc/complete")
          ;;
        rename_archived_to_complete)
          FIXES_TO_APPLY+=("mv:.rptc/archived:.rptc/complete")
          ;;
        rename_done_to_complete)
          FIXES_TO_APPLY+=("mv:.rptc/done:.rptc/complete")
          ;;
        create_rptc_claude_md)
          FIXES_TO_APPLY+=("create:rptc_claude_md")
          ;;
        add_gitignore_entries)
          FIXES_TO_APPLY+=("update:gitignore")
          ;;
        migrate_sop_location)
          if [ -d ".rptc/sop" ]; then
            # Can't auto-move if target exists
            SOP_MERGE_NEEDED=1
          else
            FIXES_TO_APPLY+=("mv:.claude/sop:.rptc/sop")
          fi
          ;;
      esac
    done
    ;;

  *skip-all*|*skip*)
    # User wants to keep everything as-is
    # Clear FIXES_TO_APPLY of any user-decision items
    ;;

  *)
    # Parse individual choices from user's message
    # Extract keywords: rename/keep, create/skip, add/skip, move/keep/skip
    # Based on extracted choices, populate FIXES_TO_APPLY array
    ;;
esac
```

**Note to Claude:** Parse the user's natural language response and translate it into bash variable assignments. The bash logic above shows the structure, but YOU determine what the user wants based on their message.

If user chose to apply fixes, output confirmation:

✓ Applying your requested changes...

If user chose skip-all, output:

✓ Keeping current configuration (no changes applied)

If SOP_MERGE_NEEDED=1, output:

⚠️  Warning: .rptc/sop/ already exists. SOP migration skipped.
    Please merge .claude/sop/ and .rptc/sop/ manually if needed.

## Step 6: Create Backup

```bash
if [ ${#FIXES_TO_APPLY[@]} -gt 0 ]; then
  NEED_BACKUP=1
  # Backup settings.json
  cp .claude/settings.json .claude/settings.json.backup
else
  NEED_BACKUP=0
fi
```

If NEED_BACKUP=1, output:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Creating Backup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Backup created: .claude/settings.json.backup

## Step 7: Apply Fixes

```bash
if [ ${#FIXES_TO_APPLY[@]} -gt 0 ]; then
  APPLYING_FIXES=1
else
  APPLYING_FIXES=0
fi
```

If APPLYING_FIXES=1, output:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 Applying Fixes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```bash
for fix in "${FIXES_TO_APPLY[@]}"; do
  # Parse fix command
  FIX_TYPE="${fix%%:*}"
  FIX_ARGS="${fix#*:}"

  case "$FIX_TYPE" in
    mkdir)
      mkdir -p "$FIX_ARGS"
      FIX_MSG="✓ Created directory: $FIX_ARGS"
      ;;

    mv)
      SRC="${FIX_ARGS%%:*}"
      DEST="${FIX_ARGS#*:}"
      mv "$SRC" "$DEST"
      FIX_MSG="✓ Renamed: $SRC → $DEST"
      ;;

    create)
      if [ "$FIX_ARGS" = "rptc_claude_md" ]; then
        if [ -f "$PLUGIN_ROOT/docs/PROJECT_TEMPLATE.md" ]; then
          cp "$PLUGIN_ROOT/docs/PROJECT_TEMPLATE.md" "${ARTIFACT_LOC}/CLAUDE.md"
          FIX_MSG="✓ Created: ${ARTIFACT_LOC}/CLAUDE.md"
        else
          FIX_MSG="⚠️  Template not found, skipping ${ARTIFACT_LOC}/CLAUDE.md creation"
        fi
      fi
      ;;

    update)
      if [ "$FIX_ARGS" = "gitignore" ]; then
        GITIGNORE_CHECK=0
      fi
      ;;

    config)
      CONFIG_KEY="${FIX_ARGS%%:*}"
      CONFIG_VAL="${FIX_ARGS#*:}"
```

For 'update:gitignore', use Grep tool first:
Grep(pattern: ".claude/settings.local.json", path: ".gitignore", output_mode: "files_with_matches")

```bash
      if [ -z "$GREP_RESULT" ]; then
        # Entry not found, add it
        {
          echo ""
          echo "# Claude settings"
          echo ".claude/settings.local.json  # Local overrides"
          echo ".claude/.env*               # Secrets"
        } >> .gitignore
        FIX_MSG="✓ Updated: .gitignore"
      fi
      ;;

    config)
      # Already handled by CONFIG_KEY/CONFIG_VAL above
```

For 'config:*', use Read and Edit tools:
Read(".claude/settings.json")
Update: rptc.${CONFIG_KEY} = "${CONFIG_VAL}"
Use Edit tool to write back the modified JSON (preserve structure)

```bash
      FIX_MSG="✓ Updated config: $CONFIG_KEY = \"$CONFIG_VAL\""
      ;;

    add_missing_config_fields)
```

For 'add_missing_config_fields', use Read and Edit tools:
Read(".claude/settings.json")
Add missing fields with these defaults (preserve existing values):
- rptc._rptcVersion = "$PLUGIN_VERSION"
- rptc.defaultThinkingMode = "think"
- rptc.artifactLocation = ".rptc"
- rptc.docsLocation = "docs"
- rptc.testCoverageTarget = 85
- rptc.maxPlanningAttempts = 10
- rptc.customSopPath = ".rptc/sop"
- rptc.qualityGatesEnabled = false
- rptc.researchOutputFormat = "html"
- rptc.htmlReportTheme = "dark"
- rptc.verificationMode = "focused"
- rptc.tdgMode = "disabled"
- rptc.discord = {"webhookUrl": "", "notificationsEnabled": false, "verbosity": "summary"}
Use Edit tool to write updated JSON back to file

```bash
      FIX_MSG="✓ Added missing configuration fields"
      ;;

    update_version_only)
```

For 'update_version_only', use Read and Edit tools:
Read(".claude/settings.json")
Update: rptc._rptcVersion = "$PLUGIN_VERSION"
Use Edit tool to write back the modified JSON (preserve structure)

```bash
      FIX_MSG="✓ Updated version: v${WORKSPACE_VERSION} → v${PLUGIN_VERSION}"
      ;;
  esac
done
```

**Output each fix message as it's applied:**

For each FIX_MSG generated above, output:
${FIX_MSG}

## Step 8: Final Summary

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Upgrade & Verification Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```bash
if [ "$WORKSPACE_VERSION" != "$PLUGIN_VERSION" ]; then
  VERSION_STATUS="Version: v${WORKSPACE_VERSION} → v${PLUGIN_VERSION}"
else
  VERSION_STATUS="Version: v${PLUGIN_VERSION} (verified)"
fi

if [ ${#FIXES_TO_APPLY[@]} -gt 0 ]; then
  FIXES_APPLIED="${#FIXES_TO_APPLY[@]}"
  HAS_BACKUP=1
else
  FIXES_APPLIED=0
  HAS_BACKUP=0
fi

if [ -f ".claude/settings.json.backup" ]; then
  BACKUP_EXISTS=1
else
  BACKUP_EXISTS=0
fi
```

**Output final summary:**

${VERSION_STATUS}

If FIXES_APPLIED > 0, output:
`Applied ${FIXES_APPLIED} fix(es)\nBackup: .claude/settings.json.backup`

Next steps:
  • Review configuration: /rptc:admin-config
  • Verify SOP paths: /rptc:admin-sop-check

If BACKUP_EXISTS=1, output:

To rollback (if needed):
  mv .claude/settings.json.backup .claude/settings.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Error Handling

- **No workspace**: Direct to `/rptc:admin-init`
- **Merge conflicts**: Warn user to handle manually
- **Always backup**: Create backup before any modifications
- **Idempotent**: Safe to run multiple times
- **Non-destructive**: Asks before changing user customizations

## Philosophy

**Auto-fix** (no prompt required):
- Missing configuration fields (clearly system-level)
- Version number updates
- Missing directories that don't exist at all

**Ask first** (potential user customization):
- Directory renames (user might prefer different naming)
- Changed config values (user might have tuned these)
- Missing files (user might have deleted intentionally)
- SOP location changes (user might have specific preferences)

**Never change without asking**:
- Non-standard directory names
- Custom config values that differ from defaults
- File deletions (only offer to recreate, never force)
- Any structure that deviates from standard in a way that suggests intention
