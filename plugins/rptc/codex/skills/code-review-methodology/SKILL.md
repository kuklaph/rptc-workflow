---
name: code-review-methodology
description: Review a change against the request, concrete correctness risks, and the repository's documented standards. Use for diffs, branches, pull requests, and RPTC verification.
---

# Code Review Methodology

Review the exact diff against a fixed point when available.

## Axis 1: Request fidelity

Report separately:

- missing or partial requirements;
- behavior implemented incorrectly;
- unrequested scope;
- missing or unavailable specification.

Cite the requirement or state that no usable specification exists.

## Axis 2: Correctness and risk

Report concrete execution paths involving:

- logic errors and edge cases;
- integration gaps and orphaned entry points;
- unsafe state or concurrency;
- error handling that loses necessary information;
- performance regressions supported by a plausible workload;
- tests that fail to protect the changed behavior.

A finding needs a location and a failure path, command, or direct code argument.

## Axis 3: Repository fit

Check documented project standards and established local patterns. Flag:

- a documented rule violation;
- an unnecessary abstraction;
- duplicated decisions;
- pass-through layers;
- inconsistent naming or structure that increases reader load.

Skip issues already enforced by the formatter or linter unless the tool is not
being run.

## Output

Keep the three axes separate. For every finding include:

- severity;
- location;
- evidence or violated rule;
- impact;
- smallest reasonable correction.

Do not assign arbitrary numerical confidence. Unsupported concerns belong under
`Context needed`, not in the confirmed findings list.
