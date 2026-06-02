# Card 015: Close — Local Mutation, Separate Remote Sync

**Date:** 2026-06-01
**Status:** DESIGNED
**Origin:** Same pattern as update — close is a local mutation, remote sync is separate

## Tool Interface

```
local-issues close N [--reason completed|not_planned|duplicate]
```

## Tool Operations

1. Verify issue is currently open (exit 2 if already closed)
2. Update frontmatter: status → `closed`, add `closed_at` timestamp, set `state_reason`
3. Move `.issues/open/NNN-slug/` → `.issues/closed/NNN-slug/`
4. Auto-commit on issues-data

Exit codes:
- 0: Success — issue closed
- 1: Error — issue not found, move failed
- 2: Already closed

## Skill Card Flow

```
1. task: close (local mutation)
2. task: push-body (update remote issue status + state_reason)
```

Close is a local file operation. The remote sync is handled by the same `push-body` mechanism used for updates — `remote.md` and frontmatter metadata get pushed to the remote API.

## References

- Card-013: update separate from push-body (same pattern)
- Card-008: sync redesign (push-body)