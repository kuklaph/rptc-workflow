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

## Planning

Use a formal plan only when the fix changes interfaces, crosses several modules,
requires migration or rollback, or has meaningful competing approaches. A clear
localized fix should not wait for a planning ceremony.

## Test-first behavior

When a cheap test seam exists, demonstrate failing-before and passing-after
behavior. When it does not, state why and use the closest executable regression
check available.

Never weaken a valid test merely to make it agree with current production code.

## Completion

Report:

- the original symptom;
- the confirmed mechanism;
- the fix;
- failing-before evidence when available;
- passing-after evidence from the same surface;
- adjacent checks;
- unresolved or inconclusive claims.
