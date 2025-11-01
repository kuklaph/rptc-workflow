# Changelog

All notable changes to the RPTC Workflow plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.4.0] - 2025-10-31

### Changed
- **Phase 4.5 (Critical Simplicity Gate) now uses master-simplicity-agent sub-agent delegation** for architectural consistency with Phase 5 quality gates
  - Autonomous simplification capability: Agent can directly edit plan scaffolds using Edit tool
  - Retry-fallback mechanism: Falls back to inline validation if sub-agent unavailable (preserves UX)
  - Clear differentiation from master-efficiency-agent: Simplicity agent runs PREVENTION (pre-planning validation) while efficiency agent runs REMEDIATION (post-TDD refactoring)
  - Context efficiency: Isolated sub-agent execution prevents main context bloat for large plans

---

## [2.3.0] - 2025-10-31

### Added

- **Enhanced User Experience with AskUserQuestion Integration**: Implemented standardized interactive menu prompts across all 14 RPTC workflow commands, replacing 62 instances of manual "please provide" text prompts with structured AskUserQuestion calls.

  **Commands Enhanced** (62 total implementations):
  - `admin-config.md` - 2 menu prompts for display options and export configuration
  - `admin-init.md` - 5 menu prompts for project validation, SOP copying, config presets, .gitignore handling, and README documentation
  - `admin-sop-check.md` - 3 menu prompts for SOP selection, resolution action, and multiple version handling
  - `admin-upgrade.md` - 4 menu prompts for version upgrade confirmation, custom directory handling, config field updates, and backup strategy
  - `commit.md` - 8 menu prompts for commit confirmation, coverage warning, linting errors, PR creation, test failure recovery, quality issues, branch selection, and commit message approval
  - `helper-catch-up-deep.md` - 1 menu prompt (multi-select) for analysis focus areas
  - `helper-catch-up-med.md` - 1 menu prompt for depth override
  - `helper-catch-up-quick.md` - 1 menu prompt for depth override
  - `helper-cleanup.md` - 3 menu prompts for batch action selection, individual plan action, and delete confirmation
  - `helper-resume-plan.md` - 2 menu prompts for catch-up depth override and stale handoff action
  - `helper-simplify.md` - 5 menu prompts for analysis mode, test warning, approval gate, test failure response, and partial simplification
  - `helper-update-plan.md` - 3 menu prompts for update type, step modification type, and PM approval
  - `plan.md` - 10 menu prompts for depth, simulation, thinking mode, existing plans, test strategy, approach, specifications, patterns, complexity, and step breakdown
  - `research.md` - 6 menu prompts for scope, depth, format, simulation, duplicate handling, and focus areas (multi-select)
  - `tdd.md` - 8 menu prompts for plan format detection, thinking mode, quality gates, test failure handling, step completion, coverage warnings, implementation approach, and handoff recovery

  **Benefits**:
  - Consistent UX across entire workflow
  - Improved accessibility with structured menu options
  - Better error handling and input validation
  - Enhanced discoverability of command features
  - Reduced cognitive load for users (clear choices vs. free-form input)
  - Eliminated typos and ambiguous text responses
  - Visual feedback at critical decision points

  **Research Reference**: `.rptc/research/askuserquestion-opportunities-across-rptc-workflow/research.md`

### Changed

- **Command Interaction Pattern**: All workflow commands now use structured menu prompts instead of free-form text requests, improving consistency and reducing user errors.

---

## [2.2.5] - 2025-10-29

### Fixed

- **Configuration System**: `tdgMode` and `verificationMode` settings now properly loaded from `.claude/settings.json`
  - `tdgMode` config loading added in Step 0a (previously only `--tdg` flag worked)
  - `verificationMode` config loading added in Step 0a (previously non-functional)
- **Phase 1c TDG Delegation**: Implemented missing Test-Driven Generation sub-agent delegation
  - Generates ~50 comprehensive test scenarios when TDG enabled
  - Augments planned tests with edge cases, error conditions, and variations
  - Integration point between test validation and TDD execution
- **Phase 1d Independent Verification**: Implemented previously orphaned Phase 3.75
  - Catches test overfitting and validates intent fulfillment
  - Executes after GREEN phase (tests pass), before moving to next step
  - Checks: intent fulfillment, coverage gaps, test gaming detection
  - Renumbered from Phase 3.75 to Phase 1d (architectural correction)

### Removed

- **Dead Code Cleanup**: Removed `qualityGatesEnabled` setting (8 locations, 4 files)
  - Never used in any command (quality gates are non-negotiable)
  - Cleaned from: admin-init.md, admin-config.md, admin-upgrade.md, README.md

### Changed

- **Documentation**: Updated Phase 3.75 references to Phase 1d in workflow guide and SOPs

---


## [2.2.4] - 2025-10-29

### Refactored

- **Helper Commands Bash Removal**: Comprehensive cross-platform refactoring of helper commands
  - **helper-simplify.md** (11 instances): Replaced `find`, `wc -l`, `grep` loops with Glob, Read, Grep tools
  - **helper-resume-plan.md** (4 instances): Replaced `grep`/`sed`/`awk` text processing and **eliminated critical eval vulnerability**
  - **helper-catch-up-deep.md** (15+ instances): Replaced complex diagnostic pipelines with native tools
  - **helper-catch-up-med.md**: Reviewed - all bash instances are documentation examples
  - **Impact**: ~30-50K token reduction per workflow, cross-platform compatibility

- **Admin Commands Bash Removal**: Comprehensive cross-platform refactoring of admin commands
  - **admin-upgrade.md** (53 instances): **CRITICAL - Eliminated 6 interactive `read -p` prompts** blocking automation
  - **admin-config.md** (53 instances): Configuration display now approval-free
  - **admin-init.md** (39 instances): Workspace initialization streamlined
  - **admin-sop-check.md** (39 instances): SOP resolution verification simplified
  - **Impact**: Unblocked automation, 172+ approval triggers removed, zero interruptions

### Security

- **CRITICAL: Eliminated eval Vulnerability in helper-resume-plan.md**
  - **CVE Risk**: Arbitrary code execution via eval-based array restoration
  - **Fix**: Replaced 2 eval instances with Read tool + safe Claude parsing
  - **Impact**: Complete mitigation of code injection attack surface

### Technical

- **Total bash instances removed**: 200+ (30+ helper + 172+ admin)
- **Security improvements**: 2 eval vulnerabilities + 6 interactive prompts eliminated
- **Cross-platform**: All commands work reliably on Windows, macOS, Linux
- **Token efficiency**: Combined ~30-50K reduction per typical workflow
- **Files modified**: 7 helper commands + 4 admin commands + CHANGELOG

---


## [2.2.3] - 2025-10-29

### Fixed

