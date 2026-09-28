---
description: Reproduce, diagnose, fix, and verify a bug on the same observable surface
allowed-tools: Bash(git worktree add *), Bash(npm test *), Bash(npm run *), Bash(pnpm test *), Bash(pnpm run *), Bash(yarn test *), Bash(yarn run *), Bash(bun test *), Bash(bun run *), Bash(pytest *), Bash(python -m pytest *), Bash(uv run pytest *), Bash(cargo test *), Bash(cargo build *), Bash(cargo check *), Bash(cargo clippy *), Bash(go test *), Bash(go build *), Bash(go vet *), Bash(dotnet test *), Bash(dotnet build *), Read, Write, Edit, Glob, Grep, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion, EnterPlanMode, ExitPlanMode
---

# /rptc:fix

Shared contract: `shared/workflows/fix.md`

Fix a reported defect through reproduction and evidence. Claude owns the
Claude-specific task, planning, and delegation mechanics.

## Arguments

`/rptc:fix "<bug description>"`

Use `/rptc:fix-team` when a reproduction exists but several plausible
mechanisms remain and Claude agent teams are enabled; it runs competing
investigators before this flow's fix steps.

## 1. Initialize

Load:

```text
Skill("rptc:core-principles")
Skill("rptc:diagnose-methodology")
Skill("rptc:verification-evidence")
```

Load conditionally:

```text
rptc:tdd-methodology        a practical regression-test seam exists
rptc:architect-methodology  interfaces, ownership, or sequencing remain unresolved
rptc:brainstorming          a genuine product decision remains
rptc:unslop-writing-clearly substantial prose, documentation, or user-facing copy
```

Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/fix.md` and the project's own
instructions and checks.

Do not create the full task structure before reproduction establishes the shape
of the work. For a narrow correction, track work only when it protects a real
dependency or unfinished item. For broader or high-risk fixes, keep the
remaining diagnosis, implementation, and verification work visible.

## 2. Reproduce

Start from the user's actual symptom. Drive the closest available surface and
produce one repeatable failing command or interaction.

Make the loop fast and deterministic. Minimize it when that narrows the search.

When reproduction is blocked, state the exact missing environment or access.
Do not replace the missing signal with a root-cause claim.

Parallel research is allowed only for distinct evidence sources. The parent
owns the live reproduction and final mechanism.

## 3. Diagnose

Use `rptc:diagnose-methodology`.

List falsifiable mechanisms. Instrument or change one variable at a time.
Prefer the observation that eliminates the most possibilities.

Separate direct evidence from inference. Confirm the surviving mechanism before
planning the fix.

## 4. Design only when needed

Skip Plan Mode for a clear localized correction.

Execution breadth alone does not require Plan Mode. Enter Plan Mode when interfaces, ownership, sequencing, migration, rollback, or consequential competing approaches remain unresolved.

Use one recommended fix design. Add alternatives only when the choice is real.
The user decides product behavior and consequential trade-offs.

When the fix will span many turns, offer a ready-to-paste `/goal <condition>`
as the shared contract's long-running work section describes. Keep it under
4,000 characters and recommend running it in auto mode for unattended turns.
Claude's goal evaluator reads only the transcript and runs no commands, so
print each check's result.

## 5. Implement the supported fix

When a practical regression seam exists, load `rptc:tdd-methodology` and show
the failing-before signal before changing production code.

Apply the smallest coherent production change supported by the diagnosis.
Remove speculative guards, abandoned attempts, and temporary instrumentation.

Delegate bounded edits only with exclusive ownership. Inspect the actual diff
and run the focused check after each slice.

## 6. Verify

Rerun:

1. the minimized reproduction;
2. the original user reproduction on the same surface;
3. nearby affected project checks;
4. selected independent review.

Use independent review when it tests a distinct unresolved risk. Require independent final verification for high-risk fixes. Use security review when a trust boundary changed and documentation review when public or operational behavior changed.

Act on blocking and should-fix findings that affect correctness, the request,
security, or a documented rule; list optional findings without acting on them.
Rerun the affected evidence. Do not chase zero LLM findings.

## 7. Complete

Report:

- original symptom;
- confirmed mechanism and evidence;
- fix;
- failing-before and passing-after commands or observations;
- adjacent checks;
- reviews;
- each material claim as `VERIFIED`, `NOT VERIFIED`, or `INCONCLUSIVE`.

Do not commit, push, create a pull request, or deploy unless the user explicitly
requests it.
