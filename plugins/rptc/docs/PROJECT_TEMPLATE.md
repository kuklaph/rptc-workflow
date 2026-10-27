# RPTC project setup

RPTC needs no project configuration file. Its flows discover checks from the
repository. To save that discovery, run `/rptc:config` (Claude) or the
`rptc-config` skill (Codex). It finds the project's real commands in
task-runner files and CI, then proposes a short section for the project's
instruction file (`AGENTS.md` for Codex; for Claude, the `CLAUDE.md` it loads,
or `AGENTS.md` in a project that has only that file):

```markdown
## Checks

- Focused tests: `npm test -- <path>`
- Full tests: `npm test`
- Typecheck: `npm run typecheck`
- Lint: `npm run lint`
- Build: `npm run build`
```

The flow shows the exact edit and writes it only after you approve. It lists
only the categories the project has.

Keep instruction files minimal. Do not paste RPTC's command catalog, workflow
diagrams, or plugin version into them.

## Upgrading

- RPTC 3.x `<!-- RPTC-START ... RPTC-END -->` blocks: the config flow proposes
  replacing the block with the Checks section.
- RPTC 4.0-4.1 `.rptc/project.yml`: RPTC no longer reads this file. The config
  flow offers to move its checks into the Checks section, delete the file, and
  remove the `RPTC project contract:` pointer.
