---
name: tool-guide
description: Choose repository, semantic-navigation, documentation, web, and runtime tools based on the evidence needed. Use when an RPTC flow needs capability discovery or a preferred tool is unavailable.
---

# Tool Guide

## Principle

Choose the tool that gives the most direct reliable evidence with the least
unnecessary context.

## Repository work

- Use git and project files for exact current state.
- Use semantic symbol tools when they make callers, references, or module
  structure faster to establish.
- Use native search and file tools when semantic tooling is unavailable or a
  plain text search is the better fit.
- Read actual configuration and command help rather than restating cached tool
  behavior.

No MCP server is mandatory. A missing optional tool changes the method, not the
engineering contract.

## External facts

Prefer official documentation, source repositories, specifications, and
first-party changelogs. Use community sources for practice and edge cases, with
their status made clear.

## Runtime evidence

Use the closest available control surface for the user's actual experience.
When no control surface exists, state the limitation and use the strongest
repeatable proxy without overstating what it proves.

## Delegation

Use sub-agents for bounded context-heavy work, independent evidence sources, or
separate artifacts. The parent inspects outputs and owns final judgment.

Provider adapters define the actual tool names, spawn mechanics, and waiting
rules.
