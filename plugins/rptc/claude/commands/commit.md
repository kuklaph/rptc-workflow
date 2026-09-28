---
description: Run project-defined checks, stage selected paths, and create only the requested commit or pull request
allowed-tools: Bash(git add *), Bash(git commit *), Bash(git switch -c *), Bash(git push -u origin *), Bash(gh pr create *), Bash(fj pr create *), Bash(glab mr create *), Bash(npm test *), Bash(npm run *), Bash(pnpm test *), Bash(pnpm run *), Bash(yarn test *), Bash(yarn run *), Bash(bun test *), Bash(bun run *), Bash(pytest *), Bash(python -m pytest *), Bash(uv run pytest *), Bash(cargo test *), Bash(cargo build *), Bash(cargo check *), Bash(cargo clippy *), Bash(go test *), Bash(go build *), Bash(go vet *), Bash(dotnet test *), Bash(dotnet build *), Read, Glob, Grep, AskUserQuestion
---

# /rptc:commit

Shared contract: `shared/workflows/ship.md`

## Arguments

- no argument: prepare and create a commit;
- `pr`: commit, push, and create a draft pull request.

## 1. Initialize

Load `rptc:unslop-writing-clearly`.
Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/ship.md`.

## 2. Inspect scope

Inspect status, staged and unstaged diffs. Identify intended and unrelated
paths. Inspect changed content for secrets, debug residue, generated artifacts,
and accidental broad edits.

## 3. Run checks

Inspect repository guidance, package scripts, build files, task runners, and CI.
Run checks relevant to the changed paths. Prefer project commands over guessed
framework commands. Reuse passing results from this session when the code has
not changed since they ran; run only checks without current evidence.

If no check exists, say so. Do not install a framework or invent an 80 percent
coverage policy during commit.

## 4. Propose the commit

Present:

- exact paths to stage;
- checks run and results;
- skipped checks and reasons;
- proposed message using the repository's convention.

Use Conventional Commits only when the project requires or already follows
them.

Commit without further confirmation when the user's request already fixes the
scope and intent. Ask when unrelated or ambiguous paths are present or project
policy requires confirmation.

## 5. Commit

Stage only in-scope paths:

```bash
git add -- <path>...
```

Never use `git add .`, `git add -A`, or `git add --all`.

With `pr`, check the branch before committing: if it is the default branch,
create a feature branch or ask the user first, so the commit never lands on the
default branch.

Create the commit and report its SHA.

## 6. Optional pull request

Only when the argument is `pr`:

1. push the feature branch;
2. create a draft pull request unless the user requested otherwise, using the
   host CLI that matches the remote (for example `gh` for GitHub, `fj` for
   Forgejo, `glab` for GitLab);
3. include the actual verification evidence;
4. return the URL.

No deployment or external notification is implied.
