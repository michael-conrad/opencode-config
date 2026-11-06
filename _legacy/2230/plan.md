---
plan_schema_version: "1.0"
issue: 2230
title: "Rewrite pre-work trunk-tip verification and submodule workflow"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 6
---

# Implementation Plan — #2230 — Rewrite Pre-Work Trunk-Tip Verification and Submodule Workflow

**Goal:** Decompose the 596-line monolithic `pre-work.md` into a dispatcher that sequences sub-tasks via canonical dispatch strings, with extracted trunk-tip verification as a separate task file and shared submodule divergence handling as a reference file.

**Architecture:** Three new/extracted artifacts (trunk-tip-verification.md task file, submodule-sync.md reference file, pre-work.md dispatcher) replace the current inline procedure. The dispatcher enforces sub-repo-before-parent and tag-before-branch ordering via state machine. All callers are within the same submodule and updated atomically in the same PR — no backward compatibility constraint.

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md` (restructure)
- `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` (new)
- `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` (extract reference)
- `.opencode/skills/git-workflow-branch/SKILL.md` (dispatch table entry)
- `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md` (cross-refs)
- `.opencode/skills/git-workflow-branch/tasks/operating-protocol.md` (cross-refs)
- `.opencode/guidelines/000-critical-rules.md` (cross-refs)
- `.opencode/tests-v2/behaviors/trunk-tip-enforcement.sh` (update)
- `.opencode/tests-v2/behaviors/submodule-pointer-enforcement.sh` (update)
- `.opencode/tests-v2/behaviors/pre-work-decomposition.sh` (new)
- 15+ additional files with mechanical cross-reference updates

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec #2230 is internally consistent: all 6 SCs have matching phases, all phases have matching SCs, no orphan SCs, no orphan phases. Verify dependency DAG is acyclic (PHASE-1, PHASE-2 → PHASE-3 → PHASE-4, PHASE-5, PHASE-6). **→ all SCs**
- [ ] 2. **Baseline check (**clean-room**).** Verify current state: pre-work.md exists at 596 lines, trunk-tip-verification.md does not exist, submodule-sync.md exists with duplicated divergence logic. Read all source files listed in spec Documentation Sources. Verify all 15+ cross-reference files exist. **→ all SCs**

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Trunk-tip verification task | `git-workflow-branch` | `pre-work` | `trunk-tip-verification.md` (new) | SC-1 | — |
| 2 — Submodule divergence reference | `git-workflow-branch` | `pre-work` | `submodule-sync.md` (extract) | SC-2 | — |
| 3 — Pre-work decomposition | `git-workflow-branch` | `pre-work` | `pre-work.md` (restructure) | SC-3a, SC-3b | 1, 2 |
| 4 — Cross-reference updates | `git-workflow-branch` | `pre-work` | 15+ files | SC-4 | 3 |
| 5 — Update existing tests | `test-driven-development` | `red` | 2 test files | SC-5 | 3 |
| 6 — New behavioral test | `test-driven-development` | `red` | `pre-work-decomposition.sh` (new) | SC-6 | 3 |

---

## Phase Details

### Phase 1 — Trunk-Tip Verification Task

| Field | Value |
|-------|-------|
| Skill | `git-workflow-branch` |
| Task | `pre-work` |
| Target | `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` (new) |
| SCs | SC-1 |
| Depends On | — |

**Context:**
- 6-step trunk-tip verification gate: (1) parent repo trunk tip, (2) zero pending changes, (3) remote tracking match, (4) submodule trunk tip, (5) submodule zero pending, (6) submodule remote tracking match, (7) submodule pointer match
- BLOCKED return contract format with specific failure reason
- Tag convention: `<parent-repo>/<issue-number>` for sub-repo tags
- Dispatchable task file with entry/exit criteria and result contract
- SKILL.md dispatch table entry with canonical dispatch string
- File is created directly using editor tools (no `skill-creator --task init` — that task does not exist)

- [ ] 3. **RED (**sub-agent**).** Write failing behavioral test asserting trunk-tip-verification.md task file does not exist yet and pre-work.md does not dispatch it. **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Create `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` with 6-step gate. Add dispatch table entry to `git-workflow-branch/SKILL.md`. **→ SC-1**
- [ ] 5. **GREEN doublecheck (**clean-room**).** Verify trunk-tip-verification.md contains all 6 verification steps, BLOCKED return contract, and correct tag convention. Verify SKILL.md has dispatch table entry. **→ SC-1**
- [ ] 6. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md .opencode/skills/git-workflow-branch/SKILL.md && git commit -m "feat: create trunk-tip-verification task file with 6-step gate"`

