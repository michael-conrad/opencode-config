# SPEC: Fix post-merge cleanup workflow — submodule-first depth-first cleanup

## Problem

When a user says "pr merged", the agent dispatches `check-pr` (a scanning/verification workflow) instead of `cleanup` (the full post-merge cleanup workflow). The `check-pr` task has a simplified 4-bullet submodule cleanup in Phase 4 that lacks proper depth-first iteration, content verification gates, tag-if-untagged, and dirty pointer acknowledgment. Additionally, `cleanup.md` Step 3 routes to `cleanup/branch-cleanup` which does not exist as a file.

The correct post-merge workflow is:
1. Submodules: check for merged PRs, clean up branches, restore to trunk tip
2. Parent repo: check for merged PRs, clean up branches, restore to trunk tip
3. Dirty submodule pointers left as-is (resolved on next pre-work cycle)

## Root Cause

Three defects:

1. **Wrong trigger routing in `git-workflow/SKILL.md`** — `"pr merged"` maps to `check-pr` instead of `cleanup`
2. **Wrong trigger routing in `git-workflow-cleanup/SKILL.md`** — `"pr merged"` maps to `check-pr` instead of `cleanup`
3. **Missing task file** — `cleanup.md` Step 3 routes to `cleanup/branch-cleanup` which does not exist

## Affected Files

| File | Defect |
|------|--------|
| `.opencode/skills/git-workflow/SKILL.md:35` | `"pr merged"` maps to `check-pr` instead of `cleanup` |
| `.opencode/skills/git-workflow-cleanup/SKILL.md:19` | `"pr merged"` maps to `check-pr` instead of `cleanup` |
| `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md:125` | Routes to `cleanup/branch-cleanup` which does not exist |
| `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md:109-114` | Phase 4 submodule cleanup is simplified — lacks depth-first iteration, content verification, tag-if-untagged |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `git-workflow/SKILL.md` Trigger Dispatch Table maps `"pr merged"` to `cleanup` (not `check-pr`) | `string` | grep for `"pr merged"` in SKILL.md — must show `cleanup` in the task column |
| SC-2 | `git-workflow-cleanup/SKILL.md` Trigger Dispatch Table maps `"pr merged"` to `cleanup` (not `check-pr`) | `string` | grep for `"pr merged"` in SKILL.md — must show `cleanup` in the task column |
| SC-3 | `cleanup.md` Step 3 routes to an existing sub-task file (not `cleanup/branch-cleanup` which does not exist) | `string` | grep for `branch-cleanup` in cleanup.md — must reference an existing file or be replaced with inline steps |
| SC-4 | `check-pr.md` Phase 4 submodule cleanup is removed or replaced with a cross-reference to the full cleanup workflow | `string` | grep for `Phase 4` in check-pr.md — must not contain simplified submodule cleanup bullets |
| SC-5 | `cleanup.md` contains a proper depth-first cleanup procedure: submodules first, then parent, dirty pointers left as-is | `string` | grep for submodule iteration order in cleanup.md — must show submodule-first, parent-second |
| SC-6 | All repos left at trunk tip after cleanup | `behavioral` | `opencode run` with "pr merged" prompt — verify stderr shows trunk-tip verification for all repos |

## Implementation Plan

### Phase 1: Fix Trigger Routing

1. In `git-workflow/SKILL.md:35`, change the `"pr merged"` row from `check-pr` to `cleanup`
2. In `git-workflow-cleanup/SKILL.md:19`, change the `"pr merged"` row from `check-pr` to `cleanup`

### Phase 2: Fix Missing Sub-Task

3. In `cleanup.md:125`, replace the `cleanup/branch-cleanup` route with inline steps that perform proper depth-first cleanup:
   - Iterate submodules first: switch to trunk, sync, delete merged branches, verify at tip
   - Then parent repo: switch to trunk, sync, delete merged branches, verify at tip
   - Leave dirty submodule pointers as-is

### Phase 3: Fix check-pr.md Submodule Cleanup

4. In `check-pr.md:109-114`, replace the simplified Phase 4 submodule cleanup with a cross-reference to the full cleanup workflow, or remove it entirely since `"pr merged"` now routes to `cleanup` directly.

## Change Control

| Version | Date | Author | Change |
|---------|------|--------|--------|
| 1.0 | 2026-07-20 | AI | Initial spec |
