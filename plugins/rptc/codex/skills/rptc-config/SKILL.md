---
name: rptc-config
description: Discover project conventions and configure a minimal Codex-facing RPTC project contract in .rptc/project.yml with one AGENTS.md pointer.
---

# RPTC Config

Shared contract: `shared/provider-adapter-contract.md`

Codex and Claude use different project instruction surfaces. This adapter writes
Codex's `AGENTS.md` pointer and the shared project contract.

## 1. Discover

Inspect `AGENTS.md`, repository guidance, package and build files, task runners,
CI, project checks, glossary or ADR locations, and git conventions.

## 2. Propose

Start from `RPTC plugin root/templates/project-contract.yml`.

Record only durable facts or explicit preferences. Preserve existing custom
values.

If preference input is needed, use `request_user_input` only when Plan Mode is
already active. Otherwise ask in normal chat and stop for the answer.

## 3. Write

Write `.rptc/project.yml`.

Ensure `AGENTS.md` contains one concise pointer:

```markdown
RPTC project contract: `.rptc/project.yml`.
```

Do not insert a plugin command catalog, workflow diagram, or versioned block.

## 4. Verify

Read both files back, validate configured commands against the repository, and
report discovered facts separately from user choices.
