---
description: Comprehensive verification and intelligent documentation sync before shipping
---

# RPTC: Commit Phase

**Final step in the RPTC workflow - verify everything before shipping.**

Arguments:

- None: `/rptc:commit` (just commit)
- With PR: `/rptc:commit pr` (commit + create pull request)

## Core Mission

Ensure ONLY high-quality, fully-tested code gets committed:

- Comprehensive test suite verification
- Coverage validation
- Code quality checks
- Conventional commit creation
- Optional PR generation

**Key Principle**: If ANY verification fails, STOP. Never commit broken code.

## Commit Process

### Helper Commands Available

As a Master specialist sub-agent, you have access to helper commands:

- `/rptc:helper-catch-up-quick` - Quick context (2 min)
- `/rptc:helper-catch-up-med` - Medium context (5-10 min)
- `/rptc:helper-catch-up-deep` - Deep analysis (15-30 min)

Use these if you need additional project context during commit phase.

## Step 0: Load SOPs

Load SOPs using fallback chain (highest priority first):

1. **Check project SOPs**: `.rptc/sop/`
2. **Check user global SOPs**: `~/.claude/global/sop/`
3. **Use plugin defaults**: `${CLAUDE_PLUGIN_ROOT}/sop/`

**SOPs to reference**:

- Git & deployment: Commit conventions, workflows, CI/CD
- Code quality: Style standards, linting rules

**Project Overrides**: Check `.context/` for project-specific git workflow or CI/CD configurations.

### Phase 1: Pre-Commit Verification (CRITICAL)

**Load Configuration**:

1. **Check if settings file exists**:
   - Use Read tool to read `.claude/settings.json`
   - If file doesn't exist or can't be read, use defaults (skip to step 3)

2. **Parse configuration** (extract these fields):
   - `rptc.defaultThinkingMode` → THINKING_MODE (default: "think")
   - `rptc.testCoverageTarget` → COVERAGE_TARGET (default: 85)
   - `rptc.docsLocation` → DOCS_LOC (default: "docs")

3. **Display loaded configuration**:
   ```text
   Configuration loaded:
     Thinking mode: [THINKING_MODE value]
     Coverage target: [COVERAGE_TARGET value]%
     Docs location: [DOCS_LOC value]
   ```

**Use these values throughout the command execution.**

**Note**: References to these variables appear throughout this command - use the actual loaded values from this step.

#### 1. Test Suite Verification (NON-NEGOTIABLE)

**Run FULL test suite**:

```bash
# Attempt to run tests with appropriate command
npm test || npm run test || pytest || go test ./... || cargo test
```

**If ANY test fails**:

**CRITICAL FORMATTING NOTE:** Ensure each failure item is on its own line with proper newlines. Never concatenate test failures together.

```text
════════════════════════════════════════
  ❌ COMMIT BLOCKED - TESTS FAILING
════════════════════════════════════════

Test failures detected:
[Show specific failures]

TDD Rule: Never commit with failing tests!

To fix:
1. Review the test failures above
2. Fix the implementation or tests
3. Run tests again to verify
4. When all tests pass, commit again

Use '/rptc:tdd' to fix with auto-iteration.
```

**STOP IMMEDIATELY** - do not proceed with any other checks.

**If all tests pass**:

```text
✅ Test Suite: [X] tests passing
```

#### 2. Coverage Check

**Run coverage report**:

```bash
npm run test:coverage || npm run coverage || pytest --cov || go test -cover ./...
```

**Extract coverage percentage**:

```bash
# Compare against configured target
ACTUAL_COVERAGE=[extracted from coverage output]

if [ "$ACTUAL_COVERAGE" -ge "$COVERAGE_TARGET" ]; then
  echo "✅ Coverage: ${ACTUAL_COVERAGE}% (target: ${COVERAGE_TARGET}%)"
else
  echo "⚠️  Coverage: ${ACTUAL_COVERAGE}% (below target: ${COVERAGE_TARGET}%)"
fi
```

**Report**:

**FORMATTING NOTE:** Ensure each metric is on its own line with proper newlines.

```text
📊 Coverage: [X]% (target: [COVERAGE_TARGET]%)
```

#### 3. Code Quality Checks

**Check for common issues in staged files**:

For each staged file:

- ❌ `.env` files staged? → Block commit
- ❌ `console.log()` in non-test files? → Block commit
- ❌ `debugger` statements? → Block commit
- ⚠️ `TODO`/`FIXME` comments? → Warn but allow

