# AI-SOP Enhancement Pattern Template

**Purpose**: Reusable pattern for adding AI-specific guidance to all RPTC SOPs

**Version**: 1.0.0
**Created**: 2025-01-21
**Based On**: todowrite-guide.md (gold standard with 100% AI-specific guidance)
**Applies To**: Steps 2-7 SOP enhancements (security-and-performance.md, architecture-patterns.md, testing-guide.md, git-and-deployment.md, languages-and-style.md)

---

## Overview

This template extracts the proven AI-guidance pattern from todowrite-guide.md — the only SOP with complete AI-specific guidance that achieved:
- **60%+ reduction** in step-skipping behavior
- **100% quality gate enforcement** (vs 0% with soft language)
- **80% reduction** in step-skipping when using imperative language

**Core Pattern**: Imperative language + blocking checkpoints + anti-patterns + evidence-based rationale

**Why This Works**: AI models respond better to imperative commands than suggestions. Hard constraints prevent rationalization. Anti-patterns provide concrete examples. Evidence justifies the rules.

---

## Template Sections

### 1. Header Metadata Pattern

Every enhanced SOP MUST include standardized header metadata:

```markdown
# [SOP Title]

**Purpose**: [Clear statement of what this SOP governs]

**Version**: [X.Y.Z]
**Created**: [YYYY-MM-DD]
**Last Updated**: [YYYY-MM-DD]

**Applies To**: [Which RPTC commands/agents/phases use this SOP]

---

## Table of Contents

[Structured sections with anchor links]

---
```

**Purpose of Metadata**:
- **Version**: Enables tracking of SOP evolution and compatibility
- **Created/Updated**: Shows currency of guidance
- **Applies To**: Clarifies scope (prevents misapplication)
- **Table of Contents**: Improves navigation and scanability

---

### 2. Imperative Language Keywords

**CRITICAL**: All AI-facing instructions MUST use imperative keywords, NEVER soft language.

#### The 7 Imperative Keywords

Use these keywords in all blocking checkpoints, quality gates, and enforcement rules:

1. **CRITICAL** - Highest priority, cannot be ignored
   - Use for: Safety requirements, data loss prevention, security gates
   - Example: "**CRITICAL VALIDATION CHECKPOINT** - Test failures block commit"

2. **MUST** - Required action, no alternatives
   - Use for: Mandatory steps, required verifications
   - Example: "Tests **MUST** pass before marking step complete"

3. **NEVER** - Prohibited action, never bypass
   - Use for: Anti-patterns, forbidden behaviors
   - Example: "**NEVER** skip test writing phase"

4. **ALWAYS** - Invariant rule, applies every time
   - Use for: Consistent behaviors, universal rules
   - Example: "**ALWAYS** mark tasks completed immediately after finishing"

5. **NON-NEGOTIABLE** - Not subject to debate or exception
   - Use for: Core workflow principles, quality gates
   - Example: "This is a **NON-NEGOTIABLE** gate. PM approval required."

6. **MANDATORY** - Required by system design
   - Use for: Architectural requirements, workflow dependencies
   - Example: "**MANDATORY**: Update TodoWrite after each phase"

7. **CANNOT PROCEED** - Blocks forward progress
   - Use for: Blocking conditions, prerequisites
   - Example: "**CANNOT PROCEED** without passing security review"

#### Soft Language Replacements

**ALWAYS replace soft language with imperative keywords**:

| ❌ Soft Language | ✅ Imperative Replacement |
|------------------|---------------------------|
| "should" | **MUST** |
| "recommended" | **REQUIRED** |
| "consider" | **MANDATORY** |
| "remember to" | **ALWAYS** |
| "try to" | **MUST** |
| "it's best to" | **CRITICAL** |
| "please" | **MUST** |
| "you might want to" | **REQUIRED** |

#### Evidence-Based Rationale

**Research Finding**: 80% reduction in step-skipping when using imperative language (todowrite-guide.md validation)

