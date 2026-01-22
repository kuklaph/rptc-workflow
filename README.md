# RPTC Workflow Plugin

> Research → Plan → TDD → Commit: Systematic development workflow with PM collaboration and quality gates

**Version**: 2.8.0
**Status**: Beta
**License**: MIT

---

## Quick Start

### Installation (Plugin Method - Recommended)

```bash
# Step 1: Add the marketplace
/plugin marketplace add https://github.com/kuklaph/rptc-workflow

# Step 2: Install the plugin
/plugin install rptc

# Step 3: Initialize workspace
/rptc:admin-init
```

---

## What is RPTC?

RPTC is a structured development workflow that puts **YOU in control** as the Project Manager, with Claude as your collaborative partner.

### The Workflow

```text
RESEARCH → PLAN → TDD → COMMIT
```

1. **Research**: Interactive discovery with brainstorming
2. **Plan**: Collaborative planning with Master Feature Planner
3. **TDD**: Test-driven implementation with quality gates
4. **Commit**: Comprehensive verification before shipping

### Core Principles

- **You are the PM**: Final decision authority
- **TDD is non-negotiable**: Tests always written first
- **Ask permission, not forgiveness**: Explicit approvals required
- **Quality gates matter**: Efficiency & Security reviews

---

## Commands

### Core Workflow

| Command                     | Purpose                | When to Use             |
| --------------------------- | ---------------------- | ----------------------- |
| `/rptc:research "topic"`    | Interactive discovery  | Complex/unfamiliar work |
| `/rptc:plan "feature"`      | Collaborative planning | Medium to complex work  |
| `/rptc:tdd "@plan/"`        | TDD implementation     | Always (TDD required)   |
| `/rptc:tdd "@native:name"`  | TDD with Claude's native plan | Use existing Claude plan |
| `/rptc:commit [pr]`         | Verify and ship        | Ready to commit         |

### Helper Commands

| Command                                           | Purpose                | Duration    |
| ------------------------------------------------- | ---------------------- | ----------- |
| `/rptc:helper-catch-up-quick`                     | Quick project context  | 2 min       |
| `/rptc:helper-catch-up-med`                       | Medium project context | 5-10 min    |
| `/rptc:helper-catch-up-deep`                      | Deep project analysis  | 15-30 min   |
| `/rptc:helper-update-plan "@plan/" "changes"`     | Modify existing plan   | As needed   |
| `/rptc:helper-resume-plan "@plan/"`               | Resume previous work   | After break |
| `/rptc:helper-cleanup`                            | Review completed plans | Periodic    |
| `/rptc:helper-simplify`                           | Simplify existing code complexity | As needed   |
| `/rptc:sync-prod-to-tests "[directory]"`          | Sync tests to production code with auto-fix | As needed   |

### Admin Commands

| Command                                       | Purpose                        |
| --------------------------------------------- | ------------------------------ |
| `/rptc:admin-init [--copy-sops] [--global]`   | Initialize workspace           |
| `/rptc:admin-config`                          | Show configuration             |
| `/rptc:admin-sop-check [name]`                | Verify SOP resolution          |
| `/rptc:admin-upgrade`                         | Upgrade workspace to latest version |

---

## Workflow Patterns

### Pattern 1: Simple Bug Fix

```bash
# Skip research/planning, go straight to TDD
/rptc:tdd "fix login error with special characters"
/rptc:commit
```

### Pattern 2: Medium Work (Familiar Code)

```bash
# Skip research, plan directly
/rptc:plan "add user profile avatar upload"
/rptc:tdd "@user-avatar-upload/"
/rptc:commit pr
```

### Pattern 3: Complex Work (Full Workflow)

```bash
# Get context first
/rptc:helper-catch-up-med

# Interactive research
/rptc:research "payment processing integration"

# Collaborative planning
/rptc:plan "payment processing integration"

# TDD implementation with quality gates
/rptc:tdd "@payment-processing/"

# Verify and ship
/rptc:commit pr
```

---

## Advanced Features

### Test-Driven Generation (TDG) Mode

**Purpose:** AI-accelerated comprehensive test generation from plan specifications to dramatically reduce TDD overhead.

