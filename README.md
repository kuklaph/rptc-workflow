# RPTC Workflow Plugin

RPTC is distributed as one self-contained plugin package for Claude Code and Codex:

```text
plugins\rptc\
```

Root marketplace files point both providers at that package:

```text
.claude-plugin\marketplace.json
.agents\plugins\marketplace.json
```

Provider manifests live in the package:

```text
plugins\rptc\.claude-plugin\plugin.json
plugins\rptc\.codex-plugin\plugin.json
```

See `plugins\rptc\README.md` for usage and `plugins\rptc\docs\PLUGIN_ARCHITECTURE.md` for packaging details.
