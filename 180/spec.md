## Problem Statement

The TDD methodology across the skill deck has extensive language enforcing "RED before GREEN" but lacks an **explicit prohibition against combining RED and GREEN into a single step** and lacks a **mandate that RED/GREEN pairs execute sequentially (one pair at a time)**.

Current gaps:

1. **No explicit "RED and GREEN must be separate steps" rule** — The `patterns.md` task has an "Obvious Implementation" pattern that says "GREEN only (skip RED)," which is a sanctioned form of collapsing phases. But there is no language that explicitly says "RED and GREEN may NEVER be combined into a single step." The implementation-pipeline already separates them (step 3 red-phase, step 5 green-phase with checkpoint-commit between), but the TDD skill itself lacks this prohibition.

2. **No explicit "sequential pairs" requirement** — When multiple items exist (multiple RED/GREEN pairs), there is no mandate that each RED must be immediately followed by its GREEN before the next RED starts. The Triangulation pattern in `patterns.md` already shows this visually (`RED (test case 1 → FAIL) → GREEN (passes case 1) → RED (test case 2 → FAIL) → GREEN (passes case 1+2)`), but it is a pattern illustration, not a mandated requirement. The `anti-patterns.md` file has no anti-pattern for "Parallel RED" or "All REDs then all GREENS."

3. **Spec writer and plan writer lack explicit enforcement language** — `spec-creation/tasks/write.md` and `writing-plans/tasks/create/plan-structure.md` reference TDD discipline but don't mandate that phases/steps enforce sequential RED/GREEN pairing.

4. **TDD auditors lack separation criteria** — `adversarial-audit/tasks/plan-fidelity.md` checks for "TDD checkpoints present" (PF-6) but doesn't verify RED/GREEN are separate steps. `adversarial-audit/tasks/test-quality-audit.md` has no criteria for RED/GREEN separation.

## Success Criteria

### SC-1: tdd SKILL.md — explicit RED/GREEN separation prohibition

The `tdd/SKILL.md` "Five Core Principles" section includes a new principle or expands principle 2 to state:

> **RED and GREEN must be separate phases.** They may NEVER be combined into a single phase or step. RED must complete (test written and confirmed FAIL) before GREEN begins. This is a hard gate — no authorization or developer instruction may override it.

**Evidence Type:** string + semantic
**Verification:** Read `tdd/SKILL.md` — principle 2 or a new principle includes RED/GREEN separation prohibition with "NEVER" language.

### SC-2: tdd SKILL.md — sequential pair mandate

The `tdd/SKILL.md` ASCI cycle diagram section or a new subsection states:

> **RED/GREEN pairs execute sequentially.** When multiple RED/GREEN pairs exist (multiple implementation items), each RED must be immediately followed by its GREEN before the next RED begins. Running RED for multiple items before any GREEN starts is prohibited. The cycle is: `item-1-RED → item-1-GREEN → item-2-RED → item-2-GREEN → ...`, never `RED-ALL → GREEN-ALL`.

**Evidence Type:** string + semantic
**Verification:** Read `tdd/SKILL.md` — sequential pair mandate is present.

### SC-3: tdd anti-patterns — new Combined-Phase anti-pattern

The `tdd/tasks/anti-patterns.md` includes a new anti-pattern row in the table:

| # | Anti-Pattern | Symptom | Root Cause | Alternative |
|---|-------------|---------|------------|-------------|
| 6 | **Combined-Phase (RED+GREEN)** | Single PR/commit contains both test and implementation for multiple items | Running RED for all items first then GREEN for all items, or combining RED/GREEN into one step | Sequential pairs: RED→GREEN per item, one pair at a time |

**Evidence Type:** string
**Verification:** Read `tdd/tasks/anti-patterns.md` — anti-pattern #6 exists with the description above.

### SC-4: tdd patterns — Triangulation mandates sequential pairs explicitly

The `tdd/tasks/patterns.md` Triangulation section adds an explicit note:

> **MANDATORY:** Each RED must be immediately followed by its GREEN before the next RED begins. Never batch all REDs then all GREENS. RED→GREEN per edge case, sequentially.

**Evidence Type:** string
**Verification:** Read `tdd/tasks/patterns.md` Triangulation section — sequential pair mandate note is present.

