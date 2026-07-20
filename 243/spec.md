## Problem

`local-issues init` fails for repos that have a `master` branch but no `issues-data` branch. The `_create_orphan_branch()` function silently returns `None` (void) on failure, and `_create_issues_worktree()` never checks the return value — it proceeds to `_setup_worktree()` which tries `git worktree add .issues issues-data`, but the branch was never created, so the worktree add fails.

Additionally, stale `.issues-worktree-tmp` directories from prior failed runs block re-initialization because `git worktree add --detach` refuses to create a worktree at a path that already exists.

## Root Cause

Two defects in `.opencode/tools/local-issues`:

1. **`_create_orphan_branch()` (line 481):** Returns `None` regardless of success/failure. `_init_orphan_branch()` can return `None` on failure (e.g., stale temp worktree), but `_create_orphan_branch()` never propagates this — it just returns void.

2. **`_create_issues_worktree()` (line 592):** Calls `_create_orphan_branch()` without checking the return value. When the orphan branch creation fails, it proceeds to `_setup_worktree()` which fails because `issues-data` branch doesn't exist.

3. **No stale cleanup:** If a prior `local-issues init` run failed midway, `.issues-worktree-tmp/` remains on disk. The next run's `git worktree add --detach .issues-worktree-tmp` fails because the path already exists.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `_create_orphan_branch()` returns `True` on success, `False` on failure | `structural` | Read function signature |
| SC-2 | `_create_issues_worktree()` checks `_create_orphan_branch()` return value and returns `False` on failure | `structural` | Read function body |
| SC-3 | Stale `.issues-worktree-tmp` is cleaned up before orphan branch creation retry | `structural` | Read function body |
| SC-4 | `local-issues init` succeeds on a repo with `master` branch and no `issues-data` branch | `behavioral` | Run `local-issues init` in a test repo |

## Affected File

- `.opencode/tools/local-issues` — functions `_create_orphan_branch()` and `_create_issues_worktree()`

## Change Control

- **Status:** DRAFT
- **Author:** AI agent
- **Date:** 2026-07-01
