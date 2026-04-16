---
description: Team-based bug fixing with parallel reproduction, root cause analysis, fix, and review agents
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, EnterPlanMode, ExitPlanMode, TeamCreate, SendMessage
---

# /rptc:fix-team

Team-based bug fixing: 4 persistent agents (Research, Architect, TDD, Review) collaborating via real-time messaging. Unlike `/rptc:fix` which runs agents sequentially as sub-agents, `fix-team` keeps all agents alive so they communicate, cross-check, and provide feedback throughout the bug triage and fix.

## When to Use fix-team vs fix

| Criteria | `/rptc:fix` (standard) | `/rptc:fix-team` (this) |
|----------|-----------------------|------------------------|
| Bug complexity | Any size | Medium-to-complex bugs |
| Agent lifecycle | Sequential (spawn, complete, discard) | Persistent (alive for entire session) |
| Feedback | Post-hoc verification (Phase 4) | Real-time during fix |
| Root cause scrutiny | Checked once | Architect challenges assumptions continuously |
| Cost | Lower ($0.50-$2.00) | Higher ($3.00-$10.00) |
| Best for | Straightforward bugs, known root cause | Complex bugs, unclear root cause, cross-cutting regressions |

---

## Arguments

`/rptc:fix-team <bug-description>`

**Example**: `/rptc:fix-team "Login fails intermittently when user has stale session token and navigates from cached page"`

---

## Step 0: Initialization (MANDATORY - CANNOT SKIP)

### 0.1 Load Required Skills

```
Skill(skill: "rptc:tool-guide")
Skill(skill: "rptc:brainstorming")
Skill(skill: "rptc:writing-clearly-and-concisely")
```

After loading, confirm all loaded. If ANY skill fails to load, STOP and report.

#### 0.1.1 Conditional Skills

**Frontend work** — If the bug involves HTML, CSS, UI components:
```
Skill(skill: "rptc:frontend-design")
```

### 0.1.2 Detect Repo Topology (MANDATORY)

Run these checks in parallel:

1. `Glob(pattern: ".bare")` — bare repo candidate
2. `Read(".git")` — if readable as file, confirms bare repo or worktree
3. `Bash("git rev-parse --show-toplevel")` — repo root
4. `Glob(pattern: ".worktrees")` — worktrees-dir topology

Determine topology:

| `.bare/` exists | `.git` is a file | `.worktrees/` exists | Result |
|:---------------:|:----------------:|:--------------------:|--------|
| Yes | Yes | — | `REPO_TOPOLOGY="bare"`, `REPO_ROOT` = cwd |
| No | — | Yes | `REPO_TOPOLOGY="worktrees-dir"`, `REPO_ROOT` = `git rev-parse --show-toplevel` |
| No | — | No | `REPO_TOPOLOGY="standard"`, `REPO_ROOT` = `git rev-parse --show-toplevel` |

For bare repos: `Bash("git worktree list")` to set `PRIMARY_SOURCE`.

Store `REPO_TOPOLOGY`, `REPO_ROOT`, `PRIMARY_SOURCE` for the session.

### 0.1.3 Activate Serena MCP (MANDATORY)

```
ToolSearch(query: "serena")
```

Activate Serena project using topology from 0.1.2. Skip silently if unavailable.

### 0.2 Task Classification

Classify the bug:
- **Code bug**: Root cause in source files → full team workflow
- **Configuration/docs bug**: Config drift, stale docs → use `/rptc:fix` instead (teams add no value for non-code)

If non-code, inform user and suggest `/rptc:fix`. STOP.

### 0.3 Branch Strategy

Ask user how to organize work (same logic as `/rptc:fix`):

1. Get current branch name
2. Generate worktree branch name from bug description (e.g., `fix/stale-session-token`)
3. Recommend based on expected scope (team workflows are typically non-trivial, so default recommend new worktree)

```
AskUserQuestion:
question: "How should this fix be organized?"
header: "Branch"
options:
  - label: "New worktree [fix/<name>] (Recommended)"
    description: "Isolated branch for team bug fix"
  - label: "Current branch [<current>]"
    description: "Work directly on current branch"
```

