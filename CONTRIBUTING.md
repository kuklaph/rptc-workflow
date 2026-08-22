# Contributing to RPTC Workflow

## Design rule

RPTC ships one engineering workflow through two different harnesses.

Before editing, classify the change:

- **Semantic:** changes an engineering outcome, evidence rule, approval boundary,
  or workflow decision. Edit the shared contract and both affected adapters.
- **Mechanical:** changes one provider's tool names, planning, task tracking,
  installation, delegation, or path resolution. Edit that adapter only.

Do not remove Claude/Codex differences merely because the files look similar.

## Repository layout

```text
plugins/rptc/
├── provider-contract.json
├── shared/
├── claude/
├── codex/
├── skills/
├── sop/
├── templates/
└── docs/
```

## Required checks

```bash
python3 scripts/validate-rptc.py
bash scripts/verify-version.sh
git diff --check
```

Run Claude plugin validation when available.

## Workflow changes

For each changed flow:

1. Update its shared contract for semantic changes.
2. Update the provider adapters.
3. Preserve intentional asymmetries.
4. Add routing or parity fixtures.
5. Test the flow in every provider that implements it.
6. Report exact commands and observations.

## Skills

Every `SKILL.md` needs `name` and `description` frontmatter.

Descriptions state the user situation and activation boundary. The body owns
the procedure. Move branch-specific or optional reference material behind
focused files.

Avoid:

- universal file, line, test-count, or coverage quotas;
- self-reported compliance as proof;
- arbitrary numerical model confidence;
- restating discoverable project configuration;
- automatic external side effects.

## Git writes

Stage only intended paths:

```bash
git add -- <paths>
```

Never use broad staging commands in RPTC ship guidance.

## Pull requests

Include:

- semantic versus provider-mechanical classification;
- providers affected;
- shared contracts changed;
- eval fixtures changed;
- checks run;
- live provider verification;
- remaining inconclusive items.
