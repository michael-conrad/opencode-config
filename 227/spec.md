## Problem

`local-issues list` and `local-issues search` print `spec_path=.issues` for every issue, instead of the correct per-issue path like `spec_path=.issues/1437`.

## Root Cause

In `_search_in_repo()` (line ~1319) and `_list_issues_in_repo()` (line ~1392), `spec_path` is computed **once per repo** pointing to the `.issues/` directory itself, then reused for every issue in that repo. The correct behavior (used by `read`, `read-comments`, etc.) computes `spec_path` per-issue via `_spec_path_for_issue()` which calls `_find_issue_dir_in_repo()`.

## Affected Code

**File:** `.opencode/tools/local-issues`

| Function | Lines | Behavior | Status |
|----------|-------|----------|--------|
| `_spec_path_for_issue()` | 1075-1083 | Resolves per-issue path correctly | ✅ Correct |
| `_search_in_repo()` | 1312-1342 | Computes `spec_path` once at `.issues/` level | ❌ Bug |
| `_list_issues_in_repo()` | 1386-1407 | Computes `spec_path` once at `.issues/` level | ❌ Bug |

## Fix

In both `_search_in_repo()` and `_list_issues_in_repo()`, move the `spec_path` computation inside the per-issue loop, using `_find_issue_dir_in_repo(num, repo_path)` to resolve the per-issue directory — the same approach used by `_spec_path_for_issue()`.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|----------|---------------|---------------------|
| SC-1 | `local-issues list` prints `spec_path=.issues/N` (not `.issues`) for each issue | `behavioral` | Run `local-issues list` and inspect output |
| SC-2 | `local-issues search` prints `spec_path=.issues/N` (not `.issues`) for each result | `behavioral` | Run `local-issues search <term>` and inspect output |
| SC-3 | `local-issues read` continues to print correct `spec_path=.issues/N` | `behavioral` | Run `local-issues read N` and inspect output |
| SC-4 | No regression in other commands that use `_spec_path_for_issue()` | `string` | grep for all callers of `_spec_path_for_issue()` and `_find_issue_dir_in_repo()` |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
