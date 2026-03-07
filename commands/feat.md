---
description: Research → Plan → TDD → Verify in one seamless flow
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, EnterPlanMode, ExitPlanMode
---

# /rptc:feat

Complete feature development: Discovery → Architecture → Implementation → Quality Verification.

## Step 0: RPTC Workflow Initialization (MANDATORY - CANNOT SKIP)

**Before ANY other action, establish RPTC workflow context.**

### 0.1 Load Required Skills (ALL FIVE MANDATORY)

Load ALL five skills below. Each `Skill()` call is MANDATORY — do not skip any.

```
Skill(skill: "rptc:tool-guide")
Skill(skill: "rptc:brainstorming")
Skill(skill: "rptc:writing-clearly-and-concisely")
Skill(skill: "rptc:tdd-methodology")
Skill(skill: "rptc:agent-teams")
```

After loading, confirm all five loaded. If ANY skill fails to load, STOP and report the failure.

### 0.1.1 Conditional Skills (Load When Applicable)

**Frontend work** — If the task involves creating or modifying HTML, CSS, UI components, web pages, or frontend interfaces:

```
Skill(skill: "frontend-design:frontend-design")
```

> This is an external plugin skill (Anthropic's `frontend-design` plugin) that provides creative direction and distinctive aesthetics. If unavailable, skip silently — the RPTC `frontend-guidelines.md` SOP (loaded via the SOP Reference Chain) still applies for engineering standards. Both are complementary: the SOP ensures correctness (accessibility, performance, responsive), the skill ensures distinction (bold aesthetics, memorable design). Do NOT error or warn the user if the plugin is missing.

> **IMPORTANT**: If the project already has an established design system, style guide, or visual aesthetic, the skill's creative direction MUST work within those constraints. Research existing styles first (CSS variables, component library, brand guidelines) and extend them — do not override with a conflicting aesthetic. The skill adds polish and intentionality, not a new identity.

### 0.1.2 Activate Serena MCP (MANDATORY)

Serena tools are **deferred** in the main context — they require explicit loading before they can be called.

Call ToolSearch now to activate them:

```
ToolSearch(query: "serena")
```

Once loaded, Serena tools appear as `mcp__serena__*` or `mcp__plugin_serena_serena__*`. This activates both read tools (`find_symbol`, `get_symbols_overview`, `search_for_pattern`, etc.) and edit tools (`replace_symbol_body`, `insert_after_symbol`, etc.). Use them throughout this workflow — refer to the Tool Prioritization section for the full map of Serena vs. native tools.

If Serena is unavailable (not installed), skip silently and fall back to native Grep and Glob.

### 0.2 RPTC Workflow Understanding (INTERNALIZE)

You are executing the **RPTC (Research → Plan → TDD → Commit)** workflow.

**Core Philosophy:**
- Research before coding (understand before building)
- Plan with user approval (user is PM)
- Test-first development (tests define behavior)
- Quality gates before shipping (no shortcuts)

**Non-Negotiable Directives:**

| Directive | Meaning | Verification |
|-----------|---------|--------------|
| **Surgical Coding** | Find 3 similar patterns before creating new code | Search codebase first |
| **KISS/YAGNI** | Simplest solution; no abstractions until 3+ use cases | Rule of Three |
| **Test-First** | Write tests BEFORE implementation, ALWAYS | RED phase before GREEN |
| **Pattern Alignment** | Match existing codebase conventions | Study before implementing |
| **User Authority** | User is PM; approves all major decisions | Ask when uncertain |

**SOP Reference Chain (with Precedence):**

| Topic | Check First (User) | Fallback (RPTC) |
|-------|-------------------|-----------------|
| Architecture | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/architecture-patterns.md` |
| Testing | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/testing-guide.md` |
| Security | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/security-and-performance.md` |
| Progress Tracking | Project `sop/`, `~/.claude/global/` | TaskCreate/TaskUpdate with `addBlockedBy` (see Step 0.5) |
| Refactoring | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/post-tdd-refactoring.md` |
| Frontend | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/frontend-guidelines.md` |

**Precedence Rule**: If user specifies custom SOPs (in project CLAUDE.md, project `sop/` dir, or `~/.claude/global/`), use those for the matching topic. RPTC SOPs are the fallback default.

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

Create the workflow phases as tasks with a dependency chain. Each phase is blocked by the previous one — completing a phase automatically unblocks the next.

```
TaskCreate("Phase 1: Discovery", description: "Understand what to build and existing patterns")
TaskCreate("Phase 2: Architecture", description: "Design implementation approach with user approval")
TaskCreate("Phase 3: Implementation", description: "Execute plan using appropriate method")
TaskCreate("Phase 4: Quality Verification", description: "Review agents verify changes")
TaskCreate("Phase 5: Complete", description: "Summarize what was built")

TaskUpdate(Phase 2, addBlockedBy: [Phase 1])
TaskUpdate(Phase 3, addBlockedBy: [Phase 2])
TaskUpdate(Phase 4, addBlockedBy: [Phase 3])
TaskUpdate(Phase 5, addBlockedBy: [Phase 4])
```

**At each phase**: Call `TaskUpdate(status: "in_progress")` when starting, `TaskUpdate(status: "completed")` when done.

---

## Arguments

`/rptc:feat <feature-description>`

**Example**: `/rptc:feat "Add user authentication with OAuth2"`

---

## Task Classification

**Before starting**, classify the task to determine the appropriate workflow:

| Task Type | Examples | TDD Phase | Implementation |
|-----------|----------|-----------|----------------|
| **Code** | New features, bug fixes, refactoring, API changes | ✅ Required | Delegate to tdd-agent |
| **Non-Code** | Documentation, config, markdown, plugin updates | ⏭️ Skip | Main context executes directly |

**Classification rules**:
- **Code tasks**: Create/modify `.ts`, `.js`, `.py`, `.go`, `.rs`, `.java`, or other source files
- **Non-Code tasks**: Create/modify `.md`, `.json`, `.yaml`, `.toml`, config files, or purely documentation

**Result**: Set `task_type` to `code` or `non-code` for Phase 3 routing.

---

## Tool Prioritization

**Serena MCP** (prefer over native tools — activated via ToolSearch in Step 0.1.2):

Serena tools may appear as `mcp__serena__*` or `mcp__plugin_serena_serena__*` — use whichever is available.

**Read operations** (use instead of native Grep/Glob/Read for code):

| Task | Prefer Serena | Over Native |
|------|---------------|-------------|
| Find functions/classes | `get_symbols_overview` | Grep |
| Locate specific code | `find_symbol` | Glob |
| Find usages/references | `find_referencing_symbols` | Grep |
| Regex search | `search_for_pattern` | Grep |
| List directory | `list_dir` | LS |
| Reflect on progress | `think_about_collected_information` | — |

**Edit operations** (use instead of Edit tool for code modifications):

| Task | Prefer Serena | Over Native |
|------|---------------|-------------|
| Replace function/method body | `replace_symbol_body` | Edit |
| Insert code after a symbol | `insert_after_symbol` | Edit |
| Insert code before a symbol | `insert_before_symbol` | Edit |
| Rename a symbol everywhere | `rename_symbol` | Edit |
| Reflect on task adherence | `think_about_task_adherence` | — |

---

## Skills Usage Guide

**`rptc:tool-guide`** - Tool prioritization for Serena MCP and other MCP servers (MANDATORY LOAD):

| When | Apply To |
|------|----------|
| Step 0 (always loaded) | Infrastructure — activates Serena for code navigation throughout |
| All phases | Serena read ops (`find_symbol`, `search_for_pattern`) |

**Method**: ToolSearch activates Serena at session start (Step 0.1.2); then prefer `find_symbol`, `get_symbols_overview`, `search_for_pattern` over native Grep/Glob for all code navigation.
**Timing**: Loaded first in Step 0. Applies across all phases wherever code navigation or symbol search is needed.

**`brainstorming`** - Structured dialogue for requirement clarification:

| When | Apply To |
|------|----------|
| Phase 2 (before architect agents) | Clarify unclear requirements with user |
| Throughout | Explore approaches with 2-3 options, validate incrementally |

**Method**: One question at a time via AskUserQuestion, multiple choice preferred, YAGNI ruthlessly.
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
| Phase 3 (Route A or direct code changes) | Any code written in main context (not delegated to tdd-agent) |

**Method**: Surgical coding (search 3 similar patterns first), context discovery (check existing tests), strict RED-GREEN-REFACTOR cycle.
**Timing**: Main context applies this when handling code changes directly. Sub-agent `rptc:tdd-agent` has equivalent guidance built in.

**`frontend-design:frontend-design`** *(conditional)* - Distinctive, production-grade frontend interfaces:

| When | Apply To |
|------|----------|
| Phase 3 (when task involves frontend) | HTML, CSS, UI components, web pages, visual design |

**Method**: Bold aesthetic direction, distinctive typography, cohesive color themes, purposeful motion/animation. Avoids generic AI aesthetics.
**Timing**: Load in Step 0.1.1 only when the task involves frontend work. Additive creative layer on top of `frontend-guidelines.md` SOP (which always applies for engineering standards).

**`rptc:agent-teams`** - Parallel execution via Agent Teams (MANDATORY LOAD):

| When | Apply To |
|------|----------|
| Step 0 (always loaded) | Infrastructure — required for Teams Analysis after Phase 1 |
| Phase 1 (after discovery) | Batch features, parallel fixes, user-requested teams |

**Method**: Analyzes work for teams suitability, determines autonomy level (A/B/C), builds spawn prompts with RPTC enforcement.
**Timing**: ALWAYS loaded in Step 0. Runs Teams Analysis at end of Phase 1. Routes to teams mode or continues standard RPTC. Must be loaded even if teams mode does not activate — the analysis itself requires it.

---

## Phase 1: Discovery

`TaskUpdate(Phase 1, status: "in_progress")`

**Goal**: Understand what to build and existing patterns.

> 💡 **Tool Reminder**: Use Serena for code exploration.

**Actions**:

0. **Check for RPTC configuration** in project's CLAUDE.md:
   - Look for `<!-- RPTC-START` marker in local CLAUDE.md
   - If NOT found: Suggest user run `/rptc:config` for best experience
   - If found but outdated: Suggest user run `/rptc:config` to sync with current plugin version

1. **Classify task type** (see Task Classification above)
2. **Create initial todo list** with phases based on task type:
   - Code tasks: Discovery, Architecture, TDD Implementation, Quality Verification, Complete
   - Non-Code tasks: Discovery, Architecture, Implementation, Quality Verification, Complete
3. **If codebase exploration needed**, launch 2-3 research agents in parallel (NOT the built-in Explore agent):

```
IMPORTANT: Use subagent_type="rptc:research-agent", NOT "Explore"

Use Task tool with subagent_type="rptc:research-agent" (launch all 3 in parallel):

Agent 1 prompt: "Find similar features and existing patterns for [feature].
Use code-explorer methodology Phase 1 (Feature Discovery): entry points, core files, boundaries.
Return: files implementing similar functionality, patterns used."

Agent 2 prompt: "Analyze architecture and abstractions for [feature].
Use code-explorer methodology Phase 3 (Architecture Analysis): layers, patterns, cross-cutting concerns.
Return: architectural layers, design patterns, component dependencies."

Agent 3 prompt: "Map integration points and dependencies for [feature].
Use code-explorer methodology Phase 2 (Code Flow Tracing): call chains, data transformations, side effects.
Return: external dependencies, internal dependencies, API boundaries."
```

4. **If web research needed**, use `rptc:research-agent` with Mode B (20+ sources, cross-verification)
5. **If hybrid research needed** (codebase + best practices), use `rptc:research-agent` with Mode C
6. **If unclear about requirements**, ask user for clarification
7. **Summarize findings**: Key patterns, files to modify, dependencies, gap analysis (if hybrid)

### Teams Analysis

Run the `agent-teams` skill's Teams Analysis. It evaluates three signals:
1. Multiple independent work streams detected
2. Cross-agent debate would improve outcomes
3. User explicitly requested teams

**If teams mode activates**: The skill takes over orchestration. Do NOT continue
to Phase 2 — the skill handles the remaining workflow.

**If teams mode does NOT activate**: Continue to Branch Strategy, then Phase 2.

### Branch Strategy

**Now that the scope is clear**, ask the user how to organize this work.

**Choose recommendation based on Phase 1 findings:**
- Recommend **New worktree** when: multi-file feature, >3 files to modify, long-running work, or risky changes the user may want to abandon
- Recommend **Current branch** when: small change, single-file fix, quick task, or already on a feature branch

Put your recommended option first and append "(Recommended)" to its label.

**Before asking**, prepare the option labels:

1. **Get current branch name**: `git branch --show-current` → e.g. `main`
2. **Generate worktree branch name** from the feature description:
   - Lowercase, replace spaces with hyphens, strip special characters
   - Prefix with `feature/`
   - Example: `"Add user auth"` → `feature/add-user-auth`

```
Use AskUserQuestion:
question: "How should this feature be organized?"
header: "Branch"
options:
  - label: "<recommended-option> (Recommended)"
    description: "<description>"
  - label: "<other-option>"
    description: "<description>"
```

Example — small single-file change on a feature branch:
```
  - label: "Current branch [feature/auth] (Recommended)"
  - label: "New worktree [feature/add-user-auth]"
```

Example — large multi-file feature on main:
```
  - label: "New worktree [feature/add-user-auth] (Recommended)"
  - label: "Current branch [main]"
```

**If "New worktree" selected:**

1. **Compute absolute worktree path** (do NOT use relative paths):
   ```bash
   # Get the repo root as an absolute path — no ".." segments
   REPO_ROOT=$(git rev-parse --show-toplevel)
   PARENT_DIR=$(dirname "$REPO_ROOT")
   PROJECT_DIR=$(basename "$REPO_ROOT")
   WORKTREE_PATH="${PARENT_DIR}/${PROJECT_DIR}-<branch-name>"
   ```
   Store `WORKTREE_PATH` — you will reference it throughout this session.

2. **Create worktree** using the absolute path:
   ```bash
   git worktree add -b <branch-name> "$WORKTREE_PATH" HEAD
   ```

3. **Activate worktree** — change into the new worktree directory:
   ```bash
   cd "$WORKTREE_PATH"
   ```

4. **Verify activation** — confirm the worktree is the working directory:
   ```bash
   git rev-parse --show-toplevel
   ```
   The output MUST match `WORKTREE_PATH`. If it does not, STOP and fix before continuing.

5. **Confirm to user**:
   ```
   Worktree created and activated at <WORKTREE_PATH>
   Branch: <branch-name>
   Verified: working directory is inside worktree.
   All subsequent work proceeds here.
   ```

6. **Set worktree active flag**: Remember that `WORKTREE_PATH` is set. ALL agent delegation
   prompts in Phases 2-4 MUST include the Worktree Context Block (defined below).

**If "Current branch" selected:** `WORKTREE_PATH` is not set. Continue to Phase 2.

#### Worktree Context Block

When `WORKTREE_PATH` is set, prepend this block to EVERY agent prompt in Phases 2-4 (architect, tdd, code-review, security, docs):

```
WORKTREE: This project is checked out in a git worktree.
Working directory: <WORKTREE_PATH>
You MUST cd to this path before doing ANY work:
  cd "<WORKTREE_PATH>"
All file paths are relative to this worktree root, NOT the original repo.
```

When `WORKTREE_PATH` is NOT set, omit this block entirely.

`TaskUpdate(Phase 1, status: "completed")`

---

## Phase 2: Architecture

`TaskUpdate(Phase 2, status: "in_progress")`

**Goal**: Design the implementation approach with user approval.

> 💡 **Tool Reminder**: Use Serena (`get_symbols_overview`, `search_for_pattern`) to verify architects' assumptions against the actual codebase.

**Actions**:

1. **Enter plan mode** using EnterPlanMode tool

2. **Clarify requirements using `brainstorming` skill** (BEFORE launching agents):
   - Use AskUserQuestion to clarify unclear requirements ONE question at a time
   - Prefer multiple choice options when possible
   - Focus on: purpose, constraints, success criteria, scope boundaries
   - Continue until requirements are clear enough for planning

   **Skip if**: Requirements are already crystal clear from Phase 1 discovery.

3. **Launch 3 plan agents in parallel** with different perspectives:

```
Use Task tool with subagent_type="rptc:architect-agent" (launch all 3 in parallel):

[If WORKTREE_PATH is set, prepend the Worktree Context Block to each agent prompt]

Agent 1: "Design implementation for [feature]. Perspective: Minimal. Provide: files to modify, component design, data flow, build sequence. [If code task: include test strategy]"

Agent 2: "Design implementation for [feature]. Perspective: Clean. Provide: files to modify, component design, data flow, build sequence. [If code task: include test strategy]"

Agent 3: "Design implementation for [feature]. Perspective: Pragmatic. Provide: files to modify, component design, data flow, build sequence. [If code task: include test strategy]"
```

3. **Review all 3 approaches**, form an opinion on which fits best for this specific feature

4. **MANDATORY: Ask user to choose** via AskUserQuestion (put recommended option first with "(Recommended)" suffix):

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
Use AskUserQuestion tool:

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

5. **Write selected plan to plan file** with:
   - **Step 0: RPTC Re-initialization (ALWAYS FIRST)** — Serena activation, skill loading, task list rebuild for Phase 3/4/5 (use plan-overview template for exact format)
   - Approach used (with rationale)
   - Implementation steps (ordered)
   - Files to create/modify
   - Test strategy per step (code tasks only)

6. **Exit plan mode** using ExitPlanMode to get user approval

**Plan file format** (flexible):

- Simple features: List steps directly
- Complex features: Overview + numbered implementation steps

`TaskUpdate(Phase 2, status: "completed")`

---

## Phase 3: Implementation

`TaskUpdate(Phase 3, status: "in_progress")`

**Goal**: Execute the plan using the appropriate method for the task type.

> 💡 **Tool Reminder**: Use Serena for both navigation (`find_symbol`, `get_symbols_overview`) and edits (`replace_symbol_body`, `insert_after_symbol`) — prefer over native Grep/Edit.

### Route A: Non-Code Tasks (Direct Execution)

**When**: `task_type = non-code` (documentation, config, markdown, plugin updates)

**Actions**:

1. **Execute steps directly** in main context (no sub-agent delegation)
2. **For each step**:
   - Read target files
   - Make changes using Edit/Write tools
   - Verify changes are correct
3. **Update task status** as each step completes

`TaskUpdate(Phase 3, status: "completed")`

---

### Route B: Code Tasks (TDD)

**When**: `task_type = code` (source files, tests, application logic)

**Goal**: Build with tests first, maintaining TDD discipline whether delegated or direct.

**CRITICAL - Test-First Ordering (NON-NEGOTIABLE)**:

Whether delegating to tdd-agent OR executing in main context:

1. Write/update ALL tests BEFORE modifying ANY production code
2. Run tests and confirm they fail BEFORE writing production code
3. Only after tests exist and fail may you edit production files

**FILE LOCKOUT RULE**: During RED phase, you may ONLY create or modify test files (`tests/`, `__tests__/`, `*.test.*`, `*.spec.*`). Any edit to a production/source file during RED phase is a TDD violation. STOP and revert if this happens.

#### Delegation Decision: Direct or Agent?

**Before batching**, decide how to execute based on plan complexity:

| Criteria | Execute Directly (Main Context) | Delegate to tdd-agent |
|----------|--------------------------------|----------------------|
| Plan steps | 1-2 steps | 3+ steps |
| Files affected | 1-2 files | 3+ files |
| Estimated lines | <50 lines of new/changed code | 50+ lines |
| Complexity | Straightforward, clear pattern | Complex logic, multi-component |

**If Direct**: Execute code changes in main context using TDD methodology.

```
Skill(skill: "rptc:tdd-methodology")
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

**If Delegate**: Use smart batching with tdd-agent (continue below).

#### Smart Batching (tdd-agent delegation)

Combines related steps into fewer tdd-agent calls, reducing overhead while maintaining TDD discipline.

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
   TaskCreate("Batch 1 [Steps 1-3]: User model + validation + tests")
   TaskCreate("Batch 2 [Steps 4-5]: UserService + tests")
   TaskCreate("Batch 3 [Step 6]: API endpoint")
   TaskUpdate(Batch 3, addBlockedBy: [Batch 2])  // Batch 3 waits for Batch 2
   ```

6. **For each batch, invoke tdd-agent** using the Task tool:

```
Use Task tool with subagent_type="rptc:tdd-agent":

[If WORKTREE_PATH is set, prepend the Worktree Context Block]

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
   - Invoke ALL independent Task tools in the same message (parallel execution)
   - Wait for all to complete before processing dependent batches
   - Example: Batch A and B independent → invoke both `Task(rptc:tdd-agent)` calls together

7b. **Verify batch compliance**: After each tdd-agent batch returns, check the exit verification block:
    - `Test-First Followed: YES` → mark batch complete
    - `Test-First Followed: NO` → flag as TDD violation, ask user whether to re-run or accept

8. **Update task status** as each batch completes (`TaskUpdate(batch, status: "completed")`)
9. **Handle failures**: If batch fails after 3 attempts, ask user for guidance

`TaskUpdate(Phase 3, status: "completed")`

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

---

## Phase 4: Quality Verification

`TaskUpdate(Phase 4, status: "in_progress")`

**Goal**: Verify changes and report findings for main context to address.

> 💡 **Tool Reminder**: Use Serena (`find_referencing_symbols`, `search_for_pattern`) when applying auto-fixes from verification findings.

**Mode**: Report-only. Verification agents DO NOT make changes—they report findings. Main context handles all fixes.

**Actions**:

1. **Collect files modified** during Phase 3 for verification

2. **Determine verification agent mode** (one-time project configuration):

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

3. **Select agents based on mode**:

   **Mode: `all`** — Launch all 3 agents (skip to step 4)

   **Mode: `automatic`** — Select based on changes:

   | Change Type | code-review | security | docs |
   |-------------|:-----------:|:--------:|:----:|
   | Source code in `auth/`, `api/`, `security/`, `middleware/` paths | ✅ | ✅ | Check keywords |
   | Source code (other paths) | ✅ | Check keywords | Check keywords |
   | Source code with `export` statements | ✅ | Check keywords | ✅ |
   | Test files only | ✅ | ❌ | ❌ |
   | Dependencies changed (`package.json`, `requirements.txt`, etc.) | ❌ | ✅ | ❌ |
   | Docs/markdown only | ❌ | ❌ | ✅ |
   | Config files (non-sensitive) | ❌ | ❌ | ✅ |

   **Keyword detection** (scan git diff):
   - Security keywords: `password`, `token`, `secret`, `auth`, `session`, `crypto`, `hash`, `sql`, `exec`, `eval` → include security-agent
   - API keywords: `export`, `interface`, `endpoint`, `route`, `version`, `deprecated` → include docs-agent

   **Default**: If uncertain, include the agent

   **Mode: `minimal`** — Only launch when strongly indicated:
   - code-review: **ALWAYS** (minimum floor — at least one verification agent must launch)
   - security: Only if auth/api paths OR security keywords found
   - docs: Only if doc files changed OR `export` keyword found

4. **Launch selected verification agents** — Make Task tool calls for each selected agent:

   **AGENT NAMESPACE LOCKOUT (Phase 4):**
   - ✅ CORRECT: `subagent_type="rptc:code-review-agent"`
   - ❌ WRONG: `subagent_type="feature-dev:code-reviewer"` — different plugin, not RPTC
   - ❌ WRONG: `subagent_type="code-review:code-review"` — different plugin, not RPTC
   - The `rptc:` prefix is required for ALL verification agents. No exceptions.

   **Code Review Agent** (if selected):
   ```
   Use Task tool with subagent_type="rptc:code-review-agent":
   ⚠️ WRONG agents: "feature-dev:code-reviewer", "code-review:code-review" — DO NOT USE

   [If WORKTREE_PATH is set, prepend the Worktree Context Block]

   prompt: "Review code quality for these files: [list files].
   Focus: complexity, KISS/YAGNI violations, dead code, readability.
   REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."
   ```

   **Security Agent** (if selected):
   ```
   Use Task tool with subagent_type="rptc:security-agent":

   [If WORKTREE_PATH is set, prepend the Worktree Context Block]

   prompt: "Security review for these files: [list files].
   Focus: input validation, auth checks, injection vulnerabilities, data exposure.
   REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."
   ```

   **Documentation Agent** (if selected):
   ```
   Use Task tool with subagent_type="rptc:docs-agent":

   [If WORKTREE_PATH is set, prepend the Worktree Context Block]

   prompt: "Review documentation impact for these files: [list files].
   Focus: README updates, API doc changes, inline comment accuracy, breaking changes.
   REPORT ONLY - do not make changes. Output: documentation updates needed (≥80 only)."
   ```

5. **Consolidate findings** from launched agents:
   - Categorize: bugs, security, style, structural, documentation
   - Filter to high-confidence issues only (≥80)

6. **Create tasks for findings** (auto-fix by default):
   ```
   TaskCreate("[Category] Finding 1: description (file:line)")
   TaskCreate("[Category] Finding 2: description (file:line)")
   ...
   ```

7. **Auto-fix findings** (no user approval needed for most issues):

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
   - Work through finding tasks sequentially
   - For auto-fix items: Apply fix, `TaskUpdate(finding, status: "completed")`
   - For ask-first items: Use AskUserQuestion with fix proposal, then apply or skip
   - Mark all finding tasks complete as addressed

8. **User Acknowledgment**:

   Present review results to the user. This is a tool-enforced gate — you MUST call AskUserQuestion here.

   ```
   Use AskUserQuestion:
   question: "Phase 4 verification complete. [N] findings addressed. Proceed to completion?"
   header: "Verification Gate"
   options:
     - label: "Proceed to Phase 5"
       description: "All verification findings addressed, ready to wrap up"
     - label: "Re-verify with /rptc:verify"
       description: "Run the standalone verification command to check current state"
   ```

   If user selects "Re-verify" → invoke `/rptc:verify` (uses the standalone verify workflow with agent selection and full re-scan).

`TaskUpdate(Phase 4, status: "completed")`

---

## Phase 5: Complete

`TaskUpdate(Phase 5, status: "in_progress")`

**Goal**: Summarize what was built.

**Actions**:

1. **Mark all remaining tasks complete**
2. **Summary output**:
   - Files created/modified
   - Tests added
   - Key implementation decisions
   - Any remaining todos or known issues

---

## Agent Delegation Reference

### Research Agents with Code-Explorer Methodology (Phase 1)

```
IMPORTANT: Use "rptc:research-agent", NOT "Explore"

Launch 3 Task tools in parallel with subagent_type="rptc:research-agent":

Agent 1 (Feature Discovery): "Find similar features for [topic]. Entry points, core files, boundaries."
Agent 2 (Architecture Analysis): "Analyze architecture for [topic]. Layers, patterns, cross-cutting concerns."
Agent 3 (Code Flow Tracing): "Map integration points for [topic]. Call chains, data flow, dependencies."
```

### Research Agent (Phase 1 - Web/Hybrid)

```
Use Task tool with subagent_type="rptc:research-agent":
prompt: "Research [topic]. Mode: [A=codebase|B=web|C=hybrid]. Return: findings with confidence."
```

### Planner Agent (Phase 2)

```
Use Task tool with subagent_type="rptc:architect-agent" (launch all 3 in parallel):

[If WORKTREE_PATH is set, prepend the Worktree Context Block]

Agent 1: "Design implementation for [feature]. Perspective: Minimal. ..."
Agent 2: "Design implementation for [feature]. Perspective: Clean. ..."
Agent 3: "Design implementation for [feature]. Perspective: Pragmatic. ..."

After all complete: MUST ask user to choose via AskUserQuestion (skip only for trivial single-file changes).
```

### TDD Executor Agent (Phase 3 - Batch Mode)

```
Use Task tool with subagent_type="rptc:tdd-agent":

[If WORKTREE_PATH is set, prepend the Worktree Context Block]

## Context
- Feature: [description]
- Batch: Steps [N, N+1, ...] - [summary]

## Steps in This Batch
### Step N: [name]
- Files: [list], Tests: [count], Complexity: [simple|medium|complex]

### Step N+1: [name]
- Files: [list], Tests: [count], Complexity: [simple|medium|complex]

## TDD Cycle
For each step in order:
1. RED: Write ALL tests. FILE LOCKOUT — only test files. Output RED GATE CHECK.
2. GREEN: Minimal code to pass (NOW edit production files).
3. REFACTOR: Improve while green.
Then next step.
```

### Verification Agents (Phase 4) - Semantic Selection

**AGENT NAMESPACE LOCKOUT:**
- ✅ CORRECT: `subagent_type="rptc:code-review-agent"`
- ❌ WRONG: `subagent_type="feature-dev:code-reviewer"` — different plugin, not RPTC
- ❌ WRONG: `subagent_type="code-review:code-review"` — different plugin, not RPTC

**Mode**: Report-only. Agents report findings; main context handles fixes via TaskCreate/TaskUpdate.

**Selection based on `verification-agent-mode` in project CLAUDE.md:**
- `all`: Launch all 3 agents
- `automatic`: Select based on file types/keywords (default if no CLAUDE.md)
- `minimal`: code-review always launches; others when strongly indicated

**[If WORKTREE_PATH is set, prepend the Worktree Context Block to each agent prompt]**

**Agents (use these exact `subagent_type` values):**
1. `rptc:code-review-agent`: Code quality, complexity, KISS/YAGNI
2. `rptc:security-agent`: Input validation, auth, injection, data exposure
3. `rptc:docs-agent`: README, API docs, inline comments, breaking changes

**Quick reference for `automatic` mode:**
- Source code changed → code-review
- Auth/api/security paths OR security keywords → security
- Doc files OR export keywords → docs
- Test files only → code-review only

---

## Key Principles

1. **Single approval point**: ExitPlanMode after Architecture phase
2. **Ask when uncertain**: Use AskUserQuestion only when genuinely unclear
3. **Smart parallelism**: Parallelize independent steps, sequence dependent ones
4. **Task-appropriate workflow**: TDD for code, direct execution for non-code
5. **Auto-fix by default**: Fix Tier 2-4 issues automatically; ask only for Tier 1 or major changes
6. **Confidence filtering**: Only surface issues ≥80 confidence
7. **Goal+Actions format**: Trust agents to handle details

---

## Differences from Legacy Commands

| Aspect          | Legacy (/plan + /tdd) | /feat            |
| --------------- | --------------------- | ---------------- |
| Commands        | 2 separate            | 1 unified        |
| Config loading  | 80 lines              | 0                |
| Plan formats    | 5 modes               | Native only      |
| Approval gates  | 4+                    | 1 (ExitPlanMode) |
| Quality verification | Sequential            | Parallel         |
| Lines of code   | 1800+                 | ~200             |

---

## Error Handling

- **Discovery fails**: Ask user for more context
- **All plans miss requirements**: Re-run planning with additional constraints from user
- **TDD step fails 3x**: Pause, ask user for guidance
- **Quality verification finds critical issues**: Block completion, show findings
- **Phase 4 not executed**: INVALID STATE. Return to Phase 4 and execute it. Phase 5 cannot proceed without verification.
