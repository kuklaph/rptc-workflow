---
name: rptc-verify
description: Run quality verification agents on demand. Use when the user asks for /rptc:verify or the equivalent RPTC Codex workflow intent.
---

# /rptc:verify

Run quality verification agents independently. Use after any code change — inside or outside the RPTC workflow.

**Arguments**:
- None: `/rptc:verify` - Verify uncommitted changes (git diff)
- With path: `/rptc:verify "src/"` - Verify specific directory or files
- Full app: `/rptc:verify "."` - Verify entire codebase

## Skills Usage Guide

**`writing-clearly-and-concisely`** - Apply Strunk's Elements of Style to verification output:

| When | Apply To |
|------|----------|
| Phase 5 | Summary report, finding descriptions |

**Key rules**: Active voice, positive form, definite language, omit needless words.

## Custom Agent Availability

Before spawning verification agents, verify the required TOML agents are installed in `.codex/agents/` or the user's Codex agents directory.

Required based on selection: `rptc:code-review-agent`, `rptc:security-agent`, `rptc:docs-agent`.

If any selected TOML is missing, use/load `rptc-init` to copy the packaged agents, then re-check. If agents are still unavailable, run the selected review scopes in the main context and report the limitation.

## Phase 2: Agent Selection

**Goal**: Let user choose which verification agents to run.

**Actions**:

1. **Ask user for agent selection** via request_user_input when available, otherwise ask directly in chat:

   ```
   Use request_user_input when available, otherwise ask directly in chat:
   question: "Which verification agents should run?"
   header: "Agents"
   options:
     - label: "Full (Recommended)"
       description: "All 3 agents: Code Review + Security + Documentation"
     - label: "Code + Security"
       description: "Code Review + Security agents (skip documentation)"
     - label: "Docs only"
       description: "Documentation agent only"
   ```

2. **Map selection to agent list**:
   - "Full" → `rptc:code-review-agent`, `rptc:security-agent`, `rptc:docs-agent`
   - "Code + Security" → `rptc:code-review-agent`, `rptc:security-agent`
   - "Docs only" → `rptc:docs-agent`

## Phase 4: Consolidate and Address Findings

**Goal**: Process agent findings and apply fixes.

**Actions**:

1. **Consolidate findings** from all launched agents:
   - Categorize: bugs, security, style, structural, documentation
   - Filter to high-confidence issues only (≥80)

2. **Create update_plan for ALL findings**:
   ```
   update_plan with status="pending":
   - [Category] Finding 1: description (file:line)
   - [Category] Finding 2: description (file:line)
   ...
   ```

3. **Auto-fix findings** (no user approval needed for most issues):

   **Fix automatically** (Tier 2-4):
   - Nits: naming, formatting, minor style issues
   - Dead code removal
   - Missing error handling
   - Documentation updates
   - Test coverage gaps
   - Minor refactoring (<30 lines)

   **Ask user FIRST** (Tier 1 or significant work):
   - Architecture changes (layer violations, new abstractions)
   - Security vulnerabilities (may need broader review)
   - Breaking API changes
   - Major refactoring (>50 lines or multiple files)
   - Integration issues (orphan code - user decides: wire up or remove)

   **Process**:
   - Work through update_plan items sequentially
   - For auto-fix items: Apply fix, mark complete
   - For ask-first items: Use request_user_input when available, otherwise ask directly in chat with fix proposal, then apply or skip
   - Mark all todos complete as addressed

## Key Principles

1. **Standalone operation**: Works independently of `/rptc:feat` and `/rptc:fix`
2. **Same agents, same quality**: Uses identical verification agents as Phase 4
3. **User controls scope**: Default to git diff, accept path overrides
4. **Always asks agent selection**: Unlike Phase 4 (which reads `verification-agent-mode` from AGENTS.md), this command always prompts via request_user_input when available, otherwise ask directly in chat — giving users explicit control each run
5. **Auto-fix by default**: Fix Tier 2-4 issues automatically; ask only for Tier 1 or major changes
6. **Confidence filtering**: Only surface issues ≥80 confidence

---

## Error Handling

- **No files to verify**: Ask user for path or suggest full-app scan
- **Agent fails**: Report which agent failed, continue with others
- **No findings**: Report clean bill of health
- **Git not available**: Fall back to requiring path argument