**If blocking issues found**:

**CRITICAL FORMATTING NOTE:** Each issue MUST be on its own line with proper newlines. Never concatenate issues together.

```text
════════════════════════════════════════
  ❌ COMMIT BLOCKED - CODE QUALITY ISSUES
════════════════════════════════════════

Issues found:
- [Issue 1]
- [Issue 2]

Fix these issues before committing.
```

**STOP** - do not proceed.

**If no blocking issues**:

```text
✅ Code Quality: No blocking issues
```

#### 4. Linting & Type Checking

**Run linter** (if available):

```bash
npm run lint || eslint . || pylint . || cargo clippy
```

- If fails: ⚠️ Linting errors (warn but allow)
- If passes: ✅ No linting errors

**Run type checker** (if TypeScript/typed language):

```bash
npx tsc --noEmit || mypy . || cargo check
```

- If fails: ⚠️ Type errors (warn but allow)
- If passes: ✅ No type errors

#### 5. Git Status Review

**Check current state**:

```bash
git status
git diff --staged
```

**Verify**:

- Not on main/master branch
- Has staged changes
- No sensitive files (`.env`, secrets)

**Report**:

**FORMATTING NOTE:** Each status line must be on its own line with proper newlines.

```text
🔍 Git Status:
- Branch: [branch-name] ✅
- Staged files: [N]
- Ready to commit
```

### Phase 2: Generate Commit Message

**Analyze the diff and create conventional commit**:

```bash
git diff --staged
```

**Format**:

```text
type(scope): brief description

- Implemented: [what was built]
- Tests: [tests added/modified]
- Coverage: [current coverage]%

Closes #[issue-number] (if applicable)
```

**Types**:

- `feat:` - New feature (with tests)
- `fix:` - Bug fix (with tests)
- `test:` - Test additions/changes
- `refactor:` - Code improvements (tests unchanged)
- `docs:` - Documentation only
- `chore:` - Maintenance (deps, config)

**Determine scope** from changed files:

- `auth`, `api`, `ui`, `db`, `config`, etc.

**Example**:

```text
feat(auth): add Google OAuth2 authentication

- Implemented: OAuth strategy with Passport.js
- Tests: 12 new tests covering OAuth flow
- Coverage: 87% (up from 82%)

Closes #124
```

### Phase 3: Verification Summary

**Present comprehensive summary**:

**CRITICAL FORMATTING NOTE:** Each verification item MUST be on its own line. Never concatenate items (e.g., `Test Suite: ✅Coverage: ✅` is WRONG).

```text
════════════════════════════════════════
  PRE-COMMIT VERIFICATION COMPLETE
════════════════════════════════════════

🧪 Test Suite: ✅ [X] tests passing
📊 Coverage: ✅ [Y]% (target: [COVERAGE_TARGET]%)
🔍 Linting: ✅ No errors
📝 Types: ✅ No errors
🔒 Security: ✅ No issues found

════════════════════════════════════════
  READY TO COMMIT
════════════════════════════════════════

Commit message:
───────────────────────────────────────
[Show generated commit message]
───────────────────────────────────────

Files: [N] files changed, [X] insertions(+), [Y] deletions(-)

Proceed with commit? (auto-continuing...)
```

### Phase 4: Master Documentation Specialist Agent (CRITICAL)

**Review and update documentation to stay in sync with code changes.**

**Purpose**: Ensure existing documentation (CLAUDE.md, README.md, etc.) remains accurate after code changes.

**When to run**: For ANY change that would make documentation out of sync - not just features, but refactors, architecture changes, API updates, etc.

#### Check Documentation Sync

**Analyze changes**:

```bash
git diff --staged
```

**Ask**: Do these changes affect existing documentation?

**Check for**:

- New files/modules documented in README?
- API changes affecting API docs?
- Architecture changes affecting CLAUDE.md or docs?
- New dependencies affecting setup instructions?
- Changed workflows affecting contribution guides?
- Security changes affecting security docs?

**If documentation needs updating**:

**Step 1: Use Configured Thinking Mode**:

Thinking mode already loaded in Step 0 configuration: `$THINKING_MODE`

**Step 2: Delegate to Documentation Specialist**:

**FORMATTING NOTE:** Each change line must be on its own line with proper newlines.

