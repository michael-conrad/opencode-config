# SPEC: Fix post-merge cleanup workflow — submodule-first depth-first cleanup

## Problem

When a user says "pr merged", the agent dispatches `check-pr` (a scanning workflow) instead of `cleanup` (the action workflow). This is a **workflow boundary violation**: `check-pr` is an internal scanning workflow that should only report state — it should never contain cleanup actions. Yet `check-pr.md` has Phase 4 (Submodule Branch Cleanup) and Phase 5 (Parent Branch Cleanup), which are cleanup actions leaking into a scanning workflow.

Additionally, `cleanup.md` Step 3 routes to `cleanup/branch-cleanup` which does not exist as a file, so even if `cleanup` were dispatched, it would fail at Step 3.

The correct separation of concerns:

| Trigger | Workflow | What it does |
|---------|----------|-------------|
| `"check pr"` / `"check prs"` | `check-pr` | **Scan only** — list merged PRs, report state, HALT. No cleanup actions. |
| `"pr merged"` | `cleanup` | **Act** — depth-first cleanup: submodules first, then parent, dirty pointers left as-is. |

## Root Cause

Three defects:

1. **Wrong trigger routing in `git-workflow/SKILL.md`** — `"pr merged"` maps to `check-pr` instead of `cleanup`
2. **Wrong trigger routing in `git-workflow-cleanup/SKILL.md`** — `"pr merged"` maps to `check-pr` instead of `cleanup`
3. **Missing task file** — `cleanup.md` Step 3 routes to `cleanup/branch-cleanup` which does not exist
4. **Workflow boundary violation** — `check-pr.md` Phases 4-5 contain cleanup actions that belong in `cleanup`, not in a scanning workflow

## Affected Files

| File | Defect |
|------|--------|
| `.opencode/skills/git-workflow/SKILL.md:35` | `"pr merged"` maps to `check-pr` instead of `cleanup` |
| `.opencode/skills/git-workflow-cleanup/SKILL.md:19` | `"pr merged"` maps to `check-pr` instead of `cleanup` |
| `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md:125` | Routes to `cleanup/branch-cleanup` which does not exist |
| `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md:109-125` | Phases 4-5 contain cleanup actions (branch delete, tag delete, prune) in a scanning workflow — workflow boundary violation |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `git-workflow/SKILL.md` Trigger Dispatch Table maps `"pr merged"` to `cleanup` (not `check-pr`) | `string` | grep for `"pr merged"` in SKILL.md — must show `cleanup` in the task column |
| SC-2 | `git-workflow-cleanup/SKILL.md` Trigger Dispatch Table maps `"pr merged"` to `cleanup` (not `check-pr`) | `string` | grep for `"pr merged"` in SKILL.md — must show `cleanup` in the task column |
| SC-3 | `cleanup.md` Step 3 routes to an existing sub-task file (not `cleanup/branch-cleanup` which does not exist) | `string` | grep for `branch-cleanup` in cleanup.md — must reference an existing file or be replaced with inline steps |
| SC-4 | `check-pr.md` contains NO cleanup actions — no branch deletion, no tag deletion, no prune, no submodule cleanup | `string` | grep for `delete`, `prune`, `cleanup`, `branch-cleanup` in check-pr.md — must not appear in Phase 4 or Phase 5 |
| SC-5 | `check-pr.md` Phases 4-5 are replaced with a single "Report and HALT" phase | `string` | grep for `Phase 4` and `Phase 5` in check-pr.md — must show report-only, no action |
| SC-6 | `cleanup.md` contains a proper depth-first cleanup procedure: submodules first, then parent, dirty pointers left as-is | `string` | grep for submodule iteration order in cleanup.md — must show submodule-first, parent-second |
| SC-7 | All repos left at trunk tip after cleanup | `behavioral` | `opencode run` with "pr merged" prompt — verify stderr shows trunk-tip verification for all repos |

## Implementation Plan

### Phase 1: Fix Trigger Routing

1. In `git-workflow/SKILL.md:35`, change the `"pr merged"` row from `check-pr` to `cleanup`
2. In `git-workflow-cleanup/SKILL.md:19`, change the `"pr merged"` row from `check-pr` to `cleanup`

### Phase 2: Strip Cleanup Actions from check-pr.md

3. In `check-pr.md:109-125`, replace Phases 4-5 (Submodule Branch Cleanup, Parent Branch Cleanup) with a single "Report and HALT" phase:
   - Remove all branch deletion, tag deletion, prune, and submodule cleanup actions
   - Replace with: "Report merged PRs found and HALT — cleanup is handled by the `cleanup` workflow on `"pr merged"` trigger"

### Phase 3: Fix Missing Sub-Task in cleanup.md

4. In `cleanup.md:125`, replace the `cleanup/branch-cleanup` route with inline steps that perform proper depth-first cleanup:
   - Iterate submodules first: switch to trunk, sync, delete merged branches, verify at tip
   - Then parent repo: switch to trunk, sync, delete merged branches, verify at tip
   - Leave dirty submodule pointers as-is

## Change Control

| Version | Date | Author | Change |
|---------|------|--------|--------|
| 1.0 | 2026-07-20 | AI | Initial spec |
