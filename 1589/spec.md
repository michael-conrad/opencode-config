# [SPEC] Pre-Response Gate re-entry for gap-fill cascade — skill dispatch on sub-decisions

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | The Pre-Response Gate procedure fires once per user message. When gap-fill cascade auto-creates a spec or plan, the orchestrator never re-evaluates the skill deck — it writes inline instead of dispatching to `spec-creation` or `writing-plans`. |
| Root Cause / Motivation | The Pre-Response Gate has no re-entry mechanism. Skills are evaluated against the user's message only; sub-decisions from matched skills are not re-evaluated against the skill deck. |
| Approach Chosen | Two changes: (1) add re-entry condition to Pre-Response Gate in AGENTS.md, (2) add explicit `dispatch_next` fields to approval-gate gap-fill cascade table. |
| Alternatives Considered & Why Discarded | Single monolithic gate that evaluates all possible sub-decisions upfront — rejected because it couples skill dispatch logic across unrelated skills. |
| Key Design Decisions | Re-entry is bounded (max 3 per message) to prevent infinite loops. `dispatch_next` is explicit per scope, not inferred. |

## Objective

Ensure that when the gap-fill cascade auto-creates a spec or plan, the orchestrator dispatches to the correct skill (`spec-creation`, `writing-plans`) instead of writing inline. This prevents the orchestrator inline-work bypass that currently occurs when the Pre-Response Gate does not re-evaluate after a sub-decision.

## Problem

The Pre-Response Gate procedure (AGENTS.md) fires once per user message. When the gap-fill cascade auto-creates a spec or plan, the orchestrator treats it as an implementation intent rather than a dispatch trigger. The skill deck is never re-evaluated mid-response, so `spec-creation` and `writing-plans` are never loaded — the orchestrator writes inline instead.

## Root Cause

The Pre-Response Gate procedure has no re-entry mechanism. It evaluates skills against the user's message, executes the matched skill, then proceeds. If the matched skill produces a sub-decision (e.g., "auto-create spec"), there is no gate to re-evaluate the skill deck for that sub-decision.

## Fix Approach — Two Changes

### Change 1: Pre-Response Gate re-entry trigger

Add a re-entry condition to the Pre-Response Gate procedure in AGENTS.md:

> **Re-entry condition:** After executing a skill that produces a sub-decision requiring further skill dispatch (gap-fill cascade, auto-create, auto-approve), the orchestrator MUST re-evaluate the skill deck against the sub-decision's intent before proceeding. The re-entry uses the same procedure as the initial gate: evaluate ALL skill descriptions, match triggers, load matched skill, dispatch.

The re-entry trigger is: the previous skill's output contains a `dispatch_next` field or the orchestrator's own reasoning identifies a new intent that matches a skill description.

### Change 2: Gap-fill cascade explicitly names dispatch targets

Update the approval-gate gap-fill cascade to include explicit `dispatch_next` fields:

| Scope | Gap-Fill | Dispatch Next |
|-------|----------|---------------|
| `for_plan` | auto-create spec | `skill({name: "spec-creation"})` → task write |
| `for_implementation` | auto-create spec+plan | `spec-creation` → `writing-plans` |
| `for_pr` | auto-create spec+plan+PR | `spec-creation` → `writing-plans` → `git-workflow` |

The orchestrator reads `dispatch_next` and re-enters the Pre-Response Gate with that skill name as the trigger.

## Files Affected

- `.opencode/AGENTS.md` — Pre-Response Gate procedure (add re-entry condition)
- `.opencode/skills/approval-gate/tasks/auto-dispatch.md` — add `dispatch_next` fields to gap-fill cascade
- `.opencode/skills/approval-gate/SKILL.md` — Authorization Scope Model table (add Dispatch Next column)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Pre-Response Gate procedure has re-entry condition documented | `string` | grep for "Re-entry condition" in AGENTS.md |
| SC-2 | Gap-fill cascade table has `dispatch_next` column with explicit skill names | `string` | grep for "dispatch_next" in approval-gate auto-dispatch.md |
| SC-3 | Behavioral test: orchestrator loads `spec-creation` after gap-fill cascade triggers | `behavioral` | `opencode-cli run` with "approved for plan" → stderr shows `skill({name: "spec-creation"})` |

## Edge Cases

- **Re-entry loop:** If `dispatch_next` cycles back to the same skill, the orchestrator MUST detect the cycle and HALT. Mitigation: single-pass dispatch tracking (max 3 re-entries per message).
- **No `dispatch_next` field:** If a skill produces a sub-decision but no `dispatch_next` field, the orchestrator MUST NOT re-enter the gate. The sub-decision is treated as an internal action of the matched skill.
- **Multiple `dispatch_next` values:** If a skill produces multiple `dispatch_next` values, the orchestrator MUST process them sequentially in order, re-entering the gate for each.

## Dependencies

- #1588 — Orchestrator inline-work bypass (separate concern: dispatch routing fixes)

## Out of Scope

- Changes to #1588's scope (SKILL.md inline instructions, write.md sub-agent markers, step status output)
- Changes to individual skill dispatch tables (covered by #1588)

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Re-entry bounded to max 3 per message | Prevents infinite loops while allowing multi-step cascades | MUST | SC-1 |
| DEC-2 | `dispatch_next` is explicit per scope | Avoids inference errors; each scope names its exact dispatch chain | MUST | SC-2 |
| DEC-3 | Re-entry uses same procedure as initial gate | Consistency; no special-case logic for re-entry | MUST | SC-1 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Re-entry infinite loop | Low | High | Bounded to max 3 re-entries per message | SC-1 |
| RISK-2 | Orchestrator context growth | Low | Medium | Re-entry bounded; skill deck evaluation is lightweight | SC-1 |
| RISK-3 | `dispatch_next` not implemented in gap-fill | Medium | High | Explicit table with verified grep check | SC-2 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ---------------- | ---------------------- | ----------- |
| multi-phase | 3 | One sub-issue per phase | stacked PRs per phase |

## Explicit Non-Goals

- **Changes to #1588's scope** — SKILL.md inline instructions, write.md sub-agent markers, step status output are covered by #1588
- **Changes to individual skill dispatch tables** — covered by #1588
- **Re-architecting the Pre-Response Gate** — only adding re-entry, not redesigning

## Regression Invariants

- Existing Pre-Response Gate behavior for single-skill messages MUST NOT change
- Existing gap-fill cascade behavior (auto-create spec/plan) MUST continue to work
- Existing authorization scope model MUST remain unchanged

## Cross-Cutting SCs

SC-1 and SC-2 are cross-cutting — verified once, apply to all phases.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Local docs | `.opencode/AGENTS.md` | Understand Pre-Response Gate procedure |
| Local docs | `.opencode/skills/approval-gate/SKILL.md` | Understand Authorization Scope Model |
| Local docs | `.opencode/skills/approval-gate/tasks/auto-dispatch.md` | Understand gap-fill cascade |
| Direct source search | `grep -r "Pre-Response Gate" .opencode/` | Identify all gate references |
| Direct source search | `grep -r "gap-fill" .opencode/` | Identify all gap-fill references |

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.issues/1589/plan.md` before implementation begins.

Co-authored with AI: OpenCode (deepseek-v4-flash)
