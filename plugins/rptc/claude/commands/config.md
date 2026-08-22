---
description: Discover project conventions and configure a minimal Claude-facing RPTC project contract
allowed-tools: Bash(git *), Read, Write, Edit, Glob, Grep, LS, AskUserQuestion
---

# /rptc:config

Shared contract: `shared/provider-adapter-contract.md`

Claude and Codex have different project-instruction files. This adapter writes
Claude's `CLAUDE.md` pointer and the provider-neutral project contract.

## 1. Discover

Inspect:

- `CLAUDE.md`;
- `CONTRIBUTING.md` and repository docs;
- package, build, and task-runner files;
- CI workflows;
- existing test, typecheck, lint, and build commands;
- glossary or ADR locations;
- current git and worktree conventions.

Do not copy the plugin command catalog into project context.

## 2. Propose

Start from `${CLAUDE_PLUGIN_ROOT}/templates/project-contract.yml`.

Propose only facts that are durable or cannot be reliably rediscovered:

- approval mode: `guided`, `balanced`, or `autonomous`;
- workspace mode: `current`, `auto`, or `worktree`;
- project check commands;
- glossary and ADR locations;
- commit convention when project-defined.

Ask the user to confirm unresolved preferences. Preserve existing custom values.

## 3. Write

Write `.rptc/project.yml`.

Ensure `CLAUDE.md` contains one concise pointer:

```markdown
RPTC project contract: `.rptc/project.yml`.
```

Update an existing pointer in place. Do not add command tables, workflow
diagrams, version markers, or duplicated plugin documentation.

## 4. Verify

Read both files back, validate the configured commands against the repository,
and report what was discovered versus explicitly chosen.
