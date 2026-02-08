---
name: agent-teams
description: Agent Teams execution mode for RPTC. Load when /rptc:feat or /rptc:fix receives multiple tasks, a batch of work, or when the user mentions "team," "parallel," "sprint," or "batch." Orchestrates Agent Teams creation with full RPTC discipline. Also load when the user explicitly asks to use Agent Teams for any development task.
---

# RPTC Agent Teams Mode

This skill adds Agent Teams as a first-class execution path in RPTC. When a task
(or set of tasks) benefits from parallel independent sessions, this skill handles
team creation, RPTC-compliant spawn prompts, file ownership, approval flow, and
completion integration.

Agent Teams are independent Claude Code sessions coordinating via a shared task
list and peer-to-peer inbox messaging. Each teammate gets its own context window,
automatically loads the project's CLAUDE.md, MCP servers, and `.claude/skills/`.

## Where This Fits in RPTC

**Compatibility**: RPTC v2.33.2+. This skill relies on test-first enforcement
gates (FILE LOCKOUT, RED GATE, exit block verification) introduced in v2.33.2.
Spawn prompts embed these enforcement mechanisms so teammates follow them even
when running outside the full plugin context.

This skill activates during **Phase 1 (Discovery)** of `/rptc:feat` or
`/rptc:fix`, after understanding the scope of work. It introduces a routing
decision before Phase 2:

```
Step 0: Initialization (load skills including this one)
Phase 1: Discovery → TEAMS ANALYSIS ← (this skill)
  ├─ Single-task, no teams benefit → Continue standard RPTC (Phases 2-5)
  └─ Teams benefit detected → TEAMS MODE (this skill orchestrates)
       ├─ Create team with RPTC-compliant spawn prompts
       ├─ Assign tasks with file ownership boundaries
       ├─ Teammates execute their RPTC flows
       ├─ Team Lead coordinates approvals + integration
       └─ Team Lead runs final verification → Phase 5
```

When teams mode activates, the Team Lead (main session) becomes the orchestrator.
It does not run its own Phase 2-4 — instead it manages teammates who each run
their own RPTC phases at the appropriate autonomy level.

---

## Teams Analysis

**Recursion Guard (MANDATORY)**:
1. Check: Were you spawned as a teammate? (Your initial context includes a spawn
   prompt from a Team Lead, you received your task via inbox, or your task
   description mentions file ownership boundaries.)
2. If YES → **STOP**. Do NOT run Teams Analysis. Do NOT spawn teammates. Do NOT
   create agent teams. Proceed directly to Phase 2. You are a teammate — only
   the Team Lead creates teams.
3. If NO → Continue with Teams Analysis below.

Run this analysis after Phase 1 Discovery completes. Evaluate three signals:

### Signal 1: Multiple Independent Work Streams

The strongest signal for teams. Look for:
- User described multiple distinct features, bug fixes, or tasks
- Work can be split into streams that don't share files
- Each stream is substantial enough to justify its own session (>10 min of work)

**Examples that qualify:**
- "Add auth, build dashboard, create API v2" (3 independent features)
- "Fix the login bug, the cart bug, and the notification bug" (3 independent fixes)
- "Implement steps 1-3 from our sprint plan" (multiple planned items)

**Examples that don't qualify:**
- "Add user authentication" (single feature, even if complex)
- "Fix the race condition in checkout" (single bug)
- "Refactor the data layer" (single concern, even if touching many files)

### Signal 2: Cross-Agent Debate Would Help

Less common, but valuable when different perspectives need to actively challenge
each other — not just report independently (RPTC Phase 4 already does parallel
independent reports).

Debate adds value for:
- Mystery debugging with multiple plausible root causes
- Architecture decisions where trade-offs are genuinely contested
- Security vs. performance tension that needs adversarial exploration

### Signal 3: User Explicitly Requested Teams

If the user says "use a team," "run these in parallel," "use agent teams," or
similar — respect the request. Still perform the analysis to determine autonomy
levels, but don't override their intent.

### Decision

| Signals | Route |
|---------|-------|
| No signals → | Standard RPTC (stop here, continue Phases 2-5 normally) |
| Signal 1 (multiple independent streams) → | Teams mode, continue below |
| Signal 2 only (debate for single task) → | Teams mode with debate pattern (see reference) |
| Signal 3 (user requested) → | Teams mode, continue below |

If routing to standard RPTC, this skill has no further role. The rest of this
document covers teams mode orchestration.

---

## Autonomy Level Determination

Before creating the team, determine how much RPTC each teammate runs
independently. This depends on how independent the tasks are.

### Level A: Full Autonomy (Each Teammate Runs Complete RPTC)

**When**: Tasks are fully independent — different features, different file sets,
no shared dependencies.

Each teammate runs the complete flow: Discovery → Architecture → Implementation
→ Quality Review → Complete. The Team Lead only coordinates task assignment,
collects results, and runs final integration verification.

**Approval handling**: Pre-authorize plan selection (Pragmatic default) and
high-confidence quality fixes (≥90%) in the spawn prompt. Teammates flag
low-confidence findings (80-89%) in their completion message for PM review.

### Level B: Shared Planning, Independent Implementation

**When**: Tasks relate to the same feature area but implementation is
parallelizable. The Team Lead should run Discovery and Architecture centrally
(to ensure a coherent plan), then spawn teammates for parallel TDD execution
of independent plan steps.

Team Lead runs: Phase 1 (Discovery) + Phase 2 (Architecture) → user approves plan
Teammates run: Phase 3 (Implementation) + report findings
Team Lead runs: Phase 4 (Quality Review) + Phase 5 (Complete)

**Approval handling**: User approved the plan already. Teammates execute assigned
steps and report back. Team Lead consolidates and runs quality review.

