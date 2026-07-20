## Problem

The `sc-pipeline-readiness.yaml` artifact is missing when spec-creation hands off to writing-plans. The root cause is that the pipeline-readiness gate is not explicitly positioned in the spec-creation Operating Protocol as a numbered step — it is only enforced reactively via a symbolic rule (`spec-creation-pipeline-readiness`) that fires when SCs are finalized.

### Root Cause Analysis

The `pipeline-readiness-gate` task file (`spec-creation/tasks/pipeline-readiness-gate.md`) exists and is well-defined. It states it runs "after traceability and before risk analysis" (line 11). However:

1. **Operating Protocol gap:** The 10-step Operating Protocol in `spec-creation/SKILL.md` (lines 58-67) lists traceability as step 4 and risk as step 5 with no intervening step. The pipeline-readiness gate is not numbered between them.

2. **Task table omission:** The SKILL.md Tasks table (lines 38-41) only lists `create` and `completion`. The `pipeline-readiness-gate` task is not listed as a dispatchable task, even though the symbolic rule references `CALL(spec-creation --task pipeline-readiness-gate)`.

3. **Reactive enforcement, not procedural:** The symbolic rule `spec-creation-pipeline-readiness` (lines 160-167) fires when `spec_sc_finalized == true` — which happens during the write step (step 9), long after the gate should have run (between traceability/step 4 and risk/step 5). This means:
   - The gate fires too late — after all analysis (risk, solve, plan) is complete
   - If the gate fails, all downstream work (risk, solve, plan, write) must be re-executed
   - The agent must discover the gate exists by reading symbolic rules, not by following the Operating Protocol

### Impact

- Spec-creation pipeline produces incomplete artifacts
- Writing-plans readiness step (`writing-plans/tasks/readiness.md` Step 1) reads `sc-pipeline-readiness.yaml` and returns `SPEC_NOT_READY_FOR_PIPELINE` when missing
- Behavioral tests SC-2, SC-8, and SC-13 verify this artifact must exist, but the pipeline doesn't reliably produce it

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `pipeline-readiness-gate` is listed as a dispatchable task in the spec-creation SKILL.md Tasks table | `string` | grep for `pipeline-readiness-gate` in spec-creation/SKILL.md task table |
| SC-2 | Operating Protocol includes pipeline-readiness gate as a numbered step between traceability (step 4) and risk (step 5) | `string` | grep for numbered step between traceability and risk in Operating Protocol |
| SC-3 | The symbolic rule `spec-creation-pipeline-readiness` fires at the correct pipeline position (between traceability and risk) rather than at spec finalization | `semantic` | Sub-agent reads SKILL.md symbolic rules and evaluates trigger conditions |
| SC-4 | Behavioral test verifies that spec-creation pipeline produces `sc-pipeline-readiness.yaml` with PASS status when all checks pass | `behavioral` | `opencode-cli run` with spec-creation prompt, verify artifact exists with `status: PASS` |
| SC-5 | Behavioral test verifies that plan creation halts with `SPEC_NOT_READY_FOR_PIPELINE` when artifact is missing (regression guard for existing SC-8) | `behavioral` | `opencode-cli run` with plan-creation prompt, verify BLOCKED with SPEC_NOT_READY_FOR_PIPELINE |

## Affected Files

- `.opencode/skills/spec-creation/SKILL.md` — Add pipeline-readiness-gate to task table, insert as numbered step in Operating Protocol, update symbolic rule trigger conditions
- `.opencode/tests/behaviors/1110-sc2-pipeline-readiness-yaml.sh` — Update if needed
- `.opencode/tests/behaviors/1110-sc8-missing-readiness-halts-plan.sh` — Update if needed
- `.opencode/tests/behaviors/1110-sc13-spec-finalization-halt-without-readiness.sh` — Update if needed

## Change Control

**Status:** DRAFT
**Author:** AI agent
**Date:** 2026-06-30

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
