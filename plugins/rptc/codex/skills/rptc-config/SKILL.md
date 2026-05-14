---
name: rptc-config
description: Configure RPTC workflow in project AGENTS.md - sync with current version. Use when the user asks for /rptc:config or the equivalent RPTC Codex workflow intent.
---

# RPTC Config
Configure and maintain RPTC workflow settings in your project's AGENTS.md.

**Arguments**: None

**Use when**:
- First time setting up RPTC in a project
- After updating RPTC plugin to sync configuration
- To verify project is properly configured

---

## Phase 1: Detect Current State

**Goal**: Understand what exists and what needs to be done.

**Actions**:

1. **Get current RPTC version** from plugin metadata:
   - Read `RPTC plugin root/.codex-plugin/plugin.json`
   - Extract `version` field (e.g., "2.25.6")

2. **Check for project AGENTS.md**:
   - Look for `AGENTS.md` in current working directory (project root)
   - Note: This is the PROJECT's AGENTS.md, not the RPTC plugin's

3. **Determine action needed**:

   | State | Action |
   |-------|--------|
   | No AGENTS.md | Create with RPTC section |
   | AGENTS.md exists, no RPTC section | Append RPTC section |
   | AGENTS.md exists, RPTC section present | Check version, update if outdated |
   | AGENTS.md exists, RPTC section current | Report "already up to date" |

4. **Detect RPTC section** by searching for marker:
   ```
   <!-- RPTC-START v
   ```
   If found, extract version number from the marker line.

5. **Scan for legacy/orphaned RPTC content** (content without proper markers):

   Search patterns to detect legacy content:
   - `## RPTC` or `### RPTC` headers without markers nearby
   - `rptc:rptc-feat` or `rptc:rptc-fix` skill references outside marked section
   - `rptc:research-agent` or `rptc:tdd-agent` mentions outside marked section
   - `verification-agent-mode:` outside marked section
   - Duplicate `<!-- RPTC-START` markers (multiple sections)

   If legacy content detected, set `legacy_cleanup_needed = true`.

---

## Phase 2: User Preferences (New Installs Only)

**Goal**: Gather user preferences before generating configuration.

**Skip this phase if**: Updating an existing RPTC section (preserve existing settings).

**Actions**:

1. **Ask user for verification mode preference** using request_user_input:

   ```json
   {
     "questions": [{
       "id": "verification_mode",
       "header": "Verification",
       "question": "Which verification mode would you like for Phase 4 quality verification?",
       "options": [
         {"label": "Automatic (Recommended)", "description": "Smart selection based on file types and change patterns. Launches relevant agents only."},
         {"label": "All", "description": "Always launch all 3 verification agents (code-review, security, docs) regardless of changes."},
         {"label": "Minimal", "description": "Only launch agents when strongly indicated (>50 lines changed or security keywords)."}
       ]
     }]
   }
   ```

2. **Map selection to config value**:
   - "Automatic (Recommended)" → `automatic`
   - "All" → `all`
   - "Minimal" → `minimal`

---

## Phase 3: Generate Configuration

**Goal**: Build the RPTC configuration block with user's selected verification mode.

**Configuration Template**:

```markdown
<!-- RPTC-START v{VERSION} -->
## RPTC Workflow Configuration

**RPTC Version**: {VERSION} | [Documentation](https://github.com/kuklaph/rptc-workflow)

### Quick Reference

| Skill | Purpose |
|---------|---------|
| `rptc:rptc-feat "description"` | Full workflow: Research → Plan → TDD → Verify |
| `rptc:rptc-fix "bug description"` | Bug fixing: Reproduce → Root Cause → Fix → Verify |
| `rptc:rptc-research "topic"` | Standalone research and exploration |
| `rptc:rptc-commit [pr]` | Verify quality gates and ship (add `pr` for pull request) |
| `rptc:rptc-verify [path]` | Run quality verification agents on demand |
| `rptc:rptc-sync-prod-to-tests "dir"` | Sync tests to match production code |
| `rptc:rptc-config` | Initialize or update this configuration |

### Verification Configuration

verification-agent-mode: {VERIFICATION_MODE}

<!--
Verification mode options:
- automatic: Smart selection based on file types and change patterns
- all: Always launch all 3 verification agents (code-review, security, docs)
- minimal: Only launch when strongly indicated (>50 lines or keywords)
-->

### Project-Specific Notes

<!-- Add any project-specific RPTC notes here -->

<!-- RPTC-END -->
```

**Replace placeholders:**
- `{VERSION}` → actual version from plugin.json
- `{VERIFICATION_MODE}` → user's selection from Phase 2 (or preserved value for updates)

---

## Phase 4: Apply Configuration

**Goal**: Update or create AGENTS.md with the configuration.

### Case A: No AGENTS.md exists

1. **Create new AGENTS.md** with RPTC section prominently at top:
   ```markdown
   # AGENTS.md

   {RPTC_CONFIGURATION_BLOCK}

   ---

   ## Project-Specific Instructions

   <!-- Add your project-specific Codex instructions here -->
   ```

2. **Inform user**:
   ```
   Created AGENTS.md with RPTC v{VERSION} configuration at top.

   You can customize:
   - verification-agent-mode (automatic/all/minimal)
   - Project-specific notes section within RPTC block
   - Add project instructions below the RPTC section
   ```

### Case B: AGENTS.md exists, no RPTC section

1. **Insert RPTC section near the TOP** (after main heading):
   - Look for the first `# ` heading in the file
   - Insert RPTC section immediately after that heading (and any tagline/description on the next line)
   - If no heading found, insert at the very top

   ```markdown
   # Existing Title

   {RPTC_CONFIGURATION_BLOCK}

   ---

   [Rest of existing AGENTS.md content]
   ```

