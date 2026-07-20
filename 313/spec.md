## Problem

The `writing-plans` skill (parent) and its sub-skills (`writing-plans-creation`, `writing-plans-holistic`) have the same 6 structural defects that #1993 remediated in `spec-creation`, plus 3 additional issues. The skill was built before the #1993 remediation pattern was established and was never retrofitted.

## Scope

- Parent skill: `.opencode/skills/writing-plans/SKILL.md`
- Sub-skill: `.opencode/skills/writing-plans-creation/SKILL.md` + 18 task files + 22 contract templates
- Sub-skill: `.opencode/skills/writing-plans-holistic/SKILL.md` + 1 task file

## Defect Catalog

### Defect 1: Fake Dispatch Entries in Parent SKILL.md Trigger Dispatch Table

The parent SKILL.md Trigger Dispatch Table has 7 entries, but only 1 (`create`) is a real workflow entry point. The other 6 are internal pipeline steps that should NOT appear in the parent dispatch table:

| Entry | Status | Reason |
|-------|--------|--------|
| `create` | ✅ REAL | User-facing workflow entry point |
| `retroactive` | ❌ FAKE | Same pipeline as `create` — should be a sub-mode of `create`, not a separate dispatch entry |
| `update` | ❌ FAKE | Separate workflow — should be its own entry, but currently has `task()` calls in its task card (Defect 2) |
| `handoffs/spec-to-plan` | ❌ FAKE | Orphan — no orchestrator dispatches it; its logic duplicates `pre-plan-readiness` |
| `pre-plan-readiness` | ❌ FAKE | Internal pipeline step — should not be in parent dispatch table |
| `holistic-self-check` | ✅ REAL | User-facing workflow entry point (pre-completion check) |
| `completion` | ❌ FAKE | Internal pipeline step — should not be in parent dispatch table |

**Correct dispatch entries:** `create`, `update`, `holistic-self-check`. All others are internal pipeline steps that belong in the sub-skill's task file, not the parent's Trigger Dispatch Table.

### Defect 2: `task()`/`skill()` Calls in Task Cards (Dead Code)

8 task cards contain `task()` or `skill()` calls that sub-agents cannot execute:

| Task Card | Violation | Line |
|-----------|-----------|------|
| `retroactive.md` | 8 `task()` calls | Lines 14-30 |
| `update.md` | 1 `task()` call | Line 34 |
| `research.md` | 1 `skill()` call | Line 20 |
| `revisit.md` | 1 `skill()` call | Line 20 |
| `audit-fidelity.md` | 1 `skill()` call | Line 21 |
| `audit-concern.md` | 1 `skill()` call | Line 20 |
| `completion.md` | 1 `task()` call | Line 19 |
| `clean-room.md` | 2 `skill()`/`task()` references | Lines 9, 161 |

**Fix:** Replace `task()`/`skill()` calls with `(**orchestrator**)` dispatch indicators. The orchestrator handles all sub-agent dispatch from the SKILL.md Trigger Dispatch Table. Task cards contain only step procedures and artifact expectations.

### Defect 3: 21-Step Pipeline Stored in `create.md` Task Card, Not SKILL.md

The 21-step pipeline (Steps 1-22 with Z3 checks between each orchestrator dispatch) is defined in `create.md` lines 145-227. This is a pipeline definition, not a task procedure. The pipeline should be defined in the parent SKILL.md's Operating Protocol section, and `create.md` should reference it.

**Fix:** Move the pipeline definition to `writing-plans/SKILL.md` Operating Protocol. `create.md` becomes a thin task card that references the pipeline and defines only the create-specific entry/exit criteria.

### Defect 4: 22 Contract Templates with Unclear Wiring

The `contracts/` directory has 22 YAML templates. Their wiring to specific pipeline steps is unclear — there is no contract-to-step mapping table. The `create.md` task card references contracts by name (e.g., `contracts/create-output-template.yaml:research`) but the contract directory has no index.

**Fix:** Add a contract index file (`contracts/INDEX.md`) mapping each contract to its consuming step. Remove unused contracts. Ensure every contract is referenced by exactly one step.

### Defect 5: Artifact Extension Mismatch (`.md` vs `.yaml`)

