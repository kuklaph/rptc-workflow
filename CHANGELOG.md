# Changelog

All notable changes to the RPTC Workflow plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Release history through 3.16.7 is preserved in
[`CHANGELOG-v3-and-earlier.md`](CHANGELOG-v3-and-earlier.md).

---

## [4.2.0] - 2026-09-27

A full review of 4.1 against current Anthropic and OpenAI guidance, plus a
salvage pass that checked the research removed in 4.0 and 4.1 and restored the
parts that still apply to current models.

### Added

- Test-integrity rules in `tdd-methodology`: reach passing tests only through
  the requested behavior (no deleting, skipping, loosening, or special-casing
  tests; report conflicts), mock only external or nondeterministic boundaries,
  derive expected values from the requirement, cover implied boundary and
  failure cases, size tests to the change, define affected checks, and assert
  nondeterministic output by facts and structure.
- Engineering policy: no unrequested features, abstractions, flags, or shims;
  reuse existing helpers; secure defaults at trust boundaries.
- Verification: a shared severity scale (blocking, should-fix, optional),
  `No findings` as a normal reviewer result, a parent filter rule, and
  correctness review of tests edited or weakened by a change.
- Writing skill: a current catalogue of AI-writing tells and integrity rules
  (no invented sources, marked quotations).
- Routing cases for `frontend-design` and a manual eval procedure in
  `evals/README.md`.

### Changed

- `/rptc:fix-team` is now a competing-hypotheses debugging mode: read-only
  investigators try to disprove each other, then the lead fixes the bug alone.
  It needs Claude's experimental agent teams.
- `config` no longer writes `.rptc/project.yml`. It proposes a short "Checks"
  section with the project's real commands for `CLAUDE.md` or `AGENTS.md`.
- `frontend-design` follows current practice: restraint, the brief and existing
  design system first, current generic-design tells, and a WCAG 2.2 / Core Web
  Vitals floor. Bold direction is reserved for new UI and requested redesigns.
- `html-report-generator` is a simple, self-contained, consistent template.
- Claude agents list plain tool names. Reviewers, the architect, and the
  researcher have no Write or Edit tools and are instructed to use Bash only
  for read-only commands; the TDD agent leaves git state to the parent.
- Command permissions: pre-approved Bash rules now cover specific check
  runners (for example `npm test`, `cargo test`, `pytest`) instead of whole
  package managers and `npx`. Only `commit` pre-approves git writes (`add`,
  `commit`, `switch -c`, `push -u origin`) and PR creation, apart from
  `git worktree add` in `feat`, `fix`, and `fix-team`. Read-only git is
  already approved by Claude Code. For a pull request, `commit` creates the
  commit on a feature branch, never on the default branch.
- The TDD agent preloads `tdd-methodology` and requires a failing check only
  when behavior changes at a practical seam. The architect names a
  representative slice instead of implementing it.
- `verify-loop` stops after accepted fixes are applied and rechecked, not
  merely when every claim has a status.
- `commit` inspects scope before running checks, reuses still-valid evidence,
  asks for approval only when scope is ambiguous or policy requires it, and
  uses the host CLI that matches the remote (`gh`, `fj`, `glab`).
- Claude skills resolve plugin files with `${CLAUDE_PLUGIN_ROOT}`; Codex skills
  use paths relative to the SKILL.md.
- Manifest descriptions and keywords describe the 4.x workflow.

### Removed

- `/rptc:feat-team` and `review-agent`. The `agent-teams` skill covers parallel
  workstreams with separate owners.
- `tool-guide`, `agent-teams/references/team-lifecycle.md`, and
  `codex/sop/update-plan-guide.md`, which were unreferenced and contradicted
  current policy.
- `sop/frontend-guidelines.md` (outdated WCAG 2.1 and FID specifics) and
  `templates/project-contract.yml`.
- The broken `report-template.html` and `dark-theme.css` from
  `html-report-generator`.

### Upgrade notes

- Codex: run `rptc-init` once after upgrading so the retired
  `rptc:review-agent` TOML is removed from your agents directory. Flows install
  missing agents automatically but do not remove obsolete ones.
- Claude: `/rptc:feat-team` no longer exists. Use `/rptc:feat`, or the
  `rptc:agent-teams` skill for parallel workstreams with separate owners.

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
