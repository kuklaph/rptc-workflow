---
name: rptc-commit
description: Run project-defined checks, stage selected paths, and create only the commit or pull request explicitly requested through the RPTC ship contract.
---

# RPTC Commit

Shared contract: `shared/workflows/ship.md`

## 1. Initialize

Load `rptc:unslop-writing-clearly` and read
`RPTC plugin root/shared/workflows/ship.md`.

## 2. Discover and run checks

Inspect project guidance, task-runner files, build files, package scripts, and
CI. Run checks relevant to the changed paths.

Do not guess a test runner, install a framework, or impose a universal coverage
threshold.

## 3. Inspect scope

Read git status, staged and unstaged diffs, and changed content. Identify
unrelated files, secrets, debug residue, and generated artifacts.

## 4. Propose

Present exact paths to stage, checks and results, skipped checks, and the commit
message using project conventions.

If an additional approval is required, ask in normal chat and stop. This flow
does not enter Plan Mode merely to access `request_user_input`.

## 5. Commit

Stage only confirmed paths with:

```bash
git add -- <path>...
```

Never use broad staging commands.

Create the approved commit. Push and create a draft pull request only when the
user explicitly requested the PR variant.

Report the commit SHA, checks, and PR URL when applicable.
