---
description: Simplify existing code complexity outside TDD workflow
---

# RPTC Helper: Simplify Existing Code

You are helping the user clean up existing code complexity outside the TDD workflow.

## Purpose

Standalone simplification tool for legacy code, technical debt, and existing complexity.

**Key Difference from Efficiency Agent**:
- **Efficiency Agent**: Embedded in TDD workflow, has plan context, runs automatically after implementation
- **Helper Simplify**: Standalone command, no plan context, manual invocation, works on ANY code

**Use Cases**:
- Legacy code cleanup
- Technical debt reduction
- External AI-generated code simplification
- Old RPTC code refactoring
- Pre-feature-work cleanup

## Arguments

- `[path]` - File or directory to simplify (required)
- `--auto-approve` - Skip approval gate (dangerous, use with caution)
- `--deep` - Use efficiency agent for comprehensive analysis (optional)

## Step 0: Load Configuration and Validation

### Step 0a: Load Configuration

**Load configuration**:

1. **Check if settings file exists**:
   - Use Read tool to read `.claude/settings.json`
   - If file doesn't exist or can't be read, use defaults (skip to step 3)

2. **Parse configuration** (extract these fields):
   - `rptc.artifactLocation` → ARTIFACT_LOC (default: ".rptc")
   - `rptc.docsLocation` → DOCS_LOC (default: "docs")
   - `rptc.testCoverageTarget` → COVERAGE_TARGET (default: 85)
   - `rptc.defaultThinkingMode` → THINKING_MODE (default: "think")

3. **Display loaded configuration**:
   ```text
   Configuration loaded:
     Artifact location: [ARTIFACT_LOC value]
     Test coverage target: [COVERAGE_TARGET]%
     Thinking mode: [THINKING_MODE]
   ```

**Use these values throughout the command execution.**

### Step 0b: Validate Arguments and Analysis Mode Selection

**Parse command arguments**:

```bash
# Extract arguments
TARGET_PATH="$1"
AUTO_APPROVE=false
DEEP_MODE=false

# Parse flags
for arg in "$@"; do
  case $arg in
    --auto-approve)
      AUTO_APPROVE=true
      ;;
    --deep)
      DEEP_MODE=true
      ;;
  esac
done

# Validate required argument
if [ -z "$TARGET_PATH" ]; then
  echo "❌ Error: Missing required argument"
  echo ""
  echo "Usage: /rptc:helper:simplify [path] [--auto-approve] [--deep]"
  echo ""
  echo "Examples:"
  echo "  /rptc:helper:simplify src/utils/helper.js"
  echo "  /rptc:helper:simplify src/utils/ --deep"
  echo "  /rptc:helper:simplify src/ --auto-approve"
  exit 1
fi
```

**Opportunity 1: Analysis Mode Selection**

If no `--deep` flag was provided, present analysis mode menu to user:

```text
Use AskUserQuestion tool:

Question: "Select analysis depth for code simplification"
Header: "Analysis Mode"
Options:
- Basic: "Basic analysis (quick scan)"
  Description: "Fast check for obvious simplifications"
- Deep: "Deep analysis (thorough review)"
  Description: "Comprehensive complexity analysis with Master Efficiency Agent"
- Auto: "Auto mode (recommended)"
  Description: "Intelligent depth based on codebase size"
MultiSelect: false

Capture response to: ANALYSIS_MODE
```

**Process mode selection**:

```bash
# If user selected via menu (not flag), set DEEP_MODE based on choice
if [ -z "$DEEP_MODE_SET_BY_FLAG" ]; then
  case "$ANALYSIS_MODE" in
    Basic)
      DEEP_MODE=false
      COMPLEXITY_THRESHOLD=15
      echo "Using BASIC analysis mode"
      ;;
    Deep)
      DEEP_MODE=true
      COMPLEXITY_THRESHOLD=8
      echo "Using DEEP analysis mode (Master Efficiency Agent)"
      ;;
    Auto)
      # Calculate threshold based on codebase size
      echo "Calculating optimal analysis depth..."
      FILE_COUNT=$(find src -type f 2>/dev/null | wc -l)
      if [ "$FILE_COUNT" -lt 50 ]; then
        DEEP_MODE=true
        COMPLEXITY_THRESHOLD=8
        echo "Auto mode: Using DEEP analysis (small codebase: $FILE_COUNT files)"
      else
        DEEP_MODE=false
        COMPLEXITY_THRESHOLD=12
        echo "Auto mode: Using BASIC analysis (large codebase: $FILE_COUNT files)"
      fi
      ;;
  esac
  echo ""
fi
```

### Step 0c: Validate Path

**Check if path exists**:

