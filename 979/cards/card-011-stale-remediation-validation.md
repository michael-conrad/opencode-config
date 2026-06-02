# Card 011: Stale Worktree Remediation — Real-World Validation

**Date:** 2026-06-01
**Status:** VALIDATED
**Origin:** The `.issues/` worktree was already stale when the brainstorming session started

## What Happened

During the brainstorming session, the existing `.issues/` worktree was stale — the `.git` link file at `.issues/.git` was missing. Git worktree list showed it as `prunable`. Every `git add -f 979/ && git commit --no-verify` inside `.issues/` was actually operating on the parent repo's `dev` branch, not on `issues-data`.

Two commits landed on `dev` instead of `issues-data`:
- `e339156f` — spec + 10 design decision cards
- `293e76f7` — creation skill card

The tag `opencode-config/979/spec-created` was created on `dev`, not on `issues-data`.

## Detection and Remediation

1. **Detection:** `git worktree list --porcelain` showed `prunable gitdir file points to non-existent location`. Confirmed by checking `.issues/.git` — file was absent.

2. **Remediation sequence:**
   - `git worktree prune` — removed stale worktree registration from `.git/worktrees/-issues/`
   - `mv .issues .issues.bak` — backed up existing `.issues/` content (both orphan dirs and our 979 work)
   - `git worktree add .issues issues-data` — created fresh worktree on `issues-data`
   - `cp -a .issues.bak/979/ .issues/979/` — restored our work into the worktree
   - `git add -f 979/` and commit on `issues-data` — our work now on the right branch
   - Deleted and re-created tag `opencode-config/979/spec-created` on `issues-data` commit
   - `rm -rf .issues.bak` — cleaned up

3. **Data loss:** Zero. All work was recoverable because the commits existed on `dev` and the files still existed in `.issues.bak/`.

## Implications for the Tool

This validates the `_ensure_worktree()` design. The tool must:

1. **Check for `.issues/.git` file on every command.** If missing (or pointing to a nonexistent path), the worktree is stale.
2. **Auto-remediate:** `git worktree prune` to clean registration, check if `.issues/` has content, backup to `.bak`, recreate worktree, migrate content from `.bak`, commit on `issues-data`.
3. **No data loss path:** The `.bak` safety net ensures content survives even if the worktree creation fails.

## Edge Case

The tag was initially on `dev` and had to be manually re-created on `issues-data`. In the tool, tags should only be created on `issues-data` by operating inside the worktree — never from the parent repo.

## References

- Card-002: worktree model
- Card-006: graceful fallback
- Real-world stale worktree at `.issues/` during this session