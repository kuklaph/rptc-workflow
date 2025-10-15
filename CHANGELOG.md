# Changelog

All notable changes to the RPTC Workflow plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.2] - 2025-10-15

### Improved

- **Comprehensive Upgrade Command**: Enhanced `/rptc:admin-upgrade` to be a complete workspace verification and repair tool
  - Now performs full health check on every run, even when version is current
  - Detects and respects user customizations (directory names, config values)
  - Interactive prompts for ambiguous changes (asks before modifying potential customizations)
  - Auto-fixes clearly system-level issues (missing config fields, missing directories)
  - Verifies directory structure based on user's configured locations
  - Validates configuration file completeness
  - Checks important files (CLAUDE.md, .gitignore)
  - Validates SOP locations and fallback chain
  - Shows current configuration values for transparency

- **User Customization Detection**:
  - Detects non-standard directory names (e.g., `.rptc/archive` vs `.rptc/complete`)
  - Detects customized config values (e.g., coverage target changed from 85 to 90)
  - Asks before changing anything that might be intentional
  - Default response preserves user customizations

- **Smart Repair Logic**:
  - Auto-creates missing directories (clearly unintentional)
  - Auto-adds missing config fields (system-level only)
  - Asks before recreating deleted files (might be intentional)
  - Asks before renaming directories (might be customized naming)
  - Provides rollback instructions for all changes

### Philosophy

The upgrade command now follows a "respect user intent" philosophy:

**Auto-fix without asking**: Missing config fields, version updates, completely missing directories

**Ask first**: Directory renames, missing files, SOP location changes, any non-standard structure

**Never change silently**: Custom config values, non-standard naming, anything suggesting user preference

### Migration Notes

No migration needed from v1.1.1. The enhanced upgrade command is backward compatible and will work with any v1.0.x or v1.1.x workspace.

---

## [1.1.1] - 2025-10-15

### Fixed

- **Windows Command Display Issue**: Fixed backslashes appearing in command names on Windows
  - Root cause: Subdirectories in `commands/` folder caused Windows path separators in command names
  - Example: `/rptc:\admin:config` appeared with backslash instead of `/rptc:admin-config`
  - Solution: Flattened directory structure - moved all commands to root `commands/` folder
  - Admin commands: `commands/admin/*.md` → `commands/admin-*.md`
  - Helper commands: `commands/helper/*.md` → `commands/helper-*.md`

### Changed

- **Plugin Name**: Shortened from `rptc-workflow` to `rptc` for more concise commands
  - Commands now use `/rptc:` prefix instead of `/rptc-workflow:`
  - Example: `/rptc-workflow:research` → `/rptc:research`
  - Shorter, cleaner command names for better UX
- **Command Naming Convention**: Established consistent dash-separated naming
  - Core workflow: `/rptc:research`, `/rptc:plan`, `/rptc:tdd`, `/rptc:commit`
  - Admin commands: `/rptc:admin-config`, `/rptc:admin-init`, `/rptc:admin-sop-check`, `/rptc:admin-upgrade`
  - Helper commands: `/rptc:helper-catch-up-quick`, `/rptc:helper-cleanup`, etc.
- **Directory Structure**: Commands now organized flat with prefixes instead of subdirectories
  - Before: `commands/admin/config.md`, `commands/helper/cleanup.md`
  - After: `commands/admin-config.md`, `commands/helper-cleanup.md`
- **Documentation**: Updated all references to new command names throughout README, CONTRIBUTING, and docs

### Migration Notes

**Upgrading from v1.1.0**:

Commands have changed names - update any scripts or documentation that reference old command names:
- `/rptc-workflow:research` → `/rptc:research`
- `/rptc-workflow:admin:config` → `/rptc:admin-config`
- `/rptc-workflow:helper:cleanup` → `/rptc:helper-cleanup`

---

## [1.1.0] - 2025-10-15

### Added