```bash
# Validate path exists
if [ ! -e "$TARGET_PATH" ]; then
  echo "❌ Error: File or directory not found"
  echo ""
  echo "Path: $TARGET_PATH"
  echo ""
  echo "Please check the path and try again."
  exit 1
fi

# Determine if file or directory
if [ -f "$TARGET_PATH" ]; then
  TARGET_TYPE="file"
  echo "🔍 Analyzing file: $TARGET_PATH"
elif [ -d "$TARGET_PATH" ]; then
  TARGET_TYPE="directory"
  echo "🔍 Analyzing directory: $TARGET_PATH"
else
  echo "❌ Error: Path is not a file or directory"
  exit 1
fi

echo ""
```

### Step 0d: Validate Workspace

**Check workspace initialization**:

```bash
# Check if workspace initialized
if [ ! -f ".claude/settings.json" ]; then
  echo "⚠️  Warning: Workspace not initialized"
  echo ""
  echo "This command works better with an initialized RPTC workspace."
  echo "Run /rptc:admin:init to initialize workspace with proper configuration."
  echo ""
  echo "Continuing with defaults..."
  echo ""
fi
```

## Step 1: Analysis Phase

### Step 1a: Identify Target Files

**Collect files to analyze**:

**Collect code files**:

If `TARGET_TYPE` is "file":
- Set CODE_FILES to single file: `$TARGET_PATH`
- Display: "📄 Target: 1 file"

If `TARGET_TYPE` is "directory":
- Use Glob tool to find code files in `$TARGET_PATH`:
  - Pattern 1: `**/*.{js,ts,jsx,tsx}` (JavaScript/TypeScript files)
  - Pattern 2: `**/*.{py,java,go,cs,rb,php}` (Other languages)
  - Exclude: Skip any results containing `/node_modules/` or `/.git/` in path
- Combine all results from both Glob calls into CODE_FILES list
- Display: "📄 Target: [N] files found"

Display blank line.

**Validate files found**:

If CODE_FILES list is empty:
```text
❌ Error: No code files found in path

Path: [TARGET_PATH]

Make sure the path contains code files (.js, .ts, .py, .java, .go, etc.)
```

Exit with error if no files found.

### Step 1b: Check for Tests

**Detect test coverage**:

Initialize tracking:
- TESTS_FOUND = false
- MISSING_TESTS = empty list

Display:
```text
🧪 Checking for test coverage...

```

For each code file in CODE_FILES:

1. **Extract file info** (parse in Claude, no bash needed):
   - Get filename without extension (e.g., "helper.js" → "helper")
   - Get directory path (e.g., "src/utils/helper.js" → "src/utils")

2. **Check for test files using Glob tool** (try all common patterns):
   - Pattern 1: `[dir]/[base].test.*`
   - Pattern 2: `[dir]/[base].spec.*`
   - Pattern 3: `[dir]/__tests__/[base].*`
   - Pattern 4: `tests/**/[base].*`
   - Pattern 5: `test/**/[base].*`

3. **Determine if tests exist**:
   - If ANY Glob returns results → tests exist for this file
     - Set TESTS_FOUND = true
   - If NO Glob returns results → add file to MISSING_TESTS list

**Report test status**:

If TESTS_FOUND is true:
  - If MISSING_TESTS list is not empty:
    ```text
    ⚠️  Partial test coverage detected

    Files without tests ([count]):
      - [file1]
      - [file2]

    ⚠️  Warning: Simplifying code without tests is risky!
       Changes may introduce bugs without detection.

    ```
  - If MISSING_TESTS list is empty:
    ```text
    ✅ All files have test coverage

    ```