#### Phase 1 VbC

- [ ] 7. **VbC (**clean-room**).** Verify trunk-tip-verification.md exists, contains all 6 steps, BLOCKED contract, and tag convention. Verify SKILL.md dispatch table entry exists. **→ SC-1**

**Concern transition:** Leaving sub-repo workflow extraction → entering parent repo workflow extraction. Phase 2 depends on Phase 1's trunk-tip-verification task file.

---

### Phase 2 — Submodule Divergence Reference

| Field | Value |
|-------|-------|
| Skill | `git-workflow-branch` |
| Task | `pre-work` |
| Target | `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` (extract) |
| SCs | SC-2 |
| Depends On | — |

**Context:**
- Ahead/behind detection logic (currently duplicated in pre-work.md and submodule-sync.md)
- Rebase resolution path for submodule divergence
- Escalation path for unresolvable divergence (ahead AND behind)
- Reference file (not a task) — included via reference markers, not dispatched
- Must be usable by both pre-work.md and submodule-sync.md
- File is created directly using editor tools (no `skill-creator --task init` — that task does not exist)

- [ ] 8. **RED (**sub-agent**).** Write failing test asserting submodule divergence logic is duplicated (present in both pre-work.md and submodule-sync.md). **→ SC-2**
- [ ] 9. **GREEN (**sub-agent**).** Extract shared submodule divergence handling into submodule-sync.md as a reference file. Add reference inclusion markers. Remove duplicated logic from pre-work.md. **→ SC-2**
- [ ] 10. **GREEN doublecheck (**clean-room**).** Verify submodule-sync.md contains ahead/behind detection, rebase resolution, and escalation path. Verify pre-work.md no longer contains duplicated divergence logic. **→ SC-2**
- [ ] 11. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow-branch/tasks/submodule-sync.md .opencode/skills/git-workflow-branch/tasks/pre-work.md && git commit -m "refactor: extract shared submodule divergence handling into reference file"`

#### Phase 2 VbC

- [ ] 12. **VbC (**clean-room**).** Verify submodule-sync.md contains all divergence handling logic. Verify pre-work.md references it instead of duplicating. **→ SC-2**

**Concern transition:** Leaving parent repo workflow extraction → entering pre-work decomposition. Phase 3 depends on Phase 1 and Phase 2.

---

### Phase 3 — Pre-Work Decomposition

| Field | Value |
|-------|-------|
| Skill | `git-workflow-branch` |
| Task | `pre-work` |
| Target | `.opencode/skills/git-workflow-branch/tasks/pre-work.md` (restructure) |
| SCs | SC-3a, SC-3b |
| Depends On | 1, 2 |

**Context:**
- Canonical dispatch strings: `"execute trunk-tip-verification from git-workflow-branch"`, `"execute submodule-sync from git-workflow-branch"`
- Sub-repo-before-parent ordering: sub-repo phase dispatches first, parent repo phase dispatches second
- Tag-before-branch ordering: tagging step precedes branch creation step in both phases
- Result contract redesigned for new workflow: `status: success | failure | already_implemented`
- `already_implemented` status per #2228
- No backward compatibility — all callers within same submodule, updated atomically

- [ ] 13. **RED (**sub-agent**).** Write failing behavioral test asserting pre-work.md still contains inline trunk-tip verification and duplicated divergence logic. **→ SC-3a, SC-3b**
- [ ] 14. **GREEN (**sub-agent**).** Restructure pre-work.md as a dispatcher: add dispatch table, sequence sub-repo phase (dispatch trunk-tip-verification → tag → branch), sequence parent repo phase (dispatch trunk-tip-verification → tag → branch → commit submodule pointers). Redesign result contract with `already_implemented` status. Remove inline trunk-tip verification code. Remove duplicated divergence logic. **→ SC-3a, SC-3b**
- [ ] 15. **GREEN doublecheck (**clean-room**).** Verify pre-work.md dispatches trunk-tip-verification via canonical string. Verify sub-repo-before-parent ordering. Verify tag-before-branch ordering. Verify result contract includes `already_implemented`. Verify no inline trunk-tip verification code remains. **→ SC-3a, SC-3b**
- [ ] 16. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow-branch/tasks/pre-work.md && git commit -m "refactor: decompose pre-work.md into dispatcher with sub-task dispatch"`

