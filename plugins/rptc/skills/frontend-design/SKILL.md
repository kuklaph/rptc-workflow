---
name: frontend-design
description: Distinctive, production-grade frontend interfaces. Use when the task involves creating or modifying HTML, CSS, UI components, web pages, or frontend interfaces. Trigger for any visual/styling work — landing pages, dashboards, forms, themes, layouts, component styling, redesigns, "make this look good/better/professional", or anything where visual quality matters. Provides creative direction and bold aesthetics that avoid generic AI-generated design. Complements frontend-guidelines.md SOP (engineering standards) with aesthetic intent.
---

# Frontend Design

Build interfaces that look intentionally designed, not AI-generated. This skill provides creative direction for frontend work — bold aesthetic choices, distinctive visual identity, and cohesive execution.

**Relationship with `frontend-guidelines.md` SOP**: The SOP covers engineering standards (accessibility, performance, responsive design, component patterns). This skill covers aesthetic intent (visual identity, typography choices, color personality, motion design). Both apply simultaneously — the SOP ensures the interface *works correctly*, this skill ensures it *looks distinctive*.

## When to Use This Skill

- Creating new pages, components, or layouts
- Styling or restyling existing interfaces
- Building landing pages, dashboards, forms, or any user-facing view
- User asks to "make this look good", "polish this", or "make it professional"
- Any task where visual quality and design identity matter

---

## Core Principle: Every Project Gets Its Own Identity

No two projects should converge on the same aesthetic. If the last dashboard used dark backgrounds with geometric accents, the next one should use warm tones with editorial typography — or dense monospace with industrial borders — or anything else that isn't a repeat. The goal is variety across projects and intentionality within each one.

---

## Before Writing Code

Every interface deserves a deliberate aesthetic direction. Answer these four questions before touching CSS:

1. **What is this for?** Who uses it, what problem does it solve, what emotion should it evoke?
2. **What is the visual tone?** Commit to a direction: stark minimalism, dense information design, warm editorial, raw brutalist, geometric precision, organic softness, retro analog, high-contrast drama, playful irreverence, quiet luxury. These are starting points — combine, invent, adapt.
3. **What are the constraints?** Framework, browser support, performance budget, accessibility requirements, existing design system.
4. **What is the one memorable detail?** Every interface needs one thing a person would remember and describe to someone else. A distinctive interaction, an unexpected layout choice, a signature color treatment, a typographic detail.

The key insight: intentionality matters more than intensity. A restrained minimal design executed with precision is just as distinctive as an elaborate maximalist one. What makes design generic is the absence of deliberate choices, not the absence of complexity.

**Existing design systems take priority.** If the project has CSS variables, a component library, or brand guidelines — research them first. The creative direction extends and polishes what exists. It never overrides or conflicts.

Then implement working code (HTML/CSS/JS, React, Vue, or whatever the project uses) that meets these bars:

- **Production-grade** — functional, not a mockup
- **Visually distinctive** — looks designed for this specific context
- **Aesthetically cohesive** — every element reflects the same point of view
- **Refined in detail** — spacing, color, type, and motion all feel considered

---

## Visual Identity

### Typography

Font choice is the highest-leverage aesthetic decision. The default system font stack communicates nothing.

**Principles:**
- **Choose fonts with character.** Serif, sans-serif, monospace, display — the family matters less than whether the choice feels intentional and fits the tone.
- **Pair deliberately.** A display face for headings paired with a contrasting body face creates hierarchy and visual interest. Contrast in weight, width, or classification (serif + sans, geometric + humanist).
- **Size with purpose.** Large headings create drama. Tight body text creates density. The scale should reflect the content's nature — a dashboard reads differently than a landing page.

**Avoid:** Defaulting to overused safe choices — system-ui, the framework's default sans-serif, or whichever geometric sans is popular this year. If every interface uses the same typeface, none of them have an identity. Rotate through serif, slab, monospace, humanist, display — the full range exists for a reason.

### Color

Color defines mood faster than any other element.

**Principles:**
- **Commit to a palette.** Define a dominant color, a secondary, and one or two accents. Use CSS custom properties for consistency.
- **Let one color dominate.** Evenly distributed palettes feel timid. A strong primary with sharp accents creates confidence.
- **Dark and light are both valid.** Choose based on context, not habit. Vary between projects.
- **Use color functionally.** Status colors (success, warning, error) should be distinct from brand colors. Semantic meaning must be unambiguous.

**Avoid:** Purple-on-white gradients, rainbow hero sections, and other patterns that have become visual shorthand for "AI made this."

### Spatial Composition

Layout communicates hierarchy before anyone reads a word.

**Principles:**
- **Break the expected grid.** Asymmetric layouts, overlapping elements, diagonal flow, elements that bleed to edges — these choices create visual energy.
- **Use negative space deliberately.** Generous whitespace signals confidence and luxury. Dense layouts signal information richness. Both work — the choice must be intentional.
- **Create depth.** Layered elements, shadows with personality (not generic `box-shadow`), z-axis relationships, transparency — flat layouts are easy but rarely memorable.

