# Contributing to RPTC Workflow

Thank you for your interest in contributing to the RPTC Workflow plugin! This document provides guidelines for contributing to the project.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)

---

## Code of Conduct

Be respectful, constructive, and professional in all interactions.

---

## Getting Started

### Prerequisites

- Claude Code CLI (v2.0.0 or higher) for Claude adapter testing
- Codex with plugin support for Codex adapter testing
- Git
- Basic understanding of:
  - Markdown (for commands, agents, skills, and documentation)
  - Test-Driven Development (TDD)
  - Claude Code and Codex plugin architecture

### Installation for Development

```bash
# Clone the repository
git clone https://github.com/kuklaph/rptc-workflow
cd rptc-workflow

# Claude: install as local plugin for testing
claude plugin marketplace add .
claude plugin install rptc

# Claude: test in a separate project
mkdir test-project && cd test-project
/rptc:feat "test feature"
```

For Codex development testing, verify the package surfaces instead of Claude
slash commands:

```text
.agents\plugins\marketplace.json
plugins\rptc\.codex-plugin\plugin.json
plugins\rptc\skills\
```

Then test the Codex adapter with chat intents such as:

```text
Use RPTC to implement "test feature".
Run an RPTC verification pass.
```

---

## How to Contribute

### Reporting Issues

**Found a bug or have a feature request?**

1. **Search existing issues** first to avoid duplicates
2. **Create a new issue** with:
   - Clear, descriptive title
   - Steps to reproduce (for bugs)
   - Expected vs. actual behavior
   - Environment details (OS, Claude Code version)
   - Relevant logs or screenshots

**Issue Labels:**

- `bug` - Something isn't working
- `enhancement` - New feature or improvement
- `documentation` - Documentation improvements
- `question` - Questions about usage

### Suggesting Features

Before suggesting a feature:

1. Check if it aligns with RPTC workflow principles (Research → Plan → TDD → Commit)
2. Search for existing feature requests
3. Create an issue with:
   - Clear use case and rationale
   - How it fits into the workflow
   - Proposed implementation approach (if any)

---

## Development Setup

### Project Structure

```text
rptc-workflow/
├── .claude-plugin/                # Claude marketplace listing
├── .agents/plugins/               # Codex marketplace listing
└── plugins/rptc/                  # Canonical install package
    ├── .claude-plugin/plugin.json # Claude plugin metadata
    ├── .codex-plugin/plugin.json  # Codex plugin metadata
    ├── claude/
    │   ├── commands/              # Claude slash commands (11 commands)
    │   └── agents/                # Claude specialist agents (9 agents)
    ├── sop/                       # Standard Operating Procedures (10 SOPs)
    ├── templates/                 # Templates for artifacts
    ├── skills/                    # Skills (19 skills)
    └── docs/                      # Documentation
```

### Key Files

- **`plugins\rptc\.claude-plugin\plugin.json`**: Claude plugin metadata and component paths
- **`plugins\rptc\.codex-plugin\plugin.json`**: Codex plugin metadata
- **Marketplace files**: Root `.claude-plugin\marketplace.json` and `.agents\plugins\marketplace.json`
- **Command files** (`.md`): Command prompt definitions
- **Agent files** (`.md`): Specialized agent definitions
- **SOP files** (`.md`): Standard operating procedures

---

## Testing Guidelines

### Manual Testing Checklist

Before submitting a PR, test the following:

**Claude Slash-Command Checklist:**

- [ ] `/rptc:feat "test feature"` completes all 5 phases (Discovery → Architecture → TDD → Quality → Complete)
- [ ] `/rptc:feat-team "test feature"` spawns 4 agents and completes team workflow (Discovery → Architecture → Implementation+Review → Complete)
- [ ] `/rptc:fix "test bug"` completes all 5 phases (Reproduction → RCA → Fix → Verification → Complete)
- [ ] `/rptc:research "test topic"` performs discovery with exploration agents
- [ ] `/rptc:commit` verifies and creates commits
- [ ] `/rptc:structure` analyzes codebase structure
- [ ] `/rptc:verify` runs selected verification agents on demand
- [ ] `/rptc:verify-loop` runs agents in a convergence loop, exits cleanly
- [ ] `/rptc:sync-prod-to-tests "src/"` analyzes and syncs tests

**Codex Skill/Chat-Intent Checklist:**

- [ ] `rptc-workflow` is available from the Codex plugin skills
- [ ] `Use RPTC to implement "test feature"` runs the feature workflow through chat intent
- [ ] `Run an RPTC verification pass` runs report-only quality checks
- [ ] Codex uses `update_plan` for active workflow tracking
- [ ] Codex runs in the main session by default
- [ ] Codex uses delegation only after explicit user approval and only when subagent tools are available

**Workflow Verification:**

- [ ] Phase 1 (Discovery) launches parallel exploration agents
- [ ] Branch Strategy prompt appears after Phase 1 and offers worktree option
- [ ] Phase 2 (Architecture) presents 3 planning perspectives
- [ ] Phase 3 (TDD) uses smart batching for implementation
- [ ] Phase 4 (Quality Verification) runs code-review, security, and docs agents in parallel (report-only). Note: `/rptc:feat-team` uses `review-agent` instead (unified, real-time feedback)
- [ ] Plans use the provider's planning mechanism (Claude: `~/.claude/plans/`; Codex: `update_plan`/chat approval unless a project plan file is requested)