- **Version Tracking System**: Workspace now tracks plugin version via `_rptcVersion` field in settings.json
- **Automatic Upgrade Detection**: Commands can detect when workspace is outdated
- **New Command: `/rptc:admin-upgrade`**: Migrate workspace configuration when plugin updates
  - Detects version gap between workspace and plugin
  - Shows relevant changelogs
  - Merges new configuration fields while preserving user values
  - Creates backup before making changes
  - Handles version-specific migrations (e.g., SOP path migration)
  - Interactive prompts for breaking changes
  - Idempotent and safe to run multiple times

### Fixed

- **Critical: SOP Fallback Chain Bug**: Fixed bash tilde expansion issue in `/rptc:admin-sop-check`
  - User global SOPs (`~/.claude/global/sop/`) were never being found due to quoted tilde
  - Changed `"~/.claude/global/sop"` → `"$HOME/.claude/global/sop"` throughout sop-check.md
  - Impact: SOP fallback chain now works correctly at all three levels (project → user → plugin)
  - **Note**: This was a day-one bug present since v1.0.0 - user global SOPs were never functional

### Changed

- **Default SOP Path**: Changed from `.claude/sop` to `.rptc/sop` for better workspace organization
  - All RPTC files now centralized in `.rptc/` directory
  - `.rptc/sop/` - Project-specific SOPs (was `.claude/sop/`)
  - `~/.claude/global/sop/` - User global SOPs (unchanged)
  - `${CLAUDE_PLUGIN_ROOT}/sop/` - Plugin defaults (unchanged)
- **Directory Structure**: Renamed `.rptc/archive/` to `.rptc/complete/` for better semantics
  - Clearer naming for completed work
  - Updated all references in commands and documentation
- **Gitignore Behavior**: Init command no longer auto-adds `.rptc/` entries to gitignore
  - Users can choose to track research/plans in version control
  - Still auto-adds `.claude/settings.local.json` and `.claude/.env*` (Claude-specific)
- **SOP Fallback Chain**: Updated to reflect new default path
  1. Project: `.rptc/sop/` (highest priority)
  2. User: `~/.claude/global/sop/`
  3. Plugin: `${CLAUDE_PLUGIN_ROOT}/sop/`
- **Init Command** (`/rptc:admin-init`):
  - Now sets `_rptcVersion` in settings.json
  - Copies SOPs to `.rptc/sop/` instead of `.claude/sop/`
  - Creates `.rptc/sop/` directory for project-specific SOPs
- **SOP Check Command** (`/rptc:admin-sop-check`):
  - Updated to check `.rptc/sop/` first
  - Instructions updated to reference new path
- **Directory Structure**: Project SOPs now live in `.rptc/sop/` alongside other RPTC artifacts

### Improved

- **User Experience**: Centralized workspace with all RPTC files in `.rptc/`
- **Upgrade Path**: Clear migration from older versions with `/rptc:admin-upgrade`
- **Future-Proofing**: Version tracking enables smooth future upgrades
- **Workspace Organization**: Cleaner separation between Claude settings (`.claude/`) and RPTC workspace (`.rptc/`)

### Migration Notes

**Upgrading from v1.0.x**:

```bash
# Automatic upgrade (recommended)
/rptc:admin-upgrade

# Or manual steps:
# 1. Add "_rptcVersion": "1.1.0" to .claude/settings.json
# 2. Move .claude/sop/ → .rptc/sop/ (or update customSopPath)
# 3. Update customSopPath default to ".rptc/sop"
```

**For existing .claude/sop/ users**:
- Option 1: Move to `.rptc/sop/` (recommended)
- Option 2: Keep `.claude/sop/` and set `customSopPath: ".claude/sop"` in settings.json

---

## [1.0.9] - 2025-10-15

### Fixed

- **Version Synchronization**: Updated `plugin.json` version to match marketplace versions
  - Previous v1.0.8 release accidentally omitted `plugin.json` version update (remained at 1.0.6)
  - All three version locations now synchronized at 1.0.9:
    - `plugin.json` → 1.0.9
    - `marketplace.json` metadata.version → 1.0.9
    - `marketplace.json` plugins[0].version → 1.0.9
  - No functional changes; patch release for version consistency only

---

## [1.0.8] - 2025-10-15

### Added