```text
📚 Documentation Update Needed

Changes detected that affect documentation:
- [Change 1] affects [doc 1]
- [Change 2] affects [doc 2]

Delegating to Master Documentation Specialist with $THINKING_MODE mode...
```

#### Documentation Specialist Sub-Agent

**Sub-Agent Prompt**:

```text
Use $THINKING_MODE thinking mode for this documentation review.

You are a MASTER DOCUMENTATION SPECIALIST - Expert in keeping documentation synchronized with code changes.

Your mission: Update EXISTING documentation to reflect code changes. DO NOT create new documentation unless explicitly needed.

Context:
- Changes made: [summary from git diff]
- Files modified: [list]
- Work item: [if available from plan]

**Documentation to Review**:
- `CLAUDE.md` - Project guidelines, commands, workflow
- `README.md` - Setup, usage, overview
- `.context/` files - Project-specific context
- `$DOCS_LOC/` folder - If exists, check for affected docs
- `CONTRIBUTING.md` - If contribution process changed
- API docs - If API endpoints changed

**For EACH document**:

1. **Read current content**
2. **Identify outdated sections** based on code changes
3. **Update ONLY what's out of sync**:
   - Update examples if code changed
   - Update API signatures if endpoints changed
   - Update setup steps if dependencies changed
   - Update architecture diagrams if structure changed
   - Update command references if commands changed

4. **DO NOT**:
   - Create new documentation files
   - Add documentation that wasn't requested
   - Remove existing documentation
   - Change documentation style/format unnecessarily

5. **Report changes**:
   - Which docs updated
   - What was changed in each
   - Why it needed updating

Return summary:
- Documents updated: [list]
- Changes made: [by document]
- Documentation sync status: ✅ In sync

CRITICAL: Only update existing docs. Ask before creating new docs.
```

**Present Documentation Results**:

**FORMATTING NOTE:** Ensure each documentation update and summary item is on its own line with proper newlines.

```text
📚 Master Documentation Specialist Complete!

Documentation updated:
- `README.md`: Updated API examples for new endpoints
- `CLAUDE.md`: Updated helper command references
- `.context/project-overview.md`: Updated architecture section

Changes summary:
- 3 files updated
- 12 lines changed
- Documentation now in sync with code

✅ All documentation synchronized with changes

Proceeding to commit...
```

**If no documentation changes needed**:

```text
📚 Documentation Sync Check: ✅ No updates needed

Code changes don't affect existing documentation.

Proceeding to commit...
```

### Phase 5: Execute Commit

**Create commit**:

```bash
git add -A
git commit -m "$(cat <<'COMMIT_MSG'
[Generated commit message]
COMMIT_MSG
)"
```

**Report success**:

**FORMATTING NOTE:** Ensure each status line is on its own line with proper newlines.

```text
✅ Committed: [commit-hash]

[Show commit message]

🚀 Ready to ship!
```

### Phase 6: Create PR (Optional - If "pr" Argument)

**If user provided `/rptc:commit pr`**:

1. **Check if branch is pushed**:

   ```bash
   git status
   ```

2. **Push if needed**:

   ```bash
   git push -u origin [branch-name]
   ```

3. **Create PR with gh CLI**:

   ```bash
   gh pr create --title "[type]: [description]" --body "$(cat <<'PR_BODY'
   ## Summary
   [Feature/fix summary based on commit]

   ## Implementation Details
   [Key changes from diff]

   ## Test Coverage
   - Tests: [X] passing
   - Coverage: [Y]%
   - New tests: [Z]

   ## Checklist
   - [x] All tests passing
   - [x] Coverage ≥ [COVERAGE_TARGET]%
   - [x] Code quality verified
   - [x] No debug code
   - [x] Conventional commit format
   PR_BODY
   )"
   ```

4. **Report PR creation**:

**FORMATTING NOTE:** Each PR detail must be on its own line.

```text
   🔀 Pull Request Created!

   PR URL: [github-url]
   Title: [pr-title]

   ✅ Ready for review!
```

### Phase 7: Final Summary

**Complete workflow summary**:

**CRITICAL FORMATTING NOTE:** Each workflow step MUST be on its own line. Never concatenate steps (e.g., `✅ Research: Complete✅ Planning: Complete` is WRONG).

