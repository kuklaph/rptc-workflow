---
name: research-methodology
description: Investigate codebase behavior, external facts, or both using sources appropriate to the claim. Use for RPTC discovery, unfamiliar APIs, standards, current best practices, and comparisons between a repository and external guidance.
---

# Research Methodology

## Select the mode

- **Codebase:** trace current implementation, contracts, data flow, side effects,
  errors, tests, and consumers.
- **External:** answer a question from authoritative sources.
- **Hybrid:** compare the codebase with external requirements or practice.

## Evidence plan

Choose sources by the claim:

- current API behavior: official documentation, source, changelog, and a direct
  experiment when practical;
- package implementation: repository source and tests;
- protocol or standard: the normative specification;
- security advice: standards, vendor advisories, and the relevant threat model;
- community practice: several credible practitioner sources with disagreement
  preserved;
- broad ecosystem survey: a wider and more diverse source set.

Do not use a fixed source quota. One primary source plus a direct experiment can
be stronger than many secondary articles repeating the same claim.

## Codebase mode

Trace from entry point to observable outcome. Include exact file and symbol
references. Separate:

- what the code does;
- what tests or documentation promise;
- inferred intent;
- open questions.

## External mode

Prefer primary sources. Verify citations before using them. Mark dated,
single-source, disputed, or inferred claims clearly.

## Hybrid mode

Present current implementation, external contract or practice, the gap, and a
prioritized recommendation. Do not silently treat outside practice as a project
requirement.

Return findings inline unless the parent explicitly requests an artifact.
