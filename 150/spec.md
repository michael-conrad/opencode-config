
## Problem

The `.issues/` worktree on the `issues-data` branch has gaps in remote push behavior:

**1. Setup push is fire-and-forget.** `local-issues setup` pushes `issues-data` to origin once (line 814) but does not verify upstream tracking was actually set. A silent push failure leaves the agent believing `issues-data` is on remote when it is not. On subsequent `local-issues setup` calls (idempotent exit at line 638), this code path never re-runs, so there is no verification loop.

**2. No subsequent push mechanism.** After setup, all `.issues/` commits happen inside the worktree (via `git add` + `git commit` inside `.issues/`). These commits are never pushed to the remote `issues-data` branch. The remote branch goes stale after the first commit.

**3. Missing pipeline integration points.** The push should happen at two natural points:
- At **pre-work** Step 3.7 (after `local-issues setup` returns): verify remote tracking, push if not set up
- At **review-prep** (after auto-committing dirty `.issues/` files): push `issues-data` so remote stays current

## Design

### Change 1: Enhance `local-issues setup` with remote tracking verification

In `cmd_setup()`, after the push block (lines 813-827), add a post-push verification step:

```python
# Verify upstream tracking was established
tracking_check = _git(["config", f"branch.{ISSUES_DATA_BRANCH}.remote"], check=False)
if tracking_check.returncode != 0 or tracking_check.stdout.strip() != "origin":
    print(
        f"ERROR: Push completed but upstream tracking not set for {ISSUES_DATA_BRANCH}.",
        file=sys.stderr,
    )
    _git(["push", "-u", "origin", ISSUES_DATA_BRANCH], check=False)
    return 1
```

In the idempotent early-exit path (line 638), add a **push-if-no-upstream** check:

```python
# Idempotent re-entry: verify upstream tracking exists; push if not
tracking = _git(["config", f"branch.{ISSUES_DATA_BRANCH}.remote"], check=False)
if tracking.returncode != 0 or tracking.stdout.strip() != "origin":
    push_result = _git(["push", "-u", "origin", ISSUES_DATA_BRANCH], check=False)
    if push_result.returncode != 0:
        print("ERROR: upstream tracking missing and push failed.", file=sys.stderr)
        return 1
    print(f"  Restored upstream tracking: pushed {ISSUES_DATA_BRANCH} to origin")
```

### Change 2: Add `local-issues push` subcommand

Add a new `cmd_push()` function and `push` dispatcher entry:

```python
def cmd_push() -> int:
    """Push pending issues-data commits to remote."""
    repo_root = _git(["rev-parse", "--show-toplevel"]).stdout.strip()
    issues_path = os.path.join(repo_root, ISSUES_DIR)

    if not os.path.isdir(issues_path):
        print("ERROR: .issues/ not found. Run local-issues setup first.", file=sys.stderr)
        return 1

    # Check if tracking branch exists
    tracking = _git(["config", f"branch.{ISSUES_DATA_BRANCH}.remote"], check=False)
    if tracking.returncode != 0 or tracking.stdout.strip() != "origin":
        first_push = _git(["push", "-u", "origin", ISSUES_DATA_BRANCH], check=False)
        if first_push.returncode != 0:
            print(f"ERROR: Failed to set upstream and push {ISSUES_DATA_BRANCH}.", file=sys.stderr)
            return 1
        print(f"  Set upstream and pushed {ISSUES_DATA_BRANCH}")
        return 0

    # Check for unpushed commits
    ahead = _git(["rev-list", "--count", f"origin/{ISSUES_DATA_BRANCH}..{ISSUES_DATA_BRANCH}"], check=False)
    if ahead.returncode == 0 and ahead.stdout.strip() == "0":
        print(f"  {ISSUES_DATA_BRANCH} is up to date (no unpushed commits)")
        return 0

    push_result = _git(["push", "origin", ISSUES_DATA_BRANCH], check=False)
    if push_result.returncode != 0:
        print(f"ERROR: Failed to push {ISSUES_DATA_BRANCH}.", file=sys.stderr)
        return 1

    print(f"  Pushed {ISSUES_DATA_BRANCH} to origin ({ahead.stdout.strip()} commit(s))")
    return 0
```

Dispatcher entry in `main()` and usage string update.

### Change 3: Update pre-work Step 3.7

After `local-issues setup` exits successfully, add substep 6:

```
6. **Verify issues-data remote tracking and push if needed:**
   ```bash
   local-issues push
   ```
   If exit code != 0: HALT and report push failure.
```

### Change 4: Update review-prep

After auto-commit of dirty `.issues/` files (Step 0), add:

```
6. **Push issues-data branch to remote (MANDATORY):**
   ```bash
   local-issues push
   ```
   If exit code != 0: HALT. Feature branch push MUST NOT proceed if `issues-data` cannot be pushed.
```

Update `review-prep/push-and-cleanup.md` enforcement checklist accordingly.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/tools/local-issues` | Add `cmd_push()`; add upstream tracking verification in `cmd_setup()` (push path + idempotent exit); add `push` to dispatcher and usage string |
| `.opencode/skills/git-workflow/tasks/pre-work.md` | Add substep 6 to Step 3.7: `local-issues push` after setup |
| `.opencode/skills/git-workflow/tasks/review-prep.md` | Add substep 6 to Step 0: `local-issues push` after auto-commit |
| `.opencode/skills/git-workflow/tasks/review-prep/push-and-cleanup.md` | Add `issues-data` push verification row to enforcement checklist |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `local-issues push` pushes unpushed commits to remote and reports commit count | `behavioral` | Clean-room opencode-cli run with dirty `.issues/` state, verify stderr shows push count |
| SC-2 | `local-issues push` exits 0 with "up to date" when no unpushed commits | `behavioral` | Clean-room run, verify exit 0 + up-to-date message |
| SC-3 | `local-issues push` sets upstream if missing before pushing | `behavioral` | Clean-room run with no upstream, verify tracking restored |
| SC-4 | `local-issues setup` idempotent exit verifies tracking and attempts push if missing | `behavioral` | Clean-room run, remove tracking, re-run setup, verify tracking restored |
| SC-5 | `local-issues setup` first-run push verifies tracking succeeded | `string` | Inspect source for config check after push block |
| SC-6 | `pre-work.md` Step 3.7 has `local-issues push` substep | `string` | grep for `local-issues push` in pre-work.md Step 3.7 |
| SC-7 | `review-prep.md` Step 0 has `local-issues push` substep | `string` | grep for `local-issues push` in review-prep.md Step 0 |
| SC-8 | `push-and-cleanup.md` enforcement checklist has `issues-data` push row | `string` | grep for `issues-data` in enforcement table |
| SC-9 | pre-work agent calls `local-issues push` after setup | `behavioral` | opencode-cli run with pre-work scenario, verify stderr dispatch |
| SC-10 | review-prep agent pushes `issues-data` before feature-branch push | `behavioral` | opencode-cli run with review-prep scenario, verify ordering |

## Phases

### Phase 1: CLI Changes (local-issues tool)

Implements Changes 1 and 2. RED-before-GREEN for SC-1 through SC-5.

### Phase 2: Pipeline Integration (workflow tasks)

Implements Changes 3 and 4. RED-before-GREEN for SC-6 through SC-10.