`pre-plan-readiness.md` and `handoffs/spec-to-plan.md` reference analytical artifacts with `.md` extension (e.g., `blast-radius.md`, `concern-map.md`), but the actual artifacts produced by `spec-creation` use `.yaml` extension (e.g., `blast-radius.yaml`).

**Affected files:**
- `pre-plan-readiness.md` lines 31-37
- `handoffs/spec-to-plan.md` lines 47-53

**Fix:** Change all artifact references from `.md` to `.yaml`.

### Defect 6: Pipeline Numbering Mismatch (22 vs 21)

The parent SKILL.md says "22-step pipeline" (line 12, line 85), but `create.md` has 21 numbered steps (0-22 with Step 0 being a pre-flight gate, and steps 4a existing as a sub-step). The actual count is 21 pipeline steps + 1 pre-flight gate = 22 items, but the numbering is inconsistent.

**Fix:** Standardize on one count. The pipeline in `create.md` has 22 items (Step 0 + Steps 1-21), but Step 0 is a pre-flight gate, not a pipeline step. The pipeline itself is 21 steps. Resolve the inconsistency.

### Defect 7: Orphan `handoffs/spec-to-plan` Dispatch Entry

The `handoffs/spec-to-plan` task is listed in the parent SKILL.md Trigger Dispatch Table but no orchestrator dispatches it. Its logic (spec structural completeness verification) duplicates `pre-plan-readiness.md`. The task file references `{project_root}/tmp/` for its handoff manifest output.

**Fix:** Remove the orphan dispatch entry. Merge any unique logic into `pre-plan-readiness.md`. Remove `{project_root}/tmp/` references.

### Defect 8: `{project_root}/tmp/` References (Phantom Infrastructure)

Two task files reference `{project_root}/tmp/` paths that don't exist in the actual infrastructure:

| File | Line | Reference |
|------|------|-----------|
| `clean-room.md` | 15, 44, 142 | `{project_root}/tmp/{issue-N}/artifacts/clean-room-N.md` |
| `handoffs/spec-to-plan.md` | 17, 81 | `{project_root}/tmp/{issue-N}/artifacts/spec-to-plan-handoff-*.yaml` |

**Fix:** Remove all `{project_root}/tmp/` references. Use `.issues/{N}/` for persistent artifacts. For clean-room plans, pass the problem statement inline in the task context, not via a temp file.

### Defect 9: Hard-Coded Counts in Cross-References

The skill and task cards hard-code counts for items in other skills:

| Location | Hard-Coded Count | Problem |
|----------|-----------------|---------|
| `writing-plans/SKILL.md` line 12 | "22-step pipeline" | Drifts if pipeline steps change |
| `writing-plans/SKILL.md` line 85 | "22-Step Pipeline" | Same drift |
| `writing-plans-creation/SKILL.md` line 37 | "22 contract templates" | Drifts if contracts change |
| `create.md` line 8 | "21-step pipeline" | Contradicts SKILL.md "22-step" |
| `retroactive.md` line 5 | "21-step pipeline" | Same contradiction |
| `operating-protocol.md` lines 5, 9, 13, 17 | "22-Step Pipeline" | Same drift |

**Fix:** Replace all hard-coded counts with descriptive references:
- "the pipeline defined in `create.md`" instead of "22-step pipeline"
- "the contract templates in `contracts/`" instead of "22 contract templates"
- "the tasks listed in the Tasks section" instead of "18 tasks"

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Parent SKILL.md Trigger Dispatch Table contains only real workflow entry points (`create`, `update`, `holistic-self-check`) | `string` | grep for dispatch entries in SKILL.md |
| SC-2 | No `task()` or `skill()` calls remain in any task card under `writing-plans-creation/tasks/` or `writing-plans-holistic/tasks/` | `string` | grep for `task\(` and `skill\({` in all task files |
| SC-3 | Pipeline definition moved from `create.md` to parent SKILL.md Operating Protocol section | `string` | grep for pipeline steps in SKILL.md, verify create.md references it |
| SC-4 | Contract index file exists at `contracts/INDEX.md` mapping each contract to its consuming step | `structural` | `ls contracts/INDEX.md` |
| SC-5 | All analytical artifact references use `.yaml` extension (not `.md`) in `pre-plan-readiness.md` and `handoffs/spec-to-plan.md` | `string` | grep for `.md` artifact references in those files |
| SC-6 | Pipeline step count is consistent between SKILL.md and create.md (both say same number) | `string` | grep for "step pipeline" in both files |
| SC-7 | `handoffs/spec-to-plan` dispatch entry removed from parent SKILL.md Trigger Dispatch Table | `string` | grep for `handoffs/spec-to-plan` in SKILL.md |
| SC-8 | No `{project_root}/tmp/` references remain in any task file under `writing-plans-creation/tasks/` | `string` | grep for `project_root}/tmp/` in all task files |
| SC-9 | No hard-coded counts in cross-references — all use descriptive references instead | `string` | grep for `\d+-(step|task|contract)` patterns in SKILL.md and task files |

