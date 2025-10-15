---
description: Upgrade workspace configuration when RPTC plugin is updated
---

# RPTC Admin: Upgrade Workspace

You are executing the **RPTC Workspace Upgrade** command.

## Purpose

Upgrade workspace configuration to match the installed plugin version, merging new configuration options while preserving user customizations.

## Step 1: Load Current Configuration

```bash
# Check if settings.json exists
if [ ! -f ".claude/settings.json" ]; then
  echo "❌ ERROR: No .claude/settings.json found"
  echo ""
  echo "This workspace hasn't been initialized."
  echo "Run: /rptc:admin-init"
  exit 1
fi

# Load current workspace version
if command -v jq >/dev/null 2>&1; then
  WORKSPACE_VERSION=$(jq -r '.rptc._rptcVersion // "1.0.0"' .claude/settings.json 2>/dev/null)
else
  # Fallback if jq not available
  if grep -q '"_rptcVersion"' .claude/settings.json; then
    WORKSPACE_VERSION=$(grep '_rptcVersion' .claude/settings.json | sed 's/.*: *"\([^"]*\)".*/\1/')
  else
    WORKSPACE_VERSION="1.0.0"
  fi
fi

# Plugin version (update this with each release)
PLUGIN_VERSION="1.1.1"
```

## Step 2: Check if Upgrade Needed

```bash
if [ "$WORKSPACE_VERSION" = "$PLUGIN_VERSION" ]; then
  echo "✅ Workspace is up to date (v${WORKSPACE_VERSION})"
  echo ""
  echo "No upgrade needed."
  exit 0
fi

echo "🔄 Upgrade Available"
echo ""
echo "Workspace version: v${WORKSPACE_VERSION}"
echo "Plugin version:    v${PLUGIN_VERSION}"
echo ""
```

## Step 3: Show What's New

Display changelog for versions between workspace and plugin:

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 What's New"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Show relevant changelogs based on version gap
case "$WORKSPACE_VERSION" in
  "1.0.0"|"1.0.1"|"1.0.2"|"1.0.3"|"1.0.4"|"1.0.5"|"1.0.6")
    echo "v1.0.7 (2025-10-14):"
    echo "  • Global thinking mode configuration"
    echo "  • Configure default thinking mode for sub-agents"
    echo "  • Extended thinking modes: think, think hard, ultrathink"
    echo ""
    ;&  # Fall through
  "1.0.7")
    echo "v1.0.8 (2025-10-15):"
    echo "  • Functional configuration system"
    echo "  • Customizable artifact location"
    echo "  • Customizable documentation location"
    echo "  • Configurable test coverage target"
    echo "  • Configurable max planning attempts"
    echo ""
    ;&  # Fall through
  "1.0.8")
    echo "v1.0.9 (2025-10-15):"
    echo "  • Version synchronization patch (no new features)"
    echo ""
    ;&  # Fall through
  "1.0.9")
    echo "v1.1.0 (2025-10-15):"
    echo "  • Version tracking system"
    echo "  • Automatic upgrade detection"
    echo "  • SOP path moved from .claude/sop to .rptc/sop"
    echo "  • New /rptc:admin-upgrade command"
    echo ""
    ;;
esac

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

## Step 4: Backup Current Settings

```bash
echo "📦 Creating backup..."
cp .claude/settings.json .claude/settings.json.backup
echo "✓ Backup created: .claude/settings.json.backup"
echo ""
```

## Step 5: Merge New Configuration Fields