#### Phase 3 VbC

- [ ] 17. **VbC (**clean-room**).** Verify pre-work.md dispatches trunk-tip-verification as sub-agent task. Verify sub-repo-before-parent and tag-before-branch ordering. Verify result contract has `already_implemented`. Verify SC-3b: trunk-tip-verification.md referenced in dispatch table. **→ SC-3a, SC-3b**

**Concern transition:** Leaving pre-work decomposition → entering cross-reference updates. Phase 4, 5, 6 all depend on Phase 3.

---

### Phase 4 — Cross-Reference Updates

| Field | Value |
|-------|-------|
| Skill | `git-workflow-branch` |
| Task | `pre-work` |
| Target | 15+ files with cross-references |
| SCs | SC-4 |
| Depends On | 3 |

**Context:**
- Files to update: pre-commit-pointer-check.md, operating-protocol.md, SKILL.md, 000-critical-rules.md, 15+ additional files
- New pre-work.md step numbers and dispatch strings
- New result contract format (redesigned, not preserved from old format)
- All submodule names, branch names, and repo paths resolved dynamically using `$DEFAULT_BRANCH`, `git remote show origin`, `git submodule status` — no hardcoded values
- Mechanical updates only — no behavioral changes

- [ ] 18. **RED (**sub-agent**).** Write failing grep test asserting old cross-references still exist (pre-work.md old step numbers, old contract format). **→ SC-4**
- [ ] 19. **GREEN (**sub-agent**).** Update all 15+ files with new pre-work.md step numbers, dispatch strings, and result contract format. Verify no hardcoded submodule names, branch names, or repo paths. **→ SC-4**
- [ ] 20. **GREEN doublecheck (**clean-room**).** Verify all cross-references updated. Verify no hardcoded values remain. Verify redesigned contract format is used everywhere. **→ SC-4**
- [ ] 21. **Checkpoint commit (**inline**).** `git add <all 15+ files> && git commit -m "chore: update cross-references for decomposed pre-work.md"`

#### Phase 4 VbC

- [ ] 22. **VbC (**clean-room**).** Verify grep for hardcoded submodule names, branch names, or repo paths returns empty. Verify grep for redesigned contract format returns matches. **→ SC-4**

**Concern transition:** Leaving cross-reference updates → entering behavioral test updates. Phase 5 depends on Phase 3.

---

### Phase 5 — Update Existing Behavioral Tests

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/trunk-tip-enforcement.sh`, `.opencode/tests-v2/behaviors/submodule-pointer-enforcement.sh` |
| SCs | SC-5 |
| Depends On | 3 |

**Context:**
- Existing tests assert against inline pre-work.md behavior — must be updated for new task structure
- `trunk-tip-enforcement.sh`: update assertions to match trunk-tip-verification.md dispatch pattern
- `submodule-pointer-enforcement.sh`: update assertions to match new submodule-sync.md reference pattern
- Remove overcomplicated divergence analysis assertions (ahead/behind counting, SHA comparison matrix, `--ff-only` gates)
- Remove already-implemented handler assertions from pre-work.md (moved to yield-back contract per #2228)

- [ ] 23. **RED (**sub-agent**).** Run existing behavioral tests — they should FAIL because they assert against old inline structure. **→ SC-5**
- [ ] 24. **GREEN (**sub-agent**).** Update `trunk-tip-enforcement.sh` and `submodule-pointer-enforcement.sh` to match new task structure and dispatch patterns. Remove overcomplicated divergence assertions. Remove already-implemented handler assertions. **→ SC-5**
- [ ] 25. **GREEN doublecheck (**clean-room**).** Verify updated tests assert against new task structure. Verify removed patterns are absent. **→ SC-5**
- [ ] 26. **Checkpoint commit (**inline**).** `git add .opencode/tests-v2/behaviors/trunk-tip-enforcement.sh .opencode/tests-v2/behaviors/submodule-pointer-enforcement.sh && git commit -m "test: update behavioral tests for decomposed pre-work"`

#### Phase 5 VbC

- [ ] 27. **VbC (**clean-room**).** Verify grep for removed patterns (ahead/behind counting, SHA comparison, `--ff-only` gates, already-implemented handler) returns empty in pre-work.md. **→ SC-5**

**Concern transition:** Leaving behavioral test updates → entering new behavioral test. Phase 6 depends on Phase 3.

---

### Phase 6 — New Behavioral Test

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/pre-work-decomposition.sh` (new) |
| SCs | SC-6 |
| Depends On | 3 |

