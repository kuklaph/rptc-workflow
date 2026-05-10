---
name: rptc-verify-loop
description: Run quality verification agents in a loop until all report 0 findings. Use when the user asks for /rptc:verify-loop or the equivalent RPTC Codex workflow intent.
---

# /rptc:verify-loop

Run quality verification agents repeatedly until all agents report 0 findings.
After each iteration, auto-fix mechanical issues and optionally fix structural
issues with user approval. Use when you want a fully clean result, not just a
single-pass check.

**Arguments**:
- None: `/rptc:verify-loop` - Verify uncommitted changes (git diff)
- With path: `/rptc:verify-loop "src/"` - Verify specific directory or files
- Full app: `/rptc:verify-loop "."` - Verify entire codebase

## Skills Usage Guide

**`writing-clearly-and-concisely`** - Apply Strunk's Elements of Style to all output:

| When | Apply To |
|------|----------|
| Phase 4 | Summary report, finding descriptions, iteration headers |

**Key rules**: Active voice, positive form, definite language, omit needless words.

## Custom Agent Availability

Before spawning verification agents, verify the required TOML agents are installed in `.codex/agents/` or the user's Codex agents directory.

Required based on selection: `rptc:code-review-agent`, `rptc:security-agent`, `rptc:docs-agent`.

If any selected TOML is missing, use/load `rptc-init` to copy the packaged agents, then re-check. If agents are still unavailable, run the selected review scopes in the main context and report the limitation.

## Phase 2: Agent Selection

**Goal**: Ask the user once which agents to run. The same set runs every iteration.

**Actions**:

1. **Ask user for agent selection** via request_user_input when available, otherwise ask directly in chat:

   ```
   Use request_user_input when available, otherwise ask directly in chat:
   question: "Which verification agents should run each iteration?"
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

#### 1. Iteration Header

Print at the start of each iteration:

```
--- Iteration [N] / max [M] ---
Running [agent list] on [N] files...
```

#### 3. Launch Verification Agents (parallel)

**AGENT NAMESPACE LOCKOUT:**
- ✅ CORRECT: RPTC `rptc:code-review-agent` role
- ❌ WRONG: `feature-dev:code-reviewer` role — different plugin, not RPTC
- ❌ WRONG: `code-review:code-review` role — different plugin, not RPTC
- The `rptc:` prefix is required for ALL verification agents. No exceptions.

Make `spawn_agent` calls for each selected agent simultaneously:

**Code Review Agent** (if selected):
```
Use `spawn_agent` with the RPTC `rptc:code-review-agent` role when installed:
⚠️ WRONG agents: "feature-dev:code-reviewer", "code-review:code-review" — DO NOT USE

prompt: "Review code quality for these files: [list files].
Focus: complexity, KISS/YAGNI violations, dead code, readability.
REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."
```

**Security Agent** (if selected):
```
Use `spawn_agent` with the RPTC `rptc:security-agent` role when installed:
prompt: "Security review for these files: [list files].
Focus: input validation, auth checks, injection vulnerabilities, data exposure.
REPORT ONLY - do not make changes. Output: confidence-scored findings (≥80 only)."
```

**Documentation Agent** (if selected):
```
Use `spawn_agent` with the RPTC `rptc:docs-agent` role when installed:
prompt: "Review documentation impact for these files: [list files].
Focus: README updates, API doc changes, inline comment accuracy, breaking changes.
REPORT ONLY - do not make changes. Output: documentation updates needed (≥80 only)."
```

Wait for all agents to complete.

#### 5. Stagnation Check

For each remaining finding, compute a stable key:
`"file:line:category:first-8-words-of-description"`

Compare against `findings_history`:
- Increment hit count for each key seen this iteration
- Reset hit count to 0 for any key NOT seen this iteration

If any key has a consecutive hit count ≥ 2 (appeared in 2+ consecutive iterations
without being fixed):

```
Use request_user_input when available, otherwise ask directly in chat:
question: "Stagnation detected: [N] finding(s) keep returning after attempted fixes.
           These may require manual intervention. Stop or keep trying?"
header: "Stagnation"
options:
  - label: "Stop and summarize"
    description: "Accept remaining findings as known issues and wrap up"
  - label: "Keep going"
    description: "Continue the loop — I'll handle these differently"
```

If "Stop and summarize" → record exit reason `STAGNATION` → **EXIT LOOP**
If "Keep going" → reset hit count to 0 for all currently stagnating keys in
`findings_history` (this prevents re-triggering the stagnation prompt next
iteration; the check will only fire again if those same findings return for 2
more consecutive iterations after the reset)

#### 7. Post-Fix Check

If ALL remaining findings are now in `skipped_tier1` (user declined every one):
→ record exit reason `USER_SKIPPED` → **EXIT LOOP**

### Loop Exit Summary

| Exit Reason | Meaning |
|-------------|---------|
| `CLEAN` | All agents returned 0 findings |
| `USER_SKIPPED` | All remaining findings were declined by user |
| `STAGNATION` | Same findings returned 2+ consecutive iterations; user stopped |
| `MAX_ITERATIONS` | User chose to stop at iteration limit |

## Important Notes

1. **Scope and agents fixed at start**: Determined in Phases 1-2 and never re-asked
2. **Same agents, same quality**: Uses identical verification agents as Phase 4 of `/rptc:feat`
3. **Auto-fix by default**: Fix Tier 2-4 findings without interruption; ask only for Tier 1
4. **Safety over completeness**: Stagnation detection, max iterations, and skip tracking
   guarantee the loop always exits
5. **Skipped findings persist**: Once a user declines a finding, it is not raised again
6. **Confidence filtering**: Only surface issues ≥80 confidence

---

## Error Handling

- **No files to verify**: Ask user for path or suggest full-app scan
- **Agent fails**: Report which agent failed, continue with others, count as 0 findings from that agent
- **All agents fail**: Exit loop, report failure, suggest re-running
- **No findings on first iteration**: Report clean immediately, skip remaining iterations
- **Git not available**: Fall back to requiring path argument