**Benefits:**
- Reduces TDD overhead by ~80% (~50 tests in <5 min vs. 10-20 min manually)
- Augments manually-planned scenarios (not replaces)
- Diverse coverage: happy path variations, edge cases, error conditions
- Respects implementation constraints from plan

**Usage:**

```bash
# Standard TDD execution
/rptc:tdd "@plan-name/"

# With Test-Driven Generation mode (AI-accelerated test generation)
/rptc:tdd "@plan-name/" --tdg

# TDG generates ~50 additional tests per step in <5 minutes
# Augments planned test scenarios (not replaces)
```

**Configuration:** Opt-in by default. Set `tdgMode: "enabled"` in `.claude/settings.json` to always use TDG.

**Strategy:** AUGMENTATION (planned scenarios + AI-generated tests)

**When to use TDG:**
- Complex features with many edge cases
- New implementations requiring comprehensive coverage
- Security-critical code (thorough error condition testing)
- Unfamiliar domains (AI suggests test scenarios you might miss)

**When to skip TDG:**
- Simple CRUD operations (planned tests sufficient)
- Refactoring with existing test coverage
- Hot fixes (time pressure, manual tests faster)
- Exploratory work (test strategy unclear)

---

## SOP (Standard Operating Procedure) System

### SOP Fallback Chain

SOPs are resolved in this order (highest priority first):

```text
1. Project:  .rptc/sop/testing-guide.md
2. User:     ~/.claude/global/sop/testing-guide.md
3. Plugin:   ${CLAUDE_PLUGIN_ROOT}/sop/testing-guide.md
```

### Customizing SOPs

**For this project only**:

```bash
/rptc:admin-init --copy-sops
# Copies SOPs to .rptc/sop/ for customization
```

**For all your projects**:

```bash
/rptc:admin-init --copy-sops --global
# Copies SOPs to ~/.claude/global/sop/ as defaults
```

**Verify which SOP is being used**:

```bash
/rptc:admin-sop-check testing-guide
# Shows which file will be loaded
```

### Available SOPs

- `testing-guide.md` - Testing frameworks, patterns, TDD guidance
- `flexible-testing-guide.md` - Flexible assertions for AI-generated and non-deterministic code; extends testing-guide with semantic similarity, behavioral testing, and safety mechanisms
- `architecture-patterns.md` - Architecture and design patterns
- `frontend-guidelines.md` - Frontend design, visual style, accessibility
- `git-and-deployment.md` - Git workflow, CI/CD, deployment
- `languages-and-style.md` - Language conventions, formatters, linters
- `security-and-performance.md` - Security practices, performance optimization
- `post-tdd-refactoring.md` - Comprehensive 5-phase refactoring checklist for efficiency agent. Includes Code Simplicity metrics, Rule of Three abstraction framework, AI over-engineering detection, and tool configurations by language
- `todowrite-guide.md` - TodoWrite integration patterns, state management, and best practices for progress tracking
- `test-sync-guide.md` - Test-production matching algorithms, sync verification criteria, and auto-fix strategies for keeping tests aligned with production code

---

## Directory Structure

### Plugin Structure

