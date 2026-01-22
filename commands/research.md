---
description: Interactive discovery and brainstorming with parallel exploration
allowed-tools: Bash(git *), Read, Glob, Grep, LS, Task, TodoWrite, AskUserQuestion, WebFetch, WebSearch
---

# /rptc:research

Research partner for discovery and brainstorming. Use before `/rptc:feat` when you need deep understanding first.

**Arguments**: Topic to research (e.g., "authentication system", "payment processing")

---

## Phase 1: Understand the Question

**Goal**: Clarify what the user wants to learn.

**Actions**:
1. Parse the research topic
2. Classify research type:
   - **Codebase**: "where is", "how does our", "existing", "refactor"
   - **Web**: "best practices", "compare", "latest", "industry standard"
   - **Hybrid**: Contains both types of keywords
3. If unclear, ask user to clarify scope

---

## Phase 2: Discovery

**Goal**: Gather information using appropriate methods.

### For Codebase Research

**Actions**:
1. **Launch 2-3 Explore agents in parallel** with different focuses:

```
Use Task tool with subagent_type="Explore" (launch all 3 in parallel):

Agent 1 prompt: "Find similar features and existing patterns for [topic]. Return: files implementing similar functionality, patterns used."

Agent 2 prompt: "Analyze architecture and abstractions related to [topic]. Return: layers involved, key abstractions, design patterns."

Agent 3 prompt: "Map integration points and dependencies for [topic]. Return: external dependencies, internal dependencies, API boundaries."
```

2. **Consolidate findings**:
   - Essential files list
   - Architecture overview
   - Key patterns identified
   - Potential issues or tech debt

### For Web Research

**Actions**:
1. **Delegate to master-research-agent** with context:

```
Use Task tool with subagent_type="rptc:master-research-agent":

prompt: "Research [topic] for [project tech stack].
Questions to answer: [specific questions].
This will inform: [what decisions].
Return: findings with confidence levels, recommendations, sources."
```

2. **Expected output**:
   - 20+ sources consulted
   - Cross-verified findings
   - Recommendations with confidence levels

### For Hybrid Research

**Actions**:
1. Launch codebase exploration AND web research in parallel
2. Gap analysis: What does our code do vs. what best practices recommend?
3. Prioritized recommendations

---

## Phase 3: Interactive Clarification

**Goal**: Ensure understanding before synthesis.

**Actions**:
1. As findings emerge, ask clarifying questions if:
   - Multiple valid interpretations exist
   - Scope needs narrowing
   - User's priorities are unclear
2. Do NOT ask mandatory menu questions - only ask when genuinely uncertain

---

## Phase 4: Present Findings

**Goal**: Deliver actionable insights inline.

**Actions**:
1. **Summary** (2-3 sentences)
2. **Key Findings** (bulleted, prioritized)
3. **Recommendations** (with confidence levels)
4. **Next Steps** (what to do with this research)

**Output format** (inline, not file):

```markdown
## Research: [Topic]

### Summary
[2-3 sentence overview]

### Key Findings
- [Finding 1] (confidence: high/medium/low)
- [Finding 2]
- [Finding 3]

### Recommendations
1. [Recommendation 1] - [rationale]
2. [Recommendation 2] - [rationale]

### Next Steps
- [What to do next]
```

---

## Phase 5: Optional - Save Research

**Goal**: Persist research if user explicitly requests.

**Actions** (only if user asks to save):
1. Create research document in `docs/research/`
2. Include date, methodology, detailed findings, references

```bash
mkdir -p docs/research
# Write to docs/research/YYYYMMDD-topic-slug.md
```

---

## Agent Delegation Reference

### Parallel Explore Agents (Codebase)
```
Launch 3 Task tools simultaneously with subagent_type="Explore":
- Agent 1: Similar features / existing patterns
- Agent 2: Architecture and abstractions
- Agent 3: Integration points / dependencies
```

### Research Agent (Web)
```
Use Task tool with subagent_type="rptc:master-research-agent":
prompt: "Research [topic] for [context]. Return: findings with confidence, recommendations, sources."
```

---

## Key Principles

1. **Parallel exploration**: Always use 2-3 agents for codebase research
2. **Ask when uncertain**: Don't use mandatory menus - ask naturally when needed
3. **Inline output**: Present findings in conversation, not files
4. **Save on request**: Only create files if user explicitly asks
5. **Trust agents**: Don't over-specify in delegation prompts

---

## Differences from Legacy

| Aspect | Legacy | New |
|--------|--------|-----|
| Config loading | 80 lines | 0 |
| Mandatory menus | 7+ questions | Ask when unclear |
| Exploration | Sequential | 2-3 parallel agents |
| Output | File by default | Inline by default |
| Lines of code | 1200+ | ~150 |
