---
name: rptc-structure
description: Audit concrete codebase structure friction and propose evidence-backed refactors that improve module depth, ownership, dependency direction, locality, or testability.
---

# RPTC Structure

Shared contract: `shared/workflows/structure.md`

Load `rptc:structure-methodology` and read the shared structure contract.

Scope the audit to the supplied path or recent hotspots. Use a full-codebase
scan only when explicitly requested.

Use bounded read-only agents for independent angles when available, with the
Codex spawn barrier. Inspect interfaces, callers, tests, ownership, and history.

Return a small set of candidates with evidence, proposed seam, migration risk,
and verification. This skill is report-only. Route implementation to
`rptc:rptc-feat`.
