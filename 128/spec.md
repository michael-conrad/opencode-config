## Summary

`local-issues setup` has no detection for the stale worktree state (where `issues-data` branch has a worktree at a wrong path like `.worktrees/main/.issues/` instead of at `.issues/`). When run in this state it fails silently or corrupts state. Fix: detect stale worktrees, emit a detailed human-readable report, exit code 2, and let the AI agent orchestrate remediation — never auto-repair.

## Background

The current `cmd_setup()` idempotency check (lines 625–641) only matches if the worktree is at the exact `.issues/` path. If `issues-data` branch has a worktree at `.worktrees/main/.issues/` (as was created experimentally), the check falls through, the script renames the plain `.issues/` directory to `.issues.bak`, then fails at `git worktree add .issues issues-data` because the branch already has a worktree checkout. The caller gets a confusing error and `.issues/` is gone.

The fix must not add machine-parseable error codes or auto-repair — the AI agent handles remediation intelligently (removing the stale worktree, re-running setup, migrating content). The script reports the state; the agent orchestrates the fix.

## Scope

### Repos Affected

| Repo | Changes |
|------|---------|
| `michael-conrad/.opencode` (`./.opencode/`) | `tools/local-issues` — stale worktree detection + exit code 2 report |
| `michael-conrad/opencode-config` (`./`) | `git-workflow/tasks/pre-work.md` Step 3.7 — handle exit code 2 remediation flow |

### What the Script Does (local-issues setup)

**Detection** (after idempotency check fails to find a worktree at `.issues/`):

- Scan `git worktree list` output for ANY worktree where `parts[2] == issues-data` (the branch name)
- If found and `os.path.normpath(parts[0]) != os.path.normpath(issues_path)`:
  - The `issues-data` branch has a stale worktree at a wrong path
  - Emit a structured human-readable report (see below)
  - Do NOT rename `.issues/` to `.issues.bak`
  - Do NOT attempt `git worktree add`
  - Exit code 2

**The stale report** must include:

```
Stale issues-data worktree detected at: {WRONG_PATH}
The .issues/ directory MUST be a git worktree on the issues-data branch,
but the branch is currently checked out at a different path.

To remediate:
  1. git worktree remove {WRONG_PATH}
     (This removes the linked worktree. The issues-data branch commits
      are preserved — no data loss.)
  2. Re-run: local-issues setup
     (Creates the .issues/ worktree at the correct path, migrates any
      existing .issues/ content, adds /.issues/ to .gitignore.)

Pending untracked files in .issues/ are preserved through the .bak
rename cycle (setup renames .issues/ → .issues.bak before creating
the worktree, then migrates content back).
```

**What the script does NOT do:**
- No `--repair` flag
- No auto-remediation
- No auto `git worktree remove`

### AI Agent Remediation Flow (pre-work.md Step 3.7 update)

When `local-issues setup` exits code 2:

1. Read the report from stderr/stdout
2. `git worktree remove <STALE_PATH>` to remove the stale worktree
3. Re-run `local-issues setup` — should succeed this time
4. Verify `.issues/` is now a worktree on `issues-data` at the correct path
5. **Intelligent migration**: After setup, examine the actual `.issues/` files on `dev` (both tracked and untracked) and ensure they are properly represented on `issues-data`:
   - Tracked `.issues/` files on `dev` → migrate to `issues-data` branch via intelligent copy (read each file, write into the worktree, commit)
   - Untracked `.issues/` directories → same treatment
   - After migration, `git rm --cached` the tracked `.issues/` files from `dev` and commit the removal
   - The agent reads actual files rather than relying on script migration, which handles edge cases (file format differences, nested structures, unexpected content) without script brittleness
6. Remove `.issues.bak` if it exists from the setup cycle
7. Resume the original calling task

### Pre-existing Issues-data Content

The `issues-data` branch currently has content (open/001 through open/005 on the worktree at `.worktrees/main/.issues/`). The AI agent must decide how to handle this:
- Option A: Preserve existing `issues-data` branch content and merge local issues into it
- Option B: Recreate `issues-data` branch fresh and re-import everything from `dev`

The agent makes this call based on content inspection — not the script.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `local-issues setup` detects stale `issues-data` worktree at wrong path | `behavioral` | Run setup when `issues-data` worktree at wrong path → exit 2 + stale report in output |
| SC-2 | Stale report includes wrong path, remediation steps, and preservation guarantee | `string` | grep for "Stale issues-data worktree detected at:" in script |
| SC-3 | Script does NOT rename `.issues/` or attempt `git worktree add` when stale state detected | `string` | grep for absence of rename and worktree add paths after stale detection branch |
| SC-4 | Script exits 0 for normal (idempotent, already set up) | `behavioral` | Run setup when properly configured → exit 0 |
| SC-5 | Script exits 0 for fresh setup | `behavioral` | Run setup on clean repo → exit 0 with worktree created |
| SC-6 | pre-work.md Step 3.7 documents exit code 2 remediation flow | `string` | grep for exit code 2 handling in pre-work.md |
| SC-7 | AI agent orchestration preserves untracked `.issues/` files | `behavioral` | Simulate stale state → agent remediates → verify all original `.issues/` files present post-migration |
| SC-8 | `issues-data` branch content preserved OR merged intelligently — not discarded | `behavioral` | Agent remediates stale state → verify `issues-data` branch still has prior commits and content |
| SC-9 | Callers (sync-pull-to-local, import-remote) also handle exit code 2 | `string` | grep for exit code 2 handling in both task files |

## Implementation Notes

- Exit code convention: `0 = ok/setup complete`, `1 = error (fatal, retry won't help)`, `2 = blocked (stale state, intelligent correction needed before retry)`
- The stale detection is a new section added between the idempotency check and the Phase 1 backup — inserted as the first action after falling through the idempotency loop
- No changes to `local-issues` argument parser needed — the detection is internal to `cmd_setup()`
- `.gitignore` update (adding `/.issues/`) is handled by the existing code path in setup — no change needed there
- The `local-issues` script lives in the `.opencode` submodule; pre-work.md lives in the parent repo. The PR for the `.opencode` submodule changes targets its own `dev` branch, then a parent repo PR updates the submodule pointer

## Cross-References

- `local-issues` script: `.opencode/tools/local-issues` lines 609–755 (`cmd_setup`)
- `git-workflow/tasks/pre-work.md` lines 278–286 (Step 3.7)
- `issue-operations/tasks/sync-pull-to-local.md` line 26 (`local-issues setup` call)
- `issue-operations/tasks/import-remote.md` (Step 1 — `local-issues setup` call)
