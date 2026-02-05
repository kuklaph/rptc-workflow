---
description: Research → Plan → TDD → Review in one seamless flow
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TodoWrite, AskUserQuestion, EnterPlanMode, ExitPlanMode
---

# /rptc:feat

Complete feature development: Discovery → Architecture → Implementation → Quality Review.

## Step 0: RPTC Workflow Initialization (MANDATORY - CANNOT SKIP)

**Before ANY other action, establish RPTC workflow context.**

### 0.1 Load Required Skills

```
Skill(skill: "rptc:brainstorming")
Skill(skill: "rptc:writing-clearly-and-concisely")
Skill(skill: "rptc:tdd-methodology")
```

**Wait for skills to load before proceeding.**

### 0.1.1 Conditional Skills (Load When Applicable)

**Frontend work** — If the task involves creating or modifying HTML, CSS, UI components, web pages, or frontend interfaces:

```
Skill(skill: "frontend-design:frontend-design")
```

> This is an external plugin skill (Anthropic's `frontend-design` plugin) that provides creative direction and distinctive aesthetics. If unavailable, skip silently — the RPTC `frontend-guidelines.md` SOP (loaded via the SOP Reference Chain) still applies for engineering standards. Both are complementary: the SOP ensures correctness (accessibility, performance, responsive), the skill ensures distinction (bold aesthetics, memorable design). Do NOT error or warn the user if the plugin is missing.

> **IMPORTANT**: If the project already has an established design system, style guide, or visual aesthetic, the skill's creative direction MUST work within those constraints. Research existing styles first (CSS variables, component library, brand guidelines) and extend them — do not override with a conflicting aesthetic. The skill adds polish and intentionality, not a new identity.

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
| Progress Tracking | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/todowrite-guide.md` |
| Refactoring | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/post-tdd-refactoring.md` |
| Frontend | Project `sop/`, `~/.claude/global/` | `${CLAUDE_PLUGIN_ROOT}/sop/frontend-guidelines.md` |

**Precedence Rule**: If user specifies custom SOPs (in project CLAUDE.md, project `sop/` dir, or `~/.claude/global/`), use those for the matching topic. RPTC SOPs are the fallback default.

### 0.3 Phase Structure Awareness

This workflow has **5 mandatory phases**. You MUST NOT skip phases.

| Phase | Name | Key Deliverable | Blocking? |
|-------|------|-----------------|-----------|
| 1 | Discovery | Understanding of what to build | No |
| 2 | Architecture | User-approved implementation plan | No |
| 3 | Implementation | Working code with tests | No |
| 4 | Quality Review | All findings addressed | **YES** |
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
| **Always use** | Multi-step analysis, architecture decisions, debugging, planning |
| **Skip only for** | Single-line fixes, typo corrections, trivial config changes |

**Default behavior**: When in doubt, use Sequential Thinking. It improves reasoning quality significantly.

---

## Skills Usage Guide

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

---

## Phase 1: Discovery

**Goal**: Understand what to build and existing patterns.

> 💡 **Tool Reminder**: Use Sequential Thinking for feature analysis. Use Serena for code exploration.

**Actions**:

0. **Check for RPTC configuration** in project's CLAUDE.md:
   - Look for `<!-- RPTC-START` marker in local CLAUDE.md
   - If NOT found: Suggest user run `/rptc:config` for best experience
   - If found but outdated: Suggest user run `/rptc:config` to sync with current plugin version

1. **Classify task type** (see Task Classification above)
2. **Create initial todo list** with phases based on task type:
   - Code tasks: Discovery, Architecture, TDD Implementation, Quality Review, Complete
   - Non-Code tasks: Discovery, Architecture, Implementation, Quality Review, Complete
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

---

## Phase 2: Architecture

**Goal**: Design the implementation approach with user approval.

> 💡 **Tool Reminder**: Use Sequential Thinking when reviewing/comparing agent outputs.

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
   - Approach used (with rationale)
   - Implementation steps (ordered)
   - Files to create/modify
   - Test strategy per step (code tasks only)

6. **Exit plan mode** using ExitPlanMode to get user approval

**Plan file format** (flexible):

- Simple features: List steps directly
- Complex features: Overview + numbered implementation steps

---

## Phase 3: Implementation

**Goal**: Execute the plan using the appropriate method for the task type.

> 💡 **Tool Reminder**: Use Sequential Thinking before each implementation step. Use Serena for code navigation.

### Route A: Non-Code Tasks (Direct Execution)

**When**: `task_type = non-code` (documentation, config, markdown, plugin updates)

**Actions**:

1. **Use Sequential Thinking** to plan each step before executing
2. **Execute steps directly** in main context (no sub-agent delegation)
2. **For each step**:
   - Read target files
   - Make changes using Edit/Write tools
   - Verify changes are correct
3. **Update TodoWrite** as each step completes
4. **Execute Phase 4** (Quality Review) — required for all task types

---

### Route B: Code Tasks (TDD with Smart Batching)

**When**: `task_type = code` (source files, tests, application logic)

**Goal**: Build with tests first, using intelligent step batching for efficiency.

**CRITICAL - Test-First Ordering**: Whether delegating to tdd-agent OR executing in main context, ALWAYS write/update tests BEFORE modifying production code. This applies to new tests, updated existing tests, and regression tests. Never change production code first.

**Smart Batching**: Combines related steps into fewer tdd-agent calls, reducing overhead while maintaining TDD discipline.

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

5. **Create TodoWrite** with batches (not individual steps):
   ```
   Batch 1 [Steps 1-3]: User model + validation + tests
   Batch 2 [Steps 4-5]: UserService + tests (parallel with Batch 1 if independent)
   Batch 3 [Step 6]: API endpoint (waits for Batch 2)
   ```

6. **For each batch, invoke tdd-agent** using the Task tool:

```
Use Task tool with subagent_type="rptc:tdd-agent":

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

## Test-Driven Generation
Generate tests for ALL steps in batch (~[total] tests):
- Allocate per step based on complexity scores above
- Cover: happy paths, edge cases, errors, integration

## TDD Cycle (per step in batch)
For each step in order:
1. RED: Write tests for this step
2. GREEN: Implement minimal code
3. REFACTOR: Improve while green
Then move to next step in batch.
```

7. **Launch parallel batches** simultaneously when independent:
   - Identify batches with no inter-dependencies (from step 4)
   - Invoke ALL independent Task tools in the same message (parallel execution)
   - Wait for all to complete before processing dependent batches
   - Example: Batch A and B independent → invoke both `Task(rptc:tdd-agent)` calls together

8. **Update TodoWrite** as each batch completes
9. **Handle failures**: If batch fails after 3 attempts, ask user for guidance
10. **MANDATORY**: Add TodoWrite item "Quality Review" with status "pending" (if not exists)
11. **Transition to Phase 4** — MUST execute before Phase 5

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

## Phase 4: Quality Review (MANDATORY - BLOCKING GATE)

**Goal**: Review changes and report findings for main context to address.

**Mode**: Report-only. Review agents DO NOT make changes—they report findings. Main context handles all fixes.

**CRITICAL**: This phase MUST execute. Phase 5 CANNOT begin until this phase completes.

**Actions**:

0. **Update TodoWrite**: Mark "Quality Review" as in_progress

1. **Collect files modified** during Phase 3 for review

2. **Determine review agent mode** (one-time project configuration):

   a. **Check if project CLAUDE.md exists** (in project root)

   b. **If CLAUDE.md exists**, look for `review-agent-mode:` setting:
      - If found: Use that mode (`automatic`, `all`, or `minimal`)
      - If not found: Ask user via AskUserQuestion (one-time setup):
        ```
        Use AskUserQuestion:
        question: "How should review agents be selected for this project? (saved to CLAUDE.md)"
        header: "Review Mode"
        options:
          - label: "Automatic (Recommended)"
            description: "Smart selection based on file types and change patterns"
          - label: "All Agents"
            description: "Always launch all 3 review agents"
          - label: "Minimal"
            description: "Only launch agents when strongly indicated"
        ```
        Then append to CLAUDE.md:
        ```markdown
        ## RPTC Review Configuration
        review-agent-mode: [selected mode]
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
   - code-review: Only if >50 lines of source code changed
   - security: Only if auth/api paths OR security keywords found
   - docs: Only if doc files changed OR `export` keyword found

4. **Launch selected review agents** — Make Task tool calls for each selected agent:

   **Code Review Agent** (if selected):
   ```
   Use Task tool with subagent_type="rptc:code-review-agent":
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

5. **Consolidate findings** from launched agents:
   - Categorize: bugs, security, style, structural, documentation
   - Filter to high-confidence issues only (≥80)

6. **Create TodoWrite for ALL findings** (auto-fix by default):
   ```
   TodoWrite with status="pending":
   - [Category] Finding 1: description (file:line)
   - [Category] Finding 2: description (file:line)
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
   - Work through TodoWrite items sequentially
   - For auto-fix items: Apply fix, mark complete
   - For ask-first items: Use AskUserQuestion with fix proposal, then apply or skip
   - Mark all todos complete as addressed

8. **Update TodoWrite**: Mark "Quality Review" as completed

---

## Phase 5: Complete

**BLOCKING CHECKPOINT** — Before Phase 5 can begin:

- [ ] TodoWrite "Quality Review" item MUST be marked "completed"
- [ ] At least one review agent MUST have been launched

If Quality Review not completed → **STOP**. Return to Phase 4.

---

**Goal**: Summarize what was built.

**Actions**:

1. **Mark all todos complete**
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

Agent 1: "Design implementation for [feature]. Perspective: Minimal. ..."
Agent 2: "Design implementation for [feature]. Perspective: Clean. ..."
Agent 3: "Design implementation for [feature]. Perspective: Pragmatic. ..."

After all complete: MUST ask user to choose via AskUserQuestion (skip only for trivial single-file changes).
```

### TDD Executor Agent (Phase 3 - Batch Mode)

```
Use Task tool with subagent_type="rptc:tdd-agent":

## Context
- Feature: [description]
- Batch: Steps [N, N+1, ...] - [summary]

## Steps in This Batch
### Step N: [name]
- Files: [list], Tests: [count], Complexity: [simple|medium|complex]

### Step N+1: [name]
- Files: [list], Tests: [count], Complexity: [simple|medium|complex]

## TDD Cycle
For each step in order: RED → GREEN → REFACTOR, then next step.
```

### Review Agents (Phase 4) - Semantic Selection

**Mode**: Report-only. Agents report findings; main context handles fixes via TodoWrite.

**Selection based on `review-agent-mode` in project CLAUDE.md:**
- `all`: Launch all 3 agents
- `automatic`: Select based on file types/keywords (default if no CLAUDE.md)
- `minimal`: Only when strongly indicated

**Agents:**
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
| Quality reviews | Sequential            | Parallel         |
| Lines of code   | 1800+                 | ~200             |

---

## Error Handling

- **Discovery fails**: Ask user for more context
- **All plans miss requirements**: Re-run planning with additional constraints from user
- **TDD step fails 3x**: Pause, ask user for guidance
- **Quality review finds critical issues**: Block completion, show findings
