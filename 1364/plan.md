---
plan_schema_version: "1.0"
issue: 1364
title: "for_pr scope model routes through executing-plans instead of skipping to PR"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #1364 — for_pr scope routes through executing-plans

Issue: https://github.com/michael-conrad/.opencode/issues/1364

**Goal:** Eliminate the for_pr gap-fill bypass where the agent jumps straight to PR creation without executing the plan, by adding a Pre-Flight + Pipeline model to the authorization scope table, a mandatory executing-plans routing rule, a plan-reading mandate in a new executing-plans skill, and behavioral enforcement that the agent routes through executing-plans (not direct PR creation).

**Architecture:** Create a new `executing-plans` skill with a mandatory plan-reading step that reads the plan file and dispatches each phase through the implementation pipeline in sequence. Update the `approval-gate` Authorization Scope Model `for_pr` row from a single Gap-Fill column (which conflated "auto-PR" as a standalone action) to two columns — Pre-Flight (auto-create spec+plan+auto-approve) and Pipeline (execute plan via executing-plans) — removing "auto-PR" as a gap-fill action so the PR becomes the output of plan execution. Add a routing rule: for_pr with an existing plan MUST dispatch executing-plans; direct PR creation without plan execution is a critical violation. Add two behavioral tests (existing-plan and missing-plan scenarios) that verify the agent dispatches executing-plans in stderr with no direct `git commit` / `github_create_pull_request`.

**Files:**
- `.opencode/skills/executing-plans/` (new — SKILL.md + task cards)
- `.opencode/skills/approval-gate/SKILL.md`
- `.opencode/tests-v2/behaviors/`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Create executing-plans skill with plan-reading mandate | `test-driven-development` | `red` | `.opencode/skills/executing-plans/` | SC-5 | — |
| 2 — Update approval-gate scope model and routing rule | `test-driven-development` | `red` | `.opencode/skills/approval-gate/SKILL.md` | SC-3, SC-4 | 1 |
| 3 — Behavioral enforcement of for_pr routing | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/` | SC-1, SC-2 | 1, 2 |

---

## Phase Details

### Phase 1 — Create executing-plans skill with plan-reading mandate

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/executing-plans/` (new SKILL.md + task cards) |
| SCs | SC-5 |
| Depends On | — |

**Context:**
```yaml
skill_name: executing-plans
skill_path: ".opencode/skills/executing-plans/"
mandatory_step: read the plan file and dispatch each phase through the implementation pipeline in sequence
evidence_verification: grep for the plan-reading step text in executing-plans/SKILL.md
```

**Procedure:**
1. Run the coherence gate and baseline check (clean-room) to confirm the plan faithfully derives from the approved spec #1364 and that `.opencode/skills/executing-plans/` does not currently exist.
2. **Item 1 (SC-5)** — Pre-clean stale artifacts, then run RED (assert the plan-reading mandate step is absent) → GREEN (create `.opencode/skills/executing-plans/` with SKILL.md and task cards, adding the mandatory step: read the plan file and dispatch each phase through the implementation pipeline in sequence) → post-regression → verify (grep confirms the plan-reading step text in executing-plans/SKILL.md) → commit the skill creation.
3. Run the **Phase 1 VbC** (clean-room) verifying SC-5 is clean PASS (string evidence).