```text
rptc-workflow/
├── .claude-plugin/
│   ├── plugin.json              # Plugin metadata
│   └── marketplace.json         # Marketplace listing
├── commands/
│   ├── research.md              # /rptc:research
│   ├── plan.md                  # /rptc:plan
│   ├── tdd.md                   # /rptc:tdd
│   ├── commit.md                # /rptc:commit
│   ├── helper-catch-up-quick.md # /rptc:helper-catch-up-quick
│   ├── helper-catch-up-med.md   # /rptc:helper-catch-up-med
│   ├── helper-catch-up-deep.md  # /rptc:helper-catch-up-deep
│   ├── helper-update-plan.md    # /rptc:helper-update-plan
│   ├── helper-resume-plan.md    # /rptc:helper-resume-plan
│   ├── helper-cleanup.md        # /rptc:helper-cleanup
│   ├── sync-prod-to-tests.md    # /rptc:sync-prod-to-tests
│   ├── admin-init.md            # /rptc:admin-init
│   ├── admin-config.md          # /rptc:admin-config
│   ├── admin-sop-check.md       # /rptc:admin-sop-check
│   └── admin-upgrade.md         # /rptc:admin-upgrade
├── agents/
│   ├── master-research-agent.md
│   ├── master-feature-planner-agent.md
│   ├── master-efficiency-agent.md
│   ├── master-security-agent.md
│   ├── master-documentation-specialist-agent.md
│   ├── master-test-sync-agent.md
│   └── master-test-fixer-agent.md
├── sop/                         # Default SOPs (read-only)
│   ├── testing-guide.md
│   ├── flexible-testing-guide.md
│   ├── test-sync-guide.md
│   ├── architecture-patterns.md
│   ├── frontend-guidelines.md
│   ├── git-and-deployment.md
│   ├── languages-and-style.md
│   └── security-and-performance.md
├── templates/                   # Templates for user artifacts
│   ├── research.md
│   └── plan.md
├── docs/
│   ├── RPTC_WORKFLOW_GUIDE.md  # Complete guide
│   └── PROJECT_TEMPLATE.md     # CLAUDE.md template
└── README.md                    # This file
```

### User Project Structure (After Init)

```text
your-project/
├── .rptc/                       # RPTC workspace
│   ├── CLAUDE.md                # RPTC workflow instructions (auto-created)
│   ├── research/                # Active research findings
│   │   └── feature-x.md
│   ├── plans/                   # Active/completed plans
│   │   └── feature-x.md
│   └── complete/                # Completed plans (optional)
├── docs/                        # Permanent documentation
│   ├── research/                # (optional, for promoted research)
│   ├── plans/                   # (optional, for promoted plans)
│   ├── architecture/            # Auto-created by Doc Specialist
│   ├── patterns/                # Auto-created by Doc Specialist
│   └── api/                     # Auto-created by Doc Specialist
├── .claude/
│   ├── settings.json            # Project settings
│   └── settings.local.json      # Local overrides (gitignored)
├── .rptc/sop/                   # Project SOPs (optional)
│   └── testing-guide.md         # Overrides plugin default
├── CLAUDE.md                    # Your project instructions (add RPTC reference)
└── .gitignore                   # Updated with RPTC entries
```

---
## Architecture Overview

### Incremental Sub-Agent Delegation (v1.2.0+)

RPTC uses an **incremental sub-agent architecture** that dramatically improves token efficiency and reliability:

**Key Benefits:**
- **79% token reduction** in TDD phase (loads only needed files per step)
- **Immediate persistence** (plan files saved as generated, not at end)
- **Better timeout handling** (distributed work prevents long-running failures)
- **Modular plans** (directory structure scales for complex features)

**How it works:**

1. **Planning Phase**: Master Feature Planner analyzes feature complexity
   - **Simple features (≤2 steps)**: Monolithic plan (single `.md` file)
   - **Complex features (>2 steps)**: Directory-based plan with sub-agents
     - Overview Generator Sub-Agent → `overview.md`
     - Step Generator Sub-Agents → `step-01.md`, `step-02.md`, etc.
     - Cohesiveness Reviewer → validates consistency

2. **TDD Phase**: Loads only necessary files per step
   - Reads `overview.md` for test strategy
   - Reads `step-NN.md` for current step only
   - **79% less context** vs loading entire monolithic plan

3. **Research Phase**: Parallel sub-agent execution
   - Discovery Q&A → Codebase exploration → Optional web search (in parallel)
   - **Intelligent web search**: Only triggers when needed (unfamiliar topics)

**Directory Structure Example:**

```text
.rptc/plans/
└── feature-name/                        # Directory format (v2.0.0+ all features)
    ├── overview.md                      # Test strategy, acceptance criteria
    ├── step-01.md                       # Individual step details
    ├── step-02.md
    └── step-03.md
```

**Usage:**

```bash
# Plan creates directory format (v2.0.0+)
/rptc:plan "add user authentication"     # Creates directory structure

# TDD uses directory format
/rptc:tdd "@user-authentication/"        # Directory-based plan (required)
```