**Context:**
- New behavioral test verifying decomposed pre-work dispatches sub-tasks in correct order
- SC-1 assertion: sub-repo-before-parent ordering (session.yaml inspection)
- SC-2 assertion: tag-before-branch ordering (session.yaml inspection)
- SC-6 assertion: yield-back contract includes `already_implemented` status alongside `success` and `failure`
- Use `assert_semantic` for behavioral assertions (SC-1, SC-2)
- Use `assert_stderr_pattern_present` for structural corroboration of dispatch strings
- Use `assert_required_pattern_present` for `already_implemented` in result contract (SC-6)

- [ ] 28. **RED (**sub-agent**).** Write new behavioral test `pre-work-decomposition.sh` with assertions for SC-1, SC-2, SC-6. Test should FAIL because the assertions reference the new structure that doesn't exist yet. **→ SC-6**
- [ ] 29. **GREEN (**sub-agent**).** Finalize `pre-work-decomposition.sh` with all assertions. Wire into test infrastructure. **→ SC-6**
- [ ] 30. **GREEN doublecheck (**clean-room**).** Verify test file exists, contains SC-1, SC-2, SC-6 assertions, uses correct assertion helpers. **→ SC-6**
- [ ] 31. **Checkpoint commit (**inline**).** `git add .opencode/tests-v2/behaviors/pre-work-decomposition.sh && git commit -m "test: add behavioral test for decomposed pre-work dispatch ordering"`

#### Phase 6 VbC

- [ ] 32. **VbC (**clean-room**).** Verify pre-work-decomposition.sh exists. Verify grep for `already_implemented` in pre-work.md result contract returns matches. **→ SC-6**

---

## Post-Implementation Steps

- [ ] 33. **Structural checks (**sub-agent**).** Run lint/typecheck/format on all modified files. Run `bash .opencode/tests-v2/test-enforcement.sh --changed` for content-verification tests. **→ all SCs**
- [ ] 34. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path tmp/2230-state.yaml --contract-path tmp/2230-contract.yaml` to verify all state transitions are reachable. **→ all SCs**
- [ ] 35. **Pre-PR gate (**clean-room**).** Verify all 6 SC verdicts are PASS. Any FAIL blocks PR creation. **→ all SCs**
- [ ] 36. **Regression check (**sub-agent**).** Run full behavioral test suite for changed scenarios: `bash .opencode/tests-v2/behaviors/trunk-tip-enforcement.sh`, `bash .opencode/tests-v2/behaviors/submodule-pointer-enforcement.sh`, `bash .opencode/tests-v2/behaviors/pre-work-decomposition.sh`. **→ all SCs**
- [ ] 37. **Review prep (**sub-agent**).** Prepare PR review context: summary of changes, SC coverage, test results. **→ all SCs**
- [ ] 38. **Create PR (**sub-agent**).** Create pull request with stacked strategy targeting trunk. **→ all SCs**
- [ ] 39. **Executive summary (**sub-agent**).** Generate completion executive summary with SC status table. **→ all SCs**

---

## Exit Criteria

- [ ] C1. `trunk-tip-verification.md` exists as a separate dispatchable task file with 6-step gate (SC-1, SC-3b)
- [ ] C2. `submodule-sync.md` contains shared submodule divergence handling as a reference file (SC-2)
- [ ] C3. `pre-work.md` dispatches sub-tasks via canonical dispatch strings with sub-repo-before-parent and tag-before-branch ordering (SC-3a)
- [ ] C4. All 15+ cross-reference files updated with new step numbers, dispatch strings, and result contract format (SC-4)
- [ ] C5. No hardcoded submodule names, branch names, or repo paths in pre-work.md (SC-4)
- [ ] C6. Overcomplicated divergence analysis and already-implemented handler removed from pre-work.md (SC-5)
- [ ] C7. Existing behavioral tests updated for new task structure (SC-5)
- [ ] C8. New behavioral test `pre-work-decomposition.sh` verifies sub-task dispatch order (SC-6)
- [ ] C9. Yield-back contract includes `already_implemented` status alongside `success` and `failure` (SC-6)
- [ ] C10. All 6 SCs pass with correct evidence types