If new worktree selected, create using topology-aware path computation (see `/rptc:fix` Branch Strategy for full logic). Store `WORKTREE_PATH`.

---

## Step 1: Create Team

### 1.1 Create the Team

```
TeamCreate(
  team_name: "fix-<bug-slug>",
  description: "RPTC fix-team: <bug description>"
)
```

### 1.2 Create Phase Tasks

Create tasks for the team workflow. Dependencies enforce sequencing where needed.

```
TaskCreate("Phase 1: Reproduction & Triage", description: "Research agent reproduces bug and reports affected code paths")
TaskCreate("Phase 2: Root Cause Analysis", description: "Architect agent applies 5 Whys to identify root cause and design minimal fix")
TaskCreate("Phase 3: Fix + Review", description: "TDD agent writes regression test and applies fix with Architect + Review monitoring")
TaskCreate("Phase 4: Final Regression Review", description: "Architect + Review collaborate on holistic verification that fix addresses root cause without regression")
TaskCreate("Phase 5: Wrap-up", description: "Team Lead collects reports, presents summary")

TaskUpdate(Phase 2, addBlockedBy: [Phase 1])
TaskUpdate(Phase 3, addBlockedBy: [Phase 2])
TaskUpdate(Phase 4, addBlockedBy: [Phase 3])
TaskUpdate(Phase 5, addBlockedBy: [Phase 4])
```

### 1.3 Build Environment Context Block

Construct this block once — it goes into every agent spawn prompt:

```
ENVIRONMENT:
Repo topology: <REPO_TOPOLOGY>
Repo root: <REPO_ROOT>
Serena project: <SERENA_PROJECT_NAME>
  → Call activate_project("<SERENA_PROJECT_NAME>") before using any Serena tools.
[If WORKTREE_PATH is set:]
Worktree: <WORKTREE_PATH>
  → cd "<WORKTREE_PATH>" before doing ANY work.
  → All file paths are relative to this worktree root.
```

---

## Step 2: Spawn All Agents

Spawn all 4 agents. Research starts working immediately. Architect, TDD, and Review wait for messages.

**IMPORTANT**: Launch all 4 Agent calls in the SAME message for parallel startup.

### 2.1 Research Agent

```
Agent(
  name: "researcher",
  subagent_type: "rptc:research-agent",
  team_name: "<team-name>",
  prompt: "<spawn prompt below>"
)
```

**Spawn prompt**:
```
You are the Research agent in an RPTC fix-team.

[ENVIRONMENT CONTEXT BLOCK]

## Your Task
Reproduce and triage the bug: [bug description]

## What To Do
1. **Reproduce the bug**: Identify exact reproduction steps, inputs, and conditions that trigger it
2. **Trace the failure path**: Follow the call chain from trigger to failure point (code-explorer Phase 2: call chains, data transformations, side effects)
3. **Map affected code**: Identify all files, functions, and components involved in the failure path
4. **Assess impact and severity**: How many users/flows affected? Does it cause data loss, security issues, or just inconvenience? Any related bugs in the same area?

## When Done
Message the Team Lead with your triage findings:
- Reproduction steps (minimal repro if possible)
- Failure path (file:line references from trigger to failure point)
- Affected code paths and components
- Impact assessment (severity, scope, related issues)
- Any existing tests that should have caught this (regression coverage gap)

Also message "architect" directly with the same findings so they can begin root cause analysis.

Mark your Phase 1 task as completed.

## After Phase 1: On-Call Resource
Stay available after triage completes. Teammates may message you with research questions during the fix — codebase lookups, git blame investigations, web research for known issues or CVEs. Investigate and respond directly to the requesting agent.
```

### 2.2 Architect Agent

```
Agent(
  name: "architect",
  subagent_type: "rptc:architect-agent",
  team_name: "<team-name>",
  prompt: "<spawn prompt below>"
)
```

