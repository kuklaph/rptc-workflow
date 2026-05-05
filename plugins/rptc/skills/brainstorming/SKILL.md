---
name: brainstorming
description: Use during planning phases to explore user intent, requirements, and design through structured dialogue before implementation.
---

# Brainstorming Ideas Into Designs

## Overview

Transform ideas into fully formed designs through natural collaborative dialogue. Use the structured question mechanism available in the current provider.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design in small sections (200-300 words), validating each section before proceeding.

## When to Use

Use this skill in planning phases:

- RPTC feature workflow Phase 2 (Claude: `/rptc:feat`; Codex: `rptc-workflow` feature intent) - when requirements need clarification
- RPTC fix workflow Phase 2 (Claude: `/rptc:fix`; Codex: `rptc-workflow` fix intent) - when fix approach needs exploration
- `architect-agent` - when designing implementation approach

## The Process

### First: Enter Planning Context

**Before brainstorming begins**, enter the provider's planning context. Brainstorming is a planning activity, so use the current session's planning primitive before collaborative design work.

Provider mapping:
- Claude: `EnterPlanMode`
- Codex: concise plan in chat plus `update_plan` when task tracking is useful

---

### Phase 1: Understanding the Idea

**Actions**:
- Check current project context (files, docs, recent changes)
- Ask questions one at a time using the provider's structured question primitive
- Prefer multiple choice options when possible
- Focus on: purpose, constraints, success criteria

**Structured Question Format**:
```
Question: "What is the primary goal of this feature?"
Header: "Goal"
Options:
- label: "Performance improvement"
  description: "Make existing functionality faster"
- label: "New capability"
  description: "Add functionality that doesn't exist"
- label: "User experience"
  description: "Improve how users interact with the system"
```

**Rules**:
- Only ONE question per prompt/question call
- If a topic needs more exploration, ask follow-up questions sequentially
- Never overwhelm with multiple questions at once

### Phase 2: Exploring Approaches

**Actions**:
- Propose 2-3 different approaches with trade-offs
- Lead with your recommended option and explain why
- Present options conversationally

**Structured Question Format**:
```
Question: "Which approach fits your needs?"
Header: "Approach"
Options:
- label: "Option A (Recommended)"
  description: "Simple implementation, covers 80% of use cases"
- label: "Option B"
  description: "More flexible, but adds complexity"
- label: "Option C"
  description: "Most comprehensive, highest effort"
```

### Phase 3: Presenting the Design

**Actions**:
- Present design in sections of 200-300 words
- Validate each section before proceeding
- Cover: architecture, components, data flow, error handling, testing

**Validation Format**:
```
Question: "Does this architecture section look right?"
Header: "Validate"
Options:
- label: "Yes, continue"
  description: "This section is correct, proceed to next"
- label: "Needs changes"
  description: "I have feedback on this section"
- label: "Go back"
  description: "Let's revisit earlier decisions"
```

## After the Design

**Documentation**:
- Write validated design to the provider planning context
- Reference `writing-clearly-and-concisely` skill for prose quality
- Get user approval on the final design using the current provider's approval primitive

Provider mapping:
- Claude: `ExitPlanMode`
- Codex: concise approval request in chat; use `update_plan` to track accepted steps

**Transition**:
- For the RPTC feature workflow: Proceed to Phase 3 (TDD Implementation)
- For the RPTC fix workflow: Proceed to Phase 3 (Fix Application)
- For `architect-agent`: Return design to main context

## Key Principles

| Principle | Description |
|-----------|-------------|
| **One question at a time** | Never overwhelm with multiple questions |
| **Multiple choice preferred** | Easier to answer than open-ended |
| **YAGNI ruthlessly** | Remove unnecessary features from designs |
| **Explore alternatives** | Always propose 2-3 approaches |
| **Incremental validation** | Present design in sections, validate each |
| **Be flexible** | Go back and clarify when needed |

## Tool Usage Summary

| Action | Tool |
|--------|------|
| Enter planning context | Claude: EnterPlanMode; Codex: chat plan + update_plan |
| Ask clarifying questions | Provider question primitive, one at a time |
| Present approach options | Provider question primitive with 2-4 options |
| Validate design sections | Provider question primitive (yes/changes/back) |
| Explore codebase | Serena MCP or native tools |
| Document design | Claude plan record; Codex chat plan + `update_plan` unless a project plan file is requested |
| Complete planning | Claude: ExitPlanMode; Codex: chat approval + update_plan |
