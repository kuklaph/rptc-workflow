# Deep Context Catch-Up

Get exhaustive project analysis for complex work.

Arguments: None

## Process

Perform comprehensive project analysis in 15-30 minutes:

### 1. Project Foundation (Complete)

- Read ALL `.context/` files
- Read `CLAUDE.md`
- Read `README.md`
- Read `package.json` / equivalent
- Read `tsconfig.json` / language config
- Read `.gitignore`
- Review CI/CD configs (.github/, .gitlab-ci.yml, etc.)

**Standard Operating Procedures** (resolved via fallback chain):
SOPs are loaded from (highest priority first):

1. `.rptc/sop/` - Project-specific overrides
2. `~/.claude/global/sop/` - User global defaults
3. Plugin SOPs - Plugin defaults

These SOPs provide consistent cross-project guidance.
Use `/rptc:admin:sop-check [filename]` to verify which SOP will be loaded.
Check `.context/` for project-specific context documents.

### 2. Complete Architecture Analysis

**Structure Mapping**:

```bash
tree -L 3 -I 'node_modules|__pycache__|.git' || find . -type d -not -path "*/\.*" | head -30
```

**Code Organization**:

- Identify all major modules/packages
- Map file relationships
- Find design patterns in use
- Locate configuration files

**Entry Points**:

- Read all entry files (index._, main._, app.\*)
- Understand initialization flow
- Identify core services/modules

### 3. Complete Git History

```bash
git log --all --oneline --graph -30  # Extended history
git log --all --grep="feat" --oneline | head -10  # Feature history
git log --all --grep="fix" --oneline | head -10   # Fix history
```

### 4. All Documentation

- Read ALL files in `.rptc/research/`
- Read ALL files in `.rptc/plans/`
- Extract key decisions and patterns
- Note implementation status

### 5. Complete Dependency Analysis

- Full dependency tree
- Identify critical dependencies
- Note versions and update status
- Check for security advisories

### 6. Test Infrastructure

- Identify test framework
- Count total tests
- Review test coverage
- Analyze test patterns

### 7. Code Pattern Analysis

Search for key patterns:

```bash
rg "class\s+\w+" --type ts -c    # Class usage
rg "function\s+\w+" --type js -c  # Function definitions
rg "export\s+(default|const)" -c  # Export patterns
```

### 8. Recent Changes Deep Dive

- Analyze last 30 commits
- Identify active features
- Note breaking changes
- Review merge/branch patterns

### 9. Comprehensive Summary Report

```text
📋 Deep Context Catch-Up

**Project Overview**:
- Name: [name]
- Purpose: [from README]
- Tech Stack: [complete list with versions]
- Architecture: [detailed pattern analysis]

**Project Structure** (Complete):
[Full directory tree with purposes]

**Git History Analysis**:
- Total commits: [N]
- Active branches: [list]
- Recent features: [list from last 30 commits]
- Recent fixes: [list from last 30 commits]
- Current branch: [name]
- Divergence from main: [N] commits

**Documentation Inventory**:

Research Documents:
1. [doc 1]: [summary]
2. [doc 2]: [summary]
...

Implementation Plans:
1. [plan 1]: [status] - [summary]
2. [plan 2]: [status] - [summary]
...

**Architecture Deep Dive**:
- Entry points: [list]
- Core modules: [list with purposes]
- Design patterns: [identified patterns]
- Data flow: [high-level flow]

**Dependencies** ([N] total):
Critical:
- [dep 1]: [version] - [purpose]
- [dep 2]: [version] - [purpose]

Development:
- [dev dep 1]: [version] - [purpose]

**Test Infrastructure**:
- Framework: [name]
- Total tests: [N]
- Coverage: [X]% (if available)
- Test patterns: [identified patterns]

**Code Patterns**:
- Classes: [N] defined
- Functions: [N] defined
- Components: [N] (if applicable)
- Primary patterns: [list]

**Active Work Analysis**:
- Current feature: [from branch/commits]
- Files in progress: [list with purposes]
- Related research: [link]
- Related plan: [link]
- Completion estimate: [based on plan]

**Key Decisions & Context**:
[Extract from .context/ files]
1. [Decision 1]
2. [Decision 2]
...

**Technical Constraints**:
[From documentation and analysis]
- [Constraint 1]
- [Constraint 2]

**Recommendations**:
Based on comprehensive analysis:
1. [Specific recommendation]
2. [Another recommendation]
3. [Area of focus]

**Ready for**: [Very specific task recommendations based on deep understanding]
```

**Use when**:

- Starting on unfamiliar project
- Major architectural changes
- Complex refactoring
- Comprehensive feature planning
- Project onboarding
