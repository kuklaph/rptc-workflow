---
name: research-methodology
description: Research modes and methodology for the RPTC research agent. Covers Mode A (4-phase codebase exploration), Mode B (20+ source web research with cross-verification), Mode C (hybrid with gap analysis), mode selection logic, output formats, and quality standards.
---

# Research Methodology

Research modes and execution patterns for the RPTC research agent.

---

## Research Modes

### Mode A: Codebase Exploration

Use when researching existing code, patterns, or architecture.

**4-Phase Code-Explorer Methodology:**

#### Phase 1: Feature Discovery

- Identify entry points (APIs, CLI, UI handlers)
- Find core files that implement the feature
- Map feature boundaries and scope
- List public interfaces and contracts

#### Phase 2: Code Flow Tracing

- Trace call chains from entry to exit
- Identify data transformations at each step
- Document side effects (DB writes, external calls, state changes)
- Map error handling paths

#### Phase 2.5: Clarifying Questions (Optional)

Before deep-diving into architecture, pause if:

- Scope is ambiguous or overly broad
- Multiple interpretations of the research topic exist
- Critical context is missing

Ask user for clarification before proceeding.

#### Phase 3: Architecture Analysis

- Identify architectural layers (presentation, business, data)
- Find patterns in use (repository, factory, strategy, etc.)
- Map cross-cutting concerns (logging, auth, caching)
- Document dependencies between components

#### Phase 4: Implementation Details

- Understand algorithms and data structures
- Identify edge cases handled (and not handled)
- Note tech debt and TODOs
- Find tests and coverage gaps

**Output for Mode A:**

```markdown
## Codebase Research: [Topic]

### Essential Files
- `src/api/handler.ts:45-120` - Entry point, request validation
- `src/services/processor.ts:78` - Core transformation logic

### Architecture Overview
[Layers, patterns, key abstractions]

### Code Flow
[Entry -> Processing -> Exit with key transformations]
Reference specific lines: `file.ts:line` for each step

### Key Patterns
[Patterns found with file:line examples]

### Potential Issues
[Tech debt, gaps, edge cases with file:line locations]
```

**Line Reference Requirement**: Always include `file:line` or `file:line-line` format.

---

### Mode B: Web Research

Use when researching external best practices, tools, or industry standards.

**Goal**: Gather authoritative information from 20+ diverse sources.

**Actions**:

1. **Plan** - Use extended thinking to decompose topic into 3-5 subtopics
2. **Search** - Execute multi-source queries (academic, industry, community, official)
3. **Validate** - Cross-verify all claims:
   - 5+ sources -> High confidence
   - 3-4 sources -> Medium confidence
   - 1-2 sources -> Low confidence (flag for review)
4. **Synthesize** - Organize findings with confidence levels and source attribution

**Source Diversity Requirements**:

- Academic: Peer-reviewed papers, university research
- Industry: Official documentation, vendor white papers
- Community: GitHub repos, Stack Overflow, expert blogs
- Official: Standards bodies (IETF, NIST, W3C)

**Validation Rules**:

- Never trust citations without verification
- Mark unverifiable claims as [NEEDS VERIFICATION]
- Present all perspectives when sources conflict
- Note potential bias (vendor sources, conflicts of interest)

**Output for Mode B:**

```markdown
## Web Research: [Topic]

### Executive Summary
[2-3 sentence overview]

### Key Findings
- [Finding] (confidence: high/medium/low, sources: N)

### Best Practices
1. [Practice]: [Why it matters] - [Source URL]

### Common Pitfalls
1. [Pitfall]: [Solution] - [Source URL]

### Recommended Tools
- [Tool]: [Purpose] - [Source URL]

### Sources
- [N] academic, [N] industry, [N] community, [N] official
```

---

### Mode C: Hybrid Research

Use when comparing codebase implementation against external best practices.

**Process:**

1. Run Mode A (codebase exploration)
2. Run Mode B (web research) in parallel
3. Gap analysis: Current implementation vs. best practices
4. Prioritized recommendations

**Output for Mode C:**

```markdown
## Hybrid Research: [Topic]

### Current Implementation
[Summary from Mode A]

### Best Practices
[Summary from Mode B]

### Gap Analysis

| Aspect | Current | Best Practice | Gap | Priority |
| ------ | ------- | ------------- | --- | -------- |

### Recommendations
1. [Prioritized recommendation with rationale]
```

---

## Mode Selection

Determine mode from topic keywords:

- **Mode A**: "where is", "how does our", "existing", "refactor", "find in codebase"
- **Mode B**: "best practices", "compare", "latest", "industry standard", "how to implement"
- **Mode C**: Both types of keywords present

---

## Templates

For detailed output format templates, reference:

- `${CLAUDE_PLUGIN_ROOT}/templates/research-codebase.md` - Mode A output format
- `${CLAUDE_PLUGIN_ROOT}/templates/research-web.md` - Mode B output format
- `${CLAUDE_PLUGIN_ROOT}/templates/research-hybrid.md` - Mode C output format

---

## File Writing

- Return findings INLINE by default
- Only write files when parent command explicitly instructs

---

## Quality Standards

- 20+ sources consulted, 15+ cited (Mode B/C)
- Source diversity (academic, industry, community, official)
- All claims cross-verified or marked as single-source
- Confidence levels assigned to all findings
- 100% citation integrity (no hallucinated sources)
- Actionable recommendations (not just descriptions)
- Every claim linked to specific source URL
