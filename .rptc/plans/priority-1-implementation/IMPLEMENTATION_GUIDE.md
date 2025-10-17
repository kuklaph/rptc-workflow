# Priority 1 Improvements - Implementation Guide

**Branch**: `feature/priority-1-improvements`
**Worktree**: `../rptc-priority-1`
**Start Date**: 2025-01-16
**Strategy**: Incremental + Compounding (Each improvement helps with the next)

---

## 🎯 Mission: RPTC Self-Improvement via RPTC

Use RPTC workflow to implement Priority 1 improvements into RPTC itself, manually applying each improvement immediately after building it so it helps with the next iteration.

### Priority 1 Improvements (4 Iterations)

1. **Iteration 1**: TodoWrite Integration (60% step-skipping reduction)
2. **Iteration 2**: Plan Document Optimization (75-85% token reduction)
3. **Iteration 3**: Quality Gate Enforcement (100% compliance)
4. **Iteration 4**: Imperative Language Standardization (clarity)

**Compounding Effect**: Each iteration reduces manual overhead for the next.

---

## 📋 Worktree Setup (COMPLETED ✅)

```bash
# Create worktree (DONE)
git worktree add -b feature/priority-1-improvements ../rptc-priority-1

# Navigate to worktree
cd ../rptc-priority-1

# Verify location
pwd  # Should show: .../rptc-priority-1
git branch  # Should show: * feature/priority-1-improvements
```

**Status**: ✅ Worktree created at `../rptc-priority-1`

### Research Documents (COPIED ✅)

**Issue**: Worktree doesn't include untracked files from main worktree
**Fix**: Research documents copied to worktree

```bash
# Research documents now available (DONE)
.rptc/research/
├── rptc-competitive-analysis.md       (27KB) - 7 workflows comparison
├── rptc-complete-workflow-analysis.md (45KB) - Comprehensive synthesis
└── workflow-reliability-improvements.md (36KB) - TodoWrite evidence, imperative language
```

**Status**: ✅ All 3 research documents available for planning phase

### Initial Commit (REQUIRED BEFORE PLANNING)

**Commit research documents to feature branch** (makes them available throughout implementation):

```bash
# In worktree: ../rptc-priority-1
git add .rptc/research/
git commit -m "docs(research): add Priority 1 research findings

- Competitive analysis (7 workflows, 50K+ stars)
- Complete RPTC workflow analysis (internal + external)
- Token optimization analysis
- TodoWrite integration evidence (Spec-Flow 60% reduction)

These research findings inform Priority 1 implementation decisions.
"
```

**Status**: ⬜ Not committed yet - DO THIS BEFORE PLANNING

---

## 🔄 Implementation Loop Pattern

Each iteration follows this pattern:

```
1. PLAN (using /rptc:plan)
   ├─ Manual compensations active
   ├─ Previous iterations auto-enabled
   └─ Output: .rptc/plans/[improvement]/

2. TDD (using /rptc:tdd)
   ├─ Manual compensations active
   ├─ Tests FIRST, then implementation
   └─ 100% test suite passing

3. COMMIT (using /rptc:commit)
   ├─ Documentation auto-sync
   └─ Commit to feature branch

4. VALIDATE
   ├─ Test the improvement works
   ├─ Measure effectiveness
   └─ ENABLE for next iteration
```

---

## ITERATION 1: TodoWrite Integration

**Goal**: Eliminate step-skipping via persistent state tracking

### Phase 1.0: Pre-Planning Setup

- [ ] **Switch to worktree**
  ```bash
  cd ../rptc-priority-1
  ```

- [ ] **Commit research documents** (REQUIRED - provides context for planning)
  ```bash
  git add .rptc/research/
  git commit -m "docs(research): add Priority 1 research findings

  - Competitive analysis (7 workflows, 50K+ stars)
  - Complete RPTC workflow analysis (internal + external)
  - Token optimization analysis
  - TodoWrite integration evidence (Spec-Flow 60% reduction)

  These research findings inform Priority 1 implementation decisions.
  "
  ```

### Phase 1.1: Planning

