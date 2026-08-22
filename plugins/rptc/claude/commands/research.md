---
description: Research a codebase, external question, or both using evidence appropriate to the claim
allowed-tools: Bash(git *), Read, Write, Glob, Grep, LS, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, WebSearch, WebFetch
---

# /rptc:research

Shared contract: `shared/workflows/research.md`

## Arguments

`/rptc:research "<question>"`

## Procedure

1. Load `rptc:core-principles`, `rptc:research-methodology`, and
   `rptc:unslop-writing-clearly`.
2. Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/research.md`.
3. State the question, scope, and mode.
4. Build the evidence plan.
5. Use one researcher directly for a narrow question. Use parallel report-only
   researchers only for independent codebase, documentation, standards, or
   community evidence sources.
6. Verify locations and citations.
7. Synthesize direct evidence, inference, disagreements, and gaps.
8. Return inline unless the user requested a Markdown or HTML artifact.

Do not require a fixed number of sources. Do not write into the repository
without an explicit artifact request.
