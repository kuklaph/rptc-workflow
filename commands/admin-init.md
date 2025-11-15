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
  # Valid project detected - continue
  PROJECT_VALID=true
else
  PROJECT_VALID=false
fi
```

If `$PROJECT_VALID` is true:

✓ Valid project directory detected

If `$PROJECT_VALID` is false:

⚠️  No project markers found. Are you in the correct directory?
   Expected: package.json, pyproject.toml, Cargo.toml, go.mod, or src/

Ask user to confirm they want to proceed anyway.

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
```

✓ Created workspace directories:
  .rptc/research/     - Active research findings
  .rptc/plans/        - Active implementation plans
  .rptc/complete/     - Archived work
  .rptc/sop/          - Project-specific SOPs (optional)
  docs/               - Permanent documentation

## Step 3: Resolve Plugin Root

Use the CLAUDE_PLUGIN_ROOT environment variable (provided by Claude Code plugin system):

```bash
# Step 3: Resolve plugin root
if [ -z "${CLAUDE_PLUGIN_ROOT}" ]; then
  PLUGIN_ERROR=true
else
  PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
  PLUGIN_ERROR=false
fi
```

If `$PLUGIN_ERROR` is true:

❌ Error: CLAUDE_PLUGIN_ROOT not set. Plugin may not be installed correctly.

**STOP EXECUTION** - Cannot proceed without plugin root.

If `$PLUGIN_ERROR` is false:

✓ Found plugin at: $PLUGIN_ROOT

## Step 4: Handle SOP Copying (If Requested)

### If `--copy-sops` was provided:

#### A. Copy to Project (Default)

If `--global` was NOT provided:

```bash
# Verify SOPs exist
if [ ! -d "$PLUGIN_ROOT/sop" ]; then
  SOP_ERROR=true
else
  # Copy all SOPs from plugin (.rptc/sop/ already created in Step 2)
  cp "$PLUGIN_ROOT/sop/"*.md .rptc/sop/
  SOP_ERROR=false
fi
```

If `$SOP_ERROR` is true:

❌ ERROR: SOPs directory not found at $PLUGIN_ROOT/sop

**STOP EXECUTION** - Cannot proceed without SOPs.

If `$SOP_ERROR` is false:

✓ Copied SOPs to .rptc/sop/ for project-specific customization

#### B. Copy to User Global (If --global provided)

If `--global` was provided:

```bash
mkdir -p ~/.claude/global/sop

# Verify SOPs exist
if [ ! -d "$PLUGIN_ROOT/sop" ]; then
  GLOBAL_SOP_ERROR=true
else
  # Copy all SOPs from plugin to user global
  cp "$PLUGIN_ROOT/sop/"*.md ~/.claude/global/sop/
  GLOBAL_SOP_ERROR=false
fi
```

If `$GLOBAL_SOP_ERROR` is true:

❌ ERROR: SOPs directory not found at $PLUGIN_ROOT/sop

**STOP EXECUTION** - Cannot proceed without SOPs.

If `$GLOBAL_SOP_ERROR` is false:

✓ Copied SOPs to ~/.claude/global/sop/ as user defaults

## Step 5: Create RPTC Workflow Instructions

Copy the RPTC workflow template to `.rptc/CLAUDE.md`:

```bash
if [ ! -f ".rptc/CLAUDE.md" ]; then
  # Verify template exists
  if [ ! -f "$PLUGIN_ROOT/docs/PROJECT_TEMPLATE.md" ]; then
    TEMPLATE_ERROR=true
  else
    # Copy RPTC workflow template
    cp "$PLUGIN_ROOT/docs/PROJECT_TEMPLATE.md" .rptc/CLAUDE.md
    TEMPLATE_ERROR=false
    TEMPLATE_CREATED=true
  fi
else
  TEMPLATE_CREATED=false
fi
```

If `$TEMPLATE_ERROR` is true:

❌ ERROR: Project template not found at $PLUGIN_ROOT/docs/PROJECT_TEMPLATE.md

**STOP EXECUTION** - Cannot proceed without template.

If `$TEMPLATE_CREATED` is true:

✓ Created .rptc/CLAUDE.md with RPTC workflow instructions
  This file contains RPTC-specific guidance for this project
  Your project's main CLAUDE.md (if any) remains separate

If `$TEMPLATE_CREATED` is false:

ℹ️  .rptc/CLAUDE.md already exists, skipping

## Step 6: Add RPTC Reference to Root CLAUDE.md (If Exists)

If the user has a project root `CLAUDE.md`, automatically add a reference to `.rptc/CLAUDE.md`:

Check if root CLAUDE.md exists:

```bash
if [ -f "CLAUDE.md" ]; then
  ROOT_CLAUDE_EXISTS=true
else
  ROOT_CLAUDE_EXISTS=false
fi
```

If `$ROOT_CLAUDE_EXISTS` is true:

**Check if RPTC reference already exists:**

Use Read tool to check for pattern:

```
Read(file_path: "CLAUDE.md")
```

Search the content for pattern: `.rptc/CLAUDE.md`

If pattern **NOT found**:

**Add RPTC reference to CLAUDE.md:**

```markdown
# Create temp directory
mkdir -p .rptc/.tmp

# Create RPTC header content
Use Write tool to create .rptc/.tmp/rptc_header.txt:

Content:
## IMPORTANT: RPTC Workflow

This project uses the RPTC (Research → Plan → TDD → Commit) workflow.

**See `.rptc/CLAUDE.md` for complete RPTC workflow instructions and commands.**

All development must follow the RPTC process defined in that file.

---


# Prepend to existing CLAUDE.md
Use Read tool to read existing CLAUDE.md
Concatenate: rptc_header.txt content + existing CLAUDE.md content
Use Write tool to write concatenated content to CLAUDE.md

# Cleanup temp directory
rm -rf .rptc/.tmp
```

✓ Added RPTC workflow reference to CLAUDE.md
  Your existing CLAUDE.md content is preserved below the reference

If pattern **found**:

ℹ️  RPTC reference already exists in CLAUDE.md

If `$ROOT_CLAUDE_EXISTS` is false:

ℹ️  No root CLAUDE.md found (optional)
  RPTC workflow instructions are in .rptc/CLAUDE.md

## Step 7: Create/Update .claude/settings.json

Create or update `.claude/settings.json` with RPTC default configuration:

```markdown
mkdir -p .claude

# Check if settings.json exists using Glob or Read with error handling
Use Glob tool: Glob(pattern: ".claude/settings.json")

If file does NOT exist:
  # Create new settings.json with RPTC defaults
  Use Write tool to create .claude/settings.json:

  Content:
  {
    "rptc": {
      "_rptcVersion": "2.4.3",
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
      "discord": {
        "webhookUrl": "",
        "notificationsEnabled": false,
        "verbosity": "summary"
      }
    }
  }

  SETTINGS_CREATED=true

If file EXISTS:
  SETTINGS_CREATED=false
  SETTINGS_EXISTS=true
fi
```

If `$SETTINGS_CREATED` is true:

✓ Created .claude/settings.json with RPTC defaults

  View configuration: /rptc:admin-config
  Edit: .claude/settings.json

If `$SETTINGS_EXISTS` is true:

**Check if RPTC configuration exists:**

Use Read tool to check:

```
Read(file_path: ".claude/settings.json")
```

Search the content for pattern: `"rptc"`

If pattern **NOT found**:

Merging RPTC configuration into existing .claude/settings.json...

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
  "_rptcVersion": "2.4.3",
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
  "discord": {
    "webhookUrl": "",
    "notificationsEnabled": false,
    "verbosity": "summary"
  }
}
```

**After successful edit**: Confirm with "✓ Added RPTC configuration to existing .claude/settings.json"

If pattern **found**:

ℹ️  .claude/settings.json already contains RPTC configuration

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
  GITIGNORE_EXISTS=true
else
  GITIGNORE_EXISTS=false
fi
```

If `$GITIGNORE_EXISTS` is true:

**Check if Claude settings entries exist:**

Use Read tool to check:

```
Read(file_path: ".gitignore")
```

Search content for pattern: `.claude/settings.local.json`

If pattern **NOT found**:

Use Edit tool to append Claude settings entries:

```
Edit(file_path: ".gitignore",
     old_string: [end of file content],
     new_string: "\n\n# Claude settings\n.claude/settings.local.json  # Local overrides\n.claude/.env*           # Secrets\n")
```

✓ Updated .gitignore with Claude settings entries

If pattern **found**:

ℹ️  .gitignore already contains Claude settings entries

If `$GITIGNORE_EXISTS` is false:

⚠️  No .gitignore found. Consider creating one.

## Step 9: Create README Section (Optional Suggestion)

Suggest adding RPTC section to README:

💡 Suggestion: Add RPTC workflow documentation to your README.md

   ## Development Workflow

   This project uses the RPTC workflow:
   - `/rptc:research "topic"` - Interactive discovery
   - `/rptc:plan "feature"` - Collaborative planning
   - `/rptc:tdd "@plan/"` - TDD implementation
   - `/rptc:commit [pr]` - Verify and ship

## Step 10: Summary Report

Provide clear summary of what was created:

════════════════════════════════════════════════════════
  RPTC WORKSPACE INITIALIZED
════════════════════════════════════════════════════════

✓ Workspace structure created
✓ Configuration saved (.claude/settings.json)
✓ Project instructions installed (.rptc/CLAUDE.md)

Next steps:
  • Review instructions: cat .rptc/CLAUDE.md
  • View configuration: /rptc:admin-config
  • Start research: /rptc:research "topic"
  • Get help: /rptc --help

Workspace ready! 🚀
════════════════════════════════════════════════════════

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
