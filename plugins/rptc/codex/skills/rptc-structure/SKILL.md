---
name: rptc-structure
description: Analyze and improve codebase structure for AI-ready development. Use when the user asks for /rptc:structure or the equivalent RPTC Codex workflow intent.
---

# /rptc:structure

Analyze codebase structure, identify organizational problems, and generate a restructuring plan.

**Arguments:**
- None: `/rptc:structure` — Analyze entire project from repo root
- With path: `/rptc:structure "src/"` — Analyze specific directory
- `--report-only` — Produce assessment only, skip restructuring plan
- `--plan` — Generate restructuring plan (feeds into `/rptc:feat`)

**Examples:**
```bash
/rptc:structure                        # Full project analysis
/rptc:structure "src/services/"        # Target specific area
/rptc:structure --report-only          # Assessment without plan
/rptc:structure "src/" --plan          # Assessment + restructuring plan
```

## Skills Usage Guide

**`structure-methodology`** — The methodology skill. Provides assessment checklists, anti-pattern definitions, module boundary framework, and scoring rubrics. Reference throughout all phases.

**`writing-clearly-and-concisely`** — Apply Strunk's Elements of Style to all output:

| When | Apply To |
|------|----------|
| Phase 3 | Assessment report, finding descriptions |
| Phase 4 | Restructuring plan, action items |

## Custom Agent Availability

Before spawning `rptc:research-agent`, verify its TOML is installed in `.codex/agents/` or the user's Codex agents directory. If missing, use/load `rptc-init` to copy the packaged agents, then re-check. If still unavailable, use the built-in `explorer` agent and report the fallback.

## Phase 2: Structural Analysis

**Goal**: Deep analysis of module structure, interfaces, dependencies, and navigability.

Launch 3 research agents in parallel. Each examines the codebase from a different angle.

**AGENT NAMESPACE LOCKOUT:**
- ✅ CORRECT: RPTC `rptc:research-agent` role
- ❌ WRONG: Any other namespace prefix

### Agent 1: Module Mapping

```
Use `spawn_agent` with the RPTC `rptc:research-agent` role when installed:

## Context
Analyzing project structure at [path] for module depth and organization.
Language: [detected], Framework: [detected]

## Your Task — Module Mapping
Map the codebase into logical feature areas and classify each by module depth.

For each feature area you identify:
1. **Name and location**: What is it and where does it live in the file system?
2. **File count**: How many files contribute to this feature?
3. **Entry point**: Is there a single, obvious entry point (index, barrel, facade)?
4. **Export count**: How many symbols are publicly exported?
5. **Depth classification**:
   - **Deep**: Clear entry point, focused API (3-7 exports), implementation hidden
   - **Adequate**: Entry point exists but API is wider than ideal, some leakage
   - **Shallow**: No clear entry point, many tiny files, consumers import from everywhere

Also identify any files that don't belong to a clear feature area ("orphan files").

## Output Required
Structured list of feature areas with classifications and evidence.
```

### Agent 2: Dependency and Interface Analysis

```
Use `spawn_agent` with the RPTC `rptc:research-agent` role when installed:

## Context
Analyzing project structure at [path] for dependency health and interface quality.
Language: [detected], Framework: [detected]

## Your Task — Dependency and Interface Analysis
Analyze import/dependency relationships and interface quality.

Check for:
1. **Circular dependencies**: Module A imports B while B imports A
2. **Cross-cutting imports**: Files importing from deep paths across feature boundaries
3. **Interface leakage**: Internal types/helpers being imported by consumers outside the module
4. **Import fan-in**: Which files are imported by the most other files? (These are your key interfaces)
5. **Import fan-out**: Which files import from the most other files? (These may be doing too much)
6. **Barrel/index file coverage**: Which directories have entry points vs. which force deep imports?

## Output Required
- Dependency graph summary (clusters, circular deps, cross-boundary imports)
- Interface quality assessment per feature area
- Top 10 most-imported files (potential interfaces)
- Top 10 most-importing files (potential god modules)
```

### Agent 3: Progressive Disclosure and Testability

```
Use `spawn_agent` with the RPTC `rptc:research-agent` role when installed:

## Context
Analyzing project structure at [path] for progressive disclosure and test boundary alignment.
Language: [detected], Framework: [detected]

## Your Task — Progressive Disclosure and Testability
Evaluate how well the codebase supports progressive understanding and whether tests align with module boundaries.

Check for:
1. **File system navigability**: Can you identify feature boundaries by browsing directories?
2. **Documentation at boundaries**: Do top-level modules have README, index, or documentation?
3. **Internal vs. public separation**: Are internal helpers clearly separated from public API?
4. **Test organization**: Do tests mirror module boundaries or mirror individual files?
5. **Test coupling**: Do tests import internal helpers directly or test through the public API?
6. **AI discoverability**: For 3 randomly selected features, how many steps does it take to find the right entry point? (Target: ≤3 steps)

## Output Required
- Progressive disclosure assessment with specific examples
- Test boundary alignment findings
- AI discoverability score (steps to find entry point per feature)
```

