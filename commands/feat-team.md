---
description: Team-based feature development with parallel research, planning, implementation, and review agents
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, EnterPlanMode, ExitPlanMode, TeamCreate, SendMessage
---

# /rptc:feat-team

Team-based feature development: 4 persistent agents (Research, Architect, TDD, Review) collaborating via real-time messaging. Unlike `/rptc:feat` which runs agents sequentially as sub-agents, `feat-team` keeps all agents alive so they communicate, cross-check, and provide feedback throughout the session.

## When to Use feat-team vs feat

| Criteria | `/rptc:feat` (standard) | `/rptc:feat-team` (this) |
|----------|------------------------|-------------------------|
| Task size | Any size | Medium-to-large features |
| Agent lifecycle | Sequential (spawn, complete, discard) | Persistent (alive for entire session) |
| Feedback | Post-hoc verification (Phase 4) | Real-time during implementation |
| Plan adherence | Checked at end | Architect monitors continuously |
| Cost | Lower ($0.50-$2.00) | Higher ($3.00-$10.00) |
| Best for | Straightforward features, small changes | Complex features needing cross-agent collaboration |

---

## Arguments

`/rptc:feat-team <feature-description>`

**Example**: `/rptc:feat-team "Add user authentication with OAuth2 and role-based access control"`

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

**Frontend work** — If the task involves HTML, CSS, UI components:
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

Classify the task:
- **Code tasks**: Create/modify source files → full team workflow
- **Non-code tasks**: Documentation, config only → use `/rptc:feat` instead (teams add no value for non-code)

If non-code, inform user and suggest `/rptc:feat`. STOP.

### 0.3 Branch Strategy

Ask user how to organize work (same logic as `/rptc:feat`):

1. Get current branch name
2. Generate worktree branch name from feature description (e.g., `feature/add-user-auth`)
3. Recommend based on expected scope (team workflows are typically multi-file, so default recommend new worktree)

```
AskUserQuestion:
question: "How should this feature be organized?"
header: "Branch"
options:
  - label: "New worktree [feature/<name>] (Recommended)"
    description: "Isolated branch for team development"
  - label: "Current branch [<current>]"
    description: "Work directly on current branch"
```

If new worktree selected, create using topology-aware path computation (see `/rptc:feat` Branch Strategy for full logic). Store `WORKTREE_PATH`.

---

## Step 1: Create Team

### 1.1 Create the Team

```
TeamCreate(
  team_name: "<feature-slug>",
  description: "RPTC feat-team: <feature description>"
)
```

### 1.2 Create Phase Tasks

Create tasks for the team workflow. Dependencies enforce sequencing where needed.