If TESTS_FOUND is false:
  ```text
  🚨 No tests found for any files!

  ⚠️  CRITICAL WARNING: Simplifying code without tests is VERY risky!
     You will have NO verification that behavior is preserved.

  Recommendation: Write tests first, then simplify.

  ```

  **Opportunity 2: Test Warning Response**

  If `AUTO_APPROVE` is false:

    ```text
    Use AskUserQuestion tool:

    Question: "No tests found for files to simplify. How to proceed?"
    Header: "No Tests"
    Options:
    - Continue: "Continue anyway (risky)"
      Description: "Simplify without test coverage - behavior verification impossible"
    - Skip: "Skip untested files"
      Description: "Only simplify files with tests"
    - Abort: "Abort operation"
      Description: "Don't simplify anything - write tests first"
    MultiSelect: false

    Capture response to: TEST_WARNING_DECISION
    ```

    **Process test warning decision**:

    ```bash
    case "$TEST_WARNING_DECISION" in
      Continue)
        echo ""
        echo "⚠️  WARNING: Proceeding without test coverage"
        echo "   Changes will NOT be verified by tests!"
        echo ""
        # Continue to analysis
        ;;
      Skip)
        echo ""
        echo "Filtering to only include files with tests..."
        # Filter CODE_FILES list to only include files with tests
        # (Remove files in MISSING_TESTS list from CODE_FILES)
        # If filtered list is empty, abort
        if [ "${#CODE_FILES[@]}" -eq 0 ]; then
          echo "❌ Error: No files with tests remaining after filter"
          echo ""
          echo "Write tests first, then re-run this command."
          exit 1
        fi
        echo "Continuing with ${#CODE_FILES[@]} tested files"
        echo ""
        ;;
      Abort)
        echo ""
        echo "Operation cancelled - add tests first"
        echo ""
        echo "Write tests, then re-run: /rptc:helper:simplify $TARGET_PATH"
        exit 0
        ;;
    esac
    ```

  If `AUTO_APPROVE` is true:
    - Display: "⚠️  AUTO-APPROVE enabled: Proceeding despite missing tests..."
    - Display blank line and continue.

### Step 1c: Perform Analysis

**Analyze code complexity**:

```text
═══════════════════════════════════════════════════════
  ANALYZING CODE COMPLEXITY
═══════════════════════════════════════════════════════
```

**If `--deep` flag is set**, delegate to efficiency agent:

```text
Mode: DEEP (Efficiency Agent)

Delegating to Master Efficiency Agent for comprehensive analysis...

[Use Task tool with subagent_type="master-efficiency-agent"]

Prompt:
## Context:
User has requested standalone simplification of existing code (outside TDD workflow).

**Target Files:**
[List files with content]

**Mode:** Simplification Only (no plan context available)

## Your Task:
Analyze the provided code files using the Post-TDD Refactoring SOP and identify simplification opportunities.

## SOPs to Reference (use fallback chain):
1. .rptc/sop/post-tdd-refactoring.md
2. ~/.claude/global/sop/post-tdd-refactoring.md
3. ${CLAUDE_PLUGIN_ROOT}/sop/post-tdd-refactoring.md

## Analysis Requirements:
Follow the 5-phase refactoring workflow from Post-TDD Refactoring SOP:

**Phase 1: Pre-Analysis**
- Baseline metrics (LOC, complexity, duplication)
- Code simplicity metrics (abstraction count, single-use patterns)

**Phase 2: Dead Code Detection**
- Unused imports, variables, functions, classes
- Unreachable code paths
- Commented-out code

**Phase 3: Complexity Reduction**
- High-complexity areas (cyclomatic >10, cognitive >15)
- Refactoring patterns applicable (extract method, decompose conditional, etc.)

**Phase 4: Readability Issues**
- Poor naming (generic, misleading, inconsistent)
- Comment audit (redundant vs. valuable)

**Phase 5: KISS/YAGNI Violations**
- AI over-engineering anti-patterns (5 patterns)
- Rule of Three violations
- Speculative features (YAGNI)

## Output Format:
Provide a structured report with:

1. **Complexity Analysis**:
   - Baseline metrics (LOC, complexity scores)
   - High-complexity areas identified

2. **Simplification Opportunities**:
   - Dead code to remove (with locations)
   - Complexity reduction patterns (with examples)
   - Readability improvements (with suggestions)
   - KISS/YAGNI violations (with proposed fixes)

3. **Proposed Changes**:
   - Specific refactoring actions
   - Expected impact (LOC reduction, complexity reduction)
   - Risk assessment (test coverage, breaking changes)

4. **Priority Ranking**:
   - High priority: Dead code, critical complexity
   - Medium priority: Readability, moderate complexity
   - Low priority: Nice-to-have simplifications

**Thinking Mode:** [THINKING_MODE from config]

[End of delegation]
```

**If `--deep` flag is NOT set**, use basic analysis:

Display:
```text
Mode: BASIC (Bash-based analysis)

For comprehensive analysis, use --deep flag to invoke Efficiency Agent.

📊 Basic Complexity Metrics:

```

**Lines of code analysis**:

Initialize: total_lines = 0

For each code file in CODE_FILES:
1. Use Read tool: `Read(file_path: "[file]")`
2. Extract line count from Read tool output
3. Add to total_lines (calculate in Claude)
4. Display: "  [file]: [lines] lines"

After all files processed:
```text

Total Lines: [total_lines]

🔍 Basic Pattern Detection:

Checking for potential unused imports...
```

**Import counting analysis**:

Initialize: unused_count = 0

For each code file in CODE_FILES:
1. Use Grep tool:
   - Pattern: `^import|^from.*import`
   - File: [current file]
   - Output mode: "count"
