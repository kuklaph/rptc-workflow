---
description: Run quality verification agents in a loop until all report 0 findings
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TodoWrite, AskUserQuestion
---

# /rptc:verify-loop

Run quality verification agents repeatedly until all agents report 0 findings.
After each iteration, auto-fix mechanical issues and optionally fix structural
issues with user approval. Use when you want a fully clean result, not just a
single-pass check.

**Arguments**:
- None: `/rptc:verify-loop` - Verify uncommitted changes (git diff)
- With path: `/rptc:verify-loop "src/"` - Verify specific directory or files
- Full app: `/rptc:verify-loop "."` - Verify entire codebase

---

## Step 0: RPTC Workflow Initialization (MANDATORY - CANNOT SKIP)

**Before ANY other action, establish RPTC workflow context.**

### 0.1 Load Required Skills

```
Skill(skill: "rptc:writing-clearly-and-concisely")
```

**Wait for skill to load before proceeding.**

### 0.2 RPTC Workflow Understanding (INTERNALIZE)

You are executing **RPTC Verify Loop** — a convergence-mode variant of `/rptc:verify`
that runs the verify-fix cycle until all agents report 0 findings or a safety
condition exits the loop.

**Core Philosophy:**
- Verification catches issues before they ship
- Report-only agents — findings are addressed by main context
- Confidence filtering removes noise (≥80 only)
- Loop exits cleanly; never spins forever

**Non-Negotiable Directives:**

| Directive | Meaning |
|-----------|---------|
| **Quality Verification** | All agents run in report-only mode |
| **Confidence Filtering** | Only surface findings ≥80 confidence |
| **User Authority** | User must approve Tier 1 (structural) findings |
| **Loop Safety** | Max iterations, stagnation detection, and skip tracking prevent endless loops |

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

**`writing-clearly-and-concisely`** - Apply Strunk's Elements of Style to all output:

| When | Apply To |
|------|----------|
| Phase 4 | Summary report, finding descriptions, iteration headers |

**Key rules**: Active voice, positive form, definite language, omit needless words.

---

## Phase 1: Determine Scope

**Goal**: Identify which files to verify. This runs once — the same scope is used
for every iteration of the loop.

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

**Goal**: Ask the user once which agents to run. The same set runs every iteration.

**Actions**:

1. **Ask user for agent selection** via AskUserQuestion:

   ```
   Use AskUserQuestion:
   question: "Which verification agents should run each iteration?"
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

## Phase 3: Convergence Loop

**Goal**: Run agents and fix findings repeatedly until 0 findings remain or a
safety condition exits the loop.

### Loop State (initialize once, before the loop starts)

```
iteration              = 1
max_iterations         = 5
last_iteration_count   = 0    // findings count from previous iteration (for max-iterations prompt)
findings_history       = {}   // finding_key → consecutive hit count
                               // key = "file:line:category:brief-description"
skipped_tier1          = []   // findings user declined to fix
```

### Loop Body (repeat until an EXIT condition)

---

#### 1. Iteration Header

Print at the start of each iteration:

```
--- Iteration [N] / max [M] ---
Running [agent list] on [N] files...
```

---

#### 2. Max Iterations Check

If `iteration > max_iterations`, ask before launching agents:

```
Use AskUserQuestion:
question: "Reached [max_iterations] iterations. [last_iteration_count] finding(s) remain.
           Continue 5 more iterations or stop?"
header: "Max Iterations"
options:
  - label: "Stop and summarize"
    description: "Accept remaining findings as known issues"
  - label: "Continue 5 more iterations"
    description: "Extend the loop and keep trying"
```

If "Stop and summarize" → record exit reason `MAX_ITERATIONS` → **EXIT LOOP**
If "Continue" → `max_iterations += 5`, proceed

---

#### 3. Launch Verification Agents (parallel)

**AGENT NAMESPACE LOCKOUT:**
- ✅ CORRECT: `subagent_type="rptc:code-review-agent"`
- ❌ WRONG: `subagent_type="feature-dev:code-reviewer"` — different plugin, not RPTC
- ❌ WRONG: `subagent_type="code-review:code-review"` — different plugin, not RPTC
- The `rptc:` prefix is required for ALL verification agents. No exceptions.

Make Task tool calls for each selected agent simultaneously:

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

Wait for all agents to complete.

---

#### 4. Evaluate Findings

1. Collect all findings from agents
2. Filter to ≥80 confidence
3. Record `raw_count` = number of findings before skipped filtering
4. Remove any findings that match entries in `skipped_tier1` (already declined by user)
5. Update `last_iteration_count` = number of remaining findings after filtering
6. **Exit condition check**:
   - If `raw_count == 0` → record exit reason `CLEAN` → **EXIT LOOP** → go to Phase 4
   - If `last_iteration_count == 0` (all findings were pre-skipped, raw_count > 0)
     → record exit reason `USER_SKIPPED` → **EXIT LOOP** → go to Phase 4

---

#### 5. Stagnation Check

For each remaining finding, compute a stable key:
`"file:line:category:first-8-words-of-description"`

Compare against `findings_history`:
- Increment hit count for each key seen this iteration
- Reset hit count to 0 for any key NOT seen this iteration

If any key has a consecutive hit count ≥ 2 (appeared in 2+ consecutive iterations
without being fixed):

```
Use AskUserQuestion:
question: "Stagnation detected: [N] finding(s) keep returning after attempted fixes.
           These may require manual intervention. Stop or keep trying?"
