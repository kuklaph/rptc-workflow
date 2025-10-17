# Phase Transition Blocking Pattern

**Purpose**: Prevent accidental step-skipping in RPTC workflow by adding explicit validation checkpoints at critical phase transitions.

**Created**: 2025-10-17
**Status**: Active Implementation Pattern

---

## Problem Statement

The RPTC workflow has 8 critical phase transitions where PM approval or validation is required before proceeding:

1. **Research → Save**: Must get PM sign-off on research findings
2. **Plan → Master Planner**: Must get PM approval to delegate to Master Feature Planner
3. **Plan → Save**: Must get final PM sign-off before saving plan
4. **TDD → Efficiency Agent**: Must get PM approval before quality gate review
5. **TDD → Security Agent**: Must get PM approval before security review
6. **TDD → Complete**: Must get final PM sign-off before marking TDD complete
7. **Commit → Execute**: Must verify all tests passing (non-negotiable)
8. **Commit → Execute**: Must verify code quality (non-negotiable)

**Risk**: Without explicit blocking checkpoints, Claude might skip these gates or proceed without proper validation.

---

## Solution: Imperative Blocking Checkpoints

### Pattern Structure

Each blocking checkpoint follows this structure:

```markdown
---

**CRITICAL VALIDATION CHECKPOINT - [CONSEQUENCE OF SKIPPING]**

Before [action being blocked]:

**TodoWrite Check**: "[specific todo item]" MUST be completed

**Verification**:
1. [Check 1] MUST be [condition]
2. [Check 2] MUST be [condition]
3. [Check 3] MUST be [condition]

❌ **[GATE TYPE] BLOCKED** - Cannot proceed to [next step] without [requirement]

**Required**: [What PM/system must do]

**ENFORCEMENT**: If [condition] has NOT [occurred]:
1. [Step 1]
2. [Step 2]
3. [Step 3]
4. [Step 4]
5. [Step 5]
6. NEVER [skip action] without explicit override

**Override Phrase** (optional): PM may say "[EXACT OVERRIDE PHRASE]"

**This is a NON-NEGOTIABLE gate. [Rationale for why this gate exists].**

---
```

### Key Elements

1. **Imperative Language**: MUST, NEVER, CANNOT, NON-NEGOTIABLE (not "should" or "consider")
2. **TodoWrite Integration**: References specific todo item that must be completed
3. **❌ BLOCKED Marker**: Visual indicator that progression is stopped
4. **ENFORCEMENT Section**: Numbered steps Claude must execute
5. **Override Phrase**: Exact phrase PM can use to bypass (where applicable)
6. **Rationale**: Explains WHY this gate exists

---

## Implementation Locations

### Checkpoint 1: Research - Block Save Without PM Approval

**File**: `commands/research.md`
**Lines**: 347-369
**Blocks**: Saving research findings
**TodoWrite Check**: "Get PM sign-off on research"

### Checkpoint 2: Plan - Block Master Planner Delegation

**File**: `commands/plan.md`
**Lines**: 469-491
**Blocks**: Delegating to Master Feature Planner
**TodoWrite Check**: "Get PM approval for Master Feature Planner delegation"

### Checkpoint 3: Plan - Block Plan Save

**File**: `commands/plan.md`
**Lines**: 877-900
**Blocks**: Saving plan document
**TodoWrite Check**: "Get final PM sign-off"

### Checkpoint 4: TDD - Block Efficiency Agent

**File**: `commands/tdd.md`
**Lines**: 377-406
**Blocks**: Executing Master Efficiency Agent
**TodoWrite Check**: "REQUEST PM: Efficiency Agent approval"
**Override**: "SKIP EFFICIENCY REVIEW - I ACCEPT THE RISKS"

### Checkpoint 5: TDD - Block Security Agent

**File**: `commands/tdd.md`
**Lines**: 562-590
**Blocks**: Executing Master Security Agent
**TodoWrite Check**: "REQUEST PM: Security Agent approval"
**Override**: "SKIP SECURITY REVIEW - I ACCEPT THE RISKS"

### Checkpoint 6: TDD - Block TDD Completion

**File**: `commands/tdd.md`
**Lines**: 761-787
**Blocks**: Marking TDD phase complete
**TodoWrite Check**: "REQUEST PM: Final TDD sign-off"

### Checkpoint 7: Commit - Block if Tests Failing

