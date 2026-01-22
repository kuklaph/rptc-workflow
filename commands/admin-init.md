---
description: Validate RPTC workflow setup in current project
---

# /rptc:admin-init

Validate that RPTC workflow can be used in the current project.

---

## What This Command Does

1. Verifies you're in a valid project directory
2. Checks for CLAUDE.md (project context)
3. Shows available RPTC commands
4. Offers guidance on getting started

**Note**: RPTC no longer requires workspace initialization. This command is purely informational.

---

## Step 1: Validate Project Directory

**Goal**: Confirm we're in a real project.

**Actions**:
```bash
# Check for project markers
if [ -f "package.json" ] || [ -f "pyproject.toml" ] || [ -f "Cargo.toml" ] || [ -f "go.mod" ] || [ -d "src" ]; then
  echo "✅ Valid project directory detected"
else
  echo "⚠️  No project markers found (package.json, pyproject.toml, etc.)"
  echo "   You can still use RPTC, but ensure you're in the right directory."
fi
```

---

## Step 2: Check for CLAUDE.md

**Goal**: Verify project context is available.

**Actions**:
```bash
if [ -f "CLAUDE.md" ]; then
  echo "✅ CLAUDE.md found - project context available"
else
  echo "💡 No CLAUDE.md found"
  echo "   Consider creating one with project-specific context."
  echo "   This helps agents understand your codebase better."
fi
```

---

## Step 3: Show Available Commands

**Output**:
```markdown
## RPTC Workflow Commands

### Core Workflow
- `/rptc:research <topic>` - Research and discovery
- `/rptc:feat <description>` - Full feature development (Research → Plan → TDD → Review)
- `/rptc:commit [pr]` - Verify and commit (optional PR creation)

### Getting Started
1. **Quick feature**: `/rptc:feat "add user authentication"`
2. **Research first**: `/rptc:research "OAuth best practices"` then `/rptc:feat`
3. **After implementation**: `/rptc:commit pr` to ship with PR

### Key Concepts
- **Native plan mode**: Plans are stored in `~/.claude/plans/`
- **No configuration**: RPTC uses sensible defaults
- **Parallel agents**: Exploration and reviews use parallel agents
- **Tiered authority**: Quality agents auto-fix safe issues, report risky ones
```

---

## Step 4: Optional - Create docs/research Directory

**Only if user wants to save research to files**:
```bash
mkdir -p docs/research
echo "✅ Created docs/research/ for research documents"
```

---

## What Changed (v3.0)

| Before | After |
|--------|-------|
| Creates `.rptc/` directory | Not needed |
| Creates `.claude/settings.json` | Not needed |
| Copies SOPs | Uses plugin defaults |
| Version tracking | Not needed |
| 10+ config fields | 0 config fields |

**Why the change**: RPTC now uses Claude's native plan mode and sensible defaults. No initialization required.

---

## If You Have Legacy .rptc/ Directory

If you have an existing `.rptc/` directory from older RPTC versions:
1. Plans in `.rptc/plans/` can be moved to `~/.claude/plans/`
2. Research in `.rptc/research/` can be moved to `docs/research/`
3. The `.rptc/` directory can be deleted

**Migration is optional** - old plans will still work if referenced by path.
