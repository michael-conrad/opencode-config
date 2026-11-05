---
plan_schema_version: 1
issue: 2313
title: "Submodule merged-commit verification gate for implementation and PR-creation workflows"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Implementation Plan — #2313 — Submodule merged-commit verification gate

**Issue:** https://github.com/michael-conrad/.opencode/issues/2313

## Goal

Add merged-commit verification to three independent workflow gates (pre-work trunk-tip-verification, pre-commit, and PR-creation enforcement-gate) so a submodule pointer referencing a local-only commit is caught before it breaks the deploy pipeline, each gate enforced by a behavioral test.

## Architecture

Each of the three gates independently verifies that a submodule pointer SHA is reachable from the submodule's remote `origin/$DEFAULT_BRANCH` using `git merge-base --is-ancestor` (exit code 0 = ancestor/merged; non-zero = local-only commit). The gates fire at distinct workflow boundaries — pre-work (before feature branch creation), pre-commit (before commit), and PR creation (Step 0) — and share the same reachability mechanism but operate on independent gate boundaries, so the phase DAG has no dependency edges. Each SC produces exactly one behavioral test under `tests-v2/behaviors/git-workflow/` that sends a real-domain prompt through `opencode run` and asserts `session.yaml` (SQLite DB export) evidence of the verification action or block. On network error the gate fails open (warns, does not block).

## Files

- `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` (add 8th check)
- `.opencode/skills/git-workflow-commit/tasks/implementation.md` (add merged-commit check to pre-commit section)
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` (add merged-commit check to Step 0)
- `.opencode/tests-v2/behaviors/git-workflow/` (new — one behavioral test per SC)

## Blast Radius

Affected files and impact zones (from `blast-radius.yaml`):

- **Phase 1 (pre-work gate):** edit task-file prose in `trunk-tip-verification.md` + create behavioral test. Risk: low. Rollback: revert prose edit and test.
- **Phase 2 (pre-commit gate):** edit task-file prose in `implementation.md` + create behavioral test. Risk: low. Rollback: revert prose edit and test.
- **Phase 3 (enforcement-gate):** edit task-file prose in `enforcement-gate.md` + create behavioral test. Risk: low. Rollback: revert prose edit and test.
- **Cross-repo impact:** none — all files live in the `.opencode` submodule. No root-repo (`opencode-config`) files change.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On | Step Range | Dispatch |
|-------|-------|------|--------|-----|------------|------------|----------|
| 1 — Pre-work merged-commit gate | `test-driven-development` `red`,`green`; `verification-before-completion` `verify` | trunk-tip-verification.md + behavioral test | SC-1 | — | 3–9 | sub-agent / clean-room |
| 2 — Pre-commit merged-commit gate | `test-driven-development` `red`,`green`; `verification-before-completion` `verify` | implementation.md + behavioral test | SC-2 | — | 10–16 | sub-agent / clean-room |
| 3 — Enforcement-gate merged-commit check | `test-driven-development` `red`,`green`; `verification-before-completion` `verify` | enforcement-gate.md + behavioral test | SC-3 | — | 17–23 | sub-agent / clean-room |

## Phase Details

### Phase 1 — Pre-work merged-commit gate

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red, green), `verification-before-completion` (verify) |
| Target | `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` step 8 (new); behavioral test `tests-v2/behaviors/git-workflow/2313-sc1-prework-merged-commit.sh` |
| Concern | `pre-work-gate` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
gate_file: .opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md
new_check_position: after step 7 (submodule pointer match)
check_mechanism: git merge-base --is-ancestor <committed_pointer_sha> origin/$DEFAULT_BRANCH
blocked_code: SUBMODULE_UNMERGED_COMMIT
fail_open_on_network_error: true
behavioral_test: .opencode/tests-v2/behaviors/git-workflow/2313-sc1-prework-merged-commit.sh
test_prompt: "Setup a feature branch for issue #2313. The .opencode submodule pointer references a local-only commit. Run pre-work trunk-tip-verification. It should block branch creation with SUBMODULE_UNMERGED_COMMIT."
```

