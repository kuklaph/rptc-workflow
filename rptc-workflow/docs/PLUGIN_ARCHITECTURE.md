# RPTC Plugin: What's Included?

## Plugin Distribution (What Users Get)

When users install the plugin with:

```bash
claude plugin install github.com/your-org/rptc-workflow
```

They get the **entire repository** cloned to their Claude plugin directory, which includes:

### ✅ Core Plugin Files (Distributed)

```text
rptc-workflow/                      # Plugin root (${CLAUDE_PLUGIN_ROOT})
├── .claude-plugin/
│   ├── plugin.json                 # Plugin metadata & config ✅
│   └── marketplace.json            # Marketplace listing ✅
│
├── commands/                       # All workflow commands ✅
│   ├── admin/*.md                  # Admin commands ✅
│   ├── helper/*.md                 # Helper commands ✅
│   └── *.md                        # Core workflow commands ✅
│
├── sop/                            # Standard Operating Procedures ✅
│   └── *.md                        # All SOP files ✅
│
├── agents/                         # Master Specialist Agents ✅
│   └── *.md                        # All agent definitions ✅
│
├── templates/                      # Document templates ✅
│   ├── research.md                 # Research template ✅
│   └── plan.md                     # Plan template ✅
│
├── docs/                           # Plugin documentation ✅
│   ├── RPTC_WORKFLOW_GUIDE.md      # Complete guide ✅
│   ├── PROJECT_TEMPLATE.md         # User project template ✅
│   └── MIGRATION_GUIDE.md          # Migration instructions ✅
│
├── scripts/                        # Utility scripts (if any) ✅
├── hooks/                          # Plugin hooks (if any) ✅
├── README.md                       # Main documentation ✅
├── LICENSE                         # License file ✅
└── CHANGELOG.md                    # Version history ✅
```

**Total distributed**: All commands, SOPs, agents, templates, and documentation

---

## ❌ NOT Included in Plugin Distribution

These files/folders are **development artifacts** or **user-specific**:

```text
rptc-workflow/                      # Your development repo
├── .rptc/                          # ❌ USER workspace (not distributed)
│   ├── plans/                      # ❌ User's personal plans
│   └── research/                   # ❌ User's personal research
│
├── legacy/                         # ❌ Development history (not distributed)
│   ├── commands/.rptc/             # ❌ Old bash commands
│   ├── agents/.rptc/               # ❌ Old agents
│   ├── setup/                      # ❌ Old bash scripts
│   └── notes/                      # ❌ Conversion notes
│
├── .git/                           # ❌ Version control (excluded)
├── .gitignore                      # ✅ But this IS included
├── .claude/                        # ❌ Your local dev settings (not distributed)
├── PLUGIN_CONVERSION_STATUS.md     # ❌ Development tracking (not distributed)
└── node_modules/                   # ❌ If you had dependencies (excluded)
```

---

## How It Works: Installation Flow

### 1. User Installs Plugin

```bash
claude plugin install github.com/your-org/rptc-workflow
```

**What happens**:

- Claude clones repo to: `~/.claude/plugins/rptc-workflow/`
- This becomes `${CLAUDE_PLUGIN_ROOT}`
- Claude registers all commands from `commands/`
- SOPs are available at `${CLAUDE_PLUGIN_ROOT}/sop/`
- Agents are available at `${CLAUDE_PLUGIN_ROOT}/agents/`

### 2. User Initializes Workspace

```bash
cd ~/my-project
/rptc:admin-init
```

**What happens**:

- Creates `.rptc/` in user's project (empty workspace)
- Creates `.rptc/plans/`, `.rptc/research/`, `.rptc/complete/`
- Optionally copies SOPs to `.rptc/sop/` (if `--copy-sops` flag used)
- User's project now has its own workspace

### 3. User Uses Workflow

```bash
/rptc:research "user authentication"
```

**What happens**:

- Command loaded from plugin: `${CLAUDE_PLUGIN_ROOT}/commands/research.md`
- SOPs loaded via fallback chain:
  1. `.rptc/sop/` (user's project overrides) ← checked first
  2. `~/.claude/global/sop/` (user's global settings) ← checked second
  3. `${CLAUDE_PLUGIN_ROOT}/sop/` (plugin defaults) ← checked last
- Research saved to user's project: `.rptc/research/user-authentication.md`

---

## File Separation: Plugin vs User

| Category          | Plugin Includes                   | User Creates                   | Purpose                 |
| ----------------- | --------------------------------- | ------------------------------ | ----------------------- |
| **Commands**      | ✅ All `.md` files in `commands/` | ❌ None                        | Workflow automation     |
| **SOPs**          | ✅ Defaults in `sop/`             | ✅ Overrides in `.rptc/sop/` | Customizable standards  |
| **Agents**        | ✅ All `.md` files in `agents/`   | ❌ None                        | Specialist delegation   |
| **Templates**     | ✅ In `templates/`                | ❌ None                        | Document scaffolding    |
| **Workspace**     | ❌ Not included                   | ✅ `.rptc/` in project         | User's working files    |
| **Documentation** | ✅ In `docs/`                     | ✅ In project's `docs/`        | Guidance + project docs |

---

## Key Concept: Three Locations

### 1. Plugin Installation (Read-Only for Users)

```text
~/.claude/plugins/rptc-workflow/
├── commands/           # Plugin commands (not modified)
├── sop/                # Plugin SOP defaults (not modified)
├── agents/             # Plugin agents (not modified)
└── templates/          # Plugin templates (not modified)
```

**Purpose**: Shared, version-controlled workflow definition

### 2. User Global Settings (Optional)

```text
~/.claude/global/
└── sop/                # User's global SOP overrides
    ├── testing-guide.md         # Customized for all projects
    └── architecture-patterns.md # User's preferred patterns
```

**Purpose**: User's personal preferences across all projects

### 3. Project Workspace (User's Work)

```text
my-project/
├── .rptc/              # Working artifacts
│   ├── research/       # Research documents
│   ├── plans/          # Implementation plans
│   └── archive/        # Completed work
├── .claude/            # Project-specific settings
│   └── sop/            # Project SOP overrides (optional)
└── docs/               # Permanent documentation (auto-created)
```

**Purpose**: Project-specific work and settings

---

## What Should Be .gitignored?

### In Your Development Repo (This Repo)

```gitignore
# Don't distribute to users
legacy/                          # Development history
.rptc/plans/*                    # Your personal plans
.rptc/research/*                 # Your personal research
PLUGIN_CONVERSION_STATUS.md      # Development tracking
.claude/settings.local.json      # Your local settings

# Keep these
.rptc/.gitkeep                   # Preserve directory structure
```

### In User Projects (What Users Should Ignore)

```gitignore
# Working artifacts (should be gitignored by users)
.rptc/research/*
.rptc/plans/*
.rptc/complete/*

# Keep important plans/research with explicit add
# Users can: git add -f .rptc/plans/important-feature.md
```

---

## Summary: The Big Picture

**Plugin = Workflow Definition** (distributed, version-controlled)

- Commands, SOPs, agents, templates
- Installed to `~/.claude/plugins/rptc-workflow/`
- Updated with `claude plugin update rptc-workflow`

**User Workspace = Actual Work** (local, not in plugin)

- Research documents, implementation plans
- Lives in user's project: `my-project/.rptc/`
- Managed by user with git (or not)

**SOP Fallback Chain = Customization** (3 levels)

1. Project: `.rptc/sop/` (overrides everything)
2. User: `~/.claude/global/sop/` (overrides plugin)
3. Plugin: `${CLAUDE_PLUGIN_ROOT}/sop/` (defaults)

This separation allows:

- ✅ Plugin maintainer updates workflow without touching user's work
- ✅ Users customize SOPs without modifying plugin
- ✅ Clean separation of "tool" vs "work product"
- ✅ Version control for both plugin and user work (independently)
