---
name: unslop-writing-clearly
description: Edit prose deliverables (documentation, reports, commit messages, PR descriptions, release notes, user-facing copy) to remove AI writing patterns while keeping the intended voice. Not for code-only work.
---

# Unslop and Write Clearly

## Process

1. Preserve meaning, audience, and the source's voice.
2. Fix substance first: replace generic claims with the fact, mechanism,
   example, or number. Surface tells usually mark vague content.
3. Remove the tells below.
4. Reread as the reader: "What makes this obviously machine-written?" Fix what
   remains.

## Tells current models still produce

- Contrast framing: "Not just X, but Y", "It's not X, it's Y", "This isn't about X. It's about Y.", "No X. No Y. Just Z.". State the point; name an alternative only if the reader raised it.
- Significance padding: "marking a pivotal moment", "reflects broader trends", "setting the stage for", "a testament to", trailing -ing clauses (highlighting, showcasing, emphasizing, ensuring, fostering). Cut, or state the specific consequence.
- Copula avoidance: "serves as", "stands as", "functions as", "boasts", "features", "offers" where "is" or "has" fits.
- Vague links and sources: "associated with", "in connection with", "experts say", "several sources". Name the relationship and the source.
- Stock words: delve, foster, leverage, crucial, pivotal, enhance, showcase, underscore, tapestry, landscape (abstract), vibrant, genuinely, importantly, "it's worth noting". Use the plain word.
- Mannered prose: metaphors and invented compound labels in place of the literal claim. Say it literally.
- Forced triplets: three items when the content has one, two, or four.
- Hooks and labeled conclusions: "The result? …", "Bottom line:", "In short:". State the point.
- Procedural narration: what you preserved, avoided, or left unchanged, and how you will organize the answer. Report what changed, including in commit messages and PR descriptions.
- Monotone sentences: uniform length, clauses chained with "and", few commas or parentheses. Vary length; split sentences that need rereading.
- Em dashes: current models, Claude especially, overuse them. Prefer a comma, colon, parentheses, or a new sentence.
- Formatting habits: bold-label bullets that restate the line, bold on every key term, tables or headings for content that is prose, title-case headings (use sentence case), decorative emoji. Use lists for parallel, sequential, or compared items.
- Chatbot register: "Great question", "You're absolutely right", "I hope this helps", "Let me know if", "Honest caveat:". Answer directly.
- Padding: filler sections, redundant summaries, generic closers, stacked caveats. Match length to the task.

## Integrity

- Never invent sources, quotations, identifiers, links, DOIs, or page numbers. A plausible citation is not a verified one.
- Mark quoted source text as quotation; paraphrase the rest.
- Do not fill gaps with speculation; find the source or say it is unknown.
- Present judgment as judgment; call something fact only when it is checkable.
- Remove template residue and tool artifacts (placeholders, citation markup, tracking parameters).

## Context

Match the artifact. Neutral documentation should stay neutral. A personal essay
may use first person and stronger voice. Technical writing should name the
mechanism rather than describe how it feels.
