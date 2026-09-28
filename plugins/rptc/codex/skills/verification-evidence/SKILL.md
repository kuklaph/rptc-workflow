---
name: verification-evidence
description: Classify completion claims as VERIFIED, NOT VERIFIED, or INCONCLUSIVE and attach the command, artifact, or runtime observation that supports each status. Use during RPTC verification and completion reporting.
---

# Verification Evidence

Read `../../../shared/workflows/verification.md` (relative to this SKILL.md).

For each acceptance predicate or material claim, record one line:

```text
<claim>: <VERIFIED | NOT VERIFIED | INCONCLUSIVE>. <command or artifact> → <observed result>
```

Add the git state only when the evidence predates the current diff.

`VERIFIED` requires a direct observation that proves the stated claim.
`NOT VERIFIED` means the predicate failed.
`INCONCLUSIVE` means access, environment, instability, or an unresolved contract
prevented a reliable answer.

Do not promote a weaker proxy into a stronger claim. A typecheck proves type
consistency. It does not by itself prove runtime behavior.
A statement that TDD was followed is not evidence.