---


## Master Specialist Agents

When you approve delegation, specialized AI agents provide expert analysis:

### Master Research Agent

**Purpose**: Research best practices through web search and codebase exploration
**When**: Research phase (optional, with permission)
**Provides**: Authoritative sources, implementation examples, pitfalls
**Architecture**: Parallel sub-agents for discovery, codebase search, and web research

### Master Feature Planner

**Purpose**: Create comprehensive TDD-ready plans
**When**: Planning phase (with permission)
**Provides**: Detailed steps, test strategy, file changes, risks
**Architecture**: Incremental sub-agent delegation with directory format (v2.0.0+ all features)

### Master Efficiency Agent

**Purpose**: Optimize code for simplicity (KISS/YAGNI)
**When**: After TDD implementation (optional, with permission)
**Provides**: Dead code removal, logic simplification, readability improvements

### Master Security Agent

**Purpose**: Identify and fix vulnerabilities
**When**: After Efficiency review (optional, with permission)
**Provides**: OWASP audit, input validation, auth/authz review, security fixes

### Master Documentation Specialist

**Purpose**: Automatic intelligent documentation
**When**: TDD phase completion (automatically invoked after optional quality gates)
**Provides**: Auto-creates permanent docs in `docs/` based on significance

### Master Test Sync Agent

**Purpose**: Analyze test-production relationships and verify synchronization
**When**: `/rptc:sync-prod-to-tests` command (analysis phase)
**Provides**: Multi-layer confidence matching, 4-level sync verification, structured mismatch reports
**Architecture**: 5-layer scoring (naming, directory, imports, semantic, intent) with MCP integration

### Master Test Fixer Agent

**Purpose**: Auto-repair test files based on sync analysis findings
**When**: `/rptc:sync-prod-to-tests` command (fix phase)
**Provides**: 4 fix scenarios (update, add, create, assertion fix) with retry logic
**Architecture**: Orchestrates fixes, delegates test generation to TDD executor agent

---

## Documentation Promotion (Automatic)

The **Master Documentation Specialist** runs during commit and intelligently decides what deserves permanent documentation:

```text
Working Artifacts (.rptc/)  →  Permanent Docs (docs/)
```

**Automatic promotion for**:

- New architecture patterns → `docs/architecture/`
- New public APIs → `docs/api/`
- New reusable patterns → `docs/patterns/`
- Security/performance changes → Update relevant docs

**No promotion for**:

- Simple bug fixes
- Internal refactors
- Trivial changes

You get to review and approve the documentation before commit.

---

## Configuration

RPTC configuration is managed through `.claude/settings.json` in your project. The plugin itself has no configurable settings - all configuration is user-controlled.

### Available Settings

All RPTC configuration lives under the `rptc` namespace in `.claude/settings.json`:

```json
{
  "rptc": {
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
```

**Configuration Options:**

| Setting | Default | Description |
|---------|---------|-------------|
| `defaultThinkingMode` | `"think"` | Default thinking mode for sub-agents: `"think"`, `"think hard"`, or `"ultrathink"` |
| `artifactLocation` | `".rptc"` | Directory for working artifacts (research, plans, complete) |
| `docsLocation` | `"docs"` | Directory for permanent documentation |
| `testCoverageTarget` | `85` | Minimum test coverage percentage (used in commit phase) |
| `maxPlanningAttempts` | `10` | Maximum auto-retry attempts during TDD implementation |
| `customSopPath` | `".rptc/sop"` | Project-specific SOP directory (for fallback chain) |
| `researchOutputFormat` | `"html"` | Default output format for research "auto" save option. Valid: `"html"` (dark-theme reports), `"md"` (editable files), `"both"` (both formats in same directory). HTML creates professional formatted reports, Markdown creates editable text files. |
| `htmlReportTheme` | `"dark"` | HTML report theme: `"dark"` (GitHub Dark with WCAG AA compliance) |
| `verificationMode` | `"focused"` | Independent verification after GREEN phase: `"focused"` (intent/coverage/overfitting only, <5 min), `"disabled"` (skip verification), `"exhaustive"` (future enhancement) |
| `tdgMode` | `"disabled"` | Test-Driven Generation mode: `"disabled"` (default, use --tdg flag to enable), `"enabled"` (always use TDG), `"auto"` (future: heuristic-based) |
| `discord.webhookUrl` | `""` | Discord webhook URL for notifications (format: `https://discord.com/api/webhooks/...`) |
| `discord.notificationsEnabled` | `false` | Enable/disable Discord workflow notifications |
| `discord.verbosity` | `"summary"` | Notification detail level: `"summary"` (milestones only), `"detailed"` (phase updates), `"verbose"` (all steps) |

