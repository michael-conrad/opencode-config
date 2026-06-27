# [SPEC-FIX] Orchestrator bypasses cross-validate FAIL — hard gate treated as advisory note

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | The cross-validate step returns `overall_consensus: FAIL` with `next_step: "remediate then re-audit"`, but the orchestrator has no enforcement mechanism that halts on FAIL. During #1442, the orchestrator treated a hard FAIL as a "cross-validate note" and proceeded past the gate. |
| Root Cause / Motivation | Two interacting defects: (1) the orchestrator is not required to follow the `next_step` field from cross-validate, and (2) the pipeline-executor dispatch table has no intermediate gate between cross-validate (step 14) and regression-check (step 15) that checks cross-validate output and blocks on FAIL. |
| Approach Chosen | Add a dedicated pipeline step (14.5 `cross-validate-gate`) in the pipeline-executor dispatch table that reads the cross-validate YAML artifact, checks `overall_consensus`, and HALTs with blocker report on FAIL. |
| Alternatives Considered & Why Discarded | Inline orchestrator logic (invisible to state machine, uncheckpointable); modifying cross-validate task logic (out of scope, changes the wrong layer). |
| Key Design Decisions | Gate as numbered pipeline step (checkpoint-taggable, state-machine-visible); gate reads YAML artifact from disk (consistent with existing pattern). |

## Objective

Add a hard gate in the implementation-pipeline that checks cross-validate output and blocks the pipeline on FAIL, preventing the orchestrator from treating a cross-validate FAIL as an advisory note.

## Problem

During implementation of #1442, the cross-validate step returned `overall_consensus: FAIL` with `next_step: "remediate then re-audit"`. The orchestrator responded with "Cross-validate note: Returned FAIL due to audit evidence format... The actual changes are verified correct. Proceeding with remaining post-steps." — treating a hard FAIL as a note and proceeding past the gate.

## Root Cause

Two interacting defects:

1. **No orchestrator enforcement**: The cross-validate result contract includes `next_step: "remediate then re-audit"` for FAIL, but the orchestrator is not required to follow it. The `next_step` field is advisory — the orchestrator can ignore it.
2. **No pipeline gate**: The `pipeline-executor.md` dispatch table transitions from step 14 (cross-validate) directly to step 15 (regression-check) with no intermediate gate that checks cross-validate output and blocks on FAIL.

## Scope

### In Scope

- Add a cross-validate FAIL gate as a new step in the `pipeline-executor.md` dispatch table (between step 14 and step 15)
- The gate MUST read the cross-validate YAML artifact from disk, check `overall_consensus`, and HALT with blocker report on FAIL
- The gate MUST produce its own YAML artifact at `./tmp/{issue-N}/artifacts/pipeline-cross-validate-gate-{STATUS}-{timestamp}.yaml`
- The gate MUST be checkpoint-taggable (step 14.5 in the dispatch table)
- Behavioral enforcement test verifying the orchestrator halts on cross-validate FAIL

### Out of Scope