- **Full Configuration System**: Complete RPTC configuration now available via `.claude/settings.json`:
  ```json
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
  ```
- **Configurable Artifact Location** (`artifactLocation`): Users can now customize where working artifacts (research, plans, archives) are stored
- **Configurable Documentation Location** (`docsLocation`): Users can now customize where permanent documentation is stored
- **Configurable Test Coverage Target** (`testCoverageTarget`): Users can now set their own coverage threshold (default: 85%)
- **Configurable Max Planning Attempts** (`maxPlanningAttempts`): Users can now customize auto-iteration limits during TDD (default: 10)
- **Configurable SOP Path** (`customSopPath`): Users can now specify custom project-specific SOP directory location

### Changed

- **Init Command** (`/rptc:admin-init`):
  - Now creates `.claude/settings.json` with RPTC defaults on first run
  - Intelligently merges RPTC config into existing settings files
  - Summary report shows settings file creation and thinking mode tip
- **Configuration Made Functional**: All configuration options now actively used by commands:
  - **Research Phase** (`/rptc:research`): Uses `artifactLocation` for storing research documents
  - **Planning Phase** (`/rptc:plan`): Uses `artifactLocation` for storing and reading plans
  - **TDD Phase** (`/rptc:tdd`): Uses `artifactLocation` for plan synchronization AND `maxPlanningAttempts` for auto-iteration limits
  - **Commit Phase** (`/rptc:commit`): Uses `testCoverageTarget` for coverage validation AND `docsLocation` for documentation updates
  - **Cleanup Helper** (`/rptc:helper-cleanup`): Uses `artifactLocation` for archives AND `docsLocation` for promotions
- **Config Loading Pattern**: All commands now load configuration on startup with proper fallbacks to defaults

### Improved

- **Workspace Flexibility**: Users can now customize artifact and documentation locations to fit their project structure
- **Coverage Control**: Teams can now set coverage thresholds that match their quality standards
- **Iteration Control**: Users can adjust auto-iteration limits based on project complexity and time constraints

### Technical

- Implemented configuration check pattern across all command files
- Implemented consistent config loading pattern using `jq` with fallback defaults
- All hardcoded paths replaced with configuration variables (`$ARTIFACT_LOC`, `$DOCS_LOC`, `$COVERAGE_TARGET`, `$MAX_ATTEMPTS`)
- Configuration loading occurs at command startup (Step 0a) before any operations
- Backward compatibility maintained: all defaults match previous hardcoded values

---

## [1.0.7] - 2025-10-14

### Added

- **Global Thinking Mode Configuration**: Users can now set a default thinking mode for all RPTC sub-agents via `.claude/settings.json`:
  ```json
  {
    "rptc": {
      "defaultThinkingMode": "think"
    }
  }
  ```
- **Thinking Mode Selection**: All sub-agent delegations now prompt users to specify thinking mode:
  - `"think"` - Basic extended thinking (~4K tokens, default)
  - `"think hard"` - Medium depth thinking (~10K tokens)
  - `"ultrathink"` - Maximum depth thinking (~32K tokens)
- **Power User Tip**: Init command now displays thinking mode configuration guidance on first setup
- **Automatic Settings Creation**: `/rptc:admin-init` now creates `.claude/settings.json` with RPTC defaults if it doesn't exist, or merges RPTC config if file exists (using `jq` if available)

### Changed

- **Default Thinking Mode**: Changed from implicit "extended" to explicit "think" (4K tokens) to be mindful of Pro plan users
- **Thinking Mode Keywords**: Updated to use official Anthropic keywords:
  - Replaced generic "extended" with "think"
  - Replaced generic "normal" with "think" (basic mode)
  - Verified "ultrathink" keyword (~32K tokens) from official sources
- **Research Phase** (`/rptc:research`):
  - Added thinking mode prompt for Master Web Research Agent delegation
  - Removed prescriptive "ultrathink" instruction from agent itself
  - Checks `.claude/settings.json` for global default before prompting
- **Planning Phase** (`/rptc:plan`):
  - Added thinking mode prompt for Master Feature Planner delegation
  - Global default used if user doesn't specify
  - Updated token budget descriptions for each mode