- **Agent Naming Consistency**: Renamed `tdd-executor-agent` to `master-tdd-executor-agent` to follow established naming convention
  - Updated `commands/tdd.md` line 1327: Agent file path validation now references correct file path
  - Updated `commands/tdd.md` line 2075: Task tool invocation uses correct subagent name `rptc:master-tdd-executor-agent`
  - Updated `CLAUDE.md` (4 locations): Documentation now consistently references `master-tdd-executor-agent`
    - Line 322: Sub-agent delegation table
    - Line 366: TDD execution pattern description
    - Line 377: Example delegation pattern code block
    - Line 400: Agent reference file path
  - **Impact**: Fixes runtime failure where TDD command would fail to find agent definition file
  - **Pattern Alignment**: Agent now follows `master-*-agent` naming pattern used by all other master agents

- **Research Command File Creation Prevention**: Added explicit instructions to prevent sub-agents from creating files during research phase
  - Updated `commands/research.md` (4 delegation locations): All Explore and master-research-agent delegations now include `**IMPORTANT**: DO NOT create any files or documents. Return your findings inline only.`
    - Scenario A (codebase-only): Explore agent delegation
    - Scenario B (web-only): master-research-agent delegation
    - Scenario C (hybrid): Both Explore and master-research-agent delegations
  - Updated `agents/master-research-agent.md` (2 locations): Added CRITICAL instructions in Read/Write Tools section and Required Output Format section
  - **Impact**: Prevents sub-agents from proactively creating research files; file creation only happens in Phase 5 when user explicitly requests it
  - **Behavior**: Research findings returned inline, document creation deferred to user request

### Technical

- **Files Modified**: `commands/tdd.md` (2 locations), `commands/research.md` (4 locations), `agents/master-research-agent.md` (2 locations), `CLAUDE.md` (4 locations), `agents/tdd-executor-agent.md` (renamed to `agents/master-tdd-executor-agent.md`)
- **Breaking Change**: None (agent functionality unchanged for TDD rename; research behavior clarified but not breaking)
- **Backward Compatibility**: Full (existing plans and workflows continue to work)

---

## [2.2.2] - 2025-10-28

### Changed

- **TDD Delegation Enforcement**: Replaced vague "Create TDD Sub-Agent" text with explicit Task tool invocation pattern across all 3 execution paths
  - **New agent created**: `rptc:tdd-executor-agent` - Specialized TDD execution agent with comprehensive RED-GREEN-REFACTOR methodology
  - **Normal execution** (directory format): Explicit `Task tool with subagent_type="rptc:tdd-executor-agent"` at commands/tdd.md line 2000-2220
  - **Resume/handoff path**: Verified to use Phase 1a delegation (no separate logic needed)
  - **On-the-fly generation**: Updated lines 389-420 to reference Phase 1a delegation explicitly
  - **Pattern consistency**: All paths now use identical delegation structure matching plan.md:810 pattern
  - **Context passing**: 6 comprehensive sections (Feature, Step, Cumulative Context, Implementation Constraints, Configuration, SOPs)
  - **Validation checkpoint**: Minimal validation checkpoint (agent file existence check only)

### Added

- **New Agent Definition**: `agents/tdd-executor-agent.md` with TDD methodology, SOP integration, constraint awareness
  - Enforces test-first development (RED-GREEN-REFACTOR-VERIFY cycle)
  - References 4 core SOPs: testing-guide.md, flexible-testing-guide.md, architecture-patterns.md, security-and-performance.md
  - Handles implementation constraints from plan overview
  - Comprehensive context requirements documented
  - Prevents vague "create sub-agent" execution in main context
- **Phase 0d Validation Checkpoint**: Optional defense-in-depth validation in commands/tdd.md (lines 1309-1352)
  - Validates agent definition file existence before execution
  - Clear error messages with recovery instructions
  - <0.2s execution overhead

### Technical

- **Files Modified**: `commands/tdd.md` (3 locations: Phase 1a delegation at lines 2000-2220, on-the-fly generation at lines 389-420, Phase 0d validation at lines 1309-1352)
- **Files Created**: `agents/tdd-executor-agent.md` (new specialized TDD executor)
- **Architectural Improvement**: Unified delegation pathway eliminates execution path fragmentation
- **Benefits**:
  - Prevents main context execution during handoffs
  - Ensures consistent TDD enforcement across all workflow entry points
  - Improves maintainability (single delegation pattern to maintain)
  - Token efficiency (sub-agent isolation reduces main context bloat)

---

## [2.2.1] - 2025-10-28

### Changed

- **Systematic Bash Removal**: Replaced unnecessary bash with native Claude Code tools across 8 command files
  - **Cross-platform compatibility**: Removed stat command (Windows blocker in admin-sop-check)
  - **jq dependency eliminated**: 50+ instances replaced with Read + Claude parsing
  - **DRY violations fixed**: 150+ duplicated lines consolidated via ${CLAUDE_PLUGIN_ROOT}
  - **Settings merge simplified**: admin-init.md reduced from 86 to 47 lines (45% reduction)
  - **Token efficiency**: ~15-25K token reduction per command execution
  - **Maintainability**: Bash-to-keep criteria documented inline for future development
  - **Net reduction**: 171 lines removed (228 insertions, 399 deletions)

---


## [2.2.0] - 2025-10-28

### Fixed

- **Removed jq Dependency**: admin-init command now uses Read/Write tools instead of jq
  - Fixes broken JSON merge at line 276 (incomplete syntax, missing 14 config fields)
  - All 15 RPTC config fields now included in delegation instructions
  - Manual fallback provided if Read/Write delegation fails
  - More reliable workspace initialization (no external dependency required)

- **Custom Artifact Location Support**: Helper commands now respect configured paths
  - helper-resume-plan: Added Step 0 config loading, replaced 9 hardcoded paths
  - helper-update-plan: Added Step 0 config loading, replaced 3 hardcoded paths
  - Both commands now work with custom `artifactLocation` setting
  - Fixes v2+ compatibility issues for users with custom workspace paths

- **Complete SOP Coverage**: admin-sop-check now verifies all 9 SOPs
  - Added 3 missing SOPs: flexible-testing-guide, post-tdd-refactoring, todowrite-guide
  - Fixes incomplete SOP verification (was showing only 6 of 9)

- **Version Changelog Display**: admin-upgrade now shows changelogs for v2.0.x users
  - Added case entries for versions 2.0.0, 2.0.1, and 2.1.0/2.1.1
  - Fixes empty "What's New" section for users upgrading from v2.0.x

- **Documentation Path References**: Corrected outdated directory naming
  - PROJECT_TEMPLATE.md: Fixed 2 path references (archive→complete, .claude/sop→.rptc/sop)
  - PLUGIN_ARCHITECTURE.md: Fixed 2 path references (archive→complete, .claude/sop→.rptc/sop)
  - All documentation now matches v2.0.0+ directory structure

