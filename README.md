# RPTC Workflow Plugin

> Research -> Plan -> TDD -> Commit workflow for Claude Code and Codex.

**Version**: 3.16.1
**Status**: Beta
**License**: MIT

---

## Package Documentation

The distributable plugin lives in `plugins\rptc`.

Use [plugins\rptc\README.md](plugins/rptc/README.md) as the canonical user documentation for installation, commands, Codex skill entrypoints, agent behavior, and workflow details.

## Repository Layout

```text
.
├── .claude-plugin\marketplace.json   # Claude marketplace entry pointing to plugins\rptc
├── plugins\rptc\                     # Distributable plugin package
├── scripts\                          # Maintainer release/version scripts
├── tests\                            # Development tests
├── CHANGELOG.md                      # Release history
├── CONTRIBUTING.md                   # Contribution guidance
└── README.md                         # Repository landing page
```

## Release Checks

Before committing a release:

```bash
./scripts/verify-version.sh
claude plugin validate plugins/rptc
git diff --check
```

On Windows, run the scripts with Git Bash if `bash` resolves to WSL:

```powershell
& "$env:LocalAppData\Programs\Git\bin\bash.exe" scripts/verify-version.sh
```

To bump all release version locations:

```bash
./scripts/sync-version.sh X.Y.Z
```

The version scripts verify these seven locations:

1. `plugins\rptc\.claude-plugin\plugin.json`
2. `.claude-plugin\marketplace.json` metadata version
3. `.claude-plugin\marketplace.json` plugin version
4. `plugins\rptc\.codex-plugin\plugin.json`
5. `README.md`
6. `plugins\rptc\README.md`
7. `CHANGELOG.md`
