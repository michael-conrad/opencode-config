> **Full spec and artifacts: [`.issues/1447/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1447)**

## Problem

`writing-plans/tasks/structure.md` mandates dedicated pre/post `## Phase` sections, but `writing-plans/tasks/write.md` mandates flat Tier 1 (Global) steps for the same content. The plan writer must choose between contradictory specs, producing inconsistent plans.

## Scope

**In scope:**
- Update `write.md` Three-Tier Plan Structure to use dedicated pre/post phase headings
- Update `write.md` Required Sections list
- Update `write.md` Three-Tier Plan Structure table

**Out of scope:**
- Changes to `structure.md`, `implementation-pipeline`, plan validation rules

## Approach

Make `write.md` defer to `structure.md`'s model. Replace Tier 1 (Global) with dedicated `## Phase — Pre-RED Common` and `## Phase — Post-RED/green` headings. Pre-phase contains coherence gate and pre-red-baseline. Post-phase contains evidence collection, audit, cross-validate, regression, review-prep, and exec-summary.

## Impact

| Risk | Mitigation |
|------|------------|
| Plan writer ignores new structure | Behavioral enforcement test catches non-compliance |
| Global numbering breaks with new phases | Required Sections item 9 explicitly preserves global numbering |

**Call to action:** Approve this spec to fix the contradiction before the next plan is written.

## AI Agent Instructions

This issue is an executive summary for human stakeholders. The authoritative spec and plan artifacts are at `.issues/1447/`. After creation, `local-issues sync 1447` MUST be run and the result committed to create the local `.issues/1447/` entry. The implementation plan will be created in `.issues/1447/plan.md` after approval. AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.
