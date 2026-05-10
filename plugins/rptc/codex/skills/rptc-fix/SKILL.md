---
name: rptc-fix
description: Reproduction → Root Cause → Fix → Verification. Use when the user asks for /rptc:fix or the equivalent RPTC Codex workflow intent.
---

# /rptc:fix

Systematic bug fixing: Reproduction → Root Cause Analysis → Fix → Verification.

## Step 0: RPTC Workflow Initialization (MANDATORY - CANNOT SKIP)

**Before ANY other action, establish RPTC workflow context.**

### 0.1 Load Required Skills (ALL FIVE MANDATORY)

Load ALL five skills below. Each listed skill is MANDATORY — do not skip any.

```
Use/load the `rptc:tool-guide` skill.
Use/load the `rptc:brainstorming` skill.
Use/load the `rptc:writing-clearly-and-concisely` skill.
Use/load the `rptc:tdd-methodology` skill.
Use/load the `rptc:structure-methodology` skill.
```

After loading, confirm all five loaded. If ANY skill fails to load, STOP and report the failure.

> **Note**: Codex omits the Claude `fix-team` command because it depends on persistent team-agent messaging. For larger fixes, use this workflow with parent-orchestrated `spawn_agent` delegation where appropriate.

### 0.1.1 Conditional Skills (Load When Applicable)

**Frontend work** — If the bug involves HTML, CSS, UI components, web pages, or frontend interfaces:

```
Use/load the `rptc:frontend-design` skill.
```

> Provides creative direction and distinctive aesthetics. Complements the RPTC `frontend-guidelines.md` SOP (loaded via the SOP Reference Chain): the SOP ensures correctness (accessibility, performance, responsive), the skill ensures distinction (bold aesthetics, memorable design).

> **IMPORTANT**: If the project already has an established design system, style guide, or visual aesthetic, the skill's creative direction MUST work within those constraints. Research existing styles first (CSS variables, component library, brand guidelines) and preserve them — do not introduce a conflicting aesthetic when fixing bugs. The skill adds polish and intentionality, not a new identity.

### 0.1.2 Activate Serena MCP (MANDATORY)

Serena tools are **deferred** in the main context — they require explicit loading before they can be called.

Use tool discovery to activate them when available:

```
Use tool discovery for Serena when available, then activate Serena tools.
```

Once loaded, Serena tools appear as `mcp__serena__*` or `mcp__plugin_serena_serena__*`. This activates both read tools (`find_symbol`, `get_symbols_overview`, `search_for_pattern`, etc.) and edit tools (`replace_symbol_body`, `insert_after_symbol`, etc.). Use them throughout this workflow — refer to the Tool Prioritization section for the full map of Serena vs. native tools.

If Serena is unavailable (not installed), skip silently and fall back to native Grep and Glob.

### 0.1.3 Custom Agent Availability (Before Delegation)

Before any `spawn_agent` call for an RPTC custom agent, verify the required TOML agents are installed in `.codex/agents/` or the user's Codex agents directory.

Required for this workflow when delegation is used: `rptc:architect-agent`, `rptc:tdd-agent`, `rptc:code-review-agent`, `rptc:security-agent`, `rptc:docs-agent`.

If any required TOML is missing, use/load `rptc-init` to copy the packaged agents, then re-check. If agents are still unavailable, use built-in `explorer`/`worker` agents only when they can preserve the same role boundaries; otherwise keep the work in the main context and report the limitation.

### 0.2 RPTC Workflow Understanding (INTERNALIZE)

You are executing the **RPTC (Research → Plan → TDD → Commit)** workflow for bug fixing.

**Core Philosophy:**
- Reproduce before fixing (confirm the bug exists)
- Root cause analysis (fix the cause, not symptoms)
- Test-first development (regression test proves the bug)
- Quality gates before shipping (no shortcuts)

**SOP Reference Chain (with Precedence):**

| Topic | Check First (User) | Fallback (RPTC) |
|-------|-------------------|-----------------|
| Architecture | Project `sop/`, `user/project SOPs` | `the RPTC plugin root/sop/architecture-patterns.md` |
| Testing | Project `sop/`, `user/project SOPs` | `the RPTC plugin root/sop/testing-guide.md` |
| Security | Project `sop/`, `user/project SOPs` | `the RPTC plugin root/sop/security-and-performance.md` |
| Progress Tracking | Project `sop/`, `user/project SOPs` | `update_plan` with explicit ordered phase steps (see Step 0.5) |
| Refactoring | Project `sop/`, `user/project SOPs` | `the RPTC plugin root/sop/post-tdd-refactoring.md` |
| Frontend | Project `sop/`, `user/project SOPs` | `the RPTC plugin root/sop/frontend-guidelines.md` |

