## Summary

Remove all branch-status-based session triggers that cause AI agent malfunctions — they pressure agents into unnecessary git actions, create context noise, and lead to bypassing mandatory workflows. These triggers fire on branch state (on dev, on main, stale submodule) at session start and per-turn, driving agents to create submodule-bump commits, suggest pair mode inappropriately, and waste context on non-actionable warnings.

## Root Cause

The `session_context_triggers.py` script and `session-enforcement.ts` plugin inject five branch-status triggers into the agent's context at session start and after every assistant turn:

1. `on_main_branch` — warns about being on main, suggests pair mode
2. `protected_branch_with_changes` — warns about edits on dev, suggests pair mode
3. `dev_branch_with_changes` — warns about edits on dev without worktree/pair-mode
4. `uncommitted_work_warning` — warns about uncommitted changes on non-protected branches
5. `stale_submodule` — tells agent to auto-bump submodule SHA

These create a feedback loop: trigger fires → agent feels pressure to "fix" the state → creates unnecessary commits/branches/PRs → violates rules against submodule-bump-only PRs. The stale_submodule trigger additionally drives agents to create submodule-bump commits on `dev` (which are blocked by hooks) and then create feature branches just to get around the block.

Additionally, the per-turn protected branch edit guard in `session-enforcement.ts` fires after every assistant turn, injecting `### Session Triggers / protected_branch_with_changes` into the conversation whenever uncommitted changes exist on a protected branch. This creates constant noise and pressures agents to "resolve" the dirty state.

## Files Removed/Modified

### `.opencode/scripts/session_context_triggers.py`

**Remove functions (dead code after purge):**

| Function | Lines | Reason |
|----------|-------|--------|
| `get_remote_url()` | 50-51 | Never called anywhere |
| `is_on_main_branch()` | 65-67 | Only called by removed branch-status code |
| `is_on_protected_branch()` | 70-72 | Only called by removed branch-status code |
| `get_diff_summary()` | 75-108 | Only called by removed warning builders |
| `has_uncommitted_changes()` | 146-151 | Only called by removed branch-status code |
| `is_pair_mode_branch()` | 154-158 | STAYS — used by `build_pair_mode_resume()` |
| `build_main_branch_warning()` | 249-276 | Branch status trigger |
| `build_protected_branch_warning()` | 279-303 | Branch status trigger |
| `build_dev_branch_with_changes_warning()` | 521-548 | Branch status trigger |
| `build_uncommitted_work_warning()` | 326-332 | Source of confusion |
| `has_stale_submodules()` | 474-504 | Stale submodule trigger |
| `build_stale_submodule_warning()` | 507-518 | Stale submodule trigger |

**Edit `main()`:** Remove branch status collection (lines 572-583), uncommitted work warning (lines 589-590), and stale submodule call (lines 608-610).

### `.opencode/plugins/session-enforcement.ts`

**Remove functions:**

| Function | Lines | Reason |
|----------|-------|--------|
| `buildProtectedBranchEditTrigger()` | 769-778 | Per-turn noise maker |
| `detectUncommittedFileChanges()` | 784-798 | Only called by per-turn guard |
| `isProtectedBranch()` | 822-824 | Only called by per-turn guard |

**Remove per-turn guard block:** Lines 1243-1261

**Keep:** `getCurrentBranch()` and `isPairModeBranch()` — used by inline work detector (lines 1150-1151)

### `.opencode/guidelines/117-session-trigger-behavior.md`

| Section | Action |
|---------|--------|
| Trigger Behavior Map table: `protected_branch_with_changes` row | Remove |
| Trigger Behavior Map table: `on_main_branch` row | Remove |
| Trigger Behavior Map table: `stale_submodule` row | Remove |
| `## Diff Analysis Requirement` section | Remove entirely |
| `## Pair Mode Suggestion Protocol` section | Remove entirely — triggers that drove it are gone |
| No-Echo Rule example: "Protected Branch with Uncommitted Changes" | Remove or update |
| Suppression rule: visible trigger list | Update to `['stale_stash', 'pair_mode_resume']` |
| yaml+symbolic: `session-trigger-002` | Remove |
| yaml+symbolic: `session-trigger-003` | Remove |
| yaml+symbolic: `session-trigger-005` suppression rule list | Update to `['stale_stash', 'pair_mode_resume']` |
| yaml+symbolic: `session-trigger-006` | Remove |

