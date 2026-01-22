---
description: Verify and ship with quality gates
allowed-tools: Bash(git *), Bash(npm *), Bash(npx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(cargo *), Bash(go *), Bash(pytest *), Bash(python -m pytest *), Bash(make *), Bash(dotnet *), Bash(gh *), Read, Write, Edit, Glob, Grep, LS, Task, TodoWrite
---

# /rptc:commit

Verify quality gates and ship. Final step in the workflow.

**Arguments**:
- None: `/rptc:commit` - Commit only
- With PR: `/rptc:commit pr` - Commit and create pull request

---

## Phase 1: Pre-Commit Verification

**Goal**: Ensure code is ready to ship.

**Actions**:
1. **Run tests**:
   ```bash
   # Detect test runner and execute
   npm test || pytest || cargo test || go test ./... || dotnet test
   ```
   **BLOCKER**: If tests fail, STOP and fix before proceeding.

2. **Check coverage** (if available):
   ```bash
   npm run test:coverage || pytest --cov || cargo tarpaulin
   ```
   Target: 80%+ on new code.

3. **Lint check**:
   ```bash
   npm run lint || ruff check . || cargo clippy
   ```
   Fix any errors before proceeding.

4. **Type check** (if applicable):
   ```bash
   npm run typecheck || npx tsc --noEmit || mypy .
   ```

---

## Phase 2: Review Changes

**Goal**: Understand what's being committed.

**Actions**:
1. **Check git status**:
   ```bash
   git status
   git diff --stat
   ```

2. **Review staged changes**:
   ```bash
   git diff --cached
   ```

3. **Verify no sensitive files**:
   - No `.env` files
   - No credentials or secrets
   - No debug code (console.log, debugger)

---

## Phase 3: Create Commit

**Goal**: Create a well-formatted commit.

**Actions**:
1. **Stage changes** (if not already staged):
   ```bash
   git add .  # Or specific files
   ```

2. **Create commit with conventional format**:
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<scope>): <description>

   <body - what and why>

   <footer - breaking changes, closes #issue>
   EOF
   )"
   ```

**Commit types**:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code change (no new feature or fix)
- `test`: Adding tests
- `docs`: Documentation only
- `chore`: Maintenance

---

## Phase 4: Optional PR Creation

**Goal**: Create pull request if requested.

**Trigger**: User ran `/rptc:commit pr`

**Actions**:
1. **Push to remote**:
   ```bash
   git push -u origin HEAD
   ```

2. **Create PR**:
   ```bash
   gh pr create --title "<type>: <description>" --body "$(cat <<'EOF'
   ## Summary
   <what this PR does>

   ## Changes
   - <change 1>
   - <change 2>

   ## Testing
   - [ ] Tests pass
   - [ ] Coverage maintained

   ## Notes
   <any additional context>
   EOF
   )"
   ```

3. **Return PR URL** to user.

---

## Quality Gates (Non-Negotiable)

| Check | Required | Blocking |
|-------|----------|----------|
| Tests pass | Yes | Yes |
| Coverage ≥80% new code | Yes | No (warn) |
| No lint errors | Yes | Yes |
| No type errors | Yes | Yes |
| No secrets committed | Yes | Yes |
| Conventional commit | Yes | No (warn) |

---

## Error Handling

### Tests Fail
```
❌ Tests failed. Cannot commit.

Failing tests:
- [test name]: [error]

Fix the failing tests before committing.
```

### Coverage Below Target
```
⚠️ Coverage at X% (target: 80%)

Consider adding tests for:
- [uncovered file/function]

Proceeding with commit (coverage is a warning, not blocker).
```

### Secrets Detected
```
❌ Potential secrets detected. Cannot commit.

Files:
- [file with secret]

Remove secrets and use environment variables.
```

---

## Key Principles

1. **Tests must pass**: Never commit failing tests
2. **No secrets**: Block if credentials detected
3. **Conventional commits**: Standardized format
4. **PR optional**: Only create if explicitly requested
5. **Fast feedback**: Fail fast on blockers

---

## Differences from Legacy

| Aspect | Legacy | New |
|--------|--------|-----|
| Config loading | 80 lines | 0 |
| Discord notification | 40 lines inline | 0 (use hooks) |
| SOP loading | 30 lines | 0 |
| Verbose examples | 200+ lines | Minimal |
| Lines of code | 770 | ~150 |
