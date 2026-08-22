# Unreleased RPTC modernization

## Added

- Shared engineering and workflow contracts.
- Machine-readable Claude/Codex provider mapping.
- Provider-parity and routing evaluation fixtures.
- Repository validation workflow.
- Focused `test-impact` methodology.
- `diagnose-methodology` and `verification-evidence` skills.
- Minimal `.rptc/project.yml` configuration.

## Changed

- Feature and fix flows now scale rigor to risk and uncertainty.
- TDD uses vertical failing-then-passing slices.
- Verification resolves evidence rather than seeking zero model findings.
- Commit flows discover project checks and stage selected paths only.
- Review findings require evidence or a documented rule.
- Research source depth follows the claim rather than a fixed quota.
- Claude and Codex adapters cite shared semantics while preserving harness
  differences.
- Codex agent refresh synchronizes the packaged RPTC-managed agent set.

## Removed

- The external chat-notification skill, webhook assets, and examples.
- Named semantic-navigation service instructions, project state, and stale plan
  templates.
- The legacy production-to-test synchronization command and Codex skill.
- The old test synchronization and automatic test-fixer agents,
  methodologies, references, and SOP.

This file should be folded into the root `CHANGELOG.md` when the release version
is selected.