**Procedure (steps 3–9):**
- [ ] 3. **RED — item-1 (SC-1) (**sub-agent**).** Write a behavioral enforcement test `2313-sc1-prework-merged-commit.sh` that sends a real-domain prompt through `opencode run` and asserts `session.yaml` evidence that trunk-tip-verification either performs the `git merge-base --is-ancestor` merged-commit check or blocks with `SUBMODULE_UNMERGED_COMMIT`. Test FAILS against the current task file, which has no merged-commit check. **→ SC-1**
- [ ] 4. **GREEN — item-1 (SC-1) (**sub-agent**).** Add an 8th check to `trunk-tip-verification.md` after step 7 (pointer-match) that, for each submodule, resolves `$DEFAULT_BRANCH`, fetches `origin`, runs `git merge-base --is-ancestor <committed_pointer_sha> origin/$DEFAULT_BRANCH`, and reports BLOCKED with `SUBMODULE_UNMERGED_COMMIT` on non-zero exit. Fail open (warn, do not block) on network error. **→ SC-1**
- [ ] 5. **GREEN doublecheck (**clean-room**).** Verify the new step 8 is present in `trunk-tip-verification.md`, uses `git merge-base --is-ancestor`, and includes the `SUBMODULE_UNMERGED_COMMIT` block and the fail-open network path. **→ SC-1**
- [ ] 6. **Verify — item-1 (**clean-room**).** Verify SC-1 verdict against its evidence type (behavioral) via `verification-before-completion`. BLOCK on any FAIL or EVIDENCE_TYPE_MISMATCH. **→ SC-1**
- [ ] 7. **COMMIT — item-1.** Commit the behavioral test and the task-file change atomically as one working slice. **→ SC-1**
- [ ] 8. **Enforcement cross-check (Risk: stale pointer acceptance) (**sub-agent**).** Confirm the gate fires at branch creation only (pre-work), not during development, per the spec risk mitigation. **→ SC-1**
- [ ] 9. **Interface check (**sub-agent**).** Confirm the new check is compatible with the existing `git submodule status` scanning pattern and does not alter the submodule pointer scanning mechanism (out of scope). **→ SC-1**

**Cost frame:** Verifying the pre-work gate adds one behavioral run and one read of the task file. Skipping it means every trunk-tip-verification pass is a lie — the developer starts work from an already-broken base, and the unmerged pointer is not caught until deploy, a 1000× downstream death spiral. Correctness is the only metric.

### Phase 2 — Pre-commit merged-commit gate

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red, green), `verification-before-completion` (verify) |
| Target | `.opencode/skills/git-workflow-commit/tasks/implementation.md` Pre-Commit Submodule Pointer Check; behavioral test `tests-v2/behaviors/git-workflow/2313-sc2-precommit-merged-commit.sh` |
| Concern | `pre-commit-gate` |
| SCs | SC-2 |
| Depends On | — |

**Context:**
```yaml
gate_file: .opencode/skills/git-workflow-commit/tasks/implementation.md
check_location: Pre-Commit Submodule Pointer Check section (after dirty-pointer detection)
check_mechanism: git merge-base --is-ancestor <staged_pointer_sha> origin/$DEFAULT_BRANCH
block_behavior: block commit with a clear error when a staged pointer references a local-only commit
fail_open_on_network_error: true
behavioral_test: .opencode/tests-v2/behaviors/git-workflow/2313-sc2-precommit-merged-commit.sh
test_prompt: "On branch 'feature/2313-precommit', the .opencode submodule pointer is staged and references a local-only commit. Attempt to commit. The pre-commit section should block the commit with a clear error because the staged pointer is not reachable from origin/$DEFAULT_BRANCH."
```