```
TaskCreate("Phase 1: Discovery", description: "Research agent explores codebase and reports findings")
TaskCreate("Phase 2: Architecture", description: "Architect agent creates implementation plan")
TaskCreate("Phase 3: Implementation", description: "TDD agent implements with Architect + Review monitoring")
TaskCreate("Phase 4: Final Review", description: "Architect + Review collaborate on holistic review of all changes")
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
You are the Research agent in an RPTC feat-team.

[ENVIRONMENT CONTEXT BLOCK]

## Your Task
Explore the codebase to understand what's needed for: [feature description]

## What To Do
1. Find similar features and existing patterns (code-explorer Phase 1: entry points, core files, boundaries)
2. Analyze architecture and abstractions (Phase 3: layers, patterns, cross-cutting concerns)
3. Map integration points and dependencies (Phase 2: call chains, data flow, side effects)

## When Done
Message the Team Lead with your findings:
- Key patterns found (with file:line references)
- Files that will need modification
- Dependencies and integration points
- Existing conventions to follow
- Any risks or concerns

Also message "architect" directly with the same findings so they can begin planning.

Mark your Phase 1 task as completed.

## After Phase 1: On-Call Resource
Stay available after discovery completes. Teammates may message you with research questions during implementation — codebase lookups, pattern investigations, web research for best practices. Investigate and respond directly to the requesting agent.
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
You are the Architect agent in an RPTC feat-team. You have TWO roles:
1. **Phase 2**: Create the implementation plan
2. **Phase 3**: Monitor plan adherence as the TDD agent implements

[ENVIRONMENT CONTEXT BLOCK]

## Feature
[feature description]

## Phase 2: Planning
Wait for the "researcher" agent to message you with codebase findings. Then:

1. Study the research findings
2. Design ONE pragmatic implementation plan following your architect-methodology
3. Include: approach rationale, implementation steps (ordered), files to create/modify, test strategy per step
4. Message the Team Lead with the complete plan — the Team Lead will present it to the user via plan mode for review
5. **WAIT** — do not proceed until the Team Lead messages you with approval (the user may request changes, in which case the Team Lead will relay their feedback)

## Phase 3: Plan Guardianship (after approval)
Once the Team Lead confirms the plan is approved:

1. Mark Phase 2 task as completed
2. Transition to **plan guardian** mode
3. When "implementer" messages you that a step is complete:
   - Read the changed files
   - Compare against the plan step specification
   - Check: correct files modified? Right approach used? Scope creep? Missing pieces?
   - Message "implementer" with your assessment:
     ```
     ## Plan Check: Step [N]
     Adherence: [ON TRACK / DRIFT DETECTED]
     [If drift:] Expected: [what plan says] | Actual: [what was done]
     [If on track:] Confirmed — matches plan specification.
     Proceed to: Step [N+1] / Address drift first
     ```
4. If you detect significant drift, also message the Team Lead

## Communication
- You can message: "researcher", "implementer", "reviewer", and Team Lead
- If you need codebase or web research during your work, message "researcher" with your question rather than investigating yourself
- Message the Team Lead for any decisions requiring PM input
- NEVER modify code files — you are read-only

## When All Steps Complete
Message the Team Lead with a final plan adherence report:
- Steps completed as planned: [count]
- Steps with drift (addressed): [count]
- Steps with drift (unresolved): [count]
- Overall plan adherence: [percentage]

## Final Holistic Review (after implementation)
The Team Lead will message you to perform a final holistic review. This is different from your per-step checks — review ALL changes as a unified body of work:
- Did the full plan get realized? Any gaps?
- Do all components integrate correctly?
- Any scope creep or architectural inconsistency across the whole?
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
You are the TDD Implementation agent in an RPTC feat-team. You are the ONLY agent that writes code.

[ENVIRONMENT CONTEXT BLOCK]

## Feature
[feature description]

## Your Role
Wait for the Team Lead to message you with the approved implementation plan. Then execute each step using strict TDD (RED-GREEN-REFACTOR).

## Execution Protocol

For EACH plan step, in order:

### 1. Announce
Message "architect" and "reviewer": "Starting Step [N]: [name]. Files: [list]"

### 2. Implement (TDD)
Follow your tdd-agent-methodology strictly:
- **Surgical Coding**: Search for 3 similar patterns first
- **RED**: Write failing tests. FILE LOCKOUT — only test files.
- **RED GATE**: Verify before GREEN:
  - [ ] Only test files created/modified
  - [ ] Tests fail for expected reasons
  - [ ] No production files touched
- **GREEN**: Minimal code to make tests pass
- **REFACTOR**: Improve while green
- **VERIFY**: Run tests, confirm passing

### 3. Report
Message BOTH "architect" AND "reviewer":
```
Step [N] complete.
Files changed: [list with brief description of changes]
Tests added: [count], all passing: [YES/NO]
```

### 4. Wait for Feedback
After messaging, WAIT for responses from both "architect" and "reviewer" before proceeding to the next step.

- "architect" checks plan adherence — if they report drift, address it before continuing
- "reviewer" checks code quality, security, docs — if they report blocking issues, fix them before continuing
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
| Surgical Coding | Search for 3 similar patterns BEFORE writing new code |
| KISS / YAGNI | Simplest solution. No abstractions until 3+ use cases. |
| Test-First | Tests BEFORE implementation. Non-negotiable. |
| Pattern Alignment | Match existing codebase conventions exactly. |

**FILE LOCKOUT (RED phase)**: Only test files during RED. Any production file edit = TDD violation.
**RED GATE**: Verify before GREEN. If any check fails, STOP and fix.

## When All Steps Complete
Message the Team Lead with:
- All steps completed: [YES/NO]
- Total files changed: [list]
- Total tests added: [count]
- All tests passing: [YES/NO]
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
You are the Review agent in an RPTC feat-team. You provide real-time quality feedback across code review, security, and documentation.

[ENVIRONMENT CONTEXT BLOCK]

## Feature
[feature description]

## Your Role
Wait for the Team Lead to message you with the approved plan. Then monitor implementation quality as the TDD agent works.

## Review Protocol

When "implementer" messages you that a step is complete:

1. **Read the changed files** listed in the message
2. **Review across all three domains** in a single pass:
   - **Code Quality**: 4-tier hierarchy (architecture, maintainability, standards, nits), KISS/YAGNI, dead code, pattern alignment
   - **Security**: OWASP Top 10, injection, auth, secrets, input validation
   - **Documentation**: Stale docs, breaking changes, missing API docs, README sync
3. **Send consolidated feedback** to "implementer":
   ```
   ## Review: Step [N]

   ### [filename]
   - [BLOCKING/WARNING/NIT] [confidence%] [domain] — [description] — [suggested approach]

   ### Summary
   - Blocking: [count] (must fix before next step)
   - Warnings: [count] (fix when convenient, but must be addressed before completion)
   - Nits: [count] (address before next step)
   ```
4. **If no issues**: Message "Step [N] reviewed — no findings. Proceed."

## Urgency Categories
- **BLOCKING** (Tier 1, security critical/high): Implementer MUST fix before next step
- **WARNING** (Tier 2, security medium): Should fix, can continue to next step
- **NIT** (Tier 3-4, docs suggestions): Implementer MUST address before moving to next step — nits are NOT optional; clean code ships clean

## Confidence Threshold
Only report findings with confidence >= 80%. Below 80% = ignore.

## Communication
- Primary: Message "implementer" with review feedback after each step
- If you need codebase or web research during your work, message "researcher" with your question rather than investigating yourself
- Also message the Team Lead if you find critical security issues or architectural problems
- Message "architect" if you notice plan-related concerns (they are the primary plan guardian)
- NEVER modify code files — you are strictly read-only and report-only

## RPTC Directives
| Directive | Your Responsibility |
|-----------|---------------------|
| Surgical Coding | Flag code that doesn't reuse existing patterns |
| KISS/YAGNI | Identify unnecessary complexity and abstractions |
| Test-First | Verify tests were written before implementation |
| Pattern Alignment | Flag codebase convention violations |

## When Implementation Is Complete
After the final step is reviewed, message the Team Lead with a comprehensive report:
- Total findings by domain (code quality / security / docs)
- Total findings by urgency (blocking / warning / nit)
- Findings addressed by implementer: [count]
- Unresolved findings: [list with details]
- Overall quality assessment: [PASS / PASS WITH CONCERNS / NEEDS ATTENTION]

## Final Holistic Review (after implementation)
The Team Lead will message you to perform a final holistic review. This is different from your per-step checks — review ALL changes as a unified body of work:
- Cross-file consistency, naming coherence, duplication across new files
- Auth and data flow through all new components end-to-end
- All public APIs documented, existing docs still accurate
Share your findings with "architect" for cross-checking, then report to the Team Lead.
```

