---
name: rptc-feat
description: Research → Plan → TDD → Verify in one seamless flow. Use when the user asks for /rptc:feat or the equivalent RPTC Codex workflow intent.
---

# /rptc:feat

Complete feature development: Discovery → Architecture → Implementation → Quality Verification.

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

> **Note**: Codex omits the Claude `feat-team` command because it depends on persistent team-agent messaging. For larger features, use this workflow with parent-orchestrated `spawn_agent` delegation where appropriate.

### 0.1.1 Conditional Skills (Load When Applicable)

**Frontend work** — If the task involves creating or modifying HTML, CSS, UI components, web pages, or frontend interfaces:

```
Use/load the `rptc:frontend-design` skill.
```

> Provides creative direction and distinctive aesthetics. Complements the RPTC `frontend-guidelines.md` SOP (loaded via the SOP Reference Chain): the SOP ensures correctness (accessibility, performance, responsive), the skill ensures distinction (bold aesthetics, memorable design).

> **IMPORTANT**: If the project already has an established design system, style guide, or visual aesthetic, the skill's creative direction MUST work within those constraints. Research existing styles first (CSS variables, component library, brand guidelines) and extend them — do not override with a conflicting aesthetic. The skill adds polish and intentionality, not a new identity.

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

Required for this workflow when delegation is used: `rptc:architect-agent`, `rptc:research-agent`, `rptc:tdd-agent`, `rptc:code-review-agent`, `rptc:security-agent`, `rptc:docs-agent`.

If any required TOML is missing, use/load `rptc-init` to copy the packaged agents, then re-check. If agents are still unavailable, use built-in `explorer`/`worker` agents only when they can preserve the same role boundaries; otherwise keep the work in the main context and report the limitation.

### 0.2 RPTC Workflow Understanding (INTERNALIZE)

You are executing the **RPTC (Research → Plan → TDD → Commit)** workflow.

**Core Philosophy:**
- Research before coding (understand before building)
- Plan with user approval (user is PM)
- Test-first development (tests define behavior)
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

This workflow has **5 mandatory phases**. Phase ordering is enforced by task dependencies created in Step 0.5.