### Phase 2 — Update approval-gate scope model and routing rule

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/approval-gate/SKILL.md` |
| SCs | SC-3, SC-4 |
| Depends On | 1 |

**Context:**
```yaml
table_columns: [Scope, HALT After, Pre-Flight, Pipeline, PR Strategy]
for_pr_pre_flight: "auto-create spec+plan+auto-approve"
for_pr_pipeline: "execute plan via executing-plans"
remove_action: "auto-PR"
routing_rule: "for_pr with existing plan MUST call executing-plans; direct PR creation without plan execution is a critical violation"
evidence_verification: grep for Pre-Flight/Pipeline column headers and the routing rule text in approval-gate/SKILL.md
```

**Procedure:**
1. Confirm Phase 1 is complete and its VbC passed (SC-5 clean PASS — the executing-plans skill exists) before starting the approval-gate work.
2. **Item 2 (SC-3)** — Pre-clean stale artifacts, then run RED (assert the new Pre-Flight + Pipeline column headers are absent) → GREEN (update the `for_pr` row to use Pre-Flight + Pipeline columns, removing the auto-PR gap-fill action) → post-regression → verify (grep confirms the Pre-Flight and Pipeline column headers in approval-gate/SKILL.md) → commit the scope table change.
3. **Item 3 (SC-4)** — Pre-clean stale artifacts, then run RED (assert the routing rule text is absent) → GREEN (add the mandatory routing rule: for_pr with an existing plan MUST dispatch executing-plans; direct PR creation without plan execution is a critical violation) → post-regression → verify (grep confirms the routing rule text in approval-gate/SKILL.md) → commit the routing rule change.
4. Run the **Phase 2 VbC** (clean-room) verifying SC-3 and SC-4 are clean PASS (string evidence).

### Phase 3 — Behavioral enforcement of for_pr routing

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/` |
| SCs | SC-1, SC-2 |
| Depends On | 1, 2 |

**Context:**
```yaml
behavioral_test_dir: ".opencode/tests-v2/behaviors/"
scenario_1: for_pr scope with existing plan routes through executing-plans, not direct PR creation
scenario_2: for_pr scope without existing plan auto-creates plan then executes it
prompt_type: real-domain task (not prose-recall) per tests-v2/AGENTS.md §11
primary_evidence: session.yaml (SQLite DB export) via clean-room evaluation
fixture_issues_dir: ".opencode/tests-v2/behaviors/fixtures/issues/"
```

**Procedure:**
1. Confirm Phase 1 and Phase 2 are complete and their VbC passed (executing-plans exists, routing rule present) before creating the behavioral tests.
2. **Item 4 (SC-1)** — Pre-clean stale artifacts, then run RED (create a behavioral test asserting the agent, under for_pr scope with an existing plan, routes through executing-plans and does not directly call `git commit` / `github_create_pull_request`; the test fails while the routing rule is absent) → GREEN (add the fixture and behavioral test script; the agent must dispatch executing-plans and read the plan) → post-regression → verify (clean-room sub-agent reads session.yaml and confirms executing-plans dispatch with no direct git commit / github_create_pull_request) → commit the behavioral test.
3. **Item 5 (SC-2)** — Pre-clean stale artifacts, then run RED (create a behavioral test asserting the agent, under for_pr scope with no existing plan, auto-creates a plan then dispatches executing-plans; the test fails while the routing rule is absent) → GREEN (add the fixture and behavioral test script; the agent must create the plan then execute it via executing-plans) → post-regression → verify (clean-room sub-agent reads session.yaml and confirms plan creation followed by executing-plans dispatch) → commit the behavioral test.
4. Run the **Phase 3 VbC** (clean-room) verifying SC-1 and SC-2 are clean PASS (behavioral evidence from session.yaml).

---

## Exit Criteria

- [ ] C1. SC-5 PASS: `executing-plans` skill exists with a mandatory plan-reading step (read plan file, dispatch each phase through the implementation pipeline in sequence).
- [ ] C2. SC-3 PASS: Authorization Scope Model `for_pr` row updated with Pre-Flight + Pipeline columns; `auto-PR` removed as a gap-fill action.
- [ ] C3. SC-4 PASS: approval-gate skill contains the routing rule mandating executing-plans dispatch for for_pr with an existing plan.
- [ ] C4. SC-1 PASS: Behavioral test verifies for_pr with existing plan routes through executing-plans, not direct PR creation (session.yaml evidence).
- [ ] C5. SC-2 PASS: Behavioral test verifies for_pr without existing plan auto-creates plan then executes it via executing-plans (session.yaml evidence).

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-24T13:15:18Z | `plan_created` | Plan file `.opencode/.issues/1364/plan.md` created, phase count = 3 |