- **TDD Phase** (`/rptc:tdd`):
  - Added thinking mode prompt for Master Efficiency Agent delegation
  - Added thinking mode prompt for Master Security Agent delegation
  - Both agents check global configuration before prompting
- **Commit Phase** (`/rptc:commit`):
  - Master Documentation Specialist now respects global thinking mode
  - Automatically uses configured default (no prompt, as delegation is automatic)
- **Thinking Mode Precedence**: Established hierarchy: User per-command choice > Global setting > Default ("think")

### Improved

- **Token Budget Transparency**: All thinking mode tips now display approximate token budgets
- **Pro Plan Consideration**: Default mode set to "think" to avoid excessive token usage for users on Pro plans
- **Configuration Discoverability**: Init command prominently displays thinking mode configuration example

### Technical

- Verified custom configuration options are supported in Claude Code plugin settings via hierarchical settings merge
- Updated all agent delegation prompts to accept thinking mode parameter

---

## [1.0.0] - 2025-10-14

### Added

#### Core Workflow

- **Research Phase** (`/rptc:research`): Interactive discovery with brainstorming and codebase exploration
- **Planning Phase** (`/rptc:plan`): Collaborative planning with Master Feature Planner agent
- **TDD Phase** (`/rptc:tdd`): Test-driven implementation with auto-iteration (max 10 attempts)
- **Commit Phase** (`/rptc:commit`): Comprehensive verification with test enforcement and PR creation

#### Helper Commands

- `/rptc:helper-catch-up-quick` - Quick project context (2 minutes)
- `/rptc:helper-catch-up-med` - Medium project context (5-10 minutes)
- `/rptc:helper-catch-up-deep` - Deep project analysis (15-30 minutes)
- `/rptc:helper-update-plan` - Modify existing implementation plans
- `/rptc:helper-resume-plan` - Resume previous work after breaks
- `/rptc:helper-cleanup` - Review and archive completed plans

#### Admin Commands

- `/rptc:admin-init` - Initialize RPTC workspace with optional `--copy-sops` and `--global` flags
- `/rptc:admin-config` - Display current configuration
- `/rptc:admin-sop-check` - Verify SOP resolution via fallback chain

#### Master Specialist Agents

- **Master Web Research Agent**: Find best practices and implementation patterns during research
- **Master Feature Planner**: Create comprehensive TDD-ready plans with test strategy
- **Master Efficiency Agent**: Optimize code for simplicity (KISS/YAGNI principles)
- **Master Security Agent**: Identify and fix vulnerabilities (OWASP Top 10)
- **Master Documentation Specialist**: Automatically promote significant work to permanent docs

#### Standard Operating Procedures (SOPs)

- `testing-guide.md` - Testing frameworks, patterns, TDD guidance
- `architecture-patterns.md` - Architecture and design patterns
- `frontend-guidelines.md` - Frontend design, visual style, accessibility
- `git-and-deployment.md` - Git workflow, CI/CD, deployment
- `languages-and-style.md` - Language conventions, formatters, linters
- `security-and-performance.md` - Security practices, performance optimization

#### SOP Fallback Chain

Three-tier fallback system (priority order):

1. Project: `.claude/sop/` - Project-specific overrides
2. User: `~/.claude/global/sop/` - User global defaults
3. Plugin: `${CLAUDE_PLUGIN_ROOT}/sop/` - Plugin defaults

#### Quality Enforcement Hooks

- `check-tdd.sh` - TDD warning system for implementation-first patterns
- `format-code.sh` - Auto-formatting enforcement
- `pre-commit.sh` - Comprehensive pre-commit verification
- `protect-files.sh` - Protected file guard (secrets, lock files)

#### Documentation

- `README.md` - Comprehensive plugin documentation
- `RPTC_WORKFLOW_GUIDE.md` - Complete workflow guide with patterns
- `PROJECT_TEMPLATE.md` - CLAUDE.md template for user projects
- `PLUGIN_ARCHITECTURE.md` - Technical architecture documentation
- `CONTRIBUTING.md` - Contribution guidelines
- `LICENSE` - MIT License

