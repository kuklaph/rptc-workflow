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
sizeable evidence sources. If the custom agent is missing, run
`rptc:rptc-codex-init` once to install the packaged agents, mention the
installation in the final report, and confirm the agent can be spawned. If it
still cannot, report the spawn error and any reload the user needs instead of
reinstalling.

At every spawn, keep calling `wait_agent` until every required agent has
returned or failed; one call can return when the first agent finishes or the
wait times out. The parent does not duplicate the research while agents run.
Once results are collected, close agents that are no longer needed with
`close_agent` when available; finished agents count toward the concurrency limit
until closed.

Verify code locations and citations. Return direct evidence, inference,
disagreement, and gaps. Write an artifact only when requested. No fixed source
quota applies.
