---
name: verification-evidence
description: Classify completion claims as VERIFIED, NOT VERIFIED, or INCONCLUSIVE and attach the command, artifact, or runtime observation that supports each status. Use during RPTC verification and completion reporting.
---

# Verification Evidence

Read `RPTC plugin root/shared/workflows/verification.md`.

For each acceptance predicate or material claim, record:

```text
Claim:
Status: VERIFIED | NOT VERIFIED | INCONCLUSIVE
Evidence:
Observed result:
Git state or artifact:
```

`VERIFIED` requires a direct observation that proves the stated claim.
`NOT VERIFIED` means the predicate failed.
`INCONCLUSIVE` means access, environment, instability, or an unresolved contract
prevented a reliable answer.

Do not promote a weaker proxy into a stronger claim. A typecheck proves type
consistency. It does not by itself prove runtime behavior.