```text
════════════════════════════════════════
  RPTC WORKFLOW COMPLETE! 🎉
════════════════════════════════════════

✅ Research: [if applicable]
✅ Planning: [if applicable]
✅ TDD Implementation: Complete
✅ Quality Gates: Passed
✅ Commit: [commit-hash]
✅ PR: [pr-url] (if created)

All steps completed successfully!

To continue:
- Merge PR when approved
- Start new work: /rptc:research "next topic"
- Fix bug: /rptc:tdd "bug description"

Great work! 🚀
════════════════════════════════════════
```

## Verification Failure Handling

### Tests Failing

**CRITICAL FORMATTING NOTE:** Each test failure MUST be on its own line with proper newlines.

```text
════════════════════════════════════════
  ❌ COMMIT BLOCKED - TESTS FAILING
════════════════════════════════════════

[X] tests failing:

[Show specific test failures]

TDD Rule: Never commit with failing tests!

To fix:
1. Review failures above
2. Fix implementation/tests
3. Run: [test command]
4. When passing, commit again

Use '/rptc:tdd' for auto-iteration fix.
════════════════════════════════════════
```

### Code Quality Issues

**CRITICAL FORMATTING NOTE:** Each quality issue MUST be on its own line. Never concatenate issues together.

```text
════════════════════════════════════════
  ❌ COMMIT BLOCKED - QUALITY ISSUES
════════════════════════════════════════

Issues found:
  🔒 .env file staged: .env
  🐛 console.log found: src/auth.ts:42
  🐛 debugger statement: src/utils.ts:15

Fix these issues before committing.
════════════════════════════════════════
```

### Coverage Warning (Non-Blocking)

**FORMATTING NOTE:** Each coverage item must be on its own line with proper newlines.

```text
⚠️  Warning: Coverage below target

Current: [X]%
Target: [COVERAGE_TARGET]%

This is allowed but not ideal.
Consider adding tests for:
- [file1.ts]: [Y]%
- [file2.ts]: [Z]%

Proceeding with commit...
```

## Interaction Guidelines

### DO:

- ✅ Run FULL test suite (comprehensive)
- ✅ Block commit if ANY test fails
- ✅ Check coverage and code quality
- ✅ Generate conventional commit message
- ✅ Create helpful PR descriptions
- ✅ Provide clear failure messages

### DON'T:

- ❌ Commit with failing tests (NEVER)
- ❌ Commit `.env` or sensitive files
- ❌ Commit debug code (console.log, debugger)
- ❌ Use vague commit messages
- ❌ Skip verification steps
- ❌ Push to main/master directly

## Example Interaction Flow

```text
User: /rptc:commit pr

Agent:
════════════════════════════════════════
  PRE-COMMIT VERIFICATION
════════════════════════════════════════

🧪 Running test suite...
✅ 47 tests passing

📊 Checking coverage...
✅ 87% coverage (target: [COVERAGE_TARGET]%)

🔍 Running linter...
✅ No linting errors

📝 Type checking...
✅ No type errors

🔒 Security checks...
✅ No .env files staged
✅ No debug code found

════════════════════════════════════════
  READY TO COMMIT
════════════════════════════════════════

Commit message:
───────────────────────────────────────
feat(auth): add Google OAuth2 authentication

- Implemented: OAuth strategy with Passport.js
- Tests: 12 new tests covering OAuth flow
- Coverage: 87% (up from 82%)

Closes #124
───────────────────────────────────────

Files: 8 files changed, 234 insertions(+)

Proceeding with commit...

✅ Committed: abc123def

🚀 Pushing to remote...
✅ Pushed to origin/feature/oauth

🔀 Creating pull request...
✅ PR created: https://github.com/user/repo/pull/125

════════════════════════════════════════
  RPTC WORKFLOW COMPLETE! 🎉
════════════════════════════════════════

✅ Research: user-authentication.md
✅ Planning: user-authentication.md
✅ TDD Implementation: Complete
✅ Quality Gates: Passed
✅ Commit: abc123def
✅ PR: https://github.com/user/repo/pull/125

Great work! 🚀
════════════════════════════════════════
```

## Success Criteria

- [ ] All tests passing (verified)
- [ ] Coverage checked (reported)
- [ ] Code quality verified (no blocking issues)
- [ ] Linting passed or warnings noted
- [ ] Type checking passed or warnings noted
- [ ] Git status verified (correct branch)
- [ ] Conventional commit message generated
- [ ] Commit created successfully
- [ ] PR created (if requested)
- [ ] Workflow completion confirmed

---

_Remember: Quality is non-negotiable. Verification failures block commits._
