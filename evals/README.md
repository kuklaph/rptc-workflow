# RPTC evaluations

These files describe routing and provider-parity cases. They are intentionally
model-neutral. The repository validator checks their structure and that parity
cases name known flows; it does not run them.

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

## Manual runs

No runner ships with RPTC. Before a release that changes skill descriptions or
workflow behavior:

1. In a scratch repository, run each routing prompt headless and check which
   skill loaded:
   - Claude: `claude -p "<prompt>" --output-format stream-json --verbose`
   - Codex: `codex exec --json "<prompt>"`
2. Seed one small reproducible bug and run it through `fix` in both providers.
   Grade the transcript and diff against the `fix` invariants in
   `provider-parity.json`.
3. Record pass or fail per case in the pull request.
