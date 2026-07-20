## Problem

AI agents use the plan as an execution checklist, then "optimize" by combining, batching, or skipping steps — producing defective and poisoned work that must be discarded. The existing compliance admonishment in plan files is insufficient because it addresses *consequences* of skipping (rework) but does not specify the *execution protocol*: one step at a time, no batching, no parallel dispatch.

## Solution

Add a new admonishment block to the Plan Format Requirements in `writing-plans/tasks/write.md` and to the plan-fidelity auditor's evaluation criteria. The block is a prose admonishment (not YAML) placed alongside the existing compliance admonishment.

### Required Text

> **One-step-at-a-time protocol**: Each numbered step is exactly one sub-agent dispatch. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel. The RED→GREEN transition is a zero-tolerance gate: the RED test's artifact output MUST be read and confirmed as FAILING before any GREEN implementation begins. If the RED test artifact is not read, or if it shows PASS when FAIL was expected, the phase is poisoned — all work in it MUST be discarded and the phase restarted from RED.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/writing-plans/tasks/write.md` | Add new admonishment block to Plan Format Requirements (after existing compliance admonishment) |
| `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` | Add PF-ONE-STEP criterion to evaluation criteria table |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `write.md` Plan Format Requirements includes the one-step-at-a-time protocol admonishment verbatim | `string` | grep for exact text in `write.md` |
| SC-2 | `plan-fidelity.md` evaluation criteria table includes PF-ONE-STEP criterion checking for the protocol admonishment presence | `string` | grep for `PF-ONE-STEP` in `plan-fidelity.md` |
| SC-3 | Plan-fidelity auditor reports FAIL when a plan file is missing the one-step-at-a-time protocol admonishment | `behavioral` | `opencode-cli run` with a plan missing the block → auditor verdict contains FAIL for PF-ONE-STEP |
| SC-4 | Plan-fidelity auditor reports PASS when a plan file contains the one-step-at-a-time protocol admonishment | `behavioral` | `opencode-cli run` with a plan containing the block → auditor verdict contains PASS for PF-ONE-STEP |

## Implementation Plan

### Phase 1 — Add to plan format

1. Edit `write.md` Plan Format Requirements section: add the new admonishment block after the existing compliance admonishment (item 3), as a separate blockquote
2. Update validation rules (item 13) to require the new admonishment

### Phase 2 — Add to plan-fidelity auditor

1. Add PF-ONE-STEP criterion to the evaluation criteria table in `plan-fidelity.md`
2. Criterion: "One-step-at-a-time protocol admonishment present at top of plan" — FAIL if missing

### Phase 3 — Behavioral tests

1. Write RED behavioral test: plan missing the protocol block → auditor FAIL
2. Write GREEN behavioral test: plan with the protocol block → auditor PASS

## Dependencies

None — this is a standalone format change to the plan template and its auditor.

## Risks

- Low risk: the change is additive (new block, no existing text removed)
- The plan-fidelity auditor already has PF-ADMONISHMENT for the compliance block — PF-ONE-STEP is a parallel criterion, not a replacement
