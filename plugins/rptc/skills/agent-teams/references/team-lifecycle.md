# Team Lifecycle Management

Operational procedures for running an RPTC Agent Team from creation through
shutdown. Covers file ownership enforcement, hook-based quality gates,
monitoring patterns, integration after completion, and cost management.

---

## Table of Contents

1. File Ownership Strategies
2. Shared File Protocol
3. Hook-Based Quality Gates
4. Monitoring Active Teammates
5. Integration After Completion
6. Shutdown and Cleanup
7. Cost Awareness

---

## 1. File Ownership Strategies

Agent Teams have no file locking. If two teammates edit the same file, the last
write wins silently. Ownership is your only defense.

### Strategy A: Directory-Based

Cleanest approach. Each teammate owns entire directories.

```
Teammate "auth":      src/auth/**, tests/auth/**
Teammate "dashboard": src/dashboard/**, tests/dashboard/**
Teammate "api":       src/api/v2/**, tests/api/**
```

Works well for: feature-based project structure, microservices, modular codebases.

### Strategy B: Feature-Based

When features cut across directories, assign by feature scope.

```
Teammate "user-profile": src/models/user.ts, src/routes/profile.ts,
                         src/components/ProfileCard.tsx, tests/profile/**
Teammate "notifications": src/models/notification.ts, src/routes/notify.ts,
                          src/components/NotifyBanner.tsx, tests/notifications/**
```

Works well for: features that touch multiple layers but are otherwise independent.

### Strategy C: Layer-Based (Level B)

When the Team Lead planned centrally, split by architectural layer.

```
Teammate "frontend":  src/components/**, src/pages/**, tests/ui/**
Teammate "backend":   src/api/**, src/services/**, tests/api/**
Teammate "data":      src/models/**, src/migrations/**, tests/models/**
```

Works well for: cross-layer features where the plan defines clean layer boundaries.

### Choosing a Strategy

Pick the strategy where ownership boundaries are most natural for your project
and task. The key test: can you draw clear lines where no file appears in two
teammates' ownership lists? If not, you need the shared file protocol.

---

## 2. Shared File Protocol

Some files inevitably need multiple teammates' contributions: route registrations,
index exports, shared configs, migration sequences.

### Option A: Designate a Single Owner

One teammate (or the Team Lead) owns the shared file. Other teammates message
their needed changes via inbox.

```
Shared files owned by Team Lead:
- src/routes/index.ts
- src/index.ts
- package.json (dependency additions)
```

Teammates include in their completion report:
```
Shared file changes needed:
- src/routes/index.ts: Add `import { profileRoutes } from './profile'`
  and register at line ~45
```

Team Lead applies all shared-file changes during integration (§ 5).

### Option B: Temp File Handoff

Teammates write their additions to temp files that the owner merges.

```
Teammate "auth" writes: _teammate-auth-routes.ts
Teammate "dashboard" writes: _teammate-dashboard-routes.ts
Team Lead merges both into: src/routes/index.ts
```

This is more explicit but creates cleanup work. Use when additions are complex
enough that inbox messages wouldn't capture them well.

### Option C: Sequential Access

If two teammates need the same file and the changes are order-dependent,
structure the task list with dependencies so one finishes before the other starts.

```
Task 1: "Implement user model" (teammate-A) → modifies src/models/user.ts
Task 2: "Add profile fields to user model" (teammate-B, depends on Task 1)
```

The task list's dependency tracking auto-unblocks Task 2 when Task 1 completes.

---

## 3. Hook-Based Quality Gates

Agent Teams support two hook events for programmatic enforcement. These run
automatically — no teammate cooperation required.

### TeammateIdle Hook

Fires when a teammate is about to go idle. Return exit code 2 to reject with
feedback, keeping the teammate working.

Use for:
- Verifying assigned tasks are actually marked complete in the task list
- Checking that tests exist for new code
- Ensuring completion report was sent to Team Lead

### TaskCompleted Hook

Fires when a task is marked complete. Return exit code 2 to reject, forcing
the teammate to address the issue.

Use for:
- Running the test suite (reject if tests fail)
- Checking coverage thresholds (reject if new code below 80%)
- Validating no debug code in changed files
- Verifying conventional commit readiness
- Checking file ownership compliance (reject if files outside boundary were modified)
- Verifying test-first ordering (test file timestamps before production files)

### Example Hook: RPTC Quality Gate

Place in `.claude/hooks/` at the project level. All teammates inherit it.

```javascript
// .claude/hooks/rptc-team-quality-gate.mjs
import { execSync } from 'child_process';

export default async function({ task, event }) {
  const errors = [];

  // 1. Tests must pass
  try {
    execSync('npm test 2>&1', { encoding: 'utf-8', timeout: 120000 });
  } catch (e) {
    errors.push('Tests failing:\n' + (e.stdout || e.message).slice(0, 500));
  }

  // 2. No debug code in staged/modified files
  try {
    const debug = execSync(
      'git diff --name-only HEAD | xargs grep -ln "console\\.log\\|debugger" 2>/dev/null || true',
      { encoding: 'utf-8' }
    );
    if (debug.trim()) {
      errors.push('Debug code found in:\n' + debug.trim());
    }
  } catch (e) { /* no matches is fine */ }

  // 3. Coverage check (if configured)
  try {
    const result = execSync('npm run test:coverage -- --json 2>/dev/null',
      { encoding: 'utf-8', timeout: 120000 });
    const report = JSON.parse(result);
    if (report?.total?.lines?.pct < 80) {
      errors.push(`Coverage at ${report.total.lines.pct}% — minimum is 80%`);
    }
  } catch (e) { /* coverage not configured, skip */ }

  // 4. Test-first ordering check (test files should be committed before source)
  try {
    const log = execSync(
      'git log --diff-filter=A --name-only --format="%H" HEAD~5..HEAD 2>/dev/null || true',
      { encoding: 'utf-8' }
    );
    // Basic heuristic: if new source files exist without corresponding test files,
    // flag for review (full enforcement is in tdd-agent's RED GATE)
    const newFiles = log.split('\n').filter(f => f && !f.match(/^[0-9a-f]{40}$/));
    const sourceFiles = newFiles.filter(f => !f.match(/test|spec|__tests__/i) && f.match(/\.(ts|js|py|go|rs)$/));
    const testFiles = newFiles.filter(f => f.match(/test|spec|__tests__/i));
    if (sourceFiles.length > 0 && testFiles.length === 0) {
      errors.push('New source files added without corresponding test files');
    }
  } catch (e) { /* git not available or no history, skip */ }

  if (errors.length > 0) {
    return {
      exitCode: 2,
      feedback: 'RPTC quality gate failed:\n\n' + errors.join('\n\n') +
        '\n\nFix these issues and mark the task complete again.'
    };
  }

  return { exitCode: 0 };
}
```

