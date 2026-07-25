---
title: "Fix: Authorization Workflow — Record Session Authorization Before Verifying"
created: 2026-07-25
license: MIT
provenance: AI-generated
issue: 1970
phase: 1
phase_name: Authorization Workflow Fix
authors:
  - OpenCode (deepseek-v4-flash)
---

**CREATED:** 2026-07-25
**PHASE:** 1 of 1 — Authorization Workflow Fix

# Fix: Authorization Workflow — Record Session Authorization Before Verifying

## Objective

Fix the `approval-gate-scope` authorization workflow so that session authorization (given in chat) is recorded into persistent issue state (`.issues/{N}/comments.yaml`, `spec.md` frontmatter, `issue.yaml` labels) BEFORE the workflow verifies that authorization exists. This eliminates the circular dependency where the workflow checks for recorded authorization that hasn't been written yet.

## Background

The current `verify-authorization` workflow in `approval-gate-scope` has a structural design defect:

1. **Step 0.5 (scope-auto-resolve):** Correctly parses session authorization from chat — resolves `for_implementation`, `for_pr`, etc. ✅
2. **Step 1 (verify-explicit-authorization):** Reads issue comments / `comments.yaml` for a pre-existing "approved"/"go" record — finds nothing because the authorization was just given in the chat session, not yet recorded ❌
3. **Step 3 (apply-label):** Would apply the label — but this runs AFTER verification, and verification already failed because the label wasn't there

**Result:** The agent is authorized (you said "approved" in chat) but the workflow deadlocks because it checks for recorded authorization that it hasn't been allowed to write yet. This is a **confused deputy variant**: the agent holds valid authority but its own workflow prevents it from exercising that authority.

**Research card:** `.issues/research-cards/authorization-session-vs-workflow-state.md` documents the industry research supporting the record-then-verify pattern.

## Not Included

- Changes to the `gap-fill-cascade` checklist items (they work correctly once authorization is recorded)
- Changes to `spec-to-plan-cascade` (it works correctly once spec status is `approved`)
- Changes to `scope-auto-resolve.md` (it works correctly)
- Changes to the `apply-label` task (it works correctly — just needs to run at the right time)
- Changes to the `verify-explicit-authorization` task (it will be replaced by a `verify-recording` task)
- Changes to the `verify-authorization` workflow ordering in `approval-gate-scope/SKILL.md` Workflows section
- Changes to the `gap-fill-cascade` task files
- Changes to the `auto-dispatch` task

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | A new `record-authorization` task exists at `approval-gate-scope/tasks/record-authorization.md` that writes session authorization into persistent issue state | `structural` | File exists at `approval-gate-scope/tasks/record-authorization.md` |
| SC-2 | The `record-authorization` task updates `spec.md` frontmatter to add `status: approved` when the resolved scope is `for_implementation` or higher | `behavioral` | Dispatch the task with a mock session authorization → verify `spec.md` frontmatter contains `status: approved` |
| SC-3 | The `record-authorization` task appends an authorization record to `comments.yaml` with the authorization text, scope, timestamp, and human attribution | `behavioral` | Dispatch the task → verify `comments.yaml` contains a new entry with `author: "human"`, `scope: "for_implementation"`, and a timestamp |
| SC-4 | The `record-authorization` task updates `issue.yaml` to add the `approved-for-{scope}` label | `behavioral` | Dispatch the task → verify `issue.yaml` labels array contains `approved-for-implementation` (or matching scope) |
| SC-5 | The `record-authorization` task commits the `.issues/` worktree changes after writing | `behavioral` | Dispatch the task → verify `git -C .issues/ status` shows clean working tree |
| SC-6 | The `verify-authorization` fast-path workflow in `approval-gate-scope/SKILL.md` is reordered to: (1) scope-auto-resolve, (2) record-authorization, (3) verify-recording, (4) apply-label, (5) auto-dispatch | `string` | grep SKILL.md for the fast-path workflow — verify the step order matches the new sequence |
| SC-7 | The `verify-authorization` full-path workflow in `approval-gate-scope/SKILL.md` is reordered to: (1) scope-auto-resolve, (2) record-authorization, (3) verify-recording, (4) apply-label, (5) item-decomposition, (6) SC-traceability, (7) sub-issues, (8) spec-to-plan-cascade, (9) gap-fill-cascade, (10) verify-codebase, (11) verify-blockers, (12) verify-closed-issue, (13) verify-already-implemented, (14) auto-dispatch | `string` | grep SKILL.md for the full-path workflow — verify the step order matches the new sequence |
| SC-8 | The `verify-explicit-authorization.md` task is replaced by a `verify-recording.md` task that reads back the recorded state and confirms it matches what was written | `structural` | File `verify-explicit-authorization.md` no longer exists; file `verify-recording.md` exists at `approval-gate-scope/tasks/verify-authorization/verify-recording.md` |
| SC-9 | The `verify-recording` task checks that `spec.md` frontmatter has `status: approved`, `comments.yaml` has the authorization record, and `issue.yaml` has the label — and returns BLOCKED if any are missing | `behavioral` | Dispatch the task after a successful record → verify PASS. Corrupt one of the three files → verify BLOCKED with specific reason |
| SC-10 | The `apply-label` task in the fast-path and full-path workflows is moved to AFTER `record-authorization` and `verify-recording` (it was previously step 3, now step 4) | `string` | grep SKILL.md for the `apply-label` step position — verify it appears after `verify-recording` in both workflows |
| SC-11 | The `verify-authorization` gap-fill-path workflow in `approval-gate-scope/SKILL.md` is reordered to: (1) scope-auto-resolve, (2) record-authorization, (3) verify-recording, (4) gap-fill-cascade, (5) auto-dispatch | `string` | grep SKILL.md for the gap-fill-path workflow — verify the step order matches the new sequence |
| SC-12 | All three workflows (fast-path, gap-fill-path, full-path) in `approval-gate-scope/SKILL.md` have the `record-authorization` step inserted at position 2, immediately after `scope-auto-resolve` | `string` | grep SKILL.md for each workflow — verify `record-authorization` is step 2 in all three |

