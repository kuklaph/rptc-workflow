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
2. **Launch 3 code-architect agents in parallel** with different perspectives:
   - **Minimal**: Smallest change, maximum reuse of existing code
   - **Clean**: Maintainability-focused, elegant abstractions
   - **Pragmatic**: Balance of speed and quality
3. **Review all approaches**, form an opinion
4. **Write plan to plan file** with:
   - Recommended approach (with rationale)
   - Alternative approaches (brief summary)
   - Implementation steps (testable, ordered)
   - Files to create/modify
   - Test strategy per step
5. **Exit plan mode** using ExitPlanMode to get user approval

**Plan file format** (flexible):

- Simple features: List steps directly
- Complex features: Overview + numbered implementation steps

---

## Phase 3: TDD Implementation (with Test-Driven Generation)

**Goal**: Build with tests first, using AI-accelerated test generation.

**TDG (Test-Driven Generation)**: Each step generates ~50 comprehensive tests covering:

- Happy paths and success scenarios
- Edge cases and boundary conditions
- Error conditions and failure modes
- Integration scenarios

This eliminates ~80% of manual TDD overhead while maintaining test-first discipline.

**Actions**:

1. **Extract steps from plan** into TodoWrite
2. **Detect parallelizable steps**:
   - Different target files → likely independent → parallelize
   - Shared state/data → sequential
   - Explicit "after step N" → sequential
3. **For each step**, delegate to TDD executor sub-agent:

```
Use Task tool with subagent_type="rptc:tdd-agent":

## Context
- Feature: [description]
- Step: [N] - [step name]
- Previous steps completed: [list]

## Test-Driven Generation
Generate comprehensive test suite (~50 tests) covering:
- Happy paths for this step's functionality
- Edge cases (empty, null, boundaries)
- Error conditions (invalid input, failures)
- Integration with previous steps

## Implementation
- Files to modify: [from plan]
- Constraints: [any limits]

## TDD Cycle
RED: Write all tests first (they fail)
GREEN: Implement minimal code to pass
REFACTOR: Improve while keeping green
```

4. **Update TodoWrite** as each step completes
5. **Handle failures**: If step fails after 3 attempts, ask user for guidance

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

### Architect Agent (Phase 2)

```
Use Task tool with subagent_type="feature-dev:code-architect":
prompt: "Design implementation for [feature]. Perspective: [Minimal|Clean|Pragmatic]. Provide: files to modify, component design, data flow, build sequence."
```

### TDD Executor Agent (Phase 3)

```
Use Task tool with subagent_type="rptc:tdd-agent":
prompt: "[Context + Step details + TDG instruction (generate ~50 tests) + TDD cycle]"
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
- **Architecture disagreement**: Present all 3 perspectives, user chooses
- **TDD step fails 3x**: Pause, ask user for guidance
- **Quality review finds critical issues**: Block completion, show findings
