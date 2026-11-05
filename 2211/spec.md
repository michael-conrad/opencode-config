---
remote_issue: 2211
remote_url: https://github.com/michael-conrad/.opencode/issues/2211
labels: [spec]
approved: true
---

> **Full spec and artifacts: [`.opencode/.issues/2211/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2211)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2211/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

**Problem Statement:** The four auditor task files (`spec-audit-evaluator.md`, `spec-audit-investigator.md`, `plan-fidelity-evaluator.md`, `plan-fidelity-investigator.md`) hard-code structural criteria that duplicate — and have drifted from — the producer templates. A brainstorming session identified 39 items of misalignment.

**Root Cause / Motivation:** The auditor task files hard-code their own separate criteria lists that are not synchronized with the producer templates. When the producer side changes, the auditor side must be manually updated. The root cause is the absence of a single canonical reference document that both sides read from. Spec A (`.opencode#2210`) creates those reference docs. This spec updates the auditor side to read from them.

**Approach Chosen:** Update the four auditor task files to read from the canonical reference docs (`reference/spec-structure-standards.md` and `reference/plan-structure-standards.md`) via `Read [Text](path)` instead of hard-coding structural criteria. Remove criteria that were eliminated during the brainstorming session. This is Spec B of a two-spec split — Spec A (`.opencode#2210`) creates the reference docs and updates the producer templates.

**Alternatives Considered & Why Discarded:**
1. Single monolithic spec: Rejected — split into Spec A (producer side) and Spec B (auditor side) for manageable scope.
2. Keep all hard-coded criteria: Rejected — the 36-item misalignment proves this doesn't work.
3. Move everything to reference docs including behavioral checks: Rejected — behavioral judgments (determinism, evidence type uplift) cannot be codified as structural rules.

**Key Design Decisions:**
- Reference docs are the single source of truth — both producers and auditors read via `Read [Text](path)`.
- Criteria that are cross-artifact comparisons or behavioral judgments (PF-1, PF-2, PF-3, PF-5, PF-STRUCTURAL-FAIL, PF-Z3-CONTRACT, PF-SEQUENCE-MATCHES) remain as explicit instructions — they cannot be codified as structural rules.
- Eliminated criteria: phases in spec-audit (plan concept), STATUS marker (prohibited pattern), PF-DELEGATION (too rare), Z3 contract refs (redundant), verification instructions (redundant), gate sequence (redundant), PF-4 (pipeline invariant), PF-GLOBAL-NUMBERING (no defect prevention evidence).

**User Intent / Original Prompt:** "audit the specs against themselves for requirements for specs" — eat your own dogfood. The specs must follow the canonical structure they define.

## Not Included

- Changes to producer templates (handled by `.opencode#2210`)
- Changes to the audit DiMo chain dispatch
- Behavioral enforcement test creation
- Changes to the solve skill or Z3 constraint solver
- Changes to the approval-gate pipeline

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-audit/tasks/spec-audit-evaluator.md` Step 5a replaces the hard-coded SC-1 through SC-14 table with `Read [spec-structure-standards.md](reference/spec-structure-standards.md)` and derives criteria from its required sections. SC-3, SC-4, SC-6, SC-7, SC-8, SC-10, SC-13 are removed. SC-1, SC-2, SC-5, SC-9, SC-11, SC-12, SC-14 are derived from the reference doc. Steps 5b-5h (SC-DET, SC-STRUCTURAL-FAIL, SC-EVIDENCE-TYPE, SC-TRACKING-LANG, SC-PRESCRIPTIVE-CODE, SC-PIPELINE-GATES, SC-CANONICAL-PLAN-FORM) remain as explicit instructions but reference the reference doc for their rule definitions. | string | grep for SC-1 through SC-14 table removed; grep for Read reference; grep for removed SC IDs absent |
| SC-2 | `spec-audit/tasks/spec-audit-investigator.md` Step 3 replaces hard-coded section names (Intent and Executive Summary, Documentation Sources, STATUS marker) with `Read [spec-structure-standards.md](reference/spec-structure-standards.md)` and collects evidence against its sections. Phase inventory (Step 3.3) and STATUS marker (Step 3.7) are removed. | string | grep for hard-coded section names removed; grep for Read reference; grep for removed items absent |
| SC-3 | `plan-fidelity/tasks/plan-fidelity-evaluator.md` Step 3 replaces hard-coded PF criteria that derive from plan structure (PF-4, PF-6, PF-7, PF-7a, PF-ADMONISHMENT, PF-ONE-STEP, PF-DELEGATION, PF-PRESCRIPTIVE-CODE, PF-GLOBAL-NUMBERING) with `Read [plan-structure-standards.md](reference/plan-structure-standards.md)` and derives criteria from its elements. PF-4, PF-DELEGATION, PF-GLOBAL-NUMBERING are removed entirely. PF-CHECKLIST-FORMAT, PF-DISPATCH-MODE, PF-DISPATCH-DEFECTS, PF-SUBSTEP-EXPAND reference the reference doc for their rule definitions. PF-1, PF-2, PF-3, PF-5, PF-STRUCTURAL-FAIL, PF-Z3-CONTRACT, PF-SEQUENCE-MATCHES remain as explicit instructions. | string | grep for removed PF criteria absent; grep for Read reference |
| SC-4 | `plan-fidelity/tasks/plan-fidelity-investigator.md` Steps 2-5 replaces hard-coded evidence collection items (phase descriptions, cross-references, delegation, scope boundary, admonishments, plan scope, gate sequence, verification instructions, Z3 contracts, prescriptive content, cost-frame prose, SC gate language) with `Read [plan-structure-standards.md](reference/plan-structure-standards.md)` and collects evidence against its elements. Delegation refs (Step 2.6, 3.11, 5.5), gate sequence (Step 3.12), verification instructions (Step 3.13), Z3 contract refs (Step 3.14), cost-frame prose (Step 5.8), and SC gate language (Step 5.9) are removed. | string | grep for removed evidence collection items absent; grep for Read reference |
| SC-5 | All reference doc `Read [Text](path)` references point to existing files (created by `.opencode#2210`) | string | read each referenced path — expect file exists |
| SC-6 | `spec-audit-evaluator.md` SC-13 (cost-frame) replaces hard-coded evaluation rule with `Read [cost-model-standards.md](reference/cost-model-standards.md)` and verifies each SC's cost frame follows the dark-prose-007 pattern | string | grep for Read reference to cost-model-standards; grep for old hard-coded rule removed |
| SC-7 | `plan-fidelity-evaluator.md` PF-7a (cost-frame) replaces hard-coded evaluation rule with `Read [cost-model-standards.md](reference/cost-model-standards.md)` and verifies each phase's cost frame follows the dark-prose-007 pattern | string | grep for Read reference to cost-model-standards; grep for old hard-coded rule removed |

> **Enforcement gate:** All success criteria must pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Grepping for the Read reference costs one search. Skipping means the evaluator still hard-codes its SC table and drifts from the reference doc.
- SC-2: Grepping for the Read reference costs one search. Skipping means the investigator still hard-codes section names that drift from the reference doc.
- SC-3: Grepping for the Read reference costs one search. Skipping means the plan-fidelity evaluator still hard-codes PF criteria that drift from the reference doc.
- SC-4: Grepping for the Read reference costs one search. Skipping means the plan-fidelity investigator still hard-codes evidence collection items that drift from the reference doc.
- SC-5: Reading each referenced path costs one read call per path. Skipping means a missing reference doc isn't caught until the auditor fails at runtime.
- SC-6: Grepping for the Read reference to cost-model-standards costs one search. Skipping means the evaluator still hard-codes the cost-frame rule and drifts from the reference doc.
- SC-7: Grepping for the Read reference to cost-model-standards costs one search. Skipping means the plan-fidelity evaluator still hard-codes the cost-frame rule and drifts from the reference doc.

## Requirements

- REQ-1: `spec-audit-evaluator.md` references spec-structure-standards, removes eliminated SCs
- REQ-2: `spec-audit-investigator.md` references spec-structure-standards, removes eliminated items
- REQ-3: `plan-fidelity-evaluator.md` references plan-structure-standards, removes eliminated PF criteria
- REQ-4: `plan-fidelity-investigator.md` references plan-structure-standards, removes eliminated items
- REQ-5: All reference doc paths are valid
- REQ-6: `spec-audit-evaluator.md` SC-13 references cost-model-standards
- REQ-7: `plan-fidelity-evaluator.md` PF-7a references cost-model-standards

## Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1 | Update `spec-audit-evaluator.md` |
| 2 | SC-2 | Update `spec-audit-investigator.md` |
| 3 | SC-3 | Update `plan-fidelity-evaluator.md` |
| 4 | SC-4 | Update `plan-fidelity-investigator.md` |
| 5 | SC-5 | Verify reference doc paths |
| 6 | SC-6 | Update `spec-audit-evaluator.md` SC-13 to reference cost-model-standards |
| 7 | SC-7 | Update `plan-fidelity-evaluator.md` PF-7a to reference cost-model-standards |

## Dependencies

- `.opencode#2210` — must complete first (creates the reference docs this spec reads)

## Traceability

| Requirement | SC | Phase |
|-------------|----|-------|
| REQ-1 | SC-1 | Phase 1 |
| REQ-2 | SC-2 | Phase 2 |
| REQ-3 | SC-3 | Phase 3 |
| REQ-4 | SC-4 | Phase 4 |
| REQ-5 | SC-5 | Phase 5 |
| REQ-6 | SC-6 | Phase 6 |
| REQ-7 | SC-7 | Phase 6 |

## Phases

### Phase 1 (REQ-1): Update spec-audit-evaluator.md

**Step 5a changes:**
- Remove the hard-coded SC-1 through SC-14 table
- Replace with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, check that the spec has that section with the correct content. For each SC in the spec's SC table, verify it has a verification method, that dependencies are documented, and that SCs are deterministic.`
- Removed SCs: SC-3 (phases), SC-4 (steps), SC-6 (concerns), SC-7 (fidelity), SC-8 (edge cases), SC-10 (prose structure), SC-13 (cost-frame)
- Derived from reference doc: SC-1 (preamble), SC-2 (verification methods), SC-5 (dependencies), SC-9 (determinism), SC-11 (documentation sources), SC-12 (preamble fields), SC-14 (enforcement gate)

**Steps 5b-5h changes:**
- SC-DET (5b): Remains as explicit instruction — determinism is a behavioral judgment
- SC-STRUCTURAL-FAIL (5c): Remains as explicit instruction — evidence type uplift is behavioral
- SC-EVIDENCE-TYPE (5d): Replace hard-coded taxonomy with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Evidence Type Taxonomy and verify each SC's evidence matches the minimum acceptable method.`
- SC-TRACKING-LANG (5e): Replace hard-coded list with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Prohibited Content Patterns and verify the spec contains no tracking/status language.`
- SC-PRESCRIPTIVE-CODE (5f): Replace hard-coded rules with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Prohibited Content Patterns and verify the spec contains no prescriptive code.`
- SC-PIPELINE-GATES (5g): Replace hard-coded rules with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Format Requirements and verify pipeline gates use the canonical checklist format.`
- SC-CANONICAL-PLAN-FORM (5h): Replace hard-coded rules with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Format Requirements and verify any plan output format requirements use the canonical checklist format.`

**Affected files:**
- `.opencode/skills/audit/tasks/spec-audit-evaluator.md`

### Phase 2 (REQ-2): Update spec-audit-investigator.md

**Step 3 changes:**
- Remove Step 3.3 (Phase inventory) — phases are a plan concept
- Remove Step 3.7 (STATUS marker) — prohibited pattern
- Replace Step 3.5 (Preamble presence) with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, collect evidence about its presence, content, and structure. Record what is found — do not infer or assume.`
- Remove Step 3.6 (Documentation Sources) as a hard-coded section name — it's now derived from the reference doc's required sections
- Update the `spec_structure` YAML evidence structure to remove `phases`, `preamble`, `documentation_sources`, and `status_marker` fields. Replace with a dynamic structure derived from the reference doc's required sections.

**Affected files:**
- `.opencode/skills/audit/tasks/spec-audit-investigator.md`

### Phase 3 (REQ-3): Update plan-fidelity-evaluator.md

**Step 3 changes:**
- Remove PF-4 (edge cases) — error recovery is a pipeline invariant
- Remove PF-DELEGATION — too rare, false FAILs
- Remove PF-GLOBAL-NUMBERING — no evidence of defect prevention
- Replace PF-6, PF-7, PF-7a, PF-ADMONISHMENT, PF-ONE-STEP, PF-PRESCRIPTIVE-CODE with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md). For each structural element in the reference doc, verify the plan has that element with the correct format.`
- PF-CHECKLIST-FORMAT: Replace hard-coded rule with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Step Format and verify all steps use the canonical checklist format.`
- PF-DISPATCH-MODE: Replace hard-coded rule with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Dispatch Indicators and verify every step has exactly one valid dispatch indicator.`
- PF-DISPATCH-DEFECTS: Replace hard-coded rules with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Dispatch Indicators and verify dispatch declarations are consistent with step indicators.`
- PF-SUBSTEP-EXPAND: Replace hard-coded rule with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Step Format and verify no step describes more than one atomic action.`
- PF-1, PF-2, PF-3, PF-5, PF-STRUCTURAL-FAIL, PF-Z3-CONTRACT, PF-SEQUENCE-MATCHES remain as explicit instructions (cross-artifact comparisons or behavioral judgments).

**Affected files:**
- `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md`

### Phase 4 (REQ-4): Update plan-fidelity-investigator.md

**Step 2 changes:**
- Remove Step 2.4 (phase descriptions) — phases are a plan concept, spec may not have them
- Remove Step 2.5 (cross-references) — not a canonical spec section
- Remove Step 2.6 (delegation references) — PF-DELEGATION removed
- Remove Step 2.7 (scope boundary) — not a canonical spec section
- Replace with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, collect evidence about its presence, content, and structure.`
- Update the `spec` YAML evidence structure to remove `phases`, `cross_references`, `delegation_refs`, `scope` fields.

**Step 3 changes:**
- Remove Step 3.8 (admonishments) — now derived from plan-structure-standards
- Remove Step 3.9 (plan scope) — not a canonical plan element
- Remove Step 3.10 (cross-references from plan) — not a canonical plan element
- Remove Step 3.11 (delegation definitions) — PF-DELEGATION removed
- Remove Step 3.12 (gate sequence) — redundant with PF-SEQUENCE-MATCHES
- Remove Step 3.13 (verification instructions) — redundant with PF-STRUCTURAL-FAIL
- Remove Step 3.14 (Z3 contract references) — redundant with PF-Z3-CONTRACT
- Remove Step 3.15 (prescriptive content) — now derived from plan-structure-standards
- Replace with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md). For each structural element in the reference doc, collect evidence about its presence, content, and format.`
- Update the `plan` YAML evidence structure to remove `admonishments`, `plan_scope`, `cross_references`, `delegation_definitions`, `gate_sequence`, `verification_instructions`, `z3_contract_refs`, `prescriptive_content` fields.

**Step 4 changes:**
- Remove Step 4.9 (one-step protocol) — now derived from plan-structure-standards

**Step 5 changes:**
- Remove Step 5.5 (delegation completeness) — PF-DELEGATION removed
- Remove Step 5.6 (gate sequence) — redundant with PF-SEQUENCE-MATCHES
- Remove Step 5.7 (verification evidence types) — redundant with PF-STRUCTURAL-FAIL
- Remove Step 5.8 (cost-frame prose) — now derived from plan-structure-standards
- Remove Step 5.9 (SC gate language) — now derived from plan-structure-standards

**Affected files:**
- `.opencode/skills/audit/tasks/plan-fidelity-investigator.md`

### Phase 5 (REQ-5): Verify reference doc paths

Verify that all `Read [Text](path)` references in the updated auditor task files point to existing files:
- `reference/spec-structure-standards.md` — must exist (created by `.opencode#2210`)
- `reference/plan-structure-standards.md` — must exist (created by `.opencode#2210`)

**Affected files:**
- Verification only

### Phase 6 (REQ-6, REQ-7): Update auditor cost-frame criteria to reference cost-model-standards

**spec-audit-evaluator.md Step 5a changes:**
- SC-13 (cost-frame): Replace hard-coded evaluation rule with: `Read [cost-model-standards.md](reference/cost-model-standards.md) and verify each SC's cost frame follows the dark-prose-007 pattern.`

**plan-fidelity-evaluator.md Step 3 changes:**
- PF-7a (cost-frame): Replace hard-coded evaluation rule with: `Read [cost-model-standards.md](reference/cost-model-standards.md) and verify each phase's cost frame follows the dark-prose-007 pattern.`

**Affected files:**
- `.opencode/skills/audit/tasks/spec-audit-evaluator.md`
- `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md`

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Brainstorming session resolutions | Discussion | This session | 39 items discussed and resolved |
| Spec A — reference docs and producer templates | Issue | `.opencode/.issues/2210/spec.md` | Read at spec creation time |
| Spec-audit evaluator | Task file | `.opencode/skills/audit/tasks/spec-audit-evaluator.md` | Read at spec creation time |
| Spec-audit investigator | Task file | `.opencode/skills/audit/tasks/spec-audit-investigator.md` | Read at spec creation time |
| Plan-fidelity evaluator | Task file | `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` | Read at spec creation time |
| Plan-fidelity investigator | Task file | `.opencode/skills/audit/tasks/plan-fidelity-investigator.md` | Read at spec creation time |

## Files Affected

- `.opencode/skills/audit/tasks/spec-audit-evaluator.md` — update Step 5a, Steps 5b-5h, SC-13
- `.opencode/skills/audit/tasks/spec-audit-investigator.md` — update Step 3
- `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` — update Step 3, PF-7a
- `.opencode/skills/audit/tasks/plan-fidelity-investigator.md` — update Steps 2-5

## Risks

1. **Reference docs don't exist yet**: This spec depends on `.opencode#2210` completing first. If Spec A is delayed, this spec cannot be verified. **Mitigation**: Sequential phase ordering in the overall plan.

2. **Over-correction**: Removing too many criteria could reduce audit coverage. **Mitigation**: Only criteria that were redundant (duplicated by another check), too rare to justify, or checking the wrong artifact were removed. All behavioral and cross-artifact checks remain.

3. **Stale reference in plan-fidelity-evaluator**: PF-DISPATCH-MODE currently references `skills/writing-plans/tasks/write.md` — a file deleted in PR #2082. **Mitigation**: This spec updates that reference to `reference/plan-structure-standards.md`.

## Edge Cases

1. **Reference doc content doesn't match auditor expectations**: If the reference doc defines a structure that the auditor can't derive criteria from, the audit produces incorrect verdicts. **Resolution**: The reference doc is the canonical source — if the auditor can't derive from it, the auditor is wrong and must be fixed.

2. **Remaining hard-coded criteria drift**: PF-1, PF-2, PF-3, PF-5, PF-STRUCTURAL-FAIL, PF-Z3-CONTRACT, PF-SEQUENCE-MATCHES remain as explicit instructions. These could drift from their source definitions. **Resolution**: These are cross-artifact comparisons or behavioral judgments that cannot be codified as structural rules. They are inherently judgment-based.

## Alternatives Considered

1. **Single monolithic spec**: Rejected — split into Spec A (producer side) and Spec B (auditor side) for manageable scope.

2. **Keep all hard-coded criteria**: Rejected — the 36-item misalignment proves this doesn't work.

3. **Move everything to reference docs including behavioral checks**: Rejected — behavioral judgments (determinism, evidence type uplift) cannot be codified as structural rules.

---

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-31 | Initial spec | Created from brainstorming session on 39 items of auditor/producer misalignment | OpenCode (deepseek-v4-flash) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
