# RPTC v4 provider-aware migration plan

## Goal

Modernize RPTC without erasing the deliberate Claude/Codex adapter split.

The target is:

> One portable engineering contract, two faithful provider adapters, risk-scaled
> workflows, and observable evidence before completion claims.

## Design constraints

1. One repository must continue to install into Claude Code and Codex.
2. Claude-only persistent teams remain available.
3. Codex keeps parent-owned spawn barriers and TOML agent installation.
4. Shared semantics must not contain provider tool names.
5. Existing primary commands and skills remain available unless the feature is
   deliberately removed.
6. Project rules override RPTC defaults.
7. No flow may turn unknown or inconclusive evidence into a pass.
8. Optional third-party integrations must not become workflow dependencies.

## Phase 1: Provider contract and validation

Status: implemented on the modernization branch.

Deliverables:

- `provider-contract.json`;
- shared policy and workflow contracts;
- routing and provider-parity fixtures;
- `scripts/validate-rptc.py`;
- GitHub Actions validation.

Acceptance:

- every mapped path exists;
- every asymmetry has a reason;
- shared workflow files contain no provider tool names;
- adapters cite their shared contract.

## Phase 2: Safety and surface cleanup

Status: implemented on the modernization branch.

Deliverables:

- focused `test-impact` flow and methodology;
- removal of the legacy production-to-test synchronization flow;
- removal of the old test synchronization and automatic test-fixer agents;
- removal of the external chat-notification skill and assets;
- removal of named semantic-navigation service instructions and project state;
- evidence-based `verify-loop`;
- selected-path staging;
- project-discovered checks.

Acceptance:

- neither implementation nor tests are automatic behavioral truth;
- agent failure cannot count as zero findings;
- no broad git staging command appears in ship adapters;
- removed commands, skills, agents, assets, SOPs, and stale templates are absent;
- `test-impact` still works through provider-native tools and focused policy.

## Phase 3: Core workflow rewrite

Status: implemented on the modernization branch.

Deliverables:

- small core policy;
- conditional architecture;
- vertical TDD;
- reproduction-first diagnosis;
- claim-based evidence;
- risk-scaled feature and fix adapters;
- modernized specialist agents.

Acceptance:

- local changes can bypass heavy planning;
- normal and high-risk work retain appropriate rigor;
- Claude and Codex preserve the same outcome with provider-native mechanics.

## Phase 4: Project configuration and documentation

Status: implemented on the modernization branch.

Deliverables:

- `.rptc/project.yml` template;
- one-line `CLAUDE.md` or `AGENTS.md` pointer;
- rewritten architecture, workflow, provider, and contribution docs;
- release notes in `docs/UNRELEASED.md`.

## Phase 5: Behavioral evaluation

Status: foundation implemented; live runs remain.

Required before release:

1. Select representative historical RPTC tasks.
2. Run current main, modernization branch, and no-skill baselines.
3. Keep model, repository state, tools, and prompt fixed.
4. Grade acceptance, evidence, scope, questions, tokens, and elapsed time.
5. Run feature, fix, verify, test-impact, and ship in Claude and Codex.
6. Adjust descriptions from routing misses and false activations.

## Phase 6: Release hardening

Required before merge or release:

- decide version and fold `docs/UNRELEASED.md` into `CHANGELOG.md`;
- run Claude plugin validation;
- install and run Codex `rptc-init`;
- confirm obsolete RPTC-managed Codex agents are removed during refresh;
- exercise both provider adapters on fixture repositories;
- validate Windows path and shell behavior;
- confirm removed surfaces cannot route or install;
- update release version locations together.

## Non-goals

- Making Claude and Codex prompt files identical.
- Porting pstack's model roster, Graphite workflow, or Cursor transcript paths.
- Requiring Matt's issue-tracker lifecycle.
- Removing explicit PM authority.
- Adding a large runtime framework before evals prove it is needed.