**Note:** The init command (`/rptc:admin-init`) automatically creates this file with sensible defaults.

### Research Workflow

The `/rptc:research` command provides a unified workflow for interactive discovery and exploration:

**How it works:**
1. Interactive discovery through questions and codebase exploration
2. Findings presented inline immediately
3. Optional save prompt after findings displayed (skip/html/md/both/auto)
4. "auto" option uses `researchOutputFormat` config setting (default: html)
5. Uses inline/dynamic TodoWrite tracking throughout research

**Output options:**
- HTML: Professional dark-theme reports in `.rptc/research/[topic-slug]/research.html`
- Markdown: Editable text files in `.rptc/research/[topic-slug]/research.md`
- Both: Generates both formats in the same directory
- Auto: Uses configured `researchOutputFormat` preference

### Thinking Mode Configuration (v1.0.7+)

**Configure default thinking depth for all sub-agent delegations:**

RPTC sub-agents (Web Research, Feature Planner, Efficiency, Security, Documentation) support extended thinking modes with different token budgets:

| Mode | Token Budget | Best For | Default |
|------|-------------|----------|---------|
| `"think"` | ~4K tokens | Most tasks, Pro plan users | ✅ Yes |
| `"think hard"` | ~10K tokens | Complex analysis | |
| `"ultrathink"` | ~32K tokens | Maximum depth, complex features | |

**Set global default** in `.claude/settings.json`:

```json
{
  "rptc": {
    "defaultThinkingMode": "think"
  }
}
```

**How it works:**
- Commands check for global setting before prompting
- You can override per-command when prompted
- Precedence: **User choice** > **Global setting** > **Default** ("think")

**Example workflow:**

```bash
# Set global default to ultrathink (Max plan users)
echo '{
  "rptc": {
    "defaultThinkingMode": "ultrathink"
  }
}' > .claude/settings.json

# Now all sub-agents use ultrathink by default
/rptc:research "complex authentication"
# Agent automatically uses ultrathink

# Or override per-command:
/rptc:plan "simple feature"
# When prompted: "yes" uses ultrathink, or specify "think" for this one
```

**Pro plan consideration:**
Default is `"think"` (~4K tokens) to be mindful of Pro plan token limits. Max plan users can set `"ultrathink"` as their default.

---

### Discord Notifications (Optional)

RPTC supports real-time notifications via Discord webhooks for long-running workflows. Get notified when research completes, planning finishes, TDD steps progress, or quality gates pass - without watching the terminal.

#### Setup

**1. Create Discord Webhook:**
- Open Discord Server Settings > Integrations > Webhooks
- Click "New Webhook"
- Copy webhook URL (starts with `https://discord.com/api/webhooks/...`)

**2. Configure RPTC:**

Edit `.claude/settings.json`:

```json
{
  "rptc": {
    "discord": {
      "webhookUrl": "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL",
      "notificationsEnabled": true,
      "verbosity": "summary"
    }
  }
}
```

**3. Security Warning:**
- **Webhook URLs are credentials** - treat as secrets
- Add `.claude/settings.json` to `.gitignore` if committing
- Never share webhook URLs publicly
- Consider using environment variables for team projects

#### Verbosity Levels

| Level | Notifications | Best For |
|-------|--------------|----------|
| `summary` | Start + final result only | Minimal noise (default, recommended) |
| `detailed` | Start + major milestones + final | Moderate monitoring |
| `verbose` | All steps (every phase) | Debugging (may trigger rate limits) |

**Recommendation:** Start with `summary` mode to avoid notification fatigue.

