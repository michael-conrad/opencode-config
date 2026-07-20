## Summary

Remove all `dev` branch auto-creation logic, `git checkout dev`, `git pull origin dev`, and `origin/dev` references from the codebase. The `dev` branch has been deleted from both repos (opencode-config and .opencode). `main` is now the single trunk.

## Motivation

The `dev` branch was deleted as part of the trunk-based development transition. However, the codebase still contains:
- `_ensure_dev_branch()` in `session-init` that recreates `dev` on every session start (currently disabled with a stub, but still called)
- `git checkout dev` commands in worktree setup, cleanup, pre-work, and pair-mode tasks
- `git pull origin dev` and `git rebase origin/dev` commands in skill task files
- `origin/dev` references in verification checks, squash resets, and diff comparisons
- `dev` branch references in guidelines (115-branch-naming, 116-pair-mode, 000-critical-rules)
- `dev` branch references in hooks (pre-push help text)
- `dev` branch references in README, AGENTS.md, and agent config files
- `dev` branch references in behavioral test prompts and content-verification tests

## Affected Files

### Phase 1: Auto-Creation Logic (CRITICAL — must be removed first)

| File | Change |
|------|--------|
| `.opencode/tools/session-init` | Remove `_ensure_dev_browser()` function entirely; remove call at `run_guard_checks()`; change `git checkout dev` to `git checkout main` in `_setup_main_worktree()` |
| `.opencode/scripts/validate-submodule-refs.sh` | Already updated to `BRANCH="main"` — verify complete |

### Phase 2: Skill Task Files — `git checkout dev` / `git pull origin dev` → `main`

| File | Lines | Change |
|------|-------|--------|
| `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` | 60, 82, 87, 123, 193 | `git checkout dev` → `git checkout main`; `git pull origin dev` → `git pull origin main` |
| `.opencode/skills/git-workflow/tasks/cleanup.md` | 190 | `git checkout dev && git pull origin dev` → `git checkout main && git pull origin main` |
| `.opencode/skills/git-workflow/tasks/check-pr.md` | 54 | Same change |
| `.opencode/skills/git-workflow/tasks/pair-cleanup.md` | 16-17 | Same change |
| `.opencode/skills/git-workflow/tasks/rebase-pending.md` | 76, 92, 111 | `git submodule foreach "git checkout dev && git pull"` → `git submodule foreach "git checkout main && git pull"` |
| `.opencode/skills/git-workflow/tasks/pre-work.md` | 216 | Same submodule foreach change |
| `.opencode/skills/git-workflow/tasks/submodule-sync.md` | 13 | Same change |
| `.opencode/skills/git-workflow/tasks/pr-creation.md` | 5, 11 | "targeting dev branch" → "targeting main branch" |
| `.opencode/skills/git-workflow/tasks/pair-pr-creation.md` | 3, 9, 11 | "targeting dev" → "targeting main"; `git reset --soft origin/dev` → `git reset --soft origin/main` |
| `.opencode/skills/git-workflow/tasks/pair-mode-resume.md` | 18 | `git diff --stat origin/dev..HEAD` → `git diff --stat origin/main..HEAD` |
| `.opencode/skills/git-workflow/tasks/review-prep/push-and-cleanup.md` | 84, 148 | `git rebase origin/dev` → `git rebase origin/main` |
| `.opencode/skills/git-workflow/tasks/review-prep.md` | 58 | `git log origin/dev..HEAD` → `git log origin/main..HEAD` |
| `.opencode/skills/git-workflow/tasks/pr-creation/enforcement-gate.md` | 112, 130 | `git log origin/dev..HEAD` → `git log origin/main..HEAD`; `git reset --soft origin/dev` → `git reset --soft origin/main` |
| `.opencode/skills/git-workflow/tasks/commit-prep.md` | 80 | `git reset --soft origin/dev` → `git reset --soft origin/main` |
| `.opencode/skills/git-workflow/tasks/provenance/dev-push-provenance.md` | 5, 9, 38, 43, 93 | "dev branch" → "main branch"; "dev-push" → "main-push" |
| `.opencode/skills/git-workflow/tasks/provenance/promotion-provenance.md` | 5 | "dev → main" → remove (no promotion needed in trunk-based) |
| `.opencode/skills/finishing-a-development-branch/tasks/prepare.md` | 37, 40, 47, 55 | `git pull origin dev` → `git pull origin main` |
| `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` | 94 | "Local dev branch synced with origin/dev" → "Local main branch synced with origin/main" |
| `.opencode/skills/approval-gate/tasks/pre-impl/write-work-state.md` | 16, 38, 66 | `git rev-parse origin/dev` → `git rev-parse origin/main`; "Dev base hash" → "Main base hash" |
| `.opencode/skills/approval-gate/tasks/post-implementation.md` | 147 | `git log origin/dev..HEAD` → `git log origin/main..HEAD` |
| `.opencode/skills/pr-creation-workflow/tasks/pre-pr-checklist.md` | 33, 36, 65, 163 | `origin/dev` → `origin/main` |

### Phase 3: Guidelines

| File | Change |
|------|--------|
| `.opencode/guidelines/115-branch-naming.md` | Remove all "dev branch" definitions; update to trunk-based model (main only) |
| `.opencode/guidelines/116-pair-mode.md` | Update protected branch references from `['dev', 'main']` to `['main']` |
| `.opencode/guidelines/000-critical-rules.md` | Update "syncs dev" → "syncs main"; update compare URL patterns |
| `.opencode/guidelines/020-go-prohibitions.md` | Update "dev commits" / "dev tip" references |
| `.opencode/guidelines/060-tool-usage.md` | Update "committed directly to dev or main" → "committed directly to main" |

