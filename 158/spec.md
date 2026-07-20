## Intent and Executive Summary

- **Problem Statement:** `session-init`'s `collect_repo_info()` skips `.issues` worktrees in the `## Repo Information` output, so the agent never learns about them as routing targets.
- **Root Cause:** Two defects in `collect_repo_info()`: (a) a worktree filter at line 233-239 skips any subdirectory whose remote owner/repo matches the parent, which catches `.issues/` worktrees; (b) the scan at line 219 uses `os.listdir(cwd)` which is single-level and never reaches `.opencode/.issues/` (two levels deep).
- **Approach Chosen:** Remove the worktree filter entirely (it's wrong — entries are keyed by `path`, not owner/repo), and add one-level recursion into submodule directories to find nested worktrees.
- **Alternatives Considered & Why Discarded:** Whitelist-based approach (only allow `.issues`) — fragile, doesn't handle future worktree names. Path-prefix matching — couples to naming conventions.
- **Key Design Decisions:** `path` is the routing discriminant, not `owner/repo`. Removal/reduction of a filter always beats adding exceptions to it.

## Objective

Make `session-init` emit every subdirectory with a `.git` entry and resolvable remote as a repo info entry, regardless of owner/repo match with parent. Include worktrees nested inside submodule directories (one level deep into submodules).

## Context

Current `collect_repo_info()` (`.opencode/tools/session-init:179-248`):

- Scans immediate subdirectories of `cwd` via `os.listdir(cwd)`
- Skips entries whose `(owner, repo)` matches the parent (lines 233-239)
- `.issues/` worktree at root skipped because it resolves to same `michael-conrad/opencode-config` as parent
- `.opencode/.issues/` worktree never reached (two levels deep)

Agents use the `## Repo Information` section for MCP API routing. Missing entries mean the agent doesn't know about valid routing targets, causing incorrect `owner/repo` values in API calls.

## Affected Files

| Path | Anchor | Description |
|------|--------|-------------|
| `.opencode/tools/session-init` | `collect_repo_info()` (L179-248) | Repo discovery and filtering logic |
| `.opencode/tools/session-init` | `install_hooks()` (L347-394) | Calls `collect_repo_info()` — must handle new entries correctly |
| `.opencode/tools/session-init` | `bootstrap_worktree_layout()` (L579-597) | Iterates `collect_repo_info()` for submodule updates — must handle new entries correctly |

## Fix Approach

### Change 1: Remove worktree filter (L232-239)

Delete the four-line filter block. After removal, an entry like `.issues/` with `owner=michael-conrad, repo=opencode-config, path=.issues` will be emitted alongside the root entry `path=.`. The agent routes by path — no collision exists.

### Change 2: Submodule recursion for nested worktrees

After the immediate-scan loop, walk the `.gitmodules` file (or check each entry already found for submodule status) and scan one level into each submodule directory for additional `.git` entries. This catches `.opencode/.issues/`. Apply the same logic: if it has `.git` + resolvable remote, emit an entry.

### Change 3: Caller audit

Both `install_hooks()` (L347) and `bootstrap_worktree_layout()` (L579) call `collect_repo_info()` and iterate entries. They filter on `dir_name == "."` and `os.path.isdir(dir_name)` — these guards should still work correctly with additional entries. Verify no regressions.

## Success Criteria

| ID | Criterion | Verification Method | Remediation |
|----|-----------|-------------------|-------------|
| SC-1 | Root `.issues/` worktree appears in `## Repo Information` output with `path: .issues` and correct `owner`/`repo`/`platform`/`url` | `uv run ./.opencode/tools/session-init \| grep -A4 'path: \.issues'` — must return 4 lines of YAML | If missing: verify `.issues/.git` exists and has a resolvable remote |
| SC-2 | `.opencode/.issues/` worktree appears in `## Repo Information` output with `path: .opencode/.issues` and correct values | `uv run ./.opencode/tools/session-init \| grep -A4 'path: \.opencode/.issues'` — must return 4 lines of YAML | If missing: verify submodule scan recurses into `.opencode/` |
| SC-3 | Root entry (`path: .`) still appears first in the output | `uv run ./.opencode/tools/session-init \| grep -A4 '^- path: \.$'` — must exist as first YAML entry | Regression check — root entry must not be lost |
| SC-4 | Submodule entry (`path: .opencode`) still appears in output | `uv run ./.opencode/tools/session-init \| grep -A4 'path: \.opencode$'` — must exist | Regression check — submodule must not be lost |
| SC-5 | `install_hooks()` does not crash with additional entries | `uv run ./.opencode/tools/session-init` — must exit 0 | If crash: check entry iteration guards (L581-590) |
| SC-6 | `bootstrap_worktree_layout()` does not crash with additional entries | `uv run ./.opencode/tools/session-init` — must exit 0 | Same as SC-5 |

### Semantic Intent Notes

- **SC-1, SC-2**: `.issues` worktrees are valid routing targets with distinct `path` values. The agent must know about them to issue correct MCP API calls for issue operations.
- **SC-3, SC-4**: Root and submodule entries are the primary routing targets for most operations. Removing the worktree filter must not accidentally suppress them.
- **SC-5, SC-6**: `install_hooks()` and `bootstrap_worktree_layout()` both iterate `collect_repo_info()` results — they must handle subdirectory entries robustly regardless of count.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `.opencode/tools/session-init` L179-248 | Analyze `collect_repo_info()` filtering logic |
| Direct source search | `.opencode/tools/session-init` L347-394, L579-597 | Audit callers of `collect_repo_info()` |
| Live verification | `cat .issues/.git`, `cat .opencode/.issues/.git` | Confirm both are git worktrees with resolvable gitdirs |
| Live verification | `git -C .issues remote get-url origin`, `git -C .opencode/.issues remote get-url origin` | Confirm both resolve to correct remote |

## Risk and Edge Cases

- **Risk: Duplicate remote URLs in output.** After removing the filter, entries like `.` and `.issues` will both show `git@github.com:michael-conrad/opencode-config.git`. This is harmless — the agent routes by `path`, and the identical `owner`/`repo` values are the expected remote identity. No collision.
- **Risk: Orphaned worktrees with missing remotes.** If a worktree's `.git` file points to a gitdir whose parent repo has been moved/deleted, `git remote get-url origin` may fail. The existing guard at L226-228 handles this silently (`if not sub_url: continue`).
- **Edge case: Submodule directory has no `.issues` worktree.** The scan emits whatever it finds — zero additional entries is valid. No crash.
- **Edge case: Multiple nested worktrees in submodules.** Each gets its own entry. The one-level recursion limit prevents unbounded traversal. If deeper nesting is needed later, recursion depth can be increased.

## Phases

This is a single-phase change: all three changes (remove filter, add submodule recursion, audit callers) apply to one file and should be implemented together.

## All-or-Nothing Gate

ALL success criteria MUST pass for implementation to be considered complete. Any FAIL triggers autonomous remediation by the producing agent — remediate and re-verify. If re-verification also fails (double-failure), HALT with blocker report.

🤖 OpenCode (deepseek-v4-flash) created
