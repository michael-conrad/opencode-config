<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# [SPEC-FIX] Auditor gate bypass — next_step: proceed on FAIL criteria allows orchestrator to skip mandatory remediation

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | Plan auditors can return FAIL findings with `next_step: proceed`, allowing the orchestrator to bypass mandatory remediation and re-audit |
| **Root Cause / Motivation** | Per-criterion YAML templates default `next_step: "proceed"` unconditionally; `create.md` Z3 checks only verify output field existence, not clean PASS |
| **Approach Chosen** | Conditional `next_step` on PASS/FAIL result + `all_criteria_pass: bool` field + Z3 check enforcement |
| **Alternatives Considered & Why Discarded** | Parsing per-criterion results in orchestrator (more complex, more fragile than single boolean field) |
| **Key Design Decisions** | DEC-1: Fix all 7 auditor files; DEC-2: Single `all_criteria_pass` boolean; DEC-3: `next_step` conditional on result |

## Problem

Plan auditors (plan-fidelity, concern-separation) can return non-clean PASS results (BLOCKED with FAIL findings) that include `next_step: proceed` in individual criterion findings. The orchestrator then uses this `next_step: proceed` to bypass mandatory remediation and re-audit, treating a FAIL as "functionally equivalent to PASS."

## Root Cause

Two interacting defects:

1. **plan-fidelity.md** (`adversarial-audit/tasks/plan-fidelity.md` Step 7) — The per-criterion YAML template includes `next_step: "proceed"` as the default value. When a criterion FAILs, the auditor sub-agent can set `next_step: proceed` instead of `next_step: remediate`, creating an escape hatch that lets the orchestrator bypass remediation.

2. **create.md** (`writing-plans/tasks/create.md` Steps 17-20) — Steps 17-18 (audit-fidelity) and 19-20 (audit-concern) expect `PASS in audit-fidelity output` and `PASS in audit-concern output`, but the Z3 check only verifies the output field exists — it does NOT enforce that the audit result is a clean PASS (all criteria PASS, no FAIL findings). When the auditor returns BLOCKED with FAIL findings, the orchestrator can proceed if the finding says `next_step: proceed`.

**Concrete example from session:**
- plan-fidelity auditor returned `status: BLOCKED` with 1 FAIL (PF-7a: cost-frame prose gap)
- The FAIL finding included `next_step: proceed` and `classification: SPEC_GAP`
- The orchestrator treated this as "proceed per finding's recommendation" instead of treating it as a hard FAIL requiring remediation and re-audit

## Scope

### In Scope

- Fix `plan-fidelity.md` per-criterion template to reject `next_step: proceed` for FAIL criteria
- Fix `concern-separation.md` per-criterion template to reject `next_step: proceed` for FAIL criteria
- Fix `create.md` (writing-plans) Steps 17-20 to enforce clean PASS from auditors
- Add `all_criteria_pass: bool` field to auditor result contracts
- Add `mandatory_remediation` field enforcement in orchestrator gate check
- All other auditor task files (spec-audit, guideline-audit, verification-audit, closure-verification, cross-validate) have the same `next_step: "proceed"` default in per-criterion templates — these MUST be fixed identically

### Out of Scope

- Changes to the cross-validate task's consensus logic (cross-validate already correctly maps FAIL → `remediate then re-audit`)
- Changes to auditor dispatch or model selection
- Changes to the adversarial-audit SKILL.md routing

## Approach

Three changes across three file groups:

1. **Auditor task files (7 files):** Replace the unconditional `next_step: "proceed"` default in per-criterion YAML templates with a conditional rule: `next_step` MUST be `"remediate"` when `result` is `"FAIL"`, and MUST be `"proceed"` when `result` is `"PASS"`. Add a validation rule in each file's yaml+symbolic rules section.

2. **create.md (writing-plans):** Steps 18 and 20 Z3 checks MUST verify `all_criteria_pass == true`, not just that the output field exists. The orchestrator MUST NOT proceed past the audit gate unless the auditor result contract has `all_criteria_pass: true`.

