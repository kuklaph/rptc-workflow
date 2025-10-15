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

- Claude Code CLI (v2.0.0 or higher)
- Git
- Basic understanding of:
  - Markdown (for commands, agents, and documentation)
  - Test-Driven Development (TDD)
  - Claude Code plugin architecture

### Installation for Development

```bash
# Clone the repository
git clone https://github.com/kuklaph/rptc-workflow
cd rptc-workflow

# Install as local plugin for testing
claude plugin install .

# Initialize a test workspace
mkdir test-project && cd test-project
/rptc:admin:init
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
├── .claude-plugin/        # Plugin metadata
├── commands/              # Slash command definitions
│   ├── admin/            # Admin commands
│   └── helper/           # Helper commands
├── agents/                # Master specialist agent definitions
├── sop/                   # Standard Operating Procedures (defaults)
├── templates/             # User artifact templates
├── hooks/                 # Quality enforcement hooks
└── docs/                  # Documentation
```

### Key Files

- **`plugin.json`**: Plugin metadata and configuration
- **`marketplace.json`**: Marketplace listing information
- **Command files** (`.md`): Command prompt definitions
- **Agent files** (`.md`): Specialized agent definitions
- **SOP files** (`.md`): Standard operating procedures

---

## Testing Guidelines

### Manual Testing Checklist

Before submitting a PR, test the following:

**Admin Commands:**

- [ ] `/rptc:admin:init` creates correct directory structure
- [ ] `/rptc:admin:init --copy-sops` copies SOPs correctly
- [ ] `/rptc:admin:sop-check` resolves SOPs via fallback chain
- [ ] `/rptc:admin:config` displays configuration

**Core Workflow:**

- [ ] `/rptc:research` performs interactive discovery
- [ ] `/rptc:plan` creates comprehensive plans
- [ ] `/rptc:tdd` implements with tests-first approach
- [ ] `/rptc:commit` verifies and creates commits

**Helper Commands:**

- [ ] `/rptc:helper:catch-up-*` provides appropriate context
- [ ] `/rptc:helper:update-plan` modifies plans correctly
- [ ] `/rptc:helper:cleanup` archives completed plans

**SOP Fallback Chain:**

- [ ] Project SOPs (`.rptc/sop/`) override user SOPs
- [ ] User SOPs (`~/.claude/global/sop/`) override plugin SOPs
- [ ] Plugin SOPs work as fallback

### Test on Multiple Platforms

If possible, test on:

- Windows (Git Bash, PowerShell)
- macOS (Zsh, Bash)
- Linux (Bash)

---

## Documentation Standards

### Command Documentation

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

### Agent Documentation

All agent files must include:

```markdown
# Agent Name

## Purpose

What this agent specializes in

## When Used

Phase/context when agent is invoked

## Standard Operating Procedures

List of SOPs this agent consults

## Analysis Process

Detailed steps the agent takes

## Output Format

Expected deliverables
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
- [ ] SOP fallback chain still works
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
feat(commands): add /rptc:helper:resume-plan command

Allows users to resume previous work by loading plan context
and recent progress. Useful after breaks or context switches.

Closes #42
```

```text
fix(sop): correct fallback chain resolution

Project SOPs were not being prioritized over user SOPs.
Updated resolution logic to follow documented priority order.
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
- Agents: `kebab-case-agent.md` (e.g., `master-feature-planner-agent.md`)
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
- **Documentation**: See `docs/RPTC_WORKFLOW_GUIDE.md`

---

Thank you for contributing to RPTC Workflow! Your efforts help make systematic development accessible to everyone. 🚀
