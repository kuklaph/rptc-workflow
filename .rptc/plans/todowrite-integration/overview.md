# TodoWrite Integration - Overview

**Date**: 2025-10-16
**Status**: ✅ Approved by PM
**Thinking Mode**: Ultrathink
**Planning Approach**: Sequential step-specific agents + Final coordination

---

## Executive Summary

**Mission**: Integrate TodoWrite state persistence across all 4 RPTC commands (research, plan, tdd, commit) to achieve **60% reduction in step-skipping** while preserving PM-centric approval patterns.

**Context**: This is Iteration 1 of Priority 1 improvements. Evidence from research shows:
- Spec-Flow achieved 60% step-skipping reduction with TodoWrite
- Pimzino workflow achieved 80% reduction with imperative language
- Every Marketplace demonstrates TodoWrite survives compaction
- TodoWrite is built into Claude Code system prompt (persists across sessions)

**Approach**: 7 coordinated implementation steps with sequential agent planning to prevent timeout on complex features.

**Timeline**:
- Sequential execution: 17-24 hours
- Parallel execution (recommended): 11-16 hours (40% time savings)

**Success Metrics**:
- 60%+ reduction in step-skipping (validated in testing)
- 100% quality gate enforcement (Efficiency/Security never accidentally skipped)
- 100% compaction survival (TodoWrite persists)
- Zero regressions in existing functionality

**Deliverables**:
- 4 modified command files (research, plan, tdd, commit)
- 6 new files (SOP, patterns, tests)
- ~1,660-2,070 total new lines of code

---

## Implementation Steps

### Step 1: Add TodoWrite to Research Command
- **File**: `commands/research.md`
- **Time**: 2-3 hours
- **Phases**: 6 research phases tracked
- **Details**: See `step-01-research-command.md`

### Step 2: Add TodoWrite to Plan Command
- **File**: `commands/plan.md`
- **Time**: 2-3 hours
- **Phases**: Simple (4) vs Complex (9) paths
- **Details**: See `step-02-plan-command.md`

### Step 3: Add TodoWrite to TDD Command
- **File**: `commands/tdd.md`
- **Time**: 2-3 hours
- **Phases**: Dynamic (N×4 + 6) based on plan steps
- **Details**: See `step-03-tdd-command.md`

### Step 4: Add TodoWrite to Commit Command
- **File**: `commands/commit.md`
- **Time**: 2-3 hours
- **Phases**: 6-7 verification phases (conditional PR)
- **Details**: See `step-04-commit-command.md`

### Step 5: Implement Phase Transition Blocking
- **Files**: All 4 command files
- **Time**: 2-3 hours
- **Gates**: 8 blocking locations with imperative language
- **Details**: See `step-05-phase-blocking.md`

### Step 6: Create TodoWrite SOP Documentation
- **File**: `.rptc/sop/todowrite-guide.md`
- **Time**: 3-4 hours
- **Sections**: 8 comprehensive sections
- **Details**: See `step-06-sop-documentation.md`

### Step 7: Testing & Validation
- **Files**: `.rptc/tests/` directory (4 files)
- **Time**: 4-6 hours
- **Tests**: 21+ comprehensive test cases
- **Details**: See `step-07-testing.md`

---

## Execution Strategy

### Recommended Implementation Order

```
Phase 1: Foundation (3-4 hours)
  └─ Step 6: SOP Documentation

Phase 2: Command Integration (2-3 hours each, parallel possible)
  ├─ Step 1: Research Command
  ├─ Step 2: Plan Command
  ├─ Step 3: TDD Command
  └─ Step 4: Commit Command

Phase 3: Validation (6-9 hours)
  ├─ Step 5: Blocking Implementation (2-3 hours)
  └─ Step 7: Testing & Validation (4-6 hours)
```

**Total Timeline**:
- Sequential: 17-24 hours
- Parallel (Phase 2): 11-16 hours (40% time savings)

### Dependency Graph

```
                    Step 6: SOP Documentation
                            ↓
        ┌──────────────────┼──────────────────┐
        ↓                  ↓                  ↓
  Step 1: Research    Step 2: Plan    Step 3: TDD    Step 4: Commit
        └──────────────────┼──────────────────┘
                           ↓
              Step 5: Phase Transition Blocking
                           ↓
                  Step 7: Testing & Validation
```

**Critical Path**: Step 6 → Step 1 → Step 5 → Step 7 (cannot be parallelized)

**Bottleneck**: Step 7 (4-6 hours) - longest single step

---

## Success Criteria

### Functional Requirements
- [ ] TodoWrite integration complete (all 4 commands)
- [ ] JSON schema consistency (all commands)
- [ ] Compaction survival (100%)
- [ ] Status management (only ONE in_progress)
- [ ] Blocking gates enforced (all 8)
- [ ] Imperative language (0% soft language)
- [ ] PM approval pattern preserved (6 gates)
- [ ] Sequential planning (>3 steps)

### Quality Requirements
- [ ] 60%+ step-skipping reduction validated
- [ ] 100% quality gate enforcement
- [ ] SOP documentation complete
- [ ] Pattern documentation complete
- [ ] Integration tests pass (21+ tests)
- [ ] No regressions

---

## Coordination Information

For detailed coordination plan, conflicts resolved, integration validation scenarios, risk mitigation, and PM recommendations, see `coordination.md`.

---

**Next Step**: Begin implementation with Step 6 (SOP Documentation) or review individual step files for detailed instructions.