3. **Result contract:** Add `all_criteria_pass: bool` to the per-criterion YAML template in all auditor task files. The orchestrator checks this field before proceeding past any audit gate.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` | Per-criterion template: `next_step` conditional on PASS/FAIL; add `all_criteria_pass`; add validation rule |
| `.opencode/skills/adversarial-audit/tasks/concern-separation.md` | Same as plan-fidelity |
| `.opencode/skills/adversarial-audit/tasks/spec-audit.md` | Same as plan-fidelity |
| `.opencode/skills/adversarial-audit/tasks/guideline-audit.md` | Same as plan-fidelity |
| `.opencode/skills/adversarial-audit/tasks/verification-audit.md` | Same as plan-fidelity |
| `.opencode/skills/adversarial-audit/tasks/closure-verification.md` | Same as plan-fidelity |
| `.opencode/skills/adversarial-audit/tasks/cross-validate.md` | Per-criterion template: `next_step` conditional on PASS/FAIL; add `all_criteria_pass` |
| `.opencode/skills/writing-plans/tasks/create.md` | Steps 18, 20: enforce `all_criteria_pass == true` in Z3 check |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Fix ALL 7 auditor task files, not just plan-fidelity and concern-separation | The same `next_step: "proceed"` default exists in spec-audit, guideline-audit, verification-audit, closure-verification, and cross-validate — all have the same bypass vulnerability | MUST | SC-1, SC-2 |
| DEC-2 | Add `all_criteria_pass` field to result contract rather than parsing per-criterion results | Single boolean field is simpler for orchestrator to check than iterating N criteria | MUST | SC-5, SC-6 |
| DEC-3 | `next_step` conditional on `result` — not advisory | Prevents auditor sub-agents from setting `proceed` on FAIL, which is the root cause | MUST | SC-1, SC-2 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Other auditor task files missed in fix sweep | Medium | High | Fix all 7 files with same pattern; grep for `next_step: "proceed"` in all task files | SC-1 |
| RISK-2 | Behavioral tests flake due to model non-determinism | Medium | Medium | Use stderr-based assertions (tool dispatch strings) not prose-recall prompts | SC-3, SC-4, SC-6 |
| RISK-3 | Z3 check change in create.md breaks existing plan creation | Low | High | Verify existing plan creation still works with clean PASS auditors | SC-3, SC-4 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Phase Binding | Verification Gate | Integration Mode |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|--------------|-----------------|-----------------|
| SC-1 | All 7 auditor task files reject `next_step: proceed` for FAIL criteria — `next_step` MUST be `"remediate"` when `result` is `"FAIL"` | `string` | `grep -A2 'result: "FAIL"' .opencode/skills/adversarial-audit/tasks/*.md` — verify no FAIL template shows `next_step: "proceed"` | If any FAIL template shows `proceed`, fix template and re-grep | pre-commit | `.opencode/skills/adversarial-audit/tasks/` | Phase 1 | pre-commit | atomic |
| SC-2 | All 7 auditor task files have `all_criteria_pass: bool` in per-criterion YAML template and result contract | `string` | `grep 'all_criteria_pass' .opencode/skills/adversarial-audit/tasks/*.md` — must appear in all 7 task files | If missing, add field to template and result contract | pre-commit | `.opencode/skills/adversarial-audit/tasks/` | Phase 1 | pre-commit | atomic |
| SC-3 | create.md step 18 Z3 check enforces clean PASS from audit-fidelity — orchestrator MUST halt when `all_criteria_pass: false` | `behavioral` | Run plan creation pipeline with audit returning FAIL findings — `assert_stderr_pattern_present 'all_criteria_pass: false'` followed by `assert_stderr_pattern_present 'BLOCKED'` or halt signal | If orchestrator proceeds past FAIL audit, fix Z3 check in create.md step 18 | pre-commit | `.opencode/skills/writing-plans/tasks/create.md` | Phase 2 | pre-commit | atomic |
| SC-4 | create.md step 20 Z3 check enforces clean PASS from audit-concern — orchestrator MUST halt when `all_criteria_pass: false` | `behavioral` | Run plan creation pipeline with concern-separation audit returning FAIL — `assert_stderr_pattern_present 'all_criteria_pass: false'` followed by halt signal | If orchestrator proceeds past FAIL audit, fix Z3 check in create.md step 20 | pre-commit | `.opencode/skills/writing-plans/tasks/create.md` | Phase 2 | pre-commit | atomic |
| SC-5 | cross-validate.md per-criterion template has `next_step` conditional on PASS/FAIL and includes `all_criteria_pass` | `string` | `grep 'all_criteria_pass' .opencode/skills/adversarial-audit/tasks/cross-validate.md` — must be present | If missing, add to template | pre-commit | `.opencode/skills/adversarial-audit/tasks/cross-validate.md` | Phase 1 | pre-commit | atomic |
| SC-6 | Orchestrator checks `all_criteria_pass` before proceeding past any audit gate — halts on `all_criteria_pass: false` | `behavioral` | Run pipeline with mixed audit results (some PASS, some FAIL) — `assert_stderr_pattern_present 'all_criteria_pass.*false'` followed by halt signal | If orchestrator proceeds, fix gate check in create.md | pre-commit | `.opencode/skills/writing-plans/tasks/create.md` | Phase 2 | pre-commit | atomic |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Edge Cases

| Case | Expected Behavior |
|------|------------------|
| Auditor returns all PASS with `all_criteria_pass: true` | Orchestrator proceeds normally — no change from current behavior |
| Auditor returns mixed results (some PASS, some FAIL) | `all_criteria_pass: false` → orchestrator MUST halt and require remediation |
| Auditor returns all FAIL | `all_criteria_pass: false` → orchestrator MUST halt and require remediation |
| Auditor result contract missing `all_criteria_pass` field | Orchestrator MUST treat as `all_criteria_pass: false` (fail-safe default) |
| Cross-validate returns FAIL consensus | Cross-validate already correctly returns `next_step: "remediate then re-audit"` — no change needed |

## Regression Invariants

1. Existing plan creation with clean PASS auditors MUST continue to work without changes
2. The `next_step` field in cross-validate's result contract MUST remain `"proceed"` for PASS and `"remediate then re-audit"` for FAIL — cross-validate already handles this correctly
3. Auditor sub-agents MUST NOT be re-tasked after a FAIL verdict — FAIL stays FAIL per adversarial-audit-005

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep 'next_step: "proceed"' .opencode/skills/adversarial-audit/tasks/*.md` | Identify all auditor task files with the same pattern |
| Direct source search | `grep 'all_criteria_pass' .opencode/skills/` | Verify `all_criteria_pass` field does not exist yet |
| Direct source search | `read .opencode/skills/writing-plans/tasks/create.md` | Verify Steps 17-20 Z3 check behavior |
| Direct source search | `read .opencode/skills/adversarial-audit/tasks/cross-validate.md` | Verify cross-validate already handles FAIL → `remediate then re-audit` correctly |

After this spec is approved, invoke `writing-plans` to create `.issues/1442/plan.md` before implementation begins.

Co-authored with AI: OpenCode (deepseek-v4-flash)
