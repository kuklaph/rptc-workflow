---
name: html-report-generator
description: Generate an accessible self-contained HTML report when the user explicitly requests HTML output or conversion of an existing report to a web page.
---

# HTML Report Generator

## Outcome

Create one readable HTML file that preserves the source report's claims and
citations without inventing verification, testing, or status statements.

## Procedure

1. Read the complete source material.
2. Choose a semantic heading hierarchy and stable unique IDs.
3. Generate a self-contained document with embedded CSS and JavaScript.
4. Include a table of contents only when the document is long enough to need it.
5. Make tables horizontally scrollable and code blocks readable.
6. Support keyboard navigation, visible focus, reduced motion, print, and narrow
   screens.
7. Validate links between the table of contents and headings.
8. Open or render the file when the environment supports it.
9. Report the path and any validation not performed.

Do not load CDN scripts or fonts unless the user explicitly accepts network
dependencies. Do not claim browser, device, accessibility, or print testing
unless the current run actually performed it.

Use `templates/report-structure.html` as a starting point.
