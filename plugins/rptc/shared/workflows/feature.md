# Feature workflow contract

## Outcome

Deliver the requested behavior with:

- acceptance predicates tied to the user's request;
- a change that follows the repository's established design where appropriate;
- tests or another executable check at a meaningful seam;
- evidence for every completion claim;
- an explicit record of anything not verified.

## Route by risk

Choose the lightest route that still protects the work.

### Local

Use for mechanical or localized changes that follow an established pattern.

1. Ground the affected area.
2. Make the smallest coherent change.
3. Run the focused project check.
4. Inspect the diff.

### Normal

Use for behavior changes with moderate uncertainty or more than one affected
module.

1. Ground the affected behavior and nearby patterns.
2. State acceptance predicates and the strongest feasible evidence.
3. Resolve only genuine product ambiguity with the user.
4. Design the interface, data shape, ownership, and sequencing when uncertain.
5. Implement in vertical, independently verifiable slices.
6. Run focused checks during implementation and broader affected checks at the
   end.
7. Review request fidelity, correctness risk, and repository fit separately.

### High risk

Use when work is broad, difficult to reverse, weakly observable, or touches
authorization, secrets, money, user data, persistence, deployment, or migration.

Add:

- blast-radius analysis;
- explicit rollback or recovery;
- a baseline or verification harness before the change;
- staged implementation with verification at each boundary;
- independent final verification.

## Design

A plan is a hypothesis. Generate multiple alternatives only when materially
different structures are viable and the choice matters. A localized change that
follows an established pattern does not need an architecture ceremony.

## Testing

Use vertical TDD when behavior is changing and a stable, economical seam exists:

`RED -> minimal GREEN -> next behavior -> RED -> minimal GREEN -> refactor`

Do not write an imagined complete test suite before learning from the first
slice. Do not force a new automated test when the available test would be
brittle, expensive, or less meaningful than a scripted runtime check.

## Completion

Report each acceptance predicate as:

- `VERIFIED`, with the command or artifact and observed result;
- `NOT VERIFIED`, with the failing evidence;
- `INCONCLUSIVE`, with the missing access or unresolved source of truth.

A build or typecheck is evidence for compilation, not automatic evidence that
the feature works.