**Avoid:** Centering everything, uniform card grids with identical spacing, layouts that look like a wireframe someone forgot to design.

### Texture and Atmosphere

Solid flat backgrounds are a missed opportunity.

**Principles:**
- **Add visual texture.** Subtle noise overlays, gradient meshes, geometric patterns, grain effects — even at low opacity, texture adds warmth and depth.
- **Create atmosphere.** Background treatments, border details, decorative elements, custom cursors that reinforce the tone. An industrial interface might use hard borders and monospace everywhere. An organic one might use soft gradients and rounded shapes.
- **Layer transparencies.** Frosted glass, translucent overlays, and backdrop filters create sophisticated depth.

**Avoid:** Untreated flat backgrounds as the default. Pure black or white can work when the design is deliberately stark — but that's a choice, not a fallback. If the background has no texture, gradient, or depth, ask whether that's intentional.

### Motion and Interaction

Animation should feel purposeful, not decorative.

**Principles:**
- **Orchestrate entry.** A single well-choreographed page load — elements appearing in sequence with staggered delays — creates more impact than scattered micro-interactions.
- **Respond to the user.** Hover states, focus indicators, and click feedback should feel immediate and specific. A button that subtly shifts on hover communicates interactivity.
- **Use scroll as a trigger.** Elements that reveal on scroll, parallax layers, progress indicators — scroll is the primary interaction on most pages.
- **Prefer CSS.** `transition`, `animation`, `@keyframes`, and `scroll-timeline` handle most motion needs without JavaScript overhead. Use a motion library only when CSS falls short.

**Avoid:** Gratuitous bounce effects, animations that delay usability, motion that runs on every render.

---

## What Generic AI Design Looks Like

These patterns appear when aesthetic decisions are deferred rather than made. Avoid all of them:

- **Typography:** System font stacks, the same popular geometric sans-serif on every project, no font pairing, uniform sizing
- **Color:** Purple/blue gradients on white, pastel rainbow palettes, no dominant color, identical schemes across unrelated projects
- **Layout:** Everything centered, uniform card grids, symmetrical hero sections, predictable component stacking
- **Motion:** No animation at all, or identical fade-in on every element
- **Details:** No texture, no depth, no decorative elements, no personality

**The test:** If you swapped the logo and content with a different project and nobody could tell, the design lacks identity.

---

## Execution

Match implementation effort to the aesthetic vision:

- **Maximalist designs** need elaborate CSS — extensive custom properties, complex gradients, multiple animation sequences, layered pseudo-elements, detailed hover states. Use `@keyframes` liberally, stack pseudo-elements for depth, and define 20+ custom properties if the palette demands it. Cutting corners makes maximalism look unfinished.
- **Minimalist designs** need precision — perfect spacing, considered typography scales, subtle transitions, restrained color. Build a tight spacing scale (4/8/16/32/64px), limit the palette to 3-4 values, and make every `margin` and `padding` deliberate. Minimalism with sloppy spacing is just empty.
- **Information-dense designs** need systematic organization — consistent component patterns, clear data hierarchy, functional color coding, readable type at small sizes. Use CSS grid for structure, define semantic color tokens for status/category, and test readability at 12-14px.

**Always verify the result.** After implementation, view the page at full viewport. Check that the aesthetic direction comes through. Adjust until it does.

## Example: Generic vs. Distinctive

A generic card component — functional but forgettable:

```css
.card {
  background: #fff;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  font-family: system-ui, sans-serif;
}
```

The same card with aesthetic intent — editorial tone, depth, character:

```css
.card {
  background: linear-gradient(135deg, #faf8f5 0%, #f3ede6 100%);
  border-left: 3px solid #c4956a;
  padding: 2rem 1.75rem;
  box-shadow: 0 4px 24px rgba(120,90,60,0.08), 0 1px 2px rgba(120,90,60,0.04);
  font-family: 'Source Serif 4', 'Georgia', serif;
  letter-spacing: -0.01em;
  position: relative;
}
.card::before {
  content: '';
  position: absolute;
  inset: 0;
  background: url("data:image/svg+xml,...") repeat; /* subtle paper grain */
  opacity: 0.03;
  pointer-events: none;
}
```

The difference: specific colors with warmth, a signature border accent, layered shadows with tinted color (not generic gray), a serif with tracking, and a texture overlay for atmosphere. Every property reflects a decision.

---

Push creative boundaries. Extraordinary interfaces come from committing fully to a vision and executing it without hedging. Don't default to safe choices — the whole point of this skill is to produce work that feels genuinely designed, not generated.

**SOP Reference**: `${CLAUDE_PLUGIN_ROOT}/sop/frontend-guidelines.md` — accessibility (WCAG 2.1 AA), responsive breakpoints, performance metrics, component patterns, form design, error handling, loading states. These engineering standards apply to all frontend work regardless of aesthetic direction.
