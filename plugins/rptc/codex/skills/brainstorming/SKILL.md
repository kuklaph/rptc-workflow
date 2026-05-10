---
name: brainstorming
description: Use during planning phases to explore user intent, requirements, and design through structured dialogue before implementation.
---

# Brainstorming Ideas Into Designs

## Overview

Transform ideas into fully formed designs through natural collaborative dialogue. Use structured questions when the harness provides them; otherwise ask directly in chat.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design in small sections (200-300 words), validating each section before proceeding.

## When to Use

Use this skill in planning phases:

- `/rptc:feat` Phase 2 (Architecture) - when requirements need clarification
- `/rptc:fix` Phase 2 (Root Cause) - when fix approach needs exploration
- `rptc:architect-agent` - when designing implementation approach

## The Process

### First: Enter Planning Context

**Before brainstorming begins**, establish planning context using the provider's planning surface. In Codex, provide a concise plan in chat and use `update_plan` when useful.

---

### Phase 1: Understanding the Idea

**Actions**:
- Check current project context (files, docs, recent changes)
- Ask questions one at a time using `request_user_input` when available, otherwise ask directly
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
- Only ONE question per structured question or chat turn
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
- Write validated design to plan file
- Reference `writing-clearly-and-concisely` skill for prose quality
- Get user approval on the final design through the provider's approval flow or direct chat

**Transition**:
- For `/rptc:feat`: Proceed to Phase 3 (TDD Implementation)
- For `/rptc:fix`: Proceed to Phase 3 (Fix Application)
- For `rptc:architect-agent`: Return design to main context

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
| Enter planning context | Provider planning surface; in Codex, concise plan in chat and `update_plan` when useful |
| Ask clarifying questions | `request_user_input` when available, otherwise direct chat |
| Present approach options | `request_user_input` with 2-4 options when available, otherwise direct chat |
| Validate design sections | `request_user_input` or direct chat |
| Explore codebase | Serena MCP or native tools |
| Document design | Write to plan file |
| Complete planning | Provider approval flow or direct chat when design is ready |
