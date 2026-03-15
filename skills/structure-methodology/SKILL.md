---
name: structure-methodology
description: Codebase structure analysis and design guidance for AI-ready projects. Applies deep module principles (Ousterhout) to evaluate module depth, interface quality, progressive disclosure, and testability. Two modes - Assessment (analyze existing structure, detect shallow module webs, score AI navigability) and Design Guidance (plan module boundaries, interface-first design during architecture phases). Use when evaluating project structure, reorganizing a codebase, planning feature boundaries, reviewing architecture, or when the user mentions "structure", "organize code", "restructure", "module boundaries", or "codebase layout".
---

# Project Structure

Structural analysis and design guidance for AI-ready codebases. Based on deep module principles from John Ousterhout's *A Philosophy of Software Design*, adapted for AI-assisted development.

**Core insight**: AI agents are perpetual new starters — no memory, no mental map. Your codebase structure is the single biggest influence on AI output quality. Well-structured modules with simple interfaces make codebases navigable for both humans and AI.

---

## When to Use

| Context | Mode | What You Get |
|---------|------|-------------|
| "Is this project structured well?" | Assessment | Module depth analysis, anti-pattern report |
| "How should I structure this feature?" | Design Guidance | Module boundary recommendations |
| During `/rptc:feat` Phase 2 (planning) | Design Guidance | Interface-first module design |
| Code review / refactoring | Assessment | Shallow module web detection |
| New project setup | Design Guidance | Initial module architecture |

---

## Core Concepts

### Deep vs. Shallow Modules

**Deep module**: Large implementation behind a simple interface. Lots of functionality accessible through a small, well-defined API. The interface hides complexity — consumers don't need to understand internals.

**Shallow module**: Minimal implementation with a complex or wide interface. The interface doesn't hide much — you end up needing to understand the internals anyway.

```
Deep Module (good):          Shallow Module (bad):

┌─────────────┐              ┌─────────────────────────────────┐
│  Interface  │ (small)      │         Interface               │ (wide)
├─────────────┤              ├─────────────────────────────────┤
│             │              │  implementation  │ (thin)
│             │              └─────────────────────────────────┘
│ Implementa- │
│    tion     │ (deep)
│             │
│             │
└─────────────┘
```

**Why it matters for AI**: A deep module can be understood from its interface alone. An AI agent reads the types, understands the contract, and moves on — no need to read 15 files to grasp what a feature does.

### Progressive Disclosure of Complexity

Structure code so AI (and humans) can understand what a module does without reading its internals:

1. **Level 0 — File system**: Directory names and structure reveal module boundaries
2. **Level 1 — Interface**: Exported types/functions explain capabilities
3. **Level 2 — Implementation**: Internal code, only explored when modifying behavior

AI agents should stop at Level 1 for most modules and only descend to Level 2 for the module they're changing. This saves tokens, reduces confusion, and prevents the AI from getting lost in implementation details of unrelated code.

### Graybox Modules

Tests lock down module behavior at the interface boundary. The internals become a "gray box" — you *can* look inside, but you don't *need* to unless you're modifying behavior.

This creates a natural delegation boundary:

- **Humans** design interfaces, set module boundaries, apply architectural taste
- **AI** implements internals, writes tests against interfaces, refactors within boundaries

---

## Mode A: Assessment

Analyze an existing codebase or directory for structural health. Use this when you want to understand how AI-navigable the current code is and where the biggest structural improvements would come from.

### Assessment Checklist

Run through these checks in order:

#### 1. Module Depth Analysis

- [ ] **Count modules per feature area**: How many files/classes contribute to each logical feature?
- [ ] **Measure interface width**: How many exports does each module expose?
- [ ] **Check depth ratio**: Implementation lines vs. interface surface area

**Signals of shallow modules**:

- Feature spread across 10+ files with no clear entry point
- Most files export 1-2 small functions
- Consumers import from many different files to use one feature
- Understanding one feature requires reading many files

**Signals of deep modules**:

- Feature has a clear entry point (index file, facade, service class)
- Entry point exports a focused API (3-7 public functions/methods)
- Consumers import from one place
- Feature can be understood from its interface alone

#### 2. Interface Quality

- [ ] **Entry points exist**: Each feature area has a single, obvious entry point
- [ ] **Types tell the story**: Exported types/interfaces describe capabilities without exposing internals
- [ ] **No leaky abstractions**: Internal types, helpers, and implementation details aren't exported
- [ ] **Stable contracts**: Interface changes are rare compared to implementation changes

#### 3. Progressive Disclosure

- [ ] **Directory structure matches mental model**: Browsing the file tree reveals feature boundaries
- [ ] **Index files at boundaries**: Top-level modules have barrel files or documentation explaining purpose
- [ ] **Internal directories clearly marked**: `internal/`, `lib/`, `impl/`, or similar conventions separate public from private

#### 4. Testability at Boundaries

- [ ] **Tests target interfaces, not internals**: Most tests call public APIs, not internal helpers
- [ ] **Module behavior testable in isolation**: Can swap implementations without changing tests
- [ ] **Test files mirror module boundaries**: Test organization reflects module structure

#### 5. AI Navigability

- [ ] **Feature discovery in ≤3 steps**: AI finds the right module by: browse directory → read index → find interface
- [ ] **Import graph has clear hierarchy**: Modules import downward, not from random siblings
- [ ] **No circular dependencies**: Module A doesn't import from B while B imports from A

### Anti-Patterns

