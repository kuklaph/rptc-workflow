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
   - `rptc.discord.notificationsEnabled` → DISCORD_ENABLED (default: false)
   - `rptc.discord.webhookUrl` → DISCORD_WEBHOOK (default: "")
   - `rptc.discord.verbosity` → DISCORD_VERBOSITY (default: "summary")

3. **Create Discord notification helper function**:

```bash
notify_discord() {
  local message="$1"
  local min_verbosity="${2:-summary}"  # summary, detailed, or verbose

  # Check if notifications enabled
  if [ "$DISCORD_ENABLED" != "true" ] || [ -z "$DISCORD_WEBHOOK" ]; then
    return 0  # Silent skip
  fi

  # Check verbosity level
  case "$DISCORD_VERBOSITY" in
    summary)
      if [ "$min_verbosity" != "summary" ]; then
        return 0  # Skip this notification
      fi
      ;;
    detailed)
      if [ "$min_verbosity" = "verbose" ]; then
        return 0  # Skip verbose-only notifications
      fi
      ;;
    verbose)
      # Always send
      ;;
  esac

  # Send notification (fail-safe, never block workflow)
  if ! bash "${CLAUDE_PLUGIN_ROOT}/skills/discord-notify/scripts/notify.sh" \
    "$DISCORD_WEBHOOK" "$message" 2>/dev/null; then
    echo "⚠️  Discord notification failed (continuing workflow)" >&2
  fi
}
```

**Use these values throughout the command execution.**

**Note**: References to these variables appear throughout this command - use the actual loaded values from this step.

## Step 0b: Initialize TODO Tracking

**Initialize TodoWrite to track commit verification phases.**

Use the TodoWrite tool to create task list:

```json
{
  "tool": "TodoWrite",
  "todos": [
    {
      "content": "Pre-commit verification (tests, linting, coverage)",
      "status": "pending",
      "activeForm": "Running pre-commit checks"
    },
    {
      "content": "Generate commit message",
      "status": "pending",
      "activeForm": "Generating commit message"
    },
    {
      "content": "Verification summary",
      "status": "pending",
      "activeForm": "Presenting verification summary"
    },
    {
      "content": "Execute git commit",
      "status": "pending",
      "activeForm": "Creating commit"
    },
    {
      "content": "Create pull request",
      "status": "pending",
      "activeForm": "Creating pull request"
    },
    {
      "content": "Final summary",
      "status": "pending",
      "activeForm": "Presenting final summary"
    }
  ]
}
```

**Note**: "Create pull request" only applies if `pr` flag passed. Mark as completed immediately if not creating PR.

**Important TodoWrite Rules**:
- Mark tasks "in_progress" when starting each phase
- Mark tasks "completed" immediately after finishing each phase
- Only ONE task should be "in_progress" at a time
- Update frequently to track commit progress

**Update TodoWrite**: Mark "Pre-commit verification (tests, linting, coverage)" as in_progress

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

❌ **CANNOT PROCEED - FIX FAILING TESTS FIRST**

**ENFORCEMENT**:
1. List all failing tests above
2. Show failure details
3. Display: "NEVER commit with failing tests under ANY circumstances"
4. Exit with error code 1
5. MUST fix all test failures before proceeding

**This is a NON-NEGOTIABLE gate. Failing tests indicate broken functionality - MUST be fixed before commit.**

To fix:
1. Review the test failures above
2. Fix the implementation or tests
3. Run tests again to verify
4. When all tests pass, commit again

Use '/rptc:tdd' to fix with auto-iteration.
```

```bash
# Notify about test failures
notify_discord "❌ **Commit Blocked**\nTests failing - fix before committing" "summary"
```

**STOP IMMEDIATELY** - do not proceed with any other checks.

**If all tests pass**:

```text
✅ Test Suite: [X] tests passing
```

```bash
# Notify about tests passing
notify_discord "✅ **Tests Passing**\nReady to commit" "detailed"
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

---

**CRITICAL VALIDATION CHECKPOINT - CANNOT COMMIT WITH QUALITY ISSUES**

After running code quality checks:

**Quality Check**: NO debug code, NO quality violations

**Verification**:

