# RPTC v4 implementation handoff

## Branch

`feat/rptc-v4-provider-aware-modernization`

## Base

`main` at `061f0448cb2ec817e7a936896e6df25c7cd10b2b`.

## Implemented

- Provider-aware shared contract and capability mapping.
- Shared engineering, feature, fix, verification, test-impact, and ship
  contracts.
- Risk-scaled Claude and Codex feature and fix adapters.
- Reproduction-first diagnosis.
- Vertical TDD.
- Evidence statuses.
- Verification and recheck flows.
- Focused test-impact methodology with no legacy synchronization or automatic
  test-fixer agents.
- Project-discovered ship checks and selected-path staging.
- Minimal provider-specific project configuration.
- Modernized specialist agents and methodology skills.
- Removed external chat-notification assets and behavior.
- Removed named semantic-navigation service instructions and project state.
- Automated contract, frontmatter, and removed-surface validation.
- Routing and provider-parity fixture schemas.
- Updated architecture, workflow, provider, and contribution documentation.

## Required verification before release

Run:

```bash
python3 scripts/validate-rptc.py
bash scripts/verify-version.sh
git diff --check
```

Then test:

### Claude

- install the branch as a local marketplace;
- run `/rptc:feat` on a local and a normal feature;
- run `/rptc:fix` on a reproducible bug;
- run `/rptc:feat-team` and `/rptc:fix-team`;
- run `/rptc:test-impact`;
- run `/rptc:verify-loop`;
- run `/rptc:commit` without and with `pr`;
- confirm `rptc-config` writes only the concise pointer;
- confirm removed commands and skills are unavailable.

### Codex

- install the branch plugin;
- run `rptc-init`;
- confirm it installs the packaged agent set and removes obsolete
  RPTC-managed TOMLs;
- invoke `rptc-feat`, `rptc-fix`, `rptc-test-impact`,
  `rptc-verify-loop`, and `rptc-commit`;
- confirm `update_plan`, Plan Mode, `spawn_agent`, and `wait_agent` behavior;
- confirm no peer-team or inbox behavior is implied;
- confirm removed skills and agents are unavailable.

## Release work

- choose the release version;
- merge `docs/UNRELEASED.md` into root `CHANGELOG.md`;
- update all seven version locations;
- add live eval results or known limitations to the pull request;
- update any stale documentation not covered by the rewritten canonical docs.

## Important design decision

Do not collapse Claude and Codex adapters into generated identical text.

Generate or validate shared semantics where practical. Keep provider mechanics
separate and explicit. The machine-readable provider contract is the source of
truth for which differences are intentional.
