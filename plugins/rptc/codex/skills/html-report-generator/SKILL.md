---
name: html-report-generator
description: Produce a saved report as one self-contained HTML file in a consistent house style. Use when the user asks for an HTML report or a saved report deliverable.
---

# HTML Report Generator

Use this when the user asks for an HTML report, a saved report, or conversion
of an existing report to a web page. Do not create reports unprompted; findings
otherwise belong in the conversation.

## Output

One `.html` file that opens directly in a browser: no build step, no external
assets (fonts, stylesheets, scripts, images from a CDN), and no JavaScript
required. It has:

- semantic headings with stable, unique `id`s;
- a table of contents when the report is long enough to need one;
- working source links;
- readable tables and code blocks that scroll horizontally on narrow screens;
- light and dark themes through `prefers-color-scheme`;
- a print-friendly layout.

## Procedure

1. Read the complete source material.
2. Copy `templates/report-structure.html` and keep its styles, so every report
   looks the same. Fill in content; do not restyle.
3. Replace the placeholder sections (summary, findings, evidence and sources,
   open questions, next steps). Drop a section that has no content rather than
   padding it.
4. Preserve the source's claims and citations. Do not add verification,
   testing, or status claims the source does not support.
5. Check that every table-of-contents link matches a heading `id`, and open or
   render the file when the environment allows.
6. Report the path and any check you did not perform.