**File**: `commands/commit.md`
**Lines**: 147-179
**Blocks**: Committing with failing tests
**Verification**: All tests must pass (automated)

### Checkpoint 8: Commit - Block if Code Quality Issues

**File**: `commands/commit.md`
**Lines**: 220-287
**Blocks**: Committing with quality violations
**Verification**: No debug code, no .env files (automated)

---

## TodoWrite Integration Requirements

Each checkpoint references a specific TodoWrite task:

```json
{
  "content": "Get PM sign-off on research",
  "status": "pending",  // Must be "completed" to pass checkpoint
  "activeForm": "Getting PM approval"
}
```

**Validation Logic**:

1. Claude checks TodoWrite list for specific task
2. If task status is NOT "completed" → BLOCK
3. Display enforcement message
4. Wait for PM to complete task
5. Only proceed after task marked "completed"

---

## Testing and Validation

### Automated Verification Script

Location: `tests/verify-blocking-checkpoints.sh`

**What it checks**:

1. Each checkpoint exists at documented location
2. Uses imperative language (CRITICAL, MUST, NEVER, NON-NEGOTIABLE)
3. Has TodoWrite integration (references specific task)
4. Includes ❌ BLOCKED marker
5. Has ENFORCEMENT section

**Run validation**:

```bash
bash tests/verify-blocking-checkpoints.sh
```

**Expected output**:

```text
🔍 Verifying Phase Transition Blocking Checkpoints...

=== Checkpoint 1: Research - Block Save Without PM Approval ===
✅ PASS: Research Save Block - Checkpoint exists
✅ PASS: Research Save Block - Uses imperative language
✅ PASS: Research Save Block - TodoWrite integration verified

[... all 9 checkpoints ...]

=========================================
Test Results:
  Passed: 27
  Failed: 0
=========================================
✅ All blocking checkpoints verified!
```

---

## Usage Guidelines

### For Claude

1. **Always check TodoWrite** before proceeding at checkpoint
2. **Display ENFORCEMENT** message if task not completed
3. **Never skip** checkpoints without explicit override phrase
4. **Wait for PM** to complete required task
5. **Only proceed** when validation passes

### For Project Managers

1. **Complete TodoWrite tasks** to signal approval
2. **Use override phrases** only when you accept the risks
3. **Review enforcement messages** to understand what's being blocked
4. **Trust the gates** - they prevent costly mistakes

### For Developers

1. **Don't modify checkpoints** without updating this documentation
2. **Run validation script** after any command file changes
3. **Follow the pattern** when adding new checkpoints
4. **Update line numbers** in this doc if checkpoint locations change

---

## Adding New Checkpoints

To add a new blocking checkpoint:

1. **Identify the phase transition** that needs blocking
2. **Define TodoWrite task** that must be completed
3. **Write checkpoint** following the pattern structure above
4. **Add enforcement logic** with numbered steps
5. **Update this documentation** with new checkpoint location
6. **Add to verification script** (`tests/verify-blocking-checkpoints.sh`)
7. **Test validation** to ensure checkpoint works

---

## Rationale

**Why imperative language?**
Soft language like "should" or "consider" is easily ignored. MUST, NEVER, CANNOT create clear boundaries.

**Why TodoWrite integration?**
Explicit task completion is trackable and verifiable. No ambiguity about whether approval was given.

**Why ENFORCEMENT sections?**
Numbered steps give Claude clear instructions on what to do when blocked. No guesswork.

**Why override phrases?**
PM may have valid reasons to skip a gate. Explicit phrase ensures it's intentional, not accidental.

**Why NON-NEGOTIABLE rationale?**
Explains the "why" behind the gate, helping PM understand consequences of bypassing.

---

## Success Metrics

Blocking pattern is successful when:

- ✅ All 8 checkpoints pass validation script
- ✅ Zero accidental step-skipping incidents
- ✅ PM approvals are explicitly tracked
- ✅ Quality gates are never bypassed without override
- ✅ TodoWrite integration provides clear approval trail

---

## Maintenance

**Review frequency**: Every major version release
**Update triggers**:
- New phase transitions added to workflow
- Command file restructuring
- TodoWrite integration changes
- User feedback on gate effectiveness

**Last reviewed**: 2025-10-17
**Next review**: Next major version release

---

**Document Status**: Active
**Pattern Status**: Implemented and validated
**Verification**: `bash tests/verify-blocking-checkpoints.sh`
