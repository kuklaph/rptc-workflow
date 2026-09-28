---
name: docs-methodology
description: Determine documentation required by changed public behavior, APIs, configuration, migrations, or operating procedures. Use for RPTC documentation review.
---

# Documentation Methodology

## Ask what changed for a reader

Check whether the diff changes:

- public behavior or an API contract;
- setup, configuration, environment variables, or permissions;
- a migration, rollback, recovery, or deployment procedure;
- command output or user workflow;
- a non-obvious constraint future maintainers cannot discover from code or
  configuration;
- examples that now produce the wrong result.

Report only documentation made inaccurate, incomplete, or unsafe by the change.

## Project instruction files

`CLAUDE.md` and `AGENTS.md` are always-loaded context. Add only durable,
non-discoverable project facts and concise pointers. Do not copy plugin command
catalogs, architecture trees, tool manuals, or implementation details that the
repository can reveal directly.

## Output

For each finding include:

- changed behavior;
- affected audience;
- document and location;
- evidence from the diff or contract;
- smallest update.

Report every evidence-backed finding with its severity: blocking (breaks the
request, correctness, or security), should-fix (violates a documented rule or
leaves a real risk), or optional (improvement). An axis with none reports
`No findings`. The parent decides what to act on.

Do not request documentation merely because files changed.