**Procedure (steps 10–16):**
- [ ] 10. **RED — item-2 (SC-2) (**sub-agent**).** Write a behavioral enforcement test `2313-sc2-precommit-merged-commit.sh` that sends a real-domain prompt through `opencode run` and asserts `session.yaml` evidence that the pre-commit section blocks commit with a clear error when a staged pointer references a local-only commit. Test FAILS against the current pre-commit section, which has no reachability check. **→ SC-2**
- [ ] 11. **GREEN — item-2 (SC-2) (**sub-agent**).** Extend the Pre-Commit Submodule Pointer Check in `implementation.md` to verify each newly-staged submodule pointer SHA is reachable from `origin/$DEFAULT_BRANCH` via `git merge-base --is-ancestor`, blocking commit with a clear error when a pointer references a local-only commit. Fail open (warn, do not block) on network error. **→ SC-2**
- [ ] 12. **GREEN doublecheck (**clean-room**).** Verify the merged-commit check is in the pre-commit section of `implementation.md`, uses `git merge-base --is-ancestor`, and blocks commit on a local-only pointer with a clear error and the fail-open network path. **→ SC-2**
- [ ] 13. **Verify — item-2 (**clean-room**).** Verify SC-2 verdict against its evidence type (behavioral) via `verification-before-completion`. BLOCK on any FAIL or EVIDENCE_TYPE_MISMATCH. **→ SC-2**
- [ ] 14. **COMMIT — item-2.** Commit the behavioral test and the task-file change atomically as one working slice. **→ SC-2**
- [ ] 15. **Enforcement cross-check (Risk: developer self-block) (**sub-agent**).** Confirm the pre-commit gate only checks newly-staged pointers and lets the developer block themselves, per the spec risk mitigation — it does not fire during development. **→ SC-2**
- [ ] 16. **Interface check (**sub-agent**).** Confirm the new check composes with the existing dirty-pointer detection and does not alter the submodule pointer scanning mechanism (out of scope). **→ SC-2**

**Cost frame:** Verifying the pre-commit gate adds one behavioral run and one read of the task file. Skipping it means every commit is a ticking time bomb — the commit looks clean but breaks the deploy pipeline the moment someone uses it. Correctness is the only metric.

