# Plan: Fix `local-issues init` for GitBucket repos with `master` branch

**Issue:** #244
**Spec:** `.issues/244/spec.md`
**Authorization scope:** `for_implementation`
**PR strategy:** `stacked`

## Phase Table

| Phase | Description | Steps | Dependencies |
|-------|-------------|-------|--------------|
| 1 | Fix orphan branch creation, stale cleanup, return-value check, and -C git_dir override | 1–5 | None |

---

## Phase 1: Fix `local-issues init` defects

### Steps

1. **Change `_create_orphan_branch()` return type from `None` to `bool`**
   - File: `.opencode/tools/local-issues` (in `.opencode` submodule)
   - Change return annotation from `None` to `bool`
   - Return `True` on successful orphan branch creation
   - Return `False` on failure (propagate `None` from `_init_orphan_branch()` as `False`)
   - SC-1

2. **Add stale `.issues-worktree-tmp` cleanup before orphan branch creation retry**
   - File: `.opencode/tools/local-issues`
   - In `_create_issues_worktree()`, before the orphan branch creation retry logic, add `shutil.rmtree` (or equivalent) to clean up stale `.issues-worktree-tmp/` directory
   - SC-3

3. **Add return-value check in `_create_issues_worktree()` after `_create_orphan_branch()` call**
   - File: `.opencode/tools/local-issues`
   - After calling `_create_orphan_branch()`, check the return value
   - If `False`, return `False` (do not proceed to `_setup_worktree()`)
   - SC-2

4. **Remove `-C git_dir` from orphan branch subprocess calls**
   - File: `.opencode/tools/local-issues`
   - In `_init_orphan_branch()`: remove `-C git_dir` from `git checkout --orphan` call (cwd=wt_tmp already resolves the correct repo)
   - In `_commit_orphan_init()`: remove `-C git_dir` from `git commit --allow-empty` call
   - In `_remove_temp_worktree()`: remove `-C git_dir` from `git checkout -` call
   - SC-5

5. **Verify all SCs pass**
   - SC-1: Read function signature — confirm return type annotation changed from `None` to `bool`
   - SC-2: Read function body — confirm conditional check present after `_create_orphan_branch()` call
   - SC-3: Read function body — confirm cleanup call present before retry
   - SC-4: Run `local-issues init` in a test repo with `master` branch and no `issues-data` branch; verify exit code 0 and `.issues/` worktree created
   - SC-5: Read each function body — confirm `-C git_dir` absent from subprocess.run calls that also use `cwd=wt_tmp`
