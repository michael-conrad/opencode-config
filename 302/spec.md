## Executive Summary

`env-loader.ts` runs 3 git commands (`branch --show-current`, `remote get-url origin`, `config user.email`) on every `shell.env` hook invocation — i.e., every single bash tool call. The data is already available in LLM context via `session-init` (`github.owner`, `github.repo`, `branch`, `dev.name`, `dev.email`). The bash-level consumers that reference these env vars should run git commands on-demand instead of paying the cost on every turn.

Remove the git commands and their infrastructure from `env-loader.ts`, and update the 3 consumer task files to fetch the data on-demand.

## Problem

- 3 git commands run on every bash invocation via `shell.env` hook
- Data is static (doesn't change mid-session) but fetched every turn
- Same data already available in LLM context via `session-init`
- `$.nothrow()` prints to console (the original complaint)

## Scope

### Remove from `env-loader.ts`

- `GIT_FALLBACK_PATHS` constant (lines 29-33)
- `resolveGitPath()` function (lines 35-54)
- `GIT_CMD_TIMEOUT_MS` constant (line 289)
- `gitCmd()` function (lines 292-311)
- The entire try block that calls git commands (lines 313-367)
- `execSync` import (line 25) — no longer needed

### Update consumers

| File | Env Vars Used | Replace With |
|------|--------------|--------------|
| `completion-core/completion-core.md` | `GIT_OWNER`, `GIT_REPO`, `GITHUB_HTML_URL`, `GITBUCKET_HTML_URL` | Inline `git remote get-url origin` on-demand |
| `completion-core/tasks/completion.md` | `GIT_OWNER`, `GIT_REPO`, `GITHUB_HTML_URL`, `GITBUCKET_HTML_URL` | Inline `git remote get-url origin` on-demand |
| `git-workflow-branch/tasks/pair-pre-work.md` | `DEV_NAME`, `DEV_EMAIL` | Inline `git config user.name` / `git config user.email` on-demand |
| `using-git-worktrees/tasks/create-worktree.md` | `BRANCH_NAME` | Inline `git branch --show-current` on-demand |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `env-loader.ts` no longer imports `execSync` | `string` | grep for `execSync` in `env-loader.ts` — must be absent |
| SC-2 | `env-loader.ts` no longer contains `gitCmd`, `resolveGitPath`, `GIT_FALLBACK_PATHS`, or `GIT_CMD_TIMEOUT_MS` | `string` | grep for each symbol — must be absent |
| SC-3 | `env-loader.ts` no longer runs any git commands in `shell.env` | `behavioral` | `opencode run` → stderr must not contain `branch --show-current`, `remote get-url origin`, or `config user.email` |
| SC-4 | `completion-core` consumers still produce correct compare URLs | `behavioral` | `opencode run` with completion task → compare URL contains correct owner/repo |
| SC-5 | `pair-pre-work` still produces `Co-authored-by` with correct name/email | `behavioral` | `opencode run` with pair-pre-work task → `Co-authored-by` trailer present with correct values |
| SC-6 | `create-worktree` still resolves correct branch name | `behavioral` | `opencode run` with create-worktree task → worktree path contains correct branch name |

## Risk Assessment

Low risk. Each consumer already has access to git — the change is moving from pre-fetched env vars to on-demand git commands at the point of use. The env vars were the only consumers of the git data in `env-loader.ts`; no other code reads `BRANCH_NAME`, `GIT_OWNER`, `GIT_REPO`, `GIT_PLATFORM`, `DEV_NAME`, or `DEV_EMAIL` from the shell environment.
