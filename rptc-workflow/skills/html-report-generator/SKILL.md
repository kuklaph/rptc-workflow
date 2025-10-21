---
name: HTML Report Generator
description: Generates professional HTML reports from markdown with dark theme styling. Use when user requests HTML output, converting research/documentation to HTML, or mentions "HTML report", "dark mode", or "web page". Creates standalone HTML files with responsive design, TOC, and syntax highlighting.
version: 1.0.0
---

# HTML Report Generator Skill

## Purpose

Provides comprehensive instructions and best practices for generating professional, dark-themed HTML reports from markdown research documents. This Skill ensures consistent, high-quality HTML output with industry-standard dark mode styling.

## When to Use This Skill

Use this Skill when:
- User requests HTML output from research
- Converting markdown documentation to HTML
- Creating shareable research reports
- User mentions "HTML", "report", "dark mode", "web page"
- Generating documentation that needs professional presentation
- Creating stakeholder-ready research artifacts

## Quick Start

When generating an HTML report from markdown:

1. Read the source markdown file
2. Follow the HTML structure pattern (see Templates section)
3. Apply industry-standard dark theme colors (see reference/dark-theme.css)
4. Include all required features (TOC, syntax highlighting, responsive design)
5. Save as `.html` file

## Core Requirements

### 1. Industry-Standard Dark Theme (Default)

Use GitHub Dark color palette (WCAG AA compliant). See `reference/dark-theme.css` for complete implementation.

**Primary colors:** `#0d1117` (background), `#e6edf3` (text), `#58a6ff` (accent)

### 2. Responsive Design

**Breakpoints:**
```css
/* Desktop (default) */
@media (min-width: 1024px) { /* Sidebar TOC layout */ }

/* Tablet */
@media (max-width: 1023px) and (min-width: 641px) { /* Collapsible sidebar */ }

/* Mobile */
@media (max-width: 640px) { /* Full-width, hamburger menu */ }
```

**Layout:**
- Desktop: Sidebar TOC (fixed) + main content
- Tablet: Collapsible sidebar or top navigation
- Mobile: Hamburger menu, full-width content

### 3. Required Features

**Navigation:**
- ✅ Table of contents (auto-generated from headings)
- ✅ Smooth scrolling to sections
- ✅ Active section highlighting in TOC
- ✅ Back to top button (appears on scroll)
- ✅ Reading progress indicator

**Typography:**
- ✅ Proper heading hierarchy (h1 → h6)
- ✅ Readable font sizes (16px base minimum)
- ✅ Adequate line height (1.6-1.8 for body text)
- ✅ Monospace font for code (`'Consolas', 'Monaco', monospace`)
- ✅ Sans-serif for body (`-apple-system, BlinkMacSystemFont, 'Segoe UI'`)

**Code Blocks:**
- ✅ Syntax highlighting (use Prism.js CDN)
- ✅ Language labels (show language in top-right corner)
- ✅ Proper indentation preservation
- ✅ Horizontal scroll for long lines (don't wrap)
- ✅ Dark theme for code (--code-bg background)

**Tables:**
- ✅ Styled headers (--bg-secondary background)
- ✅ Striped rows (alternating backgrounds)
- ✅ Hover effects (--bg-tertiary on hover)
- ✅ Responsive (horizontal scroll on mobile)

**Metadata:**
- ✅ Display date, status, research mode at top
- ✅ Use badges/pills for status indicators
- ✅ Color-code metadata (success, warning, info colors)

## Markdown Conversion

Convert markdown to semantic HTML5 elements:
- Headings with IDs (lowercase, hyphenated from heading text)
- Code blocks with `class="language-*"` for Prism.js syntax highlighting
- Tables with proper `<thead>` and `<tbody>` structure
- External links with `target="_blank" rel="noopener noreferrer"`

Complete implementation in `templates/report-structure.html`.

## Special Formatting for Research Reports

### Metadata Badges

```html
<span class="badge badge-info">Research Mode: Exploration</span>
<span class="badge badge-success">Status: Complete</span>
<span class="badge badge-warning">Version: 1.2.0</span>
```

**Badge styles:**
- `badge-info`: --info color (blue)
- `badge-success`: --success color (green)
- `badge-warning`: --warning color (yellow)
- `badge-error`: --error color (red)

### Callout Boxes

```html
<div class="callout callout-info">
    <strong>Key Finding:</strong> Skills use progressive disclosure...
</div>
```

**Callout types:** info, success, warning, error

### Comparison Tables

Add visual indicators:
- ✅ (green) for "Yes", "Good", "Pros"
- ❌ (red) for "No", "Bad", "Cons"
- ⚠️ (yellow) for "Maybe", "Caution"

### Source Citations

```html
<div class="citation">
    <strong>Source:</strong> Anthropic Engineering Blog<br>
    <strong>Confidence:</strong> High (5+ sources)
</div>
```

## Templates and Reference

- **Complete example:** `templates/report-structure.html` - Full implementation with embedded CSS/JS
- **Dark theme CSS:** `reference/dark-theme.css` - GitHub Dark color palette and styling

## Validation Checklist

After generating HTML report:

- [ ] HTML syntax valid (no unclosed tags)
- [ ] All headings have unique IDs
- [ ] TOC links match heading IDs
- [ ] Code blocks have language classes
- [ ] Tables have proper structure (thead, tbody)
- [ ] Responsive design works (test 320px, 768px, 1440px)
- [ ] Dark theme colors applied correctly
- [ ] Syntax highlighting loads (Prism.js CDN)
- [ ] Interactive features work (smooth scroll, back to top, progress bar)
- [ ] Print styles applied (@media print)
- [ ] Accessibility: ARIA labels, semantic HTML, keyboard nav

## Example Usage

**User request:**
> "Create an HTML report from my research document with dark theme"

**Your steps:**
1. Read source markdown file
2. Reference this Skill (HTML Report Generator)
3. Follow HTML structure template from `templates/report-structure.html`
4. Apply GitHub Dark color palette from `reference/dark-theme.css`
5. Convert markdown content to HTML:
   - Headings with IDs
   - Code blocks with syntax highlighting
   - Tables with styling
   - Lists (unordered, ordered, task lists)
   - Links, emphasis, blockquotes
6. Generate table of contents from headings
7. Add interactive JavaScript:
   - Reading progress bar
   - Mobile menu toggle
   - Smooth scrolling
   - Back to top button
   - Active section highlighting
8. Embed all CSS and JS (single standalone file)
9. Save as `.html` file
10. Confirm creation and features included

---

**Skill Version:** 1.0.0
**Last Updated:** 2025-10-19
**Compatibility:** Claude Code, Claude.ai, API