---
name: structure-methodology
description: Assess or design codebase structure using module depth, interface size, ownership, dependency direction, locality, and testability. Use for explicit structure audits and non-trivial architecture work.
---

# Structure Methodology

## Vocabulary

- **Module:** an interface plus its implementation.
- **Interface:** everything a caller must know to use the module correctly.
- **Depth:** behavior and decisions hidden behind a comparatively small interface.
- **Seam:** a place where behavior can vary or be tested through an interface.
- **Locality:** related knowledge, change, and verification concentrated together.

## Assessment

Look for evidence that structure increases reader or change cost:

- callers coordinate behavior the module should own;
- the same decision is repeated across files;
- pass-through layers add no compression;
- one change requires shotgun edits;
- public interfaces expose private transport or storage representation;
- tests must bypass the public seam to reach behavior;
- cycles or unclear ownership force hidden coupling;
- speculative abstractions have one consumer or one implementation.

Use repository hotspots and the requested area to focus the audit. Do not score
the whole codebase by arbitrary file or line thresholds.

## Design guidance

Prefer:

- a small interface that hides meaningful decisions;
- ownership aligned with domain behavior, not execution phase;
- dependencies pointing toward stable policy;
- explicit data shapes and invariants;
- one real seam only where behavior varies or a boundary needs substitution;
- tests through the same interface callers use.

Use the deletion test: if removing a module merely spreads its complexity across
callers, the module is earning its place. If complexity disappears, it may be a
pass-through.

## Output

Report concrete candidates with files, current friction, proposed seam,
benefits, migration risk, and verification. Separate strong candidates from
speculative ideas without numeric scoring.
