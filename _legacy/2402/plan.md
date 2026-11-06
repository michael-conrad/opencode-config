---
plan_schema_version: 1
issue: 2402
title: "finishing-a-development-branch checklist: agent-owned trailer/byline auto-remediation with scope guard"
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow, git-workflow-pr, completion-core]
---

# Plan: finishing-a-development-branch checklist — agent-owned trailer/byline auto-remediation with scope guard

**Issue:** `.opencode#2402`
**Spec:** `.opencode/.issues/2402/spec.md`

## Goal / Architecture / Files / Dispatch

**Goal:** Reclassify missing Co-authored-by commit trailers and missing "Co-authored with AI:" footer bylines on an agent-created, unmerged, unshared feature branch as agent-owned auto-fixable MISSING-ELEMENTs, add an explicit agent-owned remediation procedure (amend/squash own commits to add trailers, then force-push with `--force-with-lease`), and add a scope guard confining the auto-force-push carve-out to the agent's own unmerged, unshared branch.

**Architecture:** The `finishing-a-development-branch` checklist (`checklist.md`) currently classifies missing trailers as a decision-requiring blocker that surfaces a force-push authorization decision to the developer. The fix reclassifies trailer absence on the agent's own unmerged branch as an auto-fixable MISSING-ELEMENT, adds an explicit agent-owned remediation procedure to `checklist.md` and `prepare.md` (amend/squash own commits to add repo-standard Co-authored-by trailers, then `--force-with-lease` push), auto-fixes missing new-file footer bylines via the producing agent, and adds a scope guard confining the auto-force-push carve-out to the agent's own unmerged, unshared branch. The generic force-push authorization gate (`000-critical-rules.md`) remains in force for all other branches. Four new behavioral test scripts are created as RED-phase deliverables.

**Files:**
- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` — modify (SC-1, SC-2, SC-3, SC-4, SC-5)
- `.opencode/skills/finishing-a-development-branch/tasks/prepare.md` — modify (SC-2, SC-3)
- `.opencode/tests-v2/behaviors/finish-checklist-trailer-agent-own-remediation.sh` — create (SC-1)
- `.opencode/tests-v2/behaviors/finish-trailer-auto-remediation-no-solicitation.sh` — create (SC-2)
- `.opencode/tests-v2/behaviors/finish-footer-byline-auto-fix.sh` — create (SC-3)
- `.opencode/tests-v2/behaviors/finish-forcepush-scope-guard.sh` — create (SC-4, SC-5)

**Dispatch:** `test-driven-development` (RED/GREEN cycles), `verification-before-completion` (verify SCs), `audit` (adversarial audit), `finishing-a-development-branch` (checklist), `git-workflow` (review-prep), `git-workflow-pr` (create PR), `completion-core` (lifecycle event)

## Blast Radius

- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` — "Co-authored-by trailers present" item, Finding Classification table, "AI co-authored attribution in new files" item, remediation procedure, scope guard
- `.opencode/skills/finishing-a-development-branch/tasks/prepare.md` — Step 1 trailer verification, agent-owned remediation procedure, footer byline auto-fix verification step
- `.opencode/tests-v2/behaviors/finish-checklist-trailer-agent-own-remediation.sh` — new behavioral test (SC-1)
- `.opencode/tests-v2/behaviors/finish-trailer-auto-remediation-no-solicitation.sh` — new behavioral test (SC-2)
- `.opencode/tests-v2/behaviors/finish-footer-byline-auto-fix.sh` — new behavioral test (SC-3)
- `.opencode/tests-v2/behaviors/finish-forcepush-scope-guard.sh` — new behavioral test (SC-4, SC-5)
- `.opencode/skills/finishing-a-development-branch/SKILL.md` — read-only authority (agent-owned remediation mandate)
- `.opencode/skills/git-workflow-commit/tasks/commit-prep.md` — read-only authority (trailer format)
- `.opencode/skills/git-workflow-commit/tasks/implementation.md` — read-only authority (checkpoint commits legitimately lack trailers)
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/squash-push.md` — read-only authority (PR-time trailer application)
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` — read-only authority (force-push carve-out precedent)
- `.opencode/guidelines/080-code-standards.md` — read-only authority (mandatory attribution)
- `.opencode/guidelines/000-critical-rules.md` — read-only authority (generic force-push gate)
- `.opencode/tmp/2241-finishing-checklist-evidence.md` — read-only reference (recorded defect instance)

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|-------------|-------|----------|
| 1 | Trailer classification on agent-own branch | trailer-classification | SC-1 | — | 1-4 | test-driven-development |
| 2 | Agent-owned trailer remediation procedure | trailer-remediation | SC-2 | Phase 1 | 5-8 | test-driven-development |
| 3 | Footer byline auto-fix | footer-byline-autofix | SC-3 | — (parallel) | 9-12 | test-driven-development |
| 4 | Agent-own-branch scope guard | scope-guard | SC-4, SC-5 | Phase 2 | 13-17 | test-driven-development |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1: All 4 phases complete with PASS
- [ ] C2: `checklist.md` classifies missing trailers on an agent-own unmerged branch as an auto-fixable MISSING-ELEMENT, not a decision-requiring blocker
- [ ] C3: `checklist.md` and `prepare.md` include an agent-owned remediation procedure (amend/squash + `--force-with-lease`) that does not solicit a developer force-push decision
- [ ] C4: `checklist.md` auto-fixes missing "Co-authored with AI:" footer bylines in new files, preserving existing bylines
- [ ] C5: `checklist.md` includes a scope guard confining auto-force-push to the agent's own unmerged, unshared branch
- [ ] C6: The scope guard refuses auto-force-push on shared/merged/trunk branches and defers to the generic force-push authorization gate
- [ ] C7: All four behavioral test scripts created and passing
- [ ] C8: All SCs verified via verification-before-completion
- [ ] C9: Audit confirms plan executed faithfully against spec
- [ ] C10: Cross-validation confirms audit and verification agree
- [ ] C11: PR created with all changes