- **Command Format Consistency**: Fixed command references in CLAUDE.md
  - Updated 7 command references from colon format to hyphen format
  - Users can now copy-paste commands directly from documentation

### Improved

- **Configuration Display**: admin-config now shows all 13 configuration fields
  - Previously showed only 4 fields (artifactLocation, docsLocation, testCoverageTarget, maxPlanningAttempts)
  - Now displays all fields: version, thinking mode, SOP path, research format, HTML theme, verification mode, TDG mode, quality gates, Discord settings
  - Uses Read tool pattern (consistent with jq removal)
  - Users can verify complete configuration at a glance

- **Feature Documentation**: Added missing command and skill documentation
  - Added helper-simplify to README.md Helper Commands table
  - Added discord-notify to CLAUDE.md Available Skills table
  - Improved feature discoverability

### Technical

- **Issues Resolved**: 21/21 (100% completion)
  - 6 critical issues fixed
  - 8 high priority issues resolved
  - 7 medium/low priority issues addressed
- **Files Modified**: 9 command/documentation files
- **Total Changes**: +202 insertions, -60 deletions

---

## [2.1.1] - 2025-10-27

### Fixed

- **Windows Compatibility**: Eliminated Git Bash permission prompts during plan generation
  - Replaced bash file existence checks (`if [ -f "..." ]`) with Read tool in plan.md
  - Overview and step file verification now uses Read tool (lines 892-914, 1022-1041)
  - No more workflow interruptions on Windows during incremental planning

### Improved

- **Context Window Efficiency**: Removed ~1,600 lines of informational bloat across command files
  - Configuration display blocks removed from core workflow commands (research.md, plan.md, tdd.md, commit.md)
  - SOP explanation blocks removed from helper/admin commands
  - Technical implementation displays condensed in tdd.md
  - Pre-action prose and use case examples removed
  - All functionality preserved (thinking mode, errors, confirmations intact)
  - Result: 30-40% reduction in command file token consumption

---


## [2.1.0] - 2025-10-26

### Changed

- **BREAKING**: Simplified research workflow to single unified mode (removed exploration vs planning-prep mode selection)
  - Research command now uses casual inline/dynamic TodoWrite style throughout
  - Agent engages conversationally while exploring (no rigid phase progression)
  - Findings always presented inline immediately before optional save
  - Save prompt is now non-blocking (skip/html/md/both/auto options)
- **Repository Structure**: Moved plugin files from `rptc-workflow/` subfolder to repository root for GitHub URL installation compatibility
- **Installation Methods**: Plugin now supports three install methods - local (`claude plugin install .`), GitHub URL (`claude plugin install <repo-url>`), and marketplace
- **Development Files**: Reorganized dev artifacts - renamed `docs/` to `dev-docs/` to avoid conflict with user-facing documentation
- **Version Scripts**: Updated all path references in `scripts/sync-version.sh`, `scripts/verify-version.sh`, and `.git/hooks/pre-commit` to work with new structure

### Removed

- **BREAKING**: Removed planning-prep mode from `/rptc:research` command
  - No more mode selection prompt at start of research
  - No more PM sign-off gate before saving research
  - Planning-prep specific phases and assessments removed (~280 lines)
- **Documentation**: Cleaned up obsolete mode references from README.md and RPTC_WORKFLOW_GUIDE.md

### Improved

- Research workflow more natural and flexible (no forced mode choice)
- TodoWrite usage now inline/dynamic throughout research (not deferred to end)
- Documentation accuracy (removed obsolete mode references)
- Command file reduced from ~1000 to ~723 lines (simpler, more maintainable)
- **Context window efficiency**: Removed ~3,650 words of informational bloat across 13 command files (~30-40% reduction)
- **Command output clarity**: Commands now focus on essential information and action confirmations only
- **User experience**: Reduced cognitive load by eliminating redundant pre-action explanations
- **Maintainability**: 605 lines removed total across command files

### Technical Details (Context Window Optimization)

**Bloat Removal Categories:**

1. **Configuration Displays Removed** (32 lines, 4 files):
   - Removed "Configuration loaded:" blocks from core workflow commands
   - Config still loaded and validated, just not displayed
   - Files: research.md, plan.md, tdd.md, commit.md

2. **SOP Explanations Removed** (127 lines, 5 files):
   - Removed verbose SOP fallback chain explanations from helper/admin commands
   - SOP resolution still works identically (documented in CLAUDE.md instead)
   - Files: helper-catch-up-quick.md, helper-catch-up-med.md, helper-catch-up-deep.md, admin-init.md, admin-upgrade.md

3. **Technical Displays Removed from tdd.md** (206 lines):
   - Removed context prediction displays ("Context will load:" sections)
   - Removed parsed arguments echo blocks
   - Thinking mode displays preserved (essential debugging info)

4. **Pre-Action Prose Removed** (19 lines, 2 files):
   - Removed verbose "what we're about to do" explanations
   - Commands demonstrate behavior through execution instead
   - Files: helper-catch-up-deep.md, helper-resume-plan.md

5. **Use Case Examples Removed** (168 lines, 4 files):
   - Removed example interaction scenarios
   - Commands demonstrate usage naturally during execution
   - Files: helper-cleanup.md, helper-resume-plan.md, helper-update-plan.md, plan.md

6. **Admin Outputs Condensed** (53 lines net, 2 files):
   - admin-init.md: Condensed config defaults display and final summary
   - admin-config.md: Fixed to read actual config instead of showing hardcoded defaults

**Total Impact:**
- **Lines removed**: 605 lines
- **Words removed**: ~3,650 words
- **Token savings**: ~4,865 tokens per command execution
- **Files modified**: 13 command files

**What's Preserved (Not Bloat):**
- ✅ All thinking mode displays (essential for debugging delegation)
- ✅ All error messages and warnings
- ✅ All essential action confirmations ("✅ Created...", "✓ Complete!")
- ✅ All progress indicators ("Phase 1:", "Step 2 of 5...")
- ✅ All command functionality (only verbose displays removed)

### Migration Notes (Context Window Optimization)

**For users upgrading from v2.0.x:**

Commands work identically - only verbose informational displays removed. No breaking changes to functionality or workflow.

**What you'll notice:**

- Commands proceed without showing "Configuration loaded:" blocks
- No more SOP fallback chain explanations (still works, just not explained every run)
- No more pre-action prose explaining what's about to happen
- Cleaner, more focused command outputs

**What's unchanged:**

- All command functionality works identically
- Configuration still loaded from `.claude/settings.json`
- SOP fallback chain still resolves correctly
- Error messages still displayed when issues occur
- Essential confirmations still shown for all actions
- Thinking mode displays still shown (per your preference)

**If you see errors:**

This release only removed informational displays. If you encounter errors, they're unrelated to this change. Report via GitHub issues.

