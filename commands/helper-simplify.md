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

### Step 0b: Validate Arguments

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

```bash
# Create list of code files
if [ "$TARGET_TYPE" = "file" ]; then
  CODE_FILES=("$TARGET_PATH")
  echo "📄 Target: 1 file"
elif [ "$TARGET_TYPE" = "directory" ]; then
  # Find code files (common extensions)
  CODE_FILES=($(find "$TARGET_PATH" -type f \( \
    -name "*.js" -o \
    -name "*.ts" -o \
    -name "*.jsx" -o \
    -name "*.tsx" -o \
    -name "*.py" -o \
    -name "*.java" -o \
    -name "*.go" -o \
    -name "*.cs" -o \
    -name "*.rb" -o \
    -name "*.php" \
  \) -not -path "*/node_modules/*" -not -path "*/.git/*"))

  echo "📄 Target: ${#CODE_FILES[@]} files found"
fi

echo ""

# Validate files found
if [ ${#CODE_FILES[@]} -eq 0 ]; then
  echo "❌ Error: No code files found in path"
  echo ""
  echo "Path: $TARGET_PATH"
  echo ""
  echo "Make sure the path contains code files (.js, .ts, .py, .java, .go, etc.)"
  exit 1
fi
```

### Step 1b: Check for Tests

**Detect test coverage**:

```bash
# Check if tests exist for these files
TESTS_FOUND=false
MISSING_TESTS=()

echo "🧪 Checking for test coverage..."
echo ""

for file in "${CODE_FILES[@]}"; do
  # Derive potential test file names
  base_name=$(basename "$file" | sed 's/\.[^.]*$//')
  dir_name=$(dirname "$file")

  # Common test file patterns
  test_patterns=(
    "${dir_name}/${base_name}.test.*"
    "${dir_name}/${base_name}.spec.*"
    "${dir_name}/__tests__/${base_name}.*"
    "tests/*/${base_name}.*"
    "test/*/${base_name}.*"
  )

  # Check if any test file exists
  test_exists=false
  for pattern in "${test_patterns[@]}"; do
    if ls $pattern 2>/dev/null | grep -q .; then
      test_exists=true
      TESTS_FOUND=true
      break
    fi
  done

  if [ "$test_exists" = false ]; then
    MISSING_TESTS+=("$file")
  fi
done

# Report test status
if [ "$TESTS_FOUND" = true ]; then
  if [ ${#MISSING_TESTS[@]} -gt 0 ]; then
    echo "⚠️  Partial test coverage detected"
    echo ""
    echo "Files without tests (${#MISSING_TESTS[@]}):"
    for file in "${MISSING_TESTS[@]}"; do
      echo "  - $file"
    done
    echo ""
    echo "⚠️  Warning: Simplifying code without tests is risky!"
    echo "   Changes may introduce bugs without detection."
    echo ""
  else
    echo "✅ All files have test coverage"
    echo ""
  fi
else
  echo "🚨 No tests found for any files!"
  echo ""
  echo "⚠️  CRITICAL WARNING: Simplifying code without tests is VERY risky!"
  echo "   You will have NO verification that behavior is preserved."
  echo ""
  echo "Recommendation: Write tests first, then simplify."
  echo ""

  # Require explicit confirmation if no tests
  if [ "$AUTO_APPROVE" = false ]; then
    read -p "Continue without tests? [y/N]: " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
      echo ""
      echo "Aborting. Write tests first, then re-run this command."
      exit 0
    fi
    echo ""
  fi
fi
```

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

**If `--deep` flag is NOT set**, use basic bash analysis:

```bash
echo "Mode: BASIC (Bash-based analysis)"
echo ""
echo "For comprehensive analysis, use --deep flag to invoke Efficiency Agent."
echo ""

# Basic metrics collection
echo "📊 Basic Complexity Metrics:"
echo ""

# Lines of code
total_lines=0
for file in "${CODE_FILES[@]}"; do
  lines=$(wc -l < "$file")
  total_lines=$((total_lines + lines))
  echo "  $file: $lines lines"
done

echo ""
echo "Total Lines: $total_lines"
echo ""

# Basic pattern detection
echo "🔍 Basic Pattern Detection:"
echo ""

# Unused imports (basic heuristic)
echo "Checking for potential unused imports..."
unused_count=0
for file in "${CODE_FILES[@]}"; do
  # This is a simplified check - not perfect but helpful
  imports=$(grep -E "^import|^from.*import" "$file" 2>/dev/null | wc -l)
  if [ "$imports" -gt 20 ]; then
    echo "  ⚠️  $file: $imports imports (may have unused)"
    unused_count=$((unused_count + 1))
  fi
done

if [ "$unused_count" -eq 0 ]; then
  echo "  ✅ No files with excessive imports"
fi
echo ""

# Long files (>500 lines)
echo "Checking for oversized files (>500 lines)..."
long_files=0
for file in "${CODE_FILES[@]}"; do
  lines=$(wc -l < "$file")
  if [ "$lines" -gt 500 ]; then
    echo "  🚨 $file: $lines lines (exceeds 500 line limit)"
    long_files=$((long_files + 1))
  fi
done

if [ "$long_files" -eq 0 ]; then
  echo "  ✅ All files within size limits"
fi
echo ""

# Dead code indicators
echo "Checking for dead code indicators..."
dead_code=false

# Commented-out code
for file in "${CODE_FILES[@]}"; do
  commented=$(grep -E "^\\s*//\\s*(function|const|class|def)" "$file" 2>/dev/null | wc -l)
  if [ "$commented" -gt 3 ]; then
    echo "  ⚠️  $file: $commented commented-out definitions"
    dead_code=true
  fi
done

if [ "$dead_code" = false ]; then
  echo "  ✅ No obvious dead code detected"
fi
echo ""

# Summary
echo "═══════════════════════════════════════════════════════"
echo ""
echo "📋 Basic Analysis Summary:"
echo ""
echo "  Files analyzed: ${#CODE_FILES[@]}"
echo "  Total lines: $total_lines"
echo "  Oversized files: $long_files"
echo "  Potential issues detected: Yes"
echo ""
echo "💡 Recommendation: Use --deep flag for comprehensive analysis"
echo "   /rptc:helper:simplify $TARGET_PATH --deep"
echo ""
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

```text
Review the proposed changes above.

Options:
  [y] Apply all simplifications
  [n] Cancel (no changes)
  [s] Show detailed changes (before/after)

Apply these simplifications? [y/n/s]:
```

**If user selects 's' (show details)**:

```text
[Show detailed before/after for each proposed change]

After review:
  [y] Apply simplifications
  [n] Cancel

Apply? [y/n]:
```

**If user declines**:

```text
❌ Simplification cancelled by user

No changes were made.

To analyze with different settings:
  /rptc:helper:simplify [path] --deep
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

Options:
  [r] Rollback changes (restore from backup)
  [k] Keep changes (investigate failures manually)
  [d] Show diff (see what changed)

What would you like to do? [r/k/d]:
```

**If user selects 'r' (rollback)**:

```bash
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
```

**If user selects 'k' (keep changes)**:

```text
⚠️  Keeping changes with failing tests

You are responsible for fixing test failures manually.

Backup available at: $BACKUP_DIR

To restore manually:
  cp -r $BACKUP_DIR/* ./
```

**If user selects 'd' (show diff)**:

```bash
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

# After showing diff, ask again
echo "Options:"
echo "  [r] Rollback changes"
echo "  [k] Keep changes"
echo ""
read -p "Decision? [r/k]: " decision
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

Proceed with simplifying [X] files? [y/n]:
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
