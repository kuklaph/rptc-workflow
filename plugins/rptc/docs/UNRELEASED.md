# Unreleased RPTC modernization

## Added

- Shared engineering and workflow contracts.
- Machine-readable Claude/Codex provider mapping.
- Provider-parity and routing evaluation fixtures.
- Repository validation workflow.
- `test-impact` replacement for unsafe production-to-test synchronization.
- `diagnose-methodology` and `verification-evidence` skills.
- Minimal `.rptc/project.yml` configuration.

## Changed

- Feature and fix flows now scale rigor to risk and uncertainty.
- TDD uses vertical failing-then-passing slices.
- Verification resolves evidence rather than seeking zero model findings.
- Commit flows discover project checks and stage selected paths only.
- Review findings require evidence or a documented rule.
- Research source depth now follows the claim rather than a fixed quota.
- Discord notifications require explicit user intent.
- Claude and Codex adapters cite shared semantics while preserving harness
  differences.

## Deprecated

- `sync-prod-to-tests`. Use `test-impact`.

This file should be folded into the root `CHANGELOG.md` when the release version
is selected.
