---
name: frontend-design
description: Aesthetic direction for new user-facing UI or explicit redesign and polish requests. Not for bug fixes or small edits inside an existing design system.
---

# Frontend Design

Give an interface a point of view that belongs to its subject, then execute it
with discipline. Generic design comes from deferred decisions, not from a lack
of decoration.

## Scope

- New UI, or a request to redesign or polish: set a clear aesthetic direction.
- Changes inside an existing product: extend its tokens, components, and
  patterns. Match what is there; a new direction is not wanted.
- A brief or design system that pins down a look: follow it exactly, even when
  the look is one of the common defaults listed below.

Existing design systems take priority. Read the project's CSS variables,
component library, and brand guidelines before proposing anything.

## Before writing code

1. **What is this for?** The subject, the audience, and the screen's primary
   job. If the brief does not say, propose an answer and confirm it.
2. **What is the tone?** Take it from the subject's own world: its materials,
   vocabulary, and the people who use it. A tool for kids and a tool for
   bond traders should not look alike.
3. **What are the constraints?** Framework, existing design system, browser
   support, performance budget.
4. **What is the one memorable detail?** Name the single thing a person would
   describe to someone else afterward: an interaction, a layout move, a type
   treatment, a color decision.

Intentionality matters more than intensity. A quiet design with precise
choices is as distinctive as a loud one.

## Plan, check, build, critique

1. **Plan** a compact token system:
   - palette: a few named colors with roles;
   - type: one or two families, their roles, and a scale;
   - layout: the structure and alignment, sketched in a sentence or an ASCII
     wireframe;
   - principles: two or three rules that make this design specific.
2. **Check the plan against the brief.** For each choice, ask whether you would
   have made it for any similar page. If so, it is a default; replace it with a
   choice drawn from the subject, and say what changed.
3. **Build** with the project's stack. Put tokens in CSS custom properties or
   the existing theme, and keep selector specificity flat so section and
   component rules do not fight each other.
4. **Critique in a browser.** Look at the rendered page, take screenshots when
   the environment allows, and fix what you see. Check whether the memorable
   detail comes through and whether anything around it is competing. Remove one
   decoration before calling it done.

## Restraint

Pick one place to be bold and let the rest of the page stay calm around it.
If a decoration says nothing about the subject or helps no reader, remove it.

- **Typography** carries most of the personality. Pick faces for this subject
  rather than the ones you would use anywhere. One family is often enough; if
  you use two, make the contrast obvious. Keep body text to a comfortable
  measure.
- **Structure is information.** Borders, numbers, labels, and dividers should
  encode something about the content. Number items only when they are a real
  sequence.
- **Motion** earns its place by pointing somewhere. A single designed moment,
  such as how the page first appears, does more than effects on every element.
  Animate in response to a user's action when it clarifies the result.

## Current generic-AI tells

These are defaults that show up regardless of subject. Each can be right for a
specific brief; use one only when the brief calls for it.

- A warm off-white page with a heavy serif headline and a rust or clay accent
  color.
- A black page lit by one neon accent color.
- Content split into matching rounded cards, all with one soft shadow and one
  corner radius, with gradients added for decoration.
- A small spaced-out uppercase label sitting over each section heading.
- A hero built around one oversized metric, whatever the product does.
- A headline with a single word singled out by weight, slant, or color.
- A fade-and-slide-up entrance on every section and a hover lift on every card.

The test: swap the logo and copy for another product's. If nobody could tell,
the design has no point of view.

## Interface copy

Words in an interface help people understand and act. Name things the way
users think of them, not by system internals. Use plain verbs and sentence
case. Buttons say what happens ("Send invoice"), and an action is called the
same thing on the button, in the confirmation, and anywhere else it appears.
Errors say what happened and how to fix it, without apology or vagueness. Empty states tell the person what to do next.

## Engineering floor

Meet these without announcing them:

- WCAG 2.2 AA: text and UI contrast, full keyboard access, visible focus that
  other content does not obscure, and pointer targets of at least 24 by 24 CSS
  pixels.
- Honor `prefers-reduced-motion`.
- Do not regress LCP, INP, or CLS; load fonts and images so layout does not
  shift.
- Design loading, empty, and error states, not only the happy path.
- Check the result at narrow and wide viewport widths.
