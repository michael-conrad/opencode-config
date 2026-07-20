## Objective

Shift the `writing-plans` skill from producing micromanaging per-step implementation instructions ("exact code, exact commands, exact file paths", "2-5 minutes per step") to producing phase-level outcome-focused plans. The TDD cycle per item (RED→GREEN→adversarial audit) remains a **structural mandate** — it is a non-waivable verification protocol, not a script the implementing agent must follow keystroke-by-keystroke.

## Problem

The writing-plans skill currently enforces that plans contain:

- "Exact code, exact commands, exact file paths" — `plan-structure.md` Step 5
- "Each step is one action (2-5 minutes)" — `plan-structure.md` Step 5
- Rejection of abstract-but-legitimate guidance like "Add validation", "Handle edge cases", "Add appropriate error handling" as plan failures — `validate.md` Lines 34-38

This treats the implementing agent as a script runner that must be told exactly what to type, not as an intelligent engineer. The result: plans are over-prescriptive, fragile (any deviation breaks the "exact" instructions), and waste effort on specifying keystrokes instead of outcomes.

Meanwhile, the TDD mandate per `091-incremental-build.md` already correctly defines the principle-level requirement: RED before GREEN, decomposition, verification evidence. The problem is that writing-plans re-implements this as a rigid script.

## Scope

**In scope:**
- `.opencode/skills/writing-plans/SKILL.md` — overview line, operating protocol points 3 and 4
- `.opencode/skills/writing-plans/tasks/create/plan-structure.md` — Step 5 rewrite, add Plan Autonomy Gate
- `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` — update references to match
- `.opencode/skills/writing-plans/tasks/validate.md` — relax abstract-guidance rejection patterns
- `.opencode/tests/behaviors/plan-autonomy-gate.sh` — new behavioral enforcement test

**Out of scope:**
- `091-incremental-build.md` — no change needed (already principle-level)
- `spec-creation` — already correctly WHAT-level
- `brainstorming` — already correctly WHAT-level
- `executing-plans` — thin routing layer, no substantive change needed

## Approach

### Phase 1: Revise `plan-structure.md`

**Step 5 rewrite:** Replace micromanagement requirements with phase-level item definitions:

- Items define **what concern they address** and **what verification outcomes prove success**
- Per-item TDD cycle kept as verification protocol reference (not implementation recipe): "Every item must have a test written before implementation code (RED) and pass after implementation (GREEN)"
- No "exact code, exact commands, exact file paths" — the agent determines HOW to implement
- No "2-5 minutes per step" — the agent organizes its own work

**Add Step 3.6 Plan Autonomy Gate:**

Analogous to the spec's boundary check. Question: *"Could two implementing agents produce valid but different implementations from this plan?"* If no — if the plan only permits one exact implementation — it is too prescriptive. Items must be reworded to outcomes.

### Phase 2: Revise `validate.md`

**Relax abstract-guidance rejection:**

Remove from plan-failure list:
- "Add appropriate error handling" → legitimate phase-level guidance
- "Add validation" / "Handle edge cases" → legitimate phase-level guidance  
- "Must specify actual code" → the plan is not a code editor
- "Steps describing what to do without showing how" → "what to do" IS the plan's job

Reclassify these from `VERIFICATION-GAP / flag-for-review` to advisory (plan author may choose to be more specific, but it's not a validation failure).

**Keep:** Placeholder detection (TBD/TODO), symbol consistency, spec reference check, testability requirement (SCs with executable commands), file structure completeness, sub-issue parent check.

### Phase 3: Revise `writing-plans/SKILL.md`

- **Overview line:** Remove "Every step is one action (2-5 min)"
- **Protocol pt 3:** Change "TDD steps mandatory: each step is RED→GREEN→REFACTOR within tasks" to "TDD cycle mandatory per item: RED test before GREEN implementation, adversarial audit verification"
- **Protocol pt 4:** Change "No placeholders: exact file paths, exact function/class names, exact commands" to "No placeholders: phase concerns, deliverables, and verification outcomes must be concrete"

### Phase 4: Behavioral Enforcement Test

Create `.opencode/tests/behaviors/plan-autonomy-gate.sh`:

**RED scenario:** A plan containing "Add validation for edge cases" without specifying exact code paths should pass validation (not be rejected as "must specify actual code"). Test verifies the validate task does not flag abstract-but-legitimate phase-level guidance as a plan failure.

## Success Criteria

| ID | Criterion | Verification |
|----|-----------|-------------|
| SC-1 | Plans no longer require "exact code, exact commands, exact file paths" per item | No occurrence of "exact code" or "exact commands" in writing-plans task files |
| SC-2 | Plans no longer mandate "2-5 minutes per step" granularity | No occurrence of "2-5 minutes" in writing-plans task files |
| SC-3 | Plan Autonomy Gate exists: plans that permit only one implementation path are flagged | `plan-structure.md` contains "Plan Autonomy Gate" section with autonomy question |
| SC-4 | Validate no longer rejects "Add validation", "Handle edge cases", "Add appropriate error handling" as plan failures | `validate.md` removes these from the FAIL patterns table (may reclassify to advisory) |
| SC-5 | TDD mandate remains structurally enforced per `091-incremental-build.md` | RED before GREEN requirement still referenced; no language weakening TDD as principle |
| SC-6 | Behavioral test exists that verifies validate gate accepts abstract phase-level guidance | `.opencode/tests/behaviors/plan-autonomy-gate.sh` passes with phase-level plan content |
| SC-7 | SKILL.md overview and protocol updated to remove micromanagement language | No "2-5 min" or "exact code/commands" in SKILL.md |

## Edge Cases and Risks

| Case | Risk | Mitigation |
|------|------|-----------|
| Overcorrection — plans become too vague to act on | Plan Autonomy Gate checks that items have concrete verification outcomes and file structure boundaries | Keep file structure mapping, SC testability requirement, item decomposition |
| Validate gate allows genuinely incomplete plans | The relaxations are narrow (abstract-guidance patterns only) — placeholder detection, spec reference, and SC testability remain strict | Narrow scope of relaxation explicitly documented |
| TDD structural mandate perceived as weakened | The change removes the *script* around TDD but reinforces the *principle* | `091-incremental-build.md` references preserved; adversarial audit call remains mandatory |
| Existing tests rely on old validate behavior | Existing behavioral tests may expect rejected patterns | Update or remove affected test assertions; add new autonomy-gate test |

## Dependencies

- `skill-creator` if fragment management needed (unlikely — no shared content blocks involved)
