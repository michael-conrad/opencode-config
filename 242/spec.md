> **Migrated to `michael-conrad/.opencode#1666`** — this issue was filed in the wrong repo. The plan-fidelity audit lives in the `.opencode` submodule repo. All future work on this spec-fix should reference `.opencode#1666`.

---

## Problem

The current workflow has a gap: after plan creation, the `plan-fidelity` audit (criterion PF-3) claims to verify that the plan covers all spec success criteria, but it does so **indirectly** — by comparing the existing plan against a clean-room plan, not by directly cross-referencing the spec's SC table against the plan's step structure.

The `validate` step (check 02) checks plan completeness against the spec's problem statement, not against individual SCs. The `spec-to-plan-handoff` validates SC summary YAML is well-formed before plan creation but doesn't check the resulting plan against it. The `pre-red-baseline` (implementation-pipeline Step 2) checks SC-ID traceability in TDD headings, but this runs during implementation, not after plan creation.

**Root cause:** PF-3's expected result says "Each SC has corresponding step — missing any is automatic FAIL" but the actual implementation compares the existing plan against a clean-room plan (which may itself be incomplete or miss SCs), not against the spec's SC table directly. This is an indirect check that can miss SC coverage gaps.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | New gate exists that directly cross-references spec SC table against plan step structure | `string` | grep for the gate's evaluation criterion in the relevant task file |
| SC-2 | Gate produces PASS only when every spec SC-ID has a corresponding plan step | `behavioral` | `opencode-cli run` with a complete plan → gate verdict contains PASS |
| SC-3 | Gate produces FAIL with specific missing SC-IDs when coverage is incomplete | `behavioral` | `opencode-cli run` with a plan missing SC-3 → gate verdict contains FAIL and lists SC-3 |
| SC-4 | Gate runs as a mandatory post-plan-creation check before plan approval for implementation | `string` | grep for the gate in the writing-plans pipeline (between validate and audit-fidelity) |
| SC-5 | Existing plan-fidelity PF-3 is either strengthened or replaced (no duplicate/conflicting gates) | `string` | grep PF-3 in plan-fidelity.md — either removed or updated to reference the new gate |
| SC-6 | Behavioral enforcement test verifies the gate catches an incomplete plan | `behavioral` | `opencode-cli run` with a plan missing one SC → gate FAILs with the missing SC-ID |

## Design Options

### Option A (Recommended): Strengthen PF-3 in plan-fidelity

Change PF-3 from clean-room plan comparison to direct SC table comparison. The auditor reads the spec's SC table from the issue body, reads the plan's step structure, and produces PASS/FAIL on "every SC-ID from the spec has a corresponding plan step." The clean-room plan comparison (PF-1, PF-2) remains for structural fidelity.

**Pros:** Minimal change — single criterion update in one file. No new task files. No pipeline restructuring.
**Cons:** Changes the semantics of PF-3 from "plan vs clean-room plan" to "plan vs spec SCs". Must ensure the existing clean-room comparison is not lost.

### Option B: New standalone audit task in adversarial-audit

Create a new `--task sc-coverage` in adversarial-audit that reads the spec SC table and plan step structure independently.

**Pros:** Clean separation of concerns. No semantic drift on existing criteria.
**Cons:** New task file, new dispatch table entry, new pipeline step. More surface area.

### Option C: New check in writing-plans/tasks/validate.md

Add a new validation check (check 19) to the validate step that reads the spec SC table and verifies plan coverage.

**Pros:** Close to the plan creation pipeline. Natural fit for a validation check.
**Cons:** The validate step runs at orchestrator level (inline), not as an adversarial audit. Loses the adversarial separation that makes audits reliable.

### Option D: New step in the writing-plans pipeline

Add a new step between Step 15 (validate) and Step 17 (audit-fidelity) in the writing-plans pipeline.

**Pros:** Explicit pipeline step. Clear position in the dependency chain.
**Cons:** Adds another step to an already long 22-step pipeline. Requires updating the pipeline numbering and Z3 checks.

## Recommended Approach: Option A

Strengthen PF-3 in `plan-fidelity.md` to use direct SC table comparison. The change:

1. **PF-3 description** changes from "Steps cover ALL success criteria; missing any is automatic FAIL per spec gate" to "Every spec SC-ID has a corresponding plan step — direct SC table comparison, not clean-room comparison"
2. **PF-3 expected result** changes from "Each SC has corresponding step — missing any is automatic FAIL" to "Every SC-ID from the spec's SC table has at least one plan step referencing it. Missing SC-IDs are listed in the FAIL verdict."
3. **PF-3 procedure** adds a step: read spec issue body, extract SC table (SC-IDs), read plan step structure, cross-reference, report missing SC-IDs
4. **New criterion PF-3a** (or rename existing): "Clean-room plan comparison for structural fidelity" — preserves the existing clean-room comparison that PF-3 currently performs, now as a separate criterion

This avoids duplication: PF-3 becomes the direct SC coverage gate, and a new/additional criterion preserves the clean-room structural comparison.

## Implementation Plan

### Phase 1: Design the gate

- Confirm Option A as the approach
- Define the exact PF-3 replacement text
- Define the new/additional criterion for clean-room structural comparison
- Map the data flow: spec issue → SC table extraction → plan step structure → cross-reference → verdict

### Phase 2: Implement the gate

- Update `plan-fidelity.md` Step 3 evaluation criteria table:
  - Replace PF-3 with direct SC coverage criterion
  - Add PF-3a (or equivalent) for clean-room structural comparison
- Update Step 2 (Fetch Existing Plan) to also fetch the spec and extract SC table
- Update Step 5 (Classify Discrepancies) to include MISSING_SC as a finding type
- Update the verdict artifact schema to include per-SC coverage results

### Phase 3: Add behavioral enforcement test

- Write RED behavioral test: plan missing SC-3 → gate FAILs with SC-3 listed
- Write GREEN behavioral test: complete plan → gate PASSes
- Write RED behavioral test: plan with all SCs but wrong approach → PF-3a catches it

### Phase 4: Update plan-fidelity PF-3 to avoid duplication/conflict

- Ensure PF-3 and the new clean-room criterion have distinct IDs and non-overlapping scope
- Update the completion dependency chain if needed
- Update cross-references

## Constraints

- Must not duplicate existing checks (validate check 02, pre-red-baseline)
- Must not break the existing plan-fidelity audit (PF-1, PF-2, PF-4 through PF-SEQUENCE-MATCHES remain unchanged)
- Must use direct SC table comparison, not clean-room plan comparison
- The clean-room plan comparison must be preserved as a separate criterion (not lost)

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` | Replace PF-3 with direct SC coverage criterion; add clean-room structural comparison criterion |
| `.opencode/tests/behaviors/plan-fidelity-sc-coverage.sh` | NEW — behavioral test for SC-2, SC-3, SC-6 |

## Risks

- Low: PF-3 semantic change is contained to one criterion in one file
- The clean-room plan comparison is preserved as a separate criterion, so no fidelity loss
- The plan-fidelity auditor already reads the spec (via `spec_local_dir`), so SC table extraction is additive, not new infrastructure

## Dependencies

None — this is a standalone change to the plan-fidelity evaluation criteria.

## Changelog

- v1 — Initial spec

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)