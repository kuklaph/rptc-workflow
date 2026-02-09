---
name: tool-guide
description: Shared tool prioritization for all RPTC agents. Covers Serena MCP (read-only and edit operations), Sequential Thinking MCP, Serena Memory, Context7, Fetch MCP, and directory exploration. Load at session start before any work.
---

# Tool Guide

Tool prioritization and usage patterns for RPTC agents.

---

## Serena MCP (Prefer Over Native Tools)

Serena tools may appear as `mcp__serena__*` or `mcp__plugin_serena_serena__*` — use whichever is available.

### Read-Only Operations

| Task | Prefer Serena | Over Native |
|------|---------------|-------------|
| Find functions/classes | `get_symbols_overview` | Grep |
| Locate specific code | `find_symbol` | Glob |
| Find usages/references | `find_referencing_symbols` | Grep |
| Regex search | `search_for_pattern` | Grep |
| Reflect on findings | `think_about_collected_information` | — |
| List directory | `list_dir` | LS |

### Edit Operations (Agents with Edit Access Only)

| Task | Prefer Serena | Over Native |
|------|---------------|-------------|
| Replace function body | `replace_symbol_body` | Edit |
| Insert after symbol | `insert_after_symbol` | Edit |
| Insert before symbol | `insert_before_symbol` | Edit |
| Rename symbol | `rename_symbol` | Edit |
| Reflect on task | `think_about_task_adherence` | — |

---

## Sequential Thinking MCP

Use `sequentialthinking` tool for complex reasoning. It may appear as:
- `mcp__sequentialthinking__sequentialthinking`
- `mcp__MCP_DOCKER__sequentialthinking`
- `mcp__plugin_sequentialthinking_sequentialthinking__sequentialthinking`

Use whichever variant is available.

**When to use:**
- Complex planning decisions
- Multi-step analysis
- Architectural trade-off evaluation
- Ambiguous match resolution
- Complex security analysis

---

## Serena Memory (Optional)

Use `write_memory` to persist important discoveries for future sessions — things that would go in CLAUDE.md:

- Architectural decisions and constraints
- Non-obvious patterns or gotchas ("X uses Y because of Z")
- Key relationships between components
- Testing patterns specific to the project
- Documentation conventions and structures

**Read memory first** to check for existing knowledge before starting analysis.

**Naming convention**: `[domain]-[project]-[topic]` (e.g., `docs-rptc-structure`, `security-myapp-auth`)

---

## Other MCP Tools

### Context7 (Library Documentation)

When available, use for up-to-date library documentation:
- `resolve-library-id` — Find library identifier
- `get-library-docs` — Fetch documentation

May appear as `mcp__context7__*`, `mcp__MCP_DOCKER__*`, or `mcp__plugin_context7_context7__*`.

### Fetch MCP (Web Content)

Prefer over WebFetch for web content retrieval:
- May appear as `mcp__fetch__fetch`, `mcp__MCP_DOCKER__fetch`, or `mcp__plugin_MCP_DOCKER_MCP_DOCKER__fetch`

### IDE MCP (Diagnostics)

When available, use for IDE integration:
- `getDiagnostics` — Get IDE diagnostic information
- `executeCode` — Execute code in IDE context

---

## Directory Exploration

- Use Serena `list_dir` or native `LS` for quick directory listing
- Use `NotebookRead` for Jupyter notebooks in data science codebases

---

## Context Management

- Clear old search results after extracting information
- Maintain structured notes (smaller token footprint)
- Preserve all source URLs (never lose citations)

---

## Progress Tracking

Use `TodoWrite` for long sessions to track:
- Phases completed
- Files analyzed
- Questions to follow up
