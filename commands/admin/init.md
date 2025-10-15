---
description: Initialize RPTC workflow workspace in current project
---

# RPTC Admin: Initialize Workspace

You are executing the **RPTC Workspace Initialization** command.

## Purpose

Set up the RPTC workflow structure in the user's project, creating necessary directories and optionally copying SOPs for customization.

## Arguments

Parse the user's input for options:

- `--copy-sops`: Copy SOPs from plugin to `.claude/sop/` for project-specific customization
- `--global`: Copy SOPs to `~/.claude/global/sop/` for user-wide defaults (requires `--copy-sops`)

## Step 1: Verify Current Directory

Check that we're in a valid project directory (not plugin directory itself):

```bash
# Check for indicators this is a real project
if [ -f "package.json" ] || [ -f "pyproject.toml" ] || [ -f "Cargo.toml" ] || [ -f "go.mod" ] || [ -d "src" ]; then
  echo "✓ Valid project directory detected"
else
  echo "⚠️  No project markers found. Are you in the correct directory?"
  echo "   Expected: package.json, pyproject.toml, Cargo.toml, go.mod, or src/"
  # Ask user to confirm
fi
```

## Step 2: Create Workspace Directories

Create the RPTC workspace structure:

```bash
# Working artifact directories
mkdir -p .rptc/research
mkdir -p .rptc/plans
mkdir -p .rptc/archive

# Documentation directory
mkdir -p docs/research
mkdir -p docs/plans
mkdir -p docs/architecture
mkdir -p docs/patterns
mkdir -p docs/api

echo "✓ Created workspace directories:"
echo "  .rptc/research/     - Active research findings"
echo "  .rptc/plans/        - Active implementation plans"
echo "  .rptc/archive/      - Archived work"
echo "  docs/               - Permanent documentation"
```

## Step 3: Locate Plugin Directory (CRITICAL)

Before copying files, we need to find where the RPTC plugin is installed:

```bash
# Find the plugin directory by searching for the unique plugin manifest
# Search in common Claude Code plugin installation locations
PLUGIN_ROOT=""

# Check user plugins directory
if [ -d "$HOME/.claude/plugins" ]; then
  FOUND=$(find "$HOME/.claude/plugins" -name "plugin.json" -path "*/.claude-plugin/plugin.json" 2>/dev/null | while read manifest; do
    if grep -q '"name".*"rptc-workflow"' "$manifest" 2>/dev/null; then
      dirname "$(dirname "$manifest")"
      break
    fi
  done | head -1)
  if [ -n "$FOUND" ]; then
    PLUGIN_ROOT="$FOUND"
  fi
fi

# If not found, check system plugins directory
if [ -z "$PLUGIN_ROOT" ] && [ -d "/opt/claude/plugins" ]; then
  FOUND=$(find "/opt/claude/plugins" -name "plugin.json" -path "*/.claude-plugin/plugin.json" 2>/dev/null | while read manifest; do
    if grep -q '"name".*"rptc-workflow"' "$manifest" 2>/dev/null; then
      dirname "$(dirname "$manifest")"
      break
    fi
  done | head -1)
  if [ -n "$FOUND" ]; then
    PLUGIN_ROOT="$FOUND"
  fi
fi

# If still not found, try alternative search in home directory
if [ -z "$PLUGIN_ROOT" ]; then
  FOUND=$(find "$HOME" -type f -name "plugin.json" -path "*rptc-workflow*/.claude-plugin/plugin.json" 2>/dev/null | while read manifest; do
    if grep -q '"name".*"rptc-workflow"' "$manifest" 2>/dev/null; then
      dirname "$(dirname "$manifest")"
      break
    fi
  done | head -1)
  if [ -n "$FOUND" ]; then
    PLUGIN_ROOT="$FOUND"
  fi
fi

if [ -z "$PLUGIN_ROOT" ]; then
  echo "❌ ERROR: Could not locate RPTC plugin installation directory"
  echo ""
  echo "Searched in:"
  echo "  - $HOME/.claude/plugins/"
  echo "  - /opt/claude/plugins/"
  echo "  - $HOME/**/rptc-workflow/"
  echo ""
  echo "Please ensure the rptc-workflow plugin is properly installed."
  echo "Try: /plugin install rptc-workflow"
  exit 1
fi

echo "✓ Found plugin at: $PLUGIN_ROOT"
```

## Step 4: Handle SOP Copying (If Requested)

### If `--copy-sops` was provided:

#### A. Copy to Project (Default)

If `--global` was NOT provided:

```bash
mkdir -p .claude/sop

# Verify SOPs exist
if [ ! -d "$PLUGIN_ROOT/sop" ]; then
  echo "❌ ERROR: SOPs directory not found at $PLUGIN_ROOT/sop"
  exit 1
fi

# Copy all SOPs from plugin
cp "$PLUGIN_ROOT/sop/"*.md .claude/sop/

echo "✓ Copied SOPs to .claude/sop/ for project-specific customization"
echo ""
echo "  Project SOPs will override plugin defaults:"
echo "  - testing-guide.md"
echo "  - architecture-patterns.md"
echo "  - frontend-guidelines.md"
echo "  - git-and-deployment.md"
echo "  - languages-and-style.md"
echo "  - security-and-performance.md"
echo ""
echo "  Edit these files to customize for this project."
```

