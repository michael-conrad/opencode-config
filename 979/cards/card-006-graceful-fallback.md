# Card 006: Graceful Fallback — Plain Files When Worktree Unavailable

**Date:** 2026-06-01
**Status:** DECIDED
**Origin:** Worktree creation may fail (no remote, locked tree, permissions issue)

## The Problem

`local-issues setup` can fail for various reasons:
- No remote configured (local-only repo)
- Stale worktree at a different path
- Git lock files preventing worktree creation
- Permission errors

The tool must not become non-functional when the worktree cannot be set up. The fallback must allow all operations to proceed.

## Decision

**If worktree creation fails, write `.issues/` as plain files on the current feature branch.** The tool operates as a regular directory with the same structure: `.issues/open/NNN-slug/spec.md`, `comments.md`, etc.

### Behavior

1. On first mutation command (`create`, `update`, etc.), check if `.issues/` is a worktree.
2. If it IS a worktree: proceed as normal (write to worktree, auto-commit, push-at-gates).
3. If it IS NOT a worktree: check if worktree CAN be created.
   - If yes: create worktree, migrate any existing `.issues/` content into it, proceed as normal.
   - If no: write `.issues/` as plain files on the current branch.
4. On every subsequent mutation, re-check worktree availability.
   - If worktree becomes available (e.g., remote was configured after first command): replace plain `.issues/` with worktree, migrate content, continue.

### Migration Path

When falling back → worktree becomes available:

```
1. Stash or note current .issues/ state
2. Run setup (creates worktree, renames existing .issues/ → .issues.bak)
3. Copy all content from .issues.bak back into worktree's .issues/
4. Commit on issues-data
5. Remove .issues.bak
6. Continue with worktree mode
```

### Durability in Fallback Mode

Without a worktree, `.issues/` files live on the feature branch and are subject to branch reset/deletion. This is acceptable because:
- The primary durable copy is on the remote issue tracker (GitHub/GitBucket)
- The local `.issues/` is a convenience copy for agent workflow
- If the worktree is available, the agent gets full durability; if not, the agent gets best-effort

## References

- Card-002: worktree model
- Existing `cmd_setup()` migration logic in current `local-issues` (lines 854-883)
- 060-tool-usage.md §Identity Source Semantics (`identity_source: local` means no remote)