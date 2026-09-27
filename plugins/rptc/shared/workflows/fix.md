# Bug-fix workflow contract

## Outcome

Produce:

- a repeatable reproduction of the reported symptom;
- an evidence-supported root cause;
- the smallest justified fix;
- durable regression protection when practical;
- proof that the original symptom no longer occurs.

## Procedure

1. Reproduce the user's actual symptom on the closest available surface.
2. Turn the symptom into one fast, deterministic feedback loop.
3. Minimize the reproduction when doing so reduces the search space.
4. Form falsifiable hypotheses only after the reproduction is trustworthy.
5. Instrument or change one variable at a time.
6. Confirm the surviving mechanism with runtime or executable evidence.
7. Fix the cause supported by that evidence. Revert speculative changes.
8. Add regression protection at a stable seam when it provides durable value.
9. Rerun the original, unminimized reproduction.
10. Run the repository's affected checks and remove temporary instrumentation.

For a localized defect with an obvious reproduction and correction, do not add a
multi-phase task structure solely to mirror this procedure.

## Planning

Execution complexity does not by itself require a design decision. Use a formal
plan only when the fix changes interfaces, has uncertain ownership or
sequencing, requires migration or rollback, or has meaningful competing
approaches. A clear localized fix should not wait for a planning ceremony.

## Test-first behavior

When a cheap test seam exists, demonstrate failing-before and passing-after
behavior. When it does not, state why and use the closest executable regression
check available.

Never weaken a valid test merely to make it agree with current production code.

Reuse still-valid evidence from the current code state. Repeat a check when a
subsequent edit could invalidate it, not simply because the workflow moved to a
new phase.

## Long-running work

When a trustworthy reproduction exists and the diagnosis or fix will span many
turns, offer the user a goal condition as described in the feature contract.
Build it from the original reproduction passing on the same surface, the
regression check passing, and the affected project checks passing, plus the
constraints that must hold.

## Completion

Continue through the passing reproduction and affected checks unless an actual
approval, access, environment, or product decision blocks progress.

Report:

- the original symptom;
- the confirmed mechanism;
- the fix;
- failing-before evidence when available;
- passing-after evidence from the same surface;
- adjacent checks;
- unresolved or inconclusive claims.
