---
name: rptc-verify-loop
description: Fix accepted RPTC verification findings and recheck the affected evidence until claims are verified, failed, inconclusive, or explicitly left open. Use for iterative verify-fix-recheck work.
---

# RPTC Verify Loop

Shared contract: `shared/workflows/verification.md`

This compatibility flow converges on resolved evidence, not zero model findings.

## 1. Initialize

Load `rptc:verification-evidence` and read the shared verification contract.
Keep the loop and its current finding in `update_plan`.

## 2. Iterate

1. Run the `rptc:rptc-verify` contract on the fixed scope.
2. Separate confirmed findings from context-needed and inconclusive items.
3. Obtain approval for consequential fixes. `request_user_input` requires Codex
   Plan Mode; otherwise ask in normal chat and stop for the answer.
4. Apply accepted fixes in the parent or through a bounded custom agent.
5. At every `spawn_agent`, immediately call `wait_agent` for all required IDs.
6. Rerun the affected checks, original acceptance predicates, and only the
   review axes that raised confirmed findings.
7. Stop when every material claim is verified, failed, inconclusive, or accepted
   as open.

## 3. Safety

Default to five iterations. Stop when evidence stagnates, the environment is
unavailable, scope would expand, a product decision is required, or no accepted
fix changed the result.

An agent failure is not zero findings. Declined findings remain in the report.

## 4. Report

Return iterations, fixes, evidence changes, open findings, and final predicate
statuses.