## Affected Files

- `.opencode/skills/writing-plans/SKILL.md` — Parent skill card (Trigger Dispatch Table, Operating Protocol, hard-coded counts)
- `.opencode/skills/writing-plans-creation/SKILL.md` — Sub-skill card (hard-coded contract count)
- `.opencode/skills/writing-plans-creation/tasks/create.md` — Pipeline definition, hard-coded count
- `.opencode/skills/writing-plans-creation/tasks/retroactive.md` — `task()` calls, hard-coded count
- `.opencode/skills/writing-plans-creation/tasks/update.md` — `task()` call
- `.opencode/skills/writing-plans-creation/tasks/research.md` — `skill()` call
- `.opencode/skills/writing-plans-creation/tasks/revisit.md` — `skill()` call
- `.opencode/skills/writing-plans-creation/tasks/audit-fidelity.md` — `skill()` call
- `.opencode/skills/writing-plans-creation/tasks/audit-concern.md` — `skill()` call
- `.opencode/skills/writing-plans-creation/tasks/completion.md` — `task()` call
- `.opencode/skills/writing-plans-creation/tasks/clean-room.md` — `{project_root}/tmp/` references, `skill()`/`task()` references
- `.opencode/skills/writing-plans-creation/tasks/pre-plan-readiness.md` — `.md` artifact extension mismatch
- `.opencode/skills/writing-plans-creation/tasks/handoffs/spec-to-plan.md` — Orphan dispatch entry, `.md` artifact extension mismatch, `{project_root}/tmp/` references
- `.opencode/skills/writing-plans-creation/tasks/operating-protocol.md` — Hard-coded count
- `.opencode/skills/writing-plans-creation/contracts/` — 22 contract templates (needs INDEX.md)

## Non-Goals

- Not changing the pipeline logic or step ordering
- Not adding new pipeline steps
- Not changing the plan format or output structure
- Not modifying `writing-plans-holistic` task logic (only cross-reference cleanup)
- Not removing contracts — only adding an index and removing unused ones

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Pipeline step renumbering breaks cross-references | Medium | High | Use stable step names, not numbers |
| Contract removal breaks downstream consumers | Low | High | Verify each contract has a consumer before removing |
| `{project_root}/tmp/` removal breaks clean-room workflow | Low | Medium | Pass problem statement inline in task context |
| Hard-coded count removal causes confusion | Low | Low | Replace with descriptive references that are self-maintaining |

## Decision Log

| Decision | Rationale |
|----------|-----------|
| Keep `update` as a real dispatch entry | It's a separate workflow (non-substantive spec revision) that doesn't go through the full create pipeline |
| Remove `retroactive` as separate dispatch entry | Retroactive plan creation is a sub-mode of `create` — the create task detects whether a plan exists and adjusts its research step accordingly |
| Remove `handoffs/spec-to-plan` | Orphan entry — its logic duplicates `pre-plan-readiness` |
| Remove `pre-plan-readiness` from parent dispatch table | Internal pipeline step — belongs in the sub-skill's task file |
| Remove `completion` from parent dispatch table | Internal pipeline step — belongs in the sub-skill's task file |
| Keep `holistic-self-check` as real dispatch entry | User-facing pre-completion check that can be invoked independently |

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
