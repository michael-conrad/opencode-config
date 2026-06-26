# [SPEC-FIX] Plan phase structure inconsistency — structure.md and write.md disagree on pre/post phase organization

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | `writing-plans/tasks/structure.md` mandates dedicated pre/post `## Phase` sections, but `writing-plans/tasks/write.md` mandates flat Tier 1 (Global) steps for the same content. The plan writer must choose between contradictory specs, producing inconsistent plans. |
| **Root Cause / Motivation** | The two task files were written at different times without cross-referencing each other's phase structure model. `structure.md` (the phase structure definition task) uses dedicated phase headings; `write.md` (the plan writing task) uses a flat Tier 1 concept. |
| **Approach Chosen** | Make `write.md` defer to `structure.md`'s model. Replace Tier 1 (Global) with dedicated `## Phase — Pre-RED Common` and `## Phase — Post-RED/green` headings. |
| **Alternatives Considered & Why Discarded** | (1) Make `structure.md` defer to `write.md` — discarded because `structure.md` is the phase structure definition task and should drive the format. (2) Keep both and add a disambiguation note — discarded because contradictory specs produce inconsistent plans regardless of disclaimers. |
| **Key Design Decisions** | DEC-1: Defer to `structure.md` as authoritative. DEC-2: Pre/post are dedicated `## Phase` sections, not flat steps. |

## Objective

Eliminate the contradiction between `structure.md` and `write.md` so that plan writers produce consistent phase structures regardless of which task file they reference.

## Problem

`writing-plans/tasks/structure.md` Exit Criteria (line 17) mandates "global pre-phase (once), per-file RED/GREEN phases (one chain each), global post-phase (once)" — pre/post are dedicated `## Phase` sections with their own headings.

`writing-plans/tasks/write.md` Three-Tier Plan Structure (lines 88-100) mandates "Tier 1 (Global): Steps numbered sequentially across the entire plan. Includes global pre-steps and global post-steps" — pre/post are plan-wide steps without their own phase heading.

The plan writer must choose between contradictory specs, producing inconsistent plans.

## Context

- `structure.md` is the phase structure definition task — it defines HOW phases are organized
- `write.md` is the plan writing task — it defines HOW the plan document is formatted
- The contradiction means a plan written per `write.md`'s Tier 1 model would fail `structure.md`'s Exit Criteria, and vice versa

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/writing-plans/tasks/write.md` | Three-Tier Plan Structure section: replace Tier 1 with dedicated pre/post phase headings |
| `.opencode/skills/writing-plans/tasks/write.md` | Required Sections list: add pre-phase and post-phase entries |
| `.opencode/skills/writing-plans/tasks/write.md` | Three-Tier Plan Structure table: replace Tier 1 row with pre-phase and post-phase rows |

## Fix Approach

Replace the Tier 1 (Global) concept in `write.md` with dedicated `## Phase — Pre-RED Common` and `## Phase — Post-RED/green` phase headings, matching `structure.md`'s three-tier organization.

### Pre-Phase Content

The pre-phase contains:
- Coherence gate
- Pre-red-baseline

### Post-Phase Content

The post-phase contains:
- Collect behavioral evidence from `./tmp/behavioral-evidence-*/` into `./tmp/{issue-N}/artifacts/`
- Adversarial audit
- Cross-validate
- Regression check
- Review-prep
- Exec-summary

### Required Sections Update

The Required Sections list in `write.md` MUST be updated to include:
- Pre-phase section entry (before per-file RED/GREEN phases)
- Post-phase section entry (after per-file RED/GREEN phases)
- Global sequential numbering rule preserved (item 9)

### Three-Tier Plan Structure Table Update

Replace:

| Tier | Level | Format | Purpose |
|------|-------|--------|---------|
| 1 — Global | Plan-wide | `- [ ] N.` (sequential across all phases) | Pre-RED common steps, global post-steps |

With:

| Tier | Level | Format | Purpose |
|------|-------|--------|---------|
| 1 — Pre-Phase | Phase section | `## Phase — Pre-RED Common` | Coherence gate, pre-red-baseline |
| 2 — Per-Phase | Phase sections | `## Phase N — <name>` | Phase metadata + per-file RED+green chains |
| 3 — Post-Phase | Phase section | `## Phase — Post-RED/green` | Evidence collection, audit, cross-validate, regression, review-prep, exec-summary |
| 4 — Per-Item | Item chains | `- [ ] N.M.` (sub-steps) | RED → GREEN → doublecheck → commit per item |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `write.md` Three-Tier Plan Structure section no longer references "Tier 1 (Global)" as flat plan-wide steps | `string` | `grep` for "Tier 1" in `write.md` — MUST NOT appear in the Three-Tier Plan Structure section | Remove Tier 1 references | edit-write-md | `.opencode/skills/writing-plans/tasks/write.md` | DEC-1 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | `write.md` Three-Tier Plan Structure section has dedicated `## Phase — Pre-RED Common` and `## Phase — Post-RED/green` headings | `string` | `grep` for "Phase — Pre-RED Common" and "Phase — Post-RED/green" in `write.md` — both MUST be present | Add missing phase headings | edit-write-md | `.opencode/skills/writing-plans/tasks/write.md` | DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-3 | `write.md` Required Sections list includes pre-phase and post-phase entries in the correct order | `string` | Read Required Sections list — pre-phase and post-phase MUST appear in order | Add missing entries | edit-write-md | `.opencode/skills/writing-plans/tasks/write.md` | DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-4 | `write.md` Three-Tier Plan Structure table replaces Tier 1 row with pre-phase and post-phase rows | `string` | Read Three-Tier Plan Structure table — MUST have rows for pre-phase and post-phase, NOT Tier 1 | Update table | edit-write-md | `.opencode/skills/writing-plans/tasks/write.md` | DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-5 | Pre-phase in `write.md` includes coherence gate and pre-red-baseline steps | `string` | `grep` for "coherence gate" and "pre-red-baseline" under the pre-phase section — both MUST be present | Add missing steps | edit-write-md | `.opencode/skills/writing-plans/tasks/write.md` | DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-6 | Post-phase in `write.md` includes evidence collection, adversarial audit, cross-validate, regression check, review-prep, and exec-summary steps | `string` | `grep` for each of the six step names under the post-phase section — all MUST be present | Add missing steps | edit-write-md | `.opencode/skills/writing-plans/tasks/write.md` | DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-7 | Global sequential numbering rule (Required Sections item 9) is preserved — steps numbered across all phases including pre and post | `string` | Read Required Sections item 9 — MUST still mandate global sequential numbering | Preserve existing rule | edit-write-md | `.opencode/skills/writing-plans/tasks/write.md` | — | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-8 | No structural changes to `structure.md` | `structural` | `git diff` on `structure.md` — MUST show no changes | Revert any changes | verify-no-change | `.opencode/skills/writing-plans/tasks/structure.md` | — | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-9 | Behavioral enforcement test exists in `.opencode/tests/behaviors/` that verifies the plan writer uses dedicated pre/post phase headings | `behavioral` | `opencode-cli run` with prompt to write a plan — stderr MUST show `## Phase — Pre-RED Common` and `## Phase — Post-RED/green` in the written plan | Create behavioral test | test-creation | `.opencode/tests/behaviors/` | DEC-1, DEC-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |

## Edge Cases

- **Existing plans:** Plans already written with the Tier 1 (Global) structure are not invalidated — they were written under the old spec. Only new plans must use the new structure.
- **Single-phase plans:** A single-phase plan still gets a pre-phase and post-phase. The pre-phase runs once before the single implementation phase; the post-phase runs once after.

## Dependencies

None. This is a self-contained documentation fix.

## Risk

| RISK-ID | Risk | Likelihood | Impact | Mitigation | Verifying SC |
|---------|------|------------|--------|------------|--------------|
| RISK-1 | Plan writer ignores new structure and uses old Tier 1 pattern | Medium | High — inconsistent plans | Behavioral enforcement test (SC-9) catches non-compliance | SC-9 |
| RISK-2 | Global sequential numbering breaks with new phase structure | Low | Medium — steps restart per phase | Required Sections item 9 explicitly preserves global numbering (SC-7) | SC-7 |

## Decision Rationale

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Defer to `structure.md` as authoritative | `structure.md` is the phase structure definition task; `write.md` is the plan writing task. The structure definition should drive the writing format, not the other way around. | MUST | SC-1, SC-9 |
| DEC-2 | Pre/post are dedicated `## Phase` sections, not flat steps | Dedicated phase sections carry metadata (Concern, Files, SCs, Dependencies, Entry/Exit) that flat steps cannot express. This matches `structure.md`'s model. | MUST | SC-2, SC-3, SC-4, SC-5, SC-6, SC-9 |

## Phases

### Phase 1 — Edit write.md

**Concern:** Update `write.md` to use dedicated pre/post phase headings instead of Tier 1 (Global) flat steps.

**Files:**
- `.opencode/skills/writing-plans/tasks/write.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8

**Dependencies:** None

**Entry:** Spec approved

**Exit:** All string SCs pass, behavioral test (SC-9) passes

### Phase 2 — Behavioral Test

**Concern:** Create behavioral enforcement test that verifies the plan writer uses dedicated pre/post phase headings.

**Files:**
- `.opencode/tests/behaviors/` (new test file)

**SCs:** SC-9

**Dependencies:** Phase 1 (test verifies the change)

**Entry:** Phase 1 complete

**Exit:** Behavioral test passes (RED before Phase 1, GREEN after)

## Non-Goals

- **Changes to `structure.md`** — It is the authoritative model and does not need modification.
- **Changes to `implementation-pipeline` skill** — The pipeline dispatch routing table is unaffected.
- **Changes to plan validation rules** — Validation rules in `write.md` are not being modified.
- **Changes to any other skill or guideline** — This is scoped to `write.md` only.

## Regression Invariants

1. Global sequential numbering MUST continue across all phases including pre and post.
2. All existing dispatch indicators (`(**sub-agent**)`, `(**clean-room**)`, `(**inline**)`) MUST remain valid.
3. The Required Sections list MUST still mandate all existing sections (Title, Goal/Architecture/Files, Admonishment, etc.) — only the phase section entry changes.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read` on `structure.md` line 17 | Verify Exit Criteria mandates dedicated pre/post phase headings |
| Direct source search | `read` on `write.md` lines 86-100 | Verify Three-Tier Plan Structure uses Tier 1 (Global) flat steps |
| Direct source search | `read` on `write.md` lines 56-84 | Verify Required Sections list |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.issues/1447/plan.md` before implementation begins.

🤖 OpenCode (deepseek-v4-flash) created
