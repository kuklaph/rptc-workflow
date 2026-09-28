---
name: tdd-agent-methodology
description: Execution contract for an RPTC implementation agent using vertical TDD. Use when a delegated implementation agent owns a bounded code change.
---

# TDD Agent Methodology

Follow `rptc:tdd-methodology` for the slice loop and test quality.

When behavior changes at a practical seam, produce a failing check before the
implementation. Otherwise state why and use the closest executable check.
Before reporting, inspect the final diff and remove temporary instrumentation.

## Ownership

- Stay inside the file and behavior scope supplied by the parent.
- Read the relevant production and test patterns before editing.
- Do not widen the feature, redesign unrelated modules, or modify shared files
  owned by another worker.
- Return findings that require product judgment to the parent.

## Report

Return:

- files changed;
- behaviors implemented;
- failing-before evidence, or why none applied;
- passing-after evidence;
- checks run;
- deviations from the plan;
- unresolved or inconclusive items.
