---
plan_schema_version: 1
issue: 2431
title: "Stacked-PR ordering gate: parent PR must wait for submodule PR merges"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 5
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Implementation Plan — #2431 — Stacked-PR ordering gate: parent PR must wait for submodule PR merges

**Issue:** https://github.com/michael-conrad/.opencode/issues/2431

## Goal

Add a three-condition ordering gate to the stacked-PR procedure, evaluated immediately before parent stacked PR creation and hosted as exactly one authoritative blocking check in `pr-creation/enforcement-gate`: in-scope submodule set enumeration, live-API merge-state verification with bounded retry and fail-closed inconclusive handling, pointer freshness assertions, pointers-ride-alongside timing with idle waiting behavior, and per-submodule blocking-reason reporting. Designate the authoritative site and annotate the three non-selected sites as advisory/consistency.

## Architecture

The ordering gate extends the existing enforcement-gate card (Step 0 reachability gates from #2313 and the Submodule-Bump-Only PR Gate remain unchanged and coexist). Condition 1 enumerates the in-scope submodule set from changed submodule paths relative to the trunk base, then verifies each in-scope submodule PR's merge state via a live platform API using the merge-state fields — never inferred from local checkout state or `git merge-base` ancestry — with a bounded retry (up to 3 probes at 60-second intervals) that blocks on inconclusive state. Condition 2 commits submodule pointer bumps on the parent feature branch after merges land (pointers-ride-alongside) while the parent branch sits idle. Condition 3 asserts clean `git submodule status` (no `+` prefix) for in-scope submodules and pointer-SHA ancestry against `origin/$DEFAULT_BRANCH` dynamically resolved per submodule. Every block reports which in-scope submodule blocks it across four categories (unmerged PR, inconclusive state, stale pointer, `+`-prefixed working tree), naming the submodule and its PR. The gate is fail-closed on inconclusive state while the #2313 reachability gates remain fail-open on network error — the card keeps the two policies explicitly separated. Behavioral evidence for the three blocking SCs follows the two-SC pattern: artifact-only generator scripts plus clean-room evaluation of `session.yaml`. Enforcement placement designates `pr-creation/enforcement-gate` as the sole authoritative blocking check; the three non-selected sites carry advisory/consistency annotations with no blocking authority.

## Files

- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` — authoritative site; ordering-gate step, assertions, timing rule, waiting behavior, four-category reporting, designation statement
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` — Pre-Push Submodule Pointer Verification cross-reference for timing alignment (SC-5)
- `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md` — advisory/consistency annotation (SC-9)
- `.opencode/skills/git-workflow-pr/tasks/post-implementation.md` — advisory/consistency annotation (SC-9)
- `.opencode/tests-v2/AGENTS.md` — behavioral-suite role annotation for the ordering gate (SC-9)
- `.opencode/tests-v2/behaviors/2431-sc1-unmerged-submodule-pr-blocks.sh` (new) with `fixtures/issues/2431/` and `fixtures/setup/` provisioning (SC-1)
- `.opencode/tests-v2/behaviors/2431-sc6-plus-prefix-submodule-blocks.sh` (new) with per-scenario fixture provisioning (SC-6)
- `.opencode/tests-v2/behaviors/2431-sc7-pointer-absent-from-trunk-blocks.sh` (new) with per-scenario fixture provisioning (SC-7)

## Dispatch

Every item runs the per-task cycle from the implementation-workflow reference card: RED, GREEN, post-regression, and verify dispatch task cards; commit-inline executes directly in the orchestrator context.

- `test-driven-development` — red, green, post-regression (phase-0 pre-regression and phase-4 regression tasks) for every item
- `verification-before-completion` — verify task per item, pre-regression-verify, pre-pr-gate
- `audit` — post-implementation adversarial audit (DiMo investigator, then validator, evaluator, arbiter in sequence)
- `finishing-a-development-branch` — structural checklist
- `git-workflow-pr` — review-prep and PR creation
- `completion-core` — completion executive summary
- Orchestrator-direct steps: coherence gate, baseline check, every commit-inline, z3-check

## Blast Radius

Affected files and impact zones (from the blast-radius artifact):

- **Phase 1 (spec-scope phase 1, implementation phases 1–4):** edit task-card prose in `pr-creation/enforcement-gate.md` and `pr-creation.md`; create three behavioral test scripts with fixture provisioning. Ripple: stacked-PR pipeline halts before parent PR creation while any in-scope submodule PR is unmerged; #2313 Step 0 reachability gates unchanged; parent branches idle during the wait; behavioral suite grows by three scenarios requiring merge-state fixture provisioning. Risk: live-API verification can false-block when platform merge-state lags — bounded retry absorbs transient lag and the block names the submodule PR.
- **Phase 5 (spec-scope phase 2):** designation statement in the authoritative card; advisory annotations at `pre-commit-pointer-check.md`, `post-implementation.md`, and the tests-v2 behavioral-suite role documentation. Risk: low — annotations are additive card text; the designation consolidates rather than relocates blocking authority.
- **No ripple:** SKIP_STALE_POINTER_CHECK commit-time semantics unchanged; human merge behavior untouched; single-repo PR flows unchanged (gate skips with no in-scope set); submodule PR lifecycle automation out of scope; #2313 fail-open reachability policy unchanged.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

Verification coercions (from the implementation-workflow reference card): a DONE_WITH_CONCERNS verdict coerces to FAIL for pipeline gate purposes, and EVIDENCE_TYPE_MISMATCH is a hard FAIL — structural or string evidence for a behavioral SC, or behavioral evidence declared for a string SC, blocks the gate.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| Pre | Pre-implementation (global) — coherence gate, baseline check, pre-regression, pre-regression-verify | — | — | — | 1–4 | direct (1–2) + task-card (3–4) |
| 1 | In-scope enumeration and live-API merge-state verification | Merge-state verification (Condition 1), including in-scope set enumeration | SC-2, SC-1, SC-3, SC-4 | — | 5–24 | task-card (red/green/post-regression/verify) + direct (commit) |
| 2 | Pointer freshness assertions | Pointer freshness assertions (Condition 3) | SC-6, SC-7 | 1 | 25–34 | task-card (red/green/post-regression/verify) + direct (commit) |
| 3 | Pointers-ride-alongside timing and waiting behavior | Pointers-ride-alongside timing and waiting behavior (Condition 2) | SC-5, SC-11 | 1 | 35–44 | task-card (red/green/post-regression/verify) + direct (commit) |
| 4 | Per-submodule blocking-reason reporting | Blocking-reason reporting | SC-10 | 1, 2 | 45–49 | task-card (red/green/post-regression/verify) + direct (commit) |
| 5 | Enforcement placement — designation and advisory annotations | Enforcement placement (authoritative vs advisory) | SC-8, SC-9 | 1, 2, 3, 4 | 50–59 | task-card (red/green/post-regression/verify) + direct (commit) |
| Post | Post-implementation (global) — audit, z3-check, structural checks, pre-PR gate, regression check, review-prep, PR creation, completion | — | all | 1–5 | 60–67 | mixed (see steps) |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

1. C1. SC-1 through SC-11 each verified PASS with evidence matching its declared type (string greps, behavioral `session.yaml` clean-room evaluations, semantic clean-room judgments)
2. C2. Every item committed as one atomic slice (test + change together) with the daisy chain intact — no batching, no combined commits
3. C3. The ordering gate language is complete in `pr-creation/enforcement-gate.md`: enumeration before merge verification, live-API verification with the never-inferred prohibition, bounded retry and inconclusive block, both freshness assertions, timing rule, waiting behavior, four-category reporting, and the sole-authoritative designation
4. C4. Advisory/consistency annotations present at `pre-commit-pointer-check.md`, `post-implementation.md`, and the tests-v2 behavioral-suite role documentation, each with no blocking authority
5. C5. Behavioral scripts follow the artifact-only generator paradigm (exit 0, no evaluation) with `fixtures/issues/2431/` and per-scenario `fixtures/setup/` provisioning present before any run
6. C6. Structural checks pass (markdown lint/format on all changed cards)
7. C7. Pre-PR gate confirms all SC verdicts PASS with the coercion rules applied
8. C8. PR created per stacked strategy — one branch, squashed commits, targeting the trunk

---

# Pre-Implementation (Global)

**Cost frame:** Running the coherence gate and baseline check costs minutes each — the plan is structurally valid against the spec and the tree starts from the trunk tip. Skipping costs days — a spec-plan divergence or stale base branch contaminates every downstream item and surfaces as rework at the first FAIL.

- [ ] 1. (**direct**) coherence gate — spec/plan coherence check
  - Re-read the spec Success Criteria and Requirements against this plan's phase table and exit criteria; confirm every SC maps to exactly one item, evidence types match the spec table, and the DAG is acyclic
  - Any incoherence halts the plan for remediation before item work begins
- [ ] 2. (**direct**) baseline check
  - Verify the working tree is clean, the feature branch is current with the trunk tip, and submodule state matches the committed pointer (`git submodule status` shows no `+` prefix)
  - Any deviation halts before the first item's RED
- [ ] 3. (**task-card**) pre-regression
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-pre-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - Runs the regression test patterns before the first RED phase
- [ ] 4. (**task-card**) pre-regression-verify
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-pre-regression-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verifies the pre-regression results; FAIL halts before Phase 1

---

# Phase 1 — In-scope enumeration and live-API merge-state verification

| Field | Value |
|-------|-------|
| Concern | Merge-state verification (Condition 1) — includes in-scope set enumeration per the concern-map reconciliation |
| Files | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md`; `.opencode/tests-v2/behaviors/` (new SC-1 script + fixtures) |
| SCs | SC-2, SC-1, SC-3, SC-4 |
| Dependencies | none |
| Entry condition | Pre-implementation steps (coherence gate, baseline check, pre-regression, pre-regression-verify) complete; feature branch current; working tree clean |
| Exit condition | Enumeration precedes merge verification in the card; live-API verification and bounded-retry language present; SC-2, SC-1, SC-3, SC-4 verified and committed |

## Code Path Coverage

- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` — new ordering-gate step evaluated immediately before parent stacked PR creation, alongside the existing Step 0 (submodule reachability) and Step 0.5 (bump-only gate); carries in-scope enumeration, live-API merge-state verification with bounded retry, and the never-inferred prohibition
- `.opencode/tests-v2/behaviors/` — new artifact-only generator script for SC-1 with `fixtures/issues/2431/` and per-scenario `fixtures/setup/` provisioning using `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`

## Cross-Cutting SCs

- Fail-closed vs fail-open semantics boundary — the ordering gate is fail-closed on inconclusive state; the #2313 reachability gates in the same card are fail-open on network error; card text keeps the two policies explicitly separated
- Ancestry vs merge-state distinction — the gate runs both an ancestry assertion and live-API merge-state verification; they are not interchangeable and carry separate failure categories (stale pointer vs unmerged PR)
- Behavioral evidence infrastructure coupling — the SC-1 script depends on multi-submodule provisioning and the two-SC pattern; the bounded-retry parameters are stated in the card as text verified by grep (the behavioral test does not execute the retry loop)
- Skip semantics for out-of-scope repos — no submodules or no changed submodule pointers means no in-scope set; the skip is explicit, not a silent pass

## Interface Boundaries

- Enforcement-gate Step 0 result contract — modified, backward compatible; existing PASS/FAIL/SKIP semantics unchanged; merge-state and inconclusive categories added as new report fields
- pr-creation task routing — modified, backward compatible; the ordering gate evaluates inside the existing enforcement-gate call with no routing changes; BLOCKED-with-wait-reason re-attempts after merges land

## State Transitions

- Parent stacked PR creation gate decision state: from "gate not present — parent PR created regardless of merge state" to "gate present — creation blocked while any in-scope submodule PR is unmerged or inconclusive or pointers fail freshness" (items 1, 3, 4)
- In-scope submodule set: from "undefined coverage" to "enumerated set — changed submodule paths relative to the trunk base"; enumeration precedes merge verification (item 2)

**Cost frame:** Grepping the enumeration, live-API, and bounded-retry language costs seconds and running the SC-1 behavioral test costs minutes of execution time — coverage is defined, merge state is verified against reality, and inconclusive state resolves to a definite block. Skipping costs days-to-weeks — the gate silently covers the wrong submodule set or infers merge state from ancestry, re-creating the #304 unmergeable parent PR discovered at review or merge time.

## Step-by-step

**Item 2 (SC-2) — In-scope submodule set enumeration (evidence: string)**

- [ ] 5. (**task-card**) RED for item-2 (SC-2)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-red-*`
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED condition: a grep of the authoritative task card for in-scope-set enumeration language (changed submodule paths relative to the trunk base) returns no match — the enumeration requirement does not exist yet, so the test fails
  - Record the failing grep artifact under `tmp/2431/artifacts/`
- [ ] 6. (**task-card**) GREEN for item-2 (SC-2)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-green-*`
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN condition: the ordering gate in the enforcement-gate card documents the in-scope-set enumeration from changed submodule paths relative to the trunk base, positioned before merge verification; minimum change only — no scope creep
  - Target: Read [the enforcement-gate card](.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md) before editing
- [ ] 7. (**task-card**) post-regression for item-2 (SC-2)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-post-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 8. (**task-card**) verify for item-2 (SC-2)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: the grep for enumeration language passes; evidence type string
- [ ] 9. (**direct**) commit item-2
  - `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md && git commit -m "Add in-scope submodule set enumeration to ordering gate (SC-2)"`
  - No co-author trailers during implementation commits — those are added during squash at PR time

**Item 1 (SC-1) — Ordering gate blocks parent PR creation on unmerged in-scope submodule PR (evidence: behavioral)**

- [ ] 10. (**task-card**) RED for item-1 (SC-1)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-red-*`
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED condition: the behavioral enforcement test fails — the scenario reaches parent stacked PR creation with one in-scope submodule PR open and the gate does not block, so a parent PR would be created
  - Create the artifact-only generator script `.opencode/tests-v2/behaviors/2431-sc1-unmerged-submodule-pr-blocks.sh` (exit 0, no evaluation), with `fixtures/issues/2431/` (spec and plan copies) and per-scenario `fixtures/setup/2431-sc1-unmerged-submodule-pr-blocks.sh` provisioning using `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`
  - Run via `with-test-home` with the bash tool timeout at 600000ms or more; the clean-room evaluation of the generated `session.yaml` shows no blocking evidence, which is the RED failure
- [ ] 11. (**task-card**) GREEN for item-1 (SC-1)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-green-*`
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN condition: the merge-state blocking condition is implemented in the ordering gate so an unmerged in-scope submodule PR blocks parent stacked PR creation; re-run only the named scenario after the change
- [ ] 12. (**task-card**) post-regression for item-1 (SC-1)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-post-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 13. (**task-card**) verify for item-1 (SC-1)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: clean-room sub-agent reads `session.yaml` from the GREEN artifact directory and judges that the gate blocks and no parent PR is created; evidence type behavioral; EVIDENCE_TYPE_MISMATCH is a hard FAIL
- [ ] 14. (**direct**) commit item-1
  - `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md .opencode/tests-v2/behaviors/2431-sc1-unmerged-submodule-pr-blocks.sh .opencode/tests-v2/behaviors/fixtures/issues/2431/ .opencode/tests-v2/behaviors/fixtures/setup/2431-sc1-unmerged-submodule-pr-blocks.sh && git commit -m "Add merge-state blocking to ordering gate with behavioral test (SC-1)"`
  - Test and implementation committed as one atomic slice

**Item 3 (SC-3) — Live-API merge-state verification, no local/ancestry inference (evidence: string)**

- [ ] 15. (**task-card**) RED for item-3 (SC-3)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-red-*`
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED condition: a grep for live-API merge-state verification language and for the prohibition on inferring merge state from local checkout state or `git merge-base` ancestry returns no match — the test fails
  - Record the failing grep artifact under `tmp/2431/artifacts/`
- [ ] 16. (**task-card**) GREEN for item-3 (SC-3)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-green-*`
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN condition: the ordering gate verifies each in-scope submodule PR's merge state via a live platform API call using the merge-state fields, with the explicit never-inferred-from-local-state-or-ancestry rule; minimum change only
- [ ] 17. (**task-card**) post-regression for item-3 (SC-3)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-post-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 18. (**task-card**) verify for item-3 (SC-3)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: the grep for live-API language and the prohibition passes; evidence type string
- [ ] 19. (**direct**) commit item-3
  - `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md && git commit -m "Add live-API merge-state verification with no-inference rule (SC-3)"`

**Item 4 (SC-4) — Bounded retry and inconclusive-block parameters (evidence: string)**

- [ ] 20. (**task-card**) RED for item-4 (SC-4)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-red-*`
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED condition: a grep for the bounded-retry parameters (up to 3 probes at 60-second intervals) and the chat-reported inconclusive block naming the inconclusive submodule and its PR returns no match — the test fails
  - Record the failing grep artifact under `tmp/2431/artifacts/`
- [ ] 21. (**task-card**) GREEN for item-4 (SC-4)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-green-*`
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN condition: the bounded retry/report path is present — up to 3 probes at 60-second intervals, then block with a clear reason reported in chat naming the inconclusive submodule and its PR; the retry parameters are card text verified by grep (no behavioral script executes the retry loop); minimum change only
- [ ] 22. (**task-card**) post-regression for item-4 (SC-4)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-post-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 23. (**task-card**) verify for item-4 (SC-4)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: the grep for the retry parameters and report destination passes; evidence type string
- [ ] 24. (**direct**) commit item-4
  - `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md && git commit -m "Add bounded retry and inconclusive-block reporting to ordering gate (SC-4)"`

## Phase Completion Block

- All four phase SCs (SC-2, SC-1, SC-3, SC-4) verified PASS with evidence matching declared types
- Enumeration language precedes merge verification in the card, per the state-analysis invariant
- Commits are atomic per item; daisy chain intact (item-2 commit preceded item-1 RED, and so on)

**Concern transition:** merge-state verification complete — proceed to Phase 2 for pointer freshness assertions.

---

# Phase 2 — Pointer freshness assertions

| Field | Value |
|-------|-------|
| Concern | Pointer freshness assertions (Condition 3) |
| Files | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md`; `.opencode/tests-v2/behaviors/` (new SC-6 and SC-7 scripts + fixtures) |
| SCs | SC-6, SC-7 |
| Dependencies | Phase 1 |
| Entry condition | Phase 1 complete; in-scope set enumeration exists in the card |
| Exit condition | Both freshness assertions present in the card; SC-6 and SC-7 verified behaviorally and committed |

## Code Path Coverage

- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` — ordering-gate assertions: the clean `git submodule status` assertion (no `+` prefix for in-scope submodules) and the pointer-SHA ancestry assertion against `origin/$DEFAULT_BRANCH` dynamically resolved per submodule, both blocking PR creation on failure
- `.opencode/tests-v2/behaviors/` — new artifact-only generator scripts for SC-6 and SC-7 with per-scenario `fixtures/setup/` provisioning using `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`

## Cross-Cutting SCs

- Ancestry vs merge-state distinction — the ancestry assertion and the live-API merge-state verification remain separate conditions with separate failure categories (stale pointer vs unmerged PR)
- Behavioral evidence infrastructure coupling — both scripts depend on multi-submodule provisioning, the two-SC pattern, and a bash tool timeout of 600000ms or more
- #2313 convention alignment — ancestry is asserted against `origin/$DEFAULT_BRANCH` dynamically resolved per submodule, never a hardcoded trunk name

## Interface Boundaries

- Enforcement-gate Step 0 result contract — modified, backward compatible; the stale-pointer and `+`-prefixed-working-tree categories join the per-submodule report fields without altering existing PASS/FAIL/SKIP semantics
- tests-v2 behavioral suite surface — modified, backward compatible; new scripts follow the two-SC pattern with no changes to harness helpers

## State Transitions

- Parent stacked PR creation gate decision state: creation blocked when an in-scope submodule shows a `+`-prefixed working tree (item 6) or when an in-scope recorded pointer SHA is absent from `origin/$DEFAULT_BRANCH` (item 7); PR creation proceeds only when both assertions pass

**Cost frame:** Running the two freshness behavioral tests costs minutes of execution time — working-tree divergence and unreachable pointers are caught at the gate. Skipping costs weeks — a parent PR tree resolving divergent or nonexistent submodule content ships and breaks downstream builds, the failure mode #2313 documented.

## Step-by-step

**Item 6 (SC-6) — No-`+`-prefix assertion blocks (evidence: behavioral)**

- [ ] 25. (**task-card**) RED for item-6 (SC-6)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-red-*`
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED condition: the behavioral enforcement test fails — the scenario reaches parent stacked PR creation with a `+`-prefixed in-scope submodule and the gate does not block
  - Create the artifact-only generator script `.opencode/tests-v2/behaviors/2431-sc6-plus-prefix-submodule-blocks.sh` (exit 0, no evaluation), with per-scenario `fixtures/setup/2431-sc6-plus-prefix-submodule-blocks.sh` provisioning using `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`
  - Run via `with-test-home` with the bash tool timeout at 600000ms or more; the clean-room evaluation of the generated `session.yaml` shows no blocking evidence, which is the RED failure
- [ ] 26. (**task-card**) GREEN for item-6 (SC-6)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-green-*`
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN condition: the clean `git submodule status` assertion for in-scope submodules is implemented in the ordering gate and blocks parent PR creation on a `+` prefix; re-run only the named scenario after the change
- [ ] 27. (**task-card**) post-regression for item-6 (SC-6)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-post-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 28. (**task-card**) verify for item-6 (SC-6)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: clean-room sub-agent reads `session.yaml` from the GREEN artifact directory and judges that the gate blocks; evidence type behavioral
- [ ] 29. (**direct**) commit item-6
  - `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md .opencode/tests-v2/behaviors/2431-sc6-plus-prefix-submodule-blocks.sh .opencode/tests-v2/behaviors/fixtures/setup/2431-sc6-plus-prefix-submodule-blocks.sh && git commit -m "Add no-plus-prefix freshness assertion to ordering gate (SC-6)"`

**Item 7 (SC-7) — Pointer-SHA ancestry assertion blocks (evidence: behavioral)**

- [ ] 30. (**task-card**) RED for item-7 (SC-7)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-red-*`
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED condition: the behavioral enforcement test fails — the scenario reaches parent stacked PR creation with an in-scope pointer referencing a commit absent from `origin/$DEFAULT_BRANCH` and the gate does not block
  - Create the artifact-only generator script `.opencode/tests-v2/behaviors/2431-sc7-pointer-absent-from-trunk-blocks.sh` (exit 0, no evaluation), with per-scenario `fixtures/setup/2431-sc7-pointer-absent-from-trunk-blocks.sh` provisioning using `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`
  - Run via `with-test-home` with the bash tool timeout at 600000ms or more; the clean-room evaluation of the generated `session.yaml` shows no blocking evidence, which is the RED failure
- [ ] 31. (**task-card**) GREEN for item-7 (SC-7)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-green-*`
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN condition: the ancestry assertion against `origin/$DEFAULT_BRANCH` (dynamically resolved per submodule) is implemented for in-scope pointers and blocks parent PR creation when the recorded SHA is absent from the remote trunk; re-run only the named scenario after the change
- [ ] 32. (**task-card**) post-regression for item-7 (SC-7)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-post-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 33. (**task-card**) verify for item-7 (SC-7)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: clean-room sub-agent reads `session.yaml` from the GREEN artifact directory and judges that the gate blocks; evidence type behavioral
- [ ] 34. (**direct**) commit item-7
  - `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md .opencode/tests-v2/behaviors/2431-sc7-pointer-absent-from-trunk-blocks.sh .opencode/tests-v2/behaviors/fixtures/setup/2431-sc7-pointer-absent-from-trunk-blocks.sh && git commit -m "Add pointer-ancestry assertion against remote trunk to ordering gate (SC-7)"`

## Phase Completion Block

- SC-6 and SC-7 verified PASS with clean-room behavioral evidence
- Both assertions block PR creation with per-submodule reporting hooks consistent with the result contract
- Commits atomic per item; daisy chain intact

**Concern transition:** freshness assertions complete — proceed to Phase 3 for the pointers-ride-alongside timing rule and waiting behavior.

---

# Phase 3 — Pointers-ride-alongside timing and waiting behavior

| Field | Value |
|-------|-------|
| Concern | Pointers-ride-alongside timing and waiting behavior (Condition 2) |
| Files | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md`; `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` (Pre-Push Submodule Pointer Verification cross-reference) |
| SCs | SC-5, SC-11 |
| Dependencies | Phase 1 |
| Entry condition | Phase 1 complete; gate merge-state conditions present |
| Exit condition | Timing rule and waiting-behavior language present in both cards; SC-5 and SC-11 verified and committed |

## Code Path Coverage

- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` — ordering-gate timing rule: pointer bumps committed on the parent feature branch after the submodule merges land so the parent PR's squashed commit carries fresh pointers; waiting statement: the parent branch sits idle with no new commits, pushes, or PR mutations until all in-scope submodule PRs land
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` — Pre-Push Submodule Pointer Verification section gains an additive cross-reference aligning its timing language with the ordering gate

## Cross-Cutting SCs

- Pointers-ride-alongside convention coherence — the timing rule stays consistent with `pr-creation.md` (Pre-Push Submodule Pointer Verification), `pre-commit-pointer-check.md`, and the Submodule-Bump-Only PR Gate in the same enforcement-gate card; pointer bumps are never standalone and never committed before merges land for in-scope submodules
- Waiting behavior vs branch-activity invariants — idle means no mutations until verification passes at the next PR-creation attempt, not an indefinite freeze; the bounded retry race (submodule PR merges while probing) is absorbed by the next probe

## Interface Boundaries

- pr-creation.md Pre-Push Submodule Pointer Verification language — modified, backward compatible; additive cross-reference only, no removal of existing staging-verification steps

## State Transitions

- Pointer bump timing: from "pointer bumps committed before merges land" to "committed on the parent feature branch after the submodule merges land"; SKIP_STALE_POINTER_CHECK commit-time semantics unchanged (item 5)
- Parent branch waiting state: from "waiting with undefined behavior" to "idle wait — no new commits, pushes, or PR mutations until all in-scope submodule PRs land"; the gate re-evaluates branch state at the next PR-creation attempt (item 11)

**Cost frame:** Grepping the timing-rule and waiting-behavior language costs seconds — pointer bumps land after merges and the parent branch idles deterministically during the wait. Skipping costs days — pointers committed before merges re-create the stale-pointer parent PR, and undefined waiting behavior invites mid-wait commits or PR mutations that invalidate the gate's verification at PR creation.

## Step-by-step

**Item 5 (SC-5) — Pointers-ride-alongside timing rule in the authoritative card (evidence: string)**

- [ ] 35. (**task-card**) RED for item-5 (SC-5)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-red-*`
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED condition: a grep for the pointers-ride-alongside rule requiring pointer bumps committed after merges land returns no match in the authoritative card — the test fails
  - Record the failing grep artifact under `tmp/2431/artifacts/`
- [ ] 36. (**task-card**) GREEN for item-5 (SC-5)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-green-*`
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN condition: the timing rule is present — pointer bumps committed on the parent feature branch after merges land, so the squashed commit carries fresh pointers — with an additive cross-reference in the pr-creation card's Pre-Push Submodule Pointer Verification section aligning timing language; minimum change only
  - Targets: Read [the enforcement-gate card](.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md) and Read [the pr-creation card](.opencode/skills/git-workflow-pr/tasks/pr-creation.md) before editing
- [ ] 37. (**task-card**) post-regression for item-5 (SC-5)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-post-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 38. (**task-card**) verify for item-5 (SC-5)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: the grep for the timing rule passes; evidence type string
- [ ] 39. (**direct**) commit item-5
  - `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md .opencode/skills/git-workflow-pr/tasks/pr-creation.md && git commit -m "Add pointers-ride-alongside timing rule to ordering gate (SC-5)"`

**Item 11 (SC-11) — Waiting behavior — parent branch sits idle (evidence: string)**

- [ ] 40. (**task-card**) RED for item-11 (SC-11)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-red-*`
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED condition: a grep for waiting-behavior language (parent branch sits idle; no commits, pushes, or PR mutations until submodule PRs land) returns no match — the test fails
  - Record the failing grep artifact under `tmp/2431/artifacts/`
- [ ] 41. (**task-card**) GREEN for item-11 (SC-11)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-green-*`
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN condition: the waiting-behavior statement is present — the parent branch sits idle with no new commits, pushes, or PR mutations until all in-scope submodule PRs land; minimum change only
- [ ] 42. (**task-card**) post-regression for item-11 (SC-11)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-post-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 43. (**task-card**) verify for item-11 (SC-11)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: the grep for the waiting-behavior language passes; evidence type string
- [ ] 44. (**direct**) commit item-11
  - `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md && git commit -m "Add idle waiting behavior to ordering gate (SC-11)"`

## Phase Completion Block

- SC-5 and SC-11 verified PASS with string evidence
- Timing language coherent across the enforcement-gate card and the pr-creation card
- Commits atomic per item; daisy chain intact

**Concern transition:** timing and waiting behavior complete — proceed to Phase 4 for per-submodule blocking-reason reporting.

---

# Phase 4 — Per-submodule blocking-reason reporting

| Field | Value |
|-------|-------|
| Concern | Blocking-reason reporting |
| Files | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` (result contract) |
| SCs | SC-10 |
| Dependencies | Phase 1, Phase 2 |
| Entry condition | Phases 1 and 2 complete; merge-state and freshness categories exist as gate conditions |
| Exit condition | Four-category per-submodule blocking-reason reporting present in the result contract; SC-10 verified and committed |

## Code Path Coverage

- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` — result contract gains per-submodule blocking-reason reporting covering the four categories (unmerged PR, inconclusive state, stale pointer, `+`-prefixed working tree), each naming the submodule and its PR; mixed states enumerate every pending or inconclusive submodule

## Cross-Cutting SCs

- Ancestry vs merge-state distinction — stale pointer and unmerged PR remain separate report categories so the remedy (merge vs wait vs pointer bump vs working-tree sync) is unambiguous

## Interface Boundaries

- Enforcement-gate Step 0 result contract — modified, backward compatible; new status values/report fields added without altering existing PASS/FAIL/SKIP semantics; the #2313 SUBMODULE_PR_MISSING failure code is unchanged and the ordering gate adds merge-state and inconclusive codes

## State Transitions

- Per-submodule blocking report: from "bare or ambiguous block" to "categorized per-submodule report naming the submodule and its PR"; every block names the blocking submodule and its category

**Cost frame:** Grepping the four-category reporting language costs seconds — every block names the submodule and its PR. Skipping costs hours — a bare block with no reason sends the developer hunting across submodule repos for what is pending.

## Step-by-step

**Item 10 (SC-10) — Per-submodule blocking-reason reporting (evidence: string)**

- [ ] 45. (**task-card**) RED for item-10 (SC-10)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-red-*`
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED condition: a grep for per-submodule blocking-reason reporting covering the four categories (unmerged PR, inconclusive state, stale pointer, `+`-prefixed working tree) returns no match — the test fails
  - Record the failing grep artifact under `tmp/2431/artifacts/`
- [ ] 46. (**task-card**) GREEN for item-10 (SC-10)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-green-*`
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN condition: the four-category per-submodule blocking-reason reporting is present in the result contract, naming the submodule and its PR for every block; minimum change only
- [ ] 47. (**task-card**) post-regression for item-10 (SC-10)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-post-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 48. (**task-card**) verify for item-10 (SC-10)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: the grep for the four blocking-reason categories passes; evidence type string
- [ ] 49. (**direct**) commit item-10
  - `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md && git commit -m "Add four-category per-submodule blocking-reason reporting (SC-10)"`

## Phase Completion Block

- SC-10 verified PASS with string evidence
- Every gate block category (unmerged PR, inconclusive state, stale pointer, `+`-prefixed working tree) names the submodule and its PR
- Commit atomic; daisy chain intact

**Concern transition:** blocking-reason reporting complete — proceed to Phase 5 for enforcement placement designation and advisory annotations.

---

# Phase 5 — Enforcement placement — designation and advisory annotations

| Field | Value |
|-------|-------|
| Concern | Enforcement placement (authoritative vs advisory) |
| Files | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` (designation); `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md`; `.opencode/skills/git-workflow-pr/tasks/post-implementation.md`; `.opencode/tests-v2/AGENTS.md` (behavioral-suite role annotation) |
| SCs | SC-8, SC-9 |
| Dependencies | Phase 1, Phase 2, Phase 3, Phase 4 |
| Entry condition | Phases 1–4 complete; complete gate language exists in the authoritative card |
| Exit condition | Exactly one authoritative blocking check designated; three non-selected sites annotated advisory/consistency; SC-8 and SC-9 verified by clean-room judgment and committed |

## Code Path Coverage

- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` — designation statement: the ordering gate is the sole authoritative blocking check for stacked-PR ordering across the four candidate enforcement sites, per the spec's placement evaluation and published selection criteria (every-path coverage, post-commit execution, existing blocking authority, fail-closed capability)
- `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md` — advisory/consistency annotation: runs pre-commit before merges can be verified, commits legally proceed under SKIP_STALE_POINTER_CHECK, no blocking authority
- `.opencode/skills/git-workflow-pr/tasks/post-implementation.md` — advisory/consistency annotation: runs only on the standard executing-plans path, pushes branches without PR-creation authority, no blocking authority
- `.opencode/tests-v2/AGENTS.md` — behavioral-suite role annotation: the ordering-gate behavioral tests are the behavioral-evidence instrument with no runtime blocking authority

## Cross-Cutting SCs

- Pointers-ride-alongside convention coherence — the designation and annotations reference the timing rule without contradicting the convention documented across the four cards
- Fail-closed vs fail-open semantics boundary — the designation text keeps the authoritative gate's fail-closed merge-state policy separate from the #2313 fail-open reachability policy

## Interface Boundaries

- pre-commit-pointer-check task role — modified, backward compatible; existing staging-hygiene behavior and SKIP_STALE_POINTER_CHECK escape hatch unchanged
- post-implementation task role — modified, backward compatible; push-without-PR behavior and HALT-for-developer-review flow unchanged
- tests-v2 behavioral suite surface — modified, backward compatible; the suite's role annotation is additive

## State Transitions

- Enforcement authority assignment: from "undesignated placement — four candidate sites, no published selection criteria" to "exactly one authoritative blocking check at pr-creation/enforcement-gate; three sites annotated advisory/consistency"; non-selected sites cannot contradict the authoritative gate

**Cost frame:** Dispatching the two clean-room semantic judgments costs minutes — exactly one site owns blocking authority, so gate failures have one diagnosable owner and non-selected sites cannot contradict it. Skipping costs days — conflicting or duplicated blocking checks produce contradictory pass/block outcomes, and a rogue blocking check at an advisory site blocks legitimate PRs with no authoritative basis.

## Step-by-step

**Item 8 (SC-8) — Authoritative site designation (evidence: semantic)**

- [ ] 50. (**task-card**) RED for item-8 (SC-8)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-red-*`
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED condition: a clean-room sub-agent reads the four enforcement sites and cannot identify exactly one designated authoritative blocking check — the judgment fails because the designation does not exist yet
- [ ] 51. (**task-card**) GREEN for item-8 (SC-8)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-green-*`
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN condition: the enforcement-gate card designates the ordering gate as the sole authoritative blocking site per the spec's placement evaluation and selection criteria; minimum change only
- [ ] 52. (**task-card**) post-regression for item-8 (SC-8)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-post-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 53. (**task-card**) verify for item-8 (SC-8)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: a clean-room sub-agent re-reads the four sites and judges that exactly one authoritative blocking check is assigned; evidence type semantic
- [ ] 54. (**direct**) commit item-8
  - `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md && git commit -m "Designate ordering gate as sole authoritative blocking check (SC-8)"`

**Item 9 (SC-9) — Advisory roles at the three non-selected sites (evidence: semantic)**

- [ ] 55. (**task-card**) RED for item-9 (SC-9)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-red-*`
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - RED condition: a clean-room sub-agent reads the three non-selected sites and finds blocking authority or a missing advisory annotation — the judgment fails because the annotations do not exist yet
- [ ] 56. (**task-card**) GREEN for item-9 (SC-9)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-green-*`
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - GREEN condition: advisory/consistency annotations present at all three sites — the pre-commit-pointer-check card, the post-implementation card, and the tests-v2 behavioral-suite role documentation — each stating no blocking authority for the ordering gate; minimum change only
- [ ] 57. (**task-card**) post-regression for item-9 (SC-9)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-post-regression-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 58. (**task-card**) verify for item-9 (SC-9)
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-verify-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify: a clean-room sub-agent re-reads the three sites and judges that each is advisory/consistency only with no blocking authority; evidence type semantic
- [ ] 59. (**direct**) commit item-9
  - `git add .opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md .opencode/skills/git-workflow-pr/tasks/post-implementation.md .opencode/tests-v2/AGENTS.md && git commit -m "Annotate three non-selected enforcement sites as advisory (SC-9)"`

## Phase Completion Block

- SC-8 and SC-9 verified PASS with clean-room semantic judgments
- The designation statement and all three advisory annotations are present and mutually consistent
- Commits atomic per item; daisy chain intact

---

# Post-Implementation (Global)

**Cost frame:** Running the audit, structural checks, pre-PR gate, and final regression costs minutes each — verdicts are confirmed against evidence before the PR exists. Skipping costs weeks — a coerced or mismatched verdict ships in the PR and surfaces at review or merge time as an unmergeable or defective branch.

- [ ] 60. (**task-card**) audit of the deliverable
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-audit-*`
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
  - The adversarial audit covers all eleven SC deliverables; findings route through the self-remediation protocol before the pre-PR gate
- [ ] 61. (**direct**) z3-check of the phase state
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-z3-check-*`
  - Run `./.opencode/tools/solve check --state-path .opencode/.issues/2431/artifacts/state-analysis.yaml --contract-path .opencode/.issues/2431/dependency-contract.yaml`
  - A non-SAT result halts the plan pending remediation
- [ ] 62. (**task-card**) structural checks
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-structural-checks-*`
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Covers lint/format on all changed markdown cards; linters run read-only (report only, no auto-modify)
- [ ] 63. (**task-card**) pre-PR gate
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-pre-pr-gate-*`
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Reads all SC verdicts and BLOCKs if any FAIL; coercion rules apply (DONE_WITH_CONCERNS coerces to FAIL; EVIDENCE_TYPE_MISMATCH is a hard FAIL)
- [ ] 64. (**task-card**) final regression check
  - Pre-cleanup: `rm -f tmp/2431/artifacts/pipeline-regression-check-*`
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 65. (**task-card**) review-prep
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
- [ ] 66. (**task-card**) create PR
  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`
  - Stacked strategy: one branch, squash to exactly one commit per issue at PR creation, targeting the trunk; HALT after PR creation — the merge is human-only
- [ ] 67. (**task-card**) completion executive summary
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`
  - Report once after all phases and post-implementation steps complete; HALT at the end

---

## lifecycle_events

- event: plan_created
  timestamp: 2026-09-05T00:43:45Z
  plan_file: .opencode/.issues/2431/plan.md
  phase_count: 7

---

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)*