### SC-5: tdd checklist — RED/GREEN separation items

The `tdd/tasks/checklist.md` adds to the RED and GREEN sections:

- **RED checklist:** `[ ] RED confirmed as separate phase — no GREEN begun yet for this item` (after existing RED items)
- **GREEN checklist:** `[ ] GREEN is for THIS item's RED only — no next-item RED started yet` (after existing GREEN items)

**Evidence Type:** string
**Verification:** Read `tdd/tasks/checklist.md` — RED and GREEN sections each include the new checklist item.

### SC-6: spec-creation write.md — spec mandates sequential per-item TDD

The `spec-creation/tasks/write.md` Step 0.5 (Behavioral Test Mandate) or a new adjacent step includes:

When writing the spec's success criteria, the spec MUST mandate that implementation follows sequential per-item TDD: each item completes its RED→GREEN→REFACTOR cycle before the next item begins. Items may NOT be batched.

**Evidence Type:** string + semantic
**Verification:** Read `spec-creation/tasks/write.md` — sequential TDD mandate is present in or adjacent to Step 0.5.

### SC-7: writing-plans plan-structure — RED/GREEN defined as separate phases

The `writing-plans/tasks/create/plan-structure.md` Step 3.5 (RED/GREEN Condition Language) adds:

Each item in the plan defines RED and GREEN as separate sub-steps within the item's phase. RED and GREEN MUST NOT be in the same sub-step. The plan explicitly enumerates "RED" and "GREEN" as distinct steps in each item's pipeline gate table.

The existing per-unit pipeline gate table already has separate rows for `red-phase` (gate 3) and `green-phase` (gate 5), but Step 3.5 should explicitly note this separation as a requirement.

**Evidence Type:** string + semantic
**Verification:** Read `writing-plans/tasks/create/plan-structure.md` Step 3.5 — RED/GREEN separation and sequential pair requirement are explicitly stated.

### SC-8: plan-fidelity auditor — PF-6 expanded for RED/GREEN separation

The `adversarial-audit/tasks/plan-fidelity.md` PF-6 criterion is expanded from "TDD checkpoints present" to:

> **PF-6:** "TDD checkpoints present — RED and GREEN are separate, sequential steps within each item. RED and GREEN MUST NOT be combined. RED must be immediately followed by its GREEN before the next item's RED begins."

PASS: Plan has RED and GREEN as distinct sequential steps per item.
FAIL: Plan combines RED and GREEN into a single step, or batches all REDs before any GREEN.

**Evidence Type:** string + semantic
**Verification:** Read `adversarial-audit/tasks/plan-fidelity.md` — PF-6 includes RED/GREEN separation criteria with PASS/FAIL conditions.

### SC-9: test-quality-audit — new TQ-11 for sequential TDD

The `adversarial-audit/tasks/test-quality-audit.md` Step 2 includes a new criterion TQ-11:

| ID | Dimension | PASS condition | FAIL condition |
|----|-----------|---------------|----------------|
| TQ-11 | Sequential TDD discipline | Tests show one-item-at-a-time RED/GREEN sequencing | Tests were created in batches (all REDs before all GREENS) or RED/GREEN are combined into a single step |

**Evidence Type:** string + semantic
**Verification:** Read `adversarial-audit/tasks/test-quality-audit.md` Step 2 — TQ-11 exists with binary PASS/FAIL conditions.

### SC-10: sequential mandate applies to ALL TDD patterns including Obvious Implementation

The "Obvious Implementation" pattern in `tdd/tasks/patterns.md` states that even when RED is skipped (trivial one-liner), the GREEN phase for that item must complete before the next item's RED or GREEN begins. The exemption is for the test-writing step only — the sequential-per-item discipline is NOT exempted.

**Evidence Type:** string
**Verification:** Read `tdd/tasks/patterns.md` Obvious Implementation section — includes sequential-per-item note for the RED-skip case.

### SC-11: concern enumeration — single concern

This spec addresses one concern: enforcing sequential RED/GREEN pair discipline across the TDD skill, spec writer, plan writer, and auditors. No other concerns are mixed in.

**Evidence Type:** structural
**Verification:** Read spec body — all success criteria address this single concern.

## Phases

