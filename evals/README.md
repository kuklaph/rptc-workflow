# RPTC evaluations

These files describe routing and provider-parity cases. They are intentionally
model-neutral. A provider runner may execute them later, but the repository
validator already checks their structure and referenced flows.

## Routing

`routing.json` contains positive, negative, and overlap prompts for model-invoked
disciplines. Evaluate a skill description separately from the skill's output.

## Provider parity

`provider-parity.json` defines outcomes that Claude and Codex must preserve even
when their orchestration differs.

## Behavioral comparison

For substantive prompt changes, run the same organic task in a fresh session:

1. without the proposed skill;
2. with the current skill;
3. with the proposed skill.

Keep the model, repository state, tools, and prompt constant. Grade the artifact
and evidence rather than asking the agent whether it complied.
