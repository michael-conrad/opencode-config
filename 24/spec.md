# SPEC: Paper Artifact Maintenance Mandate — Sync Implementation Progress with Paper

## Problem

The `docs/unix-philosophy-skilldeck/` directory contains the paper "Do One Thing Well" and supporting artifacts:

| Artifact | Purpose |
|----------|---------|
| `unix-philosophy-skilldeck.tex` | The paper — §11 Implementation Progress tracks issue states |
| `plan/remediation-plan.md` | Ordered dependency map of steps |
| `tracking/issue-restructure-plan.md` | Triage of open issues to paper gaps |
| `experiments/experiment-log.md` | Record of executed steps (currently 0 entries) |

These artifacts drift from implementation reality because no structural mandate requires updating them. The paper's progress section became stale because:

1. No guideline tells the agent to update paper artifacts when completing paper-referenced work
2. No verification gate checks paper artifact currency at PR or completion boundaries
3. The agent treats paper-as-documentation (immutable) rather than paper-as-tracking (must reflect current state)

**Evidence:** The paper's §11 was updated May 1 only after explicit developer direction following multiple rounds of correction. The remediation plan and issue tracker were similarly updated only when directed. In the absence of direction, paper artifacts go stale within one implementation cycle.

## Root Cause

Paper artifacts are treated as documentation (write once, stable), but the progress section and remediation plan are tracking artifacts (must reflect current state). No directive exists requiring their maintenance, and no verification gate checks them.

## Fix Approach

Add a section to `opencode-config/AGENTS.md` (the repo-specific agent file) documenting the paper artifact maintenance mandate. This is the correct location because:

- Paper artifacts live in `opencode-config/`, not `.opencode/`
- `AGENTS.md` is already loaded as an instruction source per `opencode.jsonc`
- It avoids polluting the submodule's skill deck with parent-repo-specific concerns

### Section Content

- Trigger table: when each artifact must be updated (issue state changes, gap discoveries, step executions)
- Historical preservation rule: additive only, never remove/overwrite
- Gate integration: checked at `verification-before-completion` when completed work references a paper gap

## Success Criteria

| ID | Criterion |
|----|-----------|
| SC-1 | `AGENTS.md` contains a "Paper Artifact Maintenance" section with trigger table |
| SC-2 | Section mandates additive-only updates — never remove historical entries |
| SC-3 | Section references `verification-before-completion` gate integration |
| SC-4 | Behavioral enforcement test: agent completing a paper-referenced implementation updates paper progress without being prompted |

## Affected Files

- `AGENTS.md` — Add Paper Artifact Maintenance section

## Out of Scope

- Changing the paper's own content (that's what the maintenance mandate produces, not what this spec changes)
- Adding verification-before-completion task changes (gate integration is a procedural reference, not a task file edit)
- Creating new skills or tools

## Relationship to Existing Issues

- **#274, #276, #294, #295, #296** — These are the first issues this maintenance mandate would apply to. Once implemented, the paper must reflect their completion.
- **#91** — Same class: unverified state treated as accurate because no structural gate flagged the drift.

## Revision Notes

- **v1.0** — Initial creation from May 1 paper drift discovery

Co-authored with AI: OpenCode (deepseek-v4-pro)