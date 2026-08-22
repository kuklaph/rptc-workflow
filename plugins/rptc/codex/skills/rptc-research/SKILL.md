---
name: rptc-research
description: Research a codebase, external question, or hybrid comparison using evidence appropriate to the claim and clear fact/inference separation.
---

# RPTC Research

Shared contract: `shared/workflows/research.md`

Load `rptc:research-methodology` and read the shared research contract.

State the question, scope, mode, and evidence plan. Use `rptc:research-agent`
for independent evidence sources when available. Run `rptc:rptc-init` if the
custom agent is missing.

At every spawn, immediately call `wait_agent` for all required IDs. The parent
does not duplicate the research while agents run.

Verify code locations and citations. Return direct evidence, inference,
disagreement, and gaps. Write an artifact only when requested. No fixed source
quota applies.
