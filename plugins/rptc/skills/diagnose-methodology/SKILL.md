---
name: diagnose-methodology
description: Reproduce and diagnose a reported bug, regression, flake, crash, or performance problem whose cause is not proven. Use when behavior is broken, intermittent, or slow. Skip when an existing failing check already isolates a known mechanical fix.
---

# Diagnose Methodology

Read `RPTC plugin root/shared/workflows/fix.md`.

## Tight feedback loop

Before proposing a cause, establish one command or controlled interaction that
reproduces the user's symptom. Make it fast and deterministic enough to run
repeatedly.

If the symptom does not reproduce:

- drive the closest available real surface;
- tighten the triggering conditions;
- add temporary instrumentation;
- state exactly what remains inaccessible.

Do not replace a missing reproduction with a confident theory.

## Hypotheses

After the loop is trustworthy:

1. List plausible mechanisms.
2. Prefer the next observation that eliminates the most possibilities.
3. Change one variable at a time.
4. Record what each observation supports or rejects.
5. Confirm the surviving mechanism before designing the fix.

## Fix and proof

Apply only the change justified by the evidence. Remove speculative changes and
temporary instrumentation. Rerun both the minimized loop and the original
reported reproduction.

Report direct evidence separately from inference.
