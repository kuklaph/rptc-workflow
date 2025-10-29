---
description: Initialize RPTC workflow workspace in current project
---

# RPTC Admin: Initialize Workspace

You are executing the **RPTC Workspace Initialization** command.

## Purpose

Set up the RPTC workflow structure in the user's project, creating necessary directories and optionally copying SOPs for customization.

## Arguments

Parse the user's input for options:

- `--copy-sops`: Copy SOPs from plugin to `.rptc/sop/` for project-specific customization
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
mkdir -p .rptc/complete
mkdir -p .rptc/sop

# Documentation directory
mkdir -p docs/research
mkdir -p docs/plans
mkdir -p docs/architecture
mkdir -p docs/patterns
mkdir -p docs/api

echo "✓ Created workspace directories:"
echo "  .rptc/research/     - Active research findings"
echo "  .rptc/plans/        - Active implementation plans"
echo "  .rptc/complete/     - Archived work"
echo "  .rptc/sop/          - Project-specific SOPs (optional)"
echo "  docs/               - Permanent documentation"
```

## Step 3: Resolve Plugin Root

Use the CLAUDE_PLUGIN_ROOT environment variable (provided by Claude Code plugin system):

```bash
# Step 3: Resolve plugin root
if [ -z "${CLAUDE_PLUGIN_ROOT}" ]; then
  echo "❌ Error: CLAUDE_PLUGIN_ROOT not set. Plugin may not be installed correctly."
  exit 1
fi
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"

echo "✓ Found plugin at: $PLUGIN_ROOT"
```

## Step 4: Handle SOP Copying (If Requested)

### If `--copy-sops` was provided:

#### A. Copy to Project (Default)

If `--global` was NOT provided:

```bash
# Verify SOPs exist
if [ ! -d "$PLUGIN_ROOT/sop" ]; then
  echo "❌ ERROR: SOPs directory not found at $PLUGIN_ROOT/sop"
  exit 1
fi

# Copy all SOPs from plugin (.rptc/sop/ already created in Step 2)
cp "$PLUGIN_ROOT/sop/"*.md .rptc/sop/

echo "✓ Copied SOPs to .rptc/sop/ for project-specific customization"
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
    "_rptcVersion": "2.2.2",
    "defaultThinkingMode": "think",
    "artifactLocation": ".rptc",
    "docsLocation": "docs",
    "testCoverageTarget": 85,
    "maxPlanningAttempts": 10,
    "customSopPath": ".rptc/sop",
    "researchOutputFormat": "html",
    "htmlReportTheme": "dark",
    "verificationMode": "focused",
    "tdgMode": "disabled",
    "qualityGatesEnabled": false,
    "discord": {
      "webhookUrl": "",
      "notificationsEnabled": false,
      "verbosity": "summary"
    }
  }
}
EOF
  echo "✓ Created .claude/settings.json with RPTC defaults"
  echo ""
  echo "  View configuration: /rptc:admin-config"
  echo "  Edit: .claude/settings.json"
  echo ""
else
  # File exists - check if it needs RPTC section
  if ! grep -q '"rptc"' .claude/settings.json; then
    # Settings file exists but no rptc section - merge using Edit tool
    echo "Merging RPTC configuration into existing .claude/settings.json..."

    cat <<'MERGE_INSTRUCTION'

**Action Required**: Use the Edit tool to add RPTC configuration:

1. **Read** `.claude/settings.json` to understand existing structure
2. **Use Edit tool** to add the rptc section as a new top-level key:
   - Preserve all existing fields
   - Add comma after last existing field if needed
   - Insert before closing brace
3. **Verify** JSON remains valid after edit

**RPTC configuration to add:**

```json
"rptc": {
  "_rptcVersion": "2.2.2",
  "defaultThinkingMode": "think",
  "artifactLocation": ".rptc",
  "docsLocation": "docs",
  "testCoverageTarget": 85,
  "maxPlanningAttempts": 10,
  "customSopPath": ".rptc/sop",
  "researchOutputFormat": "html",
  "htmlReportTheme": "dark",
  "verificationMode": "focused",
  "tdgMode": "disabled",
  "qualityGatesEnabled": false,
  "discord": {
    "webhookUrl": "",
    "notificationsEnabled": false,
    "verbosity": "summary"
  }
}
```

**After successful edit**: Confirm with "✓ Added RPTC configuration to existing .claude/settings.json"

MERGE_INSTRUCTION
  else
    echo "ℹ️  .claude/settings.json already contains RPTC configuration"
  fi
fi
```

## Step 8: Update .gitignore

<!--
BASH USAGE CRITERIA (Developer Reference)

**When to KEEP bash:**
- Git operations: `git status`, `git add`, `git commit` (subprocess coordination)
- Simple file operations: `mkdir`, `cp`, `rm` (reliable, cross-platform)
- Directory/file checks: `if [ -d dir ]`, `if [ -f file ]` (simple conditionals)
- Version extraction in maintainer scripts: `grep/awk` for version parsing

**When to REPLACE with native tools:**
- File content reading: Use Read tool (not `cat`/`head`/`tail`)
- File searching: Use Glob tool (not `find`)
- Content searching: Use Grep tool (not `grep -l`)
- JSON parsing: Use Read + Claude parsing (not `jq`)
- File introspection: Use Read tool (not `stat`)
- Complex pipelines: Use native tools (not `cat|grep|awk|head`)

**Rationale:** Native tools provide better error handling, cross-platform compatibility
(Windows), and context efficiency. Bash appropriate for subprocess coordination and
simple shell operations where Claude native tools don't apply.

Research reference: .rptc/research/bash-removal-native-tools.md
-->

Add Claude settings gitignore entries if not already present:

```bash
if [ -f ".gitignore" ]; then
  # Claude: Use Read + Edit tools to append .gitignore entries
  # 1. Read(".gitignore") → check if ".claude/settings.local.json" exists
  # 2. If NOT found:
  #    Edit(file_path: ".gitignore",
  #         old_string: [end of file],
  #         new_string: "\n\n# Claude settings\n.claude/settings.local.json  # Local overrides\n.claude/.env*           # Secrets\n")
  #    echo "✓ Updated .gitignore with Claude settings entries"
  # 3. If found:
  #    echo "ℹ️  .gitignore already contains Claude settings entries"
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
echo "   - \`/rptc:tdd \"@plan/\"\` - TDD implementation"
echo "   - \`/rptc:commit [pr]\` - Verify and ship"
echo ""
```

## Step 10: Summary Report

Provide clear summary of what was created:

```bash
echo ""
echo "════════════════════════════════════════════════════════"
echo "  RPTC WORKSPACE INITIALIZED"
echo "════════════════════════════════════════════════════════"
echo ""
echo "✓ Workspace structure created"
echo "✓ Configuration saved (.claude/settings.json)"
echo "✓ Project instructions installed (.rptc/CLAUDE.md)"
echo ""
echo "Next steps:"
echo "  • Review instructions: cat .rptc/CLAUDE.md"
echo "  • View configuration: /rptc:admin-config"
echo "  • Start research: /rptc:research \"topic\""
echo "  • Get help: /rptc --help"
echo ""
echo "Workspace ready! 🚀"
echo "════════════════════════════════════════════════════════"
```

## Important Notes

- **Do not create files in user's src/ directory** - only create .rptc/, docs/, and .rptc/sop/ (if --copy-sops)
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
