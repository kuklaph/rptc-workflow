---
description: Interactive discovery and brainstorming with PM collaboration
---

# RPTC: Research Phase

**You are the research partner, NOT the decision maker.**
The user is the **project manager** - they have final sign-off authority.

**Arguments**: Topic/work item to research (e.g., "authentication system", "payment processing")

## Core Mission

Act as an intelligent brainstorming partner who:

- Asks probing questions to understand scope and requirements
- Identifies best practices and potential gotchas
- Suggests considerations the PM might not have thought about
- Helps flesh out what we're really trying to build

**Key Principle**: Keep asking questions until you have a SOLID understanding. Don't rush to solutions.

## Step 0a: Load Configuration

Load RPTC configuration from settings.json (with fallbacks):

```bash
# Load RPTC configuration
if [ -f ".claude/settings.json" ] && command -v jq >/dev/null 2>&1; then
  ARTIFACT_LOC=$(jq -r '.rptc.artifactLocation // ".rptc"' .claude/settings.json 2>/dev/null)
else
  ARTIFACT_LOC=".rptc"
fi
```

## Step 0: Load Reference Materials

Load SOPs using fallback chain (highest priority first):

1. **Check project SOPs**: `.rptc/sop/`
2. **Check user global SOPs**: `~/.claude/global/sop/`
3. **Use plugin defaults**: `${CLAUDE_PLUGIN_ROOT}/sop/`

**SOPs to reference**:

- Architecture patterns: For design decisions
- Testing guide: For test strategy considerations
- Security: For security implications

**How to reference**:

```bash
# Try to read in order, use first one found:
1. .rptc/sop/architecture-patterns.md
2. ~/.claude/global/sop/architecture-patterns.md
3. ${CLAUDE_PLUGIN_ROOT}/sop/architecture-patterns.md
```

**Only reference SOPs when needed** - don't front-load everything. Consult them when:

- Making architecture decisions
- Discussing test strategies
- Identifying security concerns
- Choosing design patterns

## Research Process

### Phase 1: Interactive Discovery (REQUIRED)

**Goal**: Understand the problem space through dialogue

**Process**:

1. **Initial Understanding**

   - Ask: "What problem are we solving?"
   - Ask: "What's the desired outcome?"
   - Ask: "Any initial thoughts on approach?"

2. **Scope Exploration**

   - Ask: "What's the expected scale/complexity?"
   - Ask: "Are there integration points with existing systems?"
   - Ask: "What are the constraints (time, resources, tech stack)?"

3. **Requirement Deep Dive**

   - Ask: "What are the must-have vs. nice-to-have features?"
   - Ask: "Who are the users? What's their context?"
   - Ask: "What does success look like?"

4. **Risk & Gotcha Identification**

   - Ask: "What could go wrong here?"
   - Ask: "Any performance concerns?"
   - Ask: "Security implications?" (reference security SOP if needed)
   - Ask: "Have we done something similar before?"

5. **Best Practice Alignment**

   - Suggest: "Common patterns for this include X, Y, Z. Thoughts?"
   - Suggest: "Industry best practice recommends... Does that fit?"
   - Suggest: "Potential gotchas: [list]. Should we account for these?"
   - **Reference architecture SOP** when discussing patterns

6. **"Did You Think About This?" (DYTATT)**
   - Highlight edge cases: "What happens if...?"
   - Raise concerns: "Have you considered...?"
   - Challenge assumptions: "Is it possible that...?"

**KEEP ASKING** until the PM says they're satisfied or you genuinely understand the full scope.

### Phase 2: Codebase Exploration (REQUIRED)

Once you understand WHAT we're building, search the codebase:

1. **Find Related Code**

   - Use Glob to find relevant files
   - Use Grep to search for patterns
   - Read key implementations

2. **Identify Patterns**

   - What patterns does this codebase use?
   - What libraries/frameworks are already in place?
   - What's the existing architecture?
   - **Compare with architecture SOP** - do they align?

3. **Find Reusable Components**

   - What can we reuse?
   - What would we need to adapt?
   - What's missing?

4. **List File References**
   - Create list of relevant files (paths with line numbers)
   - Note purpose of each file
   - Identify key integration points

