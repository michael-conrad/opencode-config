## Problem

The `pre-commit` and `pre-push` hooks (both templates in `.opencode/hooks/` and installed copies in `.git/hooks/`) use the mandated walk-up-to-`.opencode` pattern for project root detection. But hooks execute from `.git/hooks/`, which is OUTSIDE the `.opencode/` tree. The loop walks up to `/`, where `dirname "/"` returns `"/"`, so the loop never terminates — causing `git commit` and `git push` to hang indefinitely (timeout).

## Root Cause

The walk-up pattern is canonically correct for all scripts that live inside `.opencode/` (tools, tests, scripts). But hooks are structurally different: they execute from `.git/hooks/`, so `BASH_SOURCE[0]` resolves outside `.opencode/` and the walk-up is guaranteed to overshoot.

Additionally, hooks are repo-scoped by definition: a hook in `.git/hooks/` only fires for the repo it is installed in. `git rev-parse --show-toplevel` in a hook context correctly returns the repo root — it does NOT have the submodule-wrong-root problem that affects tools running across repo boundaries.

## Acceptance Criteria

1. `.opencode/hooks/pre-commit` uses `git rev-parse --show-toplevel` for project root detection (not walk-up loop)
2. `.opencode/hooks/pre-push` uses `git rev-parse --show-toplevel` for project root detection (not walk-up loop)
3. All other hooks (pre-merge-commit, prepare-commit-msg, post-commit) verified to not have the same issue (note: these three hooks do NOT use walk-up — they only use `git branch --show-current` for branch checking, no root detection, so they are unaffected)
4. Guideline `210-scripting.md` updated to add a "Hooks Exception" section that explicitly permits `git rev-parse --show-toplevel` for hook files only
5. Issue #249 (unified root detection spec) updated to record hooks as a deliberate carve-out
6. Behavioral enforcement test added to verify agent applies hook exception properly (does not mistakenly use walk-up in hook files)

## Affected Files

**Broken (need fix):**
- `.opencode/hooks/pre-commit` — line 91-95: walk-up loop, no root-guard, will hang at `/`
- `.opencode/hooks/pre-push` — line 56-60: same loop, same bug

**Unaffected (no root detection needed):**
- `pre-merge-commit` — only uses `git branch --show-current`, no root detection
- `prepare-commit-msg` — only uses `git branch --show-current`, no root detection
- `post-commit` — only uses `git branch --show-current`, no root detection

**Guideline/doc updates:**
- `.opencode/guidelines/210-scripting.md` — add hooks exception section
- `.opencode/.issues/open/007-unified-root-detection-walk-up/spec.md` — record carve-out

## Fix Approach

Replace the walk-up loop in both hook files with:
```bash
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
```

This is correct for hooks because:
1. Hooks are repo-scoped — they only fire for the repo the commit/push targets
2. In submodule context, `--show-toplevel` correctly returns the submodule root (which IS the project for files being committed there)
3. No risk of parent/super-project confusion because hooks do not cross repo boundaries
4. Prevents the infinite loop at filesystem root

## Non-Goal

- Do NOT change the walk-up pattern for non-hook scripts
- Do NOT add `--show-toplevel` as an allowed alternative anywhere else
- The hooks exception is narrow: one class of file, one specific reason

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-pro)