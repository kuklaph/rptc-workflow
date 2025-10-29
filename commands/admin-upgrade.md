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
  echo "❌ Error: CLAUDE_PLUGIN_ROOT not set. Plugin may not be installed correctly."
  exit 1
fi
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
```

## Step 1: Initial Health Check

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 RPTC Workspace Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Plugin location: $PLUGIN_ROOT"
echo ""
echo "Checking workspace health..."
echo ""

# Check if workspace is initialized at all
if [ ! -f ".claude/settings.json" ]; then
  echo "❌ ERROR: Workspace not initialized"
  echo ""
  echo "This directory hasn't been set up for RPTC."
  echo ""
  echo "Run: /rptc:admin-init"
  exit 1
fi

# Check if settings.json has rptc section
if ! grep -q '"rptc"' .claude/settings.json; then
  echo "❌ ERROR: No RPTC configuration found in .claude/settings.json"
  echo ""
  echo "This workspace has Claude settings but no RPTC config."
  echo ""
  echo "Run: /rptc:admin-init"
  exit 1
fi

echo "✓ Workspace is initialized"
echo ""
```

## Step 2: Load Current State

```bash
# Plugin version (update this with each release)
PLUGIN_VERSION="2.2.3"
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

```bash

echo "Workspace version: v${WORKSPACE_VERSION}"
echo "Plugin version:    v${PLUGIN_VERSION}"
echo ""
```

## Step 3: Version Check & Changelog

```bash
if [ "$WORKSPACE_VERSION" = "$PLUGIN_VERSION" ]; then
  echo "✓ Workspace version is current (v${WORKSPACE_VERSION})"
  echo ""
  echo "Running comprehensive verification anyway..."
  echo ""
else
  echo "🔄 Upgrade available: v${WORKSPACE_VERSION} → v${PLUGIN_VERSION}"
  echo ""

  # Show relevant changelogs
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📋 What's New"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  case "$WORKSPACE_VERSION" in
    "1.0."*|"1.0.0"|"1.0.1"|"1.0.2"|"1.0.3"|"1.0.4"|"1.0.5"|"1.0.6")
      echo "v1.0.7 - v1.0.9: Configuration system, thinking modes"
      echo "v1.1.0: Version tracking, SOP path migration, upgrade command"
      echo "v1.1.1: Fixed Windows backslash issue, shortened plugin name"
      echo ""
      ;;
    "1.0.7"|"1.0.8"|"1.0.9")
      echo "v1.1.0: Version tracking, SOP path migration, upgrade command"
      echo "v1.1.1: Fixed Windows backslash issue, shortened plugin name"
      echo ""
      ;;
    "1.1.0")
      echo "v1.1.1: Fixed Windows backslash issue, shortened plugin name"
      echo ""
      ;;
    "1.1.1"|"1.1.2"|"1.1.3"|"1.1.4"|"1.1.5"|"1.1.6"|"1.1.7"|"1.1.8"|"1.1.9"|"1.1.10")
      echo "v1.2.0: TodoWrite integration, blocking validation checkpoints, comprehensive quality gates"
      echo "v2.0.0: Efficiency agent rewrite, post-TDD refactoring SOP, Discord notifications"
      echo ""
      ;;
    "1.2.0")
      echo "v2.0.0: Efficiency agent rewrite, post-TDD refactoring SOP, Discord notifications"
      echo ""
      ;;
    "2.0.0")
      echo "v2.0.1: Security agent streamlined, admin config display enhanced"
      echo "v2.1.0: BREAKING: Simplified research workflow, GitHub URL installation"
      echo "v2.1.1: Windows compatibility fixes, context window efficiency"
      echo ""
      ;;
    "2.0.1")
      echo "v2.1.0: BREAKING: Simplified research workflow, GitHub URL installation"
      echo "v2.1.1: Windows compatibility fixes, context window efficiency"
      echo ""
      ;;
    "2.1.0"|"2.1.1")
      echo "v2.2.0: Bug fixes and cohesiveness improvements"
      echo ""
      ;;
  esac

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi
```

## Step 4: Comprehensive Workspace Verification

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Verifying Workspace Structure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

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

# 1. Check directory structure
echo "📁 Directory Structure:"
echo ""

for dir in "${EXPECTED_ARTIFACT_DIRS[@]}" "${EXPECTED_DOC_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "  ✓ $dir"
  else
    echo "  ✗ $dir (missing)"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    FIXES_TO_APPLY+=("mkdir:$dir")
  fi
done

echo ""

# 2. Check for non-standard directory names (potential user customizations)
echo "🔍 Checking for customized directory names:"
echo ""

CUSTOM_DIRS_FOUND=0

# Check if user renamed 'complete' to something else
if [ "$ARTIFACT_LOC" = ".rptc" ]; then
  # Only check if using default artifact location
  if [ ! -d ".rptc/complete" ]; then
    # Look for alternative names
    if [ -d ".rptc/archive" ]; then
      echo "  ⚠️  Found: .rptc/archive (expected: .rptc/complete)"
      echo "      This might be an intentional customization."
      CUSTOM_DIRS_FOUND=1
      USER_DECISIONS+=("rename_archive_to_complete")
    elif [ -d ".rptc/archived" ]; then
      echo "  ⚠️  Found: .rptc/archived (expected: .rptc/complete)"
      echo "      This might be an intentional customization."
      CUSTOM_DIRS_FOUND=1
      USER_DECISIONS+=("rename_archived_to_complete")
    elif [ -d ".rptc/done" ]; then
      echo "  ⚠️  Found: .rptc/done (expected: .rptc/complete)"
      echo "      This might be an intentional customization."
      CUSTOM_DIRS_FOUND=1
      USER_DECISIONS+=("rename_done_to_complete")
    fi
  fi
fi

if [ $CUSTOM_DIRS_FOUND -eq 0 ]; then
  echo "  ✓ No directory name customizations detected"
fi

echo ""

# 3. Check configuration file completeness
echo "⚙️  Configuration Verification:"
echo ""
```

