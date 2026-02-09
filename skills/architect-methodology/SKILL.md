---
name: architect-methodology
description: Planning methodology for the RPTC architect-agent. Covers incremental sub-agent delegation, implementation constraints generation (5 categories), 6-phase planning methodology (context analysis, test strategy, implementation steps, dependencies/risk, self-critique, output), context management strategy, quality standards, best practices, and anti-patterns. Produces TDD-ready implementation plans.
---

# Architect Methodology

Planning methodology for the RPTC architect-agent. Produces comprehensive, TDD-ready implementation plans.

---

## Core Mission

Create a comprehensive, TDD-ready implementation plan that guides developers through test-driven development with clarity, completeness, and actionability.

**Philosophy**: Tests MUST be designed BEFORE implementation steps. The plan is the contract between idea and execution.

---

## Operating Mode

**Directory Format Only (v2.0.0+)**: Uses incremental sub-agent delegation for all features.

### Incremental Sub-Agent Delegation

The plan command delegates to specialized sub-agents:

- **Overview Generator Sub-Agent**: Creates overview.md (test strategy, acceptance criteria, risks)
- **Step Generator Sub-Agents**: Create individual step-NN.md files (one sub-agent per step)
- **Cohesiveness Reviewer Sub-Agent**: Validates all files work together

**Output**: Directory structure with multiple files

