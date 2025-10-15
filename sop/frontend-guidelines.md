# Frontend Guidelines

## Design Philosophy

### Core Principles

- **User-Centered Design**: Prioritize user needs, goals, and context
- **Consistency Over Novelty**: Maintain cohesive brand experience
- **Progressive Disclosure**: Present information in layers, reveal complexity when needed
- **Accessibility First**: Design for all users from the start (WCAG 2.1 AA minimum)
- **Performance Matters**: Fast, responsive interfaces are part of good design

## Design System

### Colors

**Primary Palette**: Define brand colors with hex codes and usage contexts
**Semantic Colors**: Success (green), warning (yellow), error (red), info (blue)
**Neutrals**: 5-7 step gray scale for text, backgrounds, borders

```css
/* Brand */
--color-primary: #0066cc;
--color-primary-dark: #004c99;

/* Semantic */
--color-success: #10b981;
--color-error: #ef4444;

/* Neutrals */
--color-text-primary: #1f2937;
--color-background: #ffffff;
--color-border: #e5e7eb;
```

**Color Rules**:

- WCAG AA contrast ratios (4.5:1 for normal text, 3:1 for large)
- Never rely on color alone to convey information
- Document color tokens

### Typography

**Type Scale**: H1-H6, body, small, caption
**Font Families**: Primary (headings), secondary (body), monospace (code)

```css
/* Headings */
--font-size-h1: 2.5rem;
--font-size-h2: 2rem;
--font-size-h3: 1.5rem;
/* Body */
--font-size-base: 1rem;
--font-size-small: 0.875rem;
/* Weights */
--font-weight-normal: 400;
--font-weight-semibold: 600;
/* Line Heights */
--line-height-normal: 1.5;
--line-height-tight: 1.25;
```

**Typography Rules**:

- Max line length: 65-75 characters
- Line height: 1.5 for body, tighter for headings
- Consistent vertical rhythm

### Spacing and Layout

**Spacing Scale** (8px base):

```css
--space-1: 0.25rem; /* 4px */
--space-2: 0.5rem; /* 8px */
--space-4: 1rem; /* 16px */
--space-8: 2rem; /* 32px */
```

**Grid System**: 12-column responsive grid
**Containers**: SM (640px), MD (768px), LG (1024px), XL (1280px)

### Component Library

**Standard Components**: Buttons, inputs, cards, modals, navigation, alerts, tables, loading states

**Component States**: Default, hover, active, focus, disabled, loading, error

## Responsive Design

### Mobile-First Approach

Design for mobile first, then adapt for larger screens.

**Breakpoints**:

```css
/* Mobile: < 640px (default) */
@media (min-width: 640px) {
  /* SM: Tablets */
}
@media (min-width: 768px) {
  /* MD: Tablets landscape */
}
@media (min-width: 1024px) {
  /* LG: Desktops */
}
@media (min-width: 1280px) {
  /* XL: Large desktops */
}
```

**Responsive Patterns**:

- Fluid layouts (%, rem, em)
- Flexible images
- Min 44x44px touch targets on mobile
- Min 16px font size on mobile
- Stack vertically on mobile, horizontal on desktop

## Visual Hierarchy

**Techniques**:

- **Size**: Larger elements attract attention
- **Weight**: Bolder text stands out
- **Color**: High contrast draws focus
- **Position**: Top-left to bottom-right flow
- **Whitespace**: Isolation increases importance

**Data-Dense Interfaces**:

- Scannable layouts with clear sections
- Progressive disclosure (overview → details on demand)
- Filters and search
- Data visualization for digestibility
- Avoid clutter

## AI-Specific Design Patterns

### Visual Cues for AI Activity

**Distinguish AI Content**:

- Icon (sparkle, robot, AI badge)
- Subtle background color or border
- Explicit label: "AI-generated", "AI suggestion"

```html
<div class="ai-suggestion">
  <span class="ai-badge">
    <svg><!-- AI icon --></svg>
    AI Suggestion
  </span>
  <p>Based on your preferences...</p>
</div>
```

### Provisional States

Display AI content as **"provisional"** until user confirms:

- Dimmed opacity (0.7-0.8)
- Dashed outline
- "Draft" or "Pending" label
- Accept/Reject buttons

```html
<div class="provisional-content">
  <div class="provisional-label">Pending Review</div>
  <div class="content"><!-- AI-generated --></div>
  <div class="actions">
    <button>Accept</button>
    <button>Edit</button>
    <button>Reject</button>
  </div>
</div>
```

### Thinking Indicators

**Types**:

- Spinners: Quick operations (< 3 seconds)
- Progress bars: Known duration
- Skeleton screens: Loading content layouts
- Pulsing animations: Background processing
- Status text: "Analyzing...", "Generating..."

```css
.thinking-animation .dot {
  animation: pulse 1.4s infinite ease-in-out;
}
@keyframes pulse {
  0%,
  80%,
  100% {
    opacity: 0.3;
    transform: scale(0.8);
  }
  40% {
    opacity: 1;
    transform: scale(1);
  }
}
```

### Confidence Indicators

Display AI confidence when applicable:

- Percentage: "85% confident"
- Colored bar: Green (high), yellow (medium), red (low)
- Text: "High confidence", "Moderate", "Low"

```html
<div class="confidence-indicator">
  <div
    class="confidence-bar"
    style="width: 85%"></div>
</div>
<p class="confidence-text">85% confident</p>
```

### Explainability Elements

Provide concise explanations without cluttering:

- Tooltips: Hover for brief explanation
- Expandable sections: Click for detailed reasoning
- Info icons: "?" with explanation on click
- "Why?" links: Open explanation modal

### User Control Over AI

**Always provide**:

- **Undo/Redo**: Easy reversal
- **Edit Capabilities**: Modify AI content
- **Parameter Controls**: Sliders for creativity, verbosity, formality
- **Feedback**: Thumbs up/down, report incorrect
- **Opt-Out**: Disable AI features

## Accessibility (WCAG 2.1 AA)

**Critical Requirements**:

- Color contrast: 4.5:1 (normal text), 3:1 (large text, UI components)
- Keyboard navigation: All interactive elements accessible
- Focus indicators: Visible focus states
- Alt text: Meaningful descriptions for images
- ARIA labels: Screen reader support
- Semantic HTML: Use proper elements (button, nav, header)
- Form labels: Associated with inputs
- Skip links: Bypass navigation
- Error messages: Clear, actionable

**Testing**:

- Keyboard-only navigation
- Screen reader testing (NVDA, JAWS, VoiceOver)
- Automated tools (axe, Lighthouse)
- Color contrast checkers

## Performance

**Optimization**:

- Lazy loading: Images and components
- Code splitting: Route-based chunks
- Asset optimization: Minify, compress
- CDN: Static assets
- Caching: HTTP headers, service workers

**Metrics** (Core Web Vitals):

- LCP (Largest Contentful Paint): < 2.5s
- FID (First Input Delay): < 100ms
- CLS (Cumulative Layout Shift): < 0.1

**Tools**: Lighthouse, WebPageTest, Chrome DevTools

## Micro-interactions

**Purpose**: Visual feedback for user actions
**Types**: Hover effects, button presses, form submissions, state changes

**Guidelines**:

- Quick animations: 150-300ms
- Appropriate easing: ease-in-out
- Subtle, not distracting
- Consistent timing and style

```css
button {
  transition: background-color 200ms ease-in-out;
}
button:hover {
  background-color: var(--color-primary-dark);
}
```

## Forms and Input

**Best Practices**:

- Clear labels above inputs
- Placeholder text for examples (not labels)
- Inline validation (real-time feedback)
- Error messages: Specific, helpful
- Success states: Confirm completion
- Required field indicators: Asterisks or "(required)"
- Logical tab order
- Autocomplete attributes

## Loading States

**Strategies**:

- **Skeleton screens**: Content shape placeholders
- **Spinners**: Small, indeterminate operations
- **Progress bars**: Determinate operations with known duration
- **Optimistic UI**: Show expected result immediately, revert on error

**Guidelines**:

- Show loading states for operations > 200ms
- Provide context: "Loading users...", "Saving changes..."
- Disable actions during loading
- Allow cancellation for long operations

## Error Handling

**Types**:

- **Inline errors**: Field-level validation
- **Alert/banner errors**: Page-level issues
- **Toast/snackbar errors**: Temporary notifications
- **Modal errors**: Critical, requires acknowledgment

**Error Message Guidelines**:

- Clear, specific, actionable
- Plain language (no jargon)
- Suggest solutions
- Avoid blame ("invalid" not "you entered invalid")

## Empty States

**Purpose**: First use, no data, no results

**Elements**:

- Icon or illustration
- Clear heading: "No items yet"
- Brief explanation
- Primary action: "Add your first item"
- Optional: Help link or documentation

## Documentation

**Component Documentation**:

- Purpose and usage
- Props/parameters
- Variants and states
- Code examples
- Accessibility notes
- Do's and don'ts

## Project-Specific Guidelines

Document project-specific design decisions in `.context/design-decisions.md`:

- Brand colors and usage
- Custom components
- Accessibility requirements
- Design tool references (Figma, Sketch)
- Component library location
- Testing procedures
