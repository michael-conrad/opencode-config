## Problem

The pre-push hook (`opencode-config/.git/hooks/pre-push`) fails silently on branches whose name does not contain a numeric segment immediately after the first `/`. The hook has `set -e` at line 7, and line 143 runs:

```bash
ISSUE_NUM=$(echo "$LOCAL_BRANCH" | grep -oP '^\w+/\K\d+')
```

When the branch is `feature/update-submodule-pointer-1718-1709`, the regex `^\w+/\K\d+` expects digits immediately after the first `/`, but the branch has `update-submodule-pointer-1718-1709` which starts with letters. `grep` exits 1 (no match), and `set -e` kills the entire script before any `echo` output reaches stderr.

**Impact:** The hook blocks pushes with zero diagnostic output. The user sees only `error: failed to push some refs to 'github.com:michael-conrad/opencode-config.git'` with no explanation.

## Root Cause

Two compounding defects:

1. **`set -e` at line 7** — Any command that exits non-zero kills the script silently. The hook has multiple `grep` calls that can fail on unexpected input.
2. **`grep -oP '^\w+/\K\d+'` at line 143** — Only matches branches where the segment after the first `/` starts with digits (e.g., `feature/123-name`). Fails on `feature/update-submodule-pointer-1718-1709` where the segment starts with letters.

## Fix

1. Remove `set -e` and add explicit error handling (`|| true` guards) on commands that can legitimately fail
2. Update the regex at line 143 to extract the first numeric sequence anywhere in the branch name, not just immediately after the first `/`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `set -e` removed from pre-push hook | `string` | grep for `set -e` in `.git/hooks/pre-push` — must return no match |
| SC-2 | grep at line 143 has `|| true` guard or equivalent | `string` | grep for `grep -oP` in `.git/hooks/pre-push` — must show `|| true` or error handling |
| SC-3 | Regex extracts issue number from `feature/update-submodule-pointer-1718-1709` | `string` | `echo "feature/update-submodule-pointer-1718-1709" \| grep -oP '\d+' \| head -1` returns `1718` |
| SC-4 | Hook outputs BLOCKED message on submodule-pointer-only push for branches without numeric issue segment | `behavioral` | Simulate push with branch `feature/no-issue-branch` — stderr must contain "BLOCKED" message |

## Files Affected

- `opencode-config/.git/hooks/pre-push` — Fix `set -e` and regex

## Change Control

- **Status**: DRAFT
- **Version**: 1
- **Created**: 2026-07-07