**Field Existence Check** (replaced jq dependency with Read tool + Claude parsing):

# Claude: Use Read tool to parse JSON
# Read(".claude/settings.json")
# Check which of these fields are missing in the rptc configuration:
# - rptc._rptcVersion
# - rptc.defaultThinkingMode
# - rptc.artifactLocation
# - rptc.docsLocation
# - rptc.testCoverageTarget
# - rptc.maxPlanningAttempts
# - rptc.customSopPath
# - rptc.qualityGatesEnabled
# - rptc.researchOutputFormat
# - rptc.htmlReportTheme
# - rptc.verificationMode
# - rptc.tdgMode
# - rptc.discord (object with webhookUrl, notificationsEnabled, verbosity)
#
# For each missing field, add to MISSING_FIELDS array.
# Then execute the following bash logic:

```bash
  if [ ${#MISSING_FIELDS[@]} -gt 0 ]; then
    echo "  ✗ Missing config fields: ${MISSING_FIELDS[*]}"
    ISSUES_FOUND=$((ISSUES_FOUND + ${#MISSING_FIELDS[@]}))
    FIXES_TO_APPLY+=("add_missing_config_fields")
  else
    echo "  ✓ All configuration fields present"
  fi

  # Check for customized values (informational)
  echo ""
  echo "  Current configuration:"
  echo "    • artifactLocation: $ARTIFACT_LOC"
  echo "    • docsLocation: $DOCS_LOC"
  echo "    • testCoverageTarget: $COVERAGE_TARGET"
  echo "    • maxPlanningAttempts: $MAX_ATTEMPTS"
  echo "    • customSopPath: $CUSTOM_SOP_PATH"
  echo "    • defaultThinkingMode: $THINKING_MODE"
  echo "    • researchOutputFormat: $RESEARCH_OUTPUT_FORMAT"
  echo "    • htmlReportTheme: $HTML_REPORT_THEME"
  echo "    • verificationMode: $VERIFICATION_MODE"
  echo "    • tdgMode: $TDD_MODE"
  echo "    • discord.notificationsEnabled: $DISCORD_ENABLED"

echo ""

# 4. Check for important files
echo "📄 Important Files:"
echo ""

# Check .rptc/CLAUDE.md
if [ -f "${ARTIFACT_LOC}/CLAUDE.md" ]; then
  echo "  ✓ ${ARTIFACT_LOC}/CLAUDE.md"
else
  echo "  ✗ ${ARTIFACT_LOC}/CLAUDE.md (missing)"
  ISSUES_FOUND=$((ISSUES_FOUND + 1))
  USER_DECISIONS+=("create_rptc_claude_md")
fi

# Check .gitignore has Claude entries
if [ -f ".gitignore" ]; then
  if grep -q ".claude/settings.local.json" .gitignore; then
    echo "  ✓ .gitignore has Claude entries"
  else
    echo "  ⚠️  .gitignore missing Claude entries"
    USER_DECISIONS+=("add_gitignore_entries")
  fi
else
  echo "  ℹ️  No .gitignore found (optional)"
fi

echo ""

# Special migration check for v1.0.x users
if [ -d ".claude/sop" ] && [ "$CUSTOM_SOP_PATH" != ".claude/sop" ]; then
  echo ""
  echo "  ⚠️  Legacy SOP location detected: .claude/sop/"
  echo "      Plugin now defaults to: .rptc/sop/"
  SOP_ISSUES=1
  USER_DECISIONS+=("migrate_sop_location")
fi

echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Verification Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ISSUES_FOUND -eq 0 ] && [ ${#USER_DECISIONS[@]} -eq 0 ]; then
  echo "✅ Workspace is healthy!"
  echo ""

  # Still need to update version if behind
  if [ "$WORKSPACE_VERSION" != "$PLUGIN_VERSION" ]; then
    echo "Only version update needed."
    FIXES_TO_APPLY+=("update_version_only")
  else
    echo "No issues found. Everything is up to date."
    exit 0
  fi
else
  echo "Found $ISSUES_FOUND issue(s) that can be auto-fixed"
  echo "Found ${#USER_DECISIONS[@]} item(s) that need your decision"
  echo ""
fi
```