### Phase 1: Update TDD skill core (SKILL.md + tasks)

**Steps:**
1. Add RED/GREEN separation prohibition and sequential pair mandate to `tdd/SKILL.md` (SC-1, SC-2)
2. Add anti-pattern #6 (Combined-Phase) to `tdd/tasks/anti-patterns.md` (SC-3)
3. Add sequential pair mandate note to Triangulation in `tdd/tasks/patterns.md` (SC-4)
4. Add sequential note to Obvious Implementation in `tdd/tasks/patterns.md` (SC-10)
5. Add new checklist items to `tdd/tasks/checklist.md` RED and GREEN sections (SC-5)

**Files:** `tdd/SKILL.md`, `tdd/tasks/anti-patterns.md`, `tdd/tasks/patterns.md`, `tdd/tasks/checklist.md`

### Phase 2: Update spec writer and plan writer

**Steps:**
1. Add sequential per-item TDD mandate to `spec-creation/tasks/write.md` (SC-6)
2. Add RED/GREEN separation and sequential pair requirement to `writing-plans/tasks/create/plan-structure.md` Step 3.5 (SC-7)

**Files:** `spec-creation/tasks/write.md`, `writing-plans/tasks/create/plan-structure.md`

### Phase 3: Update auditors

**Steps:**
1. Expand PF-6 in `adversarial-audit/tasks/plan-fidelity.md` with RED/GREEN separation criteria (SC-8)
2. Add TQ-11 to `adversarial-audit/tasks/test-quality-audit.md` (SC-9)

**Files:** `adversarial-audit/tasks/plan-fidelity.md`, `adversarial-audit/tasks/test-quality-audit.md`

## Dependencies

Phase 1 must complete before Phase 2 (TDD core changes define the requirements that spec/plan writers must enforce).
Phase 2 and Phase 3 are independent (spec/plan writers and auditors each incorporate the new requirements autonomously).

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| "Obvious Implementation" pattern conflicts with mandatory RED | Low | Medium | SC-10 explicitly exempts Obvious from test-writing but NOT from sequential-per-item discipline |
| New anti-pattern pushes checklist/patterns past word limits | Low | Low | Each change is small (~3-5 lines) |
| Auditors over-flag parallelism that is actually independent items | Medium | Low | PF-6 and TQ-11 check for batching within a single item, not across independent spec phases |
| Spec writer mandate adds boilerplate to every spec | Low | Low | Single sentence in Step 0.5; no structural overhead |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `skills/test-driven-development/SKILL.md` | Current TDD core principles and cycle diagram |
| Direct source search | `skills/test-driven-development/tasks/anti-patterns.md` | Current anti-pattern table |
| Direct source search | `skills/test-driven-development/tasks/patterns.md` | Current pattern decision matrix |
| Direct source search | `skills/test-driven-development/tasks/checklist.md` | Current RED/GREEN/REFACTOR checklists |
| Direct source search | `skills/spec-creation/tasks/write.md` | Current behavioral test mandate (Step 0.5) |
| Direct source search | `skills/writing-plans/tasks/create/plan-structure.md` | Current RED/GREEN condition language (Step 3.5) and per-unit pipeline gate table |
| Direct source search | `skills/adversarial-audit/tasks/plan-fidelity.md` | Current PF-6 TDD checkpoint criteria |
| Direct source search | `skills/adversarial-audit/tasks/test-quality-audit.md` | Current TQ-1 through TQ-5 criteria |
| Direct source search | `skills/implementation-pipeline/SKILL.md` | Current 14-step dispatch routing (RED and GREEN as separate steps) |
| Direct source search | `guidelines/080-code-standards.md` | RED-Phase Ordering, Behavioral RED/GREEN gate |
| Direct source search | `guidelines/091-incremental-build.md` | Per-item TDD cycle, `incremental-build-003` |
| Direct source search | `guidelines/000-critical-rules.md` | Monolithic implementation, critical-rules-042 |
| Live verification | `grep "RED.*GREEN\|combined.*step\|parallel.*RED\|skip RED" -r .opencode/skills/` | Confirmed current language patterns across all skill files |

## Change Control

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0 | 2026-06-08 | Initial spec | 🤖 OpenCode (ollama-cloud/deepseek-v4-flash) |

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)