#### Templates

- `templates/research.md` - Research findings template
- `templates/plan.md` - Implementation plan template

#### Configuration

- Customizable test coverage target (default: 80%)
- Auto-promotion policy for documentation
- Retention policy for completed plans
- Max planning iteration attempts (default: 10)

### Changed

- **Plugin Architecture**: Converted from bash setup scripts to Claude Code plugin
- **Path Structure**: All plugin resources now use `${CLAUDE_PLUGIN_ROOT}` for portability
- **SOP Resolution**: Implemented fallback chain instead of hardcoded paths
- **Template Handling**: Templates remain at plugin root (not copied to user projects)
- **Command Namespacing**: All commands prefixed with `/rptc:` for clarity

### Migrated

- Legacy bash setup scripts moved to `legacy/` directory
- Old `.claude/commands/.rptc/` structure converted to plugin `commands/`
- Old `.claude/agents/.rptc/` structure converted to plugin `agents/`
- Old `.rptc/sop/` moved to plugin `sop/` as defaults
- Old `.rptc/templates/` moved to plugin `templates/`

### Architecture Decisions

- **User Workspace**: `.rptc/research/`, `.rptc/plans/`, `.rptc/complete/` preserved (user artifacts)
- **Plugin Resources**: Commands, agents, SOPs, templates stay at plugin root
- **Documentation Promotion**: Automatic via Documentation Specialist (not manual prompts)
- **PM-Controlled Workflow**: Explicit approvals required at every phase transition

### Removed

- Manual bash setup scripts (replaced by plugin installation)
- Hardcoded SOP paths (replaced by fallback chain)
- Template copying to user projects (now referenced from plugin root)

---

## [1.0.8] - 2025-10-15

### Added

- **Global Thinking Mode Configuration**: Users can now set a default thinking mode for all RPTC sub-agents via `.claude/settings.json`:
  ```json
  {
    "rptc": {
      "defaultThinkingMode": "think"
    }
  }
  ```
- **Thinking Mode Selection**: All sub-agent delegations now prompt users to specify thinking mode:
  - `"think"` - Basic extended thinking (~4K tokens, default)
  - `"think hard"` - Medium depth thinking (~10K tokens)
  - `"ultrathink"` - Maximum depth thinking (~32K tokens)
- **Power User Tip**: Init command now displays thinking mode configuration guidance on first setup
- **Automatic Settings Creation**: `/rptc:admin-init` now creates `.claude/settings.json` with RPTC defaults if it doesn't exist, or merges RPTC config if file exists (using `jq` if available)
- **Full Configuration System**: Complete RPTC configuration now available via `.claude/settings.json`:
  ```json
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
  ```
- **Configurable Artifact Location** (`artifactLocation`): Users can now customize where working artifacts (research, plans, archives) are stored
- **Configurable Documentation Location** (`docsLocation`): Users can now customize where permanent documentation is stored
- **Configurable Test Coverage Target** (`testCoverageTarget`): Users can now set their own coverage threshold (default: 85%)
- **Configurable Max Planning Attempts** (`maxPlanningAttempts`): Users can now customize auto-iteration limits during TDD (default: 10)
- **Configurable SOP Path** (`customSopPath`): Users can now specify custom project-specific SOP directory location

### Changed

- **Default Thinking Mode**: Changed from implicit "extended" to explicit "think" (4K tokens) to be mindful of Pro plan users
- **Thinking Mode Keywords**: Updated to use official Anthropic keywords:
  - Replaced generic "extended" with "think"
  - Replaced generic "normal" with "think" (basic mode)
  - Verified "ultrathink" keyword (~32K tokens) from official sources
- **Research Phase** (`/rptc:research`):
  - Added thinking mode prompt for Master Web Research Agent delegation
  - Removed prescriptive "ultrathink" instruction from agent itself
  - Checks `.claude/settings.json` for global default before prompting
- **Planning Phase** (`/rptc:plan`):
  - Added thinking mode prompt for Master Feature Planner delegation
  - Global default used if user doesn't specify
  - Updated token budget descriptions for each mode