### `.opencode/tools/impl/skildeck/skill-registry-v2-guidelines.json`

Remove `session-trigger-002`, `session-trigger-003`, and `session-trigger-006` entries. Update `session-trigger-005` suppression rule list.

## Remaining Triggers (Unchanged)

- `pair_mode_resume` — stays, first turn only
- `stale_stash` — stays
- `merge_conflict` — stays
- `unpushed_commits` — stays
- `orphaned_worktrees` — stays
- `check_prs_intent` — stays
- `nested_opencode` — stays
- `local_only_repo` — stays

## Success Criteria

| SC | Description | Verification |
|----|-------------|--------------|
| SC-1 | `session_context_triggers.py` no longer contains `build_main_branch_warning`, `build_protected_branch_warning`, `build_dev_branch_with_changes_warning`, `build_uncommitted_work_warning`, `build_stale_submodule_warning`, `has_stale_submodules`, `get_diff_summary`, `is_on_main_branch`, `is_on_protected_branch`, `has_uncommitted_changes`, or `get_remote_url` | Content verification — grep for removed function names |
| SC-2 | `session_context_triggers.py` `main()` no longer collects branch status triggers or stale submodule data — lines 572-583, 589-590, 608-610 removed | Content verification — read main() function |
| SC-3 | `session_context_triggers.py` still contains `build_pair_mode_resume()`, `is_pair_mode_branch()`, and `get_current_branch()` | Content verification — grep for kept functions |
| SC-4 | `session-enforcement.ts` no longer contains `buildProtectedBranchEditTrigger`, `detectUncommittedFileChanges`, or `isProtectedBranch` | Content verification — grep for removed function names |
| SC-5 | `session-enforcement.ts` per-turn guard block (lines 1243-1261) is removed | Content verification — read plugin file |
| SC-6 | `session-enforcement.ts` still contains `getCurrentBranch()` and `isPairModeBranch()` — used by inline work detector | Content verification — grep for kept functions |
| SC-7 | `117-session-trigger-behavior.md` no longer references `protected_branch_with_changes`, `on_main_branch`, or `stale_submodule` in trigger behavior table | Content verification — grep for removed trigger names in table |
| SC-8 | `117-session-trigger-behavior.md` no longer has `## Diff Analysis Requirement` or `## Pair Mode Suggestion Protocol` sections | Content verification — grep for removed section headings |
| SC-9 | `117-session-trigger-behavior.md` suppression rule yaml+symbolic rule `session-trigger-005` updated to exclude only `['stale_stash', 'pair_mode_resume']` | Content verification — read yaml+symbolic section |
| SC-10 | `skill-registry-v2-guidelines.json` no longer contains `session-trigger-002`, `session-trigger-003`, or `session-trigger-006` entries | Content verification — grep for removed IDs |
| SC-11 | `skill-registry-v2-guidelines.json` `session-trigger-005` suppression rule updated | Content verification — read entry |
| SC-12 | No references to `session-trigger-002`, `session-trigger-003`, or `session-trigger-006` remain in `skill-registry-v2-guidelines.json` | Content verification — grep for removed IDs |
| SC-13 | `session-enforcement.ts` inline work detector (lines 1146-1204) still functions — `getCurrentBranch()` and `isPairModeBranch()` kept | Behavioral test — edit on non-pair branch triggers inline work warning |
| SC-14 | `session_context_triggers.py` still emits `pair_mode_resume`, `stale_stash`, `merge_conflict`, `unpushed_commits`, `orphaned_worktrees` triggers | Behavioral test — session start with stale stash or pair-mode branch |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