**Precedence Rule**: If user specifies custom SOPs (in project AGENTS.md, project `sop/` dir, or `user/project SOPs`), use those for the matching topic. RPTC SOPs are the fallback default.

### 0.3 Phase Structure Awareness

This workflow has **5 mandatory phases**. You MUST NOT skip phases.

| Phase | Name | Key Deliverable |
|-------|------|-----------------|
| 1 | Reproduction & Triage | Confirmed bug with repro steps |
| 2 | Root Cause Analysis | 5 Whys result, fix approach |
| 3 | Fix Application | Regression test + minimal fix |
| 4 | Verification | All verification findings addressed |
| 5 | Complete | Summary for commit |

Phase ordering is enforced by task dependencies created in Step 0.5.

### 0.4 Initialization Verification

Before proceeding to Phase 1, confirm:
- Skills loaded and active
- RPTC directives understood
- SOP references noted
- Phase structure clear

**CRITICAL: If verification fails, STOP. Do not proceed to Phase 1.**

### 0.5 Phase Task Initialization

Create the workflow phases as an ordered `update_plan` list. Codex supports `step` and `status`; enforce dependencies by sequence: do not start a phase until the previous phase is completed.

```
update_plan:
- pending: Phase 1: Reproduction & Triage — Confirm bug with reproduction steps
- pending: Phase 2: Root Cause Analysis — 5 Whys methodology, identify fix approach
- pending: Phase 3: Fix Application — Regression test + minimal fix via TDD
- pending: Phase 4: Verification — Review agents verify fix quality
- pending: Phase 5: Complete — Summarize fix for commit
```

**At each phase**: Call `update_plan(status: "in_progress")` when starting, `update_plan(status: "completed")` when done.

### 0.6 Plan Continuation Detection

Check if the bug description argument contains **"Plan is approved"**:

**If YES** — this is a post-plan-approval re-entry (context was cleared after plan approval):

1. Step 0 initialization is already complete (skills loaded, Serena active, tasks created)
2. **Verify environment**: re-derive `REPO_ROOT` from `git rev-parse --show-toplevel`.
   Check if currently inside a worktree: compare `git rev-parse --show-toplevel` against `git worktree list`. If in a worktree, set `WORKTREE_PATH` accordingly.
3. Mark Phases 1 and 2 complete:
   ```
   update_plan(Phase 1, status: "completed")
   update_plan(Phase 2, status: "completed")
   ```
4. **Proceed directly to Phase 3: Fix Application** — the plan is already approved and available in the plan file.

**If NO** — this is a new bug report. Proceed to Phase 1.

## Bug Severity Classification

**Before starting**, classify the bug to determine urgency:

| Severity | Description | Response |
|----------|-------------|----------|
| **S1 Blocker** | System unusable, crashes, data loss | Immediate fix, skip plan mode |
| **S2 Critical** | Core functionality broken, no workaround | High priority, skip plan mode |
| **S3 Major** | Significant impact, workarounds exist | Normal priority, full workflow |
| **S4 Minor** | UI issues, inconveniences | Lower priority, skip plan mode |

**Result**: Set `severity` for Phase 2 routing (S1-S2, S4 may skip plan mode). Phase 4 (Verification) is always required.

## Skills Usage Guide

**`rptc:tool-guide`** - Tool prioritization for Serena MCP and other MCP servers (MANDATORY LOAD):

| When | Apply To |
|------|----------|
| Step 0 (always loaded) | Infrastructure — activates Serena for code navigation throughout |
| All phases | Serena read ops (`find_symbol`, `search_for_pattern`) |

**Method**: Tool discovery activates Serena at session start (Step 0.1.2 Activate Serena); then prefer `find_symbol`, `get_symbols_overview`, `search_for_pattern` over native Grep/Glob for all code navigation.
**Timing**: Loaded first in Step 0. Applies across all phases wherever code navigation or symbol search is needed.

**`brainstorming`** - Structured dialogue for fix approach exploration:

| When | Apply To |
|------|----------|
| Phase 2 (before architect agent) | Explore fix approaches when multiple options exist |
| Throughout | Validate assumptions, clarify constraints |