- [ ] **Run planning command**
  ```bash
  /rptc:plan "Implement TodoWrite integration across all 4 core RPTC commands (research, plan, tdd, commit) with phase transition blocking. Context: This is Iteration 1 of Priority 1 improvements. Spec-Flow achieved 60% step-skipping reduction with TodoWrite. Must preserve PM-centric approval pattern and work across compaction."
  ```

- [ ] **MANUAL: Apply TodoWrite checklist during planning** (Test-drive concept)
  ```markdown
  📝 PLANNING PHASE TODOS (Track manually)

  - [ ] Research TodoWrite API and best practices
  - [ ] Review Spec-Flow implementation patterns
  - [ ] Design TodoWrite integration for /rptc:research
  - [ ] Design TodoWrite integration for /rptc:plan
  - [ ] Design TodoWrite integration for /rptc:tdd
  - [ ] Design TodoWrite integration for /rptc:commit
  - [ ] Design phase transition blocking logic
  - [ ] Define test strategy (BEFORE implementation)
  - [ ] Create acceptance criteria
  - [ ] Identify risks and dependencies
  - [ ] Master Feature Planner Agent report delivered ✅
  - [ ] Implementation plan created
  ```

- [ ] **MANUAL: Restructure plan into directory format** (Test optimization)
  ```bash
  # After Master Feature Planner delivers monolithic plan
  mkdir -p .rptc/plans/todowrite-integration

  # Split into:
  # .rptc/plans/todowrite-integration/
  # ├── overview.md              (~450 tokens)
  # ├── step-01-research-api.md  (~200 tokens)
  # ├── step-02-design.md        (~200 tokens)
  # ├── step-03-impl-research.md (~200 tokens)
  # ├── step-04-impl-plan.md     (~200 tokens)
  # ├── step-05-impl-tdd.md      (~200 tokens)
  # ├── step-06-impl-commit.md   (~200 tokens)
  # ├── step-07-blocking.md      (~200 tokens)
  # └── step-08-integration.md   (~200 tokens)
  ```

- [ ] **Verify test strategy is defined FIRST**
  - Check overview.md has complete test strategy
  - Unit tests defined
  - Integration tests defined
  - Coverage targets set (90% for TodoWrite code)

### Phase 1.2: TDD Implementation

- [ ] **Run TDD command**
  ```bash
  /rptc:tdd "@todowrite-integration/overview.md"
  ```

- [ ] **MANUAL: Track steps with TodoWrite checklist**
  ```markdown
  📝 TDD PHASE TODOS (Track manually)

  - [ ] Step 1: Research TodoWrite API (load step-01.md only)
  - [ ] Step 2: Design integration pattern (load step-02.md only)
  - [ ] Step 3: Implement /rptc:research integration (load step-03.md)
  - [ ] Step 4: Implement /rptc:plan integration (load step-04.md)
  - [ ] Step 5: Implement /rptc:tdd integration (load step-05.md)
  - [ ] Step 6: Implement /rptc:commit integration (load step-06.md)
  - [ ] Step 7: Implement blocking logic (load step-07.md)
  - [ ] Step 8: Full integration test (load step-08.md)
  - [ ] All tests passing (100%) ✅
  - [ ] [QUALITY GATE 1] Master Efficiency Agent review (MANUAL)
  - [ ] [QUALITY GATE 2] Master Security Agent review (MANUAL)
  ```

- [ ] **MANUAL: Load only overview + current step** (Test token efficiency)
  - Measure tokens: overview (450) + step (200) = 650 tokens
  - Compare to monolithic: Would be 2000+ tokens

- [ ] **MANUAL: Enforce quality gates after tests pass**
  - STOP after all tests pass
  - Manually invoke: Master Efficiency Agent (with PM approval)
  - Manually invoke: Master Security Agent (with PM approval)
  - Do NOT proceed to commit until both complete

- [ ] **MANUAL: Monitor token usage**
  - Check token count every 30 minutes
  - Compact at 80% threshold if needed
  - Preserve TodoWrite checklist (screenshot before compaction)

### Phase 1.3: Commit

- [ ] **Run commit command**
  ```bash
  /rptc:commit
  ```

- [ ] **Verify commit includes**
  - All TodoWrite integration code
  - All tests (100% passing)
  - Efficiency Agent report applied
  - Security Agent report applied
  - Documentation auto-sync from Doc Specialist

- [ ] **Git commit message**
  ```
  feat(workflow): implement TodoWrite integration across core commands

  - Add TodoWrite initialization to /rptc:research
  - Add TodoWrite initialization to /rptc:plan
  - Add TodoWrite initialization to /rptc:tdd
  - Add TodoWrite initialization to /rptc:commit
  - Implement phase transition blocking logic
  - Add step tracking (in_progress → completed)
  - Tests: 90%+ coverage on TodoWrite integration code

  This implements Priority 1.1 of the self-improvement roadmap.
  Based on Spec-Flow evidence showing 60% step-skipping reduction.

  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

### Phase 1.4: Validation

- [ ] **Test TodoWrite in action**
  ```bash
  # Test in a new session
  /rptc:research "test topic for TodoWrite validation"

  # Verify:
  # - TodoWrite initializes automatically
  # - Steps are tracked (in_progress → completed)
  # - You can see persistent state
  ```

- [ ] **Measure effectiveness**
  - Baseline: "Sometimes steps are skipped in long sessions"
  - With TodoWrite: Run 2-hour session, count skipped steps
  - Target: 60% reduction in skipped steps
  - Record results: _____ skipped steps (vs baseline: _____)

- [ ] **Enable for Iteration 2**
  - If TodoWrite reduces step-skipping → ✅ Use for Plan Opt planning
  - If TodoWrite has issues → 🔧 Refine before proceeding

**Iteration 1 Status**: ⬜ Not Started | 🟡 In Progress | ✅ Complete

---

## ITERATION 2: Plan Document Optimization

**Goal**: 75-85% token reduction on plan loading

### Phase 2.1: Planning

- [ ] **Run planning command**
  ```bash
  /rptc:plan "Implement directory-based plan structure in Master Feature Planner. Update /rptc:tdd to load overview.md + current step only. Context: This is Iteration 2 of Priority 1. Monolithic plans waste 90% of tokens during TDD. Target: 650 tokens per step vs 1500-4500 monolithic."
  ```

- [ ] **AUTO: TodoWrite tracking** ✅ (Enabled from Iteration 1)
  - TodoWrite should initialize automatically
  - Track planning steps automatically

- [ ] **AUTO: Plan directory structure** ✅ (Already tested in Iteration 1)
  - Master Feature Planner should generate directory structure
  - No manual splitting needed

- [ ] **Verify test strategy defined FIRST**

### Phase 2.2: TDD Implementation

- [ ] **Run TDD command**
  ```bash
  /rptc:tdd "@plan-optimization/overview.md"
  ```

- [ ] **AUTO: TodoWrite tracking** ✅
  - Steps tracked automatically
  - Phase transition blocking works

- [ ] **AUTO: Plan token efficiency** ✅
  - Load only overview + current step
  - 650 tokens vs 4000+ monolithic

- [ ] **MANUAL: Quality gates** (Still manual in Iteration 2)
  - STOP after tests pass
  - Invoke Efficiency Agent manually
  - Invoke Security Agent manually

- [ ] **MANUAL: Token monitoring** (Still manual in Iteration 2)

### Phase 2.3: Commit

- [ ] **Run commit command**
  ```bash
  /rptc:commit
  ```

- [ ] **Git commit message**
  ```
  feat(planning): implement directory-based plan optimization

  - Update Master Feature Planner to generate overview.md + step-NN.md structure
  - Update /rptc:tdd to load overview + current step only (650 tokens vs 1500-4500)
  - Add step file navigation logic
  - Tests: Full workflow test with 10-step feature (measure token savings)

  This implements Priority 1.2 of the self-improvement roadmap.
  Achieves 75-85% token reduction on plan loading.

  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

### Phase 2.4: Validation

- [ ] **Measure token efficiency**
  - Create 10-step test plan
  - Measure tokens loaded per step: _____ tokens
  - Compare to monolithic baseline: _____ tokens
  - Calculate savings: _____% reduction
  - Target: 75-85% reduction

- [ ] **Enable for Iteration 3**
  - If optimization works → ✅ Use for Quality Gates planning
  - If issues → 🔧 Refine

**Iteration 2 Status**: ⬜ Not Started | 🟡 In Progress | ✅ Complete

---

## ITERATION 3: Quality Gate Enforcement

**Goal**: 100% quality gate compliance (never skip)

### Phase 3.1: Planning

- [ ] **Run planning command**
  ```bash
  /rptc:plan "Implement automated quality gate enforcement in /rptc:tdd. Add TodoWrite checklist for Efficiency + Security gates. Block /rptc:commit until both gates completed. Context: This is Iteration 3 of Priority 1. Current gates are optional (soft language), can be accidentally skipped. Must preserve PM approval pattern."
  ```

- [ ] **AUTO: TodoWrite + Plan structure** ✅ (Both enabled)

### Phase 3.2: TDD Implementation

- [ ] **Run TDD command**
  ```bash
  /rptc:tdd "@quality-gate-enforcement/overview.md"
  ```

- [ ] **AUTO: TodoWrite + Plan efficiency** ✅
- [ ] **MANUAL: Quality gates** (Testing the enforcement we're building)
- [ ] **MANUAL: Token monitoring**

### Phase 3.3: Commit

- [ ] **Run commit command**
  ```bash
  /rptc:commit
  ```

- [ ] **Git commit message**
  ```
  feat(quality): implement automated quality gate enforcement

  - Add TodoWrite checklist for Efficiency + Security gates in /rptc:tdd
  - Implement blocking logic: commit phase blocked until gates complete
  - Preserve PM approval pattern (user control maintained)
  - Update gate language: "MUST delegate" (hard imperative)
  - Tests: Verify blocking works, test gate compliance tracking

  This implements Priority 1.3 of the self-improvement roadmap.
  Ensures 100% quality gate compliance.

  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

### Phase 3.4: Validation

- [ ] **Test automated enforcement**
  - Run /rptc:tdd on test feature
  - After tests pass, verify:
    - TodoWrite shows gate checkboxes
    - Cannot proceed to commit without gates
    - Gates must be explicitly completed

- [ ] **Measure compliance**
  - Run 5 test features through TDD
  - Count: Gates invoked _____ / 5 (target: 5/5 = 100%)

- [ ] **Enable for Iteration 4**
  - If enforcement works → ✅ Use for Language planning
  - If issues → 🔧 Refine

**Iteration 3 Status**: ⬜ Not Started | 🟡 In Progress | ✅ Complete

---

## ITERATION 4: Imperative Language Standardization

**Goal**: Clear, unambiguous command language (no soft language)

### Phase 4.1: Planning

- [ ] **Run planning command**
  ```bash
  /rptc:plan "Audit all 14 RPTC command files for soft language patterns. Replace with hard imperative keywords (CRITICAL, MUST, NEVER, ALWAYS). Create language standards document. Context: This is Iteration 4 (final) of Priority 1. Current commands use soft language (should, consider) leading to misinterpretation and step-skipping."
  ```

- [ ] **AUTO: TodoWrite + Plan structure + Quality gates** ✅ (All enabled)

### Phase 4.2: TDD Implementation

- [ ] **Run TDD command**
  ```bash
  /rptc:tdd "@language-standardization/overview.md"
  ```

- [ ] **AUTO: TodoWrite + Plan efficiency + Quality gates** ✅
  - First iteration with ALL improvements working together!

- [ ] **MANUAL: Token monitoring** (Only manual item left)

### Phase 4.3: Commit

- [ ] **Run commit command**
  ```bash
  /rptc:commit
  ```

- [ ] **Git commit message**
  ```
  feat(language): standardize imperative language across all commands

  - Audit 14 command files for soft language patterns
  - Replace "should", "consider", "recommended" with CRITICAL/MUST/NEVER/ALWAYS
  - Create language standards document (.rptc/sop/imperative-language-guide.md)
  - Apply standards consistently across all commands
  - Tests: Verify language clarity, test agent response to hard imperatives

  This implements Priority 1.4 (final) of the self-improvement roadmap.
  Completes all Priority 1 improvements.

  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

### Phase 4.4: Validation

- [ ] **Full workflow test with ALL improvements**
  ```bash
  # Run complete workflow with all improvements active
  /rptc:research "final validation test"
  /rptc:plan "@final-validation-test.md"
  /rptc:tdd "@final-validation-plan/overview.md"
  /rptc:commit

  # Verify:
  # - TodoWrite: ✅ No steps skipped
  # - Plan optimization: ✅ 75%+ token savings
  # - Quality gates: ✅ 100% compliance (auto-enforced)
  # - Language: ✅ Clear, unambiguous instructions
  ```

- [ ] **Measure overall improvement**
  - Step-skipping: _____% reduction (target: 60%)
  - Token efficiency: _____% savings on plans (target: 75-85%)
  - Quality gate compliance: _____% (target: 100%)
  - Language clarity: Manual assessment (clear vs ambiguous)

**Iteration 4 Status**: ⬜ Not Started | 🟡 In Progress | ✅ Complete

---

## 🚀 Final Steps: Merge Back to Main

### Create Pull Request

- [ ] **Push feature branch**
  ```bash
  git push -u origin feature/priority-1-improvements
  ```

- [ ] **Create PR**
  ```bash
  gh pr create --title "feat: Priority 1 Workflow Improvements (TodoWrite, Plan Opt, Quality Gates, Language)" --body "$(cat <<'EOF'
  ## Summary

  Implements all Priority 1 improvements from the RPTC self-improvement roadmap:

  - ✅ **TodoWrite Integration**: Persistent state tracking, 60% step-skipping reduction
  - ✅ **Plan Document Optimization**: Directory structure, 75-85% token reduction
  - ✅ **Quality Gate Enforcement**: Automated blocking, 100% compliance
  - ✅ **Imperative Language Standardization**: Clear command language, reduced ambiguity

  ## Implementation Approach

  - **Strategy**: Incremental + Compounding (each improvement helps the next)
  - **Testing**: Each improvement validated before enabling for next iteration
  - **Dogfooding**: Used RPTC to improve RPTC (with manual compensations)

  ## Test Results

  - Step-skipping reduction: _____% (target: 60%)
  - Plan token efficiency: _____% savings (target: 75-85%)
  - Quality gate compliance: _____% (target: 100%)
  - Language clarity: Clear and unambiguous ✅

  ## Breaking Changes

  - Plan structure changed: Monolithic → Directory-based
  - Quality gates now enforced: Blocking logic added
  - Command language updated: Soft → Hard imperatives

  ## Migration

  Workspace version bump required. `/rptc:admin-upgrade` will handle migration.

  🤖 Generated with [Claude Code](https://claude.com/claude-code)
  EOF
  )"
  ```

- [ ] **Review PR, address feedback**

- [ ] **Merge to main**
  ```bash
  # After approval
  gh pr merge --squash
  ```

### Cleanup Worktree

- [ ] **Remove worktree after merge**
  ```bash
  cd ../rptc-workflow  # Back to main worktree
  git worktree remove ../rptc-priority-1
  git branch -d feature/priority-1-improvements
  ```

- [ ] **Update main branch**
  ```bash
  git pull origin main
  ```

---

## 📊 Success Metrics (Final Report)

### Quantitative Results

| Metric | Baseline | Target | Actual | Status |
|--------|----------|--------|--------|--------|
| Step-skipping reduction | Frequent | 60% | _____% | ⬜ |
| Plan token efficiency | 1500-4500/step | 650/step (75-85% ↓) | _____ tokens | ⬜ |
| Quality gate compliance | Variable | 100% | _____% | ⬜ |
| Language clarity | Mixed soft/hard | 100% hard | _____% | ⬜ |

### Qualitative Results

- [ ] TodoWrite persistence across compaction: ✅ / ❌
- [ ] Directory-based plans easier to navigate: ✅ / ❌
- [ ] Quality gates prevent skipping: ✅ / ❌
- [ ] Command language reduces ambiguity: ✅ / ❌

---

## 🎯 Current Status

**Active Iteration**: ⬜ Iteration 1 | ⬜ Iteration 2 | ⬜ Iteration 3 | ⬜ Iteration 4 | ⬜ Complete

**Current Phase**: ⬜ Planning | ⬜ TDD | ⬜ Commit | ⬜ Validation

**Last Updated**: 2025-01-16

---

## 📝 Notes & Learnings

### What Worked Well
-

### What Needed Adjustment
-

### Key Insights
-

### Recommendations for Future Improvements
-

---

**End of Implementation Guide**
