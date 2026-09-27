# Changelog

All notable changes to the RPTC Workflow plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Release history through 3.16.7 is preserved in
[`CHANGELOG-v3-and-earlier.md`](CHANGELOG-v3-and-earlier.md).

---

## [4.1.0] - 2026-09-27

### Added

- Long-running work guidance: `feat` and `fix` offer a ready-to-paste `/goal` condition built from acceptance predicates, their checks, and constraints when approved work will span many turns. The user starts goal mode; approvals stay with the user.
- `goal_mode` entries for Claude and Codex in `provider-contract.json`.
- Architecture-routing eval cases that distinguish broad mechanical edits from genuine design uncertainty.
- `.gitattributes` that keeps LF line endings on every OS.

### Changed

- Classified feature and fix work before creating formal task or plan structures, so localized work no longer pays mandatory phase bookkeeping.
- Separated execution complexity from design uncertainty; multi-file work enters formal planning only when consequential design choices remain unresolved. The fix adapters now load architecture methodology on that basis instead of on module count.
- Made the full writing-style methodology conditional on substantial prose, documentation, or user-facing copy instead of loading it for every feature and fix, and trimmed the skill for both providers.
- Applied the same conditional loading and needs-based task creation to `/rptc:feat-team` and `/rptc:fix-team`.
- Changed general independent review to target distinct unresolved risks instead of duplicating decisive deterministic evidence, while preserving independent final verification for high-risk work.
- Reused still-valid evidence instead of rerunning unchanged checks when a workflow phase changes.
- Preserved the Codex parent-session spawn/wait barrier and explicit approval boundaries.

### Removed

- Unreferenced 3.x SOPs: flexible testing, testing, languages and style, git and deployment, architecture patterns, post-TDD refactoring, and security and performance. `sop/frontend-guidelines.md` remains for the frontend-design skill.
- The `tdd-phases.md` references for both providers, which contradicted vertical TDD with horizontal test-first phases and a fixed coverage target.
- Unreferenced templates: SOP enhancement pattern, plan step, and research output templates.
- Completed v4 transition documents: migration plan, implementation handoff, and `UNRELEASED.md`.
- The unwired repository-root `hooks/` scripts.

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
