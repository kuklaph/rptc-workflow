---
description: Deprecated compatibility alias for /rptc:test-impact
allowed-tools: Read
---

# /rptc:sync-prod-to-tests

Shared contract: `shared/workflows/test-impact.md`

This command is deprecated because it implied that production code is always
the source of behavioral truth.

Do not edit production or tests from this command. Tell the user to run:

```text
/rptc:test-impact [path]
```

Explain that the replacement compares production and tests against requirements,
public contracts, and previously verified behavior before choosing which side
should change.
