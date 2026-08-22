# `update_plan` guide

Use `update_plan` to keep long RPTC flows visible and resumable in Codex.

## Plan shape

Keep the flow's top-level phases visible for the whole run. Codex plans are
flat, so prefix child items with their parent phase:

```text
Phase 1: Ground and classify
Phase 2: Define acceptance and evidence
Phase 3: Design when needed
Phase 4: Implement verified slices
Phase 4.1: Add failing parser behavior
Phase 4.2: Implement parser behavior
Phase 5: Verify and summarize
```

Do not replace the top-level phase list with an unrelated list of edits.

## State rules

- Use `pending`, `in_progress`, and `completed`.
- Keep only one item `in_progress`.
- Mark an item completed when its evidence exists, not when work merely started.
- Add a child item only when it helps the user understand a meaningful unit,
  blocker, finding, or recheck.
- Mark intentionally skipped work clearly rather than pretending it ran.

## Delegation

The parent session owns the plan.

When a flow uses `spawn_agent`:

1. mark the delegated item `in_progress`;
2. spawn the bounded agent with a clear scope and output contract;
3. immediately call `wait_agent`;
4. do not edit, test, or synthesize in the parent while the required agent runs;
5. inspect the returned artifact;
6. update the matching plan item before starting the next unit.

Parallel agents may share one parent phase when their work is independent.
Wait for every required result before synthesizing.

## Planning questions

`request_user_input` is available only in Codex Plan Mode. Confirm Plan Mode
before using it. Outside Plan Mode, ask in normal chat and stop for the answer.

Investigate repository and runtime facts instead of turning them into user
questions.

## Recovery

After interruption or compaction:

1. read the latest visible plan;
2. inspect current files, git state, and command evidence;
3. verify completed claims before preserving their status;
4. resume the active or next pending item;
5. avoid duplicate tasks.

The plan is operational state, not the source of truth for whether work exists
or works.
