# RPTC plugin architecture

## One package, two adapters

The installable package is `plugins/rptc/`.

```text
plugins/rptc/
├── .claude-plugin/
├── .codex-plugin/
├── provider-contract.json
├── shared/
│   ├── engineering-policy.md
│   ├── provider-adapter-contract.md
│   └── workflows/
├── claude/
│   ├── commands/
│   ├── agents/
│   └── sop/
├── codex/
│   ├── skills/
│   ├── agents/
│   └── sop/
├── skills/
├── sop/
├── templates/
└── docs/
```

The repository intentionally contains separate Claude and Codex adapters.
Textual duplication is not automatically a defect. The relevant question is
whether duplicated text represents shared engineering semantics or required
provider mechanics.

## Shared semantics

Shared files own:

- engineering invariants;
- workflow outcomes;
- evidence and completion states;
- approval boundaries;
- risk routing;
- behavior authority.

A semantic change starts in `shared/`.

## Claude adapter

Claude owns:

- slash-command frontmatter;
- allowed tools;
- `TaskCreate` and `TaskUpdate`;
- `AskUserQuestion`;
- `EnterPlanMode` and `ExitPlanMode`;
- plugin-declared agents;
- persistent teams through `TeamCreate` and `SendMessage`;
- `${CLAUDE_PLUGIN_ROOT}` resolution.

Team commands are Claude-only because Codex has no equivalent persistent peer
team and inbox surface.

## Codex adapter

Codex owns:

- skill frontmatter and natural-language routing;
- `update_plan`;
- plan-mode restrictions on `request_user_input`;
- `spawn_agent` and `wait_agent`;
- parent-session spawn barriers;
- packaged TOML agents;
- `rptc-init` installation;
- Codex plugin-cache path resolution.

Codex agents do not message one another directly. The parent session relays
state and owns integration.

## Provider contract

`provider-contract.json` maps each logical flow to:

- its shared contract;
- its Claude adapter;
- its Codex adapter;
- its parity class;
- the reason for provider-specific or missing surfaces.

Parity classes:

- `semantic`: both providers preserve the same outcome;
- `provider-specific`: both implement the flow with different project or
  harness behavior;
- `intentional-asymmetry`: one provider exposes a capability the other does not.

## Validation

`python3 scripts/validate-rptc.py` verifies:

- all contract paths exist;
- provider asymmetries include reasons;
- shared workflows contain no provider tool names;
- adapters cite the correct shared contract;
- every skill has name and description frontmatter;
- evaluation fixtures reference known flows.

The validator warns, but does not yet fail, when legacy skills exceed the
recommended progressive-disclosure size.

## Change process

1. Classify the change as semantic or mechanical.
2. Edit the shared contract for semantic changes.
3. Edit only the affected adapter for mechanical changes.
4. Update both adapters when new semantics require new mappings.
5. Add routing or parity cases.
6. Run validation.
7. Test the affected flow in both providers when both implement it.
