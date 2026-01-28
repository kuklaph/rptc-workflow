<!--
TDD Handoff Template

This template is used to generate handoff documents when TDD execution reaches
context limits (75% threshold by default). The handoff enables resuming work in
a fresh session while maintaining full context awareness.

AVAILABLE VARIABLES (substituted at generation time):

Core Identifiers:
  {{FEATURE_NAME}}           - Feature/plan name (human-readable)
  {{PLAN_NAME}}              - Plan directory name (for resume command)

Progress Tracking:
  {{COMPLETED_STEPS_COUNT}}  - Number of steps completed
  {{TOTAL_STEPS}}            - Total steps in plan
  {{NEXT_STEP_NUM}}          - Next step number to execute
  {{NEXT_STEP_NAME}}         - Next step title/description

Context Usage:
  {{CONTEXT_USAGE}}          - Percentage of context budget used (e.g., "76")
  {{ESTIMATED_TOKENS}}       - Estimated tokens consumed (e.g., "152000")
  {{MAX_TOKENS}}             - Maximum token budget (e.g., "200000")

Work Summary:
  {{COMPLETED_STEPS_SUMMARY}} - Concise summary of completed steps
  {{FILES_MODIFIED_LIST}}     - List of files modified during execution
  {{FILES_COUNT}}             - Count of modified files
  {{TESTS_PASSING}}           - Test status (e.g., "✅ All tests passing")

Metadata:
  {{TIMESTAMP}}              - Generation timestamp (UTC format)

LOCATION:
This template is provided by the RPTC plugin at:
  ${CLAUDE_PLUGIN_ROOT}/templates/handoff.md

NOTE: Do not remove required variables marked in acceptance criteria.
Unsubstituted variables ({{VAR}}) will be detected and logged as warnings.
-->

# TDD Handoff: {{FEATURE_NAME}}

## Status

**Handoff Reason:** Context limit reached ({{CONTEXT_USAGE}}% of budget)
**Completed Steps:** {{COMPLETED_STEPS_COUNT}}/{{TOTAL_STEPS}}
**Next Step:** Step {{NEXT_STEP_NUM}} - {{NEXT_STEP_NAME}}

---

## Completed Work Summary

{{COMPLETED_STEPS_SUMMARY}}

---

## Context State

**Token Usage:** {{CONTEXT_USAGE}}% ({{ESTIMATED_TOKENS}}/{{MAX_TOKENS}})
**Files Modified:** {{FILES_COUNT}} files
**Tests Passing:** {{TESTS_PASSING}}

{{FILES_MODIFIED_LIST}}

---

## Next Steps

**To Resume:**

1. Start fresh session (resets context)
2. Run: `/rptc:feat "@{{PLAN_NAME}}/"`
3. System will detect handoff.md and continue with Step {{NEXT_STEP_NUM}}

**What Happens on Resume:**
- Loads overview.md + previous steps summary (concise)
- Skips to Step {{NEXT_STEP_NUM}} execution
- Maintains full context awareness

---

_Auto-generated at {{TIMESTAMP}}_
