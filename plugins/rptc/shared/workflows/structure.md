# Structure workflow contract

## Outcome

Identify concrete structural friction in the requested area and propose
refactors that improve ownership, interface depth, dependency direction,
locality, or testability.

## Procedure

1. Scope the audit to the user's area or recent repository hotspots.
2. Read public seams, callers, tests, and dependency paths.
3. Find friction supported by actual navigation or change cost.
4. Apply the deletion test and reader-load test.
5. Report a small set of candidates with evidence, risk, and verification.
6. Recommend one candidate when a clear winner exists.
7. Do not modify code unless the user starts a separate implementation flow.

Avoid whole-codebase scoring, arbitrary thresholds, and theoretical refactors
without a current source of friction.
