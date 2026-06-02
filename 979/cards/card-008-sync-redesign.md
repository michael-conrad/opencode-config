# Card 008: Sync Redesign — Three Disjoint Operations Unified

**Date:** 2026-06-01
**Status:** DECIDED
**Origin:** Current sync system has three separate, poorly coordinated, partially non-functional paths

## Current State

The existing sync surface is a mess:

| Command | What It Actually Does | Status |
|---------|----------------------|--------|
| `sync N --direction pull` | Prints "not yet implemented" → returns 1 | ❌ Dead stub |
| `sync N --direction push` | Prints "not yet implemented" → returns 1 | ❌ Dead stub |
| `sync N --direction bidirectional` | Prints "not yet implemented" → returns 1 | ❌ Dead stub |
| `sync-push N` | Reads remote.md → calls `gh issue edit` | ⚠️ GitHub only, silent GitBucket failure |
| `sync-pull N` | Fetches via `gh issue view` → writes remote.md + state.md | ⚠️ Doesn't update spec.md |
| `push` | Pushes issues-data branch to origin | ✅ Works correctly |

## The Confusion

Three distinct operations share overlapping names:
1. **Push the `issues-data` git branch** to remote (git operation) — currently `push`
2. **Push the issue body** from local `remote.md` to the remote API — currently `sync-push`
3. **Pull the issue body** from the remote API to local `remote.md` — currently `sync-pull`

## Resolution

| Old Name | New Name | What It Does |
|----------|----------|--------------|
| (was `push`) | (becomes internal) | Push issues-data branch. Called only by tool internally at gates. |
| `sync-push` | `push-body` | Push remote.md content to GitHub/GitBucket issue via API |
| `sync-pull` | `pull-body` | Pull remote issue body to local remote.md + state.md |
| (was `sync`) | REMOVED | Dead umbrella removed entirely |

### push-body Design

```
local-issues push-body N

1. Read .issues/open/NNN-slug/remote.md
2. Detect platform (github / gitbucket / local)
3. If github: call gh issue edit <N> --body-file -
4. If gitbucket: call gitbucket-api update-issue
5. If local: print info, return 0 (no remote to push to)
6. Update state.md with last_sync timestamp
7. On success: return 0 with "Pushed body for #N"
8. On failure: return 1 with error details
```

### pull-body Design

```
local-issues pull-body N

1. Check .issues/ has no dirty changes (abort if dirty)
2. Detect platform (github / gitbucket / local)
3. If github: call gh issue view <N> --json body
4. If gitbucket: call gitbucket-api get-issue
5. If local: print info, return 0 (no remote to pull from)
6. Write body to .issues/open/NNN-slug/remote.md (overwrite)
7. Update state.md with last_sync timestamp
8. Return 0 on success, 1 on failure
```

### What About spec.md?

`pull-body` does NOT update `spec.md` by design. The `spec.md` is the canonical local source with full-fidelity detail. `remote.md` is the exec-summary that gets pushed to the remote API. They serve different purposes and have different content. Updating `spec.md` from `pull-body` would overwrite local detail that may not exist on the remote.

## References

- Current `cmd_sync_push()` lines 1164-1262
- Current `cmd_sync_pull()` lines 1265-1348
- Current `cmd_sync()` lines 552-608 (dead code)
- body-edit.md Phase 4 (manual push-body called as `local-issues sync push N`)
- comment.md Step 1.5 (manual sync push for stakeholder comments)