## Step 5: Handle User Decisions (Interactive)

```bash
if [ ${#USER_DECISIONS[@]} -gt 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "👤 User Decisions Required"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "These items might be intentional customizations."
  echo "Please review each one:"
  echo ""

  for decision in "${USER_DECISIONS[@]}"; do
    case "$decision" in
      rename_archive_to_complete)
        echo "1. Directory name: .rptc/archive → .rptc/complete"
        echo "   Current: .rptc/archive"
        echo "   Standard: .rptc/complete"
        echo ""
        read -p "   Rename to standard name? [y/N]: " RENAME_CHOICE
        if [[ "$RENAME_CHOICE" =~ ^[Yy]$ ]]; then
          FIXES_TO_APPLY+=("mv:.rptc/archive:.rptc/complete")
        else
          echo "   ✓ Keeping .rptc/archive (your customization preserved)"
        fi
        echo ""
        ;;

      rename_archived_to_complete)
        echo "1. Directory name: .rptc/archived → .rptc/complete"
        echo "   Current: .rptc/archived"
        echo "   Standard: .rptc/complete"
        echo ""
        read -p "   Rename to standard name? [y/N]: " RENAME_CHOICE
        if [[ "$RENAME_CHOICE" =~ ^[Yy]$ ]]; then
          FIXES_TO_APPLY+=("mv:.rptc/archived:.rptc/complete")
        else
          echo "   ✓ Keeping .rptc/archived (your customization preserved)"
        fi
        echo ""
        ;;

      rename_done_to_complete)
        echo "1. Directory name: .rptc/done → .rptc/complete"
        echo "   Current: .rptc/done"
        echo "   Standard: .rptc/complete"
        echo ""
        read -p "   Rename to standard name? [y/N]: " RENAME_CHOICE
        if [[ "$RENAME_CHOICE" =~ ^[Yy]$ ]]; then
          FIXES_TO_APPLY+=("mv:.rptc/done:.rptc/complete")
        else
          echo "   ✓ Keeping .rptc/done (your customization preserved)"
        fi
        echo ""
        ;;

      create_rptc_claude_md)
        echo "2. Missing file: ${ARTIFACT_LOC}/CLAUDE.md"
        echo "   This file contains RPTC workflow instructions."
        echo "   It was either deleted or never created."
        echo ""
        read -p "   Create it now? [Y/n]: " CREATE_CHOICE
        if [[ ! "$CREATE_CHOICE" =~ ^[Nn]$ ]]; then
          FIXES_TO_APPLY+=("create:rptc_claude_md")
        else
          echo "   ✓ Skipped (you can create it later with /rptc:admin-init)"
        fi
        echo ""
        ;;

      add_gitignore_entries)
        echo "3. .gitignore missing Claude entries"
        echo "   Recommended entries:"
        echo "     .claude/settings.local.json"
        echo "     .claude/.env*"
        echo ""
        read -p "   Add these entries? [Y/n]: " GITIGNORE_CHOICE
        if [[ ! "$GITIGNORE_CHOICE" =~ ^[Nn]$ ]]; then
          FIXES_TO_APPLY+=("update:gitignore")
        else
          echo "   ✓ Skipped"
        fi
        echo ""
        ;;

      migrate_sop_location)
        echo "4. SOP location migration: .claude/sop/ → .rptc/sop/"
        echo "   In v1.1.0, the default SOP location changed."
        echo ""
        echo "   Options:"
        echo "     [m] Move .claude/sop/ → .rptc/sop/ (recommended)"
        echo "     [k] Keep .claude/sop/ and update config to use it"
        echo "     [s] Skip (handle manually)"
        echo ""
        read -p "   What would you like to do? [m/k/s]: " SOP_CHOICE

        case "$SOP_CHOICE" in
          m|M)
            if [ -d ".rptc/sop" ]; then
              echo "   ⚠️  .rptc/sop/ already exists. Please merge manually."
            else
              FIXES_TO_APPLY+=("mv:.claude/sop:.rptc/sop")
              echo "   ✓ Will move .claude/sop/ → .rptc/sop/"
            fi
            ;;
          k|K)
            FIXES_TO_APPLY+=("config:customSopPath:.claude/sop")
            echo "   ✓ Will update config to use .claude/sop/"
            ;;
          *)
            echo "   ✓ Skipped (handle manually)"
            ;;
        esac
        echo ""
        ;;
    esac
  done
fi
```

