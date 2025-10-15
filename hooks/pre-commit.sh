#!/bin/bash
# Comprehensive Pre-Commit Verification
# Enforces quality standards before code enters repository
# Reference: CLAUDE.md (project root), testing-guide.md (SOP fallback chain)

set -e

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🔍 PRE-COMMIT VERIFICATION"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Read hook input to get commit message
INPUT=$(cat)
COMMIT_MSG=$(echo "$INPUT" | jq -r '.tool_input.command' | sed 's/git commit -m "//' | sed 's/"$//')

# ============================================================================
# Check 1: Conventional Commit Format
# Reference: git-and-deployment.md (SOP fallback chain)
# ============================================================================
echo "📋 Checking commit message format..."

if ! echo "$COMMIT_MSG" | grep -qE '^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,72}'; then
    echo "❌ Invalid commit message format!" >&2
    echo "" >&2
    echo "Required format (Conventional Commits):" >&2
    echo "  type(scope): description" >&2
    echo "" >&2
    echo "Types:" >&2
    echo "  feat     - New feature" >&2
    echo "  fix      - Bug fix" >&2
    echo "  docs     - Documentation only" >&2
    echo "  style    - Formatting, no code change" >&2
    echo "  refactor - Code restructuring" >&2
    echo "  test     - Adding/updating tests" >&2
    echo "  chore    - Maintenance tasks" >&2
    echo "" >&2
    echo "Example: feat(auth): add OAuth2 support" >&2
    echo "" >&2
    echo "See: git-and-deployment.md (SOP)" >&2
    exit 2
fi

echo "✅ Commit message valid"
echo ""

# ============================================================================
# Check 2: Code Quality
# Reference: CLAUDE.md (security, clean code)
# ============================================================================
echo "📋 Checking code quality..."

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")

if [ -z "$STAGED_FILES" ]; then
    echo "⚠️  No files staged for commit" >&2
    exit 2
fi

ISSUES=()

while IFS= read -r FILE; do
    # Skip if file doesn't exist (might have been deleted)
    [ ! -f "$FILE" ] && continue

    FILENAME=$(basename "$FILE")

    # Security: Check for environment files
    if [[ "$FILENAME" == .env* ]]; then
        ISSUES+=("🔒 .env file staged: $FILE (security risk)")
    fi

    # Code cleanliness (skip test files)
    if [[ ! "$FILE" =~ \.(test|spec)\. ]] && [[ ! "$FILE" =~ __tests__ ]]; then
        # Check for debug code
        if grep -q "console\.log(" "$FILE" 2>/dev/null; then
            ISSUES+=("🐛 console.log found in: $FILE (remove debug code)")
        fi

        if grep -q "debugger" "$FILE" 2>/dev/null; then
            ISSUES+=("🐛 debugger statement in: $FILE (remove breakpoint)")
        fi

        # Warn about TODOs
        if grep -q "TODO\|FIXME" "$FILE" 2>/dev/null; then
            echo "⚠️  TODO/FIXME found in: $FILE (consider creating issue)" >&2
        fi
    fi
done <<< "$STAGED_FILES"