**Method**: One question at a time via request_user_input when available, otherwise ask directly in chat, multiple choice preferred, YAGNI ruthlessly.
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
| Phase 3 (Fix Application) | Any code written in main context (not delegated to `rptc:tdd-agent`) |

**Method**: Surgical coding (search 3 similar patterns first), context discovery (check existing tests), strict RED-GREEN-REFACTOR cycle. For bug fixes: write a test that reproduces the bug FIRST (RED), then fix (GREEN).
**Timing**: Main context applies this when handling fix directly. Sub-agent `rptc:tdd-agent` has equivalent guidance built in.

**`rptc:frontend-design`** *(conditional)* - Distinctive, production-grade frontend interfaces:

| When | Apply To |
|------|----------|
| Phase 3 (when bug involves frontend) | HTML, CSS, UI components, web pages, visual fixes |

**Method**: Maintain design quality when fixing frontend bugs — preserve aesthetic intent, typography, color themes, and motion patterns.
**Timing**: Load in Step 0.1.1 only when the bug involves frontend code. Additive creative layer on top of `frontend-guidelines.md` SOP (which always applies for engineering standards).

## Phase 2: Root Cause Analysis

`update_plan(Phase 2, status: "in_progress")`

**Goal**: Identify the fundamental cause and plan the fix.

> 💡 **Tool Reminder**: Use Serena (`find_symbol`, `find_referencing_symbols`) to trace code paths and confirm root cause.

**Actions**:

1. **Apply 5 Whys methodology** to findings from Phase 1:
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
   - Use Codex planning context
   - **Clarify fix approach using `brainstorming` skill** (BEFORE `rptc:architect-agent`):
     - Use request_user_input when available, otherwise ask directly in chat to explore fix options ONE question at a time
     - Present 2-3 fix approaches with trade-offs
     - Clarify: acceptable scope, risk tolerance, timeline constraints
     - Skip if: fix approach is obvious from root cause analysis
   - Launch `rptc:architect-agent` for fix planning:

```
Use `spawn_agent` with the RPTC `rptc:architect-agent` role when installed:

[Prepend the Environment Context Block]

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

Plan structure: Begin with Step 0: RPTC Re-initialization — instructs re-invocation of `/rptc:fix` with "Plan is approved, continue to implementation" to restore full RPTC context.
```

4. **Review fix plan**:
   - Is the fix addressing root cause (not just symptom)?
   - Is the fix minimal and surgical?
   - What's the regression risk?

5. **If plan mode used**: Verify plan includes Step 0 (re-invocation of `/rptc:fix`), then exit with user approval in chat for user approval

`update_plan(Phase 2, status: "completed")`

## Phase 4: Verification

`update_plan(Phase 4, status: "in_progress")`

**Goal**: Verify the fix works and didn't introduce regressions.

> 💡 **Tool Reminder**: Use Serena (`find_referencing_symbols`, `search_for_pattern`) when applying auto-fixes from verification findings.

**This phase runs for ALL bugs regardless of severity (S1-S4).** Even urgent S1 fixes must be reviewed before completion.

**Actions**:

1. **Determine verification agent mode** (one-time project configuration):

   a. **Check if project AGENTS.md exists** (in project root)

   b. **If AGENTS.md exists**, look for `verification-agent-mode:` setting:
      - If found: Use that mode (`automatic`, `all`, or `minimal`)
      - If not found: Ask user via request_user_input when available, otherwise ask directly in chat (one-time setup):
        ```
        Use request_user_input when available, otherwise ask directly in chat:
        question: "How should verification agents be selected for this project? (saved to AGENTS.md)"
        header: "Verification Mode"
        options:
          - label: "Automatic (Recommended)"
            description: "Smart selection based on file types and change patterns"
          - label: "All Agents"
            description: "Always launch all 3 verification agents"
          - label: "Minimal"
            description: "Only launch agents when strongly indicated"
        ```
        Then append to AGENTS.md:
        ```markdown
        ## RPTC Verification Configuration
        verification-agent-mode: [selected mode]
        ```

   c. **If no AGENTS.md exists**: Use `automatic` mode (don't ask, don't create file)

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
   - Security keywords: `password`, `token`, `secret`, `auth`, `session`, `crypto`, `hash`, `sql`, `exec`, `eval` → include `rptc:security-agent`
   - API keywords: `export`, `interface`, `endpoint`, `route`, `version` → include `rptc:docs-agent`

   **Default**: If uncertain, include the agent

   **Mode: `minimal`** — Only launch when strongly indicated:
   - code-review: **ALWAYS** (minimum floor — at least one verification agent must launch)
   - security: Only if auth/api paths OR security keywords found
   - docs: Only if doc files changed OR export keyword found

