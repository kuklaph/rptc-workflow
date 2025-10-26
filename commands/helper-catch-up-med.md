# Medium Context Catch-Up

Get comprehensive project understanding for feature work.

Arguments: None

## Process

Gather thorough context in 5-10 minutes:

### 1. Project Foundation (Quick)

- Read `CLAUDE.md`
- Read `package.json` or equivalent
- Read `README.md`
- Check `.context/` files if exist

**Standard Operating Procedures** (resolved via fallback chain):
SOPs are loaded from (highest priority first):

1. `.rptc/sop/` - Project-specific overrides
2. `~/.claude/global/sop/` - User global defaults
3. Plugin SOPs - Plugin defaults

Available SOPs:

- architecture-patterns.md
- testing-guide.md
- flexible-testing-guide.md
- languages-and-style.md
- security-and-performance.md
- git-and-deployment.md
- frontend-guidelines.md

Check `.context/` for project-specific context documents.

### 2. Architecture Understanding

- Scan project structure:

  ```bash
  find . -type f -name "*.ts" -o -name "*.js" -o -name "*.py" | head -20
  ```

- Identify main directories (src, lib, app, etc.)
- Read main entry point (index.ts, main.py, etc.)

### 3. Recent Context (Detailed)

```bash
git log -15 --oneline --graph  # Recent history
git diff main..HEAD --stat      # Changes from main
```

### 4. Research & Plans

- List existing research docs: `ls .rptc/research/`
- List existing plans: `ls .rptc/plans/`
- Read most recent research/plan if exists

### 5. Dependencies & Config

- Check installed dependencies
- Review main config files
- Note test framework setup

### 6. Summary Report

```text
📋 Medium Context Catch-Up

**Project**: [name]
**Tech Stack**: [detailed list]
**Architecture**: [structure overview]

**Project Structure**:
- `src/` - [purpose]
- `tests/` - [test setup]
- `docs/` - [documentation]

**Recent History** (last 15 commits):
[List with context]

**Active Work**:
- Current branch: [name]
- Changes from main: [summary]
- Files modified: [list]

**Existing Research**:
- [research doc 1]
- [research doc 2]

**Existing Plans**:
- [plan 1]: [status]
- [plan 2]: [status]

**Dependencies**:
- [key dependency 1]: [version]
- [key dependency 2]: [version]

**Ready for**: [specific recommendations based on context]
```

**Use when**: Starting feature work, understanding existing code, or planning changes.
