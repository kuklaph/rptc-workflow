---
description: Run project-defined checks, stage selected paths, and create only the requested commit or pull request
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Bash(gh *), Read, Glob, Grep, LS, AskUserQuestion
---

# /rptc:commit

Shared contract: `shared/workflows/ship.md`

## Arguments

- no argument: prepare and create a commit;
- `pr`: commit, push, and create a draft pull request.

## 1. Initialize

Load `rptc:unslop-writing-clearly`.
Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/ship.md`.

## 2. Discover checks

Inspect repository guidance, package scripts, build files, task runners, and CI.
Run checks relevant to the changed paths. Prefer project commands over guessed
framework commands.

If no check exists, say so. Do not install a framework or invent an 80 percent
coverage policy during commit.

## 3. Inspect scope

Run:

```bash
git status --short
git diff --stat
git diff
git diff --cached
```

Identify intended and unrelated paths. Inspect changed content for secrets,
debug residue, generated artifacts, and accidental broad edits.

## 4. Propose the commit

Present:

- exact paths to stage;
- checks run and results;
- skipped checks and reasons;
- proposed message using the repository's convention.

Use Conventional Commits only when the project requires or already follows
them.

Ask the user to approve the paths and message.

## 5. Commit

Stage only approved paths:

```bash
git add -- <path>...
```

Never use `git add .`, `git add -A`, or `git add --all`.

Create the approved commit and report its SHA.

## 6. Optional pull request

Only when the argument is `pr`:

1. push the current branch;
2. create a draft pull request unless the user requested otherwise;
3. include the actual verification evidence;
4. return the URL.

No deployment or external notification is implied.
