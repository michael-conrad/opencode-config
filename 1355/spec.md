# [SPEC-FIX] DONE_WITH_CONCERNS Coercion Gap — Result Contract Status Enum Leak

**STATUS:** DRAFT
**CREATED:** 2026-06-23
**TYPE:** SPEC-FIX
**REPO:** michael-conrad/.opencode

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Content |
|-------|---------|
| **Problem Statement** | `DONE_WITH_CONCERNS` is listed as a valid result contract status in multiple enforcement files (`pipeline-executor.md`, `approval-gate/SKILL.md`, `work-state-verification.md`, `screen-issue-gate2.md`) but has no routing rule — orchestrators receiving it have no defined action. This creates a coercion gap where sub-agents can return a non-DONE status that the pipeline treats as valid completion, bypassing the hard-fail gate. |
| **Root Cause / Motivation** | `pipeline-executor.md` Step 0 (pre-dispatch gate) lists `DONE_WITH_CONCERNS` alongside `DONE` and `BLOCKED` as valid statuses but provides no routing rule for it. The `critical-rules-hard-fail` symbolic rule in `000-critical-rules.md` does not include `DONE_WITH_CONCERNS` in its conditions. The `020-go-prohibitions.md` §1.1 Result Contract Frugality table lists `DONE_WITH_CONCERNS` as a valid status. Multiple enforcement files accept it as valid completion without defining what action to take. |
| **Approach Chosen** | Bright-line coercion rule: `status != DONE → FAIL; status == DONE with non-empty caveat summary → FAIL`. Remove `DONE_WITH_CONCERNS` from all status enums in enforcement files. Add behavioral enforcement test using `assert_semantic` (clean-room AI inspector) to verify the orchestrator coerces `DONE_WITH_CONCERNS` to FAIL and routes to remediation. Preserve `DONE_WITH_CONCERNS` in `writing-plans/tasks/revisit.md` where it serves a distinct purpose (partial resolution signaling). |
| **Alternatives Considered & Why Discarded** | (1) Add a routing rule for `DONE_WITH_CONCERNS` — rejected because it creates a soft-pass path that undermines the hard-fail gate. (2) Treat `DONE_WITH_CONCERNS` as `DONE` — rejected because caveats are defects, not completions. (3) Remove `DONE_WITH_CONCERNS` entirely including from `revisit.md` — rejected because revisit.md uses it for a different semantic (partial resolution, not completion). |
| **Key Design Decisions** | DEC-1: Coercion is bright-line — no gray zone between DONE and FAIL. DEC-2: `revisit.md` preservation is intentional — its `DONE_WITH_CONCERNS` signals partial resolution, not completion, and belongs to a different pipeline stage. DEC-3: Behavioral enforcement test uses `assert_semantic` (clean-room AI inspector) because the coercion decision is an agent action, not a text pattern. |

## Objective

Close the coercion gap in the result contract status pipeline by establishing a bright-line coercion rule that eliminates the `DONE_WITH_CONCERNS` escape hatch from all enforcement files while preserving its legitimate use in the writing-plans revisit workflow.

## Problem

