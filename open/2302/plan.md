---
plan_schema_version: "1.0"
issue: 2302
title: "Regenerate plan when spec is revised — prevent premature halt under for_pr scope"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
---

# Implementation Plan — #2302 — Regenerate Plan When Spec Is Revised

**Goal:** Introduce the spec-revision → plan-regeneration linkage so that a revised spec always regenerates its linked plan, and ensure `for_pr` scope spec-revision + plan-regeneration does not halt the pipeline before `pr_created`.

**Architecture:** Add the missing linkage in the spec-creation revision pipeline. When a spec revision is detected, the pipeline checks for an existing linked plan and regenerates it against the revised spec's SC set before any downstream gate runs. This makes the plan always current relative to the spec, so the coherence gate passes and the orchestrator can continue the pipeline to `pr_created` under `for_pr` scope instead of halting. The regeneration is an automatic consequence of revision, not a manual corrective step.

**Files:**
- `.opencode/skills/spec-creation/` (spec revision pipeline)
- `.opencode/skills/writing-plans/` (plan regeneration linkage)
- `.opencode/skills/approval-gate/` (scope handling on spec revision)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Spec-revision → plan-regeneration linkage | `test-driven-development` | `red` | `.opencode/skills/spec-creation/`, `.opencode/skills/writing-plans/` | SC-1, SC-2 | — |
| 2 — for_pr scope continuation | `test-driven-development` | `red` | `.opencode/skills/approval-gate/` | SC-3 | 1 |

---

## Phase Details

### Phase 1 — Spec-revision → plan-regeneration linkage

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/spec-creation/`, `.opencode/skills/writing-plans/` |
| SCs | SC-1, SC-2 |
| Depends On | — |

**Context:**
```yaml
linkage: "spec-creation revise triggers plan regeneration"
regeneration: "writing-plans revise regenerates against revised SC set"
sc_ids: [SC-1, SC-2]
```

**Procedure:**
- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test asserting that when a spec is revised, the linked plan (if it exists) is regenerated to match the revised spec's SC set. **→ SC-1**
- [ ] 2. **GREEN (**sub-agent**).** Implement the change that makes the RED test pass — add the spec-revision → plan-regeneration linkage in the spec-creation revision pipeline. **→ SC-1**
- [ ] 3. **Commit (**inline**).** Stage and commit the SC-1 test + change together as one atomic slice.
- [ ] 4. **RED (**sub-agent**).** Write a failing enforcement test asserting that plan regeneration is an automatic consequence of spec revision, not a manual corrective step. **→ SC-2**
- [ ] 5. **GREEN (**sub-agent**).** Implement the change that makes the RED test pass — make regeneration automatic within the revision pipeline. **→ SC-2**
- [ ] 6. **Commit (**inline**).** Stage and commit the SC-2 test + change together as one atomic slice.

### Phase 2 — for_pr scope continuation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/approval-gate/` |
| SCs | SC-3 |
| Depends On | 1 |

**Context:**
```yaml
scope: "for_pr"
halt_at: "pr_created"
sc_ids: [SC-3]
```

**Procedure:**
- [ ] 7. **RED (**sub-agent**).** Write a failing enforcement test asserting that under `for_pr` scope, spec revision + plan regeneration does not cause a premature halt before `pr_created`. **→ SC-3**
- [ ] 8. **GREEN (**sub-agent**).** Implement the change that makes the RED test pass — adjust approval-gate scope handling so the pipeline continues to `pr_created`. **→ SC-3**
- [ ] 9. **Commit (**inline**).** Stage and commit the SC-3 test + change together as one atomic slice.

---

## Exit Criteria

- [ ] C1. When a spec is revised, the linked plan (if it exists) is regenerated to match the revised spec's SC set (SC-1)
- [ ] C2. Plan regeneration is an automatic consequence of spec revision, not a manual corrective step (SC-2)
- [ ] C3. Under `for_pr` scope, spec revision + plan regeneration does not cause a premature halt before `pr_created` (SC-3)
- [ ] C4. All SCs (SC-1, SC-2, SC-3) are covered by at least one phase
- [ ] C5. No circular dependencies in the phase DAG (phase_1 → phase_2)

---

## lifecycle_events

- **timestamp:** 2026-08-20T03:45:42Z
- **event:** plan_created
- **plan_file:** `.issues/2302/plan.md`
- **phase_count:** 2