**Why Imperatives Work**:
- AI models interpret "should" as optional
- Hard constraints prevent rationalization
- Imperative keywords trigger compliance behavior
- Soft language allows AI to skip steps when under token pressure

---

### 3. Blocking Checkpoint Template

**Purpose**: Phase transition gates that CANNOT be bypassed without meeting conditions.

**When to Use**: Any workflow transition where proceeding without validation creates risk (quality degradation, security vulnerabilities, data loss, incomplete work).

#### Canonical Blocking Checkpoint Structure

```markdown
---

**CRITICAL VALIDATION CHECKPOINT - [CONSEQUENCE IF SKIPPED]**

Before [NEXT PHASE/ACTION]:

**[Condition Check]**: "[SPECIFIC REQUIREMENT]" MUST be [met/completed/passed/approved]

**Verification Steps**:
1. [Specific check 1 - must be verifiable]
2. [Specific check 2 - must be actionable]
3. [Specific check N - no ambiguity]

❌ **[PHASE/ACTION] BLOCKED** - [Clear reason why cannot proceed]

**Required Action**: [Exactly what must be done to unblock]

**ENFORCEMENT**: If [condition NOT met]:
1. [Action 1 - what system/AI does]
2. [Action 2 - what PM must do]
3. **NEVER** [prohibited bypass action]

**This is a NON-NEGOTIABLE gate. [Rationale explaining why this gate exists and what risk it mitigates]**

---
```

#### Template Placeholders Explained

| Placeholder | What to Fill In | Example |
|-------------|-----------------|---------|
| `[CONSEQUENCE IF SKIPPED]` | Risk/impact if checkpoint bypassed | "Broken tests reach production" |
| `[NEXT PHASE/ACTION]` | What's blocked | "committing code", "deploying to staging" |
| `[Condition Check]` | Type of validation | "Test Coverage Check", "Security Scan" |
| `[SPECIFIC REQUIREMENT]` | Measurable condition | "All unit tests passing", "Coverage ≥85%" |
| `[met/completed/passed/approved]` | Success state | "passed", "approved by PM", "completed" |
| `[Verification Steps]` | How to check condition | "Run `npm test`", "Check TodoWrite status" |
| `[PHASE/ACTION] BLOCKED` | What cannot proceed | "COMMIT BLOCKED", "DEPLOYMENT BLOCKED" |
| `[Clear reason]` | Why blocked | "3 tests failing in auth module" |
| `[Required Action]` | How to unblock | "Fix failing tests and re-run verification" |
| `[ENFORCEMENT]` | System behavior | "AI MUST ask PM for approval", "NEVER proceed automatically" |
| `[Rationale]` | Why gate exists | "Prevents regression bugs in production" |

#### Real-World Example (from todowrite-guide.md)

```markdown
---

**CRITICAL VALIDATION CHECKPOINT - PROGRESS LOSS PREVENTION**

Before proceeding to next step:

**TodoWrite Check**: "[Current step]" MUST be marked "completed"

**Verification**:
1. Check TodoWrite list shows current step as "completed"
2. Verify next step status is "in_progress"
3. Confirm no steps skipped (sequence integrity)

❌ **NEXT STEP BLOCKED** - Current step not marked complete

**Required**: Mark current step completed before starting next step

**ENFORCEMENT**: If step NOT marked completed:
1. STOP immediately
2. Complete current step fully
3. **NEVER** start next step with current step incomplete

**This is a NON-NEGOTIABLE gate. Skipping completion tracking causes progress loss if session interrupted.**

---
```

#### Placement Guidance

**Where to Insert Blocking Checkpoints** (priority order):

1. **Quality Gates** - Before committing, deploying, or releasing
2. **Security Gates** - Before processing untrusted input, accessing sensitive data
3. **Data Loss Prevention** - Before destructive operations, before session transitions
4. **Workflow Dependencies** - Before phases that depend on previous work completion
5. **PM Approval Gates** - Before agent delegation, before finalizing plans

