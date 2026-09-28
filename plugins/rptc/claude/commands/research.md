---
description: Research a codebase, external question, or both using evidence appropriate to the claim
allowed-tools: Read, Write, Glob, Grep, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, WebSearch, WebFetch
---

# /rptc:research

Shared contract: `shared/workflows/research.md`

## Arguments

`/rptc:research "<question>"`

## Procedure

1. Load `rptc:core-principles` and `rptc:research-methodology`. Load
   `rptc:unslop-writing-clearly` when the output is substantial prose.
2. Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/research.md`.
3. State the question, scope, and mode.
4. Build the evidence plan.
5. Answer narrow questions in the parent. Use parallel research agents only for
   independent, sizeable evidence sources.
6. Verify locations and citations.
7. Synthesize direct evidence, inference, disagreements, and gaps.
8. Return inline unless the user requested a Markdown or HTML artifact.

Do not require a fixed number of sources. Do not write into the repository
without an explicit artifact request.