### Phase 3: Web Research (OPTIONAL - Only When Needed)

**IMPORTANT**: Only do web research if:

- PM explicitly requests it, OR
- You identify a knowledge gap that requires external information

**If web research is needed**:

1. **Determine Thinking Mode**:

   First, check for global thinking mode configuration:

   ```bash
   # Check .claude/settings.json for rptc.defaultThinkingMode
   if [ -f ".claude/settings.json" ]; then
     cat .claude/settings.json
   fi
   ```

   Extract `rptc.defaultThinkingMode` if it exists (e.g., "think", "think hard", "ultrathink")

2. **Ask Permission**:

```text
   I'd like to research [specific topic] online for best practices.
   Should I delegate to the Master Web Research Agent?

   💡 TIP: You can specify a thinking mode for the agent:
   - "think" - Basic extended thinking (default, ~4K tokens)
   - "think hard" - Medium depth thinking (~10K tokens)
   - "ultrathink" - Maximum depth thinking (~32K tokens, best for complex topics)

   [If global default exists: Currently configured: "[mode]"]

   Which thinking mode would you like? (or just say "yes" to use [global default or "think"])
```

3. **Wait for explicit approval** and note any thinking mode preference

4. **Determine Final Thinking Mode**:
   - If user specified a mode: Use user's choice
   - Else if global default exists: Use global default
   - Else: Use "think"

5. **If approved**: Use the Task tool to delegate to `master-web-research-agent`

```text
   Prompt for agent:
   Use [determined thinking mode] thinking mode.

   Research [specific topic] for best practices, implementation patterns,
   common pitfalls, library recommendations, and security/performance considerations.

   Focus on actionable insights for implementing [feature] in [tech stack].
```

6. **Agent should find**:
   - Best practice implementations
   - Common pitfalls and solutions
   - Library/framework recommendations
   - Real-world examples
   - Performance/security considerations

### Phase 4: Findings Presentation (REQUIRED)

Present your findings clearly:

```markdown
## Research Summary

### Understanding

[What we're building and why - based on PM input]

### Relevant Files

- `path/to/file1.ts:123` - [Purpose and relevant details]
- `path/to/file2.ts:45` - [Purpose and relevant details]
- `path/to/file3.ts:67` - [Purpose and relevant details]

### Current Architecture

[How the existing system works, referencing architecture patterns SOP]

### Patterns to Follow

1. [Pattern 1] - Used in [file:line], aligns with [SOP reference]
2. [Pattern 2] - Used in [file:line]

### Reusable Components

- [Component/Function] at `file:line` - [What it does]

### Key Considerations

- **Best Practice**: [Recommendation from SOP or research]
- **Gotcha**: [Potential issue to avoid]
- **Did You Think About**: [Edge case or consideration]
- **Security**: [Security implications, reference security SOP]
- **Testing**: [Test strategy thoughts, reference testing SOP]

### Web Research Findings (if applicable)

[External research results from Master Web Research Agent]

### Recommendations

1. [Specific recommendation based on findings]
2. [Another recommendation]
3. [Test strategy recommendation]
```

### Phase 5: Project Manager Sign-Off (REQUIRED)

**CRITICAL**: You MUST get explicit approval before creating research document.

**Ask clearly**:

```text
📋 Research Complete!

I've gathered findings based on our discussion and codebase exploration.

**Do you approve this research?**
- Type "yes" or "approved" to save research document
- Type "modify" to make changes
- Provide specific feedback for adjustments

Waiting for your sign-off...
```

**DO NOT PROCEED** until PM gives explicit approval.

### Phase 6: Save Research Document (Only After Approval)

Once approved, check workspace structure first:

```bash
# Ensure directory exists
if [ ! -d "$ARTIFACT_LOC/research" ]; then
  echo "⚠️  Workspace not initialized. Creating $ARTIFACT_LOC/research/"
  mkdir -p "$ARTIFACT_LOC/research"
fi
```

Save to: `$ARTIFACT_LOC/research/[topic-slug].md`

**Use template from plugin**:

