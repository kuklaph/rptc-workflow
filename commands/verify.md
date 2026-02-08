---
description: Run quality verification agents on demand
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TodoWrite, AskUserQuestion
---

# /rptc:verify

Run quality verification agents independently. Use after any code change — inside or outside the RPTC workflow.

**Arguments**:
- None: `/rptc:verify` - Verify uncommitted changes (git diff)
- With path: `/rptc:verify "src/"` - Verify specific directory or files
- Full app: `/rptc:verify "."` - Verify entire codebase

---

## Step 0: RPTC Workflow Initialization (MANDATORY - CANNOT SKIP)

**Before ANY other action, establish RPTC workflow context.**

### 0.1 Load Required Skills

```
Skill(skill: "rptc:writing-clearly-and-concisely")
```

**Wait for skill to load before proceeding.**

### 0.2 RPTC Workflow Understanding (INTERNALIZE)

You are executing **RPTC Verify** - standalone quality verification using the same agents that run during Phase 4 of `/rptc:feat` and `/rptc:fix`.

**Core Philosophy:**
- Verification catches issues before they ship
- Report-only agents — findings are addressed by main context
- Confidence filtering removes noise (≥80 only)
- User chooses verification scope

**Non-Negotiable Directives:**

| Directive | Meaning |
|-----------|---------|
| **Quality Verification** | All agents run in report-only mode |
| **Confidence Filtering** | Only surface findings ≥80 confidence |
| **User Authority** | User chooses scope and agent selection |
| **No Shortcuts** | All verification steps must complete |

**SOP Reference Chain (with Precedence):**

| Topic | Check First (User) | Fallback (RPTC) |
|-------|-------------------|-----------------|
| Architecture | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/architecture-patterns.md` |
| Security | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/security-and-performance.md` |
| Refactoring | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/post-tdd-refactoring.md` |

**Precedence Rule**: If user specifies custom SOPs (in project CLAUDE.md, project `sop/` dir, or `~/.claude/global/`), use those for the matching topic. RPTC SOPs are the fallback default.

### 0.3 Initialization Verification

Before proceeding to Phase 1, confirm:
- Skill loaded and active
- RPTC directives understood
- Verification scope clear

---

## Skills Usage Guide

**`writing-clearly-and-concisely`** - Apply Strunk's Elements of Style to verification output:

| When | Apply To |
|------|----------|
| Phase 5 | Summary report, finding descriptions |

**Key rules**: Active voice, positive form, definite language, omit needless words.

---

## Phase 1: Determine Scope

**Goal**: Identify which files to verify.

**Actions**:

1. **Parse arguments**:
   - **No arguments**: Use uncommitted changes as scope
   - **Path argument**: Use specified path(s) as scope

2. **If no arguments**, collect files from git:
   ```bash
   git diff --name-only
   git diff --cached --name-only
   ```
   Combine staged and unstaged changes into a single file list.

3. **If path argument provided**, collect files:
   ```bash
   # For directories: list all source files
   # For specific files: use as-is
   ```

4. **If no changes detected and no path provided**, ask user:
   ```
   Use AskUserQuestion:
   question: "No uncommitted changes found. What would you like to verify?"
   header: "Scope"
   options:
     - label: "Specify a path"
       description: "I'll provide a directory or file path to verify"
     - label: "Full codebase"
       description: "Run verification across the entire project"
     - label: "Cancel"
       description: "Nothing to verify right now"
   ```

5. **Report scope**:
   ```
   Verification scope: [N] files
   [list files or summary]
   ```

---

## Phase 2: Agent Selection

**Goal**: Let user choose which verification agents to run.

**Actions**:

1. **Ask user for agent selection** via AskUserQuestion:

   ```
   Use AskUserQuestion:
   question: "Which verification agents should run?"
   header: "Agents"
   options:
     - label: "Full (Recommended)"
       description: "All 3 agents: Code Review + Security + Documentation"
     - label: "Code + Security"
       description: "Code Review + Security agents (skip documentation)"
     - label: "Docs only"
       description: "Documentation agent only"
   ```

2. **Map selection to agent list**:
   - "Full" → `rptc:code-review-agent`, `rptc:security-agent`, `rptc:docs-agent`
   - "Code + Security" → `rptc:code-review-agent`, `rptc:security-agent`
   - "Docs only" → `rptc:docs-agent`

---

## Phase 3: Launch Verification Agents

**Goal**: Run selected agents in parallel, report-only mode.

**AGENT NAMESPACE LOCKOUT:**
- ✅ CORRECT: `subagent_type="rptc:code-review-agent"`
- ❌ WRONG: `subagent_type="feature-dev:code-reviewer"` — different plugin, not RPTC
- ❌ WRONG: `subagent_type="code-review:code-review"` — different plugin, not RPTC
- The `rptc:` prefix is required for ALL verification agents. No exceptions.

**Actions**:

1. **Launch selected agents in parallel** — Make Task tool calls for each:

   **Code Review Agent** (if selected):
   ```
   Use Task tool with subagent_type="rptc:code-review-agent":
   ⚠️ WRONG agents: "feature-dev:code-reviewer", "code-review:code-review" — DO NOT USE

   prompt: "Review code quality for these files: [list files].
   Focus: complexity, KISS/YAGNI violations, dead code, readability.
   REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."
   ```

   **Security Agent** (if selected):
   ```
   Use Task tool with subagent_type="rptc:security-agent":
   prompt: "Security review for these files: [list files].
   Focus: input validation, auth checks, injection vulnerabilities, data exposure.
   REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."
   ```

   **Documentation Agent** (if selected):
   ```
   Use Task tool with subagent_type="rptc:docs-agent":
   prompt: "Review documentation impact for these files: [list files].
   Focus: README updates, API doc changes, inline comment accuracy, breaking changes.
   REPORT ONLY - do not make changes. Output: documentation updates needed (≥80 only)."
   ```

2. **Wait for all agents** to complete

---

## Phase 4: Consolidate and Address Findings

**Goal**: Process agent findings and apply fixes.

**Actions**:

1. **Consolidate findings** from all launched agents:
   - Categorize: bugs, security, style, structural, documentation
   - Filter to high-confidence issues only (≥80)

2. **Create TodoWrite for ALL findings**:
   ```
   TodoWrite with status="pending":
   - [Category] Finding 1: description (file:line)
   - [Category] Finding 2: description (file:line)
   ...
   ```

3. **Auto-fix findings** (no user approval needed for most issues):

   **Fix automatically** (Tier 2-4):
   - Nits: naming, formatting, minor style issues
   - Dead code removal
   - Missing error handling
   - Documentation updates
   - Test coverage gaps
   - Minor refactoring (<30 lines)

   **Ask user FIRST** (Tier 1 or significant work):
   - Architecture changes (layer violations, new abstractions)
   - Security vulnerabilities (may need broader review)
   - Breaking API changes
   - Major refactoring (>50 lines or multiple files)
   - Integration issues (orphan code - user decides: wire up or remove)

   **Process**:
   - Work through TodoWrite items sequentially
   - For auto-fix items: Apply fix, mark complete
   - For ask-first items: Use AskUserQuestion with fix proposal, then apply or skip
   - Mark all todos complete as addressed

---

## Phase 5: Summary

**Goal**: Report what was verified and what was addressed.

**Actions**:

1. **Mark all todos complete**

2. **Summary output**:

```markdown
## Verification Complete