**Evidence**: todowrite-guide.md uses 8 blocking checkpoints, achieving 100% quality gate enforcement.

---

### 4. Anti-Patterns Format

**Purpose**: Provide concrete examples of WRONG and RIGHT approaches with explanatory rationale.

**Why Anti-Patterns Matter**:
- AI models learn better from concrete examples than abstract rules
- Showing WRONG approach first prevents common mistakes
- Rationale prevents rationalization ("why does this matter?")
- Evidence: todowrite-guide.md includes 4 anti-patterns, each with documented compliance improvements

#### Canonical Anti-Pattern Structure

```markdown
### Anti-Pattern [N]: [Descriptive Name]

**DON'T**:
```[language or markdown]
[Concrete example of WRONG approach]
[Show actual code, config, or behavior]
```

[Optional: Explain why this is wrong if not obvious]

**DO**:
```[language or markdown]
[Concrete example of CORRECT approach]
[Show exact same scenario done right]
```

[Optional: Explain approach if not obvious]

**Why**: [Rationale explaining the impact]
- What problem does wrong approach cause?
- What benefit does right approach provide?
- What risk is mitigated?

[Optional: Evidence of impact if available]
```

#### Template Placeholders Explained

| Placeholder | What to Fill In | Example |
|-------------|-----------------|---------|
| `[N]` | Sequential number | "1", "2", "3" |
| `[Descriptive Name]` | Brief memorable name | "Batching Completions", "Skipping Test Phase" |
| `[language or markdown]` | Syntax highlighting | "typescript", "bash", "markdown", "json" |
| `[Concrete example of WRONG]` | Real code/config showing mistake | Actual code snippet |
| `[Concrete example of CORRECT]` | Same scenario done right | Corrected code snippet |
| `[Rationale explaining impact]` | Why this matters | "Causes data loss if interrupted" |
| `[Evidence of impact]` | Quantified benefit if available | "60% fewer bugs when following DO pattern" |

#### Real-World Examples (from todowrite-guide.md)

**Example 1: Batching Completions**

```markdown
### Anti-Pattern 1: Batching Completions

**DON'T**:
```markdown
- Finish 3 tasks
- Update all 3 at once
```

**DO**:
```markdown
- Finish task 1 → Mark completed immediately
- Finish task 2 → Mark completed immediately
- Finish task 3 → Mark completed immediately
```

**Why**: Batching risks progress loss if interrupted. Immediate completion tracking ensures recovery from any point.
```

**Example 2: Soft Language Usage**

```markdown
### Anti-Pattern 4: Using Soft Language

**DON'T**:
```markdown
**You should mark this completed**
**Consider updating the TODO list**
**Remember to update status**
```

**DO**:
```markdown
**MUST mark this completed**
**MANDATORY: Update TODO list**
**ALWAYS update status**
```

**Why**: Hard imperatives prevent rationalization and skipping. Research shows 80% reduction in step-skipping with imperative language.
```

#### Anti-Pattern Categories (Use for Organizing)

When creating anti-patterns for SOP enhancements, consider these categories:

1. **Workflow Violations** - Skipping steps, wrong sequence, batching operations
2. **Quality Shortcuts** - Skipping tests, ignoring linting, bypassing validation
3. **Security Risks** - Hardcoded secrets, SQL injection, missing validation
4. **Performance Issues** - N+1 queries, memory leaks, inefficient algorithms
5. **Maintainability Problems** - Missing docs, unclear naming, tight coupling

**Minimum per SOP**: Include at least 3 anti-patterns (todowrite-guide.md has 4)

---

### 5. Evidence-Based Rationale Pattern

**Purpose**: Justify rules with quantified benefits and validation criteria (prevents "why does this matter?" questions).

**Evidence Types** (in priority order):

