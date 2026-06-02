# Card 007: Command Surface — Pure Domain Operations

**Date:** 2026-06-01
**Status:** DECIDED
**Origin:** Current surface mixes domain commands (create, read) with infrastructure commands (setup, push, sync)

## Decision

The new CLI surface exposes only pure domain operations. Infrastructure is internal.

### New Command Surface

| Command | Purpose | Current Status |
|---------|---------|----------------|
| `local-issues create --title T [--labels L]` | Create new local issue | ✅ Exists, keep |
| `local-issues read N` | Read issue body (frontmatter + body) | ✅ Exists, keep |
| `local-issues read-comments N` | Read comments | ❌ Missing, ADD |
| `local-issues read-labels N` | Read labels from frontmatter | ❌ Missing, ADD |
| `local-issues read-sub-issues N` | Read sub-issues from comments.md # refs | ❌ Missing, ADD |
| `local-issues review N` | Pretty-print for developer review | ✅ Exists, keep |
| `local-issues update N [--title T] [--status S] [--body B] [--labels L]` | Update metadata and/or body | ⚠️ Exists, ADD --body flag |
| `local-issues comment N --body "..."` | Add comment | ✅ Exists, keep |
| `local-issues close N` | Close issue | ✅ Exists, keep |
| `local-issues delete N [--force]` | Delete issue permanently | ❌ Missing, ADD |
| `local-issues search [--status S] [--labels L] [--query Q]` | Search issues | ✅ Exists, keep |
| `local-issues list [--status S]` | List issues | ✅ Exists, keep |
| `local-issues push-body N` | Push remote.md body to remote issue | ⚠️ Currently called sync-push, RENAME |
| `local-issues pull-body N` | Pull remote body to local remote.md | ⚠️ Currently called sync-pull, RENAME |
| `local-issues link N --github NUM` | Link local issue to GitHub issue | ✅ Exists, keep |
| `local-issues promote N` | Check promotion readiness | ⚠️ Exists, may need review |

### Removed Commands

| Command | Reason |
|---------|--------|
| `local-issues setup` | Now internal — tool auto-creates worktree on first mutation |
| `local-issues sync` | Dead umbrella — replaced by explicit push-body / pull-body |
| `local-issues sync-push` | Renamed to `push-body` |
| `local-issues sync-pull` | Renamed to `pull-body` |

### Internal Operations (not CLI-accessible)

These operations happen transparently inside the tool and are never called by agents:

- Worktree setup (auto on first mutation)
- Worktree stale detection and remediation (on every mutation)
- Auto-commit on issues-data (after every mutation when worktree active)
- Push-at-gates (called by skill task files at gate checkpoints)
- Tag creation (at each gate)
- Graceful fallback to plain files (when worktree unavailable)
- Migration from fallback → worktree (when worktree becomes available)

## References

- Issue #979 analysis: 3 missing CLI commands, non-functional sync umbrella
- Existing commands: lines 276-1761 in current `local-issues`
- Behavioral test gaps: 0 tests for sync/push/pull commands