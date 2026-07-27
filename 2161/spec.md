> **Full spec and artifacts: [`#2161`](https://github.com/michael-conrad/opencode-config/tree/issues-data/2161)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/2161/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Add spec lifecycle state labels to the opencode-config repository to track spec maturity through its lifecycle stages — from draft through review to plan-ready — using labels as the sole mechanism (no body status fields).

## Background

Specs currently have no lifecycle state tracking. The only labels applied are `needs-approval` (on creation) and `approved-for-*` (on authorization). There is no way to distinguish between:
- A newly created spec that needs work (draft)
- A spec blocked on research before review
- A spec currently under audit/review
- A spec that passed review and is sound
- A spec that has been freshness-checked and is ready for plan creation

This spec introduces 5 labels (`spec-draft`, `spec-needs-research`, `spec-under-review`, `spec-passed-review`, `spec-cleared`) that form a state machine tracking spec maturity. Labels are the mechanism — no body status fields are used (per the "Specs and Plans Are NOT Tracking Documents" rule).

## Not Included

- Authorization scope labels (`approved-for-*`) — unchanged, separate domain
- Issue state changes (open/closed) — unchanged
- Terminal state labels (superseded, abandoned) — handled by existing issue state + labels
- Spec body status fields — prohibited per tracking-document rule
- Changes to the `local-issues` CLI tool — labels are created via platform APIs, not via local-issues

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-draft` label exists on all platforms (GitHub opencode-config, GitHub .opencode, GitBucket) | `structural` | `gh label list` / `gb label list` confirms label exists |
| SC-2 | `spec-needs-research` label exists on all platforms | `structural` | `gh label list` / `gb label list` confirms label exists |
| SC-3 | `spec-under-review` label exists on all platforms | `structural` | `gh label list` / `gb label list` confirms label exists |
| SC-4 | `spec-passed-review` label exists on all platforms | `structural` | `gh label list` / `gb label list` confirms label exists |
| SC-5 | `spec-cleared` label exists on all platforms | `structural` | `gh label list` / `gb label list` confirms label exists |
| SC-6 | `spec-draft` is applied after spec creation (spec-creation create, issue-review analyze-and-spec) | `behavioral` | `opencode run` with spec creation prompt → verify `spec-draft` label on created issue |
| SC-7 | `spec-needs-research` is applied when triage identifies research need (issue-review triage) | `behavioral` | `opencode run` with triage prompt → verify `spec-needs-research` label applied |
| SC-8 | `spec-under-review` is applied when audit begins (audit evaluator) | `behavioral` | `opencode run` with audit start prompt → verify `spec-under-review` label applied |
| SC-9 | `spec-passed-review` is applied when audit PASS (audit evaluator, audit validator) | `behavioral` | `opencode run` with audit PASS prompt → verify `spec-passed-review` applied, `spec-under-review` removed |
| SC-10 | `spec-cleared` is applied at plan creation time (writing-plans create) | `behavioral` | `opencode run` with plan creation prompt → verify `spec-cleared` label applied |
| SC-11 | On spec revision: `spec-passed-review` and `spec-cleared` removed, `spec-draft` applied (revision-revocation) | `behavioral` | `opencode run` with revision prompt → verify label transition |
| SC-12 | Spec lifecycle labels documented in all three platform SKILL.md files (local, github-mcp, gitbucket-api) | `string` | `grep` for each label name in each SKILL.md file |
| SC-13 | No collision with existing `approved-for-*` labels | `structural` | Label name comparison — all `spec-*` prefix, no overlap with `approved-for-*` |
| SC-14 | No body status fields used for lifecycle tracking | `structural` | File inspection confirms no STATUS field in spec body |
| SC-15 | Terminal states (superseded, abandoned) handled by existing issue state + labels, not by spec lifecycle labels | `structural` | State machine analysis confirms no spec-lifecycle label for terminal states |

## Requirements

1. The system SHALL create five spec lifecycle labels (`spec-draft`, `spec-needs-research`, `spec-under-review`, `spec-passed-review`, `spec-cleared`) on all platforms (GitHub opencode-config, GitHub .opencode, GitBucket).
2. The system SHALL apply `spec-draft` after spec creation in `spec-creation/tasks/create.md` and `issue-review/tasks/analyze-and-spec.md`.
3. The system SHALL apply `spec-needs-research` when triage identifies a research need in `issue-review/tasks/triage.md`.
4. The system SHALL apply `spec-under-review` when audit begins in `audit/tasks/spec-audit-evaluator.md`.
5. The system SHALL apply `spec-passed-review` when audit PASS in `audit/tasks/spec-audit-evaluator.md` and `audit/tasks/spec-audit-validator.md`.
6. The system SHALL apply `spec-cleared` at plan creation time in `writing-plans/tasks/create.md`.
7. The system SHALL remove `spec-passed-review` and `spec-cleared` and apply `spec-draft` on spec revision in `approval-gate-scope/SKILL.md` (Trigger Dispatch Table — `revision-revocation` sub-task).
8. The system SHALL document spec lifecycle labels in all three platform SKILL.md files (`local/SKILL.md`, `github-mcp/SKILL.md`, `gitbucket-api/SKILL.md`).
9. The system SHALL NOT use body status fields for lifecycle tracking.
10. The system SHALL NOT collide with existing `approved-for-*` authorization scope labels.
11. The system SHALL handle terminal states (superseded, abandoned) using existing issue state and labels, not spec lifecycle labels.

## Items

| # | SC | Description |
|---|----|-------------|
| 1 | SC-1 | Create `spec-draft` label on all platforms |
| 2 | SC-2 | Create `spec-needs-research` label on all platforms |
| 3 | SC-3 | Create `spec-under-review` label on all platforms |
| 4 | SC-4 | Create `spec-passed-review` label on all platforms |
| 5 | SC-5 | Create `spec-cleared` label on all platforms |
| 6 | SC-6 | Apply `spec-draft` after spec creation in spec-creation create and issue-review analyze-and-spec |
| 7 | SC-7 | Apply `spec-needs-research` on triage research need in issue-review triage |
| 8 | SC-8 | Apply `spec-under-review` on audit start in audit evaluator |
| 9 | SC-9 | Apply `spec-passed-review` on audit PASS in audit evaluator and audit validator |
| 10 | SC-10 | Apply `spec-cleared` at plan creation time in writing-plans create |
| 11 | SC-11 | Reset labels on spec revision in revision-revocation |
| 12 | SC-12 | Document labels in platform SKILL.md files |
| 13 | SC-13 | Verify no collision with `approved-for-*` labels |
| 14 | SC-14 | Verify no body status fields used |
| 15 | SC-15 | Verify terminal states handled by existing mechanisms |

## Phases

| Phase | Scope | SCs |
|-------|-------|-----|
| Phase 1 | Label creation — create all 5 spec lifecycle labels on all platforms | SC-1, SC-2, SC-3, SC-4, SC-5, SC-13 |
| Phase 2 | Label application — apply labels at each lifecycle stage in the relevant task files | SC-6, SC-7, SC-8, SC-9, SC-10, SC-11, SC-14 |
| Phase 3 | Documentation — document labels in platform SKILL.md files | SC-12 |

## Dependencies

- Pre-spec inspection (completed) — confirmed no collision with existing labels
- Research card consultation (completed) — no research cards found
- Decomposition (completed) — 3 phases identified
- Analytical artifacts (completed) — blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment, pipeline readiness all generated

## Traceability

| Requirement | SCs | Phase |
|-------------|-----|-------|
| R1 (Create labels) | SC-1, SC-2, SC-3, SC-4, SC-5 | Phase 1 |
| R2 (Apply spec-draft on creation) | SC-6 | Phase 2 |
| R3 (Apply spec-needs-research on triage) | SC-7 | Phase 2 |
| R4 (Apply spec-under-review on audit start) | SC-8 | Phase 2 |
| R5 (Apply spec-passed-review on audit PASS) | SC-9 | Phase 2 |
| R6 (Apply spec-cleared on plan creation) | SC-10 | Phase 2 |
| R7 (Reset labels on revision) | SC-11 | Phase 2 |
| R8 (Document in SKILL.md) | SC-12 | Phase 3 |
| R9 (No body status fields) | SC-14 | Phase 2 |
| R10 (No collision with approved-for-*) | SC-13 | Phase 1 |
| R11 (Terminal states handled by existing mechanisms) | SC-15 | Phase 1 |

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-26 | Added `## Phases` section defining Phase 1/2/3 with scope and SCs | Validation finding #1 — Traceability table referenced phases but no Phases section existed | Spec revision pipeline |
| 2026-07-26 | Fixed R7 path from `approval-gate-scope/tasks/revision-revocation.md` to `approval-gate-scope/SKILL.md` (Trigger Dispatch Table) | Validation finding #2 — referenced file does not exist; correct location is the SKILL.md Trigger Dispatch Table | Spec revision pipeline |
| 2026-07-26 | Added R11 requirement and Traceability entry for SC-15 (terminal states) | Validation finding #3 — SC-15 had no corresponding requirement or Traceability entry | Spec revision pipeline |
