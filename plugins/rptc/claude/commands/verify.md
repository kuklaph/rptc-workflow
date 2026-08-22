---
description: Verify acceptance claims, changed risks, and repository fit with direct evidence
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(bunx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Read, Write, Edit, Glob, Grep, LS, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion
---

# /rptc:verify

Shared contract: `shared/workflows/verification.md`

## Arguments

- no argument: verify staged and unstaged changes;
- path: verify the named files or directory;
- `.`: verify the full project only when explicitly requested.

## 1. Initialize

Load:

```text
Skill("rptc:core-principles")
Skill("rptc:verification-evidence")
Skill("rptc:unslop-writing-clearly")
```

Read `${CLAUDE_PLUGIN_ROOT}/shared/workflows/verification.md`.

## 2. Establish scope and claims

Collect the exact diff or paths. Identify:

- the request, issue, plan, or acceptance criteria;
- project standards and declared checks;
- changed public behavior;
- changed trust boundaries;
- documentation or operational impact.

When no usable request or spec exists, say so. Do not invent one.

## 3. Run direct checks

Discover checks from repository scripts, build files, CI, and contribution
guidance. Run the narrowest relevant checks first.

Record what each check actually proves. A build does not automatically prove
runtime behavior.

## 4. Select independent review

Select review axes by the change:

- code review for correctness and repository fit;
- security review for changed trust boundaries or sensitive paths;
- documentation review for public behavior or operating procedures.

A mechanical change with decisive deterministic evidence may need no model
review unless the user requests one.

Launch selected report-only agents in parallel. Provide the exact diff, source
request, project standards, and direct-check evidence.

## 5. Consolidate

Keep findings under separate headings:

- Request fidelity.
- Correctness and risk.
- Repository fit.
- Security impact.
- Documentation impact.

A confirmed finding needs a location plus evidence or a documented rule.
Do not filter or rank findings by arbitrary numerical confidence.

Do not modify files unless the user asked this verification pass to fix findings.

## 6. Report

For each material claim, output:

```text
Claim:
Status: VERIFIED | NOT VERIFIED | INCONCLUSIVE
Evidence:
Observed result:
```

List findings, checks run, checks unavailable, and the smallest next action.