### Wait for All Agents

Collect all three agent reports before proceeding.

## Phase 4: Restructuring Plan

**Goal**: Generate a concrete, prioritized plan for improving codebase structure.

### 4.1 Prioritize Actions

Group restructuring actions by impact:

**Priority 1 — High Impact** (improves AI navigability immediately):
- Consolidate scattered feature files into cohesive modules
- Create missing entry points (index/barrel files) for existing feature areas
- Break up god modules into focused modules with clear interfaces

**Priority 2 — Medium Impact** (improves maintainability and testability):
- Separate internal helpers from public API (create `internal/` directories)
- Fix circular dependencies
- Realign test structure to match module boundaries

**Priority 3 — Low Impact** (polish and consistency):
- Add barrel files to smaller directories
- Standardize naming conventions across modules
- Add documentation at module boundaries

### 4.2 Generate Concrete Actions

Each action must be specific and executable:

```markdown
### Action [N]: [Title]

**Priority**: [1/2/3]
**Impact**: [What improves — navigability, testability, etc.]
**Effort**: [Small / Medium / Large]

**Current state**:
- [Specific files and their current locations]

**Target state**:
- [Where files should move, what interfaces should look like]

**Steps**:
1. [Concrete step — e.g., "Create `services/auth/index.ts` exporting AuthService, AuthConfig, AuthError"]
2. [Next step — e.g., "Move `utils/auth-helpers.ts` to `services/auth/internal/helpers.ts`"]
3. [Continue until action is complete]

**Import updates**: [N] files need import path changes
**Test impact**: [Which tests need updating]
```

### 4.3 Estimate Scope

For each action, classify:

| Effort | Meaning | Execution Method |
|--------|---------|-----------------|
| Small | ≤5 files, no logic changes | Direct execution in main context |
| Medium | 5-20 files, import refactoring | Single `/rptc:feat` task |
| Large | 20+ files, structural reorganization | Multiple `/rptc:feat` tasks or parent-orchestrated `spawn_agent` delegation |

### 4.4 Present Plan

```markdown
## Restructuring Plan: [project/directory]

### Summary
- Total actions: [N]
- Priority 1 (high impact): [N] actions
- Priority 2 (medium impact): [N] actions
- Priority 3 (low impact): [N] actions
- Estimated total effort: [Small / Medium / Large]

### Recommended Execution Order
[Ordered list of actions — dependencies first, then by priority]

### Actions
[Full action details as specified in 4.2]

### Next Steps
Each action can be executed via:
- `/rptc:feat "Restructure: [action title]"` — for individual actions
- Parent-orchestrated `spawn_agent` delegation — for executing multiple independent actions in parallel
```

### 4.5 User Decision

```
Use request_user_input when available, otherwise ask directly in chat:
question: "Restructuring plan ready. How would you like to proceed?"
header: "Execution"
options:
  - label: "Execute all"
    description: "Start working through the plan (priority order)"
  - label: "Execute Priority 1 only"
    description: "Focus on highest-impact changes first"
  - label: "Save plan"
    description: "Save to a file for later — I'll run /rptc:feat myself"
  - label: "Review first"
    description: "Let me look at the plan before deciding"
```

If **Execute all** or **Execute Priority 1 only**: Enter plan mode and begin execution using `/rptc:feat` pattern (TDD for each restructuring action — write tests for expected import structure first, then move files).

If **Save plan**: Write to `docs/structure-plan.md` (or user-specified location).

## Key Principles

1. **Evidence over opinion**: Every finding cites specific files and import paths
2. **Scored and comparable**: Assessments produce numeric scores for tracking over time
3. **Actionable output**: Recommendations are concrete file operations, not abstract advice
4. **Framework-aware**: "Good structure" adapts to the language and framework detected
5. **Non-destructive**: Analysis never modifies code — restructuring only happens with user approval
6. **Feeds existing workflow**: Restructuring actions execute through `/rptc:feat` with full TDD discipline

---

## Error Handling

- **Empty directory**: Report "no source files found" and suggest a different path
- **Monorepo detected**: Ask user which package/workspace to analyze
- **Agent fails**: Report which analysis failed, continue with remaining agents
- **No issues found**: Report clean assessment — structure is AI-ready
- **Mixed languages**: Assess each language area separately, then combine scores
