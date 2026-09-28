---
name: rptc-research
description: Research a codebase, external question, or hybrid comparison using evidence appropriate to the claim and clear fact/inference separation.
---

# RPTC Research

Shared contract: `shared/workflows/research.md`

Load `rptc:core-principles` and `rptc:research-methodology`, plus
`rptc:unslop-writing-clearly` when the output is substantial prose. Read
`../../../shared/workflows/research.md` (relative to this SKILL.md).

State the question, scope, mode, and evidence plan. Answer narrow questions in
the parent. Use parallel `rptc:research-agent` instances only for independent,
sizeable evidence sources. If the custom agent is missing, run `rptc:rptc-init`
once to install the packaged agents, mention the installation in the final
report, and retry.

At every spawn, immediately call `wait_agent` for all required IDs. The parent
does not duplicate the research while agents run.

Verify code locations and citations. Return direct evidence, inference,
disagreement, and gaps. Write an artifact only when requested. No fixed source
quota applies.
