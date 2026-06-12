# Execution Checklist — #1110 Pipeline-Readiness Gate

## Phase DAG
```
Phase 1 (root)
├─ Phase 2 (depends on Phase 1)
├─ Phase 3 (depends on Phase 1)
└─ Phase 4 (depends on Phase 1, Phase 2, Phase 3)
```

Each pipeline step below maps to one dispatch from the 14-step table.
Each step has 7 sub-steps: pre-cleanup → dispatch → Z3 state → checkpoint tag → lifecycle → verify → remediate.

---

## STEP 1: sc-coherence-gate
Dispatches to: `adversarial-audit --task coherence-extraction`
- [x] Dispatch sub-agent: coherence extraction
- [x] Z3 state update (previous_step→init, current_step→sc-coherence-gate, pipeline_state→running)
- [x] Checkpoint tag: `opencode-config/checkpoint/1110/phase-1-opencode`
- [x] Lifecycle manifest event append
- [x] Verify coherence gate PASS

## STEP 2: pre-red-baseline
Dispatches to: `implementation-pipeline --task pre-red-baseline` (bash)
- [x] Create state directory + init solve state
- [x] Write baseline artifact
- [x] Z3 state update (previous_step→sc-coherence-gate, current_step→pre-red-baseline, pipeline_state→running)
- [x] Checkpoint tag: `opencode-config/checkpoint/1110/phase-2-opencode`
- [x] Lifecycle manifest event append

