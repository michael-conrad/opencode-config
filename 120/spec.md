## Problem Statement

Two related problems prevent `.issues/` worktree setup from working correctly:

**Problem 1: Main repo `.issues/` is a tracked directory on `dev`, not a worktree.**
The `opencode-config` parent repo's `.issues/` directory is a regular tracked directory on the `dev` branch (verified by: no `.git` file, `git ls-files` shows 16+ tracked files, `.gitignore` has no `.issues/` entry). The `local-issues setup` command was designed to handle this migration (renames to `.issues.bak`, creates worktree, migrates content), but it was never run in the main repo. Consequence: `.issues/` content gets committed to `dev`, polluting the main branch with issue-tracking data that belongs on `issues-data`.

**Problem 2: New worktrees don't get `.issues/` autosetup.**
When `using-git-worktrees create-worktree` creates a new worktree (e.g., `.worktrees/feature-123/`), it does NOT call `local-issues setup`. The `local-issues setup` call exists only in `git-workflow/tasks/pre-work.md` Step 3.7 — which runs AFTER branch creation, and only when a full pre-work flow is executed. If a worktree is created without going through pre-work (e.g., manual creation, or the `create-worktree` task), the `.issues/` worktree is never initialized in that worktree. The worktree at `.worktrees/main/.issues/` only has a worktree because I manually ran `local-issues setup` during this investigation.

## Root Cause

1. **Main repo migration gap:** `local-issues setup` was added to the submodule repo (`.opencode`) but never run in the parent repo (`opencode-config`). The `_setup_parent_worktree()` function exists in `local-issues` (lines 900-981) but is only invoked via the `--parent` flag, which is not called from any automated workflow.

2. **Worktree creation gap:** The `create-worktree` task (`using-git-worktrees/tasks/create-worktree.md`) has NO step calling `local-issues setup`. It only runs `uv sync` (Step 6) and `pytest` (Step 7). The `pre-work.md` Step 3.7 does call `local-issues setup`, but create-worktree is a separate workflow that doesn't go through pre-work.

3. **Session-init gap:** The `session-init` tool and `session_context_triggers.py` do NOT detect whether `.issues/` is properly set up as a worktree, so there's no automated check at session start.

## Proposed Solution

### Phase 1: Migrate main repo `.issues/` to worktree

- Run `local-issues setup --migrate` in the main repo to convert the tracked `.issues/` directory to an `issues-data` worktree
- Add `/.issues/` to the parent repo's `.gitignore` (the `local-issues setup` script does this automatically)
- Commit the `.gitignore` change and removal of tracked `.issues/` files from `dev`

### Phase 2: Add `local-issues setup` to `create-worktree` task

- Add a new step to `using-git-worktrees/tasks/create-worktree.md` between Step 6 (project setup) and Step 7 (verify tests) that runs `local-issues setup` in the new worktree
- This ensures every new worktree gets `.issues/` initialized automatically
- The call is idempotent — if `.issues/` is already a worktree, it exits cleanly

### Phase 3: Add `.issues/` worktree check to session-init or session context triggers

- Add a check to `session_context_triggers.py` that detects when `.issues/` is NOT a worktree (no `.git` file inside `.issues/`)
- Emit a trigger warning so the agent can respond appropriately at session start
- This provides a safety net: if worktree creation somehow skips `.issues/` setup, the agent knows

## Success Criteria

| SC | Criterion | Verification |
|----|-----------|-------------|
| SC-1 | Running `local-issues setup --migrate` in the main repo converts `.issues/` from a tracked directory on `dev` to a worktree on `issues-data`, with all existing content migrated | Behavioral: `local-issues setup --migrate` exits 0; `cat .issues/.git` shows worktree pointer; `git ls-files .issues/` returns empty; `git -C .issues rev-parse --abbrev-ref HEAD` returns `issues-data` |
| SC-2 | `.gitignore` in the parent repo contains `/.issues/` after migration | Verification: `grep -c '\.issues' .gitignore` ≥ 1 |
| SC-3 | `create-worktree` task calls `local-issues setup` as a mandatory step after project setup | Behavioral: new worktree created via create-worktree has `.issues/` as a worktree after the task completes |
| SC-4 | `local-issues setup` is idempotent in worktree context — re-running it on an already-set-up worktree exits 0 with "Idempotent" message | Behavioral: run `local-issues setup` twice in a worktree; second run exits 0 with idempotent message |
| SC-5 | Session context trigger detects missing `.issues/` worktree at session start | Behavioral: when `.issues/` is not a worktree, session trigger emits warning; when `.issues/` is a proper worktree, no warning |
| SC-6 | Phase 1 migration preserves all existing `.issues/` content (spec files, state files, counter, closed/ directory structure) | Behavioral: `diff` between pre-migration `.issues.bak/` content and post-migration `.issues/` content shows no data loss |

## Affected Files

| File | Change Type | Description |
|------|-------------|-------------|
| `.opencode/skills/using-git-worktrees/tasks/create-worktree.md` | Modify | Add Step 6.5: `local-issues setup` call after project setup |
| `.opencode/scripts/session_context_triggers.py` | Modify | Add `.issues/` worktree check to session triggers |
| `.opencode/tools/local-issues` | Modify (potentially) | Any needed fixes for parent repo migration from worktree context |
| `.gitignore` (parent repo) | Modify | Add `/.issues/` entry |
| `.issues/` (parent repo) | Restructure | Migrate from tracked directory to worktree |

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|-------|------------|
| Migration corrupts `.issues/` data | Low | High | `local-issues setup` backs up to `.issues.bak` before migration; verify with SC-6 diff |
| Worktree creation adds latency | Low | Low | `local-issues setup` is idempotent and fast (~1s if already set up) |
| `issues-data` branch doesn't exist in new worktree context | Medium | Medium | `local-issues setup` creates the orphan branch if missing |
| Session trigger false positives (`.issues/` exists but not as worktree) | Low | Low | Trigger only warns — doesn't block operations |
| Parent repo submodule relationship complicates worktree | Medium | High | `local-issues setup --parent` handles submodule context; needs testing in both parent and submodule contexts |

## Phases

- **Phase 1:** Migrate main repo `.issues/` to worktree (manual one-time operation)
- **Phase 2:** Add `local-issues setup` to `create-worktree` task (code change to skill)
- **Phase 3:** Add session trigger for `.issues/` worktree check (code change to session triggers)

## Cross-References

- Closed spec-fix: https://github.com/michael-conrad/.opencode/issues/698
- Closed Phase 1: https://github.com/michael-conrad/.opencode/issues/774
- Closed Phase 2: https://github.com/michael-conrad/.opencode/issues/776
- `local-issues` tool: `.opencode/tools/local-issues` → `cmd_setup()` (line 609) and `_setup_parent_worktree()` (line 900)
- Pre-work task: `.opencode/skills/git-workflow/tasks/pre-work.md` Step 3.7
- Create-worktree task: `.opencode/skills/using-git-worktrees/tasks/create-worktree.md`
- Session context triggers: `.opencode/scripts/session_context_triggers.py`

🤖 OpenCode (ollama-cloud/glm-5.1) created