The result contract status enum currently includes four values: `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, and `OVERFLOW`. The `critical-rules-hard-fail` symbolic rule in `000-critical-rules.md` defines FAIL as a hard gate but does not include `DONE_WITH_CONCERNS` in its conditions. The `pipeline-executor.md` pre-dispatch gate lists `DONE_WITH_CONCERNS` as a valid status with no routing rule — orchestrators receiving it have no defined action.

This creates a coercion gap: a sub-agent can return `DONE_WITH_CONCERNS` (effectively "done but with problems") and the pipeline has no rule to coerce it to FAIL. The orchestrator may treat it as valid completion, bypassing the hard-fail gate and allowing defective work to proceed downstream.

The gap exists across eight files:
- `pipeline-executor.md` — lists `DONE_WITH_CONCERNS` as valid status with no routing rule
- `000-critical-rules.md` — `critical-rules-hard-fail` symbolic rule does not include `DONE_WITH_CONCERNS`
- `065-verification-honesty.md` — Hard Failure Discipline section does not reference `DONE_WITH_CONCERNS`
- `020-go-prohibitions.md` — Result Contract Frugality table lists `DONE_WITH_CONCERNS` as valid status
- `implementation-pipeline/SKILL.md` — line 69 references `DONE_WITH_CONCERNS` in adversarial-audit step
- `approval-gate/SKILL.md` — line 10 lists `DONE_WITH_CONCERNS` in result contract status enum
- `work-state-verification.md` — line 11 accepts `DONE_WITH_CONCERNS` as valid completion
- `screen-issue-gate2.md` — line 182 lists `DONE_WITH_CONCERNS` in status enum

One file intentionally preserves `DONE_WITH_CONCERNS`:
- `writing-plans/tasks/revisit.md` — line 25 returns `DONE_WITH_CONCERNS` for partial resolution (distinct semantic from completion)

## Affected Files

| File | Anchor | Current State | Required Change |
|------|--------|---------------|-----------------|
| `implementation-pipeline/tasks/pipeline-executor.md` | Step 0 (pre-dispatch gate) | Lists `DONE_WITH_CONCERNS` as valid status, no routing rule | Add coercion rule block: `status != DONE → FAIL; status == DONE with non-empty caveat summary → FAIL` |
| `000-critical-rules.md` | `critical-rules-hard-fail` symbolic rule | Conditions do not include `DONE_WITH_CONCERNS` | Add `DONE_WITH_CONCERNS` to conditions `any` block |
| `065-verification-honesty.md` | Hard Failure Discipline section | No reference to `DONE_WITH_CONCERNS` | Add `DONE_WITH_CONCERNS` coercion trigger |
| `020-go-prohibitions.md` | §1.1 Result Contract Frugality table | Lists `DONE_WITH_CONCERNS` as valid status | Remove `DONE_WITH_CONCERNS` from valid status table; valid statuses: `DONE`, `BLOCKED`, `OVERFLOW` |
| `implementation-pipeline/SKILL.md` | Line 69 (adversarial-audit step) | References `DONE_WITH_CONCERNS` | Remove `DONE_WITH_CONCERNS` from status enum |
| `approval-gate/SKILL.md` | Line 10 (result contract status enum) | Lists `DONE_WITH_CONCERNS` | Remove `DONE_WITH_CONCERNS` from status enum |
| `implementation-pipeline/enforcement/work-state-verification.md` | Line 11 | Accepts `DONE_WITH_CONCERNS` as valid completion | Change to treat `DONE_WITH_CONCERNS` as FAIL |
| `approval-gate/tasks/screen/screen-issue-gate2.md` | Line 182 | Lists `DONE_WITH_CONCERNS` in status enum | Remove `DONE_WITH_CONCERNS` from status enum |
| `writing-plans/tasks/revisit.md` | Line 25 | Returns `DONE_WITH_CONCERNS` for partial resolution | **PRESERVE** — no modification. Distinct semantic from completion. |
| `writing-plans/contracts/revisit-output-template.yaml` | Status field | Includes `DONE_WITH_CONCERNS` | **PRESERVE** — no modification. |
| `.opencode/tests/behaviors/` | New scenario | No coercion enforcement test exists | Create behavioral enforcement test scenario |

## Fix Approach

### Phase 1: Coercion Rule Definition (U1)

Add a coercion rule block to `pipeline-executor.md` Step 0 (pre-dispatch gate). The rule is bright-line:

```
status != DONE → FAIL
status == DONE with non-empty caveat_summary → FAIL
```

The orchestrator MUST coerce any non-DONE status (including `DONE_WITH_CONCERNS`) to FAIL and route to remediation. A `DONE` status with a non-empty `caveat_summary` field is also coerced to FAIL — caveats are defects, not completions.

### Phase 2: Symbolic Rule Update (U2)

Update `critical-rules-hard-fail` in `000-critical-rules.md` to include `DONE_WITH_CONCERNS` in its conditions `any` block. This ensures the symbolic enforcement layer catches the coercion gap at the rule level.

### Phase 3: Verification Honesty Wiring (U3)

Add `DONE_WITH_CONCERNS` coercion trigger to `065-verification-honesty.md` §Hard Failure Discipline. This wires the coercion rule into the verification honesty enforcement chain.

### Phase 4: Status Enum Cleanup (U4-U7)

Remove `DONE_WITH_CONCERNS` from all status enums in enforcement files:
- `020-go-prohibitions.md` §1.1 Result Contract Frugality table
- `implementation-pipeline/SKILL.md` line 69
- `approval-gate/SKILL.md` line 10
- `work-state-verification.md` line 11 (change to treat as FAIL)
- `screen-issue-gate2.md` line 182

### Phase 5: Revisit Preservation (U8)

Verify `writing-plans/tasks/revisit.md` line 25 and `revisit-output-template.yaml` are unchanged. `DONE_WITH_CONCERNS` in revisit.md signals partial resolution — a distinct semantic from completion that belongs to a different pipeline stage.

### Phase 6: Behavioral Enforcement Test (U9)

Create a behavioral enforcement test scenario in `.opencode/tests/behaviors/` using `assert_semantic` (clean-room AI inspector). The test MUST verify that the orchestrator coerces `DONE_WITH_CONCERNS` to FAIL and routes to remediation.

## Success Criteria

**🚫 ALL-OR-NOTHING GATE: ALL success criteria MUST pass for implementation to be considered complete.**

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `pipeline-executor.md` Step 0 contains a bright-line coercion rule: `status != DONE → FAIL; status == DONE with non-empty caveat_summary → FAIL`. The orchestrator MUST coerce `DONE_WITH_CONCERNS` to FAIL and route to remediation. | `behavioral` | `assert_semantic "SC-1" "Orchestrator receives DONE_WITH_CONCERNS result contract, coerces it to FAIL, and routes to remediation instead of treating it as valid completion"` | If coercion does not occur: verify coercion rule text is present in pipeline-executor.md; re-run behavioral test with corrected rule text | `assemble-work` RED sub-agent return gate | `.issues/1355/behavioral/` | U1 — coercion-rule-definition | Phase 1 | `red-green` | `standalone` | `coercion-core` | `assemble-work` Step 0 | `.opencode/tests/behaviors/coercion-done-with-concerns.sh` | Phase 1 |
| SC-2 | `000-critical-rules.md` `critical-rules-hard-fail` symbolic rule conditions include `DONE_WITH_CONCERNS`. The orchestrator MUST apply the updated symbolic rule when receiving `DONE_WITH_CONCERNS`. | `behavioral` | `assert_semantic "SC-2" "Orchestrator applies critical-rules-hard-fail when receiving DONE_WITH_CONCERNS — the symbolic rule fires and the pipeline halts with FAIL"` + `assert_stderr_pattern_present 'DONE_WITH_CONCERNS'` in `000-critical-rules.md` (secondary string corroboration) | If symbolic rule does not fire: verify DONE_WITH_CONCERNS is present in critical-rules-hard-fail conditions; re-run behavioral test | `assemble-work` RED sub-agent return gate | `.issues/1355/behavioral/` | U2 — symbolic-rule-coercion-gap | Phase 2 | `red-green` | `standalone` | `coercion-core` | `assemble-work` Step 0 | `.opencode/tests/behaviors/coercion-done-with-concerns.sh` | Phase 2 |
| SC-3 | `065-verification-honesty.md` §Hard Failure Discipline references `DONE_WITH_CONCERNS` as a coercion trigger. The orchestrator MUST apply coercion at the verification honesty gate. | `behavioral` | `assert_semantic "SC-3" "Orchestrator applies DONE_WITH_CONCERNS coercion at the verification honesty gate — the hard failure discipline fires when DONE_WITH_CONCERNS is received"` + `assert_stderr_pattern_present 'DONE_WITH_CONCERNS'` in `065-verification-honesty.md` (secondary string corroboration) | If coercion does not fire at verification honesty gate: verify DONE_WITH_CONCERNS reference exists in Hard Failure Discipline section; re-run behavioral test | `verification-before-completion` VbC gate | `.issues/1355/behavioral/` | U3 — verification-honesty-wiring | Phase 3 | `pre-commit` | `standalone` | `coercion-core` | `verification-before-completion` verify step | `.opencode/tests/behaviors/coercion-done-with-concerns.sh` | Phase 3 |
| SC-4 | `020-go-prohibitions.md` §1.1 Result Contract Frugality table does NOT list `DONE_WITH_CONCERNS` as a valid status. Valid statuses are `DONE`, `BLOCKED`, `OVERFLOW`. | `behavioral` | `assert_semantic "SC-4" "Orchestrator's result contract status table no longer accepts DONE_WITH_CONCERNS — when a sub-agent returns it, the orchestrator treats it as invalid status and coerces to FAIL"` + `assert_forbidden_pattern_absent 'DONE_WITH_CONCERNS'` in `020-go-prohibitions.md` §1.1 Result Contract Frugality table (secondary string corroboration) | If DONE_WITH_CONCERNS still present in table: remove it; re-run behavioral test | `assemble-work` RED sub-agent return gate | `.issues/1355/behavioral/` | U4 — result-contract-frugality-table | Phase 4 | `red-green` | `standalone` | `enum-cleanup` | `assemble-work` Step 0 | `.opencode/tests/behaviors/coercion-done-with-concerns.sh` | Phase 4 |
| SC-5 | `implementation-pipeline/SKILL.md` and `approval-gate/SKILL.md` status enums do NOT include `DONE_WITH_CONCERNS`. | `behavioral` | `assert_semantic "SC-5" "Orchestrator's SKILL.md status enums no longer include DONE_WITH_CONCERNS — the pipeline dispatcher rejects it as invalid"` + `assert_forbidden_pattern_absent 'DONE_WITH_CONCERNS'` in both SKILL.md files (secondary string corroboration) | If DONE_WITH_CONCERNS still present in either SKILL.md: remove it; re-run behavioral test | `assemble-work` RED sub-agent return gate | `.issues/1355/behavioral/` | U5 — skill-md-status-enum-cleanup | Phase 4 | `red-green` | `standalone` | `enum-cleanup` | `assemble-work` Step 0 | `.opencode/tests/behaviors/coercion-done-with-concerns.sh` | Phase 4 |
| SC-6 | `work-state-verification.md` treats `DONE_WITH_CONCERNS` as FAIL, not valid completion. | `behavioral` | `assert_semantic "SC-6" "Work-state-verification treats DONE_WITH_CONCERNS as FAIL — the verification gate rejects it and triggers remediation"` + `assert_forbidden_pattern_absent 'DONE_WITH_CONCERNS.*valid'` in `work-state-verification.md` (secondary string corroboration) | If work-state-verification still accepts DONE_WITH_CONCERNS: update to treat as FAIL; re-run behavioral test | `assemble-work` RED sub-agent return gate | `.issues/1355/behavioral/` | U6 — work-state-verification-update | Phase 4 | `red-green` | `standalone` | `enum-cleanup` | `assemble-work` Step 0 | `.opencode/tests/behaviors/coercion-done-with-concerns.sh` | Phase 4 |
| SC-7 | `screen-issue-gate2.md` status enum does NOT include `DONE_WITH_CONCERNS`. | `behavioral` | `assert_semantic "SC-7" "Screen-issue-gate2 no longer accepts DONE_WITH_CONCERNS — the screening gate rejects it as invalid status"` + `assert_forbidden_pattern_absent 'DONE_WITH_CONCERNS'` in `screen-issue-gate2.md` (secondary string corroboration) | If DONE_WITH_CONCERNS still present in screen-issue-gate2.md: remove it; re-run behavioral test | `approval-gate` screen step | `.issues/1355/behavioral/` | U7 — screen-issue-gate2-update | Phase 4 | `red-green` | `standalone` | `enum-cleanup` | `approval-gate` screen step | `.opencode/tests/behaviors/coercion-done-with-concerns.sh` | Phase 4 |
| SC-8 | `writing-plans/tasks/revisit.md` line 25 and `revisit-output-template.yaml` PRESERVE `DONE_WITH_CONCERNS` unchanged. The revisit workflow uses it for partial resolution signaling — a distinct semantic from completion. | `behavioral` | `assert_semantic "SC-8" "Writing-plans revisit workflow preserves DONE_WITH_CONCERNS for partial resolution — the revisit sub-agent can still return it, and the revisit pipeline treats it as partial-resolution (not completion)"` + `assert_required_pattern_present 'DONE_WITH_CONCERNS'` in `revisit.md` (secondary string corroboration) | If DONE_WITH_CONCERNS was accidentally removed from revisit.md: restore it; re-run behavioral test | `writing-plans` revisit step | `.issues/1355/behavioral/` | U8 — writing-plans-revisit-preservation | Phase 5 | `red-green` | `standalone` | `preservation` | `writing-plans` revisit step | `.opencode/tests/behaviors/coercion-done-with-concerns.sh` | Phase 5 |
| SC-9 | A behavioral enforcement test exists in `.opencode/tests/behaviors/` that uses `assert_semantic` (clean-room AI inspector) to verify the orchestrator coerces `DONE_WITH_CONCERNS` to FAIL and routes to remediation. The test MUST be RED (fail) before implementation and GREEN (pass) after. | `behavioral` | `bash .opencode/tests/behaviors/coercion-done-with-concerns.sh` — `assert_semantic "SC-9" "Orchestrator receives DONE_WITH_CONCERNS from a sub-agent, coerces it to FAIL, and routes to remediation — the pipeline does not treat it as valid completion"` | If behavioral test fails after implementation: diagnose root cause (coercion rule not firing, symbolic rule mismatch, enum not cleaned); fix and re-run | `assemble-work` RED sub-agent return gate | `.issues/1355/behavioral/` | U9 — behavioral-enforcement-tests | Phase 6 | `red-green` | `standalone` | `coercion-core` | `assemble-work` Step 0 | `.opencode/tests/behaviors/coercion-done-with-concerns.sh` | Phase 6 |

### Semantic Intent Annotations

- **SC-1:** The coercion rule is bright-line — no gray zone between DONE and FAIL. A status of `DONE_WITH_CONCERNS` means the sub-agent completed work but identified problems. Those problems are defects, not completions. Coercing to FAIL ensures defects are remediated before proceeding.
- **SC-2:** The symbolic rule layer is the enforcement backbone. Without it in the conditions, the rule exists in prose but not in the machine-parseable enforcement layer that `session-enforcement.ts` checks.
- **SC-3:** Verification honesty is the gate that catches soft-passing. Wiring `DONE_WITH_CONCERNS` into this gate ensures the coercion fires at the point where soft-passing would otherwise occur.
- **SC-4:** The result contract table defines what statuses the pipeline accepts. Removing `DONE_WITH_CONCERNS` from the table means the pipeline no longer recognizes it as valid — any sub-agent returning it gets coerced.
- **SC-5:** SKILL.md status enums are the canonical source for sub-agents. If they list `DONE_WITH_CONCERNS`, sub-agents will use it. Removing it prevents sub-agents from producing it in the first place.
- **SC-6:** Work-state-verification is the gate that checks whether a pipeline step completed. Treating `DONE_WITH_CONCERNS` as FAIL means the step is not marked complete until defects are resolved.
- **SC-7:** Screen-issue-gate2 is the approval-gate screening step. Removing `DONE_WITH_CONCERNS` from its enum prevents screened issues from being marked as valid with caveats.
- **SC-8:** Revisit.md's `DONE_WITH_CONCERNS` is a different semantic — it signals "I resolved some claims but not all." This is partial resolution, not completion. Preserving it is intentional.
- **SC-9:** The behavioral enforcement test is the PRIMARY gate. Without it, the coercion rule exists in text but is not verified in behavior. Bug #1217 proved that text-presence verification alone is insufficient.

## Edge Cases

| Case | Handling |
|------|----------|
| Sub-agent returns `DONE` with empty `caveat_summary` | Valid completion — proceed normally |
| Sub-agent returns `DONE` with non-empty `caveat_summary` | Coerce to FAIL — caveats are defects |
| Sub-agent returns `BLOCKED` | Already handled by existing hard-fail gate — no change |
| Sub-agent returns `OVERFLOW` | Already handled by existing overflow gate — no change |
| Sub-agent returns unknown status (not in enum) | Coerce to FAIL — unknown status is invalid |
| `revisit.md` sub-agent returns `DONE_WITH_CONCERNS` | Valid — partial resolution signaling, not completion |
| Behavioral enforcement test model unavailable | Apply remediation-first protocol: alternative model, timeout increase, infrastructure check. Only FAIL after 2+ remediation attempts with tool-call evidence. |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Coercion is bright-line — no gray zone between DONE and FAIL | A soft-pass path (DONE_WITH_CONCERNS treated as valid) undermines the hard-fail gate. Every non-DONE status is a defect. | MUST | SC-1, SC-2, SC-3 |
| DEC-2 | `revisit.md` preservation is intentional | `DONE_WITH_CONCERNS` in revisit.md signals partial resolution (some claims resolved, some not) — a distinct semantic from completion that belongs to a different pipeline stage | MUST | SC-8 |
| DEC-3 | Behavioral enforcement test uses `assert_semantic` (clean-room AI inspector) | The coercion decision is an agent action, not a text pattern. grep on agent output prose is EVIDENCE_TYPE_MISMATCH for behavioral SCs per `080-code-standards.md` §Rule 5. | MUST | SC-9 |
| DEC-4 | `caveat_summary` non-empty on DONE → FAIL | A sub-agent that returns DONE but includes caveats is signaling defects it found but did not fix. Those defects must be remediated before the pipeline proceeds. | MUST | SC-1 |

## Risk Traceability Table

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | `revisit.md` DONE_WITH_CONCERNS accidentally removed during enum cleanup | Medium | High — breaks partial resolution signaling in writing-plans revisit workflow | Explicit preservation check in SC-8; grep assertion confirms presence | SC-8 |
| RISK-2 | Behavioral enforcement test model unavailable | Low | Medium — cannot verify coercion behavior | Remediation-first protocol: alternative model, timeout increase, infrastructure check | SC-9 |
| RISK-3 | Sub-agents continue to return DONE_WITH_CONCERNS after enum removal (stale training data) | Medium | Medium — coercion rule catches it, but sub-agents waste context producing invalid status | Coercion rule in pipeline-executor.md catches any DONE_WITH_CONCERNS regardless of source | SC-1 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan (`.issues/1355/plan.md`) | MUST | Revise to match revised spec |
| SC coverage summary (`.issues/1355/sc-summary.yaml`) | MUST | Regenerate from revised SC table |
| Verification consistency contract (`.issues/1355/verification-consistency-contract.yaml`) | MUST | Regenerate with updated SC entries |
| Behavioral enforcement test (`.opencode/tests/behaviors/coercion-done-with-concerns.sh`) | SHOULD | Review for continued validity against revised SCs |
| Risk traceability table | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
|----------------|------------------|------------------------|-------------|
| multi-phase | 6 | One sub-issue per phase | stacked PRs per phase |

## Explicit Non-Goals

- **Sub-agent output format changes** — This spec addresses the coercion gap in the orchestrator's handling of result contracts, not the format sub-agents use to produce them.
- **New result contract statuses** — No new status values are introduced. The fix removes an invalid status, not adds new ones.
- **revisit.md semantic change** — The revisit workflow's use of `DONE_WITH_CONCERNS` is preserved unchanged. This spec does not alter the revisit pipeline.
- **Overflow handling changes** — The `OVERFLOW` status and its routing rules are unchanged.

## Regression Invariants

1. Existing `DONE` status handling MUST continue to work unchanged — sub-agents returning clean DONE proceed normally.
2. Existing `BLOCKED` status handling MUST continue to work unchanged — the hard-fail gate fires as before.
3. Existing `OVERFLOW` status handling MUST continue to work unchanged.
4. `writing-plans/tasks/revisit.md` MUST continue to return `DONE_WITH_CONCERNS` for partial resolution — its behavior is unchanged.
5. All existing behavioral enforcement tests MUST continue to pass — no regressions introduced.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `glob(pattern=".opencode/skills/implementation-pipeline/tasks/pipeline-executor.md")` | Verify pipeline-executor.md exists and contains DONE_WITH_CONCERNS reference |
| Direct source search | `grep(pattern="DONE_WITH_CONCERNS", path=".opencode/")` | Identify all files referencing DONE_WITH_CONCERNS |
| Direct source search | `grep(pattern="critical-rules-hard-fail", path=".opencode/guidelines/")` | Verify symbolic rule structure in 000-critical-rules.md |
| Direct source search | `grep(pattern="Hard Failure Discipline", path=".opencode/guidelines/065-verification-honesty.md")` | Verify Hard Failure Discipline section exists |
| Direct source search | `grep(pattern="Result Contract Frugality", path=".opencode/guidelines/020-go-prohibitions.md")` | Verify Result Contract Frugality section exists |
| Direct source search | `read(filePath=".opencode/skills/implementation-pipeline/SKILL.md", offset=65, limit=10)` | Verify line 69 DONE_WITH_CONCERNS reference |
| Direct source search | `read(filePath=".opencode/skills/approval-gate/SKILL.md", offset=6, limit=10)` | Verify line 10 DONE_WITH_CONCERNS reference |
| Direct source search | `read(filePath=".opencode/skills/implementation-pipeline/enforcement/work-state-verification.md", offset=7, limit=10)` | Verify line 11 DONE_WITH_CONCERNS acceptance |
| Direct source search | `read(filePath=".opencode/skills/approval-gate/tasks/screen/screen-issue-gate2.md", offset=178, limit=10)` | Verify line 182 DONE_WITH_CONCERNS in status enum |
| Direct source search | `read(filePath=".opencode/skills/writing-plans/tasks/revisit.md", offset=21, limit=10)` | Verify line 25 DONE_WITH_CONCERNS preservation |
| Direct source search | `glob(pattern=".opencode/skills/writing-plans/contracts/revisit-output-template.yaml")` | Verify revisit-output-template.yaml exists |

After this spec is approved, invoke `writing-plans` to create `.issues/1355/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (deepseek-v4-pro)