### Test on Multiple Platforms

If possible, test on:

- Windows (Git Bash, PowerShell)
- macOS (Zsh, Bash)
- Linux (Bash)

---

## Documentation Standards

### Claude Command Documentation

All command files must include:

```markdown
---
description: Brief command description
---

# Command Name

## Purpose

Clear statement of what this command does

## Arguments

List and explain all arguments

## Step-by-step Process

Detailed workflow steps

## Important Notes

Edge cases, limitations, or warnings

## Error Handling

How failures are handled
```

### Claude Agent Documentation

Agent files are thin shells — skills are loaded via frontmatter (`skills:` field), not manual Read calls. All agent files must include:

```markdown
---
name: agent-name
description: Brief description. REPORT ONLY if applicable.
tools: [tool list]
skills:
  - rptc:core-principles
  - rptc:tool-guide
  - rptc:[agent]-methodology
color: [color]
model: inherit
---

# Agent Name

[One-line role description]. **REPORT ONLY** (if applicable).

## RPTC Workflow Context (MANDATORY)

[Phase, directives table, SOPs table, exit verification block]

## Operating Methodology

[Brief reinforcement pointing to preloaded skills]
```

### Skill Documentation

Shared and Codex-facing skills must include:

```markdown
---
name: skill-name
description: Trigger description with provider mapping where needed.
---

# Skill Name

## When to Use

Clear trigger conditions.

## Provider Mapping

Claude behavior and Codex behavior where they differ.

## Workflow

Steps, required approvals, and task tracking.

## References

SOPs, templates, and methodology files used by the skill.
```

### Code Comments

- Use clear, concise comments
- Explain "why" not "what" (code should be self-documenting)
- Comment complex logic or non-obvious decisions

---

## Pull Request Process

### Before Submitting

1. **Test thoroughly** using the manual testing checklist
2. **Update documentation** for any changed behavior
3. **Follow style guidelines** (see below)
4. **Write clear commit messages** (see Commit Message Format)

### PR Description Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Motivation and Context

Why is this change needed? What problem does it solve?

## Testing

How was this tested? Include:

- Test scenarios
- Platforms tested
- Any edge cases considered

## Checklist

- [ ] Commands tested manually
- [ ] Documentation updated
- [ ] No breaking changes (or documented if unavoidable)
- [ ] Follows style guidelines
- [ ] Plugin SOPs load correctly (from `plugins\rptc\sop\` directory)
```

### Commit Message Format

Follow Conventional Commits:

```text
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Testing changes
- `chore`: Maintenance tasks

**Examples:**

```text
feat(commands): add smart batching to /rptc:feat TDD phase

Implements intelligent step grouping for ~40% token reduction.
Related steps are batched together for parallel execution.

Closes #42
```

```text
fix(agents): correct parallel agent invocation in quality review

Code Review and Security agents now launch in same message
for true parallel execution instead of sequential.
```

### Review Process

1. **Maintainers review** within 3-5 days
2. **Address feedback** promptly
3. **Squash commits** before merge (if requested)
4. **Celebrate** when merged! 🎉

---

## Style Guidelines

### Markdown

- Use ATX-style headers (`#` not `===`)
- Wrap lines at 100 characters (except code blocks)
- Use fenced code blocks with language identifiers
- Use tables for structured data
- Use bullet lists for unordered items

### Bash Scripts (Hooks)

- Use `#!/usr/bin/env bash` shebang
- Set strict mode: `set -euo pipefail`
- Quote all variables: `"${var}"`
- Use meaningful variable names (lowercase with underscores)
- Comment complex logic

### File Naming

- Commands: `kebab-case.md` (e.g., `catch-up-med.md`)
- Agents: `kebab-case-agent.md` (e.g., `architect-agent.md`)
- SOPs: `kebab-case.md` (e.g., `testing-guide.md`)
- Docs: `SCREAMING_SNAKE_CASE.md` (e.g., `RPTC_WORKFLOW_GUIDE.md`)

### Command Structure

- Always include frontmatter with `description`
- Use clear section headers
- Provide examples where helpful
- Include error handling guidance

---

## Areas for Contribution

### High Priority

- **Cross-platform testing**: Ensure Windows/macOS/Linux compatibility
- **Bug fixes**: Address any reported issues
- **Documentation improvements**: Clarify unclear sections

### Medium Priority

- **New helper commands**: Add useful utilities
- **Enhanced error messages**: Improve user feedback
- **Performance optimizations**: Speed up command execution

### Nice to Have

- **Additional SOPs**: Domain-specific best practices
- **Example projects**: Demonstrate workflow usage
- **Video tutorials**: Visual guides for new users
- **Community templates**: Shareable plan/research templates

---

## Questions?

- **Issues**: https://github.com/kuklaph/rptc-workflow/issues
- **Discussions**: https://github.com/kuklaph/rptc-workflow/discussions
- **Documentation**: See `plugins\rptc\docs\RPTC_WORKFLOW_GUIDE.md`

---

Thank you for contributing to RPTC Workflow! Your efforts help make systematic development accessible to everyone. 🚀
