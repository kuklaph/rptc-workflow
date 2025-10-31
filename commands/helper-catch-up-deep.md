# Deep Context Catch-Up

Get exhaustive project analysis for complex work.

Arguments: None

## Process

Perform comprehensive project analysis in 15-30 minutes:

### 1. Project Foundation (Complete)

- Read ALL `.context/` files
- Read `CLAUDE.md`
- Read `README.md`
- Read `package.json` / equivalent
- Read `tsconfig.json` / language config
- Read `.gitignore`
- Review CI/CD configs (.github/, .gitlab-ci.yml, etc.)

### 2. Complete Architecture Analysis

**Structure Mapping**:

```bash
tree -L 3 -I 'node_modules|__pycache__|.git' || find . -type d -not -path "*/\.*" | head -30
```

### 3. Complete Git History

```bash
git log --all --oneline --graph -30  # Extended history
git log --all --grep="feat" --oneline | head -10  # Feature history
git log --all --grep="fix" --oneline | head -10   # Fix history
```

### 4. All Documentation

- Read ALL files in `.rptc/research/`
- Read ALL files in `.rptc/plans/`
- Extract key decisions and patterns
- Note implementation status

### 5. Complete Dependency Analysis

- Full dependency tree
- Identify critical dependencies
- Note versions and update status
- Check for security advisories

### 6. Test Infrastructure

- Identify test framework
- Count total tests
- Review test coverage
- Analyze test patterns

### 7. Complexity Analysis

```markdown
# Files exceeding size limits (>500 lines)
echo "### Files Exceeding Size Limits"

Use Glob tool to find code files:
- Pattern 1: Glob(pattern: "**/*.{js,ts}", exclude: "node_modules,.git,dist,build")
- Pattern 2: Glob(pattern: "**/*.{py,java,go,rb}", exclude: "node_modules,.git,dist,build")

For each file from both Glob results:
1. Use Read tool: Read(file_path: "[file]")
2. Extract line count from Read output
3. If line count > 500: Store file + line count

Sort results by line count (descending) and display top 10:
- "[file] ([count] lines)"

# Functions exceeding length limits (>50 lines) - heuristic for common languages
echo ""
echo "### Functions Exceeding Length Limits"
# TypeScript/JavaScript: function declarations

Use Grep tool to find function starts with context:
- Pattern: "^(function|const .* = \\(|async function)"
- Type: ts, js
- Output mode: "content"
- Context: -A 60 (60 lines after)

For each match:
1. Parse function start line in Claude
2. Count lines until closing brace "^}"
3. If line count > 50:
   - Display: "[file]:[line] (function exceeds 50 lines)"

Limit to top 10 results or note: "(detection requires ripgrep)"

# Deep abstraction chains (>3 inheritance/interface layers)
echo ""
echo "### Deep Abstraction Chains"

Use Grep tool to count inheritance keywords:
- Pattern: "(extends|implements|inherits)"
- Output mode: "count"

For each file with count:
1. Parse count from Grep output in Claude
2. If count > 3:
   - Display: "[file] ([count] inheritance points)"

Sort by count (descending) and limit to top 10 results.

# Single-implementation interfaces (premature abstraction)
echo ""
echo "### Potentially Premature Abstractions"

Use Grep tool to find interface/abstract class definitions:
- Pattern: "^(interface|abstract class) \\w+"
- Output mode: "content"
- Parse unique interface names in Claude

For each interface name found:
1. Use Grep tool:
   - Pattern: "(implements|extends) [interface_name]"
   - Output mode: "count"
2. Sum counts across all files in Claude
3. If total count == 1:
   - Display: "  - [interface_name] (only 1 implementation found)"

Limit to top 10 results.

echo ""
echo "**Recommendations:**"
echo "- Files >500 lines: Consider splitting into feature modules"
echo "- Functions >50 lines: Extract sub-functions with clear responsibilities"
echo "- Deep abstractions: Flatten hierarchy, prefer composition over inheritance"
echo "- Single-impl interfaces: Remove abstraction until 2nd implementation exists (Rule of Three)"
echo ""
echo "Reference: \`architecture-patterns.md\` (SOP) for refactoring guidance"
```

### 8. Code Pattern Analysis