### Scope
- Files verified: [N]
- Agents used: [list]

### Findings
- Total findings: [N]
- Auto-fixed: [N]
- User-approved fixes: [N]
- Skipped: [N]

### Changes Made
- [list files modified by fixes, if any]

### Next Steps
- [Ready for /rptc:commit, or additional fixes needed]
```

---

## Agent Delegation Reference

### Verification Agents

**AGENT NAMESPACE LOCKOUT:**
- ✅ CORRECT: `subagent_type="rptc:code-review-agent"`
- ❌ WRONG: `subagent_type="feature-dev:code-reviewer"` — different plugin, not RPTC
- ❌ WRONG: `subagent_type="code-review:code-review"` — different plugin, not RPTC

**Mode**: Report-only. Agents report findings; main context handles fixes via TodoWrite.

**Agents (use these exact `subagent_type` values):**
1. `rptc:code-review-agent`: Code quality, complexity, KISS/YAGNI
2. `rptc:security-agent`: Input validation, auth, injection, data exposure
3. `rptc:docs-agent`: README, API docs, inline comments, breaking changes

---

## Key Principles

1. **Standalone operation**: Works independently of `/rptc:feat` and `/rptc:fix`
2. **Same agents, same quality**: Uses identical verification agents as Phase 4
3. **User controls scope**: Default to git diff, accept path overrides
4. **Always asks agent selection**: Unlike Phase 4 (which reads `verification-agent-mode` from CLAUDE.md), this command always prompts via AskUserQuestion — giving users explicit control each run
5. **Auto-fix by default**: Fix Tier 2-4 issues automatically; ask only for Tier 1 or major changes
6. **Confidence filtering**: Only surface issues ≥80 confidence

---

## Error Handling

- **No files to verify**: Ask user for path or suggest full-app scan
- **Agent fails**: Report which agent failed, continue with others
- **No findings**: Report clean bill of health
- **Git not available**: Fall back to requiring path argument