## Pre-Implementation Steps

- [ ] **Coherence gate.** Verify spec/plan coherence before RED routing. Read the spec at `.opencode/.issues/2402/spec.md` and confirm the plan matches the spec's phase structure, SC assignments, and dependency ordering. If any mismatch is found, return BLOCKED with `COHERENCE_FAIL`.
  - (**inline**)

- [ ] **Baseline check.** Verify the current state of all affected files before modification. Read each file listed in the blast radius and confirm the content matches the "before" state described in the spec. If any file has already been modified, return BLOCKED with `BASELINE_CHANGED`.
  - (**inline**)

---

## Phase 1 — Trailer classification on agent-own branch

**Concern:** trailer-classification
**Files:** `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`, `.opencode/tests-v2/behaviors/finish-checklist-trailer-agent-own-remediation.sh` (new)
**SCs:** SC-1
**Dependencies:** None
**Entry:** Coherence gate and baseline check passed
**Exit:** `checklist.md` classifies missing Co-authored-by trailers on an agent-own unmerged branch as an auto-fixable MISSING-ELEMENT, not a decision-requiring blocker

**Cost frame:** Running the behavioral trailer-classification test costs minutes of execution time. Skipping means the checklist keeps mis-classifying trailer absence as a decision-requiring blocker, forcing an unnecessary developer round-trip on every affected branch — surfacing as a behavioral defect at 1000× the fix cost.

### Code Path Coverage

- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` — "Co-authored-by trailers present" item and Finding Classification table
- `.opencode/tests-v2/behaviors/finish-checklist-trailer-agent-own-remediation.sh` — new behavioral test (SC-1)

### Cross-Cutting SCs

- SC-1 (classification) is the routing precondition for SC-2 (remediation). Both touch `checklist.md` and share the trailer-classification concern boundary.

### Interface Boundaries

- `checklist.md` → `prepare.md`: SC-1 routes trailer absence to auto-fix in `checklist.md`; `prepare.md` carries the remediation procedure. Both must agree on the MISSING-ELEMENT classification.
- `checklist.md` → `080-code-standards.md`: trailer auto-fix adds missing attribution; it never skips or weakens the mandatory co-author attribution checks (R-7).
- `checklist.md` → `commit-prep.md`: the auto-fix reuses the repo-standard Co-authored-by trailer format; no new trailer schema is introduced.

### State Transitions

- Before: `branch_complete_but_trailer_missing` → decision-requiring blocker (developer force-push decision solicited)
- After: `branch_complete_but_trailer_missing` → `trailer_remediated_by_agent` (checklist classifies trailer absence on agent-own unmerged branch as auto-fixable MISSING-ELEMENT)

### Item 1 — Reclassify missing trailers on agent-own branch as auto-fixable MISSING-ELEMENT

- [ ] **RED.** Write a behavioral enforcement test at `.opencode/tests-v2/behaviors/finish-checklist-trailer-agent-own-remediation.sh` that sends a real-domain finishing-checklist prompt to the agent and verifies the agent does NOT solicit a developer force-push authorization decision and DOES route trailer absence to agent-owned auto-remediation. The test MUST fail at this point because the checklist currently flags trailer absence as a decision-requiring blocker.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`:
  - Update the "Co-authored-by trailers present" checklist item so that trailer absence on an agent-created, unmerged, unshared feature branch is classified as an auto-fixable MISSING-ELEMENT (remediation) rather than a decision-requiring blocker.
  - Update the Finding Classification table so trailer absence on an agent-own branch routes to auto-fix, not to a developer force-push authorization decision.
  - The reclassification must not weaken the mandatory co-author attribution requirement (R-7) — the auto-fix adds missing trailers, never skips the check.
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass now. Verify the change matches the spec's SC-1 requirements: run `.opencode/tests-v2/behaviors/finish-checklist-trailer-agent-own-remediation.sh` via `bash .opencode/tests-v2/with-test-home opencode run '<message>'` and confirm the agent does NOT solicit a developer force-push authorization decision and DOES route trailer absence to agent-owned auto-remediation.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes to `checklist.md` and the new behavioral test.
  - (**inline**) `git add .opencode/skills/finishing-a-development-branch/tasks/checklist.md .opencode/tests-v2/behaviors/finish-checklist-trailer-agent-own-remediation.sh && git commit -m "Phase 1: Reclassify missing trailers on agent-own branch as auto-fixable MISSING-ELEMENT"`

### Phase Completion

- [ ] VbC: Verify SC-1 — behavioral test passes; agent does NOT solicit a developer force-push decision and DOES route trailer absence to agent-owned auto-remediation
- [ ] Concern transition: Complete. Proceed to Phase 2 (agent-owned trailer remediation procedure).

---

## Phase 2 — Agent-owned trailer remediation procedure

**Concern:** trailer-remediation
**Files:** `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`, `.opencode/skills/finishing-a-development-branch/tasks/prepare.md`, `.opencode/tests-v2/behaviors/finish-trailer-auto-remediation-no-solicitation.sh` (new)
**SCs:** SC-2
**Dependencies:** Phase 1 complete
**Entry:** Phase 1 committed
**Exit:** `checklist.md` and `prepare.md` include an explicit agent-owned remediation procedure (amend/squash own commits to add repo-standard Co-authored-by trailers, then `--force-with-lease` push) that does not solicit a developer force-push decision

**Cost frame:** Running the behavioral auto-remediation test costs minutes of execution time. Skipping means agents keep stalling on a developer force-push decision instead of self-remediating, surfacing as a behavioral defect at 1000× the fix cost.

### Code Path Coverage

- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` — remediation procedure
- `.opencode/skills/finishing-a-development-branch/tasks/prepare.md` — Step 1 trailer verification, remediation procedure
- `.opencode/tests-v2/behaviors/finish-trailer-auto-remediation-no-solicitation.sh` — new behavioral test (SC-2)

### Cross-Cutting SCs

- SC-2 (remediation procedure) is confined by the SC-4/SC-5 scope guard. The remediation procedure and the guard both live in `checklist.md`.

### Interface Boundaries

- `checklist.md` → `prepare.md`: both must agree on the MISSING-ELEMENT classification and the `--force-with-lease` remediation.
- `checklist.md` → `create-pr.md`: the auto-force-push carve-out reuses the existing sanctioned `--force-with-lease` mechanism and the "Step 7.2.3: Rebase on Stale Base" precedent. No new force-push mechanism.
- `checklist.md` → `squash-push.md`: trailer auto-fix at finishing complements, rather than replaces, the PR-time squash that applies repo-standard trailers.
- `checklist.md` → `implementation.md`: trailer-free WIP implementation commits remain permitted; finishing-time remediation is clarified, not a change to checkpoint commit policy.

### State Transitions

- Before: `branch_complete_but_trailer_missing` → developer force-push decision solicited
- After: `branch_complete_but_trailer_missing` → `trailer_remediated_by_agent` (agent amends/squashes own commits to add Co-authored-by trailers, then force-pushes with `--force-with-lease`) → `branch_ready_for_pr` (no developer force-push decision solicited)

### Item 2 — Add agent-owned trailer remediation procedure

- [ ] **RED.** Write a behavioral enforcement test at `.opencode/tests-v2/behaviors/finish-trailer-auto-remediation-no-solicitation.sh` that sends a real-domain finishing-checklist prompt to the agent and verifies the agent adds trailers via amendment/squash and force-pushes with `--force-with-lease`, and does NOT present a force-push authorization question to the developer. The test MUST fail at this point because no remediation procedure exists.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` and `.opencode/skills/finishing-a-development-branch/tasks/prepare.md`:
  - Add an explicit agent-owned remediation procedure to `checklist.md` describing amend or squash of the agent's own commits to add repo-standard Co-authored-by trailers, then force-push the agent's own branch with `--force-with-lease`, without soliciting a developer force-push decision.
  - Add the corresponding remediation procedure to `prepare.md` Step 1 (verify co-authored-by trailers present), so the producing agent self-remediates trailer absence on its own unmerged branch.
  - The remediation MUST use `--force-with-lease` only; `--force` is forbidden (R-4).
  - The remediation MUST reuse the repo-standard two-trailer format from `commit-prep.md`; no alternative trailer schema is introduced.
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass now. Verify the change matches the spec's SC-2 requirements: run `.opencode/tests-v2/behaviors/finish-trailer-auto-remediation-no-solicitation.sh` via `bash .opencode/tests-v2/with-test-home opencode run '<message>'` and confirm the agent adds trailers via amendment/squash and force-pushes with `--force-with-lease`, and does NOT present a force-push authorization question to the developer.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes to `checklist.md`, `prepare.md`, and the new behavioral test.
  - (**inline**) `git add .opencode/skills/finishing-a-development-branch/tasks/checklist.md .opencode/skills/finishing-a-development-branch/tasks/prepare.md .opencode/tests-v2/behaviors/finish-trailer-auto-remediation-no-solicitation.sh && git commit -m "Phase 2: Add agent-owned trailer remediation procedure"`

### Phase Completion

- [ ] VbC: Verify SC-2 — behavioral test passes; agent adds trailers via amendment/squash and force-pushes with `--force-with-lease`, no developer force-push question
- [ ] Concern transition: Complete. Proceed to Phase 4 (agent-own-branch scope guard). Phase 3 (footer byline auto-fix) is independent and may run in parallel.

---

## Phase 3 — Footer byline auto-fix

**Concern:** footer-byline-autofix
**Files:** `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`, `.opencode/skills/finishing-a-development-branch/tasks/prepare.md`, `.opencode/tests-v2/behaviors/finish-footer-byline-auto-fix.sh` (new)
**SCs:** SC-3
**Dependencies:** None (parallel — independent of Phase 1/Phase 2)
**Entry:** Coherence gate and baseline check passed
**Exit:** `checklist.md` auto-fixes missing "Co-authored with AI:" footer bylines in new files via the producing agent, preserving existing bylines

**Cost frame:** Running the behavioral byline-auto-fix test costs minutes of execution time. Skipping means missing footer bylines keep being escalated as blockers instead of fixed by the producing agent, surfacing as a behavioral defect at 1000× the fix cost.

### Code Path Coverage

- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` — "AI co-authored attribution in new files" item
- `.opencode/skills/finishing-a-development-branch/tasks/prepare.md` — footer byline auto-fix verification step
- `.opencode/tests-v2/behaviors/finish-footer-byline-auto-fix.sh` — new behavioral test (SC-3)

### Cross-Cutting SCs

- SC-3 (footer byline auto-fix) is independent of commit trailer remediation (SC-1/SC-2) and the scope guard (SC-4/SC-5); may run in parallel.

### Interface Boundaries

- `checklist.md` → `080-code-standards.md`: footer byline auto-fix adds missing attribution; it never skips or weakens the mandatory co-author attribution checks (R-7).
- `checklist.md` → `prepare.md`: both must agree on the footer byline auto-fix behavior and the preserve-existing-bylines rule.

### State Transitions

- Before: `new_file_missing_footer_byline` → escalated as decision-requiring blocker
- After: `new_file_missing_footer_byline` → `new_file_footer_byline_present` (producing agent auto-fixes missing "Co-authored with AI:" footer byline, preserving existing bylines)

### Item 3 — Auto-fix missing new-file footer bylines

- [ ] **RED.** Write a behavioral enforcement test at `.opencode/tests-v2/behaviors/finish-footer-byline-auto-fix.sh` that sends a real-domain finishing-checklist prompt to the agent and verifies the producing agent adds the missing footer byline and does not escalate to the developer. The test MUST fail at this point because byline absence is escalated.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` and `.opencode/skills/finishing-a-development-branch/tasks/prepare.md`:
  - Update the "AI co-authored attribution in new files" checklist item so the producing agent auto-fixes missing "Co-authored with AI:" footer bylines rather than escalating as a decision-requiring blocker.
  - Update the corresponding prepare verification step so the producing agent adds missing footer bylines, preserving any existing bylines.
  - The auto-fix MUST preserve existing bylines (R-5) and MUST NOT weaken the mandatory co-author attribution requirement (R-7).
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass now. Verify the change matches the spec's SC-3 requirements: run `.opencode/tests-v2/behaviors/finish-footer-byline-auto-fix.sh` via `bash .opencode/tests-v2/with-test-home opencode run '<message>'` and confirm the producing agent adds the missing footer byline and does not escalate to the developer.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes to `checklist.md`, `prepare.md`, and the new behavioral test.
  - (**inline**) `git add .opencode/skills/finishing-a-development-branch/tasks/checklist.md .opencode/skills/finishing-a-development-branch/tasks/prepare.md .opencode/tests-v2/behaviors/finish-footer-byline-auto-fix.sh && git commit -m "Phase 3: Auto-fix missing new-file footer bylines"`

### Phase Completion

- [ ] VbC: Verify SC-3 — behavioral test passes; producing agent adds the missing footer byline and does not escalate to the developer
- [ ] Concern transition: Complete. Proceed to Post-Implementation Steps (Phase 3 is independent and complete).

---

## Phase 4 — Agent-own-branch scope guard

**Concern:** scope-guard
**Files:** `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`, `.opencode/tests-v2/behaviors/finish-forcepush-scope-guard.sh` (new)
**SCs:** SC-4, SC-5
**Dependencies:** Phase 2 complete
**Entry:** Phase 2 committed
**Exit:** `checklist.md` includes a scope guard confining the auto-force-push carve-out to the agent's own unmerged, unshared branch; the guard refuses auto-force-push on shared/merged/trunk branches and defers to the generic force-push authorization gate

**Cost frame:** Running the scope-guard structural test costs seconds of execution time; running the behavioral scope-guard test costs minutes. Skipping means the agent-own-branch confinement could be lost without detection, and the auto-force-push carve-out on shared/merged/trunk branches remains undetected — a critical violation surfacing at 1000× the fix cost.

### Code Path Coverage

- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` — remediation procedure scope guard
- `.opencode/tests-v2/behaviors/finish-forcepush-scope-guard.sh` — new behavioral test (SC-5) and structural guard assertion (SC-4)

### Cross-Cutting SCs

- SC-4 (structural scope guard) is a companion to SC-2 (remediation) and SC-5 (behavioral refusal). The guard confines the remediation added for SC-2.
- SC-5 (behavioral refusal on shared/merged/trunk) is the behavioral companion to SC-4 and confines the SC-2 remediation carve-out.

### Interface Boundaries

- `checklist.md` → `000-critical-rules.md`: the scope guard confines the auto-force-push carve-out to the agent's own unmerged, unshared branch; shared/merged/trunk branches defer to the generic force-push authorization gate. No weakening of the generic gate.

### State Transitions

- Before: `branch_agent_own_unmerged_unshared` → auto-force-push not confined; `branch_shared_or_merged_or_trunk` → auto-force-push not refused
- After: `branch_agent_own_unmerged_unshared` → `auto_force_push_permitted` (scope guard confirms agent-own, unmerged, unshared branch); `branch_shared_or_merged_or_trunk` → `generic_force_push_gate` (scope guard refuses auto-force-push and defers to generic force-push authorization gate)

### Item 4a — Add agent-own-branch scope guard (SC-4)

- [ ] **RED.** Write a structural test assertion in `.opencode/tests-v2/behaviors/finish-forcepush-scope-guard.sh` that greps the checklist remediation procedure for a stated agent-own-branch scope guard. The test MUST fail at this point because no guard exists.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`:
  - Add a scope guard to the remediation procedure confining auto-force-push to the agent's own, unmerged, unshared feature branch.
  - The scope guard MUST state that on a shared, merged, or trunk branch, the checklist SHALL refuse auto-force-push and defer to the generic force-push authorization gate (R-6).
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass now. Verify the change matches the spec's SC-4 requirements: grep the checklist remediation procedure for the stated agent-own-branch scope guard.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes to `checklist.md` and the new behavioral test.
  - (**inline**) `git add .opencode/skills/finishing-a-development-branch/tasks/checklist.md .opencode/tests-v2/behaviors/finish-forcepush-scope-guard.sh && git commit -m "Phase 4: Add agent-own-branch scope guard"`

### Item 4b — Refuse auto-force-push on shared/merged/trunk branch (SC-5)

- [ ] **RED.** Write a behavioral enforcement test in `.opencode/tests-v2/behaviors/finish-forcepush-scope-guard.sh` that sends a real-domain finishing-checklist prompt to the agent and verifies the agent refuses to auto-force-push on a shared/merged/trunk branch and defers to the generic authorization gate. The test MUST fail at this point because no guard exists.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Confirm the scope guard added in Item 4a refuses auto-force-push on a shared, merged, or trunk branch and defers to the generic force-push authorization gate. If the guard text does not already cover the behavioral refusal, update `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` so the guard explicitly refuses auto-force-push on shared/merged/trunk branches.
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass now. Verify the change matches the spec's SC-5 requirements: run `.opencode/tests-v2/behaviors/finish-forcepush-scope-guard.sh` via `bash .opencode/tests-v2/with-test-home opencode run '<message>'` and confirm the agent refuses to auto-force-push on a shared/merged/trunk branch and defers to the generic authorization gate.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit any changes to `checklist.md` and the behavioral test.
  - (**inline**) `git add .opencode/skills/finishing-a-development-branch/tasks/checklist.md .opencode/tests-v2/behaviors/finish-forcepush-scope-guard.sh && git commit -m "Phase 4: Refuse auto-force-push on shared/merged/trunk branch"`

### Phase Completion

- [ ] VbC: Verify SC-4 — grep the checklist remediation procedure for the stated agent-own-branch scope guard
- [ ] VbC: Verify SC-5 — behavioral test passes; agent refuses to auto-force-push on a shared/merged/trunk branch and defers to the generic authorization gate
- [ ] Concern transition: Complete. Proceed to Post-Implementation Steps.

---

## Post-Implementation Steps

- [ ] **Structural checks.** Run the finishing checklist to verify all changes are complete and consistent.
  - (**clean-room**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`

- [ ] **Verification.** Run verification-before-completion against all 5 SCs. Produce evidence artifacts for each SC. If any SC FAILs, return BLOCKED with the failing SC IDs.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Audit.** Dispatch the audit skill to verify the plan was executed faithfully against the spec.
  - (**clean-room**) `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`

- [ ] **Cross-validate.** Cross-validate the audit findings against the verification evidence.
  - (**clean-room**) `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`

- [ ] **Review prep.** Prepare the PR for review with a summary of all changes.
  - (**clean-room**) `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`

- [ ] **Create PR.** Create the pull request with the completed changes.
  - (**clean-room**) `task(..., prompt: "execute create task from git-workflow-pr")`

- [ ] **Completion.** Append lifecycle event and report executive summary.
  - (**clean-room**) `task(..., prompt: "execute completion task from completion-core")`

## Lifecycle Events

| Timestamp | Event | Phase Count | Plan Path |
|-----------|-------|-------------|-----------|
| 2026-09-01T04:23:28Z | plan_created | 4 | `.opencode/.issues/2402/plan.md` |