#### Supported Commands

Notifications are available for:

| Command | Notifications |
|---------|--------------|
| `/rptc:research` | Research mode determined, discovery complete, saved |
| `/rptc:plan` | Planning started, scaffold complete, plan saved |
| `/rptc:tdd` | Step started, quality gates passed, implementation complete |
| `/rptc:commit` | Tests passing, committed, PR created |
| `/rptc:helper-resume-plan` | Plan resumed successfully |

#### Troubleshooting

**Notifications not working?**
1. Verify webhook URL is correct (test with curl)
2. Check `notificationsEnabled: true` in settings
3. Ensure discord-notify skill is installed (bundled with plugin)
4. Check console for warning messages

**Rate limiting?**
- Discord webhooks: 30 requests/60 seconds per webhook
- Use `summary` verbosity to avoid limits
- Avoid `verbose` mode for large features (>10 steps)

**Security concerns?**
- Webhook URLs never appear in logs or commits
- All notification failures are silent (workflow continues)
- Consider per-project webhooks for team visibility

---

## Advanced Features

### Auto-Handoff with Dynamic Prediction (Roadmap #22)

**Purpose:** Enables unlimited feature size by intelligently predicting context usage and triggering checkpoints before capacity is reached.

**Always Enabled:** Auto-handoff has no configuration - it's automatic. This ensures no plan size limitations.

**How It Works:**

RPTC uses a **hybrid prediction model** that combines three estimation methods:

1. **File-Based**: Analyzes next step file size (characters ÷ 4 × 1.25 for markdown/code mix)
2. **Historical Average**: Average of last 3 completed steps (reliable for consistent patterns)
3. **Growth Rate**: Extrapolates from recent delta trends (detects escalating complexity)

The system takes the **maximum (most conservative)** of all three methods, then applies research-validated safety factors:

- **1.5× safety multiplier** (overflow protection)
- **+3% margin** (PREDICTOKEN study recommendation)
- **Calibration adjustment** (improves accuracy after 3-5 steps)

**80% Hard Cap:**

Auto-handoff triggers when predicted next step would exceed **160,000 tokens (80% of 200K capacity)**.

**Why 80% and not 90%?**
- Research shows response quality degrades at 80-90% capacity
- 80% provides safety buffer for estimation error (±10% typical)
- MCP tools and quality gates consume additional overhead not in prediction

**When Handoff Occurs:**

```
Current Context: 155K tokens
Next Step Predicted: 12K tokens (with safety factors)
Projected Total: 167K tokens
Hard Cap: 160K tokens
Decision: HANDOFF TRIGGERED (would exceed cap)
```

**Resume Workflow:**

After handoff, continue in fresh context:

```bash
/rptc:helper-resume-plan "@feature-name/"
```

The helper:
1. Loads `handoff.md` checkpoint
2. Restores historical usage data and calibration
3. Initializes fresh context (15K starting point)
4. Continues from next uncompleted step

**Prediction Accuracy:**

- **Cold Start (Steps 1-3):** ±15-20% error (uses conservative floor of 25K/step)
- **Calibrated (Steps 4+):** ±5-10% error (hybrid model with calibration)
- **Improves Over Time:** Calibration adjusts multiplier based on actual vs predicted

**Example Handoff Checkpoint:**

```markdown
# TDD Handoff Checkpoint

**Feature:** user-authentication
**Checkpoint Date:** 2025-01-24 15:30:00
**Trigger Reason:** capacity_exceeded

## Status Summary
**Progress:** 13 of 20 steps completed (65%)
**Next Step:** 14 (step-14.md)

## Context Metrics
**Current Context Usage:** 156,000 tokens (78% of capacity)
**Projected with Next Step:** 174,000 tokens (87% of capacity)
**Why Handoff Triggered:** Next step predicted at 18K tokens, would exceed 160K hard cap

## Calibration Data (for Resume)
**Historical Usage Array:** [...preserved for next session...]
**Calibration Multiplier:** 1.05× (learned from previous steps)
**Prediction Errors:** [...tracked for accuracy improvement...]

## Resume Instructions
/rptc:helper-resume-plan "@user-authentication/"
```