2. If count > 20:
   - Display: "  ⚠️  [file]: [count] imports (may have unused)"
   - Increment unused_count

If unused_count is 0:
  Display: "  ✅ No files with excessive imports"

Display blank line.

Display: "Checking for oversized files (>500 lines)..."

**File size analysis**:

Initialize: long_files = 0

For each code file in CODE_FILES:
1. Use Read tool: `Read(file_path: "[file]")`
2. Extract line count from Read tool output
3. If count > 500:
   - Display: "  🚨 [file]: [count] lines (exceeds 500 line limit)"
   - Increment long_files

If long_files is 0:
  Display: "  ✅ All files within size limits"

Display blank line.

Display: "Checking for dead code indicators..."

**Dead code analysis**:

Initialize: dead_code = false

For each code file in CODE_FILES:
1. Use Grep tool:
   - Pattern: `^\\s*//\\s*(function|const|class|def)`
   - File: [current file]
   - Output mode: "count"
2. If count > 3:
   - Display: "  ⚠️  [file]: [count] commented-out definitions"
   - Set dead_code = true

If dead_code is false:
  Display: "  ✅ No obvious dead code detected"

Display blank line.

**Summary**:

```text
═══════════════════════════════════════════════════════

📋 Basic Analysis Summary:

  Files analyzed: [count of CODE_FILES]
  Total lines: [total_lines]
  Oversized files: [long_files]
  Potential issues detected: Yes

💡 Recommendation: Use --deep flag for comprehensive analysis
   /rptc:helper:simplify [TARGET_PATH] --deep

```

## Step 2: User Approval Gate

**Present findings and get approval**:

```text
═══════════════════════════════════════════════════════
  PROPOSED SIMPLIFICATIONS
═══════════════════════════════════════════════════════

[If --deep mode was used, show agent's proposed changes]
[If basic mode, show detected issues]

Files to be modified: [N]
Estimated impact:
  - Lines to remove: ~[X]
  - Complexity reduction: ~[Y]%
  - Risk level: [Low/Medium/High based on test coverage]

═══════════════════════════════════════════════════════
```

**If `--auto-approve` flag is set**:

```text
⚠️  AUTO-APPROVE MODE ENABLED

Changes will be applied WITHOUT review!

Safety measures:
  ✅ Backup created before changes
  ✅ Tests will run after changes
  ✅ Rollback available if tests fail

Proceeding with automatic changes...
```

**If `--auto-approve` flag is NOT set**:

**Opportunity 3: Approval Gate (CRITICAL SAFETY)**

```text
Use AskUserQuestion tool:

Question: "Review proposed simplifications. Ready to apply changes?"
Header: "Approve Changes"
Options:
- Apply: "Apply all changes"
  Description: "Proceed with simplification - all proposed changes will be applied"
- Review: "Review details again"
  Description: "See detailed before/after for each proposed change"
- ApplyPartial: "Select specific changes"
  Description: "Choose which simplifications to apply (interactive selection)"
- Cancel: "Cancel"
  Description: "Don't modify any files - abort operation safely"
MultiSelect: false

Capture response to: APPROVAL_DECISION
```

**Process approval decision**:

```bash
case "$APPROVAL_DECISION" in
  Apply)
    echo ""
    echo "✅ Approved - proceeding to Phase 3 (Apply Changes)"
    echo ""
    # Continue to Phase 3
    ;;
  Review)
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  DETAILED CHANGE REVIEW"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    # Display detailed diff for each file
    for file in "${PROPOSED_CHANGES[@]}"; do
      echo "File: $file"
      echo "─────────────────────────────────────────────────────"
      # Show before/after comparison
      echo "[Show detailed changes]"
      echo ""
    done
    echo "═══════════════════════════════════════════════════════"
    echo ""
    # Loop back to approval menu (re-show AskUserQuestion)
    ;;
  ApplyPartial)
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  SELECT CHANGES TO APPLY"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    # Show file-by-file selection menu
    # For each proposed change, ask: "Apply this change? [y/n]"
    # Build filtered list of approved changes
    # Apply only selected changes
    echo "✅ Partial selection complete"
    echo "   Applying ${SELECTED_COUNT} of ${TOTAL_COUNT} changes"
    echo ""
    ;;
  Cancel)
    echo ""
    echo "❌ Simplification cancelled by user"
    echo ""
    echo "No changes were made."
    echo ""
    echo "To analyze with different settings:"
    echo "  /rptc:helper:simplify $TARGET_PATH --deep"
    exit 0
    ;;
esac
```

## Step 3: Application Phase

**If user approved (or auto-approve enabled)**:

### Step 3a: Create Backup