- Changes to cross-validate task logic, auditor dispatch, or evidence format requirements
- Changes to the cross-validate YAML schema or result contract format
- Changes to auditor dispatch or resolve-models logic
- Changes to remediation routing (existing FAIL → Researcher → Remediate protocol is sufficient)

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` | Add step 14.5 (cross-validate-gate) to dispatch table; add step label to naming convention; add pre-cleanup action; add Z3 state update entries |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Add step 14.5 to dispatch routing table; add step label to step labels list; add pre-cleanup action |
| `.opencode/tests/behaviors/` | New behavioral enforcement test for cross-validate FAIL gate |

## Fix Approach

Add a new pipeline step `cross-validate-gate` at position 14.5 (between existing step 14 `cross-validate` and step 15 `regression-check`). The gate:

1. Reads the cross-validate YAML artifact from `./tmp/{issue-N}/artifacts/pipeline-cross-validate-{STATUS}-{timestamp}.yaml`
2. Checks the `overall_consensus` field
3. If `overall_consensus == FAIL`: HALT with blocker report, require remediation and re-dispatch (existing FAIL → Researcher → Remediate protocol applies)
4. If `overall_consensus == PASS`: proceed normally to step 15

The gate is a sub-agent task (not inline) — consistent with all other pipeline steps. The sub-agent reads the YAML artifact from disk, evaluates the consensus field, and returns a frugal result contract.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `pipeline-executor.md` dispatch table includes step 14.5 `cross-validate-gate` between step 14 and step 15 | `string` | `grep "14.5.*cross-validate-gate" pipeline-executor.md` | Add the step entry | red-phase | pipeline-executor.md | DEC-1 | single-phase | pre-commit | standalone | none | null | N/A | single-phase |
| SC-2 | `pipeline-executor.md` step 14.5 reads cross-validate YAML artifact and checks `overall_consensus` field | `string` | `grep "overall_consensus" pipeline-executor.md` after the step 14.5 entry | Add the gate logic | red-phase | pipeline-executor.md | DEC-2 | single-phase | pre-commit | standalone | none | null | N/A | single-phase |
| SC-3 | `pipeline-executor.md` step 14.5 HALTs with blocker report when `overall_consensus == FAIL` | `string` | `grep "HALT.*FAIL\|blocker.*FAIL" pipeline-executor.md` near step 14.5 | Add HALT condition | red-phase | pipeline-executor.md | DEC-1 | single-phase | pre-commit | standalone | none | null | N/A | single-phase |
| SC-4 | `pipeline-executor.md` step 14.5 produces YAML artifact at `./tmp/{issue-N}/artifacts/pipeline-cross-validate-gate-{STATUS}-{timestamp}.yaml` | `string` | `grep "pipeline-cross-validate-gate" pipeline-executor.md` | Add artifact path | red-phase | pipeline-executor.md | DEC-2 | single-phase | pre-commit | standalone | none | null | N/A | single-phase |
| SC-5 | `pipeline-executor.md` step 14.5 has checkpoint tag entry (step N = 14.5 → phase-14.5) | `string` | `grep "14.5\|phase-14" pipeline-executor.md` | Add checkpoint entry | red-phase | pipeline-executor.md | DEC-1 | single-phase | pre-commit | standalone | none | null | N/A | single-phase |
| SC-6 | `SKILL.md` dispatch routing table includes `cross-validate-gate` step | `string` | `grep "cross-validate-gate" SKILL.md` | Add routing entry | red-phase | SKILL.md | DEC-1 | single-phase | pre-commit | standalone | none | null | N/A | single-phase |
| SC-7 | `SKILL.md` step labels list includes `cross-validate-gate` | `string` | `grep "cross-validate-gate" SKILL.md` | Add to step labels | red-phase | SKILL.md | DEC-1 | single-phase | pre-commit | standalone | none | null | N/A | single-phase |
| SC-8 | `SKILL.md` pre-cleanup table includes `cross-validate-gate` entry | `string` | `grep "cross-validate-gate.*rm -f" SKILL.md` | Add cleanup entry | red-phase | SKILL.md | DEC-1 | single-phase | pre-commit | standalone | none | null | N/A | single-phase |
| SC-9 | Behavioral enforcement test exists at `.opencode/tests/behaviors/cross-validate-fail-gate.sh` | `behavioral` | `bash .opencode/tests/behaviors/cross-validate-fail-gate.sh` — test sends a prompt that triggers cross-validate FAIL and verifies the orchestrator HALTs instead of proceeding | Write the test; confirm RED (fails before change) then GREEN (passes after change) | green-phase | cross-validate-fail-gate.sh | DEC-1 | single-phase | post-implementation | standalone | none | null | cross-validate-fail-gate.sh | single-phase |
| SC-10 | Behavioral test uses stderr-based assertions (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models`) — not prose-recall prompts | `string` | `grep -E "assert_stderr_pattern\|assert_forbidden_pattern\|assert_required_pattern" .opencode/tests/behaviors/cross-validate-fail-gate.sh` | Use stderr helpers | red-phase | cross-validate-fail-gate.sh | DEC-1 | single-phase | pre-commit | standalone | none | null | cross-validate-fail-gate.sh | single-phase |
| SC-11 | Pipeline state machine updated to include `cross-validate-gate` as a valid transition state | `string` | `grep "cross-validate-gate" .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml` | Add state transition | red-phase | pipeline-state-machine.yaml | DEC-1 | single-phase | pre-commit | standalone | none | null | N/A | single-phase |

