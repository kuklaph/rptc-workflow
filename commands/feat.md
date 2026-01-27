---
description: Research → Plan → TDD → Review in one seamless flow
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TodoWrite, AskUserQuestion, EnterPlanMode, ExitPlanMode
---

# /rptc:feat

Complete feature development: Discovery → Architecture → Implementation → Quality Review.

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

## Phase 1: Discovery

**Goal**: Understand what to build and existing patterns.

**Actions**:

1. **Classify task type** (see Task Classification above)
2. **Create initial todo list** with phases based on task type:
   - Code tasks: Discovery, Architecture, TDD Implementation, Quality Review, Complete
   - Non-Code tasks: Discovery, Architecture, Implementation, Review, Complete
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

**Actions**:

1. **Enter plan mode** using EnterPlanMode tool

2. **Launch 3 plan agents in parallel** with different perspectives:

```
Use Task tool with subagent_type="rptc:architect-agent" (launch all 3 in parallel):

Agent 1: "Design implementation for [feature]. Perspective: Minimal. Provide: files to modify, component design, data flow, build sequence. [If code task: include test strategy]"

Agent 2: "Design implementation for [feature]. Perspective: Clean. Provide: files to modify, component design, data flow, build sequence. [If code task: include test strategy]"

Agent 3: "Design implementation for [feature]. Perspective: Pragmatic. Provide: files to modify, component design, data flow, build sequence. [If code task: include test strategy]"
```

3. **Review all 3 approaches**, form an opinion on which fits best for this specific feature

4. **Present to user** via AskUserQuestion (put recommended option first with "(Recommended)" suffix):

```
Use AskUserQuestion tool:

question: "Which planning approach would you like to use?"
header: "Plan Type"
options:
  - label: "[Best fit] (Recommended)"
    description: "[Why this fits best for this feature]"
  - label: "[Second option]"
    description: "[Brief description and trade-offs]"
  - label: "[Third option]"
    description: "[Brief description and trade-offs]"

Approach descriptions:
- Minimal: Smallest change possible. Reuses existing code. Fast but may accumulate tech debt.
- Clean: Maintainability-focused with elegant abstractions. Takes longer but easier to extend.
- Pragmatic: Balanced approach. Good enough architecture without over-engineering.
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

### Route A: Non-Code Tasks (Direct Execution)

**When**: `task_type = non-code` (documentation, config, markdown, plugin updates)

**Actions**:

1. **Execute steps directly** in main context (no sub-agent delegation)
2. **For each step**:
   - Read target files
   - Make changes using Edit/Write tools
   - Verify changes are correct
3. **Update TodoWrite** as each step completes
4. **Proceed to Phase 4** (Quality Review)

---

### Route B: Code Tasks (TDD with Smart Batching)

**When**: `task_type = code` (source files, tests, application logic)

**Goal**: Build with tests first, using intelligent step batching for efficiency.

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
10. **Proceed to Phase 4** (Quality Review) after all batches complete

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

## Phase 4: Quality Review

**Goal**: Review changes and report findings for main context to address.

**Mode**: Report-only. Review agents DO NOT make changes—they report findings. Main context handles all fixes.

**Actions**:

1. **Collect files modified** during Phase 3 for review

2. **Launch ALL THREE review agents in parallel** (MUST invoke all in same message):

```
Use Task tool with subagent_type="rptc:code-review-agent":
prompt: "Review code quality for these files: [list all files modified in Phase 3].
Focus: complexity, KISS/YAGNI violations, dead code, readability.
REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."

Use Task tool with subagent_type="rptc:security-agent":
prompt: "Security review for these files: [list all files modified in Phase 3].
Focus: input validation, auth checks, injection vulnerabilities, data exposure.
REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."

Use Task tool with subagent_type="rptc:docs-agent":
prompt: "Review documentation impact for these files: [list all files modified in Phase 3].
Focus: README updates, API doc changes, inline comment accuracy, breaking changes.
REPORT ONLY - do not make changes. Output: documentation updates needed (≥80 only)."
```

3. **Consolidate findings** from all agents:
   - Categorize: bugs, security, style, structural, documentation
   - Show only high-confidence issues (≥80)
   - Present summary to user

4. **Create TodoWrite for fixes** (if any findings):
   ```
   TodoWrite with status="pending":
   - [Category] Finding 1: description (file:line)
   - [Category] Finding 2: description (file:line)
   ...
   ```

5. **Main context addresses findings**:
   - Work through TodoWrite items
   - Simple fixes: Apply directly
   - Structural changes: Show proposed change, get user approval
   - Mark todos complete as addressed

---

## Phase 5: Complete

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

After all complete: Present options to user via AskUserQuestion, write selected plan.
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

### Review Agents (Phase 4) - MUST launch all three in parallel

**Mode**: Report-only. Agents report findings; main context handles fixes via TodoWrite.

```
Launch ALL THREE in the same message for parallel execution:

Use Task tool with subagent_type="rptc:code-review-agent":
prompt: "Review code quality for [files]. Focus: complexity, KISS/YAGNI, dead code, readability. REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."

Use Task tool with subagent_type="rptc:security-agent":
prompt: "Security review for [files]. Focus: input validation, auth, injection, data exposure. REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."

Use Task tool with subagent_type="rptc:docs-agent":
prompt: "Review documentation impact for [files]. Focus: README, API docs, inline comments, breaking changes. REPORT ONLY - do not make changes. Output: documentation updates needed (≥80 only)."
```

---

## Key Principles

1. **Single approval point**: ExitPlanMode after Architecture phase
2. **Ask when uncertain**: Use AskUserQuestion only when genuinely unclear
3. **Smart parallelism**: Parallelize independent steps, sequence dependent ones
4. **Task-appropriate workflow**: TDD for code, direct execution for non-code
5. **Report-only reviews**: Agents report findings, main context fixes via TodoWrite
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
