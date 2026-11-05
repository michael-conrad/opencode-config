---
plan_schema_version: 1
issue: 2267
title: "Replace no-op mergeability trigger with local merge-base check"
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr, completion-core]
lifecycle_events:
  - timestamp: "2026-08-12T07:12:01Z"
    event: plan_created
    plan_path: ".opencode/.issues/2267/plan.md"
    phase_count: 3
---

# Plan — Issue 2267

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2267/

## Goal

Replace the no-op-comment/empty-push "trigger mergeability" mechanism in the git-workflow-pr PR-creation procedure with the authoritative local ancestry check `git merge-base --is-ancestor origin/<target> HEAD`, re-route the `mergeable: null` path and diagnosis output to report **verified-locally**, align the pre-creation enforcement gate, and add behavioral enforcement tests.

## Architecture

The change spans two task files in the git-workflow-pr skill and one new behavioral test:

- `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` — remove the no-op comment trigger and empty-push fallback from Step 7.2.4; replace with the local merge-base ancestry check; re-route Step 7.2.2 `mergeable: null` path and Step 7.2.5 diagnosis to **verified-locally**.
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` — align Step 1.5d/e so the pre-creation `None/unknown` path names the local merge-base check and the Step 1.5e cross-reference to the post-creation check remains valid.
- `.opencode/tests-v2/behaviors/git-workflow-pr-no-op-trigger.sh` — new behavioral enforcement test asserting the agent does not post a no-op trigger comment and reports verified-locally.

## Files

- `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md`
- `.opencode/tests-v2/behaviors/git-workflow-pr-no-op-trigger.sh`

## Dispatch

- test-driven-development (red/green/post-regression)
- verification-before-completion (verify, pre-pr-gate)
- audit (verification-audit DiMo chain)
- finishing-a-development-branch (structural checks)
- git-workflow-pr (review-prep, create-pr)
- completion-core (exec-summary)

## Blast Radius

- **create-pr.md Step 7.2.4** — direct: no-op comment trigger and empty-push fallback removed, replaced with the local merge-base check. Ripple: agents no longer post useless comments; no pointless empty commits; PR history stays clean.
- **create-pr.md Step 7.2.2** — direct: `mergeable: null` path re-routed to verified-locally. Ripple: the null path runs the local ancestry check; conflict detection preserved via `git diff origin/<target>...HEAD --diff-filter=U` on non-zero exit.
- **create-pr.md Step 7.2.5** — direct: diagnosis reports verified-locally, drops the "Computation triggered: yes|no" line. Ripple: the executive summary no longer references a computation trigger that no longer exists.
- **enforcement-gate.md Step 1.5d/e** — direct: pre-creation gate aligned to name the local merge-base check; Step 1.5e cross-reference remains valid.
- **tests-v2/behaviors/** — direct: new behavioral test added. Ripple: CI runs the new test.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Dispatch |
|-------|------|---------|-----|--------------|----------|
| 1 | Remove no-op mergeability trigger from create-pr.md | SC-1, SC-2, SC-3 | SC-1, SC-2, SC-3 | None | test-driven-development, verification-before-completion |
| 2 | Align enforcement-gate.md pre-creation gate | SC-4 | SC-4 | Phase 1 | test-driven-development, verification-before-completion |
| 3 | Add behavioral enforcement tests | Behavioral tests | (none) | Phases 1, 2 | test-driven-development, verification-before-completion |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Pre-Implementation

- [ ] 1. **Coherence gate** (**inline**)
  - Verify the spec at `.opencode/.issues/2267/spec.md` is coherent: SC-1 through SC-4 are defined, each with an evidence type and verification method.
  - Verify the structure artifact at `.opencode/.issues/2267/artifacts/structure.yaml` maps every SC to exactly one phase and one item.
  - If any SC is unmapped or the phase DAG has a cycle, HALT and report.

- [ ] 2. **Baseline check** (**inline**)
  - Verify the working tree is clean and the branch is at trunk tip.
  - Verify the target files exist: `create-pr.md`, `enforcement-gate.md`.
  - Verify the current Step 7.2.4 contains the no-op comment trigger and empty-push fallback (RED precondition).

## Phase 1 — Remove no-op mergeability trigger from create-pr.md

**Concern:** SC-1, SC-2, SC-3 — remove the no-op comment trigger and empty-push fallback from Step 7.2.4, replace with the local merge-base ancestry check, re-route the `mergeable: null` path and diagnosis output to verified-locally, keep 7.2.x step numbers stable.

**Files:** `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`

**SCs:** SC-1, SC-2, SC-3

**Dependencies:** None

**Entry conditions:** Pre-implementation steps complete.

**Exit conditions:** SC-1, SC-2, SC-3 verified PASS; Step 7.2.4 uses the local merge-base check; Step 7.2.2/7.2.5 report verified-locally; 7.2.x step numbers stable.

**Code path coverage:** create-pr.md Step 7.2.2 (mergeable:null path), Step 7.2.4 (trigger mechanism), Step 7.2.5 (diagnosis output).

**Cross-cutting SCs:** Local merge-base ancestry check as authoritative mergeability determination (with Phase 2); verified-locally reporting consistency (with Phase 2); step number stability 7.2.x (with Phase 2).

**Interface boundaries:** create-pr.md Step 7.2.4 is consumed by agents executing the PR-creation procedure and by the enforcement-gate.md Step 1.5e cross-reference. The `github_add_issue_comment` no-op trigger and `git commit --allow-empty` fallback are removed; replaced with `git merge-base --is-ancestor origin/<target> HEAD`.

**State transitions:** Step 7.2.4 posts a no-op comment → Step 7.2.4 runs the local ancestry check (exit 0 = mergeable, non-zero = divergence → report conflict). Step 7.2.2 mergeable:null path proceeds to trigger → reports verified-locally after the local check. Step 7.2.5 diagnosis includes "Computation triggered" line → reports verified-locally, drops the line.

**Cost frame:** Verifying the removal costs one grep search per SC. Skipping means the no-op comment trigger ships unchanged and keeps posting useless comments on every new PR.

### Item 1 — SC-1: Remove the no-op comment trigger

- [ ] 1. **Pre-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Run regression test patterns before the RED phase.

- [ ] 2. **Pre-regression verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify pre-regression results.

- [ ] 3. **RED** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - Write a failing enforcement test for SC-1: grep create-pr.md Step 7.2.4 for `github_add_issue_comment` — the test FAILS because the no-op trigger is still present.

- [ ] 4. **GREEN** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Remove the no-op comment trigger (`github_add_issue_comment` with a no-op message) from create-pr.md Step 7.2.4.
  - The RED test now PASSES: `github_add_issue_comment` is absent from Step 7.2.4.

- [ ] 5. **Post-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Run regression test patterns after the GREEN phase.

- [ ] 6. **Verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify SC-1 against the success criterion: `github_add_issue_comment` absent from Step 7.2.4.

- [ ] 7. **Commit** (**inline**)
  - Stage the changed files and commit with a descriptive message.
  - The test and its implementation are committed as one atomic slice.

### Item 2 — SC-2: Remove the empty-push fallback

- [ ] 1. **Pre-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Run regression test patterns before the RED phase.

- [ ] 2. **Pre-regression verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify pre-regression results.

- [ ] 3. **RED** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - Write a failing enforcement test for SC-2: grep create-pr.md Step 7.2.4 for `--allow-empty` — the test FAILS because the empty-push fallback is still present.

- [ ] 4. **GREEN** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Remove the empty-push fallback (`git commit --allow-empty -m "trigger mergeability" && git push`) from create-pr.md Step 7.2.4.
  - The RED test now PASSES: `--allow-empty` is absent from Step 7.2.4.

- [ ] 5. **Post-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Run regression test patterns after the GREEN phase.

- [ ] 6. **Verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify SC-2 against the success criterion: `--allow-empty` absent from Step 7.2.4.

- [ ] 7. **Commit** (**inline**)
  - Stage the changed files and commit with a descriptive message.
  - The test and its implementation are committed as one atomic slice.

### Item 3 — SC-3: Replace with the local merge-base check and re-route to verified-locally

- [ ] 1. **Pre-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Run regression test patterns before the RED phase.

- [ ] 2. **Pre-regression verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify pre-regression results.

- [ ] 3. **RED** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - Write a failing enforcement test for SC-3: grep create-pr.md for `merge-base --is-ancestor` in Step 7.2.4 and `verified-locally` in Step 7.2.2/7.2.5 — the test FAILS because the local check and verified-locally reporting are not yet present.

- [ ] 4. **GREEN** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Replace Step 7.2.4's trigger mechanism with the authoritative local check `git merge-base --is-ancestor origin/<target> HEAD` (exit 0 = mergeable).
  - Re-route the `mergeable: null` path (Step 7.2.2) to report **verified-locally** after the local check, preserving conflict detection via `git diff origin/<target>...HEAD --name-only --diff-filter=U` on non-zero exit.
  - Update the diagnosis output (Step 7.2.5) to report **verified-locally** and drop the "Computation triggered: yes|no" line.
  - Keep the 7.2.x step numbers stable.
  - The RED test now PASSES: `merge-base --is-ancestor` present in Step 7.2.4, `verified-locally` present in Step 7.2.2/7.2.5, "Computation triggered" absent.

- [ ] 5. **Post-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Run regression test patterns after the GREEN phase.

- [ ] 6. **Verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify SC-3 against the success criterion: `merge-base --is-ancestor` present in Step 7.2.4; `verified-locally` present in Step 7.2.2/7.2.5; "Computation triggered" absent; 7.2.x step numbers stable.

- [ ] 7. **Commit** (**inline**)
  - Stage the changed files and commit with a descriptive message.
  - The test and its implementation are committed as one atomic slice.

**Phase completion block:** Verify SC-1, SC-2, SC-3 all PASS via verification-before-completion. If any FAIL, remediate before proceeding to Phase 2.

**Concern transition:** Phase 1 output (the local merge-base check in create-pr.md Step 7.2.4) is the precondition for Phase 2 alignment.

## Phase 2 — Align enforcement-gate.md pre-creation gate

**Concern:** SC-4 — align enforcement-gate.md Step 1.5d/e so the pre-creation None/unknown path explicitly names the local merge-base check and the Step 1.5e cross-reference to the post-creation check remains valid.

**Files:** `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md`

**SCs:** SC-4

**Dependencies:** Phase 1

**Entry conditions:** Phase 1 complete (create-pr.md Step 7.2.4 uses the local merge-base check).

**Exit conditions:** SC-4 verified PASS; Step 1.5d names the local merge-base check; Step 1.5e cross-reference valid.

**Code path coverage:** enforcement-gate.md Step 1.5d (None/unknown path), Step 1.5e (post-creation gate reference).

**Cross-cutting SCs:** Local merge-base ancestry check as authoritative mergeability determination (with Phase 1); verified-locally reporting consistency (with Phase 1); step number stability 7.2.x (with Phase 1).

**Interface boundaries:** enforcement-gate.md Step 1.5e cross-references the post-creation check in create-pr.md Step 7.2.4. The reference must remain valid after Phase 1 changes.

**State transitions:** Step 1.5d None/unknown path says "Wait and retry, or check locally" → explicitly names the local merge-base check. Step 1.5e cross-reference to the post-creation check → verified valid.

**Cost frame:** Verifying the alignment costs one grep search. Skipping means the pre-creation gate and post-creation gate disagree on the mergeability determination method.

### Item 4 — SC-4: Align enforcement-gate.md Step 1.5d/e

- [ ] 1. **Pre-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Run regression test patterns before the RED phase.

- [ ] 2. **Pre-regression verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify pre-regression results.

- [ ] 3. **RED** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - Write a failing enforcement test for SC-4: grep enforcement-gate.md Step 1.5d for `merge-base` and Step 1.5e for the post-creation check reference — the test FAILS because the pre-creation gate does not yet name the local merge-base check.

- [ ] 4. **GREEN** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Align enforcement-gate.md Step 1.5d so the pre-creation None/unknown path explicitly names the local merge-base check.
  - Verify the Step 1.5e cross-reference to the post-creation check (create-pr.md Step 7.2.4) remains valid.
  - The RED test now PASSES: `merge-base` present in Step 1.5d, Step 1.5e reference valid.

- [ ] 5. **Post-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Run regression test patterns after the GREEN phase.

- [ ] 6. **Verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify SC-4 against the success criterion: `merge-base` present in Step 1.5d; Step 1.5e cross-reference to the post-creation check present and valid.

- [ ] 7. **Commit** (**inline**)
  - Stage the changed files and commit with a descriptive message.
  - The test and its implementation are committed as one atomic slice.

**Phase completion block:** Verify SC-4 PASS via verification-before-completion. If FAIL, remediate before proceeding to Phase 3.

**Concern transition:** Phase 2 output (aligned pre-creation gate) is the precondition for Phase 3 behavioral tests.

## Phase 3 — Add behavioral enforcement tests

**Concern:** Behavioral tests — add a behavioral enforcement test asserting the agent does not post a no-op trigger comment and instead reports verified-locally (spec call to action; no numbered SC).

**Files:** `.opencode/tests-v2/behaviors/git-workflow-pr-no-op-trigger.sh`

**SCs:** (none — behavioral test deliverable)

**Dependencies:** Phases 1, 2

**Entry conditions:** Phases 1 and 2 complete.

**Exit conditions:** Behavioral test exists and passes asserting no trigger comment posted and verified-locally reported.

**Code path coverage:** tests-v2/behaviors/ — new behavioral test script.

**Cross-cutting SCs:** Behavioral test integrity — the test must assert agent behavior (no trigger comment, verified-locally reporting), not just file content. Must not be weakened to structural/string evidence.

**Interface boundaries:** The behavioral test runs via the tests-v2 harness (`behavior_run`), producing session.yaml artifacts for clean-room evaluation.

**State transitions:** No behavioral test for the no-op trigger removal → behavioral test exists and passes asserting the agent does not post a trigger comment. No behavioral test for verified-locally reporting → behavioral test exists and passes asserting the agent reports verified-locally.

**Cost frame:** Running the behavioral test costs minutes of execution time. Skipping means the no-op comment trigger regression ships to production and costs 1000× more to fix.

### Item 5 — Behavioral: create the no-op-trigger behavioral test

- [ ] 1. **Pre-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Run regression test patterns before the RED phase.

- [ ] 2. **Pre-regression verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify pre-regression results.

- [ ] 3. **RED** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - Write a failing behavioral enforcement test: create `.opencode/tests-v2/behaviors/git-workflow-pr-no-op-trigger.sh` asserting the agent does not post a no-op trigger comment and instead reports verified-locally.
  - The test FAILS because the no-op trigger removal is not yet in place (RED phase runs before GREEN).

- [ ] 4. **GREEN** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Ensure the behavioral test passes: the agent no longer posts a trigger comment and reports verified-locally.
  - The RED test now PASSES: the agent's actions in session.yaml show no `github_add_issue_comment` no-op call and verified-locally reporting.

- [ ] 5. **Post-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Run regression test patterns after the GREEN phase.

- [ ] 6. **Verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify the behavioral test deliverable: session.yaml shows the agent did not post a no-op trigger comment and reported verified-locally.

- [ ] 7. **Commit** (**inline**)
  - Stage the changed files and commit with a descriptive message.
  - The test and its implementation are committed as one atomic slice.

**Phase completion block:** Verify the behavioral test deliverable via verification-before-completion. If FAIL, remediate.

**Concern transition:** All phases complete. Proceed to post-implementation steps.

## Post-Implementation

- [ ] 1. **Audit** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence.
  - Adversarial audit of the deliverable.

- [ ] 2. **Z3 check** (**inline**)
  - Run `.opencode/tools/solve check --state-path ... --contract-path ...`.
  - Verify the phase DAG constraints hold.

- [ ] 3. **Structural checks** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`.
  - Run the finishing checklist (lint, typecheck, etc.).

