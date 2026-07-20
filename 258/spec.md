## Problem

The writing-plans skill contains a structural contradiction between two sections that describe how tasks are executed:

1. **"Programmatic Invocation" section** (SKILL.md lines 44-51) instructs the orchestrator to read task files and execute steps inline
2. **"Invocation" section with DISPATCH_GATE** (SKILL.md lines 75-86) instructs sub-agent dispatch via `task()`

Additionally, `tasks/create.md` line 5 (Purpose) says "orchestrator reads this task file and executes the 21-step pipeline" — also stale inline language.

This contradicts:
- `critical-rules-048` (Skill Pre-Read + Inline Execution — reading task files and executing inline is a violation)
- `critical-rules-dispatch-gate-canonical` (must use canonical dispatch string)
- Every other skill in the repo (adversarial-audit, spec-creation, playwright-cli all say "Inline execution is FORBIDDEN")

## Investigation

Research confirmed:
- Writing-plans is the **only** skill with this contradiction
- The "Programmatic Invocation" section is stale — predates the DISPATCH_GATE protocol
- Sub-agent task files dispatched from `create.md` are all leaf nodes (no nested `task()` calls)
- `write.md` has stale `(**sub-agent**)` markers on sub-steps but no actual `task()` calls — labeling issue, not nested dispatch

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | "Programmatic Invocation" section deleted from SKILL.md | `string` | grep for "Programmatic Invocation" in SKILL.md — must return no match |
| SC-2 | tasks/create.md Purpose section updated to describe sub-agent dispatch | `string` | grep for "orchestrator reads this task file and executes" in create.md — must return no match |
| SC-3 | No stale inline-execution language remains in writing-plans SKILL.md or task files | `string` | grep for "executes steps inline" in `.opencode/skills/writing-plans/` — must return no match |
| SC-4 | DISPATCH_GATE section remains intact and unchanged | `string` | grep for "DISPATCH GATE" in SKILL.md — must return match with correct content |
| SC-5 | Skill card audit passes for writing-plans | `behavioral` | Run `skill-creator --task validate` on writing-plans — must return PASS |

## Files Affected

- `.opencode/skills/writing-plans/SKILL.md` — Delete "Programmatic Invocation" section (lines 44-51)
- `.opencode/skills/writing-plans/tasks/create.md` — Update Purpose section (line 5)

## Implementation Plan

### Phase 1: Fix SKILL.md
1. Delete the "Programmatic Invocation" section (lines 44-51)
2. Verify DISPATCH_GATE section remains intact

### Phase 2: Fix tasks/create.md
1. Update Purpose section line 5 from "orchestrator reads this task file and executes the 21-step pipeline" to "orchestrator dispatches the 21-step pipeline to a sub-agent"

### Phase 3: Verify
1. Run grep checks for stale inline language
2. Run `skill-creator --task validate` on writing-plans

## Risks

- Low risk — removing a stale section that contradicts the active DISPATCH_GATE protocol
- No behavioral change expected — agents should already be following DISPATCH_GATE

## Change Control

- **Status**: DRAFT
- **Version**: 1
- **Created**: 2026-07-07
