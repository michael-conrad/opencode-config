## Problem

The `local-issues` tool (`.opencode/tools/local-issues`) only sets up the `.issues/` git worktree in the main repository. It has no awareness of submodules or subrepos. When the main repo has submodules (e.g., `.opencode/`), the tool does not create `.issues/` worktrees inside those submodules.

This means:
- Agent workflows that need local issue tracking in a submodule must manually set up the `.issues/` worktree
- The `issue-operations` platform routing for local mode can't rely on a uniform `.issues/` setup across repos
- The `.opencode/` submodule currently has a manually-created `.issues/` worktree on branch `issues-data` that is not managed by `local-issues`

## Current State

- `local-issues` has hardcoded `ISSUES_DIR = ".issues"` and `WORKTREE_BRANCH = "issues"` — no parameters for alternate targets
- `_ensure_worktree()` runs from `os.getcwd()` — always assumes repo root
- No `--workdir` or `--target-submodule` parameter exists
- The `.opencode/` submodule has a `.issues/` worktree (`issues-data` branch) that was set up manually outside the tool

## Root Cause

The `local-issues` tool was designed for single-repo use. The repo now has submodule structure, but the tool never evolved to support it. No design for multi-repo `setup` exists.

## Required Behavior

The `local-issues` tool (or a companion script) must support setting up `.issues/` worktrees for submodules and subrepos in addition to the main repo. This means:

1. **New `setup` subcommand** — explicitly initializes `.issues/` worktree for a given target (main repo or submodule)
2. **`--workdir` parameter** — specify which directory (repo or submodule) to set up the `.issues/` worktree in
3. **Branch naming** — submodules get their own issues branch (e.g., `issues` for main repo, `issues-data` for `.opencode/`) or use a consistent naming convention
4. **Integration with `validate-submodule-refs.sh`** or similar — the setup script should verify the submodule state before creating the worktree

## Affected Files

| File | Change |
|------|--------|
| `.opencode/tools/local-issues` | Add `setup` subcommand, `--workdir` parameter, submodule-aware `_ensure_worktree()` |
| `.opencode/scripts/` (new or existing) | Possibly a `setup-all-issues.sh` wrapper that invokes `local-issues setup --workdir <path>` for each submodule |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `local-issues setup` creates `.issues/` worktree in the specified `--workdir` | `behavioral` | Run `local-issues setup --workdir .opencode`, verify `.opencode/.issues/.git` exists as a linked worktree |
| SC-2 | `local-issues setup` (no `--workdir`) defaults to main repo (backward compatible) | `behavioral` | Run `local-issues setup` in main repo, verify `.issues/.git` exists as a linked worktree |
| SC-3 | Existing `create`/`read`/`update` commands work unchanged (no regression) | `behavioral` | Run existing test suite for `local-issues` |
| SC-4 | Tool handles submodules that are not initialized gracefully (informs user, no crash) | `string` | Run setup on non-existent submodule dir, verify error message |
| SC-5 | Submodule issue branch name conventions are documented in tool help | `structural` | `local-issues setup --help` output includes branch naming section |

## Key Design Decisions

1. **Branch naming**: Each submodule SHOULD have its own issues branch name (e.g., `issues` for main, `issues-<submodule-name>` for submodules). Branch discovery should be by `git worktree list`, not by hardcoded name.
2. **`setup` is idempotent**: If the worktree already exists, `setup` should verify it and exit cleanly (no-op).
3. **Submodule init check**: Before creating a worktree in a submodule, verify `git submodule status` shows it's initialized. If not, print actionable error.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)