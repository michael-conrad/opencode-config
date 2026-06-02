# Card 002: Worktree Model — Single Orphan `issues-data` Branch

**Date:** 2026-06-01
**Status:** DECIDED
**Origin:** Durability requirement — feature branch resets destroy `.issues/` files

## Problem

Feature branches have a lifecycle that includes resets, rebases, and deletions. When a feature branch is reset to `dev` tip (e.g., after a spec revision or partial implementation rollback), all `.issues/` files on that branch are lost. This has happened multiple times, losing spec revisions and state.

## Options Considered

| Approach | Durability | Complexity | Conflict Risk |
|----------|------------|------------|---------------|
| Single orphan `issues-data` branch (worktree) | High — lives outside feature branch lifecycle | Medium — setup, stale detection, push needed | Low — single writer, single timeline |
| Per-issue branches (`issues-data/123`, `issues-data/456`) | High — each issue has independent branch | High — branch switching inside worktree, merge management | Low — files disjoint per branch |
| Plain files on feature branch only | Low — lost on branch reset | None — simplest possible | None — no sharing |
| Feature branch from `issues-data` tip | Medium — branch ancestry preserves some history | Medium — must manage merge-base | Medium — merge conflicts on rebase |

## Decision

**Single orphan `issues-data` branch** with a git worktree at `.issues/`. Rationale:

1. **Orphan branch has zero ancestry** — no merge-base issues, no history from `dev`, no conflict risk when syncing.
2. **Tags as checkpoints** (pre-work, VbC GREEN, audit pass, code review) provide durable named references that survive branch deletion and force-push.
3. **Per-issue branches rejected** because: every branch switch inside the worktree is a failure point, merge from per-issue branches into `issues-data` has no common ancestor (orphan origin), and discovered issues (#456 during #123 implementation) are the common case — they need to land on the same branch.
4. **Feature branch from `issues-data` tip rejected** because `issues-data` has no ancestry to branch from. An orphan branch has no commits beyond its own history.

## Durability Guarantee

- Every mutation auto-commits on the `issues-data` branch. Committed data survives even if the feature branch is deleted.
- Tags at gates provide named recoverable points. A tag of the form `<parent-repo>/<issue>/<phase>-<stage>` pinpoints the exact commit.
- Push-at-gates (pre-work, VbC GREEN, audit pass, code review) provide remote durability.

## Implementation Notes

- The tool internally manages: worktree existence check → stale detection → remediation → setup if needed
- The agent never calls `local-issues setup` or `local-issues push` directly
- Graceful fallback: if worktree creation fails, write plain files on current branch

## References

- Pre-spec analysis: pre-work.md Step 3.7 (280 lines), review-prep.md lines 46-50, push-and-cleanup.md line 149
- Existing stale detection code in `local-issues` lines 654-711
- Bug pattern: feature branch resets have destroyed spec data on multiple occasions