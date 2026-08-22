---
name: rptc-init
description: Install or refresh the packaged RPTC Codex custom-agent TOML files in the project-local or explicitly requested global Codex agents directory.
---

# RPTC Init

Shared contract: `shared/provider-adapter-contract.md`

This skill exists only for Codex. Claude agents are registered by the Claude
plugin manifest; Codex custom agents are packaged as TOML files and must be
copied into an agents directory.

## Source

From an installed plugin, resolve the plugin version root from this skill:

```text
<plugin-version-root>/codex/skills/rptc-init/SKILL.md
```

The packaged source is:

```text
<plugin-version-root>/codex/agents/*.toml
```

When running from this repository, use:

```text
plugins/rptc/codex/agents/*.toml
```

Do not resolve an accidental `codex/codex/agents` path.

## Target

Default to:

```text
.codex/agents/
```

Use the Codex home agents directory only when the user explicitly requests a
global install. Resolve the Codex home from the environment rather than
hard-coding an operating-system path.

## Procedure

1. Resolve the source and target.
2. Verify every packaged TOML contains `name`, `description`, and
   `developer_instructions`.
3. Create the target directory when missing.
4. Copy RPTC-managed TOMLs exactly. Do not generate or transform them.
5. Refresh existing RPTC-managed files when requested.
6. Verify every target file and its `rptc:` name.
7. Report the target and files installed.

Do not modify unrelated custom agents.