- **TDD Phase** (`/rptc:tdd`):
  - Added thinking mode prompt for Master Efficiency Agent delegation
  - Added thinking mode prompt for Master Security Agent delegation
  - Both agents check global configuration before prompting
- **Commit Phase** (`/rptc:commit`):
  - Master Documentation Specialist now respects global thinking mode
  - Automatically uses configured default (no prompt, as delegation is automatic)
- **Thinking Mode Precedence**: Established hierarchy: User per-command choice > Global setting > Default ("think")
- **Init Command** (`/rptc:admin-init`):
  - Now creates `.claude/settings.json` with RPTC defaults on first run
  - Intelligently merges RPTC config into existing settings files
  - Summary report shows settings file creation and thinking mode tip
- **Configuration Made Functional**: All configuration options now actively used by commands:
  - **Research Phase** (`/rptc:research`): Uses `artifactLocation` for storing research documents
  - **Planning Phase** (`/rptc:plan`): Uses `artifactLocation` for storing and reading plans
  - **TDD Phase** (`/rptc:tdd`): Uses `artifactLocation` for plan synchronization AND `maxPlanningAttempts` for auto-iteration limits
  - **Commit Phase** (`/rptc:commit`): Uses `testCoverageTarget` for coverage validation AND `docsLocation` for documentation updates
  - **Cleanup Helper** (`/rptc:helper-cleanup`): Uses `artifactLocation` for archives AND `docsLocation` for promotions
- **Config Loading Pattern**: All commands now load configuration on startup with proper fallbacks to defaults

### Improved

- **Token Budget Transparency**: All thinking mode tips now display approximate token budgets
- **Pro Plan Consideration**: Default mode set to "think" to avoid excessive token usage for users on Pro plans
- **Configuration Discoverability**: Init command prominently displays thinking mode configuration example
- **Workspace Flexibility**: Users can now customize artifact and documentation locations to fit their project structure
- **Coverage Control**: Teams can now set coverage thresholds that match their quality standards
- **Iteration Control**: Users can adjust auto-iteration limits based on project complexity and time constraints

### Technical

- Verified custom configuration options are supported in Claude Code plugin settings via hierarchical settings merge
- Implemented configuration check pattern across all command files
- Updated all agent delegation prompts to accept thinking mode parameter
- Implemented consistent config loading pattern using `jq` with fallback defaults
- All hardcoded paths replaced with configuration variables (`$ARTIFACT_LOC`, `$DOCS_LOC`, `$COVERAGE_TARGET`, `$MAX_ATTEMPTS`)
- Configuration loading occurs at command startup (Step 0a) before any operations
- Backward compatibility maintained: all defaults match previous hardcoded values

---

## [Unreleased]

### Planned Features

- Additional language-specific SOPs (Rust, Go, Java)
- GitHub Actions integration for automated testing
- Enhanced error messages with troubleshooting hints
- Community template marketplace
- Video tutorial series

---

## Version History

- **1.1.2** (2025-10-15): Enhanced upgrade command - comprehensive workspace verification that respects user customizations
- **1.1.1** (2025-10-15): Patch release - Fixed Windows backslash issue and shortened plugin name (rptc-workflow → rptc)
- **1.1.0** (2025-10-15): Added version tracking system, upgrade command, and migrated SOP path from .claude/sop to .rptc/sop
- **1.0.9** (2025-10-15): Patch release - Fixed version synchronization (plugin.json now matches marketplace versions)
- **1.0.8** (2025-10-15): Made all configuration options functional - customizable paths, coverage targets, and iteration limits
- **1.0.7** (2025-10-14): Added global thinking mode configuration and user-selectable thinking modes for all sub-agents
- **1.0.0** (2025-10-14): Initial plugin release with full RPTC workflow

---

## Links

- [GitHub Repository](https://github.com/kuklaph/rptc-workflow)
- [Issue Tracker](https://github.com/kuklaph/rptc-workflow/issues)
- [Discussions](https://github.com/kuklaph/rptc-workflow/discussions)