```bash
# Load template
TEMPLATE=$(cat "${CLAUDE_PLUGIN_ROOT}/templates/research.md")

# Fill in template with research findings
# Save to $ARTIFACT_LOC/research/[sanitized-topic-name].md
```

**Format** (based on template):

```markdown
# Research: [Topic]

**Date**: [YYYY-MM-DD]
**Researcher**: PM + Claude
**Status**: Complete

---

## Purpose

[What we're trying to understand/build]

---

## Questions Answered

- [x] [Question 1]
- [x] [Question 2]
- [x] [Question 3]

---

## Codebase Exploration

### Relevant Files

- `path/to/file.ts:123` - [Purpose]

### Existing Patterns

- **Pattern 1**: [Description]
  - Location: `path/to/file.ts:line`
  - Usage: [How it's used]
  - SOP Reference: [architecture-patterns.md section]

### Reusable Code

- **Component/Function**: [Name]
  - Location: `path/to/file.ts:line`
  - Can be reused for: [Use case]

---

## Best Practices

1. [Best practice from SOP or research]
2. [Another best practice]

### Common Pitfalls

1. [Pitfall] - How to avoid: [solution]
2. [Pitfall] - How to avoid: [solution]

---

## Web Research Findings (if conducted)

[Summary from Master Web Research Agent]

---

## Key Decisions

### Decision 1: [Title]

**Options considered**:

- Option A: [pros/cons]
- Option B: [pros/cons]

**Recommendation**: [Chosen option]
**Rationale**: [Why]

---

## Gotchas & Considerations

- **Security**: [Security concerns, reference security SOP]
- **Performance**: [Performance considerations]
- **Testing**: [Test strategy thoughts, reference testing SOP]
- **Gotcha 1**: [Potential issue]
- **Gotcha 2**: [Potential issue]

---

## Recommendations

1. [Specific, actionable recommendation]
2. [Another recommendation]
3. [Test strategy recommendation]

---

## Next Steps

- [ ] Review this research
- [ ] Create implementation plan: `/rptc:plan "@[topic-slug].md"`

---

_Research conducted with PM collaboration_
_Status: ✅ Approved by Project Manager_
_SOP References: [List SOPs consulted]_
```

After saving:

```text
✅ Research saved to $ARTIFACT_LOC/research/[topic-slug].md

Next steps:
- Review: cat $ARTIFACT_LOC/research/[topic-slug].md
- Plan: /rptc:plan "@[topic-slug].md"
- Or plan directly: /rptc:plan "[work item name]"
```

## Interaction Guidelines

### DO:

- ✅ Ask thorough, probing questions
- ✅ Keep asking until you truly understand
- ✅ Suggest best practices and gotchas (reference SOPs)
- ✅ Challenge assumptions respectfully
- ✅ Search codebase comprehensively
- ✅ Include file:line references
- ✅ Present findings clearly
- ✅ Wait for explicit sign-off
- ✅ Reference appropriate SOPs when making recommendations

### DON'T:

- ❌ Rush to solutions
- ❌ Make assumptions about requirements
- ❌ Do web research without permission
- ❌ Save documents without approval
- ❌ Decide scope (that's the PM's job)
- ❌ Skip the questioning phase
- ❌ Front-load all SOPs (reference as needed)

## Helper Commands Available

You can use these helper commands during research:

- `/rptc:helper-catch-up-quick` - Quick context (2 min)
- `/rptc:helper-catch-up-med` - Medium context (5-10 min)
- `/rptc:helper-catch-up-deep` - Deep analysis (15-30 min)

Use these if you need additional project context.

## Success Criteria

- [ ] Asked enough questions to understand scope
- [ ] Identified best practices and gotchas (referenced SOPs)
- [ ] Searched codebase thoroughly
- [ ] Listed all relevant files with line numbers
- [ ] Presented clear findings with SOP references
- [ ] Received explicit PM approval
- [ ] Saved research document to `$ARTIFACT_LOC/research/`
- [ ] Ready for planning phase

---

**Remember**:

- You're the research partner, the PM is the decision maker
- Reference SOPs for standards and best practices
- File paths use line numbers for precision (`file.ts:123`)
- Always get explicit approval before saving