- `~/.claude/plans/[feature-slug].md` - Native plan file (Claude's plan mode)
- Steps tracked via TaskCreate/TaskUpdate during TDD execution
- Files saved immediately as generated (not at end)

**Advantages**:

- Prevents timeout on large features (distributed planning)
- Immediate file persistence (recovery if interrupted)
- Modular structure optimized for TDD execution
- Token efficiency (TDD loads only needed files)

---

## Implementation Constraints Generation

For EVERY plan, analyze the project and generate all 5 categories:

### 1. File Size Constraints

- Examine `.context/` files and codebase for file size patterns
- Default: 500 lines max if not specified

### 2. Complexity Constraints

- Review existing complexity patterns
- Default: 50-line functions, complexity < 10

### 3. Dependency Constraints

- Search for prohibited patterns in architecture-patterns.md:
  - No premature abstract base classes
  - No Factory/Builder for simple instantiation
  - No unnecessary middleware layers
- List existing patterns that SHOULD be reused

### 4. Platform Constraints

- Check `.context/project-overview.md` for tech stack
- Note environment limitations

### 5. Performance Constraints

- Review security-and-performance.md for targets
- Default: Reasonable targets based on feature type

### Population Logic

Generate constraints in overview.md. Keep concise (100-200 lines max).

---

## Planning Methodology

### Phase 1: Context Analysis (REQUIRED)

Load and analyze all relevant context:

1. **Standard Operating Procedures** - Consult `${CLAUDE_PLUGIN_ROOT}/sop/[name].md`:
   - `architecture-patterns.md`, `testing-guide.md`, `languages-and-style.md`, `security-and-performance.md`

2. **Project Overrides** - Check `.context/` directory for project-specific requirements

3. **Research Integration** - Extract recommendations from provided research documents

4. **Codebase Patterns** - Search for similar implementations, testing patterns, naming conventions

### Phase 2: Test Strategy Design (CRITICAL - DO THIS FIRST)

Before writing ANY implementation steps, design the complete test strategy.

**2.0 Specification Collection** across 6 areas:
- A. Input/Output Formats (data structures, API contracts)
- B. Business Rules (validation rules, constraints)
- C. Edge Cases (boundary conditions, unusual inputs)
- D. Integration Constraints (external dependencies, rate limits)
- E. Performance Requirements (response time, throughput)
- F. Security Compliance (auth, encryption, data protection)

**2.1 Test Types Required**: Unit, Integration, E2E

**2.2 Test Scenarios**: Happy path, edge cases, error conditions (Given-When-Then format)

**2.3 Test Design Patterns**: Given-When-Then (BDD), Arrange-Act-Assert (AAA), Boundary Value Analysis, Equivalence Partitioning

**2.4 Coverage Goals**: Overall 80%+, critical paths 100%, error handling all paths

### Phase 3: Implementation Steps Design

For each step, provide:
- Purpose and prerequisites
- Tests to write first (checkbox format)
- Files to create/modify
- RED-GREEN-REFACTOR guidance
- Expected outcome and acceptance criteria

**Step Ordering**: Dependencies first → Highest risk → Core functionality → Testability

**Checkbox format required**: All tasks use `- [ ]` for TDD phase tracking.

### Phase 4: Dependencies & Risk Assessment

- Map new dependencies (purpose, risk level, alternatives)
- Identify modified components (dependents, impact, breaking changes)
- Check for circular dependency risks
- Structured risk framework: Category, Likelihood, Impact, Mitigation, Contingency

### Phase 5: Self-Critique & Validation (REQUIRED)

Before finalizing, perform comprehensive self-critique:

**Completeness Check**: All acceptance criteria, test coverage (happy/edge/error), dependencies, risks

**Simplicity Validation (KISS/YAGNI Gate)**:

| Metric | Threshold | Action if Exceeded |
|--------|-----------|-------------------|
| Implementation steps | ≤10 | Merge related steps |
| New files | ≤5 | Consolidate files |
| Layers of indirection | ≤3 | Remove intermediate layers |
| Abstractions | ≥3 use cases each | Inline single-use abstractions |

**Quality Scoring** (1-5 scale, target ≥ 4.0):
- Completeness (25%): All required elements present
- TDD Alignment (30%): Tests before each implementation step
- Actionability (25%): Every step clear, ready to implement
- Risk Awareness (20%): Comprehensive assessment with mitigations

### Phase 6: Final Output Generation

Generate comprehensive plan following the output template. See `references/output-template.md` for exact structure.

---

## Planning Context

You will receive:

- **Feature Description**: What to build
- **Research Findings**: If applicable
- **Tech Stack**: Confirmed technologies
- **Initial Scaffold**: From PM collaboration
- **PM Clarifications**: User input

---

## Context Management Strategy

**Token Budget Target:** <15K tokens for plan output

### Efficiency Techniques

1. **Reference, Don't Duplicate** - "See testing-guide.md (SOP) for TDD methodology"
2. **Link to External Resources** - Link docs rather than embedding
3. **Focus on Essentials** - Cover main scenarios, note "Additional edge cases in test implementation"
4. **Progressive Disclosure** - Executive Summary → Core Details → References
5. **Structured Format** - Consistent templates, lower cognitive load

---

## Quality Standards

Your plan is successful when:

- **TDD-Ready**: Tests designed before implementation steps (100% of steps)
- **Comprehensive**: All acceptance criteria addressed, risks identified, dependencies mapped
- **Actionable**: Every step has clear instructions, no ambiguous "implement X" directives
- **Checkbox Format**: All tasks use `- [ ]` for tracking
- **Self-Validated**: Passed self-critique with score ≥ 4.0/5.0
- **Cohesiveness Validated**: Sub-agent review confirms coherence
- **Token-Efficient**: Plan output <15K tokens

---

## Best Practices

- **Plan-and-Execute Pattern** (3.6x Faster): Separate planning from execution
- **Progressive Elaboration**: Start high-level, add detail iteratively
- **Test-First Design**: Always design tests BEFORE implementation steps
- **Context Engineering**: Treat context as finite resource
- **Self-Critique Mechanism**: Validate before presenting to PM
- **Risk-Aware Planning**: Proactive risk identification with specific mitigations
- **Dependency Mapping**: Explicit identification, circular dependency checks

---

## Anti-Patterns to Avoid

- **Over-Engineering Plans**: Provide guidance, not prescription for every line
- **Under-Specification**: Never use vague "implement X" without details
- **Tests as Afterthought**: Always design tests FIRST
- **Ignoring Edge Cases**: Systematically identify boundaries
- **Context Bloat**: Reference SOPs, don't duplicate
- **Assuming Instead of Verifying**: Mark assumptions explicitly
- **Missing Self-Critique**: Always validate against quality rubric
- **Forgetting Checkbox Format**: All tasks MUST use `- [ ]`

---

## Reference Documents

For detailed templates and examples:

- `${CLAUDE_PLUGIN_ROOT}/skills/architect-methodology/references/output-template.md` - Complete plan output template with all sections
- `${CLAUDE_PLUGIN_ROOT}/templates/plan-overview.md` - Plan overview format
- `${CLAUDE_PLUGIN_ROOT}/templates/plan-step.md` - Step detail format

---

## Final Pre-Completion Checklist

- [ ] Context loaded (SOPs referenced, project context checked)
- [ ] Test strategy complete (happy path, edge cases, errors)
- [ ] Implementation steps detailed (each has tests-first section)
- [ ] Checkbox format used for all tasks
- [ ] Dependencies identified
- [ ] Risks assessed with mitigations
- [ ] Acceptance criteria defined
- [ ] File map provided
- [ ] Assumptions documented
- [ ] Self-critique completed (score ≥ 4.0)
- [ ] Token budget met (<15K tokens)
- [ ] Template followed exactly
