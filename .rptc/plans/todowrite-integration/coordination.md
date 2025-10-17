# Final Coordination Plan

**Date**: 2025-10-16
**Status**: ✅ Approved by PM

This document contains coordination details, conflict resolutions, integration scenarios, risk mitigation, and PM recommendations for the TodoWrite integration project.

---

## Table of Contents

1. [Execution Strategy](#execution-strategy)
2. [Conflicts Resolved](#conflicts-resolved)
3. [Unified Timeline](#unified-timeline)
4. [Integration Validation](#integration-validation)
5. [Top 10 Risks](#top-10-risks)
6. [Master Acceptance Criteria](#master-acceptance-criteria)
7. [Deliverables Summary](#deliverables-summary)
8. [PM Recommendations](#pm-recommendations)
9. [Appendices](#appendices)

---

## Section 1: Execution Strategy

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

### Critical Path

**Step 6 → Step 1 → Step 5 → Step 7** (cannot be parallelized)

**Bottleneck**: Step 7 (4-6 hours) - longest single step

**Risk Point**: Step 6 defines JSON structure - errors cascade

---

## Section 2: Conflicts Resolved

### Conflict 1: TodoWrite JSON Structure Consistency

**Resolution**: SOP (Step 6) defines canonical structure, all commands reference it

**Standard Fields**: content, status, activeForm (same across all commands)

### Conflict 2: Blocking Location Counts

**Resolution**: Exactly 8 blocking locations identified:
1. Research - save gate
2. Plan - Master Planner delegation gate
3. Plan - final save gate
4. TDD - Efficiency Agent gate
5. TDD - Security Agent gate
6. TDD - completion gate
7. Commit - test failure gate
8. Commit - code quality gate

**Note**: Doc Specialist is AUTOMATIC (not a blocking gate)

### Conflict 3: PM Approval Pattern vs Automatic Execution

**Resolution**:
- **PM Approval Required**: Research save, Plan delegation, Plan save, Efficiency, Security, TDD completion
- **Automatic**: Doc Specialist, pre-commit verification checks

### Conflict 4: Line Number References

**Resolution**: Use section headers as anchors, not hardcoded line numbers

---

## Section 3: Unified Timeline

**Phase 1 (Foundation)**: 3-4 hours
- Step 6: SOP Documentation

**Phase 2 (Command Integration)**: 2-3 hours each
- Steps 1-4 can run in parallel (8-12h sequential, 2-3h parallel)

**Phase 3 (Validation)**: 6-9 hours
- Step 5: Blocking (2-3h)
- Step 7: Testing (4-6h)

**Total**: 17-24h sequential, 11-16h parallel

---

## Section 4: Integration Validation

### Scenario 1: Complete Workflow with TodoWrite Persistence

1. Run research → plan → tdd → commit
2. Trigger `/compact` during workflow
3. Verify TodoWrite survives compaction
4. Verify no steps skipped

**Expected**: 100% phase completion, TodoWrite persists

### Scenario 2: Blocking Gate Enforcement

Test all 8 blocking gates:
- Attempt bypass without approval
- Verify blocking message appears
- Provide approval
- Verify progression

**Expected**: 100% blocking enforcement

### Scenario 3: PM Approval Pattern Consistency

Verify 6 PM gates require approval, Doc Specialist automatic

**Expected**: Clear distinction between approval and automatic phases

### Scenario 4: Complex Feature Planning (Sequential Agents)

Create 8+ step feature, verify sequential agents coordinate without timeout

**Expected**: No timeout, context handoff maintains coordination

---

## Section 5: Top 10 Risks

1. **JSON Structure Inconsistency** (CRITICAL) - SOP defines first, commands reference
2. **Blocking Gates Bypassed** (CRITICAL) - Imperative language upgrade
3. **Line Number Shifts** (HIGH) - Use section anchors
4. **Complex Feature Timeout** (HIGH) - Sequential agents (>3 steps)
5. **Compaction Failure** (HIGH) - Follow system prompt rules
6. **60% Reduction Target Not Met** (MEDIUM) - Baseline measurement + testing
7. **Doc Specialist UX** (MEDIUM) - Clear automatic messaging
8. **Testing Insufficient** (MEDIUM) - 21+ comprehensive tests
9. **System Reminders Don't Trigger** (LOW) - Update frequently
10. **Token Overhead** (LOW) - TodoWrite lightweight

---

## Section 6: Master Acceptance Criteria

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

## Section 7: Deliverables Summary

### New Files (6)

1. `.rptc/sop/todowrite-guide.md` - SOP documentation
2. `.rptc/patterns/blocking-validation.md` - Blocking pattern
3. `.rptc/tests/todowrite-integration-tests.md` - Master test checklist
4. `.rptc/tests/compaction-survival-tests.md` - Compaction tests
5. `.rptc/tests/blocking-validation-tests.md` - Blocking tests
6. `.rptc/tests/performance-measurement.md` - Performance metrics

### Modified Files (4)

1. `commands/research.md` - +50-70 lines (TodoWrite integration)
2. `commands/plan.md` - +80-100 lines (TodoWrite + routing)
3. `commands/tdd.md` - +60-80 lines (Dynamic TodoWrite)
4. `commands/commit.md` - +40-50 lines (TodoWrite + Doc Specialist)

### Blocking Upgrades (8 locations)

- Research: 1 location
- Plan: 2 locations
- TDD: 3 locations
- Commit: 2 locations

**Total New LoC**: ~1,660-2,070 lines

---

## Section 8: PM Recommendations

### Critical Decision 1: Execution Strategy

**Recommendation**: **Parallel execution** (Phase 2) if resources available

**Benefit**: 40% time savings (11-16h vs 17-24h)

**Requirement**: Clear communication that Step 6 must complete before Steps 1-4 start

### Critical Decision 2: Complex Feature Threshold

**Recommendation**: **≤3 steps** triggers simple path, **>3 steps** triggers sequential agents

**Rationale**: Conservative threshold prevents timeout, easy to adjust

### Critical Decision 3: Documentation Specialist Gate

**Recommendation**: **Automatic** (no PM approval)

**Rationale**: Doc sync is operational, not a decision gate. PM reviews generated docs in commit summary.

### Optional Enhancements (Out of Scope)

1. **File-Based State Tracking** (Spec-Flow pattern) - +5-8 hours
2. **Work Tree Integration** - +1-2 hours
3. **Performance Metrics Dashboard** - +3-4 hours

**Recommendation**: Implement if TodoWrite alone doesn't achieve 60% reduction

### Post-Implementation Monitoring

**Week 1-2**:
- Monitor actual step-skipping rate
- Track user feedback on imperative language
- Verify compaction survival
- Check for timeout issues

**Week 3-4**:
- Analyze quality gate compliance
- Gather PM feedback
- Identify missed edge cases
- Consider optional enhancements

**Red Flags**:
- Step-skipping reduction <40%
- Quality gates skipped >5%
- Complex features timeout
- PM approval fatigue

---

## Appendices

### Appendix A: TodoWrite JSON Structure (Canonical)

```json
{
  "tool": "TodoWrite",
  "todos": [
    {
      "content": "[Task description in imperative form]",
      "status": "pending" | "in_progress" | "completed",
      "activeForm": "[Human-readable description during work]"
    }
  ]
}
```

**Rules**:
- Only ONE task "in_progress" at a time
- Update frequently (prevents system reminders)
- Lowercase status values always
- Descriptive activeForm for context

### Appendix B: Imperative Keywords (Blocking Gates)

**Use these keywords**:
- **CRITICAL**: Highest priority
- **MUST**: Required action
- **NEVER**: Prohibited action
- **ALWAYS**: Invariant rule
- **NON-NEGOTIABLE**: Not subject to debate
- **MANDATORY**: Required by design
- **CANNOT PROCEED**: Blocks progress

**Avoid soft language**:
- ❌ "should" → ✅ "MUST"
- ❌ "consider" → ✅ "MANDATORY"
- ❌ "recommended" → ✅ "REQUIRED"

### Appendix C: 8 Blocking Locations

1. **Research** (commands/research.md): Save without PM approval
2. **Plan** (commands/plan.md): Master Planner delegation without PM approval
3. **Plan** (commands/plan.md): Plan save without PM approval
4. **TDD** (commands/tdd.md): Efficiency Agent without PM approval
5. **TDD** (commands/tdd.md): Security Agent without PM approval
6. **TDD** (commands/tdd.md): TDD completion without PM approval
7. **Commit** (commands/commit.md): Commit with failing tests
8. **Commit** (commands/commit.md): Commit with quality issues

**Automatic** (no PM gate):
- Commit → Documentation Specialist

### Appendix D: Sequential Execution Summary

```
Phase 1 (Foundation):    Step 6: SOP (3-4h)
Phase 2 (Parallel):      Steps 1-4: Commands (2-3h each)
Phase 3 (Validation):    Step 5: Blocking (2-3h) → Step 7: Testing (4-6h)

Total: 17-24h sequential, 11-16h parallel
```

### Appendix E: Success Metrics

**Primary**: 60%+ step-skipping reduction (validated in Step 7)

**Secondary**:
- 100% quality gate enforcement
- 100% compaction survival
- 100% blocking gate success
- 100% plan synchronization

---

## Final Approval

**Status**: ✅ Approved by PM on 2025-10-16

**Next Step**: Begin implementation with Step 6 (SOP Documentation) or `/rptc:tdd "@todowrite-integration/overview.md"`

**Quality Gates**: After implementation complete, approve Efficiency and Security reviews

---

_Coordination plan created using Sequential Planning Architecture_
_7 step-specific agents + Final coordination agent_
_Thinking mode: Ultrathink_