## STEP 3: red-phase
Dispatches to: `test-driven-development --task red` (10 behavioral test scripts)
- [x] Write 10 behavioral test scripts (7 #1110, 3 #1112)
- [x] Push to submodule feature branch `feature/1110-1112-red-phase`
- [x] Z3 state update (previous_step→pre-red-baseline, current_step→red-phase, pipeline_state→running)
- [x] Checkpoint tag: `opencode-config/checkpoint/1110/phase-3-opencode`
- [x] Lifecycle manifest event append

## STEP 4: red-doublecheck
Dispatches to: `verification-before-completion --task verify` (RED-side SC evidence)
- [x] Evaluate all 10 behavioral test outputs
- [x] Per-SC evidence table for RED state
- [x] Z3 state update (previous_step→red-phase, current_step→red-doublecheck, pipeline_state→running)
- [x] Checkpoint tag: `opencode-config/checkpoint/1110/phase-4-opencode`
- [x] Lifecycle manifest event append

## STEP 5: green-phase
Dispatches to: `test-driven-development --task green` (implement write.md + creation.md)
- [x] Extract 2 GREEN files from commit 63447a22
- [x] Verify content: write.md Step 7r, creation.md Step 5
- [x] Z3 state update (previous_step→red-doublecheck, current_step→green-phase, pipeline_state→running)
- [x] Checkpoint tag: `opencode-config/checkpoint/1110/phase-5-opencode`
- [x] Lifecycle manifest event append

## STEP 6: checkpoint-commit
Dispatches to: `git-workflow --task commit-prep`
- [x] Commit 720ef0fe on `feature/1110-1112-red-phase`
- [x] Z3 state update (previous_step→green-phase, current_step→checkpoint-commit, pipeline_state→committed)
- [x] Checkpoint tag: `opencode-config/checkpoint/1110/phase-6-opencode`
- [x] Lifecycle manifest event append

## STEP 7: structural-checks
Dispatches to: `finishing-a-development-branch --task checklist`
- [x] mdformat lint/fix
- [x] Executable permissions on test scripts
- [x] SPDX header verification
- [x] Z3 state update (previous_step→checkpoint-commit, current_step→structural-checks, pipeline_state→running)
- [x] Checkpoint tag: `opencode-config/checkpoint/1110/phase-7-opencode`
- [x] Lifecycle manifest event append

---

## STEP 8: green-doublecheck ⬅️ NEXT
Dispatches to: `verification-before-completion --task verify` (GREEN-side SC evidence)
- [ ] Pre-cleanup: `rm -f ./tmp/1110/artifacts/pipeline-green-doublecheck-*`
- [ ] Dispatch sub-agent: verify GREEN-side SC evidence
- [ ] Z3 state update (3 sequential calls)
- [ ] Checkpoint tag: `opencode-config/checkpoint/1110/phase-8-opencode`
- [ ] Lifecycle manifest event append
- [ ] If FAIL → Remediation routing (read artifact → researcher → re-dispatch)
- [ ] Re-audit if remediation applied

## STEP 9: green-vbc
Dispatches to: `verification-before-completion --task completion`
- [ ] Pre-cleanup: `rm -f ./tmp/1110/artifacts/pipeline-green-vbc-*`
- [ ] Dispatch sub-agent: VbC completion
- [ ] Z3 state update (3 sequential calls)
- [ ] Checkpoint tag: `opencode-config/checkpoint/1110/phase-9-opencode`
- [ ] Lifecycle manifest event append
- [ ] If FAIL → Remediation routing → re-dispatch

## STEP 10: adversarial-audit
Dispatches to: `adversarial-audit --task verification-audit` (dual auditor)
- [ ] Pre-cleanup: `rm -f ./tmp/1110/artifacts/pipeline-adversarial-audit-*`
- [ ] Resolve 2 auditors from different families via `.opencode/tools/resolve-models`
- [ ] Dispatch auditor 1 (clean-room, receives deliverable + SC list only)
- [ ] Dispatch auditor 2 (clean-room, cross-family, receives deliverable + SC list only)
- [ ] Z3 state update (3 sequential calls)
- [ ] Checkpoint tag: `opencode-config/checkpoint/1110/phase-10-opencode`
- [ ] Lifecycle manifest event append
- [ ] If FAIL → Remediation routing → re-audit

## STEP 11: cross-validate
Dispatches to: `adversarial-audit --task cross-validate`
- [ ] Pre-cleanup: `rm -f ./tmp/1110/artifacts/pipeline-cross-validate-*`
- [ ] Dispatch sub-agent: cross-validate findings from both auditors
- [ ] Z3 state update (3 sequential calls)
- [ ] Checkpoint tag: `opencode-config/checkpoint/1110/phase-11-opencode`
- [ ] Lifecycle manifest event append
- [ ] If FAIL → Remediation routing → re-audit

## STEP 12: regression-check
Dispatches to: `test-driven-development --task patterns` (regression)
- [ ] Pre-cleanup: `rm -f ./tmp/1110/artifacts/pipeline-regression-check-*`
- [ ] Dispatch sub-agent: run existing enforcement test suite (tag-filtered)
- [ ] Z3 state update (3 sequential calls)
- [ ] Checkpoint tag: `opencode-config/checkpoint/1110/phase-12-opencode`
- [ ] Lifecycle manifest event append
- [ ] If FAIL → Remediation routing

## STEP 13: review-prep
Dispatches to: `git-workflow --task review-prep`
- [ ] Pre-cleanup: verify working tree clean
- [ ] Dispatch sub-agent: review-prep (PR body, compare URL, branch diff)
- [ ] Z3 state update (3 sequential calls)
- [ ] Checkpoint tag: `opencode-config/checkpoint/1110/phase-13-opencode`
- [ ] Lifecycle manifest event append

## STEP 14: exec-summary
Dispatches to: `completion-core --task completion`
- [ ] Pre-cleanup: verify all prior artifacts present
- [ ] Dispatch sub-agent: push + PR creation + issue comments
- [ ] Z3 state update (3 sequential calls)
- [ ] Final checkpoint tag: `opencode-config/checkpoint/1110/phase-all-opencode`
- [ ] Lifecycle manifest final event append
- [ ] HALT

---

## A. Remediation Routing (R.1-R.10)

| Step | If FAIL at | Remediate by |
|------|-----------|--------------|
| R.1 | sc-coherence-gate | Revise spec/plan for coherence, re-run extraction |
| R.2 | pre-red-baseline | Fix state directory or permissions, re-init |
| R.3 | red-phase | Fix test script, re-run RED |
| R.4 | red-doublecheck | Fix SC evidence evaluation, re-verify |
| R.5 | green-phase | Fix GREEN implementation, re-run tests |
| R.6 | checkpoint-commit | Fix commit message or file issues, recommit |
| R.7 | structural-checks | Fix lint/format/permissions, re-run checks |
| R.8 | green-doublecheck | Fix SC evidence artifacts, re-verify |
| R.9 | green-vbc | Fix completion artifacts, re-run VbC |
| R.10 | adversarial-audit | Fix SC defects found by auditor, re-audit |
| R.11 | cross-validate | Fix disagreements between auditors, re-validate |
| R.12 | regression-check | Fix regression, re-run tests |
| R.13 | review-prep | Fix PR body or diff issues, re-prep |
| R.14 | exec-summary | Fix push/PR/comment, re-exec |

## SC Traceability Summary

| SC-ID | Evidence Type | Phase | Status |
|-------|--------------|-------|--------|
| SC-1 | structural | 1 | ✅ on dev |
| SC-2 | behavioral | 1 | 🔄 timeout remediating |
| SC-3 | behavioral | 1 | ✅ RED verified |
| SC-4 | behavioral | 1 | ✅ RED verified |
| SC-5 | behavioral | 1 | ✅ RED verified |
| SC-6 | string | 1 | ✅ on dev |
| SC-7 | string | 2 | ✅ RED verified |
| SC-8 | behavioral | 2 | ✅ RED verified |
| SC-9 | string | 3 | ✅ GREEN on branch |
| SC-10 | string | 3 | ✅ GREEN on branch |
| SC-11 | behavioral | 3 | ✅ RED verified |
| SC-12 | string | 4 | ✅ on dev |
| SC-13 | behavioral | 4 | ✅ RED verified |