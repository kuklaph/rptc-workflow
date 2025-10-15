# RPTC Workflow Plugin

> Research → Plan → TDD → Commit: Systematic development workflow with PM collaboration and quality gates

**Version**: 1.0.0
**Status**: Beta
**License**: MIT

---

## Quick Start

### Installation (Plugin Method - Recommended)

```bash
# Add marketplace
/plugin marketplace add kuklaph/rptc-workflow

# Install plugin
/plugin install rptc-workflow

# Initialize workspace
/rptc:admin:init
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

| Command                  | Purpose                | When to Use             |
| ------------------------ | ---------------------- | ----------------------- |
| `/rptc:research "topic"` | Interactive discovery  | Complex/unfamiliar work |
| `/rptc:plan "feature"`   | Collaborative planning | Medium to complex work  |
| `/rptc:tdd "@plan.md"`   | TDD implementation     | Always (TDD required)   |
| `/rptc:commit [pr]`      | Verify and ship        | Ready to commit         |

### Helper Commands

| Command                                         | Purpose                | Duration    |
| ----------------------------------------------- | ---------------------- | ----------- |
| `/rptc:helper:catch-up-quick`                   | Quick project context  | 2 min       |
| `/rptc:helper:catch-up-med`                     | Medium project context | 5-10 min    |
| `/rptc:helper:catch-up-deep`                    | Deep project analysis  | 15-30 min   |
| `/rptc:helper:update-plan "@plan.md" "changes"` | Modify existing plan   | As needed   |
| `/rptc:helper:resume-plan "@plan.md"`           | Resume previous work   | After break |
| `/rptc:helper:cleanup`                          | Review completed plans | Periodic    |

### Admin Commands

| Command                                     | Purpose               |
| ------------------------------------------- | --------------------- |
| `/rptc:admin:init [--copy-sops] [--global]` | Initialize workspace  |
| `/rptc:admin:config`                        | Show configuration    |
| `/rptc:admin:sop-check [name]`              | Verify SOP resolution |

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
/rptc:tdd "@user-avatar-upload.md"
/rptc:commit pr
```

### Pattern 3: Complex Work (Full Workflow)

```bash
# Get context first
/rptc:helper:catch-up-med

# Interactive research
/rptc:research "payment processing integration"

# Collaborative planning
/rptc:plan "@payment-processing.md"

# TDD implementation with quality gates
/rptc:tdd "@payment-processing.md"

# Verify and ship
/rptc:commit pr
```

---

## SOP (Standard Operating Procedure) System

### SOP Fallback Chain

SOPs are resolved in this order (highest priority first):

```text
1. Project:  .claude/sop/testing-guide.md
2. User:     ~/.claude/global/sop/testing-guide.md
3. Plugin:   ${CLAUDE_PLUGIN_ROOT}/sop/testing-guide.md
```

### Customizing SOPs

**For this project only**:

```bash
/rptc:admin:init --copy-sops
# Copies SOPs to .claude/sop/ for customization
```

**For all your projects**:

```bash
/rptc:admin:init --copy-sops --global
# Copies SOPs to ~/.claude/global/sop/ as defaults
```

**Verify which SOP is being used**:

```bash
/rptc:admin:sop-check testing-guide
# Shows which file will be loaded
```

### Available SOPs

- `testing-guide.md` - Testing frameworks, patterns, TDD guidance
- `architecture-patterns.md` - Architecture and design patterns
- `frontend-guidelines.md` - Frontend design, visual style, accessibility
- `git-and-deployment.md` - Git workflow, CI/CD, deployment
- `languages-and-style.md` - Language conventions, formatters, linters
- `security-and-performance.md` - Security practices, performance optimization

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
│   ├── helper/                  # /rptc:helper:*
│   │   ├── catch-up-quick.md
│   │   ├── catch-up-med.md
│   │   ├── catch-up-deep.md
│   │   ├── update-plan.md
│   │   ├── resume-plan.md
│   │   └── cleanup.md
│   └── admin/                   # /rptc:admin:*
│       ├── init.md
│       ├── config.md
│       └── sop-check.md
├── agents/
│   ├── master-web-research-agent.md
│   ├── master-feature-planner-agent.md
│   ├── master-efficiency-agent.md
│   ├── master-security-agent.md
│   └── master-documentation-specialist-agent.md
├── sop/                         # Default SOPs (read-only)
│   ├── testing-guide.md
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
│   └── archive/                 # Old plans (optional)
├── docs/                        # Permanent documentation
│   ├── research/                # (optional, for promoted research)
│   ├── plans/                   # (optional, for promoted plans)
│   ├── architecture/            # Auto-created by Doc Specialist
│   ├── patterns/                # Auto-created by Doc Specialist
│   └── api/                     # Auto-created by Doc Specialist
├── .claude/
│   ├── settings.json            # Project settings
│   ├── settings.local.json      # Local overrides (gitignored)
│   └── sop/                     # Project SOPs (optional)
│       └── testing-guide.md     # Overrides plugin default
├── CLAUDE.md                    # Your project instructions (add RPTC reference)
└── .gitignore                   # Updated with RPTC entries
```

---

## Master Specialist Agents

When you approve delegation, specialized AI agents provide expert analysis:

### Master Web Research Agent

**Purpose**: Find best practices and implementation patterns
**When**: Research phase (optional, with permission)
**Provides**: Authoritative sources, implementation examples, pitfalls

### Master Feature Planner

**Purpose**: Create comprehensive TDD-ready plans
**When**: Planning phase (with permission)
**Provides**: Detailed steps, test strategy, file changes, risks

### Master Efficiency Agent

**Purpose**: Optimize code for simplicity (KISS/YAGNI)
**When**: After TDD implementation (with permission)
**Provides**: Dead code removal, logic simplification, readability improvements

### Master Security Agent

**Purpose**: Identify and fix vulnerabilities
**When**: After Efficiency review (with permission)
**Provides**: OWASP audit, input validation, auth/authz review, security fixes

### Master Documentation Specialist

**Purpose**: Automatic intelligent documentation
**When**: Commit phase (automatically invoked)
**Provides**: Auto-creates permanent docs in `docs/` based on significance

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

### Plugin Settings

Configure in `.claude-plugin/plugin.json`:

```json
{
  "config": {
    "artifactLocation": ".rptc",
    "docsLocation": "docs",
    "autoPromoteToDocsOnComplete": false,
    "retentionPolicy": "prompt",
    "testCoverageTarget": 80,
    "maxPlanningAttempts": 10
  }
}
```

### Project Settings

Override in `.claude/settings.json`:

```json
{
  "rptc": {
    "testCoverageTarget": 90,
    "customSopPath": ".claude/sop"
  }
}
```

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

---

## Troubleshooting

### Q: How do I know which SOP is being used?

```bash
/rptc:admin:sop-check testing-guide
```

### Q: Workspace not initialized?

```bash
/rptc:admin:init
```

### Q: Want to customize SOPs?

```bash
# For this project:
/rptc:admin:init --copy-sops

# For all projects:
/rptc:admin:init --copy-sops --global
```

### Q: See current configuration?

```bash
/rptc:admin:config
```

### Q: Plans cluttering .rptc/?

```bash
/rptc:helper:cleanup
# Review and archive completed plans
```

---

## Migration from Bash Setup

If you previously used bash setup scripts:

1. **Your existing `.rptc/` and `.claude/` are preserved**
2. **Install plugin**: `/plugin install rptc-workflow`
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