| Anti-Pattern | What It Looks Like | Why It Hurts AI |
|--------------|--------------------|-----------------|
| **Shallow module web** | 50+ tiny files all importing from each other | AI can't determine which files matter for a task |
| **God module** | One file/class with 1000+ lines doing everything | AI changes conflict with too many concerns |
| **Leaky abstraction** | Internal types exported, consumers coupled to internals | AI changes to internals break unexpected consumers |
| **Feature scatter** | Auth logic in 15 directories | AI misses pieces when modifying the feature |
| **Missing entry point** | No index/barrel file, consumers import from deep paths | AI guesses import sources (often wrong) |
| **Test-implementation coupling** | Tests mock every internal function | AI can't refactor internals without breaking all tests |

### Assessment Output

```markdown
## Project Structure Assessment: [directory/project]

### Module Map
[Identified modules with depth classification: deep / adequate / shallow]

### Key Findings
1. [Finding with evidence — severity: critical / moderate / minor]

### Structural Hotspots
[Specific areas where module web is most tangled]

### Recommendations
[Ordered by impact — highest first]

### Structure Score
- File system navigability: [1-5]
- Interface clarity: [1-5]
- Implementation hiding: [1-5]
- Test boundary alignment: [1-5]
- Overall AI readiness: [1-5]
```

---

## Mode B: Design Guidance

Guide module boundary decisions during planning or new feature development. Use this when you need to decide how to structure a feature, where to draw module boundaries, or how to design interfaces that AI can work with effectively.

### Module Boundary Decision Framework

#### Step 1: Identify the Responsibility

What does this module *do* from a consumer's perspective? Write it in one sentence. If you need "and" more than once, you likely have multiple modules.

#### Step 2: Define the Interface First

Before writing implementation, define:

- What types/functions will consumers use?
- What information must consumers provide?
- What do they get back?

Start with the minimum viable API. Expand only when consumers actually need more — not when you imagine they might.

#### Step 3: Check the Depth

Ask three questions:

1. **Does this module hide meaningful complexity?** If not, it may be too shallow — consider merging with a related module.
2. **Can the interface stay stable while the implementation changes?** If not, the abstraction boundary is in the wrong place.
3. **Could an AI implement the internals given only the interface and tests?** If not, the interface may be leaking implementation details.

#### Step 4: Plan the File Structure

```
feature-name/
├── index.ts (or __init__.py, mod.rs, etc.)  ← Interface: exports only public API
├── types.ts                                  ← Public types consumers need
├── internal/                                 ← Implementation details
│   ├── helpers.ts
│   ├── transformers.ts
│   └── ...
└── __tests__/                                ← Tests against the interface
    ├── feature-name.test.ts
    └── ...
```

The key point: `internal/` is for implementation. Everything a consumer needs comes from `index` and `types`. Tests verify behavior through the public interface, not by reaching into internals.

#### Step 5: Validate the Design

- [ ] Consumer uses this module by importing from one place
- [ ] Interface fits in ~30 lines of type declarations
- [ ] Internal structure can change without breaking consumers
- [ ] Tests describe *what* the module does, not *how*
- [ ] AI agent can navigate to this module, read the interface, and understand its purpose quickly

### Integration with RPTC Planning

During `/rptc:feat` Phase 2 (Architecture), consider these questions:

1. **Which existing modules does this feature touch?** Prefer extending existing module interfaces over creating new modules
2. **Does this feature warrant a new module?** Only if it introduces a genuinely new responsibility
3. **What's the interface?** Define before implementation steps
4. **Where do tests go?** At the module boundary, testing the interface

---

## Inline Behavior (When Loaded by Agents)

When this skill is loaded by the architect-agent or code-review-agent during `/rptc:feat` or `/rptc:verify`, it operates in **preventive mode**:

- **Apply structure principles to newly designed modules only.** Do not expand scope to restructure existing code unless it directly blocks the feature.
- Design new features with clean interfaces, proper module boundaries, and tests at the right level.
- If existing structure is messy but workable, note it as an observation — not a blocker, not a scope expansion.
- If existing structure actively prevents clean implementation, suggest the user run `/rptc:structure` as a separate step.

The goal is incremental improvement: each new feature is well-structured, and over time the codebase gets better through normal development. Wholesale restructuring is the job of `/rptc:structure`, not inline planning.

---

## Relationship to Other RPTC Principles

This skill complements existing guidance — it adds the structural navigability lens that function-level principles don't cover.

| Principle | Source | Project Structure Adds |
|-----------|--------|------------------------|
| KISS / YAGNI | `core-principles` | Are modules appropriately *deep*, not just simple? |
| Over-engineering detection | `code-review-methodology` | Is the codebase a shallow module web? |
| Module boundary planning | `architect-methodology` | Interface-first design: define contract before plan |
| Surgical coding | `core-principles` | Can AI find what it needs in ≤3 steps? |

**Key distinction**: Core principles say "keep it simple." Project structure says "keep it *navigable*." A codebase can follow KISS at the function level and still be a tangled web of shallow modules at the structural level.

---

## Source Material

**Primary source**: John Ousterhout, *A Philosophy of Software Design* (2018, 2nd edition 2021)

**Applied context**: Matt Pocock, "Your codebase is NOT ready for AI" (2026) — applies deep module concepts to AI-assisted development:

- AI agents operate like perpetual new starters (no memory, no context)
- Codebase structure matters more than prompts for AI output quality
- Well-structured modules with graybox testing create natural human/AI delegation boundaries
- Progressive disclosure reduces AI confusion and human cognitive burnout
- 20 years of software quality practices are more relevant than ever