```bash
rg "class\s+\w+" --type ts -c    # Class usage
rg "function\s+\w+" --type js -c  # Function definitions
rg "export\s+(default|const)" -c  # Export patterns
```

### 9. Recent Changes Deep Dive

- Analyze last 30 commits
- Identify active features
- Note breaking changes
- Review merge/branch patterns

### 10. Comprehensive Summary Report

```text
📋 Deep Context Catch-Up

**Project Overview**:
- Name: [name]
- Purpose: [from README]
- Tech Stack: [complete list with versions]
- Architecture: [detailed pattern analysis]

**Project Structure** (Complete):
[Full directory tree with purposes]

**Git History Analysis**:
- Total commits: [N]
- Active branches: [list]
- Recent features: [list from last 30 commits]
- Recent fixes: [list from last 30 commits]
- Current branch: [name]
- Divergence from main: [N] commits

**Documentation Inventory**:

Research Documents:
1. [doc 1]: [summary]
2. [doc 2]: [summary]
...

Implementation Plans:
1. [plan 1]: [status] - [summary]
2. [plan 2]: [status] - [summary]
...

**Architecture Deep Dive**:
- Entry points: [list]
- Core modules: [list with purposes]
- Design patterns: [identified patterns]
- Data flow: [high-level flow]

**Dependencies** ([N] total):
Critical:
- [dep 1]: [version] - [purpose]
- [dep 2]: [version] - [purpose]

Development:
- [dev dep 1]: [version] - [purpose]

**Test Infrastructure**:
- Framework: [name]
- Total tests: [N]
- Coverage: [X]% (if available)
- Test patterns: [identified patterns]

**Code Patterns**:
- Classes: [N] defined
- Functions: [N] defined
- Components: [N] (if applicable)
- Primary patterns: [list]

**Active Work Analysis**:
- Current feature: [from branch/commits]
- Files in progress: [list with purposes]
- Related research: [link]
- Related plan: [link]
- Completion estimate: [based on plan]

**Key Decisions & Context**:
[Extract from .context/ files]
1. [Decision 1]
2. [Decision 2]
...

**Technical Constraints**:
[From documentation and analysis]
- [Constraint 1]
- [Constraint 2]

**Recommendations**:
Based on comprehensive analysis:
1. [Specific recommendation]
2. [Another recommendation]
3. [Area of focus]

**Ready for**: [Very specific task recommendations based on deep understanding]
```

### 11. Complexity Analysis Focus (Optional)

Before running comprehensive complexity assessment, let user select focus areas:

```markdown
AskUserQuestion(
  question: "Which complexity analysis areas should we explore?",
  header: "Analysis",
  options: [
    {
      label: "Skip complexity assessment",
      description: "Skip Section 12 entirely, show final summary",
      value: "skip"
    },
    {
      label: "Run full complexity assessment",
      description: "Execute all 6 analysis areas (15-30 min)",
      value: "full"
    },
    {
      label: "File Size Analysis",
      description: "Detect files >500 lines, modularity issues",
      value: "file_size"
    },
    {
      label: "Function Complexity Analysis",
      description: "Cyclomatic complexity, function length",
      value: "functions"
    },
    {
      label: "Abstraction Depth Analysis",
      description: "Inheritance chains, premature abstractions",
      value: "abstractions"
    },
    {
      label: "Code Duplication Detection",
      description: "DRY violations, copy-paste patterns",
      value: "duplication"
    },
    {
      label: "Dependency Complexity Analysis",
      description: "Import counts, circular dependencies",
      value: "dependencies"
    },
    {
      label: "Test-to-Code Ratio Analysis",
      description: "Coverage ratio, test quality",
      value: "tests"
    }
  ],
  multiSelect: true
)
```

Capture response in `ANALYSIS_AREAS` variable (array for multi-select).

**Handle Selection:**

