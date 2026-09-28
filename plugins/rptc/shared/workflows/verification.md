# Verification workflow contract

## Purpose

Verification evaluates claims about a change. It does not attempt to produce a
stochastic state in which reviewers happen to report zero findings.

## Evidence levels

Use the strongest feasible evidence for each claim:

1. static checks such as parsing, schema validation, typechecking, and build;
2. focused behavior checks through the chosen seam;
3. integration checks against real boundaries;
4. runtime checks on the user-facing surface;
5. production-like checks such as a dry run, trace, migration rehearsal, or
   staging observation;
6. independent review of the exact diff and evidence.

A weaker level does not prove a stronger claim.

## Review axes

Keep findings separate:

- **Request fidelity:** missing, partial, incorrect, or unrequested behavior.
- **Correctness and risk:** executable failure paths, integration gaps, unsafe
  assumptions, blast-radius concerns, tests edited, removed, or weakened by the
  change, and implementation that special-cases test inputs.
- **Repository fit:** documented convention violations, inconsistent local
  patterns, unnecessary abstractions, and maintainability concerns.
- **Documentation impact:** public behavior or operational procedures that must
  be documented.
- **Security impact:** changed trust boundaries, authorization, input handling,
  secret handling, dependency assumptions, or sensitive data paths.

Rate each finding:

- **blocking:** breaks the request, correctness, or security;
- **should-fix:** violates a documented rule or leaves a real risk;
- **optional:** an improvement.

A finding must cite a location plus evidence or a documented rule. Numerical
model confidence is not evidence.

An axis with no findings reports `No findings`; that is a normal result.

Reviewers report every evidence-backed finding; the parent decides what to act
on. Act on blocking and should-fix findings that affect correctness, the
request, security, or a documented rule. List optional findings without acting
on them. In a report-only pass, mark those findings as requiring action instead
of fixing them.

## Recheck loop

After accepted fixes, rerun:

1. the checks affected by the fix;
2. the original acceptance predicates;
3. the review axis that produced the finding.

Stop when every accepted fix has been applied and rechecked, and each remaining
claim is `VERIFIED`, or `NOT VERIFIED` / `INCONCLUSIVE` with a stated reason the
loop cannot resolve it (declined, blocked, or awaiting a product decision). Do
not loop solely to obtain an empty reviewer response.

## Status language

- `VERIFIED`: the stated predicate passed through the named observation.
- `NOT VERIFIED`: the predicate failed.
- `INCONCLUSIVE`: the available environment or authority could not resolve it.
