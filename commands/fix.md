---
description: Reproduction → Root Cause → Fix → Verification
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TodoWrite, AskUserQuestion, EnterPlanMode, ExitPlanMode
---

# /rptc:fix

Systematic bug fixing: Reproduction → Root Cause Analysis → Fix → Verification.

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

## Phase 1: Reproduction & Triage

**Goal**: Confirm the bug exists and understand its triggering conditions.

> 💡 **Tool Reminder**: Use Sequential Thinking to analyze bug context. Use Serena for code tracing.

**Actions**:

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

**CRITICAL - Test-First Ordering**: Whether delegating to tdd-agent OR executing in main context, ALWAYS write the regression test that reproduces the bug BEFORE modifying production code. Update any existing tests BEFORE changing production code. Never fix production code first.

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

### RED Phase (Critical)
Write a test that REPRODUCES the exact bug:
- Test must fail with the SAME symptom as the bug
- Test must use the SAME conditions that trigger the bug
- Verify: test fails for the right reason (not compile error)

Example structure:
```
test('should [expected behavior] when [condition]', () => {
  // Arrange: Set up bug-triggering conditions
  // Act: Perform the action that triggers the bug
  // Assert: Verify correct behavior (currently fails)
});
```

### GREEN Phase (Surgical)
Apply MINIMAL fix to make the test pass:
- Change ONLY what's necessary to fix the root cause
- Do NOT refactor nearby code
- Do NOT "improve" unrelated code
- Diff should be as small as possible

### VERIFY Phase (Regression Check)
- Run the new regression test (must pass)
- Run related test files (must pass)
- Run full test suite if available (must pass)
- Report any new failures

## Constraints
- Maximum 3 implementation steps
- Keep fix surgical and minimal
- Flag if fix suggests larger refactoring need (don't do it, just flag)
```

2. **Update TodoWrite** as fix progresses

3. **Handle failures**:
   - If test won't reproduce bug: Return to Phase 1 for better reproduction
   - If fix causes new failures: Analyze regression, adjust fix
   - If fix attempt fails 3x: Ask user for guidance

4. **MANDATORY**: Add TodoWrite item "Verification Review" with status "pending" (if not exists)
5. **Transition to Phase 4** — MUST execute before Phase 5

---

## Phase 4: Verification (MANDATORY - BLOCKING GATE)

**Goal**: Verify the fix works and didn't introduce regressions.

**CRITICAL**: This phase MUST execute. Phase 5 CANNOT begin until this phase completes.

**This phase runs for ALL bugs regardless of severity (S1-S4).** Even urgent S1 fixes must be reviewed before completion.

**Actions**:

0. **Update TodoWrite**: Mark "Verification Review" as in_progress

1. **Determine review agent mode** (one-time project configuration):

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
   - code-review: Only if >50 lines changed
   - security: Only if auth/api paths OR security keywords found
   - docs: Only if doc files changed OR export keyword found

3. **Launch selected review agents**:

   **Code Review Agent** (if selected):
   ```
   Use Task tool with subagent_type="rptc:code-review-agent":
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

7. **Update TodoWrite**: Mark "Verification Review" as completed

---

## Phase 5: Complete

**BLOCKING CHECKPOINT** — Before Phase 5 can begin:

- [ ] TodoWrite "Verification Review" item MUST be marked "completed"
- [ ] At least one review agent MUST have been launched

If Verification Review not completed → **STOP**. Return to Phase 4.

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
- [ ] Full suite passes (if run)
- [ ] Review findings addressed

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
RED: Write test that reproduces bug (must fail with same symptom)
GREEN: Apply minimal fix (surgical, no scope creep)
VERIFY: Run full test suite, check for regressions
```

### Review Agents (Phase 4) - Semantic Selection

**Selection based on `review-agent-mode` in project CLAUDE.md:**
- `all`: Launch all 3 agents
- `automatic`: Select based on file types/keywords (default if no CLAUDE.md)
- `minimal`: Only when strongly indicated

**Agents:**
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
| **Phase 4** | Quality review | Quality review + regression focus |
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