```bash
if [[ "$ANALYSIS_AREAS" == "skip" ]]; then
  echo ""
  echo "⏭️ Skipping complexity assessment..."
  echo ""
  # Jump to final summary (Section 10 content)

elif [[ "$ANALYSIS_AREAS" == "full" ]]; then
  echo ""
  echo "Running full complexity assessment..."
  echo ""
  # Execute all 6 sections (existing Section 12 content)
  # Lines 247-661: All complexity metrics

else
  echo ""
  echo "Running selected complexity analyses..."
  echo ""

  # Execute selected areas only
  if [[ " ${ANALYSIS_AREAS[@]} " =~ " file_size " ]]; then
    echo "### File Size Distribution"
    # Execute File Size Analysis section (lines 247-275)
  fi

  if [[ " ${ANALYSIS_AREAS[@]} " =~ " functions " ]]; then
    echo ""
    echo "### Function Complexity"
    # Execute Function Complexity section (lines 276-308)
  fi

  if [[ " ${ANALYSIS_AREAS[@]} " =~ " abstractions " ]]; then
    echo ""
    echo "### Abstraction Depth"
    # Execute Abstraction Depth section (lines 309-336)
  fi

  if [[ " ${ANALYSIS_AREAS[@]} " =~ " duplication " ]]; then
    echo ""
    echo "### Code Duplication"
    # Execute Duplication Detection section (lines 337-378)
  fi

  if [[ " ${ANALYSIS_AREAS[@]} " =~ " dependencies " ]]; then
    echo ""
    echo "### Dependency Complexity"
    # Execute Dependency Complexity section (lines 379-417)
  fi

  if [[ " ${ANALYSIS_AREAS[@]} " =~ " tests " ]]; then
    echo ""
    echo "### Test-to-Code Ratio"
    # Execute Test Ratio section (lines 418-449)
  fi
fi
```

### 12. Code Complexity Assessment (Conditional)

Automated analysis to identify technical debt and AI-generated over-engineering.

**Note:** This section executes based on user selection in Step 11.

#### Complexity Metrics

**File Size Distribution**:

```markdown
**Largest Files (Top 20):**

Use Glob tool to find code files:
- Glob(pattern: "**/*.{ts,js,py,java}", exclude: "node_modules,.git")

For each file:
1. Read(file_path: "[file]")
2. Extract line count from Read output

Sort all results by line count (descending).
Display top 20 files with format:
- "[line_count] [file]"

**Files Exceeding Limits:**

From the same file list above:
1. Filter files where line count > 500
2. Count total exceeding limit
3. Display: "[count] files"
```

**Interpretation**:
- 0 files >500 lines: ✅ Excellent modularity
- 1-3 files >500 lines: ⚠️ Review for splitting opportunities
- 4+ files >500 lines: 🚨 Significant refactoring needed

**Function Complexity** (cyclomatic complexity):

```bash
# For TypeScript/JavaScript (requires complexity-report or similar)
# Manual detection: Look for high branching
rg "if\s*\(|else|switch|case|\?\s*.*\s*:" --type ts --type js -c | sort -rn | head -20

# For Python (requires radon)
# radon cc . -a -nb

# Approximation: Count branching keywords per file
echo "Files with high branching (potential complexity >10):"

Use Glob tool to find files:
- Glob(pattern: "**/*.{ts,js}", exclude: "node_modules")

For each file:
1. Use Grep tool:
   - Pattern: "if\\(|else|switch|case|\\?|&&|\\|\\|"
   - File: [current file]
   - Output mode: "count"

2. If count > 20:
   - Display: "[file]: ~[count] decision points"

List all files with excessive complexity.
```

**Interpretation**:
- All functions <10 complexity: ✅ Maintainable
- Some functions 10-15: ⚠️ Consider simplification
- Any function >15: 🚨 Urgent refactoring required

**Abstraction Depth** (layers of indirection):

```bash
# Detect deep inheritance/abstraction hierarchies
# For TypeScript/JavaScript:
rg "extends\s+\w+" --type ts --type js -A 5 | grep "extends" -c

# Detect deeply nested directory structures (>4 levels from src/)
Use Glob tool to find all directories:
- Glob(pattern: "src/**/", path: ".")

For each directory:
1. Count directory depth by splitting path by "/" in Claude
2. Calculate depth relative to src/ (subtract 2 for "./" and "src/")
3. Store directory + depth

Sort by depth (descending) and display top 10 deepest directories.

# Detect excessive call chains (A→B→C→D→E)
echo "Files with potential deep call chains:"
rg "this\.\w+\(\).*\.\w+\(\).*\.\w+\(\)" --type ts --type js
```