3. **Launch selected verification agents**:

   **AGENT NAMESPACE LOCKOUT (Phase 4):**
   - ✅ CORRECT: RPTC `rptc:code-review-agent` role
   - ❌ WRONG: `feature-dev:code-reviewer` role — different plugin, not RPTC
   - ❌ WRONG: `code-review:code-review` role — different plugin, not RPTC
   - The `rptc:` prefix is required for ALL verification agents. No exceptions.

   **Code Review Agent** (if selected):
   ```
   Use `spawn_agent` with the RPTC `rptc:code-review-agent` role when installed:
   ⚠️ WRONG agents: "feature-dev:code-reviewer", "code-review:code-review" — DO NOT USE

   [Prepend the Environment Context Block]

   prompt: "Review bug fix for: [bug description].
   Files modified: [list files].
   Focus: Is this the ACTUAL root cause fix (not band-aid)? Is the fix minimal and surgical? Similar patterns elsewhere? Regression risk?
   REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."
   ```

   **Security Agent** (if selected):
   ```
   Use `spawn_agent` with the RPTC `rptc:security-agent` role when installed:

   [Prepend the Environment Context Block]

   prompt: "Security review for bug fix: [bug description].
   Files modified: [list files].
   Focus: Did the fix maintain security invariants? Any new vulnerabilities introduced?
   REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."
   ```

   **Documentation Agent** (if selected):
   ```
   Use `spawn_agent` with the RPTC `rptc:docs-agent` role when installed:

   [Prepend the Environment Context Block]

   prompt: "Documentation review for bug fix: [bug description].
   Files modified: [list files].
   Focus: Does the bug affect documented behavior? Any docs need updating?
   REPORT ONLY - do not make changes. Output: documentation updates needed (≥80 only)."
   ```

4. **Consolidate findings** from launched agents:
   - Fix quality: Root cause addressed? Minimal scope?
   - Regression risk: Side effects identified?
   - Documentation: Updates needed?

5. **Create tasks for findings** (auto-fix by default)

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
   - Work through finding tasks sequentially
   - For auto-fix items: Apply fix, mark complete (`update_plan(finding, status: "completed")`)
   - For ask-first items: Use request_user_input when available, otherwise ask directly in chat with fix proposal, then apply or skip
   - Mark all finding tasks complete as addressed

7. **User Acknowledgment**:

   Present review results to the user. This is a tool-enforced gate — you MUST call request_user_input when available, otherwise ask directly in chat here.

   ```
   Use request_user_input when available, otherwise ask directly in chat:
   question: "Phase 4 verification complete. [N] findings addressed. Proceed to completion?"
   header: "Verification Gate"
   options:
     - label: "Proceed to Phase 5"
       description: "All verification findings addressed, ready to wrap up"
     - label: "Re-verify with /rptc:verify"
       description: "Run the standalone verification command to check current state"
   ```

   If user selects "Re-verify" → invoke `/rptc:verify` (uses the standalone verify workflow with agent selection and full re-scan).

`update_plan(Phase 4, status: "completed")`

## Key Principles

1. **Reproduce before fixing**: Never fix a bug you can't reproduce
2. **Root cause, not symptom**: 5 Whys until you find the real cause
3. **Regression test first**: Write failing test that reproduces bug before fixing
4. **Minimal and surgical**: Smallest possible change to fix the root cause
5. **No scope creep**: Flag refactoring needs, don't do them in bug fix
6. **Verify thoroughly**: Check that fix works AND didn't break related functionality

## Error Handling

- **Can't reproduce**: Ask user for more details, environment info, exact steps
- **Root cause unclear after analysis**: Try multiple hypotheses, ask user for context
- **Fix causes regressions**: Analyze what broke, adjust fix approach
- **Fix attempt fails 3x**: Pause, present findings, ask user for guidance
- **Larger refactoring needed**: Flag it, complete minimal fix, suggest follow-up task
- **Phase 4 not executed**: INVALID STATE. Return to Phase 4. Phase 5 cannot proceed without verification.
