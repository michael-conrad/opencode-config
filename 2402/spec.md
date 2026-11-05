---
title: "[SPEC-FIX] finishing-a-development-branch checklist mis-applies rules: missing co-authored-by commit trailers classified as blocking FAIL forcing a force-push authorization decision"
remote_issue: 2402
remote_url: https://github.com/michael-conrad/.opencode/issues/2402
labels:
  - approved-for-pr
  - needs-approval
  - spec-draft
---

> **Full spec and artifacts: [`.opencode/.issues/2402/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2402)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2402/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The `finishing-a-development-branch` checklist task flags missing Co-authored-by commit trailers on a feature branch as a `MISSING-ELEMENT` readiness blocker, and its guidance surfaces a "force-push authorization" decision to the developer. On an agent-created, unmerged feature branch, this forces an unnecessary developer round-trip for a remediation that is already within the producing agent's authority. |
| 2 | **Root Cause / Motivation** | The checklist (`checklist.md`) classifies missing trailers as a decision-requiring blocker with no auto-remediation path. This mis-applies the generic force-push authorization gate (`000-critical-rules.md`) to the agent-own-branch case, contradicting the agent-owned remediation mandate and the existing force-push carve-out precedent in `create-pr.md` (the "Step 7.2.3: Rebase on Stale Base" force-push note that force push is authorized because the PR is not yet merged and the branch has not been shared). A concrete recorded instance (`.opencode/tmp/2241-finishing-checklist-evidence.md`) documents 36 commits with absent trailers flagged as a developer-authorization blocker. |
| 3 | **Approach Chosen** | Reclassify missing-co-author-trailer on the agent's own unmerged feature branch as an auto-fixable `MISSING-ELEMENT`, add an explicit agent-owned remediation procedure (amend/squash own commits to add trailers, then force-push `--force-with-lease` the agent's own branch), auto-fix missing new-file footer bylines, and add a scope guard limiting the auto-force-push carve-out to the agent's own unmerged, unshared branch. |
| 4 | **Alternatives Considered & Why Discarded** | **Alternative: leave the developer-in-the-loop blocker.** Discarded because it directly contradicts the agent-owned remediation mandate and the existing force-push carve-out precedent, and produced an unnecessary developer round-trip. **Alternative: weaken or skip the trailer check.** Discarded because trailer/byline presence is mandatory per `080-code-standards.md`; the auto-fix adds missing trailers, never skips the check. |
| 5 | **Key Design Decisions** | (1) The auto-remediation is scoped strictly to an agent-created, unmerged, unshared feature branch — never a shared, merged, or trunk branch. (2) The remediation reuses the existing sanctioned force-push mechanism (`--force-with-lease`) and trailer format already established across the deck; no new force-push mechanism or trailer schema is introduced. (3) Trailer auto-fix at finishing complements, rather than replaces, the PR-time squash that applies the repo-standard trailers. |
| 6 | **User Intent / Original Prompt** | A developer was asked to make a force-push authorization decision for a trailer remediation that was already within the `for_pr` scope on an agent-created branch. The fix should let the producing agent auto-remediate trailers and bylines on its own unmerged branch without soliciting a developer decision. |

## 2. Not Included

- **[Change to attribution requirements]** — `080-code-standards.md` co-author trailer and footer byline requirements remain mandatory and unchanged; this spec changes only their classification and remediation at finishing.
- **[General force-push authorization]** — The generic force-push authorization gate (`000-critical-rules.md`) remains in force for all branches except the agent's own, unmerged, unshared feature branch.
- **[Squash/PR pipeline trailer application]** — The PR-time squash step that applies repo-standard co-author trailers is unchanged.
- **[Implementation checkpoint commit policy]** — Trailer-free WIP implementation commits remain permitted; this spec clarifies finishing-time remediation.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The `finishing-a-development-branch` checklist SHALL classify missing Co-authored-by commit trailers on an agent-created, unmerged, unshared feature branch as an auto-fixable MISSING-ELEMENT (remediation) rather than a decision-requiring blocker that surfaces a force-push authorization decision to the developer. | behavioral | Run `.opencode/tests-v2/behaviors/finish-checklist-trailer-agent-own-remediation.sh` via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`; assert stderr shows the agent does NOT solicit a developer force-push authorization decision and DOES route trailer absence to agent-owned auto-remediation. |
| SC-2 | The `finishing-a-development-branch` checklist and prepare tasks SHALL include an explicit agent-owned remediation procedure: amend or squash the agent's own commits to add repo-standard Co-authored-by trailers, then force-push the agent's own branch with `--force-with-lease`, without soliciting a developer force-push decision. | behavioral | Run `.opencode/tests-v2/behaviors/finish-trailer-auto-remediation-no-solicitation.sh` via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`; assert stderr shows the agent adds trailers via amendment/squash and force-pushes with `--force-with-lease`, and does NOT present a force-push authorization question to the developer. |
| SC-3 | The `finishing-a-development-branch` checklist SHALL auto-fix missing "Co-authored with AI:" footer bylines in new files via the producing agent (preserving any existing bylines) rather than escalating as a decision-requiring blocker. | behavioral | Run `.opencode/tests-v2/behaviors/finish-footer-byline-auto-fix.sh` via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`; assert stderr shows the producing agent adds the missing footer byline and does not escalate to the developer. |
| SC-4 | The `finishing-a-development-branch` checklist SHALL include a scope guard that confines the auto-force-push carve-out to the agent's own, unmerged, unshared feature branch. | structural | Grep the checklist remediation procedure for a stated agent-own-branch scope guard (`.opencode/tests-v2/behaviors/finish-forcepush-scope-guard.sh` contains the guard assertion). |
| SC-5 | The `finishing-a-development-branch` checklist SHALL refuse auto-force-push on a shared, merged, or trunk branch, deferring to the generic force-push authorization gate. | behavioral | Run `.opencode/tests-v2/behaviors/finish-forcepush-scope-guard.sh` via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`; assert stderr shows the agent refuses to auto-force-push on a shared/merged/trunk branch and defers to the generic authorization gate. |

## 4. Requirements

- R-1. The finishing checklist SHALL NOT classify missing Co-authored-by trailers on an agent-created, unmerged feature branch as a decision-requiring blocker that surfaces a force-push authorization decision.
- R-2. The finishing checklist SHALL classify trailer absence on the agent's own unmerged feature branch as an agent-owned auto-fixable MISSING-ELEMENT.
- R-3. The finishing checklist SHALL provide an agent-owned remediation procedure that amends or squashes the agent's own commits to add repo-standard Co-authored-by trailers and force-pushes with `--force-with-lease`.
- R-4. The agent-owned trailer remediation SHALL use `--force-with-lease` and SHALL apply only to the agent's own, unmerged, unshared feature branch.
- R-5. The finishing checklist SHALL auto-fix missing "Co-authored with AI:" footer bylines in new files via the producing agent, preserving existing bylines.
- R-6. The finishing checklist SHALL include a scope guard that confines the auto-force-push carve-out to the agent's own unmerged, unshared branch and defers shared/merged/trunk branches to the generic force-push authorization gate.
- R-7. Trailer auto-fix SHALL add missing trailers rather than skip or weaken the mandatory co-author attribution checks.

## 5. Items

### Item 1 (SC-1): Reclassify missing trailers on agent-own branch as auto-fixable MISSING-ELEMENT

- RED: Behavioral test asserts the agent does NOT solicit a developer force-push decision when the finishing checklist finds missing trailers on its own unmerged branch (currently fails because the checklist flags it as a decision-requiring blocker).
- GREEN: Update the checklist's "Co-authored-by trailers present" item and Finding Classification table so trailer absence on an agent-own branch routes to auto-fix, not blocker.
- verify: Run `finish-checklist-trailer-agent-own-remediation.sh`; assert stderr shows agent-owned auto-remediation, no developer solicitation.
- commit: `finishing-a-development-branch/tasks/checklist.md` plus the behavioral test.

### Item 2 (SC-2): Add agent-owned trailer remediation procedure

- RED: Behavioral test asserts the agent adds trailers and force-pushes with `--force-with-lease` without soliciting a developer force-push decision (currently fails — no remediation procedure exists).
- GREEN: Add an explicit remediation procedure to checklist.md and prepare.md describing amend/squash to add trailers then `--force-with-lease` push on the agent's own branch.
- verify: Run `finish-trailer-auto-remediation-no-solicitation.sh`; assert stderr shows the amendment/force-push and no authorization question.
- commit: `finishing-a-development-branch/tasks/checklist.md`, `prepare.md`, plus the behavioral test.

### Item 3 (SC-3): Auto-fix missing new-file footer bylines

- RED: Behavioral test asserts the producing agent auto-fixes missing "Co-authored with AI:" footer bylines rather than escalating (currently fails — byline absence is escalated).
- GREEN: Update the checklist's "AI co-authored attribution in new files" item and the prepare verification step so the producing agent adds missing footer bylines, preserving existing ones.
- verify: Run `finish-footer-byline-auto-fix.sh`; assert stderr shows the byline being added and existing bylines preserved.
- commit: `finishing-a-development-branch/tasks/checklist.md`, `prepare.md`, plus the behavioral test.

### Item 4 (SC-4, SC-5): Add agent-own-branch scope guard

- RED: Structural test asserts the remediation procedure documents the agent-own-branch scope guard (currently fails — no guard exists). Behavioral test asserts the auto-force-push guard refuses on a shared/merged/trunk branch and defers to the generic authorization gate (currently fails — no guard exists).
- GREEN: Add a scope guard to the checklist remediation procedure confining auto-force-push to the agent's own unmerged, unshared branch.
- verify: Run `finish-forcepush-scope-guard.sh` (behavioral, SC-5) and grep the checklist remediation procedure for the scope guard (structural, SC-4).
- commit: `finishing-a-development-branch/tasks/checklist.md`, plus the behavioral test.

## 6. Dependencies

- **Reference:** `080-code-standards.md` (mandatory co-author attribution)
- **Relationship:** Source of the trailer/byline mandatory requirement; unchanged, but read as the authority the auto-fix satisfies.
- **Status:** Satisfied (existing).
- **Reference:** `git-workflow-pr/tasks/pr-creation/create-pr.md` ("Step 7.2.3: Rebase on Stale Base" force-push note)
- **Relationship:** Precedent authority for agent-owned force-push on an unmerged, unshared branch; reused, not modified.
- **Status:** Satisfied (existing).
- **Reference:** `finishing-a-development-branch/SKILL.md` (agent-owned remediation mandate)
- **Relationship:** Governing principle that the producing agent fixes its own output defects autonomously.
- **Status:** Satisfied (existing).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1, R-2 | SC-1 | Phase 1 |
| R-3, R-4 | SC-2 | Phase 2 |
| R-5 | SC-3 | Phase 3 |
| R-6 | SC-4, SC-5 | Phase 4 |
| R-7 | SC-1, SC-2 | Phase 1, Phase 2 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| finishing checklist | code | `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` | read (primary source of defect) |
| finishing prepare | code | `.opencode/skills/finishing-a-development-branch/tasks/prepare.md` | read (secondary source of defect) |
| finishing SKILL.md | code | `.opencode/skills/finishing-a-development-branch/SKILL.md` | read (agent-owned remediation mandate) |
| commit-prep task | code | `.opencode/skills/git-workflow-commit/tasks/commit-prep.md` | read (trailer format authority) |
| implementation task | code | `.opencode/skills/git-workflow-commit/tasks/implementation.md` | read (checkpoint commits legitimately lack trailers) |
| squash-push task | code | `.opencode/skills/git-workflow-pr/tasks/pr-creation/squash-push.md` | read (trailer application via squash) |
| create-pr task | code | `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` | read (force-push carve-out precedent) |
| 080-code-standards | code | `.opencode/guidelines/080-code-standards.md` | read (mandatory attribution requirement) |
| 000-critical-rules | code | `.opencode/guidelines/000-critical-rules.md` | read (generic force-push authorization gate) |
| behavioral evidence | file | `.opencode/tmp/2241-finishing-checklist-evidence.md` | read (concrete recorded instance of the defect) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the behavioral trailer-classification test costs minutes of execution time. Skipping means the checklist keeps mis-classifying trailer absence as a decision-requiring blocker, forcing an unnecessary developer round-trip on every affected branch — surfacing as a behavioral defect at 1000× the fix cost.
- SC-2: Running the behavioral auto-remediation test costs minutes of execution time. Skipping means agents keep stalling on a developer force-push decision instead of self-remediating, surfacing as a behavioral defect at 1000× the fix cost.
- SC-3: Running the behavioral byline-auto-fix test costs minutes of execution time. Skipping means missing footer bylines keep being escalated as blockers instead of fixed by the producing agent, surfacing as a behavioral defect at 1000× the fix cost.
- SC-4: Running the scope-guard structural test costs minutes of execution time. Skipping means the agent-own-branch confinement could be lost without detection — surfacing as a critical violation at 1000× the fix cost.
- SC-5: Running the behavioral scope-guard test costs minutes of execution time. Skipping means the auto-force-push carve-out on shared/merged/trunk branches remains undetected — a critical violation surfacing at 1000× the fix cost.

## 11. Edge Cases

- **Input boundaries:** A branch with zero commits, a single-commit branch missing a trailer, and a multi-commit branch missing trailers SHALL all resolve to agent-owned auto-remediation when on the agent's own unmerged branch.
- **State transitions:** `branch_complete_but_trailer_missing` → `trailer_remediated_by_agent` → `branch_ready_for_pr` when the branch is agent-owned/unmerged; the guarded branch SHALL route to the generic authorization gate instead.
- **Failure modes:** If the branch is shared with another developer, merged, or the trunk, the scope guard SHALL refuse auto-force-push and defer to the generic force-push authorization gate. If the agent attempts `--force` instead of `--force-with-lease`, the remediation SHALL fail.
- **Concurrency:** SC-3 (footer byline auto-fix) is independent of SC-1/SC-2 (commit trailer remediation) and may run in parallel; SC-4/SC-5 (scope guard) are companions to SC-2.
- **Recovery:** If a behavioral test fails, the affected checklist/prepare text is corrected and the test re-run until it passes.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-01 | Initial spec creation from analysis artifacts. | Bug-fix spec for the finishing-a-development-branch checklist trailer/byline mis-classification. | spec-creation pipeline |
| 2026-09-01 | Decomposed compound SC-4 into atomic SC-4 (confine-to-own-branch, structural) and SC-5 (refuse-on-shared/merged/trunk, behavioral); updated Items, Traceability, Edge Cases, and Cost Frame. Replaced line-number references in the preamble and Dependencies with stable anchors pointing to the `create-pr.md` "Step 7.2.3: Rebase on Stale Base" force-push note. | Validation findings: SC-4 compound SC bundling two verification targets; line-number references violate stable-anchor rule. | validation |

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
