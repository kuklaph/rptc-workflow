# RPTC Workflow Plugin

> Provider-aware Research, Plan, Test, and Commit workflows for Claude Code and Codex.

**Version**: 3.16.7
**Status**: Beta
**License**: MIT

The distributable package lives under [`plugins/rptc`](plugins/rptc/README.md).

## Repository design

RPTC ships from one repository to two different harnesses:

- Claude exposes slash commands, plugin-declared agents, native plan mode,
  task dependencies, and persistent agent teams.
- Codex exposes skills, `update_plan`, parent-orchestrated agents, spawn
  barriers, and packaged TOML agents installed by `rptc-init`.

Shared engineering policy and workflow outcomes live under
`plugins/rptc/shared/`. Provider adapters remain separate where their harnesses
require different mechanics.

See:

- [`plugins/rptc/provider-contract.json`](plugins/rptc/provider-contract.json)
- [`plugins/rptc/docs/PLUGIN_ARCHITECTURE.md`](plugins/rptc/docs/PLUGIN_ARCHITECTURE.md)
- [`plugins/rptc/docs/RPTC_V4_MIGRATION_PLAN.md`](plugins/rptc/docs/RPTC_V4_MIGRATION_PLAN.md)

## Validation

```bash
python3 scripts/validate-rptc.py
bash scripts/verify-version.sh
git diff --check
```

The validator checks provider mappings, intentional asymmetries, shared-contract
purity, skill frontmatter, and eval fixture structure.

## Release version

Release scripts keep these seven locations synchronized:

1. `plugins/rptc/.claude-plugin/plugin.json`
2. `.claude-plugin/marketplace.json` metadata
3. `.claude-plugin/marketplace.json` plugin entry
4. `plugins/rptc/.codex-plugin/plugin.json`
5. `README.md`
6. `plugins/rptc/README.md`
7. `CHANGELOG.md`
