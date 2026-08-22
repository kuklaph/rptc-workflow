---
name: brainstorming
description: Resolve genuine product intent, requirements, and design choices through focused dialogue. Use when the repository and runtime cannot answer a consequential question. Skip discoverable facts and reversible implementation details.
---

# Brainstorming

## Before asking

Classify the uncertainty:

- **Fact:** inspect code, documentation, history, or runtime.
- **Experiment:** build or run the smallest probe that can answer it.
- **Product or preference decision:** ask the user.

Do not make the user answer a question the environment can resolve.

## Dialogue

Ask one decision at a time. Lead with a recommendation when evidence supports
one. Offer alternatives only when they are materially different and viable.

Capture:

- intended user outcome;
- constraints;
- acceptance predicates;
- explicit exclusions;
- consequential trade-offs.

Stop when the implementation can proceed without guessing product intent. Do
not turn a localized change into an interview ceremony.

Provider adapters choose the available question and planning tools.
