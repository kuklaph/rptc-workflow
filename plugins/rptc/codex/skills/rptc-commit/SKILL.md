---
name: rptc-commit
description: Run project-defined checks, stage selected paths, and create only the commit or pull request explicitly requested through the RPTC ship contract.
---

# RPTC Commit

Shared contract: `shared/workflows/ship.md`

## 1. Initialize

Load `rptc:unslop-writing-clearly` and read
`../../../shared/workflows/ship.md` (relative to this SKILL.md).

## 2. Inspect scope

Read git status, staged and unstaged diffs, and changed content. Identify
unrelated files, secrets, debug residue, and generated artifacts.

## 3. Run checks

Inspect project guidance, task-runner files, build files, package scripts, and
CI. Run checks relevant to the changed paths. Reuse passing results from this
session when the code has not changed since they ran; run only checks without
current evidence.

Do not guess a test runner, install a framework, or impose a universal coverage
threshold.

## 4. Propose

Present exact paths to stage, checks and results, skipped checks, and the commit
message using project conventions.

Commit without further confirmation when the user's request already fixes the
scope and intent. Ask when unrelated or ambiguous paths are present or project
policy requires confirmation. Ask in normal chat and stop; this flow does not
enter Plan Mode merely to access `request_user_input`.

## 5. Commit

Stage only in-scope paths with:

```bash
git add -- <path>...
```

Never use broad staging commands.

For the PR variant, check the branch before committing: if it is the default
branch, create a feature branch or ask the user first, so the commit never lands
on the default branch.

Create the commit. Push and open a pull request only when the user explicitly
requested the PR variant. Use the host CLI that matches the remote (for example
`gh` for GitHub, `fj` for Forgejo, `glab` for GitLab). Create a draft unless
asked otherwise and include the actual verification evidence.

Report the commit SHA, checks, and PR URL when applicable.
