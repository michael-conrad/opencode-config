# Synced from GitHub Issue #27 at 2026-05-02T00:00:00Z

**Status: SPEC-FIX — awaiting approval**

## Problem

The `pre-commit` and `pre-push` hooks (both templates in `.opencode/hooks/` and installed copies in `.git/hooks/`) use the mandated walk-up-to-`.opencode` pattern for project root detection. But hooks execute from `.git/hooks/`, which is OUTSIDE the `.opencode/` tree. The loop walks up to `/`, where `dirname "/"` returns `"/"`, so the loop never terminates — causing `git commit` and `git push` to hang indefinitely (timeout).

## Root Cause

The walk-up pattern is canonically correct for all scripts that live inside `.opencode/` (tools, tests, scripts). But hooks are structurally different: they execute from `.git/hooks/`, so `BASH_SOURCE[0]` resolves outside `.opencode/` and the walk-up is guaranteed to overshoot.

Additionally, hooks are repo-scoped by definition: a hook in `.git/hooks/` only fires for the repo it is installed in. `git rev-parse --show-toplevel` in a hook context correctly returns the repo root — it does NOT have the submodule-wrong-root problem that affects tools running across repo boundaries.

## Acceptance Criteria

1. `.opencode/hooks/pre-commit` uses `git rev-parse --show-toplevel` for project root detection
2. `.opencode/hooks/pre-push` uses `git rev-parse --show-toplevel` for project root detection
3. All other hooks verified unaffected
4. Guideline `210-scripting.md` updated with "Hooks Exception" section
5. Issue #249 updated to record hooks as deliberate carve-out
6. Behavioral enforcement test added
