## Problem

The current TDD pipeline dispatches RED (test creation) and GREEN (implementation) sub-agents, then immediately routes their output to adversarial auditors (dual-model cross-family). The auditors consistently find that submissions are **partially complete** — missing test assertions for documented edge cases, stubbed implementation paths, incomplete spec-SC coverage — rather than finding deep correctness defects. This is a concern-separation failure: the adversarial audit cognitive mode ("find hidden defects and contradictions") is polluted by surface-level completeness checking ("does everything from the spec exist").

## Success Criteria

- **SC-1**: After each RED sub-agent completes, a non-adversarial completeness-check sub-agent is dispatched. The checker inspects the deliverable against spec SCs and returns a structured result with `completeness_result: PASS | FAIL` and `findings[]`. The orchestrator routes based on its own reading of the findings.
- **SC-2**: After each GREEN sub-agent completes, the same pattern applies — completeness check → findings → orchestrator routes.
- **SC-3**: The checker has **read-only access**. It does NOT remediate gaps or advise routing. It inspects the deliverable against spec SCs and produces a structured findings report. Remediation is the sub-agent's job; routing is the orchestrator's job.
- **SC-4**: The checker runs once per handoff (no internal loop). The loop is at the orchestrator level: re-task RED/GREEN with findings as `prior_context`, re-check, repeat. No attempt-count limit on the orchestrator loop.
- **SC-5**: The checker receives only the spec SCs, the deliverable artifact, and the audit-readiness checklist — NOT the original sub-agent's context, reasoning, or prior attempts (clean-room).
- **SC-6**: Existing pipeline files are updated to reflect the new gate. Minimal word-count increase.
- **SC-7**: The checker's `completeness_result` is an explicit `PASS | FAIL` — never an empty or absent result. An absent result is treated as a sub-agent failure by the orchestrator's existing abnormal termination handler.

## Affected Files

| File | Change |
|------|--------|
| `divide-and-conquer/tasks/assemble-work.md` | Add Step 3.x completeness gate after each sub-agent result, with orchestrator routing based on findings |
| `divide-and-conquer/SKILL.md` | Add symbolic rule for completeness gate |
| `test-driven-development/SKILL.md` | Optionally add checkpoint phase between RED/GREEN and audit |

## Design Decisions (Researched)

### Q1: New standalone skill or reuse existing?

**Decision: New standalone skill named `completeness-gate`.**

Analysis of the full skill deck found no existing skill with the required pattern:
- `verification-before-completion` — halts on failure (no findings report for orchestrator to route on), internally calls adversarial audit (circular dependency). Signal is `completion_ready`, pipeline position is end-of-pipeline.
- `finishing-a-development-branch` — branch readiness (lint/test/push), not SC completeness against spec.
- `adversarial-audit` — adversarial by design. Opposite of what's needed.
- `divide-and-conquer` — orchestrator that dispatches but doesn't check content.

The `completeness-gate` name mirrors the `approval-gate` convention (pipeline boundary skill), is short enough for INDEX.md, and is self-documenting.

### Q2: Standalone skill or task under `divide-and-conquer/`?

**Decision: Standalone skill.**

- All pipeline gate skills are standalone (`verification-before-completion`, `finishing-a-development-branch`, `adversarial-audit`, `approval-gate`, `requesting-code-review`).
- `divide-and-conquer/tasks/` serves orchestration mechanics (assess, decompose, dispatch, merge, context-passing). Not gate logic.
- `assemble-work.md` is at 3,649 words (over 3,000 max per `091-incremental-build.md`).
- The checker has its own identity: unique entry/exit criteria, clean-room sub-agent dispatch, `completeness_result` signal, structured findings report.

## Completeness Check Contract

### Input (what the checker receives)

```yaml
check_type: "red" | "green"
spec_success_criteria: [list of SCs for this phase]
deliverable: "<artifact path>"
spec: "<full spec body>"
audit_readiness_criteria:
  - All spec SCs for this phase are exercised (tests) or implemented (code)
  - No stubs, TODOs, or placeholder paths remain
  - Error paths from spec are covered
  - No scope creep beyond spec
authorization_scope: <scope_value>
halt_at: <pipeline_stage>
pr_strategy: stacked | individual | none
pipeline_phase: <current_phase_name>
```

### Output (checker result)

```yaml
status: DONE | BLOCKED
completeness_result: PASS | FAIL
summary: "<prose summary of what was found — affirmatory on PASS, enumerative on FAIL>"
findings:
  remediable:
    - {location: "test_foo.py:42", description: "Missing assertion for SC-3 edge case"}
    - {location: "impl.py:88", description: "Error path implementation is a stub"}
  structural:
    - {description: "SC-4 has no test — would require new plan item"}
    - {description: "Implementation for SC-7 contradicts spec constraint X"}
```

**`findings` is populated on FAIL only.** On PASS, `findings` is an empty list and `summary` is affirmatory (e.g., "All 5 spec SCs covered. No stubs, no missing assertions, no contradictions.").

**An absent or empty `completeness_result`** is not a PASS — it is a sub-agent failure caught by the orchestrator's existing abnormal termination handler in `assemble-work.md` Step 3.5.

### Orchestrator routing (orchestrator's responsibility — NOT dictated by checker)

| If `completeness_result` is... | And findings are... | Orchestrator routes |
|---|---|---|
| PASS | `[]` (empty) | Dispatch adversarial auditor (proceed) |
| FAIL | Only `remediable` items | Re-task RED/GREEN sub-agent with findings as `prior_context` |
| FAIL | Any `structural` items | Route to `writing-plans` or `spec-creation` for revision |

The orchestrator makes the routing decision. The checker only reports what it found.

### Loop behavior

- The checker runs once per handoff (no internal loop)
- The orchestrator handles the loop via its existing re-task mechanism (assemble-work.md Step 3.5)
- Re-task loop: RED/GREEN re-tasked with findings → re-check → re-task again if not ready
- No attempt-count limit on the re-task loop (existing mechanism, no false-PASS incentive)
- Structural findings exit the loop entirely — orchestrator routes to plan/spec revision

## Relationship to Existing Pipeline

```
Current:     RED → adversarial-audit → GREEN → adversarial-audit

Proposed:    RED → completeness-gate → findings → orchestrator routes:
               ├─ restart RED (remediable only) ────→ completeness-gate (loop)
               ├─ proceed to audit (PASS) ──────────→ adversarial-audit
               └─ escalate to plan/spec (structural) → writing-plans / spec-creation (exit loop)

             GREEN → completeness-gate → findings → orchestrator routes:
               ├─ restart GREEN (remediable only) ───→ completeness-gate (loop)
               ├─ proceed to audit (PASS) ──────────→ adversarial-audit
               └─ escalate to plan/spec (structural) → writing-plans / spec-creation (exit loop)
```

The adversarial audit remains unchanged — dual-family cross-validation. The completeness gate is a pre-gate that ensures the auditor's attention is spent on correctness defects, not surface-level completeness.

## Status

```
STATUS: DRAFT
AUTHOR: AI co-authored with deepseek-v4-flash-free
```

## Changelog

- 2026-05-20: Initial draft
- 2026-05-20: Unlimted remediation loop — removed 3-attempt cap
- 2026-05-20: Design decisions resolved — new standalone skill `completeness-gate`
- 2026-05-20: Removed checker write access — checker is read-only, reports findings only
- 2026-05-20: Removed routing recommendations from checker output — orchestrator routes, not checker
- 2026-05-20: `completeness_result: PASS | FAIL` replaces boolean `ready_for_audit` + empty-list ambiguity. Empty result is sub-agent failure, not PASS.