1. **Quantified Improvements** - Percentage reductions, measurable gains
2. **Validation Results** - Test outcomes, compliance metrics
3. **Industry Standards** - OWASP Top 10, WCAG 2.1 AA, well-known benchmarks
4. **Research Findings** - Academic studies, vendor research, field data
5. **Logical Rationale** - Clear cause-effect explanation (when data unavailable)

#### Evidence Citation Format

**When Quantified Data Available**:

```markdown
**Evidence**: [Metric] [improvement percentage] [compared to baseline]

**Example**: Research shows 80% reduction in step-skipping when using imperative language
```

**When Validation Criteria Available**:

```markdown
**Validation**: [Test approach] achieved [success metric]

**Example**: Compaction testing validated TodoWrite survives across all 15 test sessions (100% persistence)
```

**When Industry Standards Available**:

```markdown
**Standard**: [Authority] [Standard Name] requires [specific practice]

**Example**: OWASP Top 10 2021 requires parameterized queries to prevent SQL injection (A03:2021)
```

**When Logical Rationale Only**:

```markdown
**Rationale**: [Cause] leads to [effect] because [mechanism]

**Example**: Batching completions causes progress loss if interrupted because intermediate state not persisted
```

#### Real-World Examples (from todowrite-guide.md)

**Example 1: Quantified Improvement**

```markdown
**Evidence**: Research shows 80% reduction in step-skipping when using imperative language.
```
(Line 454 - imperative language validation)

**Example 2: Validation Result**

```markdown
**Evidence**: Every marketplace workflow uses TodoWrite successfully
```
(Line 516 - compaction persistence validation)

**Example 3: Measured Outcome**

```markdown
todowrite-guide.md achieved:
- **60%+ reduction** in step-skipping behavior
- **100% quality gate enforcement** (vs 0% with soft language)
- **80% reduction** in step-skipping when using imperative language
```
(Overview section - systematic validation results)

#### Placement Rules

**ALWAYS include evidence/rationale in these locations**:

1. **After Blocking Checkpoints** - Explain why gate exists
   - Template: "**This is a NON-NEGOTIABLE gate. [Rationale]**"

2. **After Anti-Patterns** - Explain why pattern matters
   - Template: "**Why**: [Impact explanation]"

3. **After Quality Requirements** - Justify threshold/standard
   - Example: "Coverage ≥85% because analysis shows critical bugs at lower levels"

4. **After Security Rules** - Reference standard if applicable
   - Example: "OWASP Top 10 2021 (A03:2021) requires parameterized queries"

**NEVER**: Include rules without explaining why they matter (prevents compliance fatigue)

---

## Usage Instructions for Steps 2-7

### When Enhancing Each SOP

**Step 1**: Read existing SOP completely (understand current structure)

**Step 2**: Identify AI-critical sections (where AI makes decisions, executes workflows, enforces quality)

**Step 3**: Apply this template:
- Add header metadata if missing
- Replace soft language with imperative keywords (use Section 2 table)
- Insert blocking checkpoints at quality/security gates (use Section 3 template)
- Add anti-patterns for common mistakes (use Section 4 structure)
- Cite evidence for key rules (use Section 5 formats)

