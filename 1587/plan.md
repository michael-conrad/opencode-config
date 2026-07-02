# Plan: #1587 — Orchestrator read-then-inline pattern enforcement

## Goal

Add three string-level text additions to two SKILL.md files to enforce canonical dispatch and prevent the orchestrator read-then-inline pattern.

## Architecture

No architecture changes. All three changes are text additions to existing SKILL.md files — no behavioral tests, no new files, no structural modifications.

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/implementation-pipeline/SKILL.md` | Add pipeline re-priming enforcement block after Sub-Agent Entry Criteria (SC-1) |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Append `dispatch-gate-rejection.sh` reference to Sub-Agent Entry Criteria (SC-2) |
| `.opencode/skills/approval-gate/SKILL.md` | Add "orchestrator MUST NOT read task file content" to Orchestrator Entry Criteria (SC-3) |

## Phase Table

| Phase | SCs | Description |
|-------|-----|-------------|
| 1 | SC-1, SC-2, SC-3 | Apply all three text additions to SKILL.md files |

### Phase 1 Details

**SC-1**: Insert a pipeline re-priming enforcement block between the Sub-Agent Entry Criteria section (ends at line 216) and the Orchestrator Entry Criteria section (starts at line 218) in `implementation-pipeline/SKILL.md`. The block must state: at every pipeline stage transition (pre-work → assemble-work → verification-before-completion → finishing-checklist → review-prep), the orchestrator re-encounters an enforcement block restating procedural discipline: sub-agents execute, orchestrators route, no inline work.

**SC-2**: Append a line to the Sub-Agent Entry Criteria in `implementation-pipeline/SKILL.md` (after line 216) referencing `dispatch-gate-rejection.sh` as the behavioral enforcement test for the `PRELOADED_CONTEXT_REJECTED` protocol.

**SC-3**: Add the exact phrase "orchestrator MUST NOT read task file content" to the Orchestrator Entry Criteria block in `approval-gate/SKILL.md` (around lines 131-135).

## Exit Criteria

| ID | Verification |
|----|-------------|
| SC-1 | `grep "pipeline re-priming" .opencode/skills/implementation-pipeline/SKILL.md` returns match |
| SC-2 | `grep "dispatch-gate-rejection" .opencode/skills/implementation-pipeline/SKILL.md` returns match |
| SC-3 | `grep "orchestrator MUST NOT read task file content" .opencode/skills/approval-gate/SKILL.md` returns match |