## Requirements

1. The `record-authorization` task SHALL write session authorization into persistent issue state.
2. The `record-authorization` task SHALL update `spec.md` frontmatter to add `status: approved` when the resolved scope is `for_implementation` or higher.
3. The `record-authorization` task SHALL append an authorization record to `comments.yaml` with the authorization text, scope, timestamp, and human attribution.
4. The `record-authorization` task SHALL update `issue.yaml` to add the `approved-for-{scope}` label.
5. The `record-authorization` task SHALL commit the `.issues/` worktree changes after writing.
6. The `record-authorization` task SHALL NOT verify that authorization exists — that is the `verify-recording` task's responsibility.
7. The `verify-recording` task SHALL read back the recorded state and confirm it matches what was written.
8. The `verify-recording` task SHALL check `spec.md` frontmatter for `status: approved`, `comments.yaml` for the authorization record, and `issue.yaml` for the label.
9. The `verify-recording` task SHALL return BLOCKED if any of the three checks fail.
10. The `verify-explicit-authorization.md` task SHALL be removed and replaced by `verify-recording.md`.
11. The `apply-label` task SHALL be moved to AFTER `record-authorization` and `verify-recording` in all three workflows.
12. The `record-authorization` step SHALL be step 2 in all three workflows (fast-path, gap-fill-path, full-path), immediately after `scope-auto-resolve`.

## Items

1. **SC-1, SC-8** — Create `record-authorization.md` task file; remove `verify-explicit-authorization.md`; create `verify-recording.md` task file
2. **SC-2, SC-3, SC-4, SC-5** — Implement the `record-authorization` task procedure (write spec.md, comments.yaml, issue.yaml, commit)
3. **SC-9** — Implement the `verify-recording` task procedure (read back and confirm)
4. **SC-6, SC-7, SC-10, SC-11, SC-12** — Reorder the three workflows in `approval-gate-scope/SKILL.md`

## Dependencies

- **Prerequisite:** Research card at `.issues/research-cards/authorization-session-vs-workflow-state.md`
- **Prerequisite skill:** `approval-gate-scope` — the skill being modified
- **Prerequisite skill:** `spec-creation` — for the task card format reference
- **Prerequisite skill:** `git-workflow-branch` — for branch creation and commit workflow
- **Prerequisite skill:** `test-driven-development` — for RED/GREEN cycles

## Traceability

| Requirement | SCs | Item |
|-------------|-----|------|
| REQ-1 | SC-1 | 1 |
| REQ-2 | SC-2 | 2 |
| REQ-3 | SC-3 | 2 |
| REQ-4 | SC-4 | 2 |
| REQ-5 | SC-5 | 2 |
| REQ-6 | SC-1 | 1 |
| REQ-7 | SC-8, SC-9 | 1, 3 |
| REQ-8 | SC-9 | 3 |
| REQ-9 | SC-9 | 3 |
| REQ-10 | SC-8 | 1 |
| REQ-11 | SC-6, SC-7, SC-10, SC-11, SC-12 | 4 |
| REQ-12 | SC-6, SC-7, SC-11, SC-12 | 4 |

## AI Co-Authored Byline

Co-authored with AI: OpenCode (deepseek-v4-flash)
