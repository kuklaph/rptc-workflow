---
name: rptc-config
description: Discover the project's check commands (tests, typecheck, lint, build) and propose a short Checks section for AGENTS.md.
---

# RPTC Config

Shared contract: `shared/provider-adapter-contract.md`

RPTC flows run a project's checks: focused tests while working, then the full
suite, typecheck, lint, and build before completion. This skill records the
real commands in `AGENTS.md` so every session finds them without rediscovery.
Codex reads `AGENTS.md`; Claude's equivalent flow writes `CLAUDE.md`.

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

Also read the existing `AGENTS.md`.

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

Keep it to those lines. Do not add RPTC's skill catalog, workflow
descriptions, or version markers; instruction files cost context in every
session.

Handle older RPTC setups in the same proposal:

- A 3.x block between `<!-- RPTC-START` and `RPTC-END -->`: propose replacing
  the whole block with the Checks section.
- A 4.x `.rptc/project.yml`: offer to move its `checks` values into the Checks
  section, delete the file (and `.rptc/` if it is then empty), and remove the
  `RPTC project contract:` pointer line. RPTC no longer reads that file.

If `AGENTS.md` does not exist, propose creating it with only the Checks
section.

Ask for approval with `request_user_input` only when Plan Mode is already
active. Otherwise ask in normal chat and stop for the answer. Write nothing
until the user approves.

## 3. Write and verify

Apply the approved edit. Read the file back and confirm each listed command
resolves to a real script, target, or tool in the repository. Report which
commands came from CI or task-runner files and which the user supplied.
