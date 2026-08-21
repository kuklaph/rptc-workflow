# RPTC engineering policy

These invariants apply across Claude Code and Codex. Provider adapters decide how
to track work, ask questions, enter planning mode, and delegate agents.

1. **Ground before changing.** Read the affected contracts, code, tests, and
   established project patterns.
2. **Prefer the smallest coherent change.** Reuse an established pattern unless
   evidence shows that it is inadequate.
3. **Verify claims.** Do not call behavior correct, fixed, complete, or safe
   without an observable check.
4. **Treat plans as hypotheses.** Revise a design when implementation or runtime
   evidence contradicts it.
5. **Fix causes.** Do not retain speculative workarounds after evidence rejects
   the hypothesis that motivated them.
6. **Project rules win.** Repository-defined commands, conventions, constraints,
   and approval policies override RPTC defaults.

## Human authority

The user owns product intent, consequential trade-offs, scope expansion, and
irreversible actions. The agent owns discoverable facts and reversible execution.

Ask the user when a decision depends on preference or product intent. Investigate
when a repository, runtime, or source can answer the question.
