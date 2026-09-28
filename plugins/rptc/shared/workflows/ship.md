# Ship workflow contract

## Purpose

Prepare and perform only the git actions the user explicitly requested.

## Procedure

1. Determine the intended scope from the current diff and conversation.
2. Inspect the exact diff and search changed content for secrets, debug residue,
   accidental generated files, and unrelated changes.
3. Discover project checks from repository documentation, task-runner files,
   package scripts, build files, and CI.
4. Run the checks relevant to the changed paths. Reuse passing results from
   this session when the code has not changed since they ran; run only checks
   without current evidence. Do not invent a universal coverage threshold or
   test runner.
5. Present the files to stage and the proposed commit message.
6. Stage only in-scope paths. Never use `git add .`, `git add -A`, or
   `git add --all`.
7. Commit without further confirmation when the user's request already fixes
   the scope and intent. Ask when unrelated or ambiguous paths are present or
   project policy requires confirmation.
8. Push or create a pull request only when explicitly requested. For a pull
   request, commit on a feature branch, created before committing or after
   asking the user, never on the default branch. Use the host CLI that matches
   the remote (for example `gh` for GitHub, `fj` for Forgejo,
   `glab` for GitLab). Create a draft unless asked otherwise and include the
   actual verification evidence.
9. Report the commit, checks run, skipped checks with reasons, and any remaining
   uncertainty.

## Project conventions

Use the repository's commit and pull-request conventions. Use Conventional
Commits only when the project requires or already follows them.
