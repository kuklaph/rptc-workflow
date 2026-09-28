---
name: diagnose-methodology
description: Reproduce and diagnose a reported bug, regression, flake, crash, or performance problem whose cause is not proven. Use when behavior is broken, intermittent, or slow. Skip when an existing failing check already isolates a known mechanical fix.
---

# Diagnose Methodology

Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/fix.md` and follow its procedure.

## When the symptom does not reproduce

- drive the closest available real surface;
- tighten the triggering conditions;
- add temporary instrumentation;
- state exactly what remains inaccessible.

Do not replace a missing reproduction with a confident theory.

## Narrowing the cause

Choose the next observation that eliminates the most possibilities. Record what
each observation supports or rejects, and report direct evidence separately from
inference.
