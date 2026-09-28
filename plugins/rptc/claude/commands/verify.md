---
description: Verify acceptance claims, changed risks, and repository fit with direct evidence
allowed-tools: Bash(npm test *), Bash(npm run *), Bash(pnpm test *), Bash(pnpm run *), Bash(yarn test *), Bash(yarn run *), Bash(bun test *), Bash(bun run *), Bash(pytest *), Bash(python -m pytest *), Bash(uv run pytest *), Bash(cargo test *), Bash(cargo build *), Bash(cargo check *), Bash(cargo clippy *), Bash(go test *), Bash(go build *), Bash(go vet *), Bash(dotnet test *), Bash(dotnet build *), Read, Write, Edit, Glob, Grep, Task, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion
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

Mark blocking and should-fix findings that affect correctness, the stated
request, security, or a documented rule as requiring action; list optional
findings separately.

Fix them only when the user asked this verification pass to fix findings;
otherwise leave files unchanged.

## 6. Report

For each material claim, output:

```text
<claim>: <VERIFIED | NOT VERIFIED | INCONCLUSIVE>. <command or artifact> → <observed result>
```

List findings, checks run, checks unavailable, and the smallest next action.
