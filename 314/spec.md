## Problem

`_discover_all_repos()` in `.opencode/tools/local-issues` uses a filesystem glob pattern to discover child repos:

```python
# Scans three patterns from project root:
# - `.git/` -- parent repo
# - `*/.git/` -- submodule/git-repo directories
# - `*/.git` -- submodule gitlink files (non-bare check)
# No recursion. No .gitmodules parsing.
```

This is too broad — it picks up any directory with a `.git` file/dir, which can include worktrees, build artifacts, or stale directories. The `.issues/` worktrees (both root `.issues/` and `.opencode/.issues/`) are orphan-branch worktrees, not submodules, but the tool should still scope its child-repo discovery to what `.gitmodules` defines.

## Current Behavior

- `_discover_all_repos()` scans `*/.git/` and `*/.git` patterns from project root
- No `.gitmodules` parsing
- Picks up any directory with a `.git` reference, regardless of whether it's a registered submodule
- The `.issues/` worktrees are gitignored in the parent repo, but the glob still finds them via their `.git` files

## Desired Behavior

- `_discover_all_repos()` parses `.gitmodules` to determine which child repos get `.issues/` worktrees
- The root repo is always included (it's the parent, not a submodule)
- Child repos come exclusively from `.gitmodules` entries
- `.issues/` worktrees (orphan-branch worktrees) are NOT treated as submodules — they are worktrees on the parent repo's `issues-data` branch
- Backward compatible: the current `.gitmodules` has one entry (`.opencode`), so the tool should discover exactly the root repo + `.opencode` submodule

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `_discover_all_repos()` parses `.gitmodules` instead of filesystem glob | `behavioral` | Run `local-issues list` and verify it discovers root repo + `.opencode` submodule only |
| SC-2 | Root repo is always included regardless of `.gitmodules` | `string` | grep for root repo always being appended first |
| SC-3 | Child repos come exclusively from `.gitmodules` entries | `behavioral` | Add a temp `.git` file in a non-submodule dir, verify it is NOT discovered |
| SC-4 | `.issues/` worktrees are not treated as submodules | `string` | grep for worktree detection logic being separate from repo discovery |
| SC-5 | All existing commands (create, read, list, search, etc.) continue to work with the new discovery | `behavioral` | Run `local-issues list` and verify output matches current behavior |
| SC-6 | `_ensure_all_worktrees()` creates worktrees only for repos discovered via `.gitmodules` | `behavioral` | Verify worktrees exist only for root + `.opencode` |

## Implementation Notes

- Parse `.gitmodules` using `git config -f .gitmodules` or a Python configparser approach
- The root repo is always the first entry (index 0)
- Child repos are appended in `.gitmodules` order
- The `.issues/` worktree detection (`_worktree_active()`, `_ensure_worktree()`) is separate from repo discovery — it operates on whatever repo path is given
- No changes needed to worktree creation/management logic — only the discovery function changes

## Affected Files

- `.opencode/tools/local-issues` — `_discover_all_repos()` function (lines 203-239)
- `.issues/AGENTS.md` — may need minor doc update
- `.opencode/.issues/AGENTS.md` — may need minor doc update