## Step 6: Create Backup

```bash
if [ ${#FIXES_TO_APPLY[@]} -gt 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 Creating Backup"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Backup settings.json
  cp .claude/settings.json .claude/settings.json.backup
  echo "✓ Backup created: .claude/settings.json.backup"
  echo ""
fi
```

## Step 7: Apply Fixes

```bash
if [ ${#FIXES_TO_APPLY[@]} -gt 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔧 Applying Fixes"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  for fix in "${FIXES_TO_APPLY[@]}"; do
    # Parse fix command
    FIX_TYPE="${fix%%:*}"
    FIX_ARGS="${fix#*:}"

    case "$FIX_TYPE" in
      mkdir)
        mkdir -p "$FIX_ARGS"
        echo "✓ Created directory: $FIX_ARGS"
        ;;

      mv)
        SRC="${FIX_ARGS%%:*}"
        DEST="${FIX_ARGS#*:}"
        mv "$SRC" "$DEST"
        echo "✓ Renamed: $SRC → $DEST"
        ;;

      create)
        if [ "$FIX_ARGS" = "rptc_claude_md" ]; then
          if [ -f "$PLUGIN_ROOT/docs/PROJECT_TEMPLATE.md" ]; then
            cp "$PLUGIN_ROOT/docs/PROJECT_TEMPLATE.md" "${ARTIFACT_LOC}/CLAUDE.md"
            echo "✓ Created: ${ARTIFACT_LOC}/CLAUDE.md"
          else
            echo "⚠️  Template not found, skipping ${ARTIFACT_LOC}/CLAUDE.md creation"
          fi
        fi
        ;;

      update)
        if [ "$FIX_ARGS" = "gitignore" ]; then
          if ! grep -q ".claude/settings.local.json" .gitignore; then
            echo "" >> .gitignore
            echo "# Claude settings" >> .gitignore
            echo ".claude/settings.local.json  # Local overrides" >> .gitignore
            echo ".claude/.env*               # Secrets" >> .gitignore
            echo "✓ Updated: .gitignore"
          fi
        fi
        ;;

      config)
        CONFIG_KEY="${FIX_ARGS%%:*}"
        CONFIG_VAL="${FIX_ARGS#*:}"
```