**Spawn prompt**:
```
You are the Architect agent in an RPTC fix-team. You have TWO roles:
1. **Phase 2**: Identify root cause and design minimal fix
2. **Phase 3**: Monitor fix adherence as the TDD agent implements

[ENVIRONMENT CONTEXT BLOCK]

## Bug
[bug description]

## Phase 2: Root Cause Analysis
Wait for the "researcher" agent to message you with triage findings. Then:

1. Study the reproduction steps and failure path
2. Apply **5 Whys methodology** to identify the true root cause:
   - Why did the failure occur? → immediate cause
   - Why did that happen? → contributing factor
   - Continue until you reach the systemic root cause, not just a symptom
3. Design ONE minimal fix plan following your architect-methodology:
   - Root cause analysis (5 Whys output)
   - Minimal fix approach — change only what addresses the root cause, no scope creep
   - Files to modify (list)
   - **Regression test strategy**: test must FAIL before fix and PASS after (reproduces the bug)
   - Related code paths that should be verified (related bug check)
4. Message the Team Lead with the complete plan — the Team Lead will present it to the user via plan mode for review
5. **WAIT** — do not proceed until the Team Lead messages you with approval (the user may request changes, in which case the Team Lead will relay their feedback)

## Phase 3: Fix Guardianship (after approval)
Once the Team Lead confirms the plan is approved:

1. Mark Phase 2 task as completed
2. Transition to **fix guardian** mode
3. When "implementer" messages you that a step is complete:
   - Read the changed files
   - Compare against the plan step specification
   - Check: correct files modified? Minimal fix (not symptom treatment)? Scope creep? Missing regression coverage?
   - Message "implementer" with your assessment:
     ```
     ## Fix Check: Step [N]
     Adherence: [ON TRACK / DRIFT DETECTED / SYMPTOM TREATMENT]
     [If drift:] Expected: [what plan says] | Actual: [what was done]
     [If symptom:] Root cause not addressed — [explanation]
     [If on track:] Confirmed — fix addresses root cause as planned.
     Proceed to: Step [N+1] / Address issue first
     ```
4. If you detect that the fix treats symptoms rather than root cause, also message the Team Lead

## Communication
- You can message: "researcher", "implementer", "reviewer", and Team Lead
- If you need codebase or web research during your work, message "researcher" with your question rather than investigating yourself
- Message the Team Lead for any decisions requiring PM input
- NEVER modify code files — you are read-only

## When All Steps Complete
Message the Team Lead with a final fix adherence report:
- Steps completed as planned: [count]
- Steps with drift (addressed): [count]
- Root cause fully addressed: [YES/NO/PARTIAL]
- Regression risk assessment: [LOW/MEDIUM/HIGH]

## Final Holistic Review (after fix applied)
The Team Lead will message you to perform a final holistic review. This is different from your per-step checks — review ALL changes as a unified fix:
- Did the fix address the root cause, or just the symptom?
- Are there related code paths that share the same root cause but weren't fixed?
- Does the regression test actually reproduce the original bug?
- Any scope creep or architectural inconsistency?
Share your findings with "reviewer" for cross-checking, then report to the Team Lead.
```

### 2.3 TDD Agent

```
Agent(
  name: "implementer",
  subagent_type: "rptc:tdd-agent",
  team_name: "<team-name>",
  prompt: "<spawn prompt below>"
)
```