**Interpretation**:
- Abstraction depth ≤3: ✅ Appropriate encapsulation
- Depth 4-5: ⚠️ Review for unnecessary indirection
- Depth >5: 🚨 Over-abstraction, simplify

**Code Duplication**:

```bash
# Detect duplicate code blocks (DRY violations)
# For simple duplication: repeated lines
Use Grep tool to count definition patterns:
- Pattern: "^\\s*(function|const|class|def)\\s+\\w+"
- Type: ts, js, py
- Output mode: "count"

For each file with count:
1. Parse count from Grep output in Claude
2. If count > 5:
   - Display: "[file]: [count] definitions"

List all files with excessive definitions.

# Detect copy-paste patterns (similar file names)
Use Glob tool with multiple patterns:
- Glob(pattern: "**/*-copy.*")
- Glob(pattern: "**/*-backup.*")
- Glob(pattern: "**/*-old.*")
- Glob(pattern: "**/*-2.*")

List all matching files.

# Approximate duplication: files with identical line counts
Use Glob tool: Glob(pattern: "**/*.{ts,js}", exclude: "node_modules")

For each file:
1. Read(file_path: "[file]")
2. Extract line count from Read output
3. Group files by line count in Claude
4. For groups with >2 files with same line count:
   - Display: "Potential duplicates: [count] files with [lines] lines"
```

**Interpretation**:
- No obvious duplication: ✅ DRY principle followed
- Some duplicated patterns: ⚠️ Extract to shared utilities
- Extensive duplication: 🚨 Systematic refactoring needed

**Dependency Complexity**:

```bash
# Count import statements per file (tight coupling indicator)
echo "Files with high import counts (>15 = tight coupling):"

Use Glob tool to find files:
- Glob(pattern: "**/*.{ts,js}", exclude: "node_modules")

For each file:
1. Use Grep tool:
   - Pattern: "^import|^const.*require"
   - File: [current file]
   - Output mode: "count"

2. If count > 15:
   - Display: "[file]: [count] imports"

List all files with excessive imports.

# Detect circular dependency candidates (mutual imports)
Use Grep tool:
- Pattern: "import.*from ['\"]\\.\\.\/"
- Type: ts, js
- Output mode: "files_with_matches"

For each file in results:
1. Extract directory path in Claude (no dirname needed)
2. Display: "Check [file] for circular deps with files in [dir]"

List all files with potential circular imports.
```

**Interpretation**:
- Most files <10 imports: ✅ Loose coupling
- Some files 10-15 imports: ⚠️ Review dependencies
- Files >15 imports: 🚨 God object, split responsibility

**Test-to-Code Ratio**:

```markdown
**Implementation Lines:**
Use Glob tool: Glob(pattern: "src/**/*.{ts,js}", exclude: "node_modules")

For each file:
1. Read(file_path: "[file]")
2. Extract line count from Read output
3. Sum all line counts in Claude → impl_lines

**Test Lines:**
Use Glob tool: Glob(pattern: "tests/**/*.{test.ts,spec.ts,test.js}")

For each file:
1. Read(file_path: "[file]")
2. Extract line count from Read output
3. Sum all line counts in Claude → test_lines

**Calculate Ratio:**
If test_lines > 0:
1. Calculate: test_lines / impl_lines in Claude
2. Format to 2 decimal places
3. Display: "Test-to-Code Ratio: [ratio]:1 ([test_lines] test lines / [impl_lines] impl lines)"
Else:
- Display: "Test-to-Code Ratio: 0:1 (NO TESTS FOUND)"
```

**Interpretation**:
- Ratio 1:1 to 2:1: ✅ Comprehensive test coverage
- Ratio 0.5:1 to 1:1: ⚠️ Adequate but could improve
- Ratio <0.5:1: 🚨 Insufficient test coverage

#### AI Technical Debt Indicators

Patterns suggesting AI-generated over-engineering:

**1. Premature Abstraction** (interfaces with single implementation):