if [ ${#ISSUES[@]} -gt 0 ]; then
    echo "❌ Code quality issues:" >&2
    printf '   %s\n' "${ISSUES[@]}" >&2
    echo "" >&2
    echo "Fix these before committing." >&2
    exit 2
fi

echo "✅ Code quality checks passed"
echo ""

# ============================================================================
# Check 3: Test Suite (CRITICAL)
# Reference: testing-guide.md (SOP fallback chain)
# ============================================================================
echo "🧪 Running FULL test suite..."
echo "   This ensures all tests pass before commit."
echo ""

TESTS_PASSED=false
TEST_COUNT=0

# Try common test commands
TEST_COMMANDS=(
    "bun test"
    "npm test"
    "npm run test"
    "pytest"
    "go test ./..."
    "cargo test"
    "php artisan test"
)

for CMD in "${TEST_COMMANDS[@]}"; do
    # Check if command exists
    MAIN_CMD=$(echo "$CMD" | cut -d' ' -f1)
    if ! command -v "$MAIN_CMD" &> /dev/null; then
        continue
    fi

    # Run tests
    if TEST_OUTPUT=$($CMD 2>&1); then
        # Extract test count
        if echo "$TEST_OUTPUT" | grep -qE '[0-9]+ (passing|passed|test)'; then
            TEST_COUNT=$(echo "$TEST_OUTPUT" | grep -oE '[0-9]+ (passing|passed|test)' | head -1 | grep -oE '[0-9]+')
        fi

        TESTS_PASSED=true
        break
    else
        # Tests failed
        echo "" >&2
        echo "═══════════════════════════════════════════════════════════" >&2
        echo "❌ TEST FAILURES DETECTED" >&2
        echo "═══════════════════════════════════════════════════════════" >&2
        echo "" >&2
        echo "$TEST_OUTPUT" >&2
        echo "" >&2
        echo "═══════════════════════════════════════════════════════════" >&2
        echo "❌ COMMIT BLOCKED: TESTS ARE FAILING" >&2
        echo "═══════════════════════════════════════════════════════════" >&2
        echo "" >&2
        echo "TDD Rule: Never commit with failing tests!" >&2
        echo "" >&2
        echo "To fix:" >&2
        echo "1. Review the test failures above" >&2
        echo "2. Fix the implementation or tests" >&2
        echo "3. Run: $CMD" >&2
        echo "4. When all tests pass, commit again" >&2
        echo "" >&2
        echo "Reference: testing-guide.md (TDD cycle - SOP)" >&2
        exit 2
    fi
done

if [ "$TESTS_PASSED" = false ]; then
    echo "❌ No test framework detected!" >&2
    echo "" >&2
    echo "Setup tests with: npm install -D jest" >&2
    echo "TDD requires tests for all code." >&2
    echo "" >&2
    echo "See: testing-guide.md (SOP)" >&2
    exit 2
fi

echo "✅ All tests passing ($TEST_COUNT tests)"
echo ""

# ============================================================================
# Check 4: Coverage (if available)
# Reference: CLAUDE.md (80% coverage minimum)
# ============================================================================
echo "📊 Checking test coverage..."

if command -v npm &> /dev/null; then
    if COVERAGE_OUTPUT=$(npm run test:coverage 2>&1 || npm run coverage 2>&1); then
        if echo "$COVERAGE_OUTPUT" | grep -qE 'All files[^0-9]+([0-9]+\.?[0-9]*)'; then
            COVERAGE=$(echo "$COVERAGE_OUTPUT" | grep -oE 'All files[^0-9]+([0-9]+\.?[0-9]*)' | grep -oE '[0-9]+\.?[0-9]*')
            echo "   Coverage: $COVERAGE%"

            if (( $(echo "$COVERAGE < 80" | bc -l) )); then
                echo "   ⚠️  Coverage below 80% target (allowed but not ideal)"
                echo "   Add more tests for critical paths"
            else
                echo "   ✅ Coverage meets 80% target"
            fi
        fi
    fi
else
    echo "   ℹ️  Coverage report not available"
fi
echo ""

# ============================================================================
# Check 5: Linting (if available)
# Reference: languages-and-style.md (SOP fallback chain)
# ============================================================================
echo "🔍 Running linter..."

if command -v npm &> /dev/null; then
    if npm run lint &> /dev/null; then
        echo "✅ No linting errors"
    else
        echo "⚠️  Linting errors found - fix recommended" >&2
    fi
else
    echo "   ℹ️  Linter not available"
fi
echo ""

# ============================================================================
# SUCCESS
# ============================================================================
echo "═══════════════════════════════════════════════════════════"
echo "✅ ALL PRE-COMMIT CHECKS PASSED"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📦 $(echo "$STAGED_FILES" | wc -l) files"
echo "🧪 $TEST_COUNT tests passing"
echo "✨ Ready to ship!"
echo ""

exit 0
