> **Full spec and artifacts: [`.issues/1442/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1442)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.

## Problem

Plan auditors (plan-fidelity, concern-separation) can return FAIL findings that include `next_step: proceed` in individual criterion results. The orchestrator then uses this `next_step: proceed` to bypass mandatory remediation and re-audit, treating a FAIL as functionally equivalent to PASS. This creates a silent bypass of the adversarial audit gate.

**Root cause:** Two interacting defects — (1) auditor per-criterion YAML templates default `next_step: "proceed"` unconditionally, and (2) the `create.md` Z3 check only verifies the audit output field exists, not that all criteria passed.

## Scope

**In scope:**
- Fix all 7 auditor task files to reject `next_step: proceed` for FAIL criteria
- Add `all_criteria_pass: bool` field to auditor result contracts
- Fix `create.md` (writing-plans) Steps 17-20 to enforce clean PASS from auditors

**Out of scope:** Cross-validate consensus logic, auditor dispatch, model selection, adversarial-audit SKILL.md routing.

## Approach

Three changes across three file groups:
1. **Auditor task files (7 files):** Replace unconditional `next_step: "proceed"` default with conditional rule — `next_step` MUST be `"remediate"` when `result` is `"FAIL"`, `"proceed"` when `result` is `"PASS"`. Add `all_criteria_pass: bool` field.
2. **create.md (writing-plans):** Steps 18 and 20 Z3 checks MUST verify `all_criteria_pass == true`.
3. **Result contract:** Add `all_criteria_pass: bool` to per-criterion YAML template in all auditor task files.

## Impact

| Risk | Mitigation |
|------|-----------|
| Other auditor files missed in fix sweep | Fix all 7 with same pattern; grep-verify |
| Behavioral tests flake from model non-determinism | Use stderr-based assertions, not prose-recall |
| Z3 check change breaks existing plan creation | Verify existing plan creation still works with clean PASS auditors |

**Call to action:** Approve this spec to proceed with plan creation and implementation.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.issues/1442/`.
After creation, `local-issues sync 1442` MUST be run and the result committed to create the local `.issues/1442/` entry.
The implementation plan will be created in `.issues/1442/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