**Spawn prompt**:
```
You are the TDD Implementation agent in an RPTC fix-team. You are the ONLY agent that writes code.

[ENVIRONMENT CONTEXT BLOCK]

## Bug
[bug description]

## Your Role
Wait for the Team Lead to message you with the approved fix plan. Then apply each step using strict TDD (regression test FIRST, then fix).

## Execution Protocol

For EACH plan step, in order:

### 1. Announce
Message "architect" and "reviewer": "Starting Step [N]: [name]. Files: [list]"

### 2. Implement (TDD for bugs)
Follow your tdd-agent-methodology strictly, adapted for bug fixing:
- **Surgical Coding**: Search for related patterns and existing tests first
- **RED (Regression Test First)**: Write a test that reproduces the bug. FILE LOCKOUT — only test files.
  - The test MUST fail against the current (broken) code
  - The test MUST fail for the correct reason (the bug, not a setup error)
- **RED GATE**: Verify before GREEN:
  - [ ] Only test files created/modified
  - [ ] Test reproduces the reported bug
  - [ ] Test fails for the bug reason (not setup/import/syntax errors)
  - [ ] No production files touched
- **GREEN**: Minimal fix that addresses the root cause (NOT just the symptom) to make the test pass
- **REFACTOR**: Improve while green (but stay minimal — bug fixes should be surgical)
- **VERIFY**: Run tests, confirm the regression test passes AND all existing tests still pass

### 3. Report
Message BOTH "architect" AND "reviewer":
```
Step [N] complete.
Files changed: [list with brief description of changes]
Regression test: [file:line]
Tests added: [count], all passing: [YES/NO]
Existing tests: [count passing / count total]
```

### 4. Wait for Feedback
After messaging, WAIT for responses from both "architect" and "reviewer" before proceeding to the next step.

- "architect" checks fix adherence and root cause coverage — if they report drift or symptom treatment, address it before continuing
- "reviewer" checks code quality, security, regression coverage — if they report blocking issues, fix them before continuing
- Warnings can be noted and addressed before completion
- Nits must be addressed before moving to the next step — all findings matter

If BOTH respond with no blocking issues (or you receive no response after reporting), proceed to the next step.

### 5. Repeat
Continue to the next plan step.

## Communication Rules
- Message "architect" and "reviewer" after EVERY step completion
- If you need codebase or web research during your work, message "researcher" with your question rather than investigating yourself
- Message the Team Lead if you hit a blocker or need a PM decision
- If feedback from architect and reviewer conflict, message the Team Lead to arbitrate
- NEVER skip the feedback wait — the whole point of this team is cross-agent review

## RPTC Directives (FOLLOW THESE)

| Directive | What It Means |
|-----------|---------------|
| Surgical Coding | Minimum change to fix the root cause. No refactoring unrelated code. |
| KISS / YAGNI | Simplest fix. Don't rewrite the module because the bug revealed ugliness. |
| Test-First | Regression test BEFORE fix. Non-negotiable. |
| Root Cause Focus | Fix the cause, not the symptom. Architect will flag symptom treatment. |

**FILE LOCKOUT (RED phase)**: Only test files during RED. Any production file edit = TDD violation.
**RED GATE**: Verify regression test reproduces the bug before GREEN. If any check fails, STOP and fix.

## When All Steps Complete
Message the Team Lead with:
- All steps completed: [YES/NO]
- Total files changed: [list]
- Regression tests added: [count]
- All tests passing: [YES/NO]
- No existing tests broken: [YES/NO]
- Test-First followed for every step: [YES/NO]
- Feedback addressed: [summary of architect/reviewer feedback acted on]
```

### 2.4 Review Agent

```
Agent(
  name: "reviewer",
  subagent_type: "rptc:review-agent",
  team_name: "<team-name>",
  prompt: "<spawn prompt below>"
)
```

**Spawn prompt**:
```
You are the Review agent in an RPTC fix-team. You provide real-time quality feedback across code review, security, and documentation, with extra focus on regression risk.

[ENVIRONMENT CONTEXT BLOCK]

## Bug
[bug description]

## Your Role
Wait for the Team Lead to message you with the approved plan. Then monitor fix quality as the TDD agent works.

## Review Protocol

When "implementer" messages you that a step is complete:

1. **Read the changed files** listed in the message
2. **Read the regression test** — verify it actually reproduces the bug
3. **Review across all three domains** in a single pass, with regression emphasis:
   - **Code Quality**: 4-tier hierarchy (architecture, maintainability, standards, nits), KISS/YAGNI, scope creep (fixes should be surgical), pattern alignment
   - **Security**: OWASP Top 10, did the bug or fix introduce security implications? Input validation at the failure point?
   - **Documentation**: Does the fix need a CHANGELOG entry? Are any docs now stale due to the fix? Comments explaining WHY (non-obvious bug)?
   - **Regression Coverage**: Does the test pin the bug correctly? Are related code paths also covered?
4. **Send consolidated feedback** to "implementer":
   ```
   ## Review: Step [N]

   ### [filename]
   - [BLOCKING/WARNING/NIT] [confidence%] [domain] — [description] — [suggested approach]

   ### Regression Test Assessment
   - Reproduces bug: [YES/NO]
   - Related paths covered: [YES/PARTIAL/NO]

   ### Summary
   - Blocking: [count] (must fix before next step)
   - Warnings: [count] (fix when convenient, but must be addressed before completion)
   - Nits: [count] (address before next step)
   ```
5. **If no issues**: Message "Step [N] reviewed — no findings. Regression test confirms bug reproduction. Proceed."

## Urgency Categories
- **BLOCKING** (Tier 1, security critical/high, missing regression test): Implementer MUST fix before next step
- **WARNING** (Tier 2, security medium, partial regression coverage): Should fix, can continue to next step
- **NIT** (Tier 3-4, docs suggestions): Implementer MUST address before moving to next step — nits are NOT optional; clean code ships clean

## Confidence Threshold
Only report findings with confidence >= 80%. Below 80% = ignore.

## Communication
- Primary: Message "implementer" with review feedback after each step
- If you need codebase or web research during your work, message "researcher" with your question rather than investigating yourself
- Also message the Team Lead if you find critical security issues, missing regression coverage on related paths, or architectural problems
- Message "architect" if you suspect the fix treats symptoms rather than root cause (they are the primary root cause guardian)
- NEVER modify code files — you are strictly read-only and report-only

## RPTC Directives
| Directive | Your Responsibility |
|-----------|---------------------|
| Surgical Coding | Flag scope creep — bug fixes should only touch what's needed |
| KISS/YAGNI | Flag unnecessary refactoring disguised as "cleanup while I'm in here" |
| Test-First | Verify regression test was written before the fix and reproduces the bug |
| Pattern Alignment | Flag codebase convention violations in the fix |

## When Fix Is Complete
After the final step is reviewed, message the Team Lead with a comprehensive report:
- Total findings by domain (code quality / security / docs / regression)
- Total findings by urgency (blocking / warning / nit)
- Findings addressed by implementer: [count]
- Unresolved findings: [list with details]
- Regression coverage: [COMPLETE / PARTIAL / INADEQUATE]
- Overall quality assessment: [PASS / PASS WITH CONCERNS / NEEDS ATTENTION]

## Final Holistic Review (after fix applied)
The Team Lead will message you to perform a final holistic review. This is different from your per-step checks — review ALL changes as a unified fix:
- Does the regression test suite adequately prevent this class of bug?
- Cross-file consistency, naming coherence, unnecessary scope expansion
- Auth and data flow — did the fix preserve existing security properties?
- All related code paths covered (not just the reported failure point)?
- Documentation: CHANGELOG, known issues, migration notes (if breaking)?
Share your findings with "architect" for cross-checking, then report to the Team Lead.
```

---

## Step 3: Orchestrate

You (Team Lead) coordinate the workflow by monitoring messages and handling approvals.

### 3.1 Reproduction & Triage Phase

`TaskUpdate(Phase 1, status: "in_progress")`

The Research agent is already working (spawned in Step 2). Wait for its triage findings message.

When received:
- Review the findings briefly
- The researcher also messages the Architect directly — no forwarding needed

`TaskUpdate(Phase 1, status: "completed")`

### 3.2 Root Cause Analysis Phase

`TaskUpdate(Phase 2, status: "in_progress")`

The Architect begins 5 Whys analysis after receiving triage findings. Wait for the Architect's plan message.

When the Architect sends the plan:

1. **Enter plan mode** and write the Architect's plan to the plan file:
   ```
   EnterPlanMode()
   ```
   Write the plan content the Architect provided. Include: root cause analysis (5 Whys), minimal fix approach, files to modify, regression test strategy, and related paths to verify.

2. **Exit plan mode** so the user can review in the native plan UI:
   ```
   ExitPlanMode()
   ```
   The user now sees the full plan and can approve, edit inline, or reject.

3. **If user approves the plan**: Message all three remaining agents:
   - Message "architect": "Plan approved. Transition to fix guardian mode. Monitor implementation for fix adherence and root cause coverage."
   - Message "implementer": "Plan approved. Begin fix. Here is the plan: [paste plan or reference plan file location]"
   - Message "reviewer": "Plan approved. Here is the plan for reference: [paste plan or reference plan file location]. Begin monitoring when implementer starts."

4. **If user edits the plan**: The edited plan is the new approved version. Send the updated plan to all three agents as above.

