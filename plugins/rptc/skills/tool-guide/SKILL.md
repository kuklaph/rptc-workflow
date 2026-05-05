---
name: tool-guide
description: Shared tool prioritization for all RPTC agents. Covers Serena MCP (read-only and edit operations), Serena Memory, Context7, Fetch MCP, and directory exploration. Load at session start before any work.
---

# Tool Guide

Tool prioritization and usage patterns for RPTC agents.

---

## Serena MCP (Prefer Over Native Tools)

Serena tools may appear as `mcp__serena__*` or `mcp__plugin_serena_serena__*` — use whichever is available.

### Read-Only Operations

| Task | Prefer Serena | Over provider-native equivalents |
|------|---------------|-------------|
| Find functions/classes | `get_symbols_overview` | text search |
| Locate specific code | `find_symbol` | file globbing |
| Find usages/references | `find_referencing_symbols` | text search |
| Regex search | `search_for_pattern` | text search |
| Reflect on findings | `think_about_collected_information` | — |
| List directory | `list_dir` | directory listing tools |

### Edit Operations (Agents with Edit Access Only)

| Task | Prefer Serena | Over provider-native equivalents |
|------|---------------|-------------|
| Replace function body | `replace_symbol_body` | text edit tools |
| Insert after symbol | `insert_after_symbol` | text edit tools |
| Insert before symbol | `insert_before_symbol` | text edit tools |
| Rename symbol | `rename_symbol` | text edit tools |
| Reflect on task | `think_about_task_adherence` | — |

---

## Serena Memory (Optional)

Use `write_memory` to persist important discoveries for future sessions — things that would belong in provider context files such as `CLAUDE.md`, `AGENTS.md`, or project rules:

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

- Use Serena `list_dir` or provider-native directory listing for quick directory exploration
- Use provider-native notebook reading support for Jupyter notebooks in data science codebases when available

---

## Context Management

- Clear old search results after extracting information
- Maintain structured notes (smaller token footprint)
- Preserve all source URLs (never lose citations)

---

## Progress Tracking

Use the provider's native task tracker for long sessions:
- Claude: `TodoWrite`, or `TaskCreate` / `TaskUpdate` when a workflow command uses structured tasks
- Codex: `update_plan`
- Other providers: the closest available task/progress tracker

Track:
- Phases completed
- Files analyzed
- Questions to follow up