**Troubleshooting:**

**Q: Handoff triggered after only 5 steps?**
A: Large step files or high complexity. Review `.rptc/tdd-prediction.log` for per-step usage. Consider splitting steps if >30K each.

**Q: Prediction consistently inaccurate?**
A: System detects this (3+ errors >20%) and switches to conservative mode. Check if MCP servers adding unexpected overhead.

**Q: Can I disable auto-handoff?**
A: No - it's always enabled. This prevents plan size limitations. Trust the prediction system or split plan manually if needed.

**Research Foundation:**

See `.rptc/research/dynamic-context-prediction.md` for complete validation:
- 25 sources (Anthropic, PREDICTOKEN, Azure, academic)
- Hybrid approach validated across domains (30-50% better than single-method)
- Safety factors proven in production systems

---

## Best Practices

### When to Use Each Phase

| Complexity      | Research    | Plan    | TDD       | Commit    |
| --------------- | ----------- | ------- | --------- | --------- |
| Bug Fix         | ❌ Skip     | ❌ Skip | ✅ Always | ✅ Always |
| Small Feature   | ❌ Skip     | ✅ Use  | ✅ Always | ✅ Always |
| Medium Feature  | ⚠️ Optional | ✅ Use  | ✅ Always | ✅ Always |
| Large Feature   | ✅ Use      | ✅ Use  | ✅ Always | ✅ Always |
| Unfamiliar Code | ✅ Use      | ✅ Use  | ✅ Always | ✅ Always |

### TDD Best Practices

1. **RED**: Write failing test first
2. **GREEN**: Minimal code to pass (auto-iterates up to 10 times)
3. **REFACTOR**: Improve code while keeping tests green
4. **VERIFY**: Run full suite

### Quality Gate Best Practices

- **Efficiency Gate**: Catches over-engineering, enforces KISS/YAGNI
- **Security Gate**: Prevents vulnerabilities before they ship
- **All tests must remain passing** after each gate

### AI Coding Best Practices

For comprehensive guidance on working effectively with AI-generated code:

- **Documentation**: `docs/AI_CODING_BEST_PRACTICES.md`
- **Topics**: Prompting strategies, red flags, simplicity directives, before/after examples
- **Read Time**: 10-15 minutes
- **Use When**: Before accepting AI code, during code review, troubleshooting AI output quality

---

## Troubleshooting

### Q: Plugin updated but workspace outdated?

```bash
/rptc:admin-upgrade
# Automatically migrates configuration to latest version
```

### Q: How do I know which SOP is being used?

```bash
/rptc:admin-sop-check testing-guide
```

### Q: Workspace not initialized?

```bash
/rptc:admin-init
```

### Q: Want to customize SOPs?

```bash
# For this project:
/rptc:admin-init --copy-sops

# For all projects:
/rptc:admin-init --copy-sops --global
```

### Q: See current configuration?

```bash
/rptc:admin-config
```

### Q: Plans cluttering .rptc/?

```bash
/rptc:helper-cleanup
# Review and archive completed plans
```

### Q: How do I set a default thinking mode for sub-agents?

```bash
# Add to .claude/settings.json:
{
  "rptc": {
    "defaultThinkingMode": "think"
  }
}

# Options: "think" (4K), "think hard" (10K), "ultrathink" (32K)
# You can override per-command when prompted
```

See [Thinking Mode Configuration](#thinking-mode-configuration-v107) for details.

---

## Migration from Bash Setup

If you previously used bash setup scripts:

1. **Your existing `.rptc/` and `.claude/` are preserved**
2. **Install plugin**: `/plugin install rptc`
3. **No re-initialization needed**: Workspace already exists
4. **Commands now use plugin versions**: Old commands still work
5. **SOPs**: Existing project SOPs will override plugin defaults

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

- **Documentation**: `docs/RPTC_WORKFLOW_GUIDE.md`
- **Issues**: https://github.com/kuklaph/rptc-workflow/issues
- **Discussions**: https://github.com/kuklaph/rptc-workflow/discussions

---

**Welcome to systematic, PM-controlled development!** 🚀
