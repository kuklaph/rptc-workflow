---
name: rptc-init
description: Initialize RPTC Codex custom agents by copying packaged agent TOML files into Codex's project-local or global agents directory. Use when setting up RPTC agents, checking whether RPTC agents are installed, or preparing RPTC before spawning Codex agents.
---

# RPTC Init

Install RPTC Codex custom agents by copying the packaged TOML files. Do not generate TOML files.

## Source

Packaged agent files live under the RPTC plugin root:

```text
codex/agents/*.toml
```

When running from this repository, the source is:

```text
plugins/rptc/codex/agents/*.toml
```

When running from an installed plugin cache, locate the plugin version root from this skill file path:

```text
<plugin-version-root>/codex/skills/rptc-init/SKILL.md
```

Then use this source directory:

```text
<plugin-version-root>/codex/agents/*.toml
```

Do not treat `<plugin-version-root>/codex` as the plugin root; that would incorrectly resolve to `<plugin-version-root>/codex/codex/agents`.

## Required Files

- `architect-agent.toml`
- `code-review-agent.toml`
- `docs-agent.toml`
- `research-agent.toml`
- `review-agent.toml`
- `security-agent.toml`
- `tdd-agent.toml`
- `test-fixer-agent.toml`
- `test-sync-agent.toml`

## Required Agent Names

The TOML filenames remain unscoped for Windows compatibility, but each file's `name` field uses the RPTC namespace:

- `rptc:architect-agent`
- `rptc:code-review-agent`
- `rptc:docs-agent`
- `rptc:research-agent`
- `rptc:review-agent`
- `rptc:security-agent`
- `rptc:tdd-agent`
- `rptc:test-fixer-agent`
- `rptc:test-sync-agent`

## Targets

Default to project-local install:

```text
.codex/agents/
```

Use global install only when the user explicitly asks for global RPTC agents:

```text
<codex-home>/agents/
```

Resolve `<codex-home>` from the current Codex environment. Do not hard-code an operating-system-specific home directory.

## Workflow

1. Resolve the packaged source directory.
2. Check whether all required files exist in the target directory.
3. If any are missing, copy all packaged `*.toml` files to the target.
4. Verify all required target files now exist.
5. Verify each target file contains `name`, `description`, and `developer_instructions`.

## Copy Rules

- Use host-native filesystem operations available in the current harness.
- Create the target directory if it does not exist.
- Copy packaged TOML files exactly; do not transform their contents.
- Overwrite existing RPTC agent TOMLs only when refreshing RPTC-managed files.
- Do not use a programming generator or script to create TOML contents.

## Verification

Use file existence and simple text field checks. Do not use Python or another generator.

For each required file in the target directory:

- confirm the file exists
- confirm it contains a `name =` line
- confirm the `name =` value matches the expected `rptc:*` namespace
- confirm it contains a `description =` line
- confirm it contains a `developer_instructions =` line