```markdown
**Find Interfaces:**
Use Grep tool:
- Pattern: "^(export\\s+)?(interface|abstract class)\\s+\\w+"
- Type: ts
- Output mode: "files_with_matches"

For each file:
1. Read(file_path: "[file]")
2. Parse interface/abstract class names in Claude (no grep -o needed)
3. For each interface name found:
   a. Use Grep tool:
      - Pattern: "implements [name]|extends [name]"
      - Type: ts
      - Output mode: "count"
   b. Sum counts across all files in Claude (no awk needed)
   c. If total count == 1:
      - Display: "⚠️ Single implementation: [name] in [file]"

**IMPORTANT:** No temporary files. Store results in variables, process in Claude.
```

**Red Flag**: >3 single-implementation interfaces suggests YAGNI violation

**2. Gold-Plating** (excessive configuration):

```markdown
**Configuration Lines:**
Use Glob tool:
- Pattern 1: Glob(pattern: "**/*.config.*")
- Pattern 2: Glob(pattern: "**/*.{conf,yaml,toml}")
- Pattern 3: Glob(pattern: "**/*rc")

For each file from all patterns:
1. Read(file_path: "[file]")
2. Extract line count from Read output
3. Sum all line counts in Claude → config_lines

**Code Lines:**
Use Glob tool: Glob(pattern: "src/**/*.{ts,js}")

For each file:
1. Read(file_path: "[file]")
2. Extract line count from Read output
3. Sum all line counts in Claude → code_lines

**Check for Bloat:**
Calculate threshold: code_lines / 4 in Claude

If config_lines > threshold:
- Display: "🚨 Configuration bloat: [config_lines] config lines vs [code_lines] code lines"
- Display: "   (Config >25% of code suggests over-configuration)"
```

**Red Flag**: Configuration exceeding 25% of code size

**3. Framework-within-Framework** (custom abstractions over existing tools):

```bash
# Detect wrapper/facade patterns
rg "class \w+(Wrapper|Facade|Adapter|Proxy)" --type ts --type js

# Detect pass-through utilities
echo "Potential pass-through utilities:"
rg "export (const|function) \w+.*=.*\(\)" --type ts --type js | head -10
```

**Red Flag**: >5 wrapper classes without clear value-add

**4. Speculative Generalization** (unused abstraction):

```markdown
**Find Generic Files:**
Use Grep tool:
- Pattern: "<T>|<K, V>|<TEntity>"
- Type: ts
- Output mode: "files_with_matches"

For each file:
1. Extract filename without extension in Claude (no basename needed)
2. Use Grep tool to count usage:
   - Pattern: "[filename]" (the extracted name)
   - Type: ts
   - Output mode: "count"
3. Sum counts across all files in Claude (no awk needed)
4. If total usage < 3:
   - Display: "⚠️ Rarely used generic: [file] (used [usage] times)"

**IMPORTANT:** No temporary files. Process results in Claude.
```

**Red Flag**: Generics/templates used <3 times across codebase

**5. Middleware Proliferation** (interceptors without interception):

```markdown
# Find middleware/interceptor definitions
Use Grep tool:
- Pattern: "(middleware|interceptor|hook|plugin).*function|class.*Middleware"
- Type: ts, js
- Output mode: "count"

Display count of middleware definitions per file.

# Check if middleware list exceeds actual cross-cutting concerns
Use Grep tool:
- Pattern: "use.*middleware|registerInterceptor|addHook"
- Type: ts, js
- Output mode: "count"

Sum all counts across files in Claude → middleware_count

If middleware_count > 10:
- Display: "⚠️ Middleware proliferation: [middleware_count] middleware registrations"
- Display: "   (Review for middleware that could be direct implementations)"
```

**Red Flag**: >10 middleware/interceptors in small-to-medium project

#### Over-Engineering Red Flags Checklist

Specific patterns to manually verify:

- [ ] **Single-Implementation Interfaces**: Interfaces with only one concrete class (YAGNI violation)
  - Check: Review output of "Premature Abstraction" detection
  - Action: Remove interface, use concrete class directly

- [ ] **Deeply Nested Directories**: Source directories >4 levels deep
  - Check: Use Glob to find all src directories and calculate depth in Claude
  - Action: Flatten structure, group by feature not file type

