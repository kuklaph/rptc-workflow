# Provider adapter contract

RPTC ships from one repository to Claude Code and Codex. The adapters are not
expected to be textually identical. They are expected to preserve the same
engineering outcome wherever both harnesses can support it.

## Shared semantics

Shared policy and workflow contracts define:

- the outcome of a flow;
- required evidence;
- approval boundaries;
- phase ordering where ordering protects correctness;
- conditions for using a specialist discipline;
- completion and failure states.

A semantic change belongs in a shared contract first. Each provider adapter then
maps that contract to its own tools.

## Adapter-owned mechanics

Claude adapters own Claude-specific behavior such as:

- slash-command frontmatter and allowed tools;
- `TaskCreate` and `TaskUpdate`;
- `AskUserQuestion`;
- `EnterPlanMode` and `ExitPlanMode`;
- `Task` sub-agents;
- persistent team commands and team messaging;
- `${CLAUDE_PLUGIN_ROOT}` path resolution.

Codex adapters own Codex-specific behavior such as:

- skill frontmatter and chat-intent routing;
- `update_plan`;
- `request_user_input` and plan-mode restrictions;
- `spawn_agent` and `wait_agent`;
- the parent-session spawn barrier;
- packaged TOML agents installed by `rptc-init`;
- Codex plugin-cache path resolution.

These differences are required adapter code, not removable duplication.

## Parity rule

For every logical flow in `provider-contract.json`:

1. Both adapters cite the same shared contract when both providers implement it.
2. Each adapter preserves the contract's outcome, evidence, and approval rules.
3. Provider-only capabilities are marked as intentional asymmetry with a reason.
4. Shared contracts do not contain provider tool names.
5. Provider mechanics do not silently redefine shared engineering policy.

## Change rule

When modifying a flow:

1. Decide whether the change is semantic or mechanical.
2. Edit the shared contract for semantic changes.
3. Edit only the affected adapter for mechanical changes.
4. Update both adapters when a semantic change requires new mappings.
5. Add or update provider-parity cases under `evals/`.
6. Run `python3 scripts/validate-rptc.py`.
