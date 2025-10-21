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

**Standard Operating Procedures** (resolved via fallback chain):
SOPs are loaded from (highest priority first):

1. `.rptc/sop/` - Project-specific overrides
2. `~/.claude/global/sop/` - User global defaults
3. Plugin SOPs - Plugin defaults

These SOPs provide consistent cross-project guidance.
Use `/rptc:admin-sop-check [filename]` to verify which SOP will be loaded.
Check `.context/` for project-specific context documents.

### 2. Complete Architecture Analysis

**Structure Mapping**:

```bash
tree -L 3 -I 'node_modules|__pycache__|.git' || find . -type d -not -path "*/\.*" | head -30
```

**Code Organization**:

- Identify all major modules/packages
- Map file relationships
- Find design patterns in use
- Locate configuration files

**Entry Points**:

- Read all entry files (index._, main._, app.\*)
- Understand initialization flow
- Identify core services/modules

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

### 7. Code Pattern Analysis

Search for key patterns:

```bash
rg "class\s+\w+" --type ts -c    # Class usage
rg "function\s+\w+" --type js -c  # Function definitions
rg "export\s+(default|const)" -c  # Export patterns
```

### 8. Recent Changes Deep Dive

- Analyze last 30 commits
- Identify active features
- Note breaking changes
- Review merge/branch patterns

### 9. Comprehensive Summary Report

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

### 10. Code Complexity Assessment

Automated analysis to identify technical debt and AI-generated over-engineering.

#### Complexity Metrics

**File Size Distribution**:

```bash
# Find files exceeding size limits (500 lines from architecture-patterns.md)
find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.java" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -exec wc -l {} + | sort -rn | head -20

# Summary statistics
echo "Files >500 lines (refactoring candidates):"
find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.java" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -exec wc -l {} + | awk '$1 > 500 {count++} END {print count " files"}'
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
for file in $(find . -name "*.ts" -o -name "*.js" -not -path "*/node_modules/*"); do
  count=$(grep -c "if\|else\|switch\|case\|\?\|&&\|||" "$file" 2>/dev/null || echo 0)
  if [ "$count" -gt 20 ]; then
    echo "$file: ~$count decision points"
  fi
done
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
find ./src -type d | awk -F/ '{print NF-2}' | sort -rn | head -10

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
rg --count-matches "^\s*(function|const|class|def)\s+\w+" --type ts --type js --type py \
  | awk -F: '$2 > 5 {print $1 ": " $2 " definitions"}'

# Detect copy-paste patterns (similar file names)
find . -type f -name "*-copy.*" -o -name "*-backup.*" -o -name "*-old.*" -o -name "*-2.*"

# Approximate duplication: files with identical line counts
find . -type f \( -name "*.ts" -o -name "*.js" \) -not -path "*/node_modules/*" \
  -exec wc -l {} + | awk '{print $1}' | sort | uniq -c | awk '$1 > 2 {print "Potential duplicates: " $1 " files with " $2 " lines"}'
```

**Interpretation**:
- No obvious duplication: ✅ DRY principle followed
- Some duplicated patterns: ⚠️ Extract to shared utilities
- Extensive duplication: 🚨 Systematic refactoring needed

**Dependency Complexity**:

```bash
# Count import statements per file (tight coupling indicator)
echo "Files with high import counts (>15 = tight coupling):"
for file in $(find . -name "*.ts" -o -name "*.js" -not -path "*/node_modules/*"); do
  count=$(grep -c "^import\|^const.*require" "$file" 2>/dev/null || echo 0)
  if [ "$count" -gt 15 ]; then
    echo "$file: $count imports"
  fi
done

# Detect circular dependency candidates (mutual imports)
rg "import.*from ['\"]\.\./" --type ts --type js -l | while read file; do
  dir=$(dirname "$file")
  echo "Check $file for circular deps with files in $dir"
done
```

**Interpretation**:
- Most files <10 imports: ✅ Loose coupling
- Some files 10-15 imports: ⚠️ Review dependencies
- Files >15 imports: 🚨 God object, split responsibility

**Test-to-Code Ratio**:

```bash
# Compare test file sizes to implementation file sizes
impl_lines=$(find ./src -name "*.ts" -o -name "*.js" -not -path "*/node_modules/*" | xargs wc -l | tail -1 | awk '{print $1}')
test_lines=$(find ./tests -name "*.test.ts" -o -name "*.spec.ts" -o -name "*.test.js" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')

if [ -n "$test_lines" ] && [ "$test_lines" -gt 0 ]; then
  ratio=$(echo "scale=2; $test_lines / $impl_lines" | bc)
  echo "Test-to-Code Ratio: $ratio:1 ($test_lines test lines / $impl_lines impl lines)"
else
  echo "Test-to-Code Ratio: 0:1 (NO TESTS FOUND)"
fi
```

**Interpretation**:
- Ratio 1:1 to 2:1: ✅ Comprehensive test coverage
- Ratio 0.5:1 to 1:1: ⚠️ Adequate but could improve
- Ratio <0.5:1: 🚨 Insufficient test coverage

#### AI Technical Debt Indicators

Patterns suggesting AI-generated over-engineering:

**1. Premature Abstraction** (interfaces with single implementation):

```bash
# Find interface/abstract definitions
rg "^(export\s+)?(interface|abstract class)\s+\w+" --type ts -l > /tmp/interfaces.txt

# Find implementations
for iface in $(cat /tmp/interfaces.txt); do
  name=$(grep -o "interface \w+" "$iface" | head -1 | awk '{print $2}')
  impl_count=$(rg "implements $name|extends $name" --type ts -c | awk -F: '{sum+=$2} END {print sum}')
  if [ "$impl_count" -eq 1 ]; then
    echo "⚠️ Single implementation: $name in $iface"
  fi
done
```

**Red Flag**: >3 single-implementation interfaces suggests YAGNI violation

**2. Gold-Plating** (excessive configuration):

```bash
# Find configuration files
config_files=$(find . -name "*.config.*" -o -name "*.conf" -o -name "*rc" -o -name "*.yaml" -o -name "*.toml")

# Compare config size to actual code
config_lines=$(echo "$config_files" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
code_lines=$(find ./src -name "*.ts" -o -name "*.js" | xargs wc -l | tail -1 | awk '{print $1}')

if [ "$config_lines" -gt $((code_lines / 4)) ]; then
  echo "🚨 Configuration bloat: $config_lines config lines vs $code_lines code lines"
  echo "   (Config >25% of code suggests over-configuration)"
fi
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

```bash
# Find generic/template types rarely used
rg "<T>|<K, V>|<TEntity>" --type ts -l > /tmp/generics.txt

for file in $(cat /tmp/generics.txt); do
  usage=$(rg "$(basename $file .ts)" --type ts -c | awk -F: '{sum+=$2} END {print sum}')
  if [ "$usage" -lt 3 ]; then
    echo "⚠️ Rarely used generic: $file (used $usage times)"
  fi
done
```

**Red Flag**: Generics/templates used <3 times across codebase

**5. Middleware Proliferation** (interceptors without interception):

```bash
# Find middleware/interceptor definitions
rg "(middleware|interceptor|hook|plugin).*function|class.*Middleware" --type ts --type js -c

# Check if middleware list exceeds actual cross-cutting concerns
middleware_count=$(rg "use.*middleware|registerInterceptor|addHook" --type ts --type js -c | awk -F: '{sum+=$2} END {print sum}')

if [ "$middleware_count" -gt 10 ]; then
  echo "⚠️ Middleware proliferation: $middleware_count middleware registrations"
  echo "   (Review for middleware that could be direct implementations)"
fi
```

**Red Flag**: >10 middleware/interceptors in small-to-medium project

#### Over-Engineering Red Flags Checklist

Specific patterns to manually verify:

- [ ] **Single-Implementation Interfaces**: Interfaces with only one concrete class (YAGNI violation)
  - Check: Review output of "Premature Abstraction" detection
  - Action: Remove interface, use concrete class directly

- [ ] **Deeply Nested Directories**: Source directories >4 levels deep
  - Check: `find ./src -type d | awk -F/ '{print NF-2}' | sort -rn | head -1`
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

**Integration with Section 9 Summary**:

The Complexity Assessment summary should be referenced in the final "Comprehensive Summary Report" (section 9) under a new subsection:

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