---


## [2.0.1] - 2025-10-26

### Changed

- **Security Agent Output**: Streamlined to deliver brief inline summaries instead of creating report files, improving token efficiency and workflow speed
- **Admin Commands**: Enhanced configuration display in `/rptc:admin-init` and `/rptc:admin-upgrade` to show new v2.0.0 SOPs and Discord settings

---


## [2.0.0] - 2025-10-24

### Added

- **Efficiency Agent Rewrite (#12)**: Extracted comprehensive refactoring checklist to `sop/post-tdd-refactoring.md`. Agent streamlined to <500 lines. Integrated Phase 1 Code Simplicity research (60-80% reduction, Rule of Three, AI pattern detection).
  - **New SOP**: `post-tdd-refactoring.md` (654 lines) - Comprehensive 5-phase refactoring workflow
    - Phase 1: Pre-Analysis (verify tests, baseline metrics, context review)
    - Phase 2: Dead Code Sweep (tools: ESLint, Vulture, staticcheck by language)
    - Phase 3: Complexity Reduction (refactoring patterns, metrics targets)
    - Phase 4: Readability Pass (naming, comments, formatting)
    - Phase 5: KISS/YAGNI Audit (AI anti-patterns, Rule of Three, Code Simplicity metrics)
    - Phase 6: Final Verification & Reporting
  - **Agent Streamlined**: `master-efficiency-agent.md` reduced to 519 lines (references SOP instead of duplicating content)
  - **Code Simplicity Integration**: 4 new metrics in efficiency reports
    - Code Reduction % (target: 5-15%)
    - Duplication Ratio (target: <5%)
    - AI Anti-Pattern Count (5 patterns from architecture-patterns.md)
    - Pattern Reuse Efficiency (target: ≥2.0)
  - **Single Source of Truth**: All refactoring guidance consolidated in SOP, accessible via fallback chain
  - **Research-Backed**: Operationalizes Phase 1 Code Simplicity findings (60-80% code reduction, 8× duplication decrease)

- **Discord Notifications**: Real-time workflow updates via Discord webhooks
  - **Opt-in configuration**: Disabled by default, configured via `.claude/settings.json`
  - **Supported commands**: `/rptc:research`, `/rptc:plan`, `/rptc:tdd`, `/rptc:commit`, `/rptc:helper-resume-plan`
  - **Three verbosity levels**:
    - `summary`: Minimal notifications (start + end only)
    - `detailed`: Major milestones (quality gates, phase transitions)
    - `verbose`: All steps (debugging mode, may trigger rate limits)
  - **Non-blocking design**: All notification failures are silent, workflow never interrupted
  - **Security**: Webhook URLs treated as credentials, never logged or committed
  - **Rate limit protection**: Summary mode safe for all workflows (2-5 notifications per command)
  - **Cross-platform**: Windows (Git Bash), macOS, Linux compatible

---

## [1.2.0] - 2025-10-17

### Added

- **TodoWrite Integration for State Persistence**: Implemented mandatory TodoWrite tracking across all workflow commands to prevent step-skipping and enable state recovery
  - **Commands Updated**: All 4 core commands now generate comprehensive TodoWrite lists at startup
    - `/rptc:research` - 6-phase tracking (discovery → codebase → web research → findings → approval → save)
    - `/rptc:plan` - Dynamic tracking (4 phases for simple, 9 phases for complex features)
    - `/rptc:tdd` - Dynamic tracking (N × 4 + 6 phases: RED/GREEN/REFACTOR/SYNC per step + quality gates)
    - `/rptc:commit` - 7-phase tracking (verification → commit message → summary → doc specialist → commit → PR → final)
  - **State Persistence Benefits**:
    - ✅ TodoWrite survives `/compact` operations (system-level protection)
    - ✅ State persists across session interruptions
    - ✅ System automatically reminds when TODO list stale
    - ✅ Perfect resumption after long sessions or context loss
  - **Enforcement Rules**:
    - Only ONE task marked "in_progress" at a time (maintains focus)
    - Tasks marked "completed" immediately after finishing (no batching)
    - All quality gates included in TODO list (prevents skipping)
    - PM approval gates explicitly tracked (ensures user control)
  - **Evidence-Based**: Pattern adopted from "Every marketplace" workflow (11.5k+ users) demonstrating 60% reduction in step-skipping

- **Blocking Validation Checkpoints**: Added 8 non-negotiable quality gate checkpoints to enforce RPTC workflow discipline
  - **Research Phase** (commands/research.md): Block save without PM approval
  - **Plan Phase** (commands/plan.md): Block Master Planner delegation without PM approval
  - **Plan Phase** (commands/plan.md): Block plan save without PM approval
  - **TDD Phase** (commands/tdd.md): Block Efficiency Agent execution without PM approval
  - **TDD Phase** (commands/tdd.md): Block Security Agent execution without PM approval
  - **TDD Phase** (commands/tdd.md): Block TDD completion marking without PM approval
  - **Commit Phase** (commands/commit.md): Block commit if tests failing
  - **Commit Phase** (commands/commit.md): Block commit if code quality issues detected
  - **Pattern Template**: Standardized blocking checkpoint format with verification, consequences, and enforcement
  - **Imperative Language**: All checkpoints use CRITICAL/MUST/NEVER/ALWAYS keywords (not "should"/"remember")
  - **Evidence-Based**: Community research shows 80% reduction in skipped steps with imperative language (Pimzino pattern)

- **TodoWrite Integration Guide SOP**: Comprehensive 664-line SOP documenting TodoWrite patterns and best practices
  - **Location**: `sop/todowrite-guide.md`
  - **Contents**:
    - JSON structure templates for all commands
    - State management rules (single in-progress, immediate completion)
    - Integration patterns per command with examples
    - Phase transition blocking patterns
    - PM-centric approval patterns
    - Compaction persistence documentation
    - Anti-patterns and gotchas
    - Testing and validation guidance
  - **Command Examples**: Full TodoWrite JSON examples for research (6 phases), plan (4 or 9 phases), TDD (dynamic N×4+6), commit (7 phases)
  - **Purpose**: Enable future command development and user customization using TodoWrite patterns

### Changed

- **Imperative Language Enforcement**: Upgraded all command language from soft suggestions to hard imperatives
  - **Keyword Transformation**:
    - ❌ "should" → ✅ "**CRITICAL:**" or "**MUST**"
    - ❌ "remember to" → ✅ "**ALWAYS**"
    - ❌ "don't forget" → ✅ "**NEVER** skip"
    - ❌ "consider" → ✅ "**MANDATORY:**"
    - ❌ "ask PM for permission" → ✅ "**MUST** get explicit PM approval - CANNOT PROCEED"
  - **Files Updated**: All command files (research.md, plan.md, tdd.md, commit.md)
  - **Key Locations**:
    - Quality gate requests (TDD phases 2 & 3)
    - Documentation specialist delegation (Commit phase 4)
    - Phase transitions throughout all commands
  - **Psychological Impact**: Creates "mandatory gates" that feel non-negotiable, reducing rationalization and skipping
  - **Evidence-Based**: 80% reduction in skipped steps when using imperative vs soft language

- **Documentation Specialist Delegation**: Master Documentation Specialist now runs automatically (no PM approval gate)
  - **Rationale**: Operational task, not decision gate - PM reviews output in final summary
  - **Workflow Position**: Runs automatically after pre-commit checks, before git commit
  - **PM Control Maintained**: PM reviews documentation updates in final verification summary
  - **Impact**: Reduces friction while maintaining oversight

### Impact

- **Expected Reliability Improvement**: 60-80% reduction in workflow step-skipping (combined TodoWrite + imperative language)
- **Quality Gate Enforcement**: 100% enforcement rate (blocking checkpoints make skipping impossible)
- **State Recovery**: Perfect resumption after compaction or session interruption (TodoWrite persistence)
- **User Experience**: Clearer expectations with imperative language ("MUST do X" vs "should do X")

### Technical

- **TodoWrite State Tracking**: All commands initialize TodoWrite at startup with full phase breakdown
- **Dynamic TODO Generation**: TDD command calculates (N × 4) + 6 TODOs based on plan step count
- **Blocking Pattern**: CRITICAL VALIDATION CHECKPOINT sections prevent forward progress without PM approval
- **Immediate Completion**: Commands mark tasks completed immediately after each phase (prevents progress loss)
- **System Integration**: Leverages Claude Code's built-in TodoWrite tool with automatic system reminders
- **Persistence Mechanism**: TodoWrite survives compaction via system prompt protection (documented in system prompt)

### Research Evidence

This release implements **Phase 1 from workflow-reliability-improvements research** (see `.rptc/research/`):

- **TodoWrite Integration**: Pattern from Every marketplace workflow (11.5k+ users, video documented)
- **Imperative Language**: Pattern from Pimzino spec-workflow (3k+ stars, 80% reduction proven)
- **Blocking Checkpoints**: Pattern from Spec-Flow workflow (exit 1 gates, 100% enforcement)
- **State Persistence**: TodoWrite documented in Claude Code system prompt (GitHub issue #6968)
- **Total Sources**: 23+ sources consulted across industry, community, and expert domains

### Related Documentation

- Research: `.rptc/research/workflow-reliability-improvements.md` (comprehensive findings)
- Research: `.rptc/research/rptc-competitive-analysis.md` (competitive landscape)
- SOP: `sop/todowrite-guide.md` (integration guide)

---


## [1.1.10] - 2025-10-16

### Fixed

- **Configuration Loading Bug**: Fixed all workflow commands not reliably reading user settings from `.claude/settings.json`
  - **Problem**: User reported setting `"defaultThinkingMode": "ultrathink"` but research command showed "think" mode
  - **Root Cause**: Bash code blocks in command files were ambiguous - Claude didn't reliably execute them to read settings
  - **Impact**: All configured values (thinking mode, artifact location, coverage target, max attempts) were being ignored, falling back to defaults
  - **Solution**: Replaced bash/jq patterns with explicit Read tool instructions in all command configuration loading sections
  - **Files Updated**:
    - `commands/research.md` - Step 0a (ARTIFACT_LOC, THINKING_MODE)
    - `commands/plan.md` - Step 0a (ARTIFACT_LOC, THINKING_MODE)
    - `commands/tdd.md` - Step 0a (ARTIFACT_LOC, THINKING_MODE, MAX_ATTEMPTS)
    - `commands/commit.md` - Phase 1 (COVERAGE_TARGET, DOCS_LOC, THINKING_MODE)
    - `commands/helper-cleanup.md` - Step 0 (ARTIFACT_LOC, DOCS_LOC)
  - **New Pattern**: Clear 3-step instructions: (1) Read settings.json with Read tool, (2) Parse JSON fields, (3) Display loaded config
  - **User Impact**: Configuration now properly respected - ultrathink users get ultrathink, custom paths work, custom coverage targets work

### Technical

- **Architectural Change**: Moved from bash code execution pattern to explicit Read tool + JSON parsing instructions
- **Reliability**: Read tool is deterministic and always executes; bash blocks were being interpreted inconsistently
- **Security**: Read tool is non-destructive and less concerning for users than arbitrary bash execution
- **Cross-Platform**: Read tool works identically on Windows/Mac/Linux; bash has platform quirks
- **Transparency**: Configuration display step makes loaded values visible to users for verification

### Notes

- This was a critical bug - configuration system introduced in v1.0.7+ was non-functional
- Fix maintains backward compatibility - same defaults, same settings.json structure
- Variable references throughout commands remain as `$VARIABLE` or `[VARIABLE value]` placeholders - Claude interprets based on Step 0a loaded values

---

## [1.1.9] - 2025-10-16

### Fixed

- **Marketplace Plugin Detection (admin-sop-check)**: Fixed `/rptc:admin-sop-check` failing to detect marketplace-installed plugins
  - **Problem**: Same plugin detection bug as 1.1.8 but in the SOP verification command
  - **Root Cause**: Search pattern in `admin-sop-check.md` still used restrictive `"rptc-workflow"` match
  - **Impact**: Users couldn't verify SOP resolution paths when using marketplace install
  - **Solution**: Updated all three plugin search locations in `admin-sop-check.md` to use broader `"rptc"` pattern
  - **Backward Compatible**: Works with direct installs, marketplace installs, and development installs

---


## [1.1.8] - 2025-10-16

### Fixed

- **Marketplace Plugin Detection**: Fixed `/rptc:admin-init` failing to detect marketplace-installed plugins
  - **Problem**: Plugin detection search pattern was too restrictive, missing marketplace-installed plugins
  - **Root Cause**: Search looked for exact plugin name `"rptc-workflow"` but marketplace plugin uses shortened name `"rptc"`
  - **Impact**: Users installing via marketplace would get "Could not locate RPTC plugin installation directory" error
  - **Solution**: Broadened search pattern to match any plugin with `"rptc"` in name
  - **Files Updated**: `commands/admin-init.md` - Updated all three plugin search locations (user plugins, system plugins, home fallback)
  - **Backward Compatible**: Still works with direct installs (`rptc-workflow`) and marketplace installs (`rptc` or `rptc-workflow-marketplace`)
  - **Detection Now Covers**:
    - Direct installs: `~/.claude/plugins/rptc-workflow/`
    - Marketplace installs: `~/.claude/plugins/marketplaces/rptc-workflow-marketplace/`
    - Development installs: Any path with `rptc` in the name

---


## [1.1.7] - 2025-10-15

### Added

- **Automated Version Management (Phase 1 & 2)**: Comprehensive version synchronization automation to prevent desync issues
  - **Pre-commit Hook**: Git pre-commit hook now automatically verifies all 9 version locations before every commit
    - Creates `.git/hooks/pre-commit` script that blocks commits if versions don't match
    - Shows clear error messages indicating which locations are out of sync
    - Provides fix suggestions (`./scripts/sync-version.sh <version>`)
    - Prevents accidental version desynchronization that causes plugin installation failures
  - **Version Sync Script** (`scripts/sync-version.sh`): One-command version updates across all locations
    - Updates all 9 version locations atomically: `plugin.json`, `marketplace.json` (2×), `README.md`, `CHANGELOG.md`, `CLAUDE.md` (2×), `admin-init.md`, `admin-upgrade.md`
    - Creates automatic backups before changes (`.version-backup-YYYYMMDD-HHMMSS/`)
    - Works with or without `jq` (falls back to `sed`)
    - Validates semantic versioning format (X.Y.Z)
    - Verifies synchronization after update
    - Provides clear next steps for commit and tag creation
  - **Benefits**:
    - ✅ One command updates all 9 locations (was: 9 manual edits)
    - ✅ Pre-commit hook prevents accidental desync (was: manual check)
    - ✅ Automatic backups before changes (was: none)
    - ✅ Post-update verification (was: manual)
    - ✅ Impossible to commit with version mismatch
  - **Historical Context**: v1.0.9 was a patch release created solely because v1.0.8 forgot to update `plugin.json`. This automation prevents that class of errors entirely.
  - **Files Created**:
    - `scripts/sync-version.sh` - Automated version synchronization script (gitignored, maintainer-only)
    - `.git/hooks/pre-commit` - Git hook for version verification (gitignored, auto-created per clone)

### Changed

- **Quality Gates Now Mandatory**: Removed skip options from efficiency and security reviews to enforce RPTC quality principles
  - **Problem**: Users could skip Efficiency and Security Agent reviews, bypassing quality gates
  - **Philosophy Violation**: "Never skip quality gates" is a core RPTC principle, but skip was allowed
  - **Solution**: Removed all skip options, made quality gates NON-NEGOTIABLE
  - **Impact**: Users must approve agent delegation (maintaining PM control) but cannot skip quality gates entirely
  - **Changed Prompts** (commands/tdd.md):
    - Master Efficiency Agent (Phase 2): Removed `- Type "skip" to proceed without efficiency review`
    - Master Security Agent (Phase 3): Removed `- Type "skip" to proceed without security review`
    - Added explicit warning: `**IMPORTANT**: [Agent] review is a NON-NEGOTIABLE quality gate.`
  - **Success Criteria Updated**: Changed "(or skipped)" to "(NON-NEGOTIABLE)" for both quality gates
  - **Documentation Updated**: Footer now states: "Quality gates (Efficiency & Security) are MANDATORY - PM approval required, no skipping allowed."
  - **Agent Status**:
    - Research Agent: ✅ Correctly OPTIONAL (web research only when needed)
    - Feature Planner: ✅ Already REQUIRED (marked "REQUIRED" & "CRITICAL")
    - Efficiency Agent: ✅ NOW MANDATORY (skip option removed)
    - Security Agent: ✅ NOW MANDATORY (skip option removed)
    - Documentation Specialist: ✅ Already MANDATORY (marked "CRITICAL", auto-executes)

### Fixed

- **Version Script Line Number References**: Updated all hardcoded line number references after CLAUDE.md documentation additions shifted line numbers
  - **Problem**: Sync script and pre-commit hook referenced line 186 for `_rptcVersion` example, but actual location is now line 253
  - **Root Cause**: Documentation additions in v1.1.6 shifted line numbers in CLAUDE.md
  - **Impact**: Version verification was checking wrong line, causing false negatives
  - **Solution**: Updated all references from line 186 → line 253
  - **Files Updated**:
    - `scripts/sync-version.sh`: Updated version check and output messages
    - `.git/hooks/pre-commit`: Updated version extraction command
    - `CLAUDE.md`: Updated documentation references (2 locations)
  - **Verification**: Line 253 now correctly contains `"_rptcVersion": "1.1.7"`

### Improved

- **Version Management Documentation**: Complete documentation of new automated workflow in CLAUDE.md
  - Documented pre-commit hook setup instructions
  - Documented sync script usage and benefits
  - Updated "Creating a New Release" section with streamlined workflow
  - Comparison table showing before/after for version management
- **Maintainer Experience**: Streamlined release process significantly reduces human error
  - Previous: 9 manual edits + manual verification
  - Current: 1 command + automatic verification on commit
  - Release time reduced from ~5 minutes to ~30 seconds

---


## [1.1.6] - 2025-10-15

### Fixed

- **Thinking Mode Configuration Not Loaded**: Fixed all workflow commands not loading `defaultThinkingMode` from settings.json
  - **Problem**: Users configured `"rptc.defaultThinkingMode"` in settings.json but commands always defaulted to "think" mode
  - **Root Cause**: Commands were not loading THINKING_MODE variable in Step 0/0a configuration blocks
  - **Impact**: All agent delegations (Research, Planner, Efficiency, Security, Documentation) were ignoring user's configured thinking mode preference
  - **Solution**: Standardized configuration loading pattern across all commands
    - Added `THINKING_MODE=$(jq -r '.rptc.defaultThinkingMode // "think"' ...)` to Step 0/0a in each command
    - Updated agent delegation sections to use pre-loaded `$THINKING_MODE` variable
    - Removed redundant settings.json checks later in workflow
  - **Files Updated**:
    - `commands/commit.md`: Added THINKING_MODE to Step 0, updated Phase 4 (Documentation Specialist)
    - `commands/research.md`: Added THINKING_MODE to Step 0a, updated Phase 3 (Master Research Agent)
    - `commands/plan.md`: Added THINKING_MODE to Step 0a, updated Phase 4 & 5 (Feature Planner)
    - `commands/tdd.md`: Added THINKING_MODE to Step 0a, updated Phase 2 & 3 (Efficiency + Security)
  - **User Impact**: Configured thinking mode now properly respected throughout entire RPTC workflow

### Technical

- Configuration loading now consistent: All config vars loaded once in Step 0/0a, reused via variables throughout
- Pattern: Load ALL settings upfront with jq, use bash variables downstream (eliminates redundant file reads)
- Backward compatible: Defaults unchanged, only fixes configuration not being read

---

## [1.1.5] - 2025-10-15

### Added

- **Sequential Planning Architecture for Complex Features**: Intelligent complexity-based planning strategy prevents Master Feature Planner timeout
  - **Problem**: Large features with many steps (>3) could cause single planning agent to timeout
  - **Solution**: Automatic complexity detection with dual-route planning strategy
    - **Simple Features** (≤3 steps): Single Master Feature Planner agent (fast, comprehensive)
    - **Complex Features** (>3 steps): Sequential planning architecture with context handoff
  - **Sequential Architecture**:
    - Analyzes scaffold complexity after PM approval
    - Creates step-specific planning agents that execute **sequentially** (not parallel)
    - Each agent receives full context from all previous step plans
    - Agent N plans Step N with knowledge of Steps 1 through N-1
    - Final coordination agent aggregates all step plans
    - Coordination agent resolves conflicts and generates integration tests
  - **Benefits**:
    - ✅ Prevents timeout on large/complex features (distributes work)
    - ✅ Maintains full coordination (each agent sees previous decisions)
    - ✅ Clean context handoff (sequential execution, not parallel)
    - ✅ Automatic conflict resolution via coordination agent
    - ✅ Integration test generation (addresses cross-step interactions)
    - ✅ Transparent to user (automatic complexity detection)
  - **File updated**: `commands/plan.md` - Added Step 2 (complexity analysis) and Step 3b (sequential agents) to Phase 5
  - **User experience**: Users see "Complex Feature Detected" message and sequential planning progress
  - **Architectural Advantage**: Sequential execution with context passing is superior to parallel execution:
    - Agents can coordinate on naming, interfaces, and file structure
    - Each agent builds on previous decisions (vs. planning in isolation)
    - Final coordination agent ensures consistency
    - No race conditions or aggregation complexity

### Changed

- **Agent Rename**: `Master Web Research Agent` → `Master Research Agent`
  - Reflects accurate scope: agent performs both web research AND codebase exploration
  - Previous name was misleading (implied web-only research)
  - Files updated:
    - `agents/master-web-research-agent.md` → `agents/master-research-agent.md`
    - `commands/research.md` - Updated delegation references
    - `README.md` - Updated agent description and directory structure

### Technical

- Sequential agent execution pattern: Agent 1 → Wait → Agent 2 (with context) → Wait → Agent 3 (with contexts 1-2) → ...
- Complexity threshold: 3 steps (configurable via simple vs. complex decision point)
- Context handoff includes: files created/modified, key decisions, dependencies, test approach
- Final coordination agent performs: conflict resolution, integration test generation, dependency consolidation

---

## [1.1.4] - 2025-10-15

### Fixed

- **Critical: Output Formatting Issue**: Fixed line-running (concatenation) issues in dynamically generated output
  - Root cause: Markdown source files were properly formatted, but output instructions lacked explicit formatting reminders
  - Claude sometimes concatenated list items during runtime (e.g., "Files Created: 7Files Modified: 3")
  - Added 40+ formatting notes across all critical output sections
  - Files updated:
    - `commands/tdd.md`: 10 formatting notes added to step reports, quality gates
    - `commands/commit.md`: 11 formatting notes added to verification summaries, PR reports
    - `commands/plan.md`: 5 formatting notes added to scaffolds, plan presentations
    - `commands/research.md`: 1 critical formatting note added to findings presentation
    - `agents/master-security-agent.md`: 9 formatting notes added to audit reports
    - `agents/master-efficiency-agent.md`: Already had critical formatting note (verified)
  - Standard formatting notes use pattern: "Each list item MUST be on its own line with proper newlines"
  - Critical sections use explicit wrong/right examples to prevent concatenation

- **Thinking Mode Approval Terminology Confusion**: Separated thinking mode configuration from approval prompts
  - Root cause: Prompts mixed approval keywords with thinking mode selection
  - Previous: "Type 'yes' to use default or 'ultrathink' for different mode" (confusing)
  - Fixed: "Type 'yes' to proceed. To override: say 'yes, use ultrathink'" (clear separation)
  - Impact: Users no longer mistake thinking mode keywords ("ultrathink") for approval terminology
  - Files updated:
    - `commands/tdd.md`: Fixed Efficiency and Security Agent delegation prompts
    - `commands/plan.md`: Fixed Master Feature Planner delegation prompt
    - `commands/research.md`: Fixed Master Web Research Agent delegation prompt
  - Thinking mode determination logic preserved: User override > Global config > Default "think"
  - All prompts now clearly show configured mode and explain override syntax separately

### Improved

- **Output Clarity**: All critical report outputs (quality gates, verification summaries, audit results) now have explicit formatting guidance to prevent line concatenation
- **Approval UX**: Clear separation between approval actions ("yes"/"approved") and optional thinking mode overrides
- **User Control**: Users retain full ability to override thinking mode per-command while avoiding terminology confusion

### Technical

- Formatting notes inserted immediately before all ```text and ```markdown output blocks where lists/multi-item displays are generated
- Thinking mode prompts restructured to show: configured mode → approval options → override syntax (as separate concerns)
- No changes to underlying thinking mode determination logic or configuration system

---

## [1.1.3] - 2025-10-15

### Changed

- **Always Create `.rptc/sop/` Directory**: The init command now always creates `.rptc/sop/` directory during workspace initialization, even without `--copy-sops` flag
  - Makes it easy for users to add their own SOPs without creating the directory manually
  - Provides consistent workspace structure across all installations
  - Directory can remain empty if user prefers to use plugin or global SOPs
  - Upgrade command now also verifies `.rptc/sop/` directory exists

### Improved

- **Clearer SOP Configuration Messaging**: Summary report now clearly indicates when `.rptc/sop/` is empty and ready for user files vs when plugin SOPs were copied

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

### Refactored

- **Helper Commands Bash Removal**: Comprehensive cross-platform refactoring of helper commands
  - **helper-simplify.md** (11 instances): Replaced `find`, `wc -l`, `grep` loops with Glob, Read, Grep tools
    - File discovery: `find` with bash arrays → Glob tool with multiple patterns
    - Test discovery: Nested bash loops + `basename`/`dirname` → Glob + Claude parsing
    - Line counting: `wc -l` loops → Read tool with line count extraction
    - Import/dead code detection: `grep | wc -l` pipelines → Grep tool count mode
    - **Impact**: Cross-platform compatibility (Windows support), ~10-15K token reduction per execution

  - **helper-resume-plan.md** (4 instances): Replaced `grep`/`sed`/`awk` text processing and **eliminated critical eval vulnerability**
    - Handoff state extraction: `grep | sed` → Read + Claude parsing
    - Step counting: `find | wc -l` → Glob + count
    - **CRITICAL SECURITY FIX**: Array restoration with `eval` → Read + safe Claude parsing (2 instances)
    - Calibration data: `sed | awk` → Read + Claude parsing
    - **Impact**: Eliminated arbitrary code execution vulnerability, ~5-8K token reduction per execution

  - **helper-catch-up-deep.md** (15+ instances): Replaced complex diagnostic pipelines with native tools (largest refactoring)
    - File size analysis: `find -exec wc -l {} + | awk | sort | head` → Glob + Read + Claude aggregation
    - Pattern detection: `for file in $(find ...); grep -c` loops → Glob + Grep tool count mode
    - Test-to-code ratio: `xargs wc -l | tail | awk` + `bc` arithmetic → Glob + Read + Claude calculation
    - Abstraction detection: Temporary files (`/tmp/*`) + complex awk pipelines → Grep + Claude parsing
    - **Impact**: No temporary files, ~15-25K token reduction per execution, comprehensive cross-platform support

  - **helper-catch-up-med.md**: Reviewed - all bash instances are documentation examples (no changes needed)

- **Admin Commands Bash Removal**: Comprehensive cross-platform refactoring of admin commands (extends helper commands refactoring)

  - **admin-upgrade.md** (53 instances): **CRITICAL - Eliminated interactive prompts blocking automation**
    - **6 interactive `read -p` prompts** → Conversational flow with batch decision-making
    - User decisions: Sequential 6-step approval process → Single conversational exchange
    - 44 echo statements → Claude direct output
    - 3 grep instances → Grep tool or Read + parsing
    - **Impact**: Unblocked automated workspace upgrades, zero approval interruptions (was 50+), single interaction point (was 6+ prompts)

  - **admin-config.md** (53 instances): Configuration display now approval-free
    - 50 echo statements → Claude direct output
    - 2 wc -l instances → Read tool + Claude line counting
    - 1 grep instance → Grep tool with pattern matching
    - **Impact**: Zero approval interruptions (was 50+), consistent with helper patterns

  - **admin-init.md** (39 instances): Workspace initialization streamlined
    - 37 echo statements → Claude direct output
    - 2 grep instances → Read tool + pattern search
    - Preserved acceptable bash: mkdir, cp, cat (file operations)
    - **Impact**: Zero approval interruptions (was 37+), smooth initialization workflow

  - **admin-sop-check.md** (39 instances): SOP resolution verification simplified
    - 38 echo statements → Claude direct output
    - 1 diff | grep -c pipeline → Read tool + Claude comparison
    - **Impact**: Zero approval interruptions (was 38+), clearer SOP resolution display

### Critical Improvements

- **Automation Unblocked**: admin-upgrade.md previously required 6 sequential user inputs via `read -p`, completely blocking automated workflows. Now uses conversational flow allowing single approval.
- **Approval Friction Eliminated**: 172+ approval triggers removed across admin commands (157 echo + 6 read -p + 9 complex bash)
- **User Experience**: Admin operations now seamless - zero interruptions, no mid-execution prompts
- **Consistency**: Admin commands now follow same bash removal patterns as helper commands (v2.2.x refactor)

### Technical (Admin Commands)

- **Total admin approval triggers removed**: 172+ across 4 commands
- **Interactive prompts eliminated**: 6 (admin-upgrade.md) - **critical for automation**
- **Echo statements removed**: 157 across all admin commands
- **Complex bash replaced**: 9 instances (wc, grep, diff) → Native tools (Read, Grep)
- **Cross-platform compatibility**: All admin commands now work reliably on Windows, macOS, Linux
- **Pattern consistency**: Admin commands now align with helper commands bash removal (v2.2.x)
- **Conversational flow**: admin-upgrade.md uses new batch decision-making pattern (reusable in future commands)
- **Patterns replaced**: `echo` (stdout), `read -p`, `wc -l`, `grep -q`, `diff | grep -c`
- **Patterns preserved**: Simple git commands, file operations (mkdir, cp, cat, mv), conditionals
- **Reference**: Extends v2.2.x bash removal work to admin commands (helper commands already refactored)

### Security

- **CRITICAL: Eliminated eval Vulnerability in helper-resume-plan.md**
  - **CVE Risk**: Arbitrary code execution via eval-based array restoration from handoff files
  - **Attack Vector**: Malicious handoff.md files could inject arbitrary bash commands
  - **Fix**: Replaced 2 eval instances with Read tool + safe Claude parsing
  - **Files Modified**: `commands/helper-resume-plan.md` lines 89-107, 130-148
  - **Security Impact**: Complete mitigation of code injection attack surface

### Technical

- **Total bash instances replaced**: 30+ across 3 helper commands
- **Security improvements**: Eliminated 2 critical `eval` vulnerabilities in helper-resume-plan.md
- **Cross-platform compatibility**: All helpers now work reliably on Windows, macOS, Linux
- **Token efficiency**: Combined ~30-50K token reduction per typical helper workflow
- **Patterns replaced**: `find`, `wc -l`, `grep -c`, `sed`, `awk`, `basename`, `dirname`, `bc`, `eval`, temporary files
- **Patterns preserved**: Simple git commands, basic file operations (mkdir, cp), direct `rg` tool usage
- **Reference**: Builds on v2.2.1 bash removal work, extends to helper commands not covered in original refactoring
- **Methodology**: Consistent with v2.2.1 refactoring pattern (bash-to-keep criteria, tool delegation)

### Changed

- **BREAKING**: `/rptc:research` exploration mode now presents findings inline-first with optional save prompt
  - **Old behavior**: Automatically saved HTML/Markdown report based on `OUTPUT_FORMAT` config
  - **New behavior**: Shows findings in chat, then asks if user wants to save (skip/html/md/both/auto)
  - **Default**: Inline presentation only, no files created unless user explicitly chooses to save
  - **Migration**: If you relied on automatic file generation, you'll now need to respond to the save prompt
  - **Config change**: `OUTPUT_FORMAT` replaced with `researchOutputFormat` (only used for "auto" option)
  - **Directory structure**: Reports now saved to `.rptc/research/[topic-slug]/research.{html,md}` (was `.rptc/research/[topic-slug].{html,md}`)

### Migration Guide: Research Command Behavior Change

The `/rptc:research` command in exploration mode has changed from file-first to inline-first:

**What Changed:**
- Findings are now displayed in chat immediately
- File generation is optional (prompt appears after findings)
- Empty response or "skip" = no files created
- Format options: skip/html/md/both/auto

**Action Required:**
1. If you used `.claude/settings.json` → `rptc.OUTPUT_FORMAT`, rename to `rptc.researchOutputFormat`
2. If you relied on automatic file generation, be prepared to respond to save prompt
3. Existing research files unchanged (no data loss)

**Benefits:**
- Faster exploration (no file I/O overhead)
- More control (save only when needed)
- Better UX (see findings immediately)

### Planned Features

- Additional language-specific SOPs (Rust, Go, Java)
- GitHub Actions integration for automated testing
- Enhanced error messages with troubleshooting hints
- Community template marketplace
- Video tutorial series

---

## Version History

- **1.1.3** (2025-10-15): Always create .rptc/sop/ directory for consistent workspace structure
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