#### B. Copy to User Global (If --global provided)

If `--global` was provided:

```bash
mkdir -p ~/.claude/global/sop

# Verify SOPs exist
if [ ! -d "$PLUGIN_ROOT/sop" ]; then
  echo "❌ ERROR: SOPs directory not found at $PLUGIN_ROOT/sop"
  exit 1
fi

# Copy all SOPs from plugin to user global
cp "$PLUGIN_ROOT/sop/"*.md ~/.claude/global/sop/

echo "✓ Copied SOPs to ~/.claude/global/sop/ as user defaults"
echo ""
echo "  These SOPs will be used across ALL your projects unless"
echo "  overridden by project-specific SOPs in .claude/sop/"
echo ""
echo "  Edit these files to set your personal coding standards."
```

### If `--copy-sops` was NOT provided:

```bash
echo "ℹ️  SOPs will be referenced from plugin (read-only)"
echo ""
echo "  Commands will use: $PLUGIN_ROOT/sop/"
echo ""
echo "  To customize SOPs for this project, run:"
echo "  /rptc:admin:init --copy-sops"
echo ""
echo "  To set personal defaults across all projects, run:"
echo "  /rptc:admin:init --copy-sops --global"
```

## Step 5: Create RPTC Workflow Instructions

Copy the RPTC workflow template to `.rptc/CLAUDE.md`:

```bash
if [ ! -f ".rptc/CLAUDE.md" ]; then
  # Verify template exists
  if [ ! -f "$PLUGIN_ROOT/docs/PROJECT_TEMPLATE.md" ]; then
    echo "❌ ERROR: Project template not found at $PLUGIN_ROOT/docs/PROJECT_TEMPLATE.md"
    exit 1
  fi

  # Copy RPTC workflow template
  cp "$PLUGIN_ROOT/docs/PROJECT_TEMPLATE.md" .rptc/CLAUDE.md

  echo "✓ Created .rptc/CLAUDE.md with RPTC workflow instructions"
  echo "  This file contains RPTC-specific guidance for this project"
  echo "  Your project's main CLAUDE.md (if any) remains separate"
else
  echo "ℹ️  .rptc/CLAUDE.md already exists, skipping"
fi
```

## Step 6: Add RPTC Reference to Root CLAUDE.md (If Exists)

If the user has a project root `CLAUDE.md`, automatically add a reference to `.rptc/CLAUDE.md`:

```bash
if [ -f "CLAUDE.md" ]; then
  # Check if RPTC reference already exists
  if ! grep -q "\.rptc/CLAUDE\.md" CLAUDE.md; then
    # Create temp file in project directory (not /tmp/)
    mkdir -p .rptc/.tmp

    cat > .rptc/.tmp/rptc_header.txt <<'EOF'
## IMPORTANT: RPTC Workflow

This project uses the RPTC (Research → Plan → TDD → Commit) workflow.

**See `.rptc/CLAUDE.md` for complete RPTC workflow instructions and commands.**

All development must follow the RPTC process defined in that file.

---

EOF

    # Prepend to existing CLAUDE.md (using project temp directory)
    cat .rptc/.tmp/rptc_header.txt CLAUDE.md > .rptc/.tmp/claude_updated.md
    mv .rptc/.tmp/claude_updated.md CLAUDE.md
    rm -rf .rptc/.tmp

    echo "✓ Added RPTC workflow reference to CLAUDE.md"
    echo "  Your existing CLAUDE.md content is preserved below the reference"
  else
    echo "ℹ️  RPTC reference already exists in CLAUDE.md"
  fi
else
  echo "ℹ️  No root CLAUDE.md found (optional)"
  echo "  RPTC workflow instructions are in .rptc/CLAUDE.md"
fi
```

## Step 7: Create/Update .claude/settings.json

Create or update `.claude/settings.json` with RPTC default configuration:

```bash
mkdir -p .claude

if [ ! -f ".claude/settings.json" ]; then
  # Create new settings.json with RPTC defaults
  cat > .claude/settings.json <<'EOF'
{
  "rptc": {
    "defaultThinkingMode": "think",
    "artifactLocation": ".rptc",
    "docsLocation": "docs",
    "testCoverageTarget": 85,
    "maxPlanningAttempts": 10,
    "customSopPath": ".claude/sop"
  }
}
EOF
  echo "✓ Created .claude/settings.json with RPTC defaults"
  echo "  Default thinking mode: \"think\" (~4K tokens)"
  echo "  Test coverage target: 85%"
  echo "  Artifact location: .rptc/"
  echo "  Documentation location: docs/"
else
  # File exists - check if it needs RPTC section
  if ! grep -q '"rptc"' .claude/settings.json; then
    # Settings file exists but no rptc section - add it
    # Check if jq is available for safe JSON merging
    if command -v jq >/dev/null 2>&1; then
      # Use jq for safe merging
      TEMP_FILE=$(mktemp)
      jq '. + {"rptc": {"defaultThinkingMode": "think", "artifactLocation": ".rptc", "docsLocation": "docs", "testCoverageTarget": 85, "maxPlanningAttempts": 10, "customSopPath": ".claude/sop"}}' .claude/settings.json > "$TEMP_FILE"
      mv "$TEMP_FILE" .claude/settings.json
      echo "✓ Added RPTC configuration to existing .claude/settings.json"
    else
      # jq not available - warn user to manually add
      echo "⚠️  .claude/settings.json exists but lacks RPTC config"
      echo ""
      echo "  Please add the following to your .claude/settings.json:"
      echo ""
      echo '  "rptc": {'
      echo '    "defaultThinkingMode": "think",'
      echo '    "artifactLocation": ".rptc",'
      echo '    "docsLocation": "docs",'
      echo '    "testCoverageTarget": 85,'
      echo '    "maxPlanningAttempts": 10,'
      echo '    "customSopPath": ".claude/sop"'
      echo '  }'
      echo ""
      echo "  (Install 'jq' for automatic merging in future)"
    fi
  else
    echo "ℹ️  .claude/settings.json already contains RPTC configuration"
  fi
fi
```

## Step 8: Update .gitignore

Add RPTC-specific gitignore entries if not already present:

```bash
if [ -f ".gitignore" ]; then
  if ! grep -q ".rptc/archive" .gitignore; then
    echo "" >> .gitignore
    echo "# RPTC workflow" >> .gitignore
    echo ".rptc/archive/          # Archived plans (optional)" >> .gitignore
    echo ".claude/settings.local.json  # Local overrides" >> .gitignore
    echo ".claude/.env*           # Secrets" >> .gitignore

    echo "✓ Updated .gitignore with RPTC entries"
  else
    echo "ℹ️  .gitignore already contains RPTC entries"
  fi
else
  echo "⚠️  No .gitignore found. Consider creating one."
fi
```

## Step 9: Create README Section (Optional Suggestion)

Suggest adding RPTC section to README:

```bash
echo ""
echo "💡 Suggestion: Add RPTC workflow documentation to your README.md"
echo ""
echo "   ## Development Workflow"
echo "   "
echo "   This project uses the RPTC workflow:"
echo "   - \`/rptc:research \"topic\"\` - Interactive discovery"
echo "   - \`/rptc:plan \"feature\"\` - Collaborative planning"
echo "   - \`/rptc:tdd \"@plan.md\"\` - TDD implementation"
echo "   - \`/rptc:commit [pr]\` - Verify and ship"
echo ""
```

## Step 10: Summary Report

Provide clear summary of what was created:

```bash
echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅ RPTC Workspace Initialized"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Structure created:"
echo "  .rptc/research/         - Active research"
echo "  .rptc/plans/            - Active plans"
echo "  .rptc/archive/          - Old work"
echo "  .rptc/CLAUDE.md         - RPTC workflow instructions"
echo "  .claude/settings.json   - RPTC configuration"
echo "  docs/                   - Permanent documentation"
echo ""
echo "SOP Configuration:"
if [ --copy-sops provided ]; then
  if [ --global provided ]; then
    echo "  ~/.claude/global/sop/   - User defaults (all projects)"
  else
    echo "  .claude/sop/            - Project-specific SOPs"
  fi
else
  echo "  Plugin SOPs (read-only) - $PLUGIN_ROOT/sop/"
fi
echo ""
echo "💡 Thinking Mode Configuration"
echo ""
echo "  Default thinking mode set to \"think\" (~4K tokens)"
echo "  Edit .claude/settings.json to change:"
echo ""
echo "  Available modes:"
echo "    - \"think\"       - Basic extended thinking (~4K tokens, default)"
echo "    - \"think hard\"  - Medium depth thinking (~10K tokens)"
echo "    - \"ultrathink\" - Maximum depth thinking (~32K tokens)"
echo ""
echo "  You can also specify thinking mode per-command when prompted."
echo "  User choice always overrides global setting."
echo ""
echo "Next Steps:"
echo "  1. Review .rptc/CLAUDE.md for RPTC workflow guidance"
echo "  2. Start your first workflow: /rptc:research \"your topic\""
echo "  3. Or jump to planning: /rptc:plan \"your feature\""
echo ""
echo "For help: See docs/RPTC_WORKFLOW_GUIDE.md"
echo "═══════════════════════════════════════════════════════"
```

## Important Notes

- **Do not create files in user's src/ directory** - only create .rptc/, docs/, and .claude/sop/ (if --copy-sops)
- **Preserve existing files** - never overwrite .rptc/CLAUDE.md if it exists
- **Separate concerns** - .rptc/CLAUDE.md is for RPTC workflow, project root CLAUDE.md is for general project instructions
- **Be explicit about SOP location** - clearly tell user where SOPs are coming from
- **Validate paths** - ensure $PLUGIN_ROOT resolves correctly before copying (use Step 3's search logic)

## Error Handling

If any step fails:

1. Report which step failed
2. Provide troubleshooting guidance
3. Do not abort entire initialization - complete what's possible
4. Suggest manual steps if automated approach fails
