## Problem

The plan-fidelity auditor (`adversarial-audit/tasks/plan-fidelity.md`) embeds expected values directly in its evaluation criteria descriptions instead of reading them dynamically from the authoritative skill cards. This causes false FAIL verdicts when the authoritative source changes but the auditor's hard-coded values don't.

Two specific criteria are affected:

### 1. PF-DISPATCH-MODE — Vocabulary Mismatch

**Current hard-coded value** (plan-fidelity.md:101):
> Every step title contains `(**clean-room**)` or `(**inline**)` — exactly one of the two

**Authoritative source** (`writing-plans/tasks/write.md` §Dispatch Indicators, lines 102-110) defines **three** valid indicators:

| Indicator | Meaning |
|-----------|---------|
| `(**sub-agent**)` | Orchestrator dispatches a clean-room sub-agent via `task()` |
| `(**clean-room**)` | Orchestrator dispatches a clean-room sub-agent (same as sub-agent) |
| `(**inline**)` | Orchestrator executes directly |

The `writing-plans` skill's own operating protocol (SKILL.md) uses `(**sub-agent**)` in 14 of 22 steps. The auditor rejects `(**sub-agent**)` because its internal list only has two entries.

### 2. PF-Z3-CONTRACT — Fabricated Format

**Current hard-coded value** (plan-fidelity.md:98):
> Hierarchical phase→item→gate booleans exist (e.g., P1_I1_G1, P1_I2_G1)

**No authoritative source defines this format.** The `solve` skill's contract schema (`solve/tasks/contract.md`) defines variables with `type`/`domain`/`nullable` fields and Z3 expressions — no `P1_I1_G1` naming convention exists anywhere in the `solve` skill, `writing-plans` skill, or `implementation-pipeline` skill.

### 3. PF-SEQUENCE-MATCHES — Correct Pattern (Contrast)

This criterion (plan-fidelity.md:106) does it correctly:
> Gate sequence matches `implementation-pipeline/SKILL.md` dispatch routing table — **read dynamically, not hardcoded**

This is the pattern the other two criteria should follow.

## Root Cause

The plan-fidelity auditor's evaluation criteria table embeds expected values directly in the criterion descriptions instead of referencing the authoritative skill cards. When the `writing-plans` skill's vocabulary changes (e.g., adding `(**sub-agent**)` as a valid indicator), the auditor silently enforces the old values because its criteria are hard-coded strings, not dynamic reads.

## Scope

Single file: `adversarial-audit/tasks/plan-fidelity.md`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | PF-DISPATCH-MODE expected result changed from hard-coded `(**clean-room**) or (**inline**)` to a dynamic reference: "valid dispatch indicator per `writing-plans/tasks/write.md` §Dispatch Indicators" | `string` | grep for the updated criterion text in plan-fidelity.md |
| SC-2 | PF-Z3-CONTRACT expected result changed from hard-coded `P1_I1_G1` format to reference the actual `solve` skill's contract schema format, or removed if no authoritative source defines a naming convention | `string` | grep for the updated criterion text in plan-fidelity.md |
| SC-3 | A general note or principle added to the evaluation criteria section stating that criteria expected values MUST reference authoritative skill cards, not hard-code values | `string` | grep for the added principle text in plan-fidelity.md |
| SC-4 | All other criteria in the evaluation criteria table are reviewed for hard-coded values that should be dynamic references; any found are flagged for follow-up | `string` | grep for any remaining hard-coded expected values that should be dynamic |

## Files Affected

- `adversarial-audit/tasks/plan-fidelity.md` — evaluation criteria table (lines 87-106)

## Risks

- Low: Changing criterion descriptions does not affect audit logic, only the expected values the auditor checks against
- The auditor sub-agent reads the task file independently, so the change takes effect on next dispatch

## Dependencies

None.

## Revisions

- v1 — Initial spec

---
🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
