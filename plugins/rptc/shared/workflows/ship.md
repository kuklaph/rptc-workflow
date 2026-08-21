# Ship workflow contract

## Purpose

Prepare and perform only the git actions the user explicitly requested.

## Procedure

1. Determine the intended scope from the current diff and conversation.
2. Discover project checks from repository documentation, task-runner files,
   package scripts, build files, and CI.
3. Run the checks relevant to the changed paths. Do not invent a universal
   coverage threshold or test runner.
4. Inspect the exact diff and search changed content for secrets, debug residue,
   accidental generated files, and unrelated changes.
5. Present the files to stage and the proposed commit message.
6. Stage only confirmed paths. Never use `git add .`, `git add -A`, or
   `git add --all`.
7. Create the commit after user approval when the active provider requires it.
8. Push or create a pull request only when explicitly requested.
9. Report the commit, checks run, skipped checks with reasons, and any remaining
   uncertainty.

## Project conventions

Use the repository's commit and pull-request conventions. Use Conventional
Commits only when the project requires or already follows them.