- [ ] 4. **Pre-PR gate** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Read all SC verdicts; BLOCK if any FAIL.

- [ ] 5. **Regression check** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Final regression check before PR.

- [ ] 6. **Review prep** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`.
  - Prepare PR review context.

- [ ] 7. **Create PR** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`.
  - Create the pull request.

- [ ] 8. **Executive summary** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute completion task from completion-core")`.
  - Generate the completion executive summary.

## Exit Criteria

- [ ] C1: SC-1 verified PASS — `github_add_issue_comment` no-op trigger absent from create-pr.md Step 7.2.4.
- [ ] C2: SC-2 verified PASS — `--allow-empty` empty-push fallback absent from create-pr.md Step 7.2.4.
- [ ] C3: SC-3 verified PASS — `merge-base --is-ancestor` present in Step 7.2.4; `verified-locally` present in Step 7.2.2/7.2.5; "Computation triggered" absent; 7.2.x step numbers stable.
- [ ] C4: SC-4 verified PASS — `merge-base` present in enforcement-gate.md Step 1.5d; Step 1.5e cross-reference valid.
- [ ] C5: Behavioral test exists and passes asserting no trigger comment posted and verified-locally reported.
- [ ] C6: All phases complete in DAG order (Phase 1 → Phase 2 → Phase 3).
- [ ] C7: Audit PASS, Z3 check SAT, structural checks PASS, pre-PR gate PASS.
- [ ] C8: PR created and executive summary reported.
