---
description: Discover the project's check commands and propose a short Checks section for the project instruction file Claude loads
allowed-tools: Bash(rm .rptc/project.yml), Bash(rmdir .rptc), Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# /rptc:config

Shared contract: `shared/provider-adapter-contract.md`

RPTC flows run a project's checks: focused tests while working, then the full
suite, typecheck, lint, and build before completion. This command records the
real commands in the project instruction file Claude loads, so every session
finds them without rediscovery. Codex's equivalent flow writes `AGENTS.md`.

## 1. Discover

Find the commands the project actually uses for:

- focused tests (one file or test name);
- full tests;
- typecheck;
- lint;
- build.

Look in task-runner and build files (`package.json` scripts, `Makefile`,
`justfile`, `pyproject.toml`, `Cargo.toml`, and similar), CI workflows, and
`CONTRIBUTING.md`. CI shows which commands the project treats as its gate.
Leave out a category the project does not have.

Then find the project instruction file Claude loads. By default:

- A project `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` in the
  working directory or above it: Claude reads the `CLAUDE.md` files. If one
  imports `AGENTS.md` (for example `@AGENTS.md`), the shared file is the better
  home for the section.
- Only an `AGENTS.md`: current Claude Code reads it directly, so it is the home
  for the section.

The **Project instructions** setting can change this (for example `claude-md`
reads only `CLAUDE.md` files). Check which instruction files this session
actually loaded and write to one of those.

## 2. Propose

Skip the edit when the instruction file already lists current check commands;
report any that look stale instead.

Otherwise, show the exact edit before writing, because it changes the user's
own instruction file:

```markdown
## Checks

- Focused tests: `<command> <path>`
- Full tests: `<command>`
- Typecheck: `<command>`
- Lint: `<command>`
- Build: `<command>`
```

Keep it to those lines. Do not add RPTC's command catalog, workflow
descriptions, or version markers; instruction files cost context in every
session.

Handle older RPTC setups in the same proposal:

- A 3.x block between `<!-- RPTC-START` and `RPTC-END -->`: propose replacing
  the whole block with the Checks section.
- A 4.x `.rptc/project.yml`: offer to move its `checks` values into the Checks
  section, delete the file (and `.rptc/` if it is then empty), and remove the
  `RPTC project contract:` pointer line. RPTC no longer reads that file.

If neither file exists, propose creating `CLAUDE.md` with only the Checks
section. Do not create a `CLAUDE.md` in a project whose loaded instructions
come from `AGENTS.md`:
by default Claude then reads the `CLAUDE.md` files instead, and the existing
`AGENTS.md` instructions stop loading.

Ask with `AskUserQuestion` and write nothing until the user approves.

## 3. Write and verify

Apply the approved edit. Read the file back and confirm each listed command
resolves to a real script, target, or tool in the repository. Report which
commands came from CI or task-runner files and which the user supplied.
