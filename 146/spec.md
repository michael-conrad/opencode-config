## Problem

The Dispatch Chain Structural Enforcement Gate (issue #767, PR #768) only fires when task files are loaded through proper `skill() → task()` dispatch. The chronic orchestrator inline bypass pattern — running git operations directly instead of routing through `task()` — prevents the gate from loading at all. The existing pre-commit Gate 3 blocks `.opencode/*` file changes on certain branches, but does not block commits where ALL staged changes are submodule pointer updates (e.g., `.opencode` gitlink SHA change) regardless of branch or author.

A pre-commit hook is the only enforcement point that cannot be bypassed by inline work, because git hooks fire on every commit regardless of who or what initiated the commit.

## Proposed Solution

Add **Gate 4** to `.opencode/hooks/pre-commit` that blocks any commit where the ONLY staged files are submodule pointer entries (exact path match to `git submodule status` output paths).

Key design properties:
- **Content-based, not branch-name-based**: No branch name matching. The check is substrate-determined — it inspects what files are staged, not what branch the commit is on.
- **Submodule-path-based, not hardcoded**: Reads submodule paths dynamically from `git submodule status | awk '{print $2}'`. No hardcoded paths.
- **Exact path match only**: A file is a "submodule pointer" only if it EXACTLY matches a submodule path from `git submodule status`. Files *inside* a submodule (`.opencode/something`) are NOT submodule pointers — they are regular file changes that pass through.
- **No exemption for any branch or author**: Every commit, every branch, every author. If ALL staged files are submodule pointers, the commit is blocked.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Pre-commit hook blocks commit where only staged change is a submodule pointer | `behavioral` | Stage `.opencode` SHA change, attempt commit → commit blocked with Gate 4 error message |
| SC-2 | Pre-commit hook allows commit where staged changes include any non-submodule-pointer file | `behavioral` | Stage a regular file change alongside submodule pointer → commit proceeds |
| SC-3 | Gate 4 error message lists the actual changed submodule paths from `git diff --cached --name-only` | `string` | Inspect Gate 4 output — shows dynamic file list, no hardcoded values |
| SC-4 | Gate 4 reads submodule paths from `git submodule status`, not hardcoded values | `structural` | Check hook source — no hardcoded submodule paths |
| SC-5 | Gate 4 fires on ALL branches, including `pair-*`, `rollback/*`, `hotfix/*` | `behavioral` | On any branch, stage only submodule pointer → commit blocked |
| SC-6 | Gate 4 does NOT fire on repos without `.gitmodules` | `behavioral` | In single-repo context (no submodules), any commit proceeds normally |

## Evidence Type Note

SC-1, SC-2, SC-5, SC-6 are behavioral because they test runtime behavior of the pre-commit hook (does the hook block or allow a commit?). SC-3 is `string` because it tests output message content. SC-4 is `structural` because it tests code structure.

## Affected Files

| File | Change Type | Description |
|------|-------------|-------------|
| `.opencode/hooks/pre-commit` | Modify | Add Gate 4 after Gate 3, update GATE_NAMES array |

## Cross-References

- Issue #767: Dispatch Chain Structural Enforcement Gate (exists in `.opencode` repo — the gate that only fires through proper dispatch)
- `020-go-prohibitions.md:156` — Tier 1 submodule-only PR prohibition
- `000-critical-rules.md:1537` — symbolic rule critical-rules-049 (Tier 2, conflicting with 020-go-prohibitions.md prose)
- `git-workflow/tasks/cleanup/branch-cleanup.md:131` — submodule-only PR forbidden pattern
- `git-workflow/tasks/cleanup/branch-cleanup.md:256` — submodule-only PR prohibition detail

CLOSED: Wrong repo — pre-commit hook is in `.opencode` submodule repo, not `opencode-config`.
