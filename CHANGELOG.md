# Changelog

All notable changes to the RPTC Workflow plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Release history through 3.16.7 is preserved in
[`CHANGELOG-v3-and-earlier.md`](CHANGELOG-v3-and-earlier.md).

---

## [4.0.0] - 2026-08-22

### Added

- Shared provider-neutral engineering and workflow contracts with a machine-readable Claude/Codex provider map.
- Risk-scaled feature and fix workflows, reproduction-first diagnosis, claim-based verification states, and focused `test-impact` analysis.
- Routing and provider-parity fixtures plus repository validation for contracts, skill metadata, and removed surfaces.
- Minimal `.rptc/project.yml` configuration with provider-specific `CLAUDE.md` and `AGENTS.md` pointers.

### Changed

- Reworked feature and fix execution around local, normal, and high-risk routes instead of applying the full planning stack universally.
- Changed TDD to vertical failing-then-passing slices at meaningful seams.
- Changed verification to report `VERIFIED`, `NOT VERIFIED`, or `INCONCLUSIVE` from observable evidence rather than self-reported compliance or zero model findings.
- Preserved distinct Claude and Codex adapters while centralizing shared engineering semantics.
- Changed commit flows to discover project checks and stage only explicitly selected paths.
- Changed Codex `rptc-init` to synchronize the packaged RPTC-managed agent set and remove obsolete managed agents.

### Removed

- The Discord notification skill, webhook assets, and notification behavior.
- Serena-specific activation, project state, MCP instructions, and stale templates.
- The legacy production-to-test synchronization command and Codex skill.
- The old test-sync and automatic test-fixer agents, methodologies, references, and SOP.
- Universal test-count, coverage, source-count, file-size, function-size, and confidence quotas from active workflow behavior.

### Breaking Changes

- `/rptc:sync-prod-to-tests` and `rptc-sync-prod-to-tests` no longer exist. Use `test-impact` for contract-first analysis of changed behavior and tests.
- Discord and Serena integrations are no longer packaged or referenced by active workflows.
- Existing Codex installations should run `rptc-init` after upgrading so obsolete RPTC-managed agent TOMLs are removed.
- Project-specific limits and checks now control coverage, test commands, formatting, and other quality gates where available.