5. **If user rejects the plan**: Read the user's feedback, then message "architect" with the feedback for revision. Wait for the revised plan. Re-enter plan mode and repeat from step 1.

`TaskUpdate(Phase 2, status: "completed")`

### 3.3 Fix + Review Phase

`TaskUpdate(Phase 3, status: "in_progress")`

TDD, Architect, and Review agents now work in a parallel feedback loop. Your role as Team Lead:

**Monitor** — Watch for messages from agents. You'll receive idle notifications with DM summaries showing peer communication.

**Intervene when**:
- An agent reports a blocker → help resolve or escalate to user
- Architect flags symptom treatment (not addressing root cause) → escalate to user for decision
- Architect and Review give conflicting feedback → arbitrate
- Any agent flags a finding needing PM review (80-89% confidence) → batch and present to user
- TDD reports a TDD violation → decide whether to re-run or accept

**PM Decision Batching**: Collect medium-confidence findings (80-89%) from Architect and Review. Present them to the user in batches rather than one-at-a-time:

```
AskUserQuestion:
question: "Agents flagged these items for your review:"
header: "Findings Review"
options:
  - label: "Address all"
    description: "Send all back to implementer to fix"
  - label: "Address blocking only"
    description: "Fix critical issues, accept warnings"
  - label: "Accept as-is"
    description: "Proceed without changes"
```

**Wait for completion signals** from all three agents:
- "implementer": All steps complete, regression test passes, no existing tests broken
- "architect": Final fix adherence report, root cause coverage assessment
- "reviewer": Final quality assessment, regression coverage assessment

`TaskUpdate(Phase 3, status: "completed")`

---

## Step 4: Final Regression Review

`TaskUpdate(Phase 4, status: "in_progress")`

**Goal**: Architect and Review collaborate on a comprehensive verification that the fix addresses the root cause without introducing regression, catching cross-cutting issues that step-by-step reviews miss.

The step-by-step reviews during the fix catch per-step issues. This final pass verifies the complete fix holistically: did we address the root cause? Are related code paths also fixed? Is the regression test suite adequate?

### 4.1 Trigger Final Review

Message both agents to begin their holistic review:

```
SendMessage(to: "architect", message:
  "The fix is complete. Perform a final holistic review of ALL changes together.

  Review the full set of modified files as a unified fix — not step-by-step.

  Check:
  - Did the fix address the root cause identified in 5 Whys, or just the symptom?
  - Are there related code paths that share the same root cause but weren't fixed?
  - Did any step introduce scope creep beyond the minimal fix?
  - Does the regression test actually reproduce the original bug (remove the fix temporarily — would the test catch it)?
  - Any systemic concerns that emerged from seeing the complete fix?

  Share your findings with 'reviewer' so you can cross-check.
  Then message the Team Lead with your final holistic assessment."
)

SendMessage(to: "reviewer", message:
  "The fix is complete. Perform a final holistic review of ALL changes together.

  Review the full set of modified files as a unified fix — not step-by-step.

  Check across all three domains plus regression:
  - **Regression coverage**: Does the test suite now prevent this class of bug? Related paths covered?
  - **Code quality**: Cross-file consistency, scope creep (refactoring disguised as fix), overall complexity
  - **Security**: Did the bug or fix introduce security implications? Trust boundary changes?
  - **Documentation**: Does CHANGELOG need an entry? Stale docs due to the fix? Comments explaining WHY the fix is correct?

  Share your findings with 'architect' so you can cross-check.
  Then message the Team Lead with your final holistic assessment."
)
```

### 4.2 Wait for Cross-Check

Both agents review all changes and share findings with each other. Wait for both to send their final holistic assessments to you.

**If findings emerge**:
- Blocking issues → message "implementer" with the consolidated list, wait for fixes, then re-trigger 4.1
- Warnings/nits → message "implementer" with the list, wait for fixes
- No findings → proceed

### 4.3 User Acknowledgment

Present the holistic review results:

```
AskUserQuestion:
question: "Final regression review complete. [N] additional findings addressed. Proceed to wrap-up?"
header: "Final Review Gate"
options:
  - label: "Proceed to wrap-up"
    description: "All holistic findings addressed, ready to finalize"
  - label: "Request another pass"
    description: "Ask architect and reviewer to check again"
```