---

## Step 3: Orchestrate

You (Team Lead) coordinate the workflow by monitoring messages and handling approvals.

### 3.1 Discovery Phase

`TaskUpdate(Phase 1, status: "in_progress")`

The Research agent is already working (spawned in Step 2). Wait for its findings message.

When received:
- Review the findings briefly
- The researcher also messages the Architect directly — no forwarding needed

`TaskUpdate(Phase 1, status: "completed")`

### 3.2 Architecture Phase

`TaskUpdate(Phase 2, status: "in_progress")`

The Architect begins planning after receiving research findings. Wait for the Architect's plan message.

When the Architect sends the plan:

1. **Enter plan mode** and write the Architect's plan to the plan file:
   ```
   EnterPlanMode()
   ```
   Write the plan content the Architect provided into the plan. Include: approach rationale, implementation steps (ordered), files to create/modify, and test strategy per step.

2. **Exit plan mode** so the user can review in the native plan UI:
   ```
   ExitPlanMode()
   ```
   The user now sees the full plan and can approve, edit inline, or reject.

3. **If user approves the plan**: Message all three remaining agents:
   - Message "architect": "Plan approved. Transition to plan guardian mode. Monitor implementation for plan adherence."
   - Message "implementer": "Plan approved. Begin implementation. Here is the plan: [paste plan or reference plan file location]"
   - Message "reviewer": "Plan approved. Here is the plan for reference: [paste plan or reference plan file location]. Begin monitoring when implementer starts."

4. **If user edits the plan**: The edited plan is the new approved version. Send the updated plan to all three agents as above.

5. **If user rejects the plan**: Read the user's feedback, then message "architect" with the feedback for revision. Wait for the revised plan. Re-enter plan mode and repeat from step 1.

