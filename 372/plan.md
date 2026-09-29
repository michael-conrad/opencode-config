---
plan_schema_version: 1
issue: 372
title: "Add repo-scope qualifier to root AGENTS.md Test Framework Discipline"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
dispatch:
  - phase: phase-1
    items: ITEM-1..ITEM-4
    red: test-driven-development/red
    green: test-driven-development/green
    verify: verification-before-completion/verify
    commit: orchestrator/commit-inline
  - phase: phase-2
    items: ITEM-5
    verify: verification-before-completion/verify
---

# Implementation Plan — Root AGENTS.md Test Framework Discipline repo-scope qualifier

- **Issue:** .issues/372/spec.md (remote mirror: https://github.com/michael-conrad/opencode-config/issues/372)

## Goal

Insert an explicit repo-scope qualifier into root `AGENTS.md` § Test Framework Discipline so that the canonical `.opencode` test framework mandate applies to `.opencode`-targeted (submodule) work only, root-repo work uses `tests/behaviors/*.sh` as its test instrument with a SHALL NOT prohibition on touching the `.opencode` submodule or its test framework, and the change touches only root `AGENTS.md`.

## Architecture

Text-only edit to one section of one file (root `AGENTS.md`). No runtime code. Phase 1 inserts the four qualifier statements (SC-1..SC-4) via per-SC RED/GREEN content-presence cycles. Phase 2 verifies commit scope containment via `git diff --stat` (SC-5).

## Files

- `AGENTS.md` (root, § Test Framework Discipline) — the only file modified

## Dispatch

- Phase 1: direct (pre-implementation 1-4, commit-inline steps) + task-card (red/green/verify task steps 5-24)
- Phase 2: direct (verification steps) + task-card (verify sub-agent step)

## Blast Radius

- Affected files: root `AGENTS.md` only (§ Test Framework Discipline)
- Impact zones: agent-facing text; no runtime code, no test framework changes, no submodule changes
- Prohibited: any modification under `.opencode/` (out-of-scope guard R-4; the post/pre enforcement regression runs of `bash .opencode/tests-v2/test-enforcement.sh` are authorized read-run verification invocations, not modifications)

## Admonishments

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Enforcement Gate

ALL of the following MUST hold or the SC set is FAIL — no partial PASS, no advisory:

1. SC-1 verified by string evidence: repo-scope qualifier distinguishing `.opencode`-targeted work from root-repo work present in the section.
2. SC-2 verified by string evidence: framework-applicability statement present.
3. SC-3 verified by string evidence: `tests/behaviors/*.sh` named as root-repo test instrument.
4. SC-4 verified by string evidence: SHALL NOT submodule-prohibition statement present.
5. SC-5 verified by structural evidence: `git diff --stat <base>..HEAD` shows exactly one changed path (root `AGENTS.md`), zero `.opencode/` paths.
6. Enforcement regression gate: `bash .opencode/tests-v2/test-enforcement.sh` run BEFORE and AFTER the AGENTS.md edit; if the suite regresses, the SC set is FAIL regardless of string/structural evidence.

## Pre-implementation Steps

- [ ] 1. Run the coherence gate. (**direct**)
  - Re-read `.issues/372/spec.md` SC table and the structure artifact `.issues/372/artifacts/structure.yaml`
  - Confirm plan items map one-to-one to SCs (ITEM-1→SC-1 … ITEM-5→SC-5) with no multi-SC item
- [ ] 2. Run the baseline check. (**direct**)
  - Verify parent repo is on the feature branch for this issue with zero pending changes; record the base commit for the SC-5 diff check
  - Run the BEFORE enforcement regression: `bash .opencode/tests-v2/test-enforcement.sh` and record the pass/fail result
- [ ] 3. Capture the RED baseline for the whole plan. (**direct**)
  - `read` root `AGENTS.md` § Test Framework Discipline and record that all four qualifier elements (SC-1..SC-4) are currently absent
- [ ] 4. Report baseline status `[pre-implementation] [PASS|FAIL]`. (**direct**)

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | Insert repo-scope qualifier statements into AGENTS.md § Test Framework Discipline | Agent-facing text edit — single-section qualifier content | SC-1, SC-2, SC-3, SC-4 | none | 5-22 | task-card (red/green/verify) + direct (commit-inline, post-regression, completion) |
| 2 | Verify commit scope containment | Structural diff verification | SC-5 | 1 | 23-31 | task-card (verify, audit, pre-pr-gate, review-prep, create-pr) + direct (diff check, summary) |

## Post-implementation Steps (end of Phase 2)

- [ ] 28. Run the adversarial audit. (**task-card**) — `task(subagent_type: general, prompt: "execute verification-audit DiMo investigator from audit. Read audit/tasks/verification-audit-investigator.md first")` followed by validator, evaluator, arbiter in sequence
  - Audit target: the AGENTS.md qualifier text and commit scope vs. SC-1..SC-5
- [ ] 29. Run the pre-PR gate. (**task-card**) — `task(subagent_type: general, prompt: "execute verify task from verification-before-completion")`
  - Reads all SC verdicts (SC-1..SC-5); BLOCKs if any FAIL
- [ ] 30. Prepare PR review context and create the PR. (**task-card**)
  - `task(subagent_type: general, prompt: "execute review-prep from git-workflow-pr. Read git-workflow-pr/tasks/review-prep.md first")`, then `task(subagent_type: general, prompt: "execute create task from git-workflow-pr")` — squash to exactly one commit at PR creation
  - Report `[PR] [PASS|FAIL]` and halt (human-only merge)
- [ ] 31. Generate the completion executive summary. (**task-card**) — `task(subagent_type: general, prompt: "execute completion task from completion-core")`

## Self-Remediation

(covered by the Self-Remediation Protocol admonishment above)

## Exit Criteria

- C1: SC-1..SC-4 each verified by string evidence (`read` of root `AGENTS.md` § Test Framework Discipline) with the four qualifier elements present in the section.
- C2: SC-5 verified by structural evidence (`git diff --stat <base>..HEAD` shows exactly one changed path, root `AGENTS.md`; zero `.opencode/` paths).
- C3: `bash .opencode/tests-v2/test-enforcement.sh` run before and after the edit with matching (non-regressed) results.
- C4: Existing non-waivable rules in § Test Framework Discipline preserved verbatim; no text outside the section changed.
- C5: All completion verdicts PASS; no FAIL verdict remains unremediated.

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

# Phase 1 — Insert repo-scope qualifier statements into AGENTS.md § Test Framework Discipline

- **Concern:** Agent-facing text edit — single-section qualifier content (SC-1..SC-4)
- **Files:** `AGENTS.md` (root, § Test Framework Discipline only)
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** none
- **Entry condition:** pre-implementation steps 1-4 PASS (baseline recorded, BEFORE enforcement run passed)
- **Exit condition:** all four qualifier statements present in the section; per-SC commits exist; AFTER enforcement run passes

### Code Path Coverage

- N/A — text-only edit; the modified artifact is agent-facing prose in root `AGENTS.md`, with no executable code path. The only executable check paths are content-presence reads of `AGENTS.md` and the enforcement regression suite run.

### Cross-Cutting SCs

- None. Each of SC-1..SC-4 is a distinct content-presence element within the same section; none spans multiple files, phases, or subsystems.

### Interface Boundaries

- The section boundary is the § Test Framework Discipline heading in root `AGENTS.md` — no text outside that section may change.
- The edit adds text only; existing non-waivable rules in the section (`timeout` prohibition, submodule pointer updates, `with-test-home` mandate) MUST be preserved verbatim.

### State Transitions

- File-state transition: before-phase (qualifier absent) → after-phase (qualifier present). Four incremental text insertions; each insertion's content-presence check flips RED→GREEN.

### Steps

- [ ] 5. ITEM-1 RED (SC-1). (**task-card**) — `task(subagent_type: general, prompt: "execute red task from test-driven-development")`
  - SC reference: SC-1 (string evidence)
  - Assert the repo-scope qualifier distinguishing `.opencode`-targeted (submodule) work from root-repo (non-submodule) work is ABSENT from § Test Framework Discipline — the presence check FAILS, establishing RED
- [ ] 6. ITEM-1 GREEN (SC-1). (**task-card**) — `task(subagent_type: general, prompt: "execute green task from test-driven-development")`
  - Edit root `AGENTS.md` § Test Framework Discipline to insert the repo-scope qualifier per R-1
  - What must be true: the qualifier text distinguishing the two work targets is present in the section
- [ ] 7. ITEM-1 post-regression + verify (SC-1). (**task-card**) — `task(subagent_type: general, prompt: "execute verify task from verification-before-completion")`
  - Re-run content-presence `read` of the section; confirm SC-1 string evidence
  - Report `[ITEM-1] [PASS|FAIL]`
- [ ] 8. ITEM-1 commit. (**direct**)
  - `git add AGENTS.md && git commit -m "AGENTS.md: add repo-scope qualifier distinguishing .opencode-targeted work from root-repo work (SC-1)"` — no co-author trailer
- [ ] 9. ITEM-2 RED (SC-2). (**task-card**) — `task(subagent_type: general, prompt: "execute red task from test-driven-development")`
  - SC reference: SC-2 (string evidence)
  - Assert the framework-applicability statement (canonical `.opencode` framework applies to `.opencode`-targeted work only) is ABSENT — presence check FAILS, establishing RED
- [ ] 10. ITEM-2 GREEN (SC-2). (**task-card**) — `task(subagent_type: general, prompt: "execute green task from test-driven-development")`
  - Edit the section to add the framework-applicability statement per R-2
  - What must be true: the statement that the canonical `.opencode` framework (`with-test-home`, `opencode run`, `tests-v2`) applies to `.opencode`-targeted work only is present
- [ ] 11. ITEM-2 post-regression + verify (SC-2). (**task-card**) — `task(subagent_type: general, prompt: "execute verify task from verification-before-completion")`
  - Re-run content-presence `read` of the section; confirm SC-2 string evidence
  - Report `[ITEM-2] [PASS|FAIL]`
- [ ] 12. ITEM-2 commit. (**direct**)
  - `git add AGENTS.md && git commit -m "AGENTS.md: state canonical .opencode framework applies to .opencode-targeted work only (SC-2)"` — no co-author trailer
- [ ] 13. ITEM-3 RED (SC-3). (**task-card**) — `task(subagent_type: general, prompt: "execute red task from test-driven-development")`
  - SC reference: SC-3 (string evidence)
  - Assert the instrument name `tests/behaviors/*.sh` is ABSENT from the section — presence check FAILS, establishing RED
- [ ] 14. ITEM-3 GREEN (SC-3). (**task-card**) — `task(subagent_type: general, prompt: "execute green task from test-driven-development")`
  - Edit the section to name `tests/behaviors/*.sh` as the root-repo test instrument per R-3
  - What must be true: the exact instrument name `tests/behaviors/*.sh` appears in the section as the root-repo test instrument
- [ ] 15. ITEM-3 post-regression + verify (SC-3). (**task-card**) — `task(subagent_type: general, prompt: "execute verify task from verification-before-completion")`
  - Re-run content-presence `read` of the section; confirm SC-3 string evidence
  - Report `[ITEM-3] [PASS|FAIL]`
- [ ] 16. ITEM-3 commit. (**direct**)
  - `git add AGENTS.md && git commit -m "AGENTS.md: name tests/behaviors/*.sh as the root-repo test instrument (SC-3)"` — no co-author trailer
- [ ] 17. ITEM-4 RED (SC-4). (**task-card**) — `task(subagent_type: general, prompt: "execute red task from test-driven-development")`
  - SC reference: SC-4 (string evidence)
  - Assert the SHALL NOT submodule-prohibition statement is ABSENT — presence check FAILS, establishing RED
- [ ] 18. ITEM-4 GREEN (SC-4). (**task-card**) — `task(subagent_type: general, prompt: "execute green task from test-driven-development")`
  - Edit the section to add the prohibition per R-3: root-repo work SHALL NOT touch the `.opencode` submodule or its test framework
  - What must be true: the SHALL NOT prohibition statement is present in the section
- [ ] 19. ITEM-4 post-regression + verify (SC-4). (**task-card**) — `task(subagent_type: general, prompt: "execute verify task from verification-before-completion")`
  - Re-run content-presence `read` of the section; confirm SC-4 string evidence
  - Report `[ITEM-4] [PASS|FAIL]`
- [ ] 20. ITEM-4 commit. (**direct**)
  - `git add AGENTS.md && git commit -m "AGENTS.md: prohibit root-repo work from touching the .opencode submodule or its test framework (SC-4)"` — no co-author trailer
- [ ] 21. AFTER enforcement regression run. (**direct**)
  - Run `bash .opencode/tests-v2/test-enforcement.sh` and confirm result matches the BEFORE baseline (no skill-enforcement regression); if regressed, the SC set is FAIL
- [ ] 22. Phase 1 completion. (**direct**)
  - Verify phase exit: all four string-evidence checks PASS from saved verify artifacts; four commits exist on the feature branch
  - Report `[phase-1] [PASS|FAIL]`

### Phase 1 Completion Block

- VbC assertion: SC-1..SC-4 each verified with string evidence (`read` of § Test Framework Discipline) recorded in `tmp/372/artifacts/pipeline-verify-*` artifacts
- VbC assertion: enforcement regression suite result at step 21 matches step 2 baseline

**Cost frame:** Verifying each qualifier insertion costs one `read` of the section plus one commit-scoped `git add` — minutes of execution. Skipping a content-presence check means an unscoped or incoherent qualifier ships and an agent performing root-repo work is still directed to a framework that does not exist in its context (fabricated excuses, `.opencode` submodule forays) — discovered only after downstream agent misbehavior, at 100×–1000× the fix cost.

### Concern transition

Phase 1 produced the qualifier text and one-file-scope commits; Phase 2 consumes that output to verify commit scope containment (SC-5).

# Phase 2 — Verify commit scope containment

- **Concern:** Structural diff verification (SC-5)
- **Files:** none modified (verification-only); consumes Phase 1 commits
- **SCs:** SC-5
- **Dependencies:** phase-1 (SC-5 containment requires ITEM-1..ITEM-4 commits to exist)
- **Entry condition:** phase-1 exit PASS (four qualifier commits exist)
- **Exit condition:** `git diff --stat <base>..HEAD` shows exactly one changed path (root `AGENTS.md`) and zero paths under `.opencode/`; all SC verdicts PASS

### Code Path Coverage

- N/A — verification-only phase; executable path is the `git diff --stat <base>..HEAD` comparison against the base commit recorded in step 2.

### Cross-Cutting SCs

- None — SC-5 is a single structural check on the cumulative commit set.

### Interface Boundaries

- Boundary is the git diff surface: exactly one changed path (`AGENTS.md`, root). Any path under `.opencode/` in the diff is a hard FAIL (unauthorized deck-repo mutation).

### State Transitions

- Verification-state transition: containment assertion undemonstrated (RED) → demonstrated (GREEN) when the diff shows the single-path change set.

### Steps

- [ ] 23. ITEM-5 RED (SC-5). (**direct**)
  - Run `git diff --stat <base>..HEAD` using the base commit recorded in step 2; BEFORE remediation the containment assertion is not yet demonstrated — establish RED by recording the assertion as unverified pending the diff inspection of the committed state
  - SC reference: SC-5 (structural evidence)
- [ ] 24. ITEM-5 GREEN (SC-5). (**direct**)
  - Confirm all ITEM-1..ITEM-4 edits are committed scoped to root `AGENTS.md` only; re-run `git diff --stat <base>..HEAD` — exactly one changed path, root `AGENTS.md`, zero `.opencode/` paths; containment assertion passes
  - What must be true: no additional commits or stray files exist; the diff is single-path
- [ ] 25. ITEM-5 verify (SC-5). (**task-card**) — `task(subagent_type: general, prompt: "execute verify task from verification-before-completion")`
  - Record SC-5 structural evidence from `git diff --stat` output in the verify artifact
  - Report `[ITEM-5] [PASS|FAIL]`
- [ ] 26. Run structural checks finishing checklist. (**task-card**) — `task(subagent_type: general, prompt: "execute checklist task from finishing-a-development-branch")`
  - Markdown format/lint advisory checks are not applicable to `AGENTS.md` per tool-type rules; checklist confirms zero pending changes and branch hygiene
- [ ] 27. Run the final regression check before PR. (**task-card**) — `task(subagent_type: general, prompt: "execute phase-4 task from test-driven-development")`
  - Confirms the AFTER enforcement regression result from step 21 still holds

### Phase 2 Completion Block

- VbC assertion: `git diff --stat <base>..HEAD` output recorded showing exactly `AGENTS.md` (root) and no `.opencode/` path
- VbC assertion: all SC verdicts (SC-1..SC-5) present and PASS in verify artifacts; pre-PR gate reads them all

**Cost frame:** Verifying commit scope containment costs one `git diff --stat` run — about a second of execution. Skipping the containment check means an edit that silently reached into `.opencode/` (unauthorized deck-repo mutation — the exact contamination this fix prevents) passes review unnoticed and is discovered only at PR review or later, at 1000× the check cost.

### Concern transition

Phase 2 completes verification; post-implementation steps 28-31 (audit, pre-PR gate, PR creation, executive summary) close out the plan.