- [ ] **Excessive Call Chains**: Methods calling methods >5 deep (A→B→C→D→E→F)
  - Check: Manual code review of high-complexity files
  - Action: Inline intermediate methods, simplify flow

- [ ] **Abstract Base with One Child**: Abstract classes extended only once
  - Check: `rg "abstract class" --type ts` + verify children count
  - Action: Merge abstract and concrete, remove abstraction

- [ ] **Configuration > Code**: Config files exceed 25% of implementation size
  - Check: Output of "Gold-Plating" detection
  - Action: Hard-code defaults, keep config for true environment variation

- [ ] **Utility Modules as Pass-Throughs**: Helper functions that just call another function
  - Check: Review "Framework-within-Framework" detection results
  - Action: Remove wrapper, call original directly

- [ ] **Unnecessary Design Patterns**: Factory for 2 types, Singleton for stateless utils
  - Check: `rg "Factory|Singleton|Builder|Strategy" --type ts` + verify complexity
  - Action: Replace with simple functions or direct instantiation

- [ ] **Premature Optimization**: Complex caching, pooling, lazy-loading without measurement
  - Check: `rg "cache|pool|lazy|memo" --type ts` + verify performance requirement
  - Action: Remove until profiling proves necessity

#### Complexity Assessment Summary

After running all metrics, compile summary:

```text
### Code Complexity Assessment

**Overall Health**: [🟢 Good / 🟡 Moderate / 🔴 High Debt]

**Metrics Summary**:
- File Size: [X files >500 lines] [✅⚠️🚨]
- Function Complexity: [X functions >10 cyclomatic] [✅⚠️🚨]
- Abstraction Depth: [Max depth: X layers] [✅⚠️🚨]
- Code Duplication: [X duplicate patterns detected] [✅⚠️🚨]
- Dependency Coupling: [X files with >15 imports] [✅⚠️🚨]
- Test Coverage: [Ratio: X:1, Coverage: Y%] [✅⚠️🚨]

**AI Technical Debt Detected**:
- Premature Abstraction: [X single-impl interfaces]
- Gold-Plating: [Config/Code ratio: X%]
- Wrapper Proliferation: [X unnecessary wrappers]
- Speculative Generalization: [X rarely-used generics]
- Middleware Overuse: [X middleware registrations]

**Over-Engineering Red Flags**:
[List detected red flags from checklist]

**Refactoring Priorities** (by impact):

1. **High Priority** (blocking maintainability):
   - [Specific file/pattern]: [Issue] → [Recommended action]

2. **Medium Priority** (increasing tech debt):
   - [Specific file/pattern]: [Issue] → [Recommended action]

3. **Low Priority** (opportunistic improvement):
   - [Specific file/pattern]: [Issue] → [Recommended action]

**KISS/YAGNI/DRY Adherence**:
- KISS (Simplicity): [Assessment based on abstraction depth, complexity]
- YAGNI (No speculation): [Assessment based on unused abstractions, single impls]
- DRY (No duplication): [Assessment based on duplication detection]

**Recommended Actions**:
1. [Most impactful refactoring to start with]
2. [Next priority improvement]
3. [Long-term architectural improvement]

**Files Requiring Immediate Attention**:
[List top 5 files exceeding multiple thresholds]
```

**Scoring Rubric**:

- **🟢 Good** (0-2 red flags):
  - All metrics within thresholds
  - <3 over-engineering patterns
  - Strong adherence to KISS/YAGNI/DRY

- **🟡 Moderate** (3-5 red flags):
  - Some metrics exceeded
  - 3-5 over-engineering patterns
  - Occasional YAGNI violations

- **🔴 High Debt** (6+ red flags):
  - Multiple metrics severely exceeded
  - Systematic over-engineering
  - Significant KISS/YAGNI/DRY violations

**Integration with Section 10 Summary**:

The Complexity Assessment summary should be referenced in the final "Comprehensive Summary Report" (section 10) under a new subsection:

```markdown
**Technical Debt Analysis**:
[Reference complexity assessment summary]
- Overall Health: [Score]
- Priority Refactorings: [Top 3]
- See full Complexity Assessment above for details
```

**Use when**:

- Starting on unfamiliar project
- Major architectural changes
- Complex refactoring
- Comprehensive feature planning
- Project onboarding