If "Request another pass" → re-trigger 4.1.

`TaskUpdate(Phase 4, status: "completed")`

---

## Step 5: Complete

`TaskUpdate(Phase 5, status: "in_progress")`

### 5.1 Collect Reports

Gather final reports from all agents. If any agent hasn't sent a completion report, message them requesting one.

### 5.2 Present Summary to User

```markdown
## fix-team Complete

### Bug: [description]

### Root Cause (from 5 Whys)
[root cause summary]

### Fix Summary
- Files modified: [list]
- Regression tests added: [count]
- All tests passing: [YES/NO]
- Existing tests unaffected: [YES/NO]

### Fix Adherence (Architect)
- Steps completed as planned: [X/Y]
- Root cause fully addressed: [YES/PARTIAL/NO]
- Symptom treatment detected: [count with resolution]
- Overall adherence: [percentage]

### Quality Assessment (Review)
- Code quality findings: [count addressed / count total]
- Security findings: [count addressed / count total]
- Documentation findings: [count addressed / count total]
- Regression coverage: [COMPLETE/PARTIAL/INADEQUATE]
- Overall: [PASS / PASS WITH CONCERNS]

### Final Holistic Review
- Cross-cutting findings caught: [count]
- Related code paths verified: [count]
- All addressed: [YES/NO]

### RPTC Compliance
- Test-First followed: [YES/NO]
- FILE LOCKOUT respected: [YES/NO]
- Surgical fix (no scope creep): [YES/NO]

### Ready for: `/rptc:commit`
```

### 5.3 Shutdown Team

Send shutdown messages to all agents:

```
SendMessage(to: "researcher", message: { type: "shutdown_request" })
SendMessage(to: "architect", message: { type: "shutdown_request" })
SendMessage(to: "implementer", message: { type: "shutdown_request" })
SendMessage(to: "reviewer", message: { type: "shutdown_request" })
```

`TaskUpdate(Phase 5, status: "completed")`

---

## Error Handling

- **Research agent cannot reproduce the bug**: Team Lead asks user for more details (logs, screenshots, environment), then restarts research with additional context
- **Architect 5 Whys reaches "unknown"**: Ask user if they want to provide additional context (system knowledge, history of similar bugs), then send to Architect for another pass
- **Architect plan rejected multiple times**: Ask user if they want to provide their own fix outline, then send to Architect to formalize with regression test strategy
- **TDD agent cannot write a failing regression test**: The bug may not be reproducible in the test environment. Team Lead pauses, asks user for guidance (integration test required? Additional setup?)
- **TDD agent hits 3 consecutive failures on a step**: Team Lead pauses implementation, asks user for guidance
- **Architect flags symptom treatment repeatedly**: Team Lead escalates to user — accept shallow fix or invest in deeper fix?
- **Conflicting feedback from Architect and Review**: Team Lead arbitrates based on priority (root cause > regression coverage > code quality > polish)
- **Agent becomes unresponsive**: Message the agent. If no response, spawn a replacement with the same role and context
- **Critical security finding during fix**: Team Lead immediately pauses TDD agent, presents to user before continuing

---

## Key Principles

1. **Persistent agents**: All 4 agents stay alive for the entire session — this enables real-time feedback
2. **TDD is sole code owner**: Only the TDD agent writes code. Architect and Review are read-only
3. **Regression test first**: Test must fail against broken code BEFORE the fix is applied — this proves the test actually pins the bug
4. **Root cause over symptom**: Architect continuously guards against symptom treatment; fix must address the cause identified in 5 Whys
5. **Surgical fixes**: Bug fixes are narrow in scope. No refactoring disguised as cleanup.
6. **Final holistic review**: After the fix, Architect and Review verify root cause coverage, related path coverage, and regression test adequacy across all changes together
7. **Team Lead intermediates**: User never communicates directly with agents — Team Lead handles all PM interactions
8. **Three-way verification**: Every step is checked by the implementer (regression test), the Architect (root cause adherence), and the Review (quality/security/docs/regression)