### Phase 3 — Enforcement-gate merged-commit check

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red, green), `verification-before-completion` (verify) |
| Target | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` Step 0; behavioral test `tests-v2/behaviors/git-workflow/2313-sc3-enforcement-merged-commit.sh` |
| Concern | `pr-creation-gate` |
| SCs | SC-3 |
| Depends On | — |

**Context:**
```yaml
gate_file: .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md
check_location: Step 0 Submodule PR Dependency Check (alongside existing liveness check)
check_mechanism: git merge-base --is-ancestor <committed_gitlink_sha> origin/$DEFAULT_BRANCH
blocked_code: SUBMODULE_PR_MISSING
report_only: true (sub-agent returns PASS/FAIL, no auto-remediation, no SHA bumps, no commits)
fail_open_on_network_error: true
behavioral_test: .opencode/tests-v2/behaviors/git-workflow/2313-sc3-enforcement-merged-commit.sh
test_prompt: "Create a PR for issue #2313. A committed submodule gitlink SHA references an unmerged commit. The enforcement-gate Step 0 should block PR creation with SUBMODULE_PR_MISSING."
```

**Procedure (steps 17–23):**
- [ ] 17. **RED — item-3 (SC-3) (**sub-agent**).** Write a behavioral enforcement test `2313-sc3-enforcement-merged-commit.sh` that sends a real-domain prompt through `opencode run` and asserts `session.yaml` evidence that enforcement-gate Step 0 blocks PR creation with `SUBMODULE_PR_MISSING` when a committed gitlink SHA references an unmerged commit. Test FAILS against the current Step 0, which only does liveness verification. **→ SC-3**
- [ ] 18. **GREEN — item-3 (SC-3) (**sub-agent**).** Extend enforcement-gate Step 0 to verify every committed submodule gitlink SHA exists on `origin/$DEFAULT_BRANCH` via `git merge-base --is-ancestor`, blocking PR creation with `SUBMODULE_PR_MISSING` when any pointer references an unmerged commit. The check is report-only (sub-agent returns PASS/FAIL; no auto-remediation, no SHA bumps, no commits) and fails open (warn, do not block) on network error. **→ SC-3**
- [ ] 19. **GREEN doublecheck (**clean-room**).** Verify Step 0 of `enforcement-gate.md` includes the merged-commit reachability check, uses `git merge-base --is-ancestor`, blocks with `SUBMODULE_PR_MISSING`, is report-only, and includes the fail-open network path. **→ SC-3**
- [ ] 20. **Verify — item-3 (**clean-room**).** Verify SC-3 verdict against its evidence type (behavioral) via `verification-before-completion`. BLOCK on any FAIL or EVIDENCE_TYPE_MISMATCH. **→ SC-3**
- [ ] 21. **COMMIT — item-3.** Commit the behavioral test and the task-file change atomically as one working slice. **→ SC-3**
- [ ] 22. **Enforcement cross-check (Risk: deploy-time discovery) (**sub-agent**).** Confirm the gate fires at PR time (the last line of defense), when all submodule work should be merged anyway, per the spec risk mitigation — not at deploy time (out of scope). **→ SC-3**
- [ ] 23. **Interface check (**sub-agent**).** Confirm the new check composes with the existing liveness check and the sub-agent result contract schema (`status`/`submodule_checks`) already present in Step 0. **→ SC-3**

**Cost frame:** Verifying the enforcement-gate adds one behavioral run and one read of the task file. Skipping it means the deploy engineer discovers the break at deployment time, not at PR time — the most expensive point in the pipeline. Correctness is the only metric.

## Pre-implementation Steps

- [ ] 1. **Coherence gate (**inline**).** Verify the spec (#2313) and its success criteria (SC-1, SC-2, SC-3) are internally consistent with the structure artifact: three independent phases, empty dependency DAG, SC-to-phase mapping SC-1 → phase 1, SC-2 → phase 2, SC-3 → phase 3, triplet co-location verified, no cross-phase dependency. **→ all SCs**
- [ ] 2. **Baseline check (**inline**).** Confirm the feature branch exists and is up to date, `.opencode` submodule is on `main` at its tracked pointer, and the working tree is clean before any file modification. **→ all SCs**

## Post-implementation Steps

- [ ] 24. **Structural checks (**sub-agent**).** Run the finishing checklist from `finishing-a-development-branch` — lint/format/typecheck on modified files per AGENTS.md build commands. **→ all SCs**
- [ ] 25. **Verification (**clean-room**).** Verify every SC verdict against its evidence type (all behavioral) from `verification-before-completion`: SC-1, SC-2, SC-3 each verified via `session.yaml` (SQLite DB export) clean-room evaluation of the behavioral test artifacts. BLOCK on any FAIL or EVIDENCE_TYPE_MISMATCH. **→ all SCs**
- [ ] 26. **Audit (**clean-room**).** Run adversarial audit of the deliverable (plan-fidelity / verification-audit chain) — spec fidelity, phase coherence, evidence-type compliance. **→ all SCs**
- [ ] 27. **Cross-validate (**clean-room**).** Independently re-verify the deliverable cross-references the structure artifact, dependency contract, and evidence artifacts consistently. **→ all SCs**
- [ ] 28. **Review-prep (**sub-agent**).** Prepare PR review context from `git-workflow-pr` review-prep task. **→ all SCs**
- [ ] 29. **Completion (**sub-agent**).** Generate completion executive summary from `completion-core`. **→ all SCs**

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. `trunk-tip-verification.md` verifies each submodule's committed pointer SHA is an ancestor of `origin/$DEFAULT_BRANCH` via `git merge-base --is-ancestor` and reports BLOCKED with `SUBMODULE_UNMERGED_COMMIT` on a local-only commit — SC-1.
- [ ] C2. `implementation.md` pre-commit section verifies each newly-staged submodule pointer SHA is reachable from `origin/$DEFAULT_BRANCH` and blocks commit with a clear error on a local-only pointer — SC-2.
- [ ] C3. `enforcement-gate.md` Step 0 verifies every committed submodule gitlink SHA exists on `origin/$DEFAULT_BRANCH` and blocks PR creation with `SUBMODULE_PR_MISSING` on an unmerged commit — SC-3.
- [ ] C4. One behavioral test per SC exists under `tests-v2/behaviors/git-workflow/` and asserts `session.yaml` evidence of the verification action or block — SC-1, SC-2, SC-3.
- [ ] C5. No out-of-scope change: submodule pointer scanning mechanism, submodule workflows, deploy-time gate, and non-submodule dependencies unchanged — SC-1, SC-2, SC-3.

---

## Lifecycle Events

| Timestamp (UTC) | Event | Details |
|-----------------|-------|---------|
| 2026-08-21T05:26:39Z | `plan_created` | Plan file: `.opencode/.issues/2313/plan.md`; phase count: 3 |

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