# Claude: Use Read tool to update JSON field
# Read(".claude/settings.json")
# Update: rptc.${CONFIG_KEY} = "${CONFIG_VAL}"
# Use Edit tool to write back the modified JSON (preserve structure)

```bash
        echo "✓ Updated config: $CONFIG_KEY = \"$CONFIG_VAL\""
        ;;

      add_missing_config_fields)
```

# Claude: Use Read tool to add missing config fields
# Read(".claude/settings.json")
# Add missing fields with these defaults (preserve existing values):
# - rptc._rptcVersion = "$PLUGIN_VERSION"
# - rptc.defaultThinkingMode = "think"
# - rptc.artifactLocation = ".rptc"
# - rptc.docsLocation = "docs"
# - rptc.testCoverageTarget = 85
# - rptc.maxPlanningAttempts = 10
# - rptc.customSopPath = ".rptc/sop"
# - rptc.qualityGatesEnabled = false
# - rptc.researchOutputFormat = "html"
# - rptc.htmlReportTheme = "dark"
# - rptc.verificationMode = "focused"
# - rptc.tdgMode = "disabled"
# - rptc.discord = {"webhookUrl": "", "notificationsEnabled": false, "verbosity": "summary"}
# Use Edit tool to write updated JSON back to file

```bash
        echo "✓ Added missing configuration fields"
        ;;

      update_version_only)
```

# Claude: Use Read tool to update version field
# Read(".claude/settings.json")
# Update: rptc._rptcVersion = "$PLUGIN_VERSION"
# Use Edit tool to write back the modified JSON (preserve structure)

```bash
        echo "✓ Updated version: v${WORKSPACE_VERSION} → v${PLUGIN_VERSION}"
        ;;
    esac
  done

  echo ""
fi
```

## Step 8: Final Summary

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Upgrade & Verification Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$WORKSPACE_VERSION" != "$PLUGIN_VERSION" ]; then
  echo "Version: v${WORKSPACE_VERSION} → v${PLUGIN_VERSION}"
else
  echo "Version: v${PLUGIN_VERSION} (verified)"
fi

echo ""

if [ ${#FIXES_TO_APPLY[@]} -gt 0 ]; then
  echo "Applied ${#FIXES_TO_APPLY[@]} fix(es)"
  echo "Backup: .claude/settings.json.backup"
  echo ""
fi

echo "Next steps:"
echo "  • Review configuration: /rptc:admin-config"
echo "  • Verify SOP paths: /rptc:admin-sop-check"
echo ""

if [ -f ".claude/settings.json.backup" ]; then
  echo "To rollback (if needed):"
  echo "  mv .claude/settings.json.backup .claude/settings.json"
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

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