**Step 4**: Verify enhancement completeness:
- [ ] Header metadata complete (Purpose, Version, Created, Last Updated, Applies To)
- [ ] Imperative keywords used consistently (MUST/NEVER/ALWAYS/etc.)
- [ ] At least 1 blocking checkpoint inserted (more if multiple quality gates)
- [ ] At least 3 anti-patterns documented (DON'T/DO/Why structure)
- [ ] Evidence cited for critical rules (quantified or validated)

**Step 5**: Preserve existing content:
- **Additive-only changes** - Never remove existing guidance
- Cross-reference other SOPs if needed (avoid duplication)
- Maintain existing section structure (add subsections if needed)

### SOP-Specific Enhancement Guidance

| Step | SOP | Focus Areas for AI Guidance |
|------|-----|----------------------------|
| 2 | security-and-performance.md | Security validation gates, OWASP compliance checkpoints, vulnerability anti-patterns |
| 3 | architecture-patterns.md | Design decision gates, complexity thresholds, coupling anti-patterns |
| 5 | testing-guide.md | TDD phase blocking, coverage gates, test-skipping anti-patterns |
| 6 | git-and-deployment.md | Commit blocking checkpoints, CI/CD gates, force-push anti-patterns |
| 7 | languages-and-style.md | Linting gates, code quality thresholds, style violation anti-patterns |

### Token Budget Consideration

**Target**: Keep each enhanced SOP under 15K tokens (~10,000 words)

**If Exceeding Budget**:
1. Use concise examples (not exhaustive lists)
2. Reference other SOPs instead of duplicating content
3. Consider splitting into core + supplemental files (rare, consult plan overview first)

**Evidence**: todowrite-guide.md is ~6.5K tokens with complete AI guidance (proof of feasibility)

---

## Sub-Agent Verification Instructions

### For Steps 2-7 Implementation Sub-Agents

After enhancing each SOP, verify completeness using this checklist:

#### 1. Pattern Completeness Check

- [ ] **Header Metadata**: All 5 fields present (Purpose, Version, Created, Last Updated, Applies To)
- [ ] **Imperative Keywords**: At least 5 uses of MUST/NEVER/ALWAYS/CRITICAL/NON-NEGOTIABLE
- [ ] **Blocking Checkpoints**: At least 1 checkpoint with full template structure (Verification → Blocked → Enforcement → NON-NEGOTIABLE)
- [ ] **Anti-Patterns**: At least 3 anti-patterns with DON'T → DO → Why structure
- [ ] **Evidence Citations**: At least 2 evidence/rationale statements for key rules

#### 2. Gold Standard Alignment Check

Compare enhanced SOP to todowrite-guide.md:

- [ ] **Imperative Language Density**: Similar keyword usage pattern (check first 3 sections)
- [ ] **Checkpoint Structure**: Matches canonical template (Section 3 of this template)
- [ ] **Anti-Pattern Format**: Matches DON'T/DO/Why structure (Section 4 of this template)
- [ ] **Evidence Style**: Citations follow evidence pattern formats (Section 5 of this template)

#### 3. Quality Verification

- [ ] **No Soft Language**: Search for "should", "consider", "recommended", "try to" - MUST replace with imperatives
- [ ] **Actionable Verification Steps**: All checkpoint verification steps are concrete (not vague)
- [ ] **Complete Anti-Patterns**: All anti-patterns include both DON'T and DO examples (not just one)
- [ ] **Cited Evidence**: No unsupported claims (all requirements have rationale or evidence)

#### 4. Compatibility Verification

- [ ] **Additive-Only**: No existing content removed (only additions/replacements)
- [ ] **Cross-References Intact**: References to other SOPs still valid
- [ ] **Structure Preserved**: Original section hierarchy maintained (subsections added, not restructured)
- [ ] **Backward Compatible**: Existing commands/agents can still use enhanced SOP without changes

#### 5. RPTC-Specific Verification

- [ ] **TodoWrite Integration**: If SOP applies to commands, references TodoWrite blocking pattern
- [ ] **Command Phases**: If SOP applies to workflow commands, aligns with research/plan/tdd/commit phases
- [ ] **Agent Context**: If SOP referenced by agents, includes agent-specific guidance
- [ ] **PM Approval Gates**: If SOP involves quality gates, references PM approval pattern

### Verification Report Format

After completing verification, provide structured report:

```markdown
## Step [N] Verification Report: [SOP Name]

**Enhancement Completeness**: [✅ PASS / ❌ FAIL]
- Header metadata (5 fields): [✅/❌]
- Imperative keywords (≥5 uses): [✅/❌] ([actual count])
- Blocking checkpoints (≥1 complete): [✅/❌] ([actual count])
- Anti-patterns (≥3 with DON'T/DO/Why): [✅/❌] ([actual count])
- Evidence citations (≥2): [✅/❌] ([actual count])

**Gold Standard Alignment**: [✅ PASS / ❌ FAIL]
- Imperative language density: [✅/❌]
- Checkpoint structure match: [✅/❌]
- Anti-pattern format match: [✅/❌]
- Evidence citation style: [✅/❌]

**Quality Verification**: [✅ PASS / ❌ FAIL]
- Soft language eliminated: [✅/❌] ([remaining count if any])
- Verification steps actionable: [✅/❌]
- Anti-patterns complete: [✅/❌]
- Evidence support complete: [✅/❌]

**Compatibility Verification**: [✅ PASS / ❌ FAIL]
- Additive-only changes: [✅/❌]
- Cross-references intact: [✅/❌]
- Structure preserved: [✅/❌]
- Backward compatible: [✅/❌]

**RPTC-Specific Verification**: [✅ PASS / ❌ FAIL]
- TodoWrite integration (if applicable): [✅/❌/N/A]
- Command phase alignment (if applicable): [✅/❌/N/A]
- Agent context (if applicable): [✅/❌/N/A]
- PM approval gates (if applicable): [✅/❌/N/A]

**Overall Assessment**: [✅ READY FOR NEXT STEP / ❌ NEEDS REVISION]

**Issues Found** (if any):
- [Issue 1 with line number reference]
- [Issue 2 with specific example]

**Recommendations** (if issues found):
- [Specific fix for Issue 1]
- [Specific fix for Issue 2]
```

### Verification Failure Handling

**If verification FAILS**:

1. **Document Issues**: List all specific gaps/problems with line number references
2. **Create Revision Plan**: Specific fixes needed (not general "improve X")
3. **Re-verify After Fixes**: Run complete verification checklist again
4. **Maximum 2 Revision Cycles**: If still failing after 2 revisions, escalate to plan review

**If verification PASSES**:

1. **Mark Step Complete**: Update plan overview status tracking
2. **Proceed to Next Step**: Begin next SOP enhancement (Steps 2-7) or agent updates (Step 4)

---

## Validation Against todowrite-guide.md

This template has been validated against the gold standard:

### Pattern Extraction Validation

- [x] **Imperative Keywords**: All 7 keywords extracted from lines 434-452
- [x] **Blocking Checkpoint Template**: Structure extracted from lines 394-421
- [x] **Anti-Pattern Format**: DON'T/DO/Why structure extracted from lines 528-601
- [x] **Evidence Pattern**: Citation formats extracted from line 454 and research context
- [x] **Header Metadata**: Format extracted from lines 1-9

### Coverage Validation

- [x] **All 5 Core Sections**: Header, Imperatives, Checkpoints, Anti-Patterns, Evidence documented
- [x] **Real-World Examples**: Each section includes concrete examples from todowrite-guide.md
- [x] **Actionable Guidance**: Steps 2-7 can apply this template without additional research
- [x] **Sub-Agent Verifiable**: Verification checklist provides clear pass/fail criteria

### Alignment with Research Findings

This template enables Steps 2-7 to replicate todowrite-guide.md's success:

- **80% reduction in step-skipping** (imperative language pattern - Section 2)
- **100% quality gate enforcement** (blocking checkpoint pattern - Section 3)
- **60%+ reduction in step-skipping behavior** (anti-pattern prevention - Section 4)
- **Evidence-based compliance** (rationale pattern prevents "why?" questions - Section 5)

---

## Version History

**v1.0.0** (2025-01-21)
- Initial template creation
- Extracted from todowrite-guide.md gold standard
- Validated against research findings
- Ready for Steps 2-7 SOP enhancements

---

**End of AI-SOP Enhancement Pattern Template**
