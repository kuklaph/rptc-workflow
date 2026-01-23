---
description: Research → Plan → TDD → Review in one seamless flow
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TodoWrite, AskUserQuestion, EnterPlanMode, ExitPlanMode
---

# /rptc:feat

Complete feature development: Discovery → Architecture → TDD Implementation → Quality Review.

## Arguments

`/rptc:feat <feature-description>`

**Example**: `/rptc:feat "Add user authentication with OAuth2"`

---

## Phase 1: Discovery

**Goal**: Understand what to build and existing patterns.

**Actions**:

1. **Create initial todo list** with phases: Discovery, Architecture, TDD, Quality Review, Complete
2. **If codebase exploration needed**, launch 2-3 Explore agents in parallel using code-explorer methodology:

```
Use Task tool with subagent_type="Explore" (launch all 3 in parallel):

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

3. **If web research needed**, delegate to researcher-agent (Mode B)
4. **If hybrid research needed** (codebase + best practices), launch both in parallel (Mode C)
5. **If unclear about requirements**, ask user for clarification
6. **Summarize findings**: Key patterns, files to modify, dependencies, gap analysis (if hybrid)

---

## Phase 2: Architecture

**Goal**: Design the implementation approach with user approval.

**Actions**:

1. **Enter plan mode** using EnterPlanMode tool

2. **Ask user which planning approach** using AskUserQuestion:

```
Use AskUserQuestion tool:

question: "Which planning approach would you like to use?"
header: "Plan Type"
options:
  - label: "Minimal (Recommended)"
    description: "Smallest change possible. Reuses existing code. Fast to implement but may accumulate tech debt."
  - label: "Clean"
    description: "Maintainability-focused with elegant abstractions. Takes longer but easier to extend later."
  - label: "Pragmatic"
    description: "Balanced approach. Good enough architecture without over-engineering. Middle ground on speed vs quality."
```

3. **Launch selected plan agent**:

```
Use Task tool with subagent_type="rptc:plan-agent":
prompt: "Design implementation for [feature]. Perspective: [selected approach]. Provide: files to modify, component design, data flow, build sequence, test strategy."
```

4. **Write plan to plan file** with:
   - Approach used (with rationale)
   - Implementation steps (testable, ordered)
   - Files to create/modify
   - Test strategy per step

5. **Exit plan mode** using ExitPlanMode to get user approval

**Plan file format** (flexible):

- Simple features: List steps directly
- Complex features: Overview + numbered implementation steps

---

## Phase 3: TDD Implementation (with Smart Batching)

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

6. **For each batch**, delegate to TDD executor sub-agent:

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

**Goal**: Ensure code quality through parallel review.

**Actions**:

1. **Auto-simplify** (autonomous, no approval):
   - Apply CLAUDE.md standards to new code
   - Enhance clarity, reduce obvious complexity
   - Fix formatting, naming violations

2. **Launch parallel review agents**:
   - **Efficiency agent**: Code quality, complexity, KISS/YAGNI
   - **Security agent**: Vulnerabilities, input validation, auth
   - Both use confidence ≥80 filtering

3. **Consolidate findings**:
   - Categorize: bugs, security, style, structural
   - Show only high-confidence issues (≥80)
   - Present to user

4. **User selects what to fix**:
   - Simple fixes: Apply autonomously
   - Structural changes: Show proposed change, get approval

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

### Explore Agents with Code-Explorer Methodology (Phase 1)

```
Launch 3 Task tools in parallel with subagent_type="Explore":

Agent 1 (Feature Discovery): "Find similar features for [topic]. Entry points, core files, boundaries."
Agent 2 (Architecture Analysis): "Analyze architecture for [topic]. Layers, patterns, cross-cutting concerns."
Agent 3 (Code Flow Tracing): "Map integration points for [topic]. Call chains, data flow, dependencies."
```

### Research Agent (Phase 1 - Web/Hybrid)

```
Use Task tool with subagent_type="rptc:researcher-agent":
prompt: "Research [topic]. Mode: [A=codebase|B=web|C=hybrid]. Return: findings with confidence."
```

### Planner Agent (Phase 2)

```
Use Task tool with subagent_type="rptc:plan-agent":
prompt: "Design implementation for [feature]. Perspective: [user-selected: Minimal|Clean|Pragmatic]. Provide: files to modify, component design, data flow, build sequence, test strategy."

Note: User selects approach via AskUserQuestion before agent launch.
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

### Efficiency Agent (Phase 4)

```
Use Task tool with subagent_type="rptc:optimizer-agent":
prompt: "Review code quality for [files]. Apply tiered authority. Output: confidence-scored findings."
```

### Security Agent (Phase 4)

```
Use Task tool with subagent_type="rptc:security-agent":
prompt: "Security review for [files]. Apply tiered authority. Output: confidence-scored findings."
```

---

## Key Principles

1. **Single approval point**: ExitPlanMode after Architecture phase
2. **Ask when uncertain**: Use AskUserQuestion only when genuinely unclear
3. **Smart parallelism**: Parallelize independent steps, sequence dependent ones
4. **Tiered authority**: Auto-fix safe issues, report risky ones
5. **Confidence filtering**: Only surface issues ≥80 confidence
6. **Goal+Actions format**: Trust agents to handle details

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
- **Plan doesn't fit requirements**: Ask user if they want to try a different approach (Minimal/Clean/Pragmatic)
- **TDD step fails 3x**: Pause, ask user for guidance
- **Quality review finds critical issues**: Block completion, show findings