```bash
# Check for debug code in staged files
git diff --staged --name-only | while read file; do
  # Check for console.log (non-test files)
  grep -n "console\.log\|console\.debug\|console\.warn" "$file" 2>/dev/null

  # Check for debugger statements
  grep -n "debugger" "$file" 2>/dev/null

  # Check for .env files
  echo "$file" | grep "\.env" 2>/dev/null
done
```

**For each staged file check**:

- ❌ `.env` files staged? → BLOCK COMMIT
- ❌ `console.log()` in non-test files? → BLOCK COMMIT
- ❌ `debugger` statements? → BLOCK COMMIT
- ⚠️ `TODO`/`FIXME` comments? → Warn but allow

**If quality issues found**:

**CRITICAL FORMATTING NOTE:** Each issue MUST be on its own line with proper newlines. Never concatenate issues together.

```text
════════════════════════════════════════
  ❌ COMMIT BLOCKED - CODE QUALITY ISSUES
════════════════════════════════════════

Issues found:
- [Issue 1]
- [Issue 2]

❌ **CANNOT PROCEED - FIX QUALITY ISSUES FIRST**

**ENFORCEMENT**:
1. List all quality violations above
2. Display: "NEVER commit debug code or quality violations"
3. Exit with error code 1
4. MUST fix all issues before proceeding

**Common violations**:
- Debug code (console.log, debugger statements)
- Sensitive files (.env, credentials)
- Unused imports (if linter detects)
- Linting violations (if critical)

**This is a NON-NEGOTIABLE gate. Code quality issues pollute codebase and must be cleaned before commit.**

To fix:
1. Review quality issues above
2. Remove debug code
3. Unstage sensitive files
4. When clean, commit again
```

**STOP IMMEDIATELY** - do not proceed with any other checks.

---

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

**Update TodoWrite**: Mark "Pre-commit verification (tests, linting, coverage)" as completed (only if all checks pass)

### Phase 2: Generate Commit Message

**Update TodoWrite**: Mark "Generate commit message" as in_progress

**Analyze the diff and create conventional commit**:

```bash
git diff --staged
```

**Format** (simple and direct):

```text
type(scope): brief description

[Optional: Bullet points for key details - max 5 bullets]
- [Key point 1]
- [Key point 2]

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

- OAuth strategy with Passport.js
- Google login integration
- 12 new tests added

Closes #124
```

**Keep it concise**: Use bullet points for clarity, but limit to 5 maximum. Each bullet should be brief and actionable.

**IMPORTANT**: Keep commit messages generic and professional. DO NOT add:
- AI generation attributions (e.g., "Generated with Claude Code")
- Co-authored-by tags for AI assistants
- Tool-specific footers or signatures

**Update TodoWrite**: Mark "Generate commit message" as completed

### Phase 3: Verification Summary

**Update TodoWrite**: Mark "Verification summary" as in_progress

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

**Update TodoWrite**: Mark "Verification summary" as completed


### Phase 4: Execute Commit

**Update TodoWrite**: Mark "Execute git commit" as in_progress

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

```bash
# Notify about successful commit
notify_discord "💾 **Commit Created**\n\`${COMMIT_MESSAGE}\`" "summary"
```

**Update TodoWrite**: Mark "Execute git commit" as completed

### Phase 5: Create PR (Optional - If "pr" Argument)

**Check**: Was `pr` flag passed in command?

**If NO `pr` flag**:
- **Update TodoWrite**: Mark "Create pull request" as completed (skipped)
- Skip to Phase 7

**If `pr` flag present**:
- **Update TodoWrite**: Mark "Create pull request" as in_progress

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
   [Brief description with bullet points for key changes - max 5 bullets]
   - [Key change 1]
   - [Key change 2]

   ## Tests
   [X] tests passing | [Y]% coverage

   ## Checklist
   - [x] All tests passing
   - [x] Coverage ≥ [COVERAGE_TARGET]%
   - [x] Code quality verified
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

```bash
# Notify about PR creation
notify_discord "🔗 **Pull Request Created**\n${PR_URL}" "summary"
```

- **Update TodoWrite**: Mark "Create pull request" as completed

### Phase 6: Final Summary

**Update TodoWrite**: Mark "Final summary" as in_progress

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

**Update TodoWrite**: Mark "Final summary" as completed

✅ All commit phases complete. TodoWrite list should show all tasks completed.

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

- OAuth strategy with Passport.js
- Google login integration
- 12 new tests added

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