## Edge Cases

| Edge Case | Expected Behavior |
|-----------|------------------|
| Cross-validate YAML artifact not found on disk | Gate returns BLOCKED with MISSING_ARTIFACT error — same pattern as other non-recovery gates |
| Cross-validate YAML artifact is unparseable | Gate returns BLOCKED with UNREADABLE_ARTIFACT error |
| Cross-validate YAML artifact has no `overall_consensus` field | Gate returns BLOCKED with MISSING_CONSENSUS_FIELD error |
| Cross-validate returns PASS but with caveats | Gate checks `overall_consensus` only — PASS with caveats is PASS (caveats are handled by the bright-line coercion rule at the pre-dispatch gate, not at the cross-validate gate) |
| Orchestrator bypasses the gate (same pattern as the original bug) | The gate is a numbered pipeline step with checkpoint tagging — bypassing it means skipping a checkpoint, which is detectable via state machine validation |

## Regression Invariants

1. Existing cross-validate YAML schema MUST remain unchanged
2. Existing cross-validate task logic MUST remain unchanged
3. Existing FAIL → Researcher → Remediate protocol MUST remain unchanged
4. All existing pipeline steps MUST retain their current positions and behavior

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |

## Decomposition Classification

| Classification | Value |
| -------------- | ----- |
| Type | single-task |
| Phases | 1 |
| Sub-Issues | None |
| PR Strategy | single PR |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Gate as dedicated pipeline step (14.5), not inline orchestrator logic | Inline logic is invisible to state machine, uncheckpointable, and un-auditable. A dedicated step is checkpoint-taggable, subject to remediation routing, and visible in Z3 state transitions. | MUST | SC-1, SC-2, SC-3, SC-4, SC-5 |
| DEC-2 | Gate reads YAML artifact from disk, not result contract | Consistent with existing pattern — orchestrator reads only YAML frontmatter from disk artifact. Preserves frugal result contract pattern. | MUST | SC-2, SC-3 |
| DEC-3 | Gate is a sub-agent task, not inline | Consistent with all other pipeline steps. The sub-agent reads the YAML artifact, evaluates consensus, and returns a frugal result contract. | MUST | SC-1 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Orchestrator skips the gate step | Low | High | Gate is a numbered pipeline step with checkpoint tagging — state machine detects skipped transitions | SC-11 |
| RISK-2 | YAML artifact not found or unparseable | Low | Medium | Gate returns BLOCKED with specific error codes | SC-2 |
| RISK-3 | Behavioral test flakes due to model non-determinism | Medium | Medium | Use stderr-based assertions (deterministic tool dispatch strings) not prose-recall | SC-10 |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep "cross-validate" .opencode/skills/implementation-pipeline/` | Verify no existing FAIL gate exists |
| Direct source search | `grep "overall_consensus" .opencode/skills/implementation-pipeline/` | Verify no consensus check in pipeline |
| MCP search | `read pipeline-executor.md` | Verify dispatch table step sequence |
| MCP search | `read cross-validate.md` | Verify cross-validate result contract format |
| MCP search | `read SKILL.md` | Verify dispatch routing table and step labels |
| MCP search | `read assemble-work.md` | Verify orchestrator entry point |

After this spec is approved, invoke `writing-plans` to create `.issues/1448/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