### Level C: Debate / Review Only

**When**: Using teams for adversarial review, competing debug hypotheses, or
architecture debate. No teammate runs the standard RPTC phases — they operate
as focused specialists.

Team Lead runs RPTC normally through Phase 3, then spawns review teammates with
specific debate prompts instead of (or in addition to) standard Phase 4 agents.

### Choosing the Level

| Scenario | Level | Reasoning |
|----------|-------|-----------|
| 3 independent features | A | Fully separate streams |
| 5 independent bug fixes | A | Each fix is self-contained |
| Complex feature, 6+ plan steps, parallelizable | B | Coherent plan, parallel execution |
| Cross-layer feature (FE + BE + DB) with shared API contract | B | Need unified architecture, separate impl |
| Mystery bug, 3 theories | C | Debate pattern |
| Security-focused deep review of completed work | C | Specialist review |

---

## Team Creation Procedure

After determining the autonomy level, create the team.

### Step 1: Define File Ownership

Before spawning any teammate, map out which files/directories each will own.
This is non-negotiable — Agent Teams have no file locking. Last write wins.

Read `references/team-lifecycle.md` § File Ownership for strategies and
enforcement patterns.

Rules:
- Every file that will be modified must have exactly one owner
- Shared files (router, index, config) get a designated owner or the Team Lead
  handles integration after teammates complete
- Include ownership boundaries in every spawn prompt
- If clean ownership boundaries can't be drawn, reconsider whether teams mode
  is appropriate — you might need Level B instead of Level A

### Step 2: Build Spawn Prompts

Each teammate gets a spawn prompt that embeds their RPTC operating context.
Read `references/spawn-prompts.md` for ready-to-use templates by autonomy level.

Every spawn prompt includes:
1. **Task assignment**: What specifically to build/fix
2. **RPTC directives**: Surgical Coding, KISS/YAGNI, Test-First, Pattern Alignment
3. **Autonomy instructions**: Which RPTC phases to run and how
4. **File ownership**: Explicit list of files/directories they own and must not touch
5. **Approval pre-authorization**: Plan selection default and quality fix thresholds
6. **Completion protocol**: What to report and how to signal done

### Step 3: Create the Team

Ask the user for confirmation before creating the team. Present:
- Number of teammates and their assignments
- Autonomy level and reasoning
- File ownership map
- Estimated cost impact (each teammate ≈ 5x tokens vs. a subagent)

Use natural language to request team creation:
```
Create an agent team called "[project]-[scope]" with [N] teammates:
- [teammate-1-name]: [assignment summary]
- [teammate-2-name]: [assignment summary]
```

### Step 4: Monitor and Coordinate

While teammates work:
- Track progress via the shared task list
- Watch for inbox messages (especially low-confidence findings that need PM input)
- If a teammate gets stuck or goes off-track, send corrective messages via inbox
- If teammates need to coordinate on shared boundaries, mediate via inbox

### Step 5: Integration and Verification

After all teammates complete:

1. **Collect completion reports** from each teammate
2. **Run full test suite** from the Team Lead session to catch integration issues
3. **Review low-confidence findings** that teammates flagged — present to user
4. **Handle shared file integration** if any teammate wrote to temp files for
   shared-file protocol
5. **Shut down teammates** — don't leave idle sessions accumulating cost
6. **Proceed to Phase 5** (Complete) with a unified summary covering all teammates

---

## Approval Flow

RPTC's PM approval gates are the biggest coordination challenge with teams.
Here's how this skill handles them:

### Pre-Authorized (Embedded in Spawn Prompts)

| Gate | Pre-Authorization |
|------|-------------------|
| Plan approach selection | Choose Pragmatic unless clearly inappropriate |
| Plan approval | Approve and proceed (teammate's own plan for their scope) |
| High-confidence quality findings (≥90%) | Auto-fix, report in completion summary |

### Batched to PM via Team Lead

| Gate | Batching Strategy |
|------|-------------------|
| Low/medium-confidence findings (80-89%) | Teammate includes in completion message → Team Lead collects all → presents batch to user |
| Architectural concerns or scope questions | Teammate messages Team Lead → Lead escalates to user |
| Blocked/stuck teammates | Team Lead detects via task list, escalates to user |

The user never receives approval requests directly from teammates. The Team Lead
is always the intermediary, keeping the PM experience organized.

---

## When NOT to Use Teams

Even when signals are present, skip teams mode if:

- **Clean file ownership is impossible**: If all tasks modify the same core files,
  parallel editing will cause conflicts. Use standard RPTC with sequential execution.
- **Tasks are trivially small**: If each task is <5 minutes of work, teammate
  startup overhead exceeds the time saved. Use standard RPTC.
- **Only 1-2 tasks**: Teams overhead isn't worth it. Standard RPTC handles 1-2
  tasks efficiently via smart batching.
- **Deep shared context needed**: If understanding one task requires the full
  context of another, teammates working in isolation will miss critical connections.
  Use standard RPTC where the main session maintains full context.
- **Budget constrained**: Each teammate ≈ 5x token cost of a subagent. For
  3 teammates, that's roughly 15x the cost of standard subagent delegation.

---

## Reference Documents

Read these when executing teams mode — they contain the templates and detailed
procedures that this skill references:

| Document | When to Read | Contents |
|----------|-------------|----------|
| `references/spawn-prompts.md` | Step 2 (building spawn prompts) | Ready-to-use templates for Level A, B, and C autonomy. RPTC directive blocks, approval pre-auth language, completion protocols |
| `references/team-lifecycle.md` | Steps 1, 4, 5 (ownership, monitoring, integration) | File ownership strategies, hook-based enforcement, shared file protocol, monitoring patterns, shutdown procedures, cost guidance |