```bash
echo "🔧 Merging new configuration..."
echo ""

if command -v jq >/dev/null 2>&1; then
  # Use jq for safe merging
  TEMP_FILE=$(mktemp)

  # Read current config
  CURRENT=$(cat .claude/settings.json)

  # Define defaults for all fields (will only add missing ones)
  jq '.rptc._rptcVersion = "1.1.0" |
      .rptc.defaultThinkingMode //= "think" |
      .rptc.artifactLocation //= ".rptc" |
      .rptc.docsLocation //= "docs" |
      .rptc.testCoverageTarget //= 85 |
      .rptc.maxPlanningAttempts //= 10 |
      .rptc.customSopPath //= ".rptc/sop"' \
    .claude/settings.json > "$TEMP_FILE"

  mv "$TEMP_FILE" .claude/settings.json

  echo "✓ Configuration merged successfully"

  # Show what was added
  echo ""
  echo "Updated fields:"

  # Check each field
  if ! echo "$CURRENT" | jq -e '.rptc._rptcVersion' >/dev/null 2>&1; then
    echo "  ✅ Added: _rptcVersion = \"1.1.0\""
  else
    echo "  ✅ Updated: _rptcVersion = \"1.1.0\""
  fi

  if ! echo "$CURRENT" | jq -e '.rptc.defaultThinkingMode' >/dev/null 2>&1; then
    echo "  ✅ Added: defaultThinkingMode = \"think\""
  fi

  if ! echo "$CURRENT" | jq -e '.rptc.artifactLocation' >/dev/null 2>&1; then
    echo "  ✅ Added: artifactLocation = \".rptc\""
  fi

  if ! echo "$CURRENT" | jq -e '.rptc.docsLocation' >/dev/null 2>&1; then
    echo "  ✅ Added: docsLocation = \"docs\""
  fi

  if ! echo "$CURRENT" | jq -e '.rptc.testCoverageTarget' >/dev/null 2>&1; then
    echo "  ✅ Added: testCoverageTarget = 85"
  fi

  if ! echo "$CURRENT" | jq -e '.rptc.maxPlanningAttempts' >/dev/null 2>&1; then
    echo "  ✅ Added: maxPlanningAttempts = 10"
  fi

  if ! echo "$CURRENT" | jq -e '.rptc.customSopPath' >/dev/null 2>&1; then
    echo "  ✅ Added: customSopPath = \".rptc/sop\""
  fi

else
  # jq not available - manual instructions
  echo "⚠️  jq not available for automatic merging"
  echo ""
  echo "Please manually update .claude/settings.json:"
  echo ""
  echo "  Add or update these fields in the \"rptc\" section:"
  echo '    "_rptcVersion": "1.1.1",'
  echo '    "defaultThinkingMode": "think"  (if missing),'
  echo '    "artifactLocation": ".rptc"  (if missing),'
  echo '    "docsLocation": "docs"  (if missing),'
  echo '    "testCoverageTarget": 85  (if missing),'
  echo '    "maxPlanningAttempts": 10  (if missing),'
  echo '    "customSopPath": ".rptc/sop"  (if missing)'
  echo ""
  echo "Tip: Install jq for automatic merging: https://jqlang.github.io/jq/"
  exit 1
fi

echo ""
```

## Step 6: Handle Version-Specific Migrations

```bash
# Migration logic for specific version transitions
case "$WORKSPACE_VERSION" in
  "1.0."*|"1.0.0"|"1.0.1"|"1.0.2"|"1.0.3"|"1.0.4"|"1.0.5"|"1.0.6"|"1.0.7"|"1.0.8"|"1.0.9")
    # Migrating from 1.0.x to 1.1.0
    echo "🔄 Applying v1.1.0 migrations..."
    echo ""

    # Check if .claude/sop exists and offer to migrate
    if [ -d ".claude/sop" ]; then
      echo "⚠️  Found .claude/sop/ directory"
      echo ""
      echo "In v1.1.0, the default SOP location changed to .rptc/sop/"
      echo ""
      echo "Options:"
      echo "  [m] Move .claude/sop/ → .rptc/sop/ (recommended)"
      echo "  [k] Keep .claude/sop/ and update customSopPath config"
      echo "  [s] Skip (I'll handle this manually)"
      echo ""
      read -p "What would you like to do? [m/k/s]: " SOP_CHOICE

      case "$SOP_CHOICE" in
        m|M)
          if [ -d ".rptc/sop" ]; then
            echo "⚠️  .rptc/sop/ already exists. Merge manually."
          else
            mv .claude/sop .rptc/sop
            echo "✅ Moved .claude/sop/ → .rptc/sop/"
          fi
          ;;
        k|K)
          # Update customSopPath to keep using .claude/sop
          jq '.rptc.customSopPath = ".claude/sop"' .claude/settings.json > .claude/settings.json.tmp
          mv .claude/settings.json.tmp .claude/settings.json
          echo "✅ Updated customSopPath to \".claude/sop\""
          ;;
        *)
          echo "ℹ️  Skipped SOP migration"
          ;;
      esac
      echo ""
    fi
    ;;
esac
```

## Step 7: Summary

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Workspace Upgraded Successfully"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Upgraded: v${WORKSPACE_VERSION} → v${PLUGIN_VERSION}"
echo ""
echo "Backup: .claude/settings.json.backup"
echo ""
echo "To review your configuration:"
echo "  /rptc:admin-config"
echo ""
echo "To verify SOP paths:"
echo "  /rptc:admin-sop-check"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

## Error Handling

- If workspace not initialized, direct user to `/rptc:admin-init`
- If jq not available, provide manual instructions
- Always create backup before making changes
- Handle edge cases (missing fields, malformed JSON)
- Provide rollback instructions if upgrade fails

## Notes

- **Non-destructive**: Always creates backup first
- **Preserves user values**: Only adds missing fields, doesn't overwrite
- **Version-aware**: Shows relevant changelogs only
- **Interactive**: Asks for confirmation on breaking changes
- **Idempotent**: Safe to run multiple times
