---
name: rptc-research
description: Interactive discovery and brainstorming with parallel exploration. Use when the user asks for /rptc:research or the equivalent RPTC Codex workflow intent.
---

# /rptc:research

Research partner for discovery and brainstorming. Use before `/rptc:feat` when you need deep understanding first.

**Arguments**: Topic to research (e.g., "authentication system", "payment processing")

## Skills Usage Guide

**`writing-clearly-and-concisely`** - Apply Strunk's Elements of Style to research output:

| When | Apply To |
|------|----------|
| Phase 3 | Research summaries, findings reports |
| Phase 4 | Recommendations, next steps |

**Key rules**: Active voice, positive form, definite language, omit needless words.

## Custom Agent Availability

Before spawning `rptc:research-agent`, verify its TOML is installed in `.codex/agents/` or the user's Codex agents directory. If missing, use/load `rptc-init` to copy the packaged agents, then re-check. If still unavailable, use the built-in `explorer` agent for codebase research and the main context for web research, and report the fallback.

## Phase 2: Discovery

**Goal**: Gather information using appropriate methods.

### For Codebase Research

**Actions**:
1. **Launch 2-3 research agents in parallel** with different focuses (NOT the built-in Explore agent):

```
IMPORTANT: Use RPTC `rptc:research-agent` role, NOT "Explore"

Use `spawn_agent` with the RPTC `rptc:research-agent` role when installed (launch all 3 in parallel):

Agent 1 prompt: "Find similar features and existing patterns for [topic].
Use code-explorer methodology Phase 1 (Feature Discovery).
Return: files implementing similar functionality, patterns used."

Agent 2 prompt: "Analyze architecture and abstractions related to [topic].
Use code-explorer methodology Phase 3 (Architecture Analysis).
Return: layers involved, key abstractions, design patterns."

Agent 3 prompt: "Map integration points and dependencies for [topic].
Use code-explorer methodology Phase 2 (Code Flow Tracing).
Return: external dependencies, internal dependencies, API boundaries."
```

2. **Consolidate findings**:
   - Essential files list
   - Architecture overview
   - Key patterns identified
   - Potential issues or tech debt

### For Web Research

**Actions**:
1. **Delegate to `rptc:research-agent`** with context:

```
Use `spawn_agent` with the RPTC `rptc:research-agent` role when installed:

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

## Key Principles

1. **Parallel exploration**: Always use 2-3 agents for codebase research
2. **Ask when uncertain**: Don't use mandatory menus - ask naturally when needed
3. **Inline output**: Present findings in conversation, not files
4. **Save on request**: Only create files if user explicitly asks
5. **Trust agents**: Don't over-specify in delegation prompts
