# [SPEC] Specs and plans are NOT tracking documents — remove STATUS tracking from AGENTS.md files

STATUS: draft

---

## Intent

Clarify in both `/AGENTS.md` and `.opencode/AGENTS.md` that specs and plans are specification documents, not tracking documents. They define what is required — implemented or not. Any recommendation to track implementation status (completed, pending, in progress, STATUS markers) in specs or plans is wrong and must be removed.

## Problem Statement

The current AGENTS.md files and the `.opencode/guidelines/141-planning-status-tracking.md` guideline treat specs and plans as progress-tracking artifacts. They recommend STATUS fields (`STATUS: in progress — Auth, Step 1`), visual status markers (`☐`/`↻`/`☑`/`☒`), and label state transitions that track implementation progress within the spec itself.

This is a category error. A spec specifies what is required. A plan specifies how to implement it. Neither is a burndown chart or a project tracker. Tracking implementation status in the spec conflates specification with progress reporting — it makes the spec a moving target that changes meaning as work progresses, rather than a fixed contract of what must be delivered.

## Approach

1. Add a section to both `/AGENTS.md` and `.opencode/AGENTS.md` stating clearly that specs and plans are NOT tracking documents
2. The section must state: specs define what is required (implemented or not); plans define how to implement it (implemented or not). Any STATUS field, completion marker, pending indicator, or progress tracker in a spec or plan is a defect.
3. Cross-reference the removal of `.opencode/guidelines/141-planning-status-tracking.md` (which must be deleted or gutted of all status-tracking content)
4. Do NOT modify the AGENTS.md files directly in this spec — this spec only defines the requirement. Implementation is a separate step.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `/AGENTS.md` contains a section stating specs and plans are NOT tracking documents | `string` | `grep -c "NOT tracking" /AGENTS.md` must output `1` |
| SC-2 | `.opencode/AGENTS.md` contains a section stating specs and plans are NOT tracking documents | `string` | `grep -c "NOT tracking" .opencode/AGENTS.md` must output `1` |
| SC-3 | `.opencode/guidelines/141-planning-status-tracking.md` is either deleted or has all status-tracking content (STATUS fields, status markers, label state transitions) removed | `string` | `grep -c "STATUS" .opencode/guidelines/141-planning-status-tracking.md` must output `0` (or file does not exist) |
| SC-4 | The section in both AGENTS.md files explicitly states that STATUS fields, completion markers, pending indicators, and progress trackers in specs/plans are defects | `string` | `grep -c "defect" /AGENTS.md` must output `1` AND `grep -c "defect" .opencode/AGENTS.md` must output `1` |

## Affected Files

- `/AGENTS.md` — root repo AGENTS.md
- `.opencode/AGENTS.md` — submodule AGENTS.md
- `.opencode/guidelines/141-planning-status-tracking.md` — must be deleted or gutted of status-tracking content

## Out of Scope

- Changes to skill task files that reference STATUS tracking (those are separate specs)
- Changes to the `writing-plans` or `spec-creation` skills
- Implementation of the AGENTS.md changes — this spec only defines the requirement