header: "Stagnation"
options:
  - label: "Stop and summarize"
    description: "Accept remaining findings as known issues and wrap up"
  - label: "Keep going"
    description: "Continue the loop — I'll handle these differently"
```

If "Stop and summarize" → record exit reason `STAGNATION` → **EXIT LOOP**
If "Keep going" → reset hit count to 0 for all currently stagnating keys in
`findings_history` (this prevents re-triggering the stagnation prompt next
iteration; the check will only fire again if those same findings return for 2
more consecutive iterations after the reset)

---

#### 6. Process Findings

Work through findings sequentially. For each finding:

**Auto-fix (no user approval needed — Tier 2-4):**
Mechanical cleanup that doesn't require human judgment:
- Nits: naming, formatting, minor style issues
- Dead code removal
- Missing error handling
- Documentation updates
- Test coverage gaps

Apply fix, mark the finding resolved.

**Ask user FIRST (Tier 1 — requires human judgment):**
Structural or consequential changes; use the nature of the change as the
criterion, not line count (ref: `${CLAUDE_PLUGIN_ROOT}/sop/post-tdd-refactoring.md`):
- Architecture changes (layer violations, new abstractions)
- Security vulnerabilities
- Breaking API changes
- Refactoring that changes structure, not just style
- Integration issues (orphan code — wire up or remove)

For each Tier 1 finding:
```
Use AskUserQuestion:
question: "Tier 1 finding requires your approval:
           [finding description] ([file:line])
           Proposed fix: [brief description]"
header: "Tier 1 Finding"
options:
  - label: "Apply fix"
    description: "Proceed with the proposed fix"
  - label: "Skip this finding"
    description: "Mark as known issue and move on"
  - label: "I'll fix it manually"
    description: "Skip for now — I'll address it outside this loop"
```

If "Apply fix" → apply, mark resolved
If "Skip this finding" → add to `skipped_tier1`, mark skipped
If "I'll fix it manually" → add to `skipped_tier1`, mark skipped

---

#### 7. Post-Fix Check

If ALL remaining findings are now in `skipped_tier1` (user declined every one):
→ record exit reason `USER_SKIPPED` → **EXIT LOOP**

---

#### 8. Advance Iteration

```
iteration++
```

Go to step 1 (Iteration Header).

---

### Loop Exit Summary

| Exit Reason | Meaning |
|-------------|---------|
| `CLEAN` | All agents returned 0 findings |
| `USER_SKIPPED` | All remaining findings were declined by user |
| `STAGNATION` | Same findings returned 2+ consecutive iterations; user stopped |
| `MAX_ITERATIONS` | User chose to stop at iteration limit |

---

## Phase 4: Summary

**Goal**: Report the full loop outcome.

**Actions**:

1. **Apply `writing-clearly-and-concisely` skill** to the summary output

2. **Output summary**:

```markdown
## Verify Loop Complete

### Scope
- Files verified: [N]
- Agents used: [list]
- Iterations run: [N]
- Exit reason: [CLEAN | USER_SKIPPED | STAGNATION | MAX_ITERATIONS]

### Findings (across all iterations)
- Total findings encountered: [N]
- Auto-fixed: [N]
- User-approved fixes: [N]
- Skipped by user: [N]

### Changes Made
- [list files modified by auto-fixes and approved Tier 1 fixes, if any]

### Remaining Issues (if any)
[List each skipped finding: file:line — description]

### Next Steps
[Ready for /rptc:commit, or note remaining known issues if any were skipped]
```

---

## Agent Delegation Reference

### Verification Agents

**AGENT NAMESPACE LOCKOUT:**
- ✅ CORRECT: `subagent_type="rptc:code-review-agent"`
- ❌ WRONG: `subagent_type="feature-dev:code-reviewer"` — different plugin, not RPTC
- ❌ WRONG: `subagent_type="code-review:code-review"` — different plugin, not RPTC

**Mode**: Report-only. Agents report findings; main context handles fixes.

**Agents (use these exact `subagent_type` values):**
1. `rptc:code-review-agent`: Code quality, complexity, KISS/YAGNI
2. `rptc:security-agent`: Input validation, auth, injection, data exposure
3. `rptc:docs-agent`: README, API docs, inline comments, breaking changes

---

## Important Notes

1. **Scope and agents fixed at start**: Determined in Phases 1-2 and never re-asked
2. **Same agents, same quality**: Uses identical verification agents as Phase 4 of `/rptc:feat`
3. **Auto-fix by default**: Fix Tier 2-4 findings without interruption; ask only for Tier 1
4. **Safety over completeness**: Stagnation detection, max iterations, and skip tracking
   guarantee the loop always exits
5. **Skipped findings persist**: Once a user declines a finding, it is not raised again
6. **Confidence filtering**: Only surface issues ≥80 confidence

---

## Error Handling

- **No files to verify**: Ask user for path or suggest full-app scan
- **Agent fails**: Report which agent failed, continue with others, count as 0 findings from that agent
- **All agents fail**: Exit loop, report failure, suggest re-running
- **No findings on first iteration**: Report clean immediately, skip remaining iterations
- **Git not available**: Fall back to requiring path argument
