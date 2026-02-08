---
description: Reproduction → Root Cause → Fix → Verification
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TodoWrite, AskUserQuestion, EnterPlanMode, ExitPlanMode
---

# /rptc:fix

Systematic bug fixing: Reproduction → Root Cause Analysis → Fix → Verification.

## Step 0: RPTC Workflow Initialization (MANDATORY - CANNOT SKIP)

**Before ANY other action, establish RPTC workflow context.**

### 0.1 Load Required Skills (ALL FOUR MANDATORY)

Load ALL four skills below. Each `Skill()` call is MANDATORY — do not skip any.

```
Skill(skill: "rptc:brainstorming")
Skill(skill: "rptc:writing-clearly-and-concisely")
Skill(skill: "rptc:tdd-methodology")
Skill(skill: "rptc:agent-teams")
```

**BLOCKING GATE — Skill Loading Verification**:

After loading, confirm ALL four skills loaded by listing them:

```
Skills loaded:
1. rptc:brainstorming — ✅
2. rptc:writing-clearly-and-concisely — ✅
3. rptc:tdd-methodology — ✅
4. rptc:agent-teams — ✅
```

If ANY skill fails to load, STOP and report the failure. Do NOT proceed to Phase 1 with missing skills. The `rptc:agent-teams` skill is infrastructure — it must load even when teams mode may not activate.

### 0.1.1 Conditional Skills (Load When Applicable)

**Frontend work** — If the bug involves HTML, CSS, UI components, web pages, or frontend interfaces:

```
Skill(skill: "frontend-design:frontend-design")
```