| Phase | Name | Key Deliverable |
|-------|------|-----------------|
| 1 | Discovery | Understanding of what to build |
| 2 | Architecture | User-approved implementation plan |
| 3 | Implementation | Working code with tests |
| 4 | Quality Verification | All findings addressed |
| 5 | Complete | Summary for commit |

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
- pending: Phase 1: Discovery — Understand what to build and existing patterns
- pending: Phase 2: Architecture — Design implementation approach with user approval
- pending: Phase 3: Implementation — Execute plan using appropriate method
- pending: Phase 4: Quality Verification — Review agents verify changes
- pending: Phase 5: Complete — Summarize what was built
```

**At each phase**: Call `update_plan(status: "in_progress")` when starting, `update_plan(status: "completed")` when done.

### 0.6 Plan Continuation Detection

Check if the feature description argument contains **"Plan is approved"**:

**If YES** — this is a post-plan-approval re-entry (context was cleared after plan approval):

1. Step 0 initialization is already complete (skills loaded, Serena active, tasks created)
2. **Verify environment**: re-derive `REPO_ROOT` from `git rev-parse --show-toplevel`.
   Check if currently inside a worktree: compare `git rev-parse --show-toplevel` against `git worktree list`. If in a worktree, set `WORKTREE_PATH` accordingly.
3. Mark Phases 1 and 2 complete:
   ```
   update_plan(Phase 1, status: "completed")
   update_plan(Phase 2, status: "completed")
   ```
4. **Proceed directly to Phase 3: Implementation** — the plan is already approved and available in the plan file.

**If NO** — this is a new feature request. Proceed to Phase 1.

## Task Classification

**Before starting**, classify the task to determine the appropriate workflow:

| Task Type | Examples | TDD Phase | Implementation |
|-----------|----------|-----------|----------------|
| **Code** | New features, bug fixes, refactoring, API changes | ✅ Required | Delegate to `rptc:tdd-agent` |
| **Non-Code** | Documentation, config, markdown, plugin updates | ⏭️ Skip | Main context executes directly |

**Classification rules**:
- **Code tasks**: Create/modify `.ts`, `.js`, `.py`, `.go`, `.rs`, `.java`, or other source files
- **Non-Code tasks**: Create/modify `.md`, `.json`, `.yaml`, `.toml`, config files, or purely documentation

**Result**: Set `task_type` to `code` or `non-code` for Phase 3 routing.

## Skills Usage Guide

**`rptc:tool-guide`** - Tool prioritization for Serena MCP and other MCP servers (MANDATORY LOAD):

| When | Apply To |
|------|----------|
| Step 0 (always loaded) | Infrastructure — activates Serena for code navigation throughout |
| All phases | Serena read ops (`find_symbol`, `search_for_pattern`) |

**Method**: Tool discovery activates Serena at session start (Step 0.1.2 Activate Serena); then prefer `find_symbol`, `get_symbols_overview`, `search_for_pattern` over native Grep/Glob for all code navigation.
**Timing**: Loaded first in Step 0. Applies across all phases wherever code navigation or symbol search is needed.

**`brainstorming`** - Structured dialogue for requirement clarification:

| When | Apply To |
|------|----------|
| Phase 2 (before architect agents) | Clarify unclear requirements with user |
| Throughout | Explore approaches with 2-3 options, validate incrementally |

**Method**: One question at a time via request_user_input when available, otherwise ask directly in chat, multiple choice preferred, YAGNI ruthlessly.
**Timing**: Main context uses this BEFORE delegating to architect agents.

**`writing-clearly-and-concisely`** - Apply Strunk's Elements of Style to all prose:

| When | Apply To |
|------|----------|
| Phase 2 | Plan descriptions, rationales, step explanations |
| Phase 5 | Summary output, implementation notes |
| Throughout | Commit messages, documentation updates, user-facing text |

**Key rules**: Active voice, positive form, definite language, omit needless words.

**`tdd-methodology`** - RED-GREEN-REFACTOR enforcement for main context code changes:

| When | Apply To |
|------|----------|
| Phase 3 (Route A or direct code changes) | Any code written in main context (not delegated to `rptc:tdd-agent`) |

**Method**: Surgical coding (search 3 similar patterns first), context discovery (check existing tests), strict RED-GREEN-REFACTOR cycle.
**Timing**: Main context applies this when handling code changes directly. Sub-agent `rptc:tdd-agent` has equivalent guidance built in.

**`rptc:frontend-design`** *(conditional)* - Distinctive, production-grade frontend interfaces:

| When | Apply To |
|------|----------|
| Phase 3 (when task involves frontend) | HTML, CSS, UI components, web pages, visual design |

**Method**: Bold aesthetic direction, distinctive typography, cohesive color themes, purposeful motion/animation. Avoids generic AI aesthetics.
**Timing**: Load in Step 0.1.1 only when the task involves frontend work. Additive creative layer on top of `frontend-guidelines.md` SOP (which always applies for engineering standards).

## Phase 2: Architecture

`update_plan(Phase 2, status: "in_progress")`

**Goal**: Design the implementation approach with user approval.

> 💡 **Tool Reminder**: Use Serena (`get_symbols_overview`, `search_for_pattern`) to verify architects' assumptions against the actual codebase.

**Actions**:

1. **Enter plan mode** using Codex planning context

2. **Clarify requirements using `brainstorming` skill** (BEFORE launching agents):
   - Use request_user_input when available, otherwise ask directly in chat to clarify unclear requirements ONE question at a time
   - Prefer multiple choice options when possible
   - Focus on: purpose, constraints, success criteria, scope boundaries
   - Continue until requirements are clear enough for planning

   **Skip if**: Requirements are already crystal clear from Phase 1 discovery.

3. **Launch 3 plan agents in parallel** with different perspectives:

```
Use `spawn_agent` with the RPTC `rptc:architect-agent` role when installed (launch all 3 in parallel):

[Prepend the Environment Context Block to each agent prompt]

Agent 1: "Design implementation for [feature]. Perspective: Minimal. Provide: files to modify, component design, data flow, build sequence. [If code task: include test strategy]"

Agent 2: "Design implementation for [feature]. Perspective: Clean. Provide: files to modify, component design, data flow, build sequence. [If code task: include test strategy]"

Agent 3: "Design implementation for [feature]. Perspective: Pragmatic. Provide: files to modify, component design, data flow, build sequence. [If code task: include test strategy]"
```

4. **Review all 3 approaches**, form an opinion on which fits best for this specific feature

5. **MANDATORY: Ask user to choose** via request_user_input when available, otherwise ask directly in chat (put recommended option first with "(Recommended)" suffix):

   **Skip asking ONLY if ALL of these are true:**
   - Single-file change with <20 lines
   - No architectural decisions involved
   - Only one approach is viable (others don't apply)

   **Otherwise, ALWAYS ask the user** - even if one option seems obviously better.

   **Before asking, present a brief summary of each approach:**

```markdown
## Architecture Options