```bash
echo ""
echo "🔒 Creating safety backup..."
echo ""

# Create backup directory
BACKUP_DIR="${ARTIFACT_LOC}/backups/simplify-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup all target files
for file in "${CODE_FILES[@]}"; do
  # Preserve directory structure
  rel_path="${file#./}"
  backup_path="$BACKUP_DIR/$rel_path"
  mkdir -p "$(dirname "$backup_path")"
  cp "$file" "$backup_path"
done

echo "✅ Backup created: $BACKUP_DIR"
echo ""

# Git stash if in git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "🔒 Creating git stash as additional safety..."
  git stash push -m "Pre-simplify backup: $TARGET_PATH"
  echo "✅ Git stash created"
  echo ""
fi
```

### Step 3b: Apply Changes

```text
═══════════════════════════════════════════════════════
  APPLYING SIMPLIFICATIONS
═══════════════════════════════════════════════════════
```

**If deep mode was used**, apply changes from efficiency agent report:

```text
Applying changes from Efficiency Agent recommendations...

[Use Edit tool to apply each recommended change]

Progress:
  - Dead code removal... ✅
  - Complexity reduction... ✅
  - Readability improvements... ✅
  - KISS/YAGNI fixes... ✅

✅ All simplifications applied
```

**If basic mode**, apply basic improvements:

```text
Applying basic improvements...

Available actions:
  - Remove commented-out code
  - Auto-format code (prettier/black/gofmt)
  - Fix obvious issues

[Apply available improvements using Edit tool]

✅ Basic improvements applied
```

## Step 4: Verification Phase

### Step 4a: Run Tests

```bash
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  RUNNING TESTS"
echo "═══════════════════════════════════════════════════════"
echo ""

# Detect test runner
TEST_RUNNER=""
if [ -f "package.json" ]; then
  TEST_RUNNER="npm test"
elif [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
  TEST_RUNNER="pytest"
elif [ -f "go.mod" ]; then
  TEST_RUNNER="go test ./..."
elif [ -f "pom.xml" ]; then
  TEST_RUNNER="mvn test"
fi

if [ -z "$TEST_RUNNER" ]; then
  echo "⚠️  Warning: Could not auto-detect test runner"
  echo ""
  echo "Please run tests manually to verify changes:"
  echo "  [your test command]"
  echo ""
  TESTS_PASSED="unknown"
else
  echo "Running: $TEST_RUNNER"
  echo ""

  # Run tests
  if $TEST_RUNNER; then
    echo ""
    echo "✅ ALL TESTS PASSED"
    TESTS_PASSED="yes"
  else
    echo ""
    echo "❌ TESTS FAILED"
    TESTS_PASSED="no"
  fi
fi
```

### Step 4b: Handle Test Failures

**If tests failed**:

```text
═══════════════════════════════════════════════════════
  TEST FAILURES DETECTED
═══════════════════════════════════════════════════════

⚠️  Changes may have introduced bugs!
```

**Opportunity 4: Test Failure Response**

```text
Use AskUserQuestion tool:

Question: "Tests failed after simplification. How to recover?"
Header: "Tests Failed"
Options:
- Revert: "Revert all changes"
  Description: "Restore original code from backup - safest option"
- RevertPartial: "Revert failed files only"
  Description: "Keep changes that passed tests, restore only failed files"
- Review: "Review test failures"
  Description: "See detailed test output and what changed"
- Force: "Keep changes anyway (dangerous)"
  Description: "Not recommended - you'll need to fix failures manually"
MultiSelect: false

Capture response to: TEST_FAIL_DECISION
```

**Process test failure decision**:

```bash
case "$TEST_FAIL_DECISION" in
  Revert)
    echo ""
    echo "🔄 Rolling back changes..."
    echo ""

    # Restore from backup
    for file in "${CODE_FILES[@]}"; do
      rel_path="${file#./}"
      backup_path="$BACKUP_DIR/$rel_path"
      if [ -f "$backup_path" ]; then
        cp "$backup_path" "$file"
        echo "  ✅ Restored: $file"
      fi
    done

    echo ""
    echo "✅ Rollback complete - all files restored from backup"
    echo ""
    echo "Backup preserved at: $BACKUP_DIR"
    echo ""
    echo "To investigate, compare backup with attempted changes."
    exit 1
    ;;
  RevertPartial)
    echo ""
    echo "🔄 Rolling back only failed files..."
    echo ""

    # Restore only files with failing tests
    # (Identify failed files from test output)
    # Keep changes to files with passing tests
    for file in "${FAILED_FILES[@]}"; do
      rel_path="${file#./}"
      backup_path="$BACKUP_DIR/$rel_path"
      if [ -f "$backup_path" ]; then
        cp "$backup_path" "$file"
        echo "  ✅ Restored: $file"
      fi
    done

    echo ""
    echo "✅ Partial rollback complete"
    echo "   Reverted: ${#FAILED_FILES[@]} files"
    echo "   Kept changes: ${#PASSED_FILES[@]} files"
    echo ""
    exit 1
    ;;
  Review)
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  TEST FAILURE DETAILS"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    # Display full test output with failures
    echo "[Show detailed test output]"
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  CHANGES MADE"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    # Show diff for each file
    for file in "${CODE_FILES[@]}"; do
      rel_path="${file#./}"
      backup_path="$BACKUP_DIR/$rel_path"

      echo ""
      echo "Changes in: $file"
      echo "─────────────────────────────────────────────────────"
      diff -u "$backup_path" "$file" || true
      echo ""
    done
    echo ""
    # Loop back to test failure menu (re-show AskUserQuestion)
    ;;
  Force)
    echo ""
    echo "⚠️  WARNING: Keeping changes despite test failures"
    echo ""
    echo "You are responsible for fixing test failures manually."
    echo ""
    echo "Backup available at: $BACKUP_DIR"
    echo ""
    echo "To restore manually:"
    echo "  cp -r $BACKUP_DIR/* ./"
    echo ""
    exit 0
    ;;
esac
```

### Step 4c: Success Report

**If tests passed**:

```text
═══════════════════════════════════════════════════════
  SIMPLIFICATION COMPLETE ✅
═══════════════════════════════════════════════════════

Changes applied successfully:

Files modified: [N]
Lines removed: [X]
Tests passing: ✅ Yes
Test coverage: [Y]% (target: [COVERAGE_TARGET]%)

Improvements:
  ✅ Dead code removed
  ✅ Complexity reduced
  ✅ Readability improved
  ✅ KISS/YAGNI violations fixed

Backup location: $BACKUP_DIR

Code Health: [🟢 Improved / 🟡 Moderate / 🔴 Needs Work]

═══════════════════════════════════════════════════════
NEXT STEPS
═══════════════════════════════════════════════════════

1. Review the changes:
   git diff

2. Commit the improvements:
   git add .
   git commit -m "refactor: simplify [description]"

3. (Optional) Remove backup after verification:
   rm -rf $BACKUP_DIR

Recommendation: Keep backup until changes are committed and verified in production.
```

## Edge Case Handling

### No Simplification Opportunities

**If analysis finds nothing to improve**:

```text
═══════════════════════════════════════════════════════
  ANALYSIS COMPLETE
═══════════════════════════════════════════════════════

🎉 Excellent code quality!

No simplification opportunities found.

Files analyzed: [N]
Total lines: [X]

Code Health: 🟢 Already optimal

Metrics:
  ✅ No dead code detected
  ✅ Complexity within limits
  ✅ Naming conventions followed
  ✅ No KISS/YAGNI violations

This code is well-written and maintainable.

═══════════════════════════════════════════════════════
```

### Partial Simplification

**If some files can be improved but others cannot**:

```text
═══════════════════════════════════════════════════════
  PARTIAL SIMPLIFICATION AVAILABLE
═══════════════════════════════════════════════════════

Files analyzed: [N]
Simplifiable: [X]
Already optimal: [Y]
```

**Opportunity 5: Partial Simplification (Edge Case)**

```text
Use AskUserQuestion tool:

Question: "Some files simplified successfully, others had issues. What to do?"
Header: "Partial Success"
Options:
- Keep: "Keep successful changes"
  Description: "Commit what worked - ${SUCCESS_COUNT} files improved"
- RevertAll: "Revert everything"
  Description: "All-or-nothing approach - discard all changes"
- Review: "Review what succeeded vs failed"
  Description: "See detailed status for each file"
- Retry: "Retry failed files"
  Description: "Try again with different settings or manual fixes"
MultiSelect: false

Capture response to: PARTIAL_DECISION
```

**Process partial simplification decision**:

```bash
case "$PARTIAL_DECISION" in
  Keep)
    echo ""
    echo "✅ Keeping ${SUCCESS_COUNT} successful changes"
    echo ""
    echo "Successfully simplified:"
    for file in "${SUCCESS_FILES[@]}"; do
      echo "  ✅ $file"
    done
    echo ""
    echo "Failed files (not modified):"
    for file in "${FAILED_FILES[@]}"; do
      echo "  ❌ $file"
    done
    echo ""
    echo "You can retry failed files manually:"
    echo "  /rptc:helper:simplify [failed_file] --deep"
    echo ""
    exit 0
    ;;
  RevertAll)
    echo ""
    echo "🔄 Reverting ALL changes (including successful ones)..."
    echo ""

    # Restore all files (even successful ones)
    for file in "${CODE_FILES[@]}"; do
      rel_path="${file#./}"
      backup_path="$BACKUP_DIR/$rel_path"
      if [ -f "$backup_path" ]; then
        cp "$backup_path" "$file"
        echo "  ✅ Restored: $file"
      fi
    done

    echo ""
    echo "✅ All changes reverted - back to original state"
    echo ""
    echo "Backup preserved at: $BACKUP_DIR"
    exit 1
    ;;
  Review)
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  DETAILED STATUS BREAKDOWN"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "Successful Simplifications (${SUCCESS_COUNT} files):"
    for file in "${SUCCESS_FILES[@]}"; do
      echo "  ✅ $file"
      echo "     Lines removed: [N]"
      echo "     Complexity reduction: [X]%"
      echo ""
    done
    echo ""
    echo "Failed Simplifications (${#FAILED_FILES[@]} files):"
    for file in "${FAILED_FILES[@]}"; do
      echo "  ❌ $file"
      echo "     Reason: [error description]"
      echo ""
    done
    echo "═══════════════════════════════════════════════════════"
    echo ""
    # Loop back to partial simplification menu (re-show AskUserQuestion)
    ;;
  Retry)
    echo ""
    echo "🔄 Retrying failed files with different settings..."
    echo ""
    echo "Failed files to retry:"
    for file in "${FAILED_FILES[@]}"; do
      echo "  - $file"
    done
    echo ""
    echo "Recommended: Try with --deep flag for comprehensive analysis"
    echo ""
    # Re-run simplification on failed files only
    # With different analysis settings (e.g., force deep mode)
    # Or exit and let user manually retry
    echo "To retry manually:"
    echo "  /rptc:helper:simplify [file] --deep"
    exit 1
    ;;
esac
```

### Invalid File Types

**If path contains non-code files**:

```text
⚠️  Warning: Non-code files detected

The following files will be skipped:
  - [file1.txt]
  - [file2.md]
  - [file3.json]

Only code files will be analyzed.

Continue? [y/n]:
```

## Configuration Support

**Read from `.claude/settings.json`** (if exists):

```json
{
  "rptc": {
    "simplify": {
      "autoBackup": true,
      "runTests": true,
      "excludePatterns": ["node_modules/**", "dist/**"],
      "maxFileSizeLines": 500,
      "complexityThreshold": 10
    }
  }
}
```

**Configuration options**:
- `autoBackup` (default: true): Create backup before changes
- `runTests` (default: true): Run tests after simplification
- `excludePatterns` (default: ["node_modules/**"]): Paths to exclude
- `maxFileSizeLines` (default: 500): Warn if files exceed this
- `complexityThreshold` (default: 10): Cyclomatic complexity warning threshold

## Examples

### Example 1: Simplify Single File (Basic Mode)

```text
User: /rptc:helper:simplify src/utils/helper.js

Agent:
🔍 Analyzing file: src/utils/helper.js

Configuration loaded:
  Artifact location: .rptc
  Test coverage target: 85%

🧪 Checking for test coverage...
✅ Test found: src/utils/helper.test.js

═══════════════════════════════════════════════════════
  ANALYZING CODE COMPLEXITY
═══════════════════════════════════════════════════════

Mode: BASIC (Bash-based analysis)

📊 Basic Complexity Metrics:
  src/utils/helper.js: 342 lines

Total Lines: 342

🔍 Basic Pattern Detection:
  ✅ No files with excessive imports
  ✅ All files within size limits
  ⚠️  3 commented-out definitions detected

═══════════════════════════════════════════════════════

📋 Basic Analysis Summary:
  Files analyzed: 1
  Total lines: 342
  Potential issues: Commented-out code

💡 Recommendation: Use --deep flag for comprehensive analysis

═══════════════════════════════════════════════════════
  PROPOSED SIMPLIFICATIONS
═══════════════════════════════════════════════════════

Files to be modified: 1
Estimated impact:
  - Lines to remove: ~15
  - Risk level: Low (tests exist)

Review the proposed changes above.

Apply these simplifications? [y/n/s]: y

🔒 Creating safety backup...
✅ Backup created: .rptc/backups/simplify-20250125-143022

═══════════════════════════════════════════════════════
  APPLYING SIMPLIFICATIONS
═══════════════════════════════════════════════════════

Applying basic improvements...
  ✅ Removed 15 lines of commented-out code
  ✅ Auto-formatted code

═══════════════════════════════════════════════════════
  RUNNING TESTS
═══════════════════════════════════════════════════════

Running: npm test

✅ ALL TESTS PASSED

═══════════════════════════════════════════════════════
  SIMPLIFICATION COMPLETE ✅
═══════════════════════════════════════════════════════

Changes applied successfully!

Files modified: 1
Lines removed: 15
Tests passing: ✅ Yes

Review changes:
  git diff src/utils/helper.js

Commit when ready:
  git add .
  git commit -m "refactor: remove dead code from helper.js"
```

### Example 2: Deep Analysis of Directory

```text
User: /rptc:helper:simplify src/utils/ --deep

Agent:
🔍 Analyzing directory: src/utils/

Configuration loaded:
  Artifact location: .rptc
  Thinking mode: think

📄 Target: 5 files found

🧪 Checking for test coverage...
✅ All files have test coverage

═══════════════════════════════════════════════════════
  ANALYZING CODE COMPLEXITY
═══════════════════════════════════════════════════════

Mode: DEEP (Efficiency Agent)

Delegating to Master Efficiency Agent...

[Agent performs comprehensive 5-phase analysis]

Analysis complete! Report generated.

═══════════════════════════════════════════════════════
  PROPOSED SIMPLIFICATIONS
═══════════════════════════════════════════════════════

Files to be modified: 3 of 5

High Priority:
  1. Remove abstract base class with single implementation (YAGNI)
     - File: src/utils/BaseValidator.ts
     - Impact: -45 lines, reduced abstraction

  2. Inline helper function (called only once)
     - File: src/utils/formatter.ts
     - Impact: -12 lines

Medium Priority:
  3. Extract method (complexity 15 → 6)
     - File: src/utils/parser.ts
     - Impact: Improved readability

Estimated total impact:
  - Lines to remove: ~57
  - Complexity reduction: ~35%
  - Risk level: Low (100% test coverage)

Apply these simplifications? [y/n/s]: y

[Proceeds with backup, application, testing, success]
```

### Example 3: Auto-Approve with Rollback

```text
User: /rptc:helper:simplify src/legacy.js --auto-approve

Agent:
🔍 Analyzing file: src/legacy.js

⚠️  Warning: Workspace not initialized
Continuing with defaults...

🧪 Checking for test coverage...
🚨 No tests found for any files!

⚠️  CRITICAL WARNING: Simplifying without tests is VERY risky!

⚠️  AUTO-APPROVE MODE ENABLED
Proceeding despite missing tests...

[Analysis and changes applied]

═══════════════════════════════════════════════════════
  RUNNING TESTS
═══════════════════════════════════════════════════════

⚠️  Warning: Could not auto-detect test runner
Please run tests manually.

═══════════════════════════════════════════════════════
  SIMPLIFICATION COMPLETE (UNVERIFIED)
═══════════════════════════════════════════════════════

⚠️  Changes applied WITHOUT test verification!

Files modified: 1
Lines removed: 23
Tests passing: Unknown (no tests found)

IMPORTANT: Manually verify behavior is preserved!

Backup available: .rptc/backups/simplify-20250125-143522

To rollback if needed:
  cp .rptc/backups/simplify-20250125-143522/src/legacy.js src/legacy.js
```

## Notes

- **Safety First**: Always backup before changes, always run tests after
- **Incremental**: Apply changes category by category for safety
- **Test Coverage**: Strong test coverage required for safe simplification
- **SOP Integration**: References `post-tdd-refactoring.md` via fallback chain
- **Standalone**: Works without efficiency agent (basic mode), enhanced with agent (deep mode)
- **User Control**: Approval gate ensures user reviews before changes
- **Rollback**: Backup mechanism allows safe experimentation

## Success Criteria

- [ ] Command created at `rptc-workflow/commands/helper-simplify.md`
- [ ] Accepts file or directory path argument
- [ ] Validates path exists and contains code files
- [ ] Checks for test coverage and warns if missing
- [ ] Performs analysis (basic or deep mode)
- [ ] Shows proposed changes to user
- [ ] User approval gate implemented (skippable with `--auto-approve`)
- [ ] Creates backup before applying changes
- [ ] Applies simplifications safely
- [ ] Runs tests automatically (if test runner detected)
- [ ] Detects test failures and offers rollback
- [ ] References `post-tdd-refactoring.md` SOP via fallback chain
- [ ] Works standalone (no efficiency agent required)
- [ ] Enhanced with efficiency agent (when `--deep` flag used)
- [ ] Handles edge cases (no tests, no simplifications, test failures)
- [ ] Provides clear success/failure reporting

---

_This command is part of RPTC v2.0 Phase 5 Optional Extensions (Quick Wins)_
_Complements Efficiency Agent by working on ANY code, not just new TDD implementations_
