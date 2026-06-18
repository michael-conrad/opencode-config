# Plan — [SPEC-FIX] check-pr: fix phase ordering

**Spec:** [michael-conrad/.opencode#1266](https://github.com/michael-conrad/.opencode/issues/1266)
**Goal:** Reorder 6 phases in `check-pr.md` to fix workflow ordering defect (submodule cleanup before parent, depth-first iteration, dirty-pointer admonishment)
**Architecture:** Single file change to `.opencode/skills/git-workflow/tasks/check-pr.md` in the opencode-config repo
**Tech Stack:** Markdown task file (no code changes)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1: RED — Write Enforcement Tests

**Concern:** Test infrastructure — write content-verification tests for SC-1..7 and behavioral test for SC-8 before any implementation. This phase establishes the failure baseline (RED) that GREEN phase must resolve.
**Files:** `.opencode/tests/test-enforcement.sh`, `.opencode/tests/behaviors/` (new scenario)
**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1266, "phase": 1, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1266, "phase": 1, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1266, "phase": 1, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1266, "phase": 1, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1266, "phase": 1, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G6: checkpoint-commit | inline | N/A | N/A | — | SC-1..8 |

### Concern Boundary Annotations

**Prior scope:** None (first phase)
**Entering:** Test creation — content-verification tests for SC-1..7 (string evidence), behavioral test for SC-8 (behavioral evidence)
**Handoff to Phase 2:** RED test artifacts at `./tmp/1266/artifacts/red-test-results-*.yaml` with FAIL status for all SCs

### RED Phase Details

**RED condition (what must be false before GREEN):** The current `check-pr.md` has the wrong phase ordering (Phase 3 = branch cleanup, Phase 4 = close issues, Phase 5 = submodule reconciliation). Content-verification tests for SC-1..7 MUST FAIL against the current file. Behavioral test for SC-8 MUST FAIL (agent does not produce correct depth-first ordering).

**Test items:**

1. **SC-1 content-verification test:** Assert that Phase 3 in `check-pr.md` is NOT "Close Linked Issues" (currently it's "Clean Up Branches"). Command: `grep -c "Phase 3: Close Linked Issues" .opencode/skills/git-workflow/tasks/check-pr.md` — must return 0 (FAIL in RED phase).
2. **SC-2 content-verification test:** Assert that Phase 4 is NOT "Submodule Branch Cleanup" (currently it's "Close Linked Issues"). Command: `grep -c "Phase 4: Submodule Branch Cleanup" .opencode/skills/git-workflow/tasks/check-pr.md` — must return 0.
3. **SC-3 content-verification test:** Assert Phase 4 does NOT contain submodule iteration steps. Command: `grep -c "submodule" .opencode/skills/git-workflow/tasks/check-pr.md | head -5` — current Phase 5 has submodule content but Phase 4 does not.
4. **SC-4 content-verification test:** Assert Phase 5 is NOT "Parent Branch Cleanup" (currently it's "Submodule Reconciliation"). Command: `grep -c "Phase 5: Parent Branch Cleanup" .opencode/skills/git-workflow/tasks/check-pr.md` — must return 0.
5. **SC-5 content-verification test:** Assert Phase 6 does NOT iterate depth-first. Command: `grep -c "depth-first" .opencode/skills/git-workflow/tasks/check-pr.md` — must return 0.
6. **SC-6 content-verification test:** Assert Phase 6 does NOT contain dirty-pointer admonishment. Command: `grep -c "dirty" .opencode/skills/git-workflow/tasks/check-pr.md` — must return 0.
7. **SC-7 content-verification test:** Assert Phase 3 does NOT close issues cross-repo depth-first. Command: `grep -c "cross-repo" .opencode/skills/git-workflow/tasks/check-pr.md` — must return 0.
8. **SC-8 behavioral test:** Write a behavioral test scenario at `.opencode/tests/behaviors/check-pr-phase-ordering.sh` that sends a "check prs" prompt and verifies the agent does NOT produce correct depth-first cleanup ordering. Must FAIL in RED phase.

## Phase 2: GREEN — Reorder check-pr.md

**Concern:** Implementation — reorder the 6 phases in `check-pr.md` to match the spec's revised ordering, add depth-first iteration, and include dirty-pointer admonishment.
**Files:** `.opencode/skills/git-workflow/tasks/check-pr.md`
**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |
| G3: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |
| G4: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |
| G5: checkpoint-commit | inline | N/A | N/A | — | SC-1..7 |
| G6: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |
| G7: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |
| G8: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |
| G9: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |
| G10: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |
| G11: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |
| G12: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |
| G13: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1266, "phase": 2, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..7 |

### Concern Boundary Annotations

**Prior scope:** RED test infrastructure (Phase 1)
**Entering:** File modification — reorder `check-pr.md` phases to match spec
**Handoff from Phase 1:** RED test artifacts proving all SCs currently FAIL against the unmodified file

### GREEN Phase Details

**GREEN condition (what must be true when done):** The `check-pr.md` file has the correct 6-phase ordering matching the spec's revised structure. Content-verification tests for SC-1..7 MUST PASS. Behavioral test for SC-8 MUST PASS.

**File changes to `.opencode/skills/git-workflow/tasks/check-pr.md`:**

1. **Phase 3: Close Linked Issues** — Move current Phase 4 content to Phase 3 position. Close issues depth-first: sub-repos first, then parent. Close cross-repo (sub-repos before parent repo).
2. **Phase 4: Submodule Branch Cleanup** — Move current Phase 5 content to Phase 4 position. Iterate submodules: switch to dev, delete branches, delete checkpoint tags, prune.
3. **Phase 5: Parent Branch Cleanup** — Move current Phase 3 content to Phase 5 position. Parent repo only: switch to dev, delete branches, delete checkpoint tags, prune.
4. **Phase 6: Depth-First Final State** — Rewrite current Phase 6 to iterate ALL discovered repos depth-first (submodule tips, then parent tip). Each repo gets branch-aware parking. Include explicit admonishment: "Submodule pointers in the parent repo are dirty by design. They are restored during the next pre-work cycle (submodule-tag-prework). Do NOT commit, reset, or otherwise correct them."

**Exit criteria:** All 7 content-verification tests PASS. Behavioral test for SC-8 PASS.

## Phase 3: REFACTOR — Verify and Clean Up

**Concern:** Post-implementation cleanup — verify all tests pass, update cross-references, ensure consistency.
**Files:** `.opencode/skills/git-workflow/tasks/check-pr.md`, `.opencode/tests/`
**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G3: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G4: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G5: checkpoint-commit | inline | N/A | N/A | — | SC-1..8 |
| G6: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G7: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G8: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G9: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G10: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G11: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G12: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |
| G13: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1266, "phase": 3, "owner": "michael-conrad", "repo": "opencode-config"}` | SC-1..8 |

### Concern Boundary Annotations

**Prior scope:** File modification (Phase 2)
**Entering:** Verification and cleanup — run full test suite, verify no regressions, update cross-references
**Handoff from Phase 2:** Modified `check-pr.md` with correct phase ordering

### REFACTOR Details

1. Run all content-verification tests: `bash .opencode/tests/test-enforcement.sh --tag check-pr` — all MUST PASS
2. Run behavioral test: `bash .opencode/tests/behaviors/check-pr-phase-ordering.sh` — MUST PASS
3. Verify no regressions in existing enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`
4. Update any cross-references in other files that reference the old phase ordering
5. Verify the spec's SC-8 behavioral test passes with clean-room execution

## SC-to-Phase Mapping

| SC | Phase | Evidence Type | Verification Method |
|----|-------|---------------|---------------------|
| SC-1 | Phase 2 (GREEN) | string | `grep -c "Phase 3: Close Linked Issues" check-pr.md` — must return > 0 |
| SC-2 | Phase 2 (GREEN) | string | `grep -c "Phase 4: Submodule Branch Cleanup" check-pr.md` — must return > 0 |
| SC-3 | Phase 2 (GREEN) | string | `grep -c "submodule" check-pr.md` — Phase 4 section must contain dev switch, branch delete, tag delete, prune |
| SC-4 | Phase 2 (GREEN) | string | `grep -c "Phase 5: Parent Branch Cleanup" check-pr.md` — must return > 0 |
| SC-5 | Phase 2 (GREEN) | string | `grep -c "depth-first" check-pr.md` — must return > 0 |
| SC-6 | Phase 2 (GREEN) | string | `grep -c "dirty" check-pr.md` — must return > 0, must contain admonishment text |
| SC-7 | Phase 2 (GREEN) | string | `grep -c "cross-repo" check-pr.md` — must return > 0 |
| SC-8 | Phase 2 (GREEN) | behavioral | `opencode-cli run` with "check prs" prompt — verify correct depth-first ordering |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- [ ] Plan stored at `.issues/1266/plan.md`
- [ ] All 3 phases defined with dispatch tables, concern boundaries, and SC mappings
- [ ] RED phase produces FAIL for all 8 SCs against current `check-pr.md`
- [ ] GREEN phase reorders `check-pr.md` to match spec
- [ ] REFACTOR phase verifies all tests PASS
- [ ] Approval cascade: `for_pr` scope → auto-approved