2. **Inform user**:
   ```
   Added RPTC v{VERSION} configuration to existing AGENTS.md (near top, after title).
   ```

### Case C: AGENTS.md exists, RPTC section outdated

1. **Find and replace** the entire section:
   - Start marker: `<!-- RPTC-START v`
   - End marker: `<!-- RPTC-END -->`
   - Replace everything between (inclusive) with new configuration

2. **Preserve verification-agent-mode** if user has customized it:
   - Before replacing, extract current `verification-agent-mode:` value
   - After generating new block, restore the user's setting

3. **Preserve project-specific notes**:
   - Extract content between `### Project-Specific Notes` and `<!-- RPTC-END -->`
   - Restore in new block

4. **Inform user**:
   ```
   Updated RPTC configuration from v{OLD} to v{NEW}.

   Changes in this version:
   - [List key changes from CHANGELOG if significant]
   ```

### Case D: AGENTS.md exists, RPTC section current

1. **No changes needed**

2. **Inform user**:
   ```
   RPTC v{VERSION} configuration is already up to date.

   Current settings:
   - verification-agent-mode: {current_mode}
   ```

### Case E: Legacy/orphaned RPTC content detected

**Applies to**: Any case where `legacy_cleanup_needed = true` from Phase 1 scan.

1. **Show user what was found**:
   ```
   ⚠️  Legacy RPTC content detected outside the marked configuration section:

   - Line 45: "## RPTC Workflow" (unmarked header)
   - Line 78-82: Command reference table (duplicate)
   - Line 120: "verification-agent-mode: all" (orphaned setting)
   ```

2. **Ask user for cleanup preference** using request_user_input:
   ```json
   {
     "questions": [{
       "id": "legacy_cleanup",
       "header": "Cleanup",
       "question": "How should I handle the legacy RPTC content?",
       "options": [
         {"label": "Remove legacy content (Recommended)", "description": "Delete orphaned RPTC references. The marked section contains all needed configuration."},
         {"label": "Keep legacy content", "description": "Leave orphaned content in place. May cause confusion with duplicate settings."},
         {"label": "Show me the content first", "description": "Display the legacy content so I can decide what to do."}
       ]
     }]
   }
   ```

3. **If "Remove legacy content" selected**:
   - Remove identified legacy sections/lines
   - Preserve any non-RPTC content around them
   - Report what was removed

4. **If "Show me the content first" selected**:
   - Display each legacy section with surrounding context
   - Re-prompt for cleanup decision

5. **Inform user**:
   ```
   ✓ Cleaned up legacy RPTC content:
   - Removed unmarked "## RPTC Workflow" section (lines 45-72)
   - Removed duplicate command table (lines 78-82)
   - Removed orphaned setting (line 120)

   All RPTC configuration is now in the marked section at the top.
   ```

---

## Phase 5: Verify Setup

**Goal**: Confirm configuration is valid and complete.

**Actions**:

1. **Read back AGENTS.md** to verify markers are present
2. **Check for required sections**:
   - [ ] RPTC version marker present
   - [ ] Quick reference table present
   - [ ] Tool prioritization section present
   - [ ] Verification configuration present

3. **Report status**:

```markdown
## RPTC Setup Complete

**Project**: {project_name}
**RPTC Version**: {version}
**Status**: ✓ Configured

### Configuration
- Verification Mode: {verification_agent_mode}
- AGENTS.md Location: ./AGENTS.md

### Next Steps
1. Customize `verification-agent-mode` if needed (automatic/all/minimal)
2. Add project-specific notes to the configuration section
3. Start developing with `rptc:rptc-feat "your feature"`
```

---

## Error Handling

| Error | Resolution |
|-------|------------|
| Cannot read plugin.json | Report error, use "unknown" as version |
| Cannot write AGENTS.md | Check permissions, report error |
| Malformed existing RPTC section | Backup existing, replace entirely |
| Markers corrupted | Remove partial markers, insert fresh section |
| Legacy content without markers | Prompt user for cleanup (Case E) |
| Multiple RPTC sections | Keep first marked section, flag others as legacy |
| Orphaned settings outside markers | Include in legacy cleanup prompt |

---

## Examples

### First-time setup
```
User: `rptc:rptc-config`

Codex: Checking RPTC configuration...

No AGENTS.md found in project root.
Creating AGENTS.md with RPTC v2.25.6 configuration...

✓ Created ./AGENTS.md

Configuration:
- verification-agent-mode: automatic (default)

Next steps:
1. Review and customize the configuration
2. Start developing with `rptc:rptc-feat` "your feature"
```

### Update existing
```
User: `rptc:rptc-config`

Codex: Checking RPTC configuration...

Found AGENTS.md with RPTC v2.24.0 configuration.
Current RPTC version: v2.25.6

Updating configuration...
- Preserved verification-agent-mode: all
- Preserved project-specific notes

✓ Updated RPTC configuration to v2.25.6

Key changes in this update:
- Added Tier 4 nits to code review
- Mandatory Phase 4 quality verification gate
```

### Already current
```
User: `rptc:rptc-config`

Codex: Checking RPTC configuration...

✓ RPTC v2.25.6 configuration is already up to date.

Current settings:
- verification-agent-mode: automatic
```

---

## Key Principles

1. **Preserve user customizations**: Never overwrite `verification-agent-mode` or project-specific notes
2. **Non-destructive updates**: Only modify the RPTC section, leave rest of AGENTS.md untouched
3. **Graceful degradation**: If plugin.json unreadable, use "unknown" version and warn user
4. **Always report status**: Show current configuration after every run
5. **Idempotent operation**: Running multiple times is safe, produces same result