> This is an external plugin skill (Anthropic's `frontend-design` plugin) that provides creative direction and distinctive aesthetics. If unavailable, skip silently — the RPTC `frontend-guidelines.md` SOP (loaded via the SOP Reference Chain) still applies for engineering standards. Both are complementary: the SOP ensures correctness (accessibility, performance, responsive), the skill ensures distinction (bold aesthetics, memorable design). Do NOT error or warn the user if the plugin is missing.

> **IMPORTANT**: If the project already has an established design system, style guide, or visual aesthetic, the skill's creative direction MUST work within those constraints. Research existing styles first (CSS variables, component library, brand guidelines) and preserve them — do not introduce a conflicting aesthetic when fixing bugs. The skill adds polish and intentionality, not a new identity.

### 0.2 RPTC Workflow Understanding (INTERNALIZE)

You are executing the **RPTC (Research → Plan → TDD → Commit)** workflow for bug fixing.

**Core Philosophy:**
- Reproduce before fixing (confirm the bug exists)
- Root cause analysis (fix the cause, not symptoms)
- Test-first development (regression test proves the bug)
- Quality gates before shipping (no shortcuts)

**Non-Negotiable Directives:**

| Directive | Meaning | Verification |
|-----------|---------|--------------|
| **Surgical Coding** | Find 3 similar patterns before creating new code | Search codebase first |
| **KISS/YAGNI** | Minimal fix; no refactoring beyond the bug | Smallest possible change |
| **Test-First** | Write regression test BEFORE fixing | Test reproduces bug first |
| **Pattern Alignment** | Match existing codebase conventions | Study before implementing |
| **User Authority** | User is PM; approves all major decisions | Ask when uncertain |

**SOP Reference Chain (with Precedence):**

| Topic | Check First (User) | Fallback (RPTC) |
|-------|-------------------|-----------------|
| Architecture | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/architecture-patterns.md` |
| Testing | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/testing-guide.md` |
| Security | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/security-and-performance.md` |
| Progress Tracking | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/todowrite-guide.md` |
| Refactoring | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/post-tdd-refactoring.md` |
| Frontend | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/frontend-guidelines.md` |

**Precedence Rule**: If user specifies custom SOPs (in project CLAUDE.md, project `sop/` dir, or `~/.claude/global/`), use those for the matching topic. RPTC SOPs are the fallback default.

### 0.3 Phase Structure Awareness

This workflow has **5 mandatory phases**. You MUST NOT skip phases.

| Phase | Name | Key Deliverable | Blocking? |
|-------|------|-----------------|-----------|
| 1 | Reproduction & Triage | Confirmed bug with repro steps | No |
| 2 | Root Cause Analysis | 5 Whys result, fix approach | No |
| 3 | Fix Application | Regression test + minimal fix | No |
| 4 | Verification | All verification findings addressed | **YES** |
| 5 | Complete | Summary for commit | **YES** |

**Phase 4 and 5 transitions are BLOCKING GATES. Cannot proceed without verification.**

### 0.4 Initialization Verification

Before proceeding to Phase 1, confirm:
- Skills loaded and active
- RPTC directives understood
- SOP references noted
- Phase structure clear

**CRITICAL: If verification fails, STOP. Do not proceed to Phase 1.**

---

## Arguments

`/rptc:fix <bug-description>`

**Example**: `/rptc:fix "Cart items disappear after page refresh"`

---

## Bug Severity Classification

**Before starting**, classify the bug to determine urgency:

| Severity | Description | Response |
|----------|-------------|----------|
| **S1 Blocker** | System unusable, crashes, data loss | Immediate fix, skip plan mode |
| **S2 Critical** | Core functionality broken, no workaround | High priority, skip plan mode |
| **S3 Major** | Significant impact, workarounds exist | Normal priority, full workflow |
| **S4 Minor** | UI issues, inconveniences | Lower priority, skip plan mode |

**Result**: Set `severity` for Phase 2 routing (S1-S2, S4 may skip plan mode). Phase 4 (Verification) is always required.

---

## Tool Prioritization

**Serena MCP** (when available, prefer over native tools):

Serena tools may appear as `mcp__serena__*` or `mcp__plugin_serena_serena__*` — use whichever is available.

| Task | Prefer Serena | Over Native |
|------|---------------|-------------|
| Find functions/classes | `get_symbols_overview` | Grep |
| Locate specific code | `find_symbol` | Glob |
| Find usages/references | `find_referencing_symbols` | Grep |
| Regex search | `search_for_pattern` | Grep |
| Reflect on progress | `think_about_collected_information` | — |

**Sequential Thinking MCP** (STRONGLY RECOMMENDED):

Use `sequentialthinking` tool (may appear as `mcp__sequentialthinking__*`, `mcp__MCP_DOCKER__sequentialthinking`, or `mcp__plugin_sequentialthinking_*`) for **anything beyond the most basic tasks**.

| When to Use | Examples |
|-------------|----------|
| **Always use** | Root cause analysis, debugging, multi-step fixes, 5 Whys |
| **Skip only for** | Single-line typo fixes, trivial config changes |

**Default behavior**: When in doubt, use Sequential Thinking. It improves reasoning quality significantly.

---

## Skills Usage Guide

**`brainstorming`** - Structured dialogue for fix approach exploration:

| When | Apply To |
|------|----------|
| Phase 2 (before architect agent) | Explore fix approaches when multiple options exist |
| Throughout | Validate assumptions, clarify constraints |

**Method**: One question at a time via AskUserQuestion, multiple choice preferred, YAGNI ruthlessly.
**Timing**: Main context uses this BEFORE delegating to architect agent.

**`writing-clearly-and-concisely`** - Apply Strunk's Elements of Style to all prose:

| When | Apply To |
|------|----------|
| Phase 2 | Root cause explanation, fix rationale |
| Phase 5 | Bug summary, regression notes |
| Throughout | Commit messages, documentation updates |

**Key rules**: Active voice, positive form, definite language, omit needless words.

**`tdd-methodology`** - RED-GREEN-REFACTOR enforcement for main context code changes:

| When | Apply To |
|------|----------|
| Phase 3 (Fix Application) | Any code written in main context (not delegated to tdd-agent) |

**Method**: Surgical coding (search 3 similar patterns first), context discovery (check existing tests), strict RED-GREEN-REFACTOR cycle. For bug fixes: write a test that reproduces the bug FIRST (RED), then fix (GREEN).
**Timing**: Main context applies this when handling fix directly. Sub-agent `rptc:tdd-agent` has equivalent guidance built in.

**`frontend-design:frontend-design`** *(conditional)* - Distinctive, production-grade frontend interfaces:

| When | Apply To |
|------|----------|
| Phase 3 (when bug involves frontend) | HTML, CSS, UI components, web pages, visual fixes |

**Method**: Maintain design quality when fixing frontend bugs — preserve aesthetic intent, typography, color themes, and motion patterns.
**Timing**: Load in Step 0.1.1 only when the bug involves frontend code. Additive creative layer on top of `frontend-guidelines.md` SOP (which always applies for engineering standards).

**`rptc:agent-teams`** - Parallel execution via Agent Teams (MANDATORY LOAD):

| When | Apply To |
|------|----------|
| Step 0 (always loaded) | Infrastructure — required for Teams Analysis after Phase 1 |
| Phase 1 (after triage) | Batch bug fixes, parallel independent fixes, user-requested teams |

**Method**: Analyzes work for teams suitability, determines autonomy level (A/B/C), builds spawn prompts with RPTC enforcement.
**Timing**: ALWAYS loaded in Step 0. Runs Teams Analysis at end of Phase 1. Routes to teams mode or continues standard RPTC. Must be loaded even if teams mode does not activate — the analysis itself requires it.

---

## Phase 1: Reproduction & Triage

**Goal**: Confirm the bug exists and understand its triggering conditions.

> 💡 **Tool Reminder**: Use Sequential Thinking to analyze bug context. Use Serena for code tracing.

**Actions**:

0. **Check for RPTC configuration** in project's CLAUDE.md:
   - Look for `<!-- RPTC-START` marker in local CLAUDE.md
   - If NOT found: Suggest user run `/rptc:config` for best experience
   - If found but outdated: Suggest user run `/rptc:config` to sync with current plugin version

1. **Create initial todo list** with phases:
   - Reproduction & Triage, Root Cause Analysis, Fix Application, Verification, Complete

2. **Gather bug context** from user:
   - What is the expected behavior?
   - What is the actual behavior?
   - Steps to reproduce (if known)
   - Environment details (if relevant)
   - Error messages, stack traces, logs

3. **If reproduction steps unclear**, ask user for clarification via AskUserQuestion

4. **Launch 2-3 research agents in parallel** for bug investigation (NOT the built-in Explore agent):

```
IMPORTANT: Use subagent_type="rptc:research-agent", NOT "Explore"

Use Task tool with subagent_type="rptc:research-agent" (launch all in parallel):

Agent 1 prompt: "Investigate bug: [description].
Use code-explorer methodology Phase 1 (Feature Discovery): Find where bug manifests, entry points, affected files.
Return: Reproduction confirmed (Y/N), failure point location, error details."

Agent 2 prompt: "Investigate bug: [description].
Use code-explorer methodology Phase 2 (Code Flow Tracing): Trace execution from entry point to error.
Return: Code path (file:line references), where behavior diverges from expected, data flow analysis."

Agent 3 prompt: "Investigate bug: [description].
Use code-explorer methodology Phase 3 (Architecture Analysis): What components are affected? Similar patterns elsewhere?
Return: Affected files/functions, related code with same pattern, potential regression scope."
```

5. **Optional: Git bisect** for regressions:
   - If bug worked before: "When did this break?"
   - Use `git log` to find likely commit range
   - Suggest bisect if >20 commits in range

6. **Summarize findings**:
   - Bug confirmed: Y/N
   - Failure point: file:line
   - Affected code paths
   - Severity classification

### Teams Analysis

Run the `agent-teams` skill's Teams Analysis. It evaluates three signals:
1. Multiple independent work streams detected
2. Cross-agent debate would improve outcomes
3. User explicitly requested teams

**If teams mode activates**: The skill takes over orchestration. Do NOT continue
to Phase 2 — the skill handles the remaining workflow.

**If teams mode does NOT activate**: Continue to Phase 2 as normal.

---

## Phase 2: Root Cause Analysis

**Goal**: Identify the fundamental cause and plan the fix.

> 💡 **Tool Reminder**: Use Sequential Thinking for 5 Whys analysis — it excels at multi-step reasoning.

**Actions**:

1. **Apply 5 Whys methodology** (use Sequential Thinking) to findings from Phase 1:
   ```
   Why? [Symptom observed]
   Why? [Immediate cause]
   Why? [Underlying cause]
   Why? [Deeper cause]
   Why? [Root cause - systemic/code-level issue]
   ```

2. **For simple bugs (S3-S4, clear root cause)**: Skip plan mode
   - Document root cause inline
   - Proceed directly to Phase 3

3. **For complex bugs (S1-S2, or unclear root cause)**: Enter plan mode
   - Use EnterPlanMode tool
   - **Clarify fix approach using `brainstorming` skill** (BEFORE architect-agent):
     - Use AskUserQuestion to explore fix options ONE question at a time
     - Present 2-3 fix approaches with trade-offs
     - Clarify: acceptable scope, risk tolerance, timeline constraints
     - Skip if: fix approach is obvious from root cause analysis
   - Launch architect-agent for fix planning:

```
Use Task tool with subagent_type="rptc:architect-agent":

## Bug Context
- Description: [bug description]
- Symptom: [observed behavior]
- Root Cause: [from 5 Whys analysis]
- Failure Point: [file:line from Phase 1]
- Affected Paths: [from Phase 1]

## Your Task
Design a minimal fix for this bug. Perspective: Surgical.

Provide:
1. Fix approach (1-3 steps maximum)
2. Files to modify
3. Regression test strategy
4. Risk assessment (what could break)

Constraints:
- MINIMAL change - fix the root cause only
- NO refactoring unrelated code
- NO scope creep
```

4. **Review fix plan**:
   - Is the fix addressing root cause (not just symptom)?
   - Is the fix minimal and surgical?
   - What's the regression risk?

5. **If plan mode used**: Exit with ExitPlanMode for user approval

---

## Phase 3: Fix Application

**Goal**: Apply the fix using test-driven approach (regression test first).

> 💡 **Tool Reminder**: Use Serena for precise code navigation when applying fixes.

**CRITICAL - Test-First Ordering (NON-NEGOTIABLE)**:

Whether delegating to tdd-agent OR executing in main context:

1. Write the regression test that reproduces the bug BEFORE modifying ANY production code
2. Update any existing tests BEFORE changing production code
3. Run tests and confirm they fail BEFORE writing the fix
4. Only after tests exist and fail may you edit production files

**FILE LOCKOUT RULE**: During RED phase, you may ONLY create or modify test files (`tests/`, `__tests__/`, `*.test.*`, `*.spec.*`). Any edit to a production/source file during RED phase is a TDD violation. STOP and revert if this happens.

#### Delegation Decision: Direct or Agent?

| Criteria | Execute Directly (Main Context) | Delegate to tdd-agent |
|----------|--------------------------------|----------------------|
| Fix steps | 1 step (single root cause) | 2+ steps or multi-component |
| Files affected | 1-2 files | 3+ files |
| Estimated lines | <30 lines changed | 30+ lines |
| Complexity | Clear root cause, obvious fix | Complex interactions, cascading changes |

**If Direct**: Execute fix in main context using TDD methodology.

```
Skill(skill: "rptc:tdd-methodology")
```

**Test-First Gate (Direct Execution)**: Execute in strict order.

1. **Surgical Coding**: Search 3 similar patterns first
2. **Context Discovery**: Check existing tests, framework, naming conventions
3. **RED**: Write regression test reproducing the bug. Run it. Confirm it fails with same symptom.

   **BLOCKING GATE — RED Phase Verification** (MANDATORY, cannot skip):

   Before ANY production file edit, verify via output:
   ```
   RED GATE CHECK:
   - Regression test written: [test file path]
   - Test failing: confirms bug symptom "[symptom]"
   - Production files touched: NONE
   → PASS: Proceed to GREEN
   ```
   If production files were touched → STOP. Revert production changes. Complete RED first.

4. **GREEN**: Apply minimal fix (NOW you may edit production files)
5. **REFACTOR**: Clean up only if needed (keep fix surgical)
6. **VERIFY**: Run affected tests, confirm regression test passes

Then skip to step 2 (Update TodoWrite) below.

**If Delegate**: Use tdd-agent (continue below).

**Actions**:

1. **Delegate to TDD agent** with regression emphasis:

```
Use Task tool with subagent_type="rptc:tdd-agent":

## Bug Fix Context
- Bug: [description]
- Root Cause: [from Phase 2]
- Fix Location: [file:line]
- Fix Approach: [from Phase 2 plan or inline decision]

## TDD Bug Fix Cycle

### RED Phase (Critical — test files ONLY)
Write a test that REPRODUCES the exact bug:
- Test must fail with the SAME symptom as the bug
- Test must use the SAME conditions that trigger the bug
- Verify: test fails for the right reason (not compile error)
- FILE LOCKOUT: Only test files may be created/modified during RED phase. Do NOT touch production files.

Example structure:
```
test('should [expected behavior] when [condition]', () => {
  // Arrange: Set up bug-triggering conditions
  // Act: Perform the action that triggers the bug
  // Assert: Verify correct behavior (currently fails)
});
```

After writing tests, output RED GATE CHECK:
```
RED GATE CHECK:
- Regression test written: [test file path]
- Test failing: confirms bug symptom "[symptom]"
- Production files touched: NONE
→ PASS: Proceed to GREEN
```
If production files were touched → STOP. Revert. Complete RED first.

### GREEN Phase (Surgical — NOW edit production files)
Apply MINIMAL fix to make the test pass:
- Change ONLY what's necessary to fix the root cause
- Do NOT refactor nearby code
- Do NOT "improve" unrelated code
- Diff should be as small as possible

### VERIFY Phase (Regression Check)
- Run the new regression test (must pass)
- Run related test files (must pass)
- Run affected tests — files that import or reference changed modules (must pass)
- Run ONLY affected tests — do NOT run the full test suite (full suite runs are reserved for `/rptc:commit`)
- Report any new failures

## Constraints
- Maximum 3 implementation steps
- Keep fix surgical and minimal
- Flag if fix suggests larger refactoring need (don't do it, just flag)
```

1b. **Verify fix compliance**: After tdd-agent returns, check the exit verification block:
    - `Test-First Followed: YES` → continue
    - `Test-First Followed: NO` → flag as TDD violation, ask user whether to re-run or accept

2. **Update TodoWrite** as fix progresses

3. **Handle failures**:
   - If test won't reproduce bug: Return to Phase 1 for better reproduction
   - If fix causes new failures: Analyze regression, adjust fix
   - If fix attempt fails 3x: Ask user for guidance

4. **MANDATORY**: Add TodoWrite item "Quality Verification" with status "pending" (if not exists)
5. **MANDATORY: Execute Phase 4 next** — Quality Verification MUST run before Phase 5. Do NOT skip to completion.

---

## Phase 4: Verification (MANDATORY - BLOCKING GATE)

**Goal**: Verify the fix works and didn't introduce regressions.

**CRITICAL**: This phase MUST execute. Phase 5 CANNOT begin until this phase completes.

**This phase runs for ALL bugs regardless of severity (S1-S4).** Even urgent S1 fixes must be reviewed before completion.

**Actions**:

0. **Update TodoWrite**: Mark "Quality Verification" as in_progress

1. **Determine verification agent mode** (one-time project configuration):

   a. **Check if project CLAUDE.md exists** (in project root)

   b. **If CLAUDE.md exists**, look for `verification-agent-mode:` setting:
      - If found: Use that mode (`automatic`, `all`, or `minimal`)
      - If not found: Ask user via AskUserQuestion (one-time setup):
        ```
        Use AskUserQuestion:
        question: "How should verification agents be selected for this project? (saved to CLAUDE.md)"
        header: "Verification Mode"
        options:
          - label: "Automatic (Recommended)"
            description: "Smart selection based on file types and change patterns"
          - label: "All Agents"
            description: "Always launch all 3 verification agents"
          - label: "Minimal"
            description: "Only launch agents when strongly indicated"
        ```
        Then append to CLAUDE.md:
        ```markdown
        ## RPTC Verification Configuration
        verification-agent-mode: [selected mode]
        ```

   c. **If no CLAUDE.md exists**: Use `automatic` mode (don't ask, don't create file)

2. **Select agents based on mode**:

   **Mode: `all`** — Launch all 3 agents (skip to step 3)

   **Mode: `automatic`** — Select based on changes:

   | Change Type | code-review | security | docs |
   |-------------|:-----------:|:--------:|:----:|
   | Source code in `auth/`, `api/`, `security/`, `middleware/` paths | ✅ | ✅ | Check keywords |
   | Source code (other paths) | ✅ | Check keywords | Check keywords |
   | Test files only | ✅ | ❌ | ❌ |
   | Dependencies changed | ❌ | ✅ | ❌ |
   | Docs/markdown only | ❌ | ❌ | ✅ |

   **Keyword detection** (scan git diff):
   - Security keywords: `password`, `token`, `secret`, `auth`, `session`, `crypto`, `hash`, `sql`, `exec`, `eval` → include security-agent
   - API keywords: `export`, `interface`, `endpoint`, `route`, `version` → include docs-agent

   **Default**: If uncertain, include the agent

   **Mode: `minimal`** — Only launch when strongly indicated:
   - code-review: **ALWAYS** (minimum floor — at least one verification agent must launch)
   - security: Only if auth/api paths OR security keywords found
   - docs: Only if doc files changed OR export keyword found

3. **Launch selected verification agents**:

   **AGENT NAMESPACE LOCKOUT (Phase 4):**
   - ✅ CORRECT: `subagent_type="rptc:code-review-agent"`
   - ❌ WRONG: `subagent_type="feature-dev:code-reviewer"` — different plugin, not RPTC
   - ❌ WRONG: `subagent_type="code-review:code-review"` — different plugin, not RPTC
   - The `rptc:` prefix is required for ALL verification agents. No exceptions.

   **Code Review Agent** (if selected):
   ```
   Use Task tool with subagent_type="rptc:code-review-agent":
   ⚠️ WRONG agents: "feature-dev:code-reviewer", "code-review:code-review" — DO NOT USE

   prompt: "Review bug fix for: [bug description].
   Files modified: [list files].
   Focus: Is this the ACTUAL root cause fix (not band-aid)? Is the fix minimal and surgical? Similar patterns elsewhere? Regression risk?
   REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."
   ```

   **Security Agent** (if selected):
   ```
   Use Task tool with subagent_type="rptc:security-agent":
   prompt: "Security review for bug fix: [bug description].
   Files modified: [list files].
   Focus: Did the fix maintain security invariants? Any new vulnerabilities introduced?
   REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."
   ```

   **Documentation Agent** (if selected):
   ```
   Use Task tool with subagent_type="rptc:docs-agent":
   prompt: "Documentation review for bug fix: [bug description].
   Files modified: [list files].
   Focus: Does the bug affect documented behavior? Any docs need updating?
   REPORT ONLY - do not make changes. Output: documentation updates needed (≥80 only)."
   ```

4. **Consolidate findings** from launched agents:
   - Fix quality: Root cause addressed? Minimal scope?
   - Regression risk: Side effects identified?
   - Documentation: Updates needed?

5. **Create TodoWrite for ALL findings** (auto-fix by default)

6. **Auto-fix findings** (no user approval needed for most issues):

   **Fix automatically**:
   - Nits: naming, formatting, minor style issues
   - Documentation updates
   - Minor code improvements (<30 lines)
   - Test assertions or coverage gaps

   **Ask user FIRST**:
   - Fix scope expansion (touches files outside original bug scope)
   - Regression risks identified by reviewers
   - Security concerns raised
   - Architectural issues

   **Process**:
   - Work through TodoWrite items sequentially
   - For auto-fix items: Apply fix, mark complete
   - For ask-first items: Use AskUserQuestion with fix proposal, then apply or skip
   - Mark all todos complete as addressed

7. **Update TodoWrite**: Mark "Quality Verification" as completed

8. **BLOCKING GATE — User Acknowledgment** (MANDATORY, cannot skip):

   Present review results to the user. This is a tool-enforced gate — you MUST call AskUserQuestion here.

   ```
   Use AskUserQuestion:
   question: "Phase 4 verification complete. [N] findings addressed. Proceed to completion?"
   header: "Verification Gate"
   options:
     - label: "Proceed to Phase 5"
       description: "All verification findings addressed, ready to wrap up"
     - label: "Re-verify needed"
       description: "I want to revisit some findings before completing"
     - label: "Add more verification scope"
       description: "Launch additional verification agents or expand scope"
   ```

   If user selects "Re-verify needed" → return to step 6 (auto-fix).
   If user selects "Add more verification scope" → return to step 3 (launch agents).

---

## Phase 5: Complete

**BLOCKING CHECKPOINT** — Before Phase 5 can begin:

- [ ] TodoWrite "Quality Verification" item MUST be marked "completed"
- [ ] At least one verification agent MUST have been launched
- [ ] User acknowledged verification results via AskUserQuestion (step 8)

If Quality Verification not completed → **STOP**. Return to Phase 4.

---

**Goal**: Summarize what was fixed and document for future reference.

**Actions**:

1. **Mark all todos complete**

2. **Summary output**:

```markdown
## Bug Fix Summary

### Bug
[Original description]

### Root Cause
[5 Whys result - the fundamental cause]

### Fix Applied
- Files modified: [list]
- Change summary: [brief description]

### Regression Prevention
- Test added: [test file:test name]
- Test verifies: [what the test checks]

### Verification
- [ ] Regression test passes
- [ ] Related tests pass
- [ ] Affected tests pass
- [ ] Verification findings addressed

### Notes
[Any follow-up items, related issues to watch, or technical debt flagged]
```

3. **Suggest next steps**:
   - Ready for `/rptc:commit`
   - Or: Additional issues identified that need separate fixes

---

## Agent Delegation Reference

### Investigation Agents (Phase 1)

```
Launch 2-3 Task tools in parallel with subagent_type="rptc:research-agent":

Agent 1: "Investigate bug [description]. Reproduce and verify failure point."
Agent 2: "Trace code flow for [bug]. Entry point → error → symptom."
Agent 3: "Map impact. Affected components, similar patterns elsewhere."
```

### Fix Planning Agent (Phase 2 - Complex Bugs Only)

```
Use Task tool with subagent_type="rptc:architect-agent":

## Bug Context
[Description, symptom, root cause, failure point]

## Your Task
Design minimal fix. Perspective: Surgical.
Provide: Fix steps (1-3 max), files, test strategy, risk assessment.
```

### TDD Fix Agent (Phase 3)

```
Use Task tool with subagent_type="rptc:tdd-agent":

## Bug Fix Context
[Bug, root cause, fix location, approach]

## TDD Bug Fix Cycle
RED: Write test that reproduces bug (must fail with same symptom).
  FILE LOCKOUT: Only test files during RED. No production file edits.
  Output RED GATE CHECK before proceeding to GREEN.
GREEN: Apply minimal fix (NOW edit production files, surgical, no scope creep)
VERIFY: Run affected tests, check for regressions
```

### Verification Agents (Phase 4) - Semantic Selection

**AGENT NAMESPACE LOCKOUT:**
- ✅ CORRECT: `subagent_type="rptc:code-review-agent"`
- ❌ WRONG: `subagent_type="feature-dev:code-reviewer"` — different plugin, not RPTC
- ❌ WRONG: `subagent_type="code-review:code-review"` — different plugin, not RPTC

**Selection based on `verification-agent-mode` in project CLAUDE.md:**
- `all`: Launch all 3 agents
- `automatic`: Select based on file types/keywords (default if no CLAUDE.md)
- `minimal`: code-review always launches; others when strongly indicated

**Agents (use these exact `subagent_type` values):**
1. `rptc:code-review-agent`: Root cause fix? Minimal? Regression risk?
2. `rptc:security-agent`: Security invariants maintained? New vulnerabilities?
3. `rptc:docs-agent`: Behavior changes need doc updates?

**Quick reference for `automatic` mode:**
- Source code changed → code-review
- Auth/api paths OR security keywords → security
- Doc files OR behavior changes → docs
- Test files only → code-review only

---

## Key Principles

1. **Reproduce before fixing**: Never fix a bug you can't reproduce
2. **Root cause, not symptom**: 5 Whys until you find the real cause
3. **Regression test first**: Write failing test that reproduces bug before fixing
4. **Minimal and surgical**: Smallest possible change to fix the root cause
5. **No scope creep**: Flag refactoring needs, don't do them in bug fix
6. **Verify thoroughly**: Check that fix works AND didn't break related functionality

---

## Differences from /rptc:feat

| Aspect | /rptc:feat | /rptc:fix |
|--------|------------|-----------|
| **Goal** | Build new functionality | Fix existing behavior |
| **Phase 1** | Discover patterns | Reproduce failure |
| **Phase 2** | Design (3 perspectives) | Diagnose (single analysis) |
| **Phase 3** | Multi-step TDD | Regression test + minimal fix |
| **Phase 4** | Quality verification | Quality verification + regression focus |
| **Test Focus** | Define NEW behavior | Prevent RECURRENCE |
| **Scope** | Can be large | Must be minimal |
| **Plan Mode** | Always required | Optional for simple bugs |
| **Typical Steps** | 5-15 steps | 1-3 steps |

---

## Error Handling

- **Can't reproduce**: Ask user for more details, environment info, exact steps
- **Root cause unclear after analysis**: Try multiple hypotheses, ask user for context
- **Fix causes regressions**: Analyze what broke, adjust fix approach
- **Fix attempt fails 3x**: Pause, present findings, ask user for guidance
- **Larger refactoring needed**: Flag it, complete minimal fix, suggest follow-up task
- **Phase 4 not executed**: INVALID STATE. Return to Phase 4. Phase 5 cannot proceed without verification.