### Phase 4: Hooks, README, AGENTS.md, Agent Configs

| File | Change |
|------|--------|
| `.opencode/hooks/pre-push` | Update help text from `git checkout dev && git pull origin dev` → `git checkout main && git pull origin main` |
| `.opencode/hooks/pre-commit` | Remove `dev` from protected branch list (keep `main` only) |
| `.opencode/AGENTS.md` | Remove "Dev parking" section; update submodule discipline to reference `main` |
| `.opencode/README.md` | Update submodule tracking instructions from `dev` → `main` |
| `README.md` (root) | Update submodule documentation from `dev` → `main` |
| `.opencode/agents/submodule-dev-restore.jsonc` | Rename to `submodule-main-restore.jsonc`; update description |
| `.opencode/agents/submodule-tag-prework.jsonc` | Update "dev tip" → "main tip" |
| `.opencode/agents/submodule-liveness-check.jsonc` | Update "dev HEAD" → "main HEAD" |
| `.opencode/commands/submodule-tag-prework.md` | Update "dev tip" → "main tip" |

### Phase 5: Tests

| File | Change |
|------|--------|
| `.opencode/tests/behaviors/1540-sc1-prework-no-dev-red.sh` | Update test to verify no dev branch auto-creation (currently RED phase) |
| `.opencode/tests/behaviors/submodule-squash-merge-safety.sh` | Update test prompt from "squash-merged into dev" → "squash-merged into main" |
| `.opencode/tests/behaviors/submodule-no-mid-implementation-resync.sh` | Update test prompt from "latest dev" → "latest main" |
| `.opencode/tests/behaviors/submodule-sub-agent-dispatch.sh` | Update test prompt from "dev tip" → "main tip" |
| `.opencode/tests/test-enforcement.sh` | Update scenario descriptions referencing "dev" |
| `.opencode/tests/content-verification/submodule-sub-agent-architecture.sh` | Update sub-agent name references |
| `.opencode/tests/content-verification/submodule-sync-discipline.sh` | Update sub-agent name references |

### Phase 6: SKILL.md Symbolic Rules

| File | Change |
|------|--------|
| `.opencode/skills/git-workflow/SKILL.md` | Update symbolic rules: `push_target == 'dev'` → `push_target == 'main'`; "dev tips" → "main tips"; "submodule_dev_restored" → "submodule_main_restored" |
| `.opencode/skills/git-workflow/SKILL.md` | Update sub-agent names: `submodule-dev-restore` → `submodule-main-restore` |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `session-init` no longer calls `_ensure_dev_branch()` or references `dev` | `string` | grep for `_ensure_dev_branch` and `"dev"` in session-init |
| SC-2 | No `git checkout dev` commands remain in any skill task file | `string` | grep for `checkout.*dev` in `.opencode/skills/` |
| SC-3 | No `git pull origin dev` commands remain in any skill task file | `string` | grep for `pull.*origin.*dev` in `.opencode/skills/` |
| SC-4 | No `origin/dev` references remain in any skill task file | `string` | grep for `origin/dev` in `.opencode/skills/` |
| SC-5 | No `dev` branch references remain in guidelines (115, 116, 000, 020, 060) | `string` | grep for `"dev"` in `.opencode/guidelines/` — only false positives allowed |
| SC-6 | `pre-push` hook help text references `main` not `dev` | `string` | grep for `dev` in `.opencode/hooks/pre-push` |
| SC-7 | `pre-commit` hook protected branch list excludes `dev` | `string` | grep for `dev` in `.opencode/hooks/pre-commit` |
| SC-8 | `AGENTS.md` and `README.md` no longer reference `dev` branch | `string` | grep for `dev` in `AGENTS.md` and `README.md` |
| SC-9 | Submodule agent configs reference `main` not `dev` | `string` | grep for `dev` in `.opencode/agents/*.jsonc` |
| SC-10 | Behavioral test: `session-init` does NOT create `dev` branch on session start | `behavioral` | `opencode-cli run` with prompt triggering session-init; verify no `dev` ref created |
| SC-11 | All `origin/dev` references in test files updated to `origin/main` | `string` | grep for `origin/dev` in `.opencode/tests/` |

## Risk and Edge Cases

| Risk | Impact | Mitigation |
|------|--------|------------|
| Missed `dev` reference in a skill task file | Agent tries to checkout/pull from non-existent `dev` branch → git error | Comprehensive grep sweep across all files; behavioral test for session-init |
| `pre-commit` hook still blocks `dev` | No impact (dev doesn't exist) | Remove `dev` from protected list to avoid confusion |
| Behavioral tests reference `dev` in prompts | Test may fail if agent tries to interact with non-existent branch | Update all test prompts to reference `main` |
| `submodule-dev-restore` agent still referenced | Agent tries to dispatch non-existent sub-agent | Rename to `submodule-main-restore` and update all references |

## Dependencies

- Phase 1 MUST complete before any other phase (auto-creation logic is the most critical)
- Phases 2-6 are independent and MAY be developed in parallel
- Phase 5 (tests) MUST complete before PR creation

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)