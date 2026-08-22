# RPTC project template

RPTC project configuration is optional. Run the provider's `rptc-config` flow
when a repository needs durable overrides.

## `.rptc/project.yml`

```yaml
version: 1

approval: balanced
workspace: auto

context:
  glossary: null
  adrs: null

checks:
  focused: null
  full: null
  typecheck: null
  lint: null
  build: null

ship:
  commit_style: project
  stage: selected-files
```

Record only durable project facts that cannot be reliably rediscovered.

## Provider pointer

Claude `CLAUDE.md`:

```markdown
RPTC project contract: `.rptc/project.yml`.
```

Codex `AGENTS.md`:

```markdown
RPTC project contract: `.rptc/project.yml`.
```

Do not paste RPTC's command catalog, workflow diagrams, or plugin version into
project instruction files.
