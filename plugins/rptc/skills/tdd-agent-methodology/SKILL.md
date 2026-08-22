---
name: tdd-agent-methodology
description: Execution contract for an RPTC implementation agent using vertical TDD. Use when a delegated implementation agent owns a bounded code change.
---

# TDD Agent Methodology

Read and follow `rptc:tdd-methodology`.

## Ownership

- Stay inside the file and behavior scope supplied by the parent.
- Read the relevant production and test patterns before editing.
- Do not widen the feature, redesign unrelated modules, or modify shared files
  owned by another worker.
- Return findings that require product judgment to the parent.

## Execution

1. Name the next observable behavior and test seam.
2. Produce a failing executable check.
3. Confirm the failure is the intended signal.
4. Implement the smallest coherent change.
5. Confirm the check passes.
6. Run nearby affected checks.
7. Repeat for the next slice.
8. Inspect the final diff and remove temporary instrumentation.

## Report

Return:

- files changed;
- behaviors implemented;
- failing-before evidence;
- passing-after evidence;
- checks run;
- deviations from the plan;
- unresolved or inconclusive items.

Do not use a compliance score or claim success without the evidence.