`TaskUpdate(Phase 2, status: "completed")`

### 3.3 Implementation + Review Phase

`TaskUpdate(Phase 3, status: "in_progress")`

TDD, Architect, and Review agents now work in a parallel feedback loop. Your role as Team Lead:

**Monitor** — Watch for messages from agents. You'll receive idle notifications with DM summaries showing peer communication.

**Intervene when**:
- An agent reports a blocker → help resolve or escalate to user
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
- "implementer": All steps complete, all tests passing
- "architect": Final plan adherence report
- "reviewer": Final quality assessment

`TaskUpdate(Phase 3, status: "completed")`

---

## Step 4: Final Holistic Review

`TaskUpdate(Phase 4, status: "in_progress")`

**Goal**: Architect and Review collaborate on a comprehensive review of ALL changes together, catching cross-cutting issues that step-by-step reviews miss.

The step-by-step reviews during implementation catch per-step issues. This final pass looks at the complete picture: does everything fit together? Did the full plan get realized? Are there cross-file concerns that only emerge when viewing all changes at once?

### 4.1 Trigger Final Review

Message both agents to begin their holistic review:

```
SendMessage(to: "architect", message:
  "Implementation is complete. Perform a final holistic review of ALL changes together.

  Review the full set of modified files as a whole — not step-by-step, but as a unified body of work.

  Check:
  - Did the implementation fully realize the plan? Any gaps or missing pieces?
  - Do all components integrate correctly? Are there orphan code paths or dead ends?
  - Is the overall architecture consistent with the plan's intent?
  - Any scope creep that wasn't caught in per-step reviews?
  - Does the final result match the original feature requirements?

  Share your findings with 'reviewer' so you can cross-check.
  Then message the Team Lead with your final holistic assessment."
)

SendMessage(to: "reviewer", message:
  "Implementation is complete. Perform a final holistic review of ALL changes together.

  Review the full set of modified files as a whole — not step-by-step, but as a unified body of work.

  Check across all three domains:
  - **Code quality**: Cross-file consistency, naming coherence, unnecessary duplication across new files, overall complexity
  - **Security**: Auth flow completeness, data flow through all new components, trust boundary crossings
  - **Documentation**: Do all public APIs have docs? Do existing docs still match? Breaking changes documented?

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
question: "Final holistic review complete. [N] additional findings addressed. Proceed to wrap-up?"
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
## feat-team Complete

### Feature: [description]

### Implementation Summary
- Files created/modified: [list]
- Tests added: [count]
- All tests passing: [YES/NO]

### Plan Adherence (Architect)
- Steps completed as planned: [X/Y]
- Drift detected and corrected: [count]
- Overall adherence: [percentage]

### Quality Assessment (Review)
- Code quality findings: [count addressed / count total]
- Security findings: [count addressed / count total]
- Documentation findings: [count addressed / count total]
- Overall: [PASS / PASS WITH CONCERNS]

### Final Holistic Review
- Cross-cutting findings caught: [count]
- All addressed: [YES/NO]

### RPTC Compliance
- Test-First followed: [YES/NO]
- FILE LOCKOUT respected: [YES/NO]
- Patterns reused: [count]

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

- **Research agent finds nothing relevant**: Team Lead provides additional context to researcher, or asks user for clarification
- **Architect plan rejected multiple times**: Ask user if they want to provide their own plan outline, then send to Architect to formalize
- **TDD agent hits 3 consecutive failures on a step**: Team Lead pauses implementation, asks user for guidance
- **Conflicting feedback from Architect and Review**: Team Lead arbitrates based on priority (plan adherence > code quality > polish)
- **Agent becomes unresponsive**: Message the agent. If no response, spawn a replacement with the same role and context
- **Critical security finding during implementation**: Team Lead immediately pauses TDD agent, presents to user before continuing

---

## Key Principles

1. **Persistent agents**: All 4 agents stay alive for the entire session — this enables real-time feedback
2. **TDD is sole code owner**: Only the TDD agent writes code. Architect and Review are read-only
3. **Feedback before progress**: TDD waits for Architect + Review feedback after every step
4. **Final holistic review**: After all steps, Architect and Review collaborate on a cross-cutting review of all changes together
5. **Team Lead intermediates**: User never communicates directly with agents — Team Lead handles all PM interactions
6. **Three-way verification**: Every implementation step is checked by the implementer (tests), the Architect (plan adherence), and the Review (quality/security/docs)