### Minimal Approach
- **Files**: [list from agent 1]
- **Key idea**: [1-sentence summary]
- **Trade-off**: Fast, reuses existing code, may accumulate tech debt

### Clean Approach
- **Files**: [list from agent 2]
- **Key idea**: [1-sentence summary]
- **Trade-off**: Maintainable, elegant abstractions, takes longer

### Pragmatic Approach
- **Files**: [list from agent 3]
- **Key idea**: [1-sentence summary]
- **Trade-off**: Balanced, good enough without over-engineering
```

   **Then ask:**

```
Use request_user_input when available, otherwise ask directly in chat tool:

question: "Which architecture approach would you like to use for this feature?"
header: "Architecture"
options:
  - label: "[Best fit] (Recommended)"
    description: "[1-sentence why this fits best + file count]"
  - label: "[Second option]"
    description: "[1-sentence trade-off + file count]"
  - label: "[Third option]"
    description: "[1-sentence trade-off + file count]"
```

6. **Write selected plan to plan file** with:
   - **Step 0: RPTC Re-initialization (ALWAYS FIRST)** — instructs re-invocation of `/rptc:feat` with "Plan is approved, continue to implementation" to restore full RPTC context
   - Approach used (with rationale)
   - Implementation steps (ordered)
   - Files to create/modify
   - Test strategy per step (code tasks only)

7. **Verify plan includes Step 0** (re-invocation of `/rptc:feat`), then exit with user approval in chat to get user approval

**Plan file format** (flexible):

- Simple features: List steps directly
- Complex features: Overview + numbered implementation steps

`update_plan(Phase 2, status: "completed")`

### Route B: Code Tasks (TDD)

**When**: `task_type = code` (source files, tests, application logic)

**Goal**: Build with tests first, maintaining TDD discipline whether delegated or direct.

**CRITICAL - Test-First Ordering (NON-NEGOTIABLE)**:

Whether delegating to `rptc:tdd-agent` OR executing in main context:

1. Write/update ALL tests BEFORE modifying ANY production code
2. Run tests and confirm they fail BEFORE writing production code
3. Only after tests exist and fail may you edit production files

**FILE LOCKOUT RULE**: During RED phase, you may ONLY create or modify test files (`tests/`, `__tests__/`, `*.test.*`, `*.spec.*`). Any edit to a production/source file during RED phase is a TDD violation. STOP and revert if this happens.

#### Delegation Decision: Direct or Agent?

**Before batching**, decide how to execute based on plan complexity:

| Criteria | Execute Directly (Main Context) | Delegate to `rptc:tdd-agent` |
|----------|--------------------------------|----------------------|
| Plan steps | 1-2 steps | 3+ steps |
| Files affected | 1-2 files | 3+ files |
| Estimated lines | <50 lines of new/changed code | 50+ lines |
| Complexity | Straightforward, clear pattern | Complex logic, multi-component |

**If Direct**: Execute code changes in main context using TDD methodology.

```
Use/load the `rptc:tdd-methodology` skill.
```

**Test-First Gate (Direct Execution)**: Execute in strict order.

1. **Surgical Coding**: Search 3 similar patterns first
2. **Context Discovery**: Check existing tests, framework, naming conventions
3. **RED**: Write failing tests. Run them. Confirm they fail.

   **BLOCKING GATE — RED Phase Verification** (MANDATORY, cannot skip):

   Before ANY production file edit, verify via output:
   ```
   RED GATE CHECK:
   - Tests written: [list test files created/modified]
   - Tests failing: [X] tests fail as expected
   - Production files touched: NONE
   → PASS: Proceed to GREEN
   ```
   If production files were touched → STOP. Revert production changes. Complete RED first.

4. **GREEN**: Minimal code to pass (NOW you may edit production files)
5. **REFACTOR**: Improve while green
6. **VERIFY**: Run affected tests, check coverage

Then skip to step 8 (Update task status) below.

**If Delegate**: Use smart batching with `rptc:tdd-agent` (continue below).

#### Smart Batching (`rptc:tdd-agent` delegation)

Combines related steps into fewer `rptc:tdd-agent` calls, reducing overhead while maintaining TDD discipline.

**Actions**:

1. **Extract steps from plan** and analyze each step for:
   - Target files (create/modify)
   - Dependencies (detect using these rules):
     - **Explicit**: Step description contains "after step N" or "requires step N"
     - **Implicit write-read**: Step B reads/imports file that Step A creates or modifies
     - **Implicit shared write**: Both steps modify the same file → must be sequential
     - **Independent**: No shared files, no explicit ordering mentioned
   - Complexity and estimated lines:
     - Simple (1 file): ~30 lines, ~15 tests
     - Medium (1-2 files): ~60 lines, ~30 tests
     - Complex (3+ files): ~100 lines, ~50 tests

2. **Group steps into batches** using these criteria:
   - **File cohesion**: Steps targeting same/related files → batch together
   - **Sequential chain**: Step N+1 depends only on N → batch together
   - **Size threshold**: Combined estimated lines < 150 → batch together
   - **No blockers**: No user approval needed between steps

3. **Calculate test allocation per batch**:
   - Use complexity-based counts: simple (~15), medium (~30), complex (~50)
   - **Batch cap**: 100 tests maximum
   - If sum exceeds 100, distribute proportionally: `adjusted = (step_count / total) × 100`
   - Example: [50, 50, 15] over cap → [43, 43, 14] after proportional reduction

4. **Identify parallel batches**: Batches with no inter-dependencies can run simultaneously
   - Build dependency graph from step analysis (step 1)
   - Batches are independent if: no batch contains steps that depend on steps in other batch

5. **Create tasks per batch** (with dependencies for dependent batches):
   ```
   update_plan("Batch 1 [Steps 1-3]: User model + validation + tests")
   update_plan("Batch 2 [Steps 4-5]: UserService + tests")
   update_plan("Batch 3 [Step 6]: API endpoint")
   Note in Batch 3 step text: waits for Batch 2
   ```

6. **For each batch, invoke `rptc:tdd-agent`** using the `spawn_agent`:

```
Use `spawn_agent` with the RPTC `rptc:tdd-agent` role when installed:

[Prepend the Environment Context Block]

## Context
- Feature: [description]
- Batch: Steps [N, N+1, ...] - [batch summary]
- Previous batches completed: [list]

## Steps in This Batch

### Step N: [name]
- Files: [list]
- Tests to generate: [calculated count]
- Complexity: [simple|medium|complex]

### Step N+1: [name]
- Files: [list]
- Tests to generate: [calculated count]
- Complexity: [simple|medium|complex]

## Test Allocation
Generate tests for ALL steps in batch (~[total] tests):
- Allocate per step based on complexity scores above
- Cover: happy paths, edge cases, errors, integration

## TDD Cycle (per step in batch)
For each step in order:
1. RED: Write ALL tests for this step. Run them. Confirm they fail.
   FILE LOCKOUT: Only test files may be created/modified during RED.
   Output RED GATE CHECK before proceeding to GREEN.
2. GREEN: Implement minimal code to pass (NOW edit production files)
3. REFACTOR: Improve while green
Then move to next step in batch.
```

7. **Launch parallel batches** simultaneously when independent:
   - Identify batches with no inter-dependencies (from step 4)
   - Invoke ALL independent `spawn_agent`s in the same message (parallel execution)
   - Wait for all to complete before processing dependent batches
   - Example: Batch A and B independent → invoke both `spawn_agent(rptc:tdd-agent)` calls together

7b. **Verify batch compliance**: After each `rptc:tdd-agent` batch returns, check the exit verification block:
    - `Test-First Followed: YES` → mark batch complete
    - `Test-First Followed: NO` → flag as TDD violation, ask user whether to re-run or accept

8. **Update task status** as each batch completes (`update_plan(batch, status: "completed")`)
9. **Handle failures**: If batch fails after 3 attempts, ask user for guidance

`update_plan(Phase 3, status: "completed")`

**Example Batching**:
```
Plan steps:                          Batched execution:
1. Create User model      ─┐
2. Add validation         ├─► Batch A [1,2,3] → 1 agent ─┐
3. Write User tests       ─┘                             ├─ parallel
4. Create UserService     ─┬─► Batch B [4,5] → 1 agent ──┘
5. Write Service tests    ─┘
6. Add API endpoint       ───► Batch C [6] → 1 agent (waits for B)

Result: 6 steps → 3 agents (vs 6 agents), ~40% token reduction
```

## Phase 5: Complete

`update_plan(Phase 5, status: "in_progress")`

Mark remaining tasks complete. Output 1-2 sentences: what changed, ready for `/rptc:commit`.

`update_plan(Phase 5, status: "completed")`

## Error Handling

- **Discovery fails**: Ask user for more context
- **All plans miss requirements**: Re-run planning with additional constraints from user
- **TDD step fails 3x**: Pause, ask user for guidance
- **Quality verification finds critical issues**: Block completion, show findings
- **Phase 4 not executed**: INVALID STATE. Return to Phase 4 and execute it. Phase 5 cannot proceed without verification.
