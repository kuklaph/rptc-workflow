---
name: core-principles
description: Shared principles for RPTC agents. Loaded at session start by all agents. Contains Surgical Coding, Simplicity Directives, Pattern Reuse (Rule of Three), SOP references, and evidence-based rationale. Must be read before any work begins.
---

# Core Principles

These principles apply to ALL work performed by RPTC agents, regardless of specific task or context.

---

## Surgical Coding Approach

**Before making ANY changes, ALWAYS do this first**:

Think harder and thoroughly examine similar areas of the codebase to ensure your proposed approach fits seamlessly with the established patterns and architecture. Aim to make only minimal and necessary changes, avoiding any disruption to the existing design.

**Mandatory Pre-Implementation Steps**:

1. **Search for existing patterns**: Find 3 similar implementations already in this codebase
2. **Analyze pattern alignment**: How does the existing code solve similar problems?
3. **Propose minimal changes**: Can this be done by modifying ONE existing file instead of creating many new ones?

---

## Explicit Simplicity Directives

**MUST enforce in all implementations:**

- **Write the SIMPLEST possible solution** (not the most clever or flexible)
- **Prefer explicit over clever** (readable code beats concise code)
- **Avoid unnecessary abstractions** (no abstract base classes, factories, or interfaces until 3+ use cases exist)
- **Keep code under reasonable limits** (functions <50 lines, files <500 lines when possible)

**Reject approaches that**:

- Create abstractions for single use cases
- Add middleware/event-driven patterns for simple operations
- Use enterprise patterns in small projects
- Have >3 layers of indirection

---

## Pattern Reuse First (Rule of Three)

**NEVER abstract on first use**
**CONSIDER abstraction on second use** (only if patterns nearly identical)
**REFACTOR to abstraction on third use** (DRY principle applies)

**Before creating new code, verify**:

- [ ] Have I searched for similar patterns in this codebase? (find 3 examples)
- [ ] Can existing code be modified instead of creating new files?
- [ ] Is this abstraction justified by 3+ actual use cases (not speculative)?
- [ ] Would a junior developer understand this on first reading?

---

## Reference Enhanced SOPs

**MUST consult before proceeding**:

1. **`architecture-patterns.md`**
   - AI Over-Engineering Prevention section
   - Anti-pattern prohibition list (5 patterns to avoid)
   - Simplicity checkpoint questions

2. **`security-and-performance.md`**
   - AI Security Verification Checklist (7 blind spots)
   - BLOCKING checkpoint for security-critical code

3. **`testing-guide.md`**
   - TDD methodology
   - Test coverage requirements (80%+ critical paths)

4. **`writing-clearly-and-concisely` skill**
   - Apply Strunk's Elements of Style to prose
   - Clear, concise descriptions and rationales
   - Active voice, definite language, omit needless words

---

## Evidence-Based Rationale

**Research Findings**:

- **60-80% code reduction**: Surgical coding prompt + simplicity directives reduce generated code by more than half
- **8x duplication decrease**: Explicit guidance reduces duplication from 800% to baseline
- **322% vulnerability reduction**: Following security SOP prevents AI-introduced security gaps

**Why This Matters**:

- Less code = less maintenance burden
- Simpler architectures = easier debugging
- Pattern alignment = consistent codebase
- Security awareness = production-ready code

---

**NON-NEGOTIABLE**: These principles override convenience or speed. Always choose simplicity and security over rapid implementation.