Hooks provide a hard enforcement floor that doesn't depend on teammates
following instructions. Even if a teammate skips TDD, the hook catches
failing tests or missing coverage at the completion boundary.

---

## 4. Monitoring Active Teammates

While teammates work, the Team Lead monitors progress and intervenes when needed.

### What to Watch

- **Task list**: Check for tasks stuck in `in_progress` for too long
- **Inbox messages**: Teammates message when blocked, when they find
  cross-cutting concerns, or when they have low-confidence findings
- **Teammate output**: In in-process mode (Shift+Up/Down), scan teammate
  activity for signs of going off track

### When to Intervene

| Signal | Action |
|--------|--------|
| Teammate working on wrong files | Send inbox message redirecting to correct scope |
| Teammate stuck on test failures >10 min | Send hint or adjust assignment |
| Teammate discovers plan needs changing | Escalate to user for plan amendment |
| Two teammates messaging about same issue | Mediate — clarify ownership or adjust scope |
| Teammate idle but tasks remain | Check task list, reassign if needed |

### Delegate Mode

Activate with `Shift+Tab`. Locks the Team Lead into pure orchestration — can
only spawn teammates, manage tasks, send/receive messages, and shut down
teammates. Cannot write code directly.

Use when: 3+ active teammates and you want to prevent the lead from getting
pulled into implementation work. Skip when the lead also needs to do integration
or handle shared files.

---

## 5. Integration After Completion

After all teammates mark their tasks complete:

### Step 1: Collect Completion Reports

Gather all completion messages from teammate inboxes. Each should include:
files changed, tests added, coverage, findings needing PM review, concerns.

### Step 2: Integrate Shared Files

If using the shared file protocol:
- Apply all shared-file changes in a sensible order (imports first, then registrations, then config)
- Resolve any conflicts between teammates' requested changes
- Run the test suite after each shared-file integration to catch issues early

### Step 3: Run Full Test Suite

From the Team Lead session:
```bash
npm test          # or project's test command
npm run lint      # if available
```

This catches integration issues that individual teammate tests wouldn't find:
- Import path conflicts
- Duplicate registrations
- Missing shared dependencies
- Type conflicts across boundaries

If tests fail, diagnose whether it's an integration issue (Team Lead fixes)
or a teammate's incomplete work (message them to fix).

### Step 4: Present Low-Confidence Findings to PM

Collect all 80-89% confidence findings that teammates flagged. Present them to
the user as a consolidated batch:

```
Team implementation complete. The following findings were flagged for your review:

From [teammate-1] (feature: [name]):
- [finding] — [file:line] — confidence: [X]%

From [teammate-2] (feature: [name]):
- [finding] — [file:line] — confidence: [X]%

Would you like to address any of these, or proceed to commit?
```

### Step 5: Proceed to Phase 5 (Complete)

Generate a unified summary covering all teammates' work:
- Total files created/modified (across all teammates)
- Total tests added
- Key implementation decisions from each teammate
- Any remaining items or known issues
- Ready for `/rptc:commit`

---

## 6. Shutdown and Cleanup

After integration and Phase 5:

1. **Shut down all teammates** — idle teammates accumulate token cost
2. **Delete temp files** from shared file protocol (`_teammate-*` files)
3. **Clean up task list** — verify all tasks marked complete
4. **Remove any hooks** that were team-specific (if you added temporary ones)

---

## 7. Cost Awareness

Agent Teams are significantly more expensive than RPTC's standard subagent model
because each teammate maintains its own full context window.

### Rough Comparisons

| Mode | Typical Cost per Feature |
|------|------------------------|
| Standard RPTC (`/rptc:feat`, subagents) | $0.50 – $2.00 |
| Agent Teams, 2 teammates (Level A) | $2.00 – $6.00 |
| Agent Teams, 3 teammates (Level A) | $3.00 – $10.00 |
| Agent Teams, 5 teammates (Level A) | $5.00 – $20.00+ |
| Agent Teams, Level B (lead plans, teammates implement) | $2.00 – $8.00 |
| Agent Teams, Level C (review/debate only) | $1.00 – $4.00 |

### Cost-Conscious Practices

- **Minimum viable team**: 2-3 focused teammates beats 5 unfocused ones
- **Shut down promptly**: An idle teammate still has context loaded
- **Level B saves cost**: Team Lead handles Discovery + Architecture once,
  instead of each teammate duplicating that work
- **Don't team small tasks**: If a task takes <10 minutes solo, teammate
  startup overhead exceeds the time savings
- **Pre-authorize approvals**: Eliminates back-and-forth rounds that consume
  tokens on both lead and teammate sides
