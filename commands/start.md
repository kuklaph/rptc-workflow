---
description: Initialize or update RPTC workflow configuration in project CLAUDE.md
allowed-tools: Read, Write, Edit, Glob, Grep
---

# /rptc:start

Initialize RPTC workflow for a project or sync configuration to latest version.

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
   - Read `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`
   - Extract `version` field (e.g., "2.25.6")

2. **Check for project CLAUDE.md**:
   - Look for `CLAUDE.md` in current working directory (project root)
   - Note: This is the PROJECT's CLAUDE.md, not the RPTC plugin's

3. **Determine action needed**:

   | State | Action |
   |-------|--------|
   | No CLAUDE.md | Create with RPTC section |
   | CLAUDE.md exists, no RPTC section | Append RPTC section |
   | CLAUDE.md exists, RPTC section present | Check version, update if outdated |
   | CLAUDE.md exists, RPTC section current | Report "already up to date" |

4. **Detect RPTC section** by searching for marker:
   ```
   <!-- RPTC-START v
   ```
   If found, extract version number from the marker line.

---

## Phase 2: Generate Configuration

**Goal**: Build the RPTC configuration block.

**Configuration Template**:

```markdown
<!-- RPTC-START v{VERSION} -->
## RPTC Workflow Configuration

**RPTC Version**: {VERSION} | [Documentation](https://github.com/kuklaph/rptc-workflow)

### Quick Reference

| Command | Purpose |
|---------|---------|
| `/rptc:feat "description"` | Full workflow: Research → Plan → TDD → Review |
| `/rptc:fix "bug description"` | Bug fixing: Reproduce → Root Cause → Fix → Verify |
| `/rptc:research "topic"` | Standalone research and exploration |
| `/rptc:commit [pr]` | Verify quality gates and ship (add `pr` for pull request) |
| `/rptc:sync-prod-to-tests "dir"` | Sync tests to match production code |
| `/rptc:start` | Initialize or update this configuration |

### Workflow Overview

    /rptc:feat "Add user authentication"
        │
        ├─► Phase 1: Discovery (parallel research agents)
        ├─► Phase 2: Architecture (3 perspectives, user chooses)
        ├─► Phase 3: Implementation (TDD with smart batching)
        ├─► Phase 4: Quality Review (parallel review agents)
        └─► Phase 5: Complete → /rptc:commit

### Tool Prioritization

**Serena MCP** (when available, prefer over native tools):
- `get_symbols_overview` → Find functions/classes (instead of Grep)
- `find_symbol` → Locate specific code (instead of Glob)
- `find_referencing_symbols` → Find usages/callers (instead of Grep)
- `search_for_pattern` → Regex search across codebase

**Sequential Thinking MCP** (STRONGLY RECOMMENDED):
- Use for ALL non-trivial tasks: analysis, planning, debugging, multi-step work
- Skip only for: single-line fixes, typo corrections, trivial changes

### Review Configuration

review-agent-mode: automatic

<!--
Review mode options:
- automatic: Smart selection based on file types and change patterns (default)
- all: Always launch all 3 review agents (code-review, security, docs)
- minimal: Only launch when strongly indicated (>50 lines or keywords)
-->

### Project-Specific Notes

<!-- Add any project-specific RPTC notes here -->

<!-- RPTC-END -->
```

**Replace `{VERSION}` with actual version from plugin.json.**

---

## Phase 3: Apply Configuration

**Goal**: Update or create CLAUDE.md with the configuration.

### Case A: No CLAUDE.md exists

1. **Create new CLAUDE.md** with:
   ```markdown
   # CLAUDE.md

   Project-specific instructions for Claude Code.

   ---

   {RPTC_CONFIGURATION_BLOCK}
   ```

2. **Inform user**:
   ```
   Created CLAUDE.md with RPTC v{VERSION} configuration.

   You can customize:
   - review-agent-mode (automatic/all/minimal)
   - Project-specific notes section
   ```

### Case B: CLAUDE.md exists, no RPTC section

1. **Append RPTC section** to end of file:
   ```markdown

   ---

   {RPTC_CONFIGURATION_BLOCK}
   ```

2. **Inform user**:
   ```
   Added RPTC v{VERSION} configuration to existing CLAUDE.md.
   ```

### Case C: CLAUDE.md exists, RPTC section outdated

1. **Find and replace** the entire section:
   - Start marker: `<!-- RPTC-START v`
   - End marker: `<!-- RPTC-END -->`
   - Replace everything between (inclusive) with new configuration

2. **Preserve review-agent-mode** if user has customized it:
   - Before replacing, extract current `review-agent-mode:` value
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

### Case D: CLAUDE.md exists, RPTC section current

1. **No changes needed**

2. **Inform user**:
   ```
   RPTC v{VERSION} configuration is already up to date.

   Current settings:
   - review-agent-mode: {current_mode}
   ```

---

## Phase 4: Verify Setup

**Goal**: Confirm configuration is valid and complete.

**Actions**:

1. **Read back CLAUDE.md** to verify markers are present
2. **Check for required sections**:
   - [ ] RPTC version marker present
   - [ ] Quick reference table present
   - [ ] Tool prioritization section present
   - [ ] Review configuration present

3. **Report status**:

```markdown
## RPTC Setup Complete

**Project**: {project_name}
**RPTC Version**: {version}
**Status**: ✓ Configured

### Configuration
- Review Mode: {review_agent_mode}
- CLAUDE.md Location: ./CLAUDE.md

### Next Steps
1. Customize `review-agent-mode` if needed (automatic/all/minimal)
2. Add project-specific notes to the configuration section
3. Start developing with `/rptc:feat "your feature"`
```

---

## Error Handling

| Error | Resolution |
|-------|------------|
| Cannot read plugin.json | Report error, use "unknown" as version |
| Cannot write CLAUDE.md | Check permissions, report error |
| Malformed existing RPTC section | Backup existing, replace entirely |
| Markers corrupted | Remove partial markers, insert fresh section |

---

## Examples

### First-time setup
```
User: /rptc:start

Claude: Checking RPTC configuration...

No CLAUDE.md found in project root.
Creating CLAUDE.md with RPTC v2.25.6 configuration...

✓ Created ./CLAUDE.md

Configuration:
- review-agent-mode: automatic (default)

Next steps:
1. Review and customize the configuration
2. Start developing with /rptc:feat "your feature"
```

### Update existing
```
User: /rptc:start

Claude: Checking RPTC configuration...

Found CLAUDE.md with RPTC v2.24.0 configuration.
Current RPTC version: v2.25.6

Updating configuration...
- Preserved review-agent-mode: all
- Preserved project-specific notes

✓ Updated RPTC configuration to v2.25.6

Key changes in this update:
- Added Tier 4 nits to code review
- Mandatory Phase 4 quality review gate
```

### Already current
```
User: /rptc:start

Claude: Checking RPTC configuration...

✓ RPTC v2.25.6 configuration is already up to date.

Current settings:
- review-agent-mode: automatic
```

---

## Key Principles

1. **Preserve user customizations**: Never overwrite `review-agent-mode` or project-specific notes
2. **Non-destructive updates**: Only modify the RPTC section, leave rest of CLAUDE.md untouched
3. **Graceful degradation**: If plugin.json unreadable, use "unknown" version and warn user
4. **Always report status**: Show current configuration after every run
5. **Idempotent operation**: Running multiple times is safe, produces same result
