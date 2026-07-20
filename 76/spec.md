## Summary

Cross-repo cleanup for submodule repos. When `git-workflow --task cleanup` runs in the parent repo, it must descend into submodules to close issues and delete branches using the correct API routing. Everything must be parked at dev tip on completion.

## Problem

Cleanup is single-repo only. After a PR merges in `opencode-config`:
- Issue closure API calls hardcode `<github.owner>`/`<github.repo>` — never route to submodule repos
- Submodule branches (created inside `.opencode/`) are never deleted by parent repo cleanup
- Step 8.5 (submodule routing) was removed by rollback commit `6db0610d` and never restored
- GitHub auto-close via `Fixes #N` only fires on default-branch merges (`main`), not `dev` — so cleanup is the SOLE closure mechanism

## Root Cause

1. **issue-closure.md** — No submodule detection. `Fixes #N` references always close in parent repo.
2. **verify-merge.md** — No submodule repo awareness.
3. **branch-cleanup.md** — Step 1.7 handles parent dev parking (running *from* submodule) but never forward descent (*into* submodules).
4. **cleanup.md** — Routes three sub-tasks with no submodule iteration step.
5. **assemble-work.md dispatch audit** — Cleanup sub-agent gets no `submodule_paths` context.

## Scope

| In scope | Out of scope |
|----------|-------------|
| Submodule iteration in `cleanup.md` | Multi-level nested submodules (>1 deep) |
| Submodule-aware API routing in `issue-closure.md` | Recursive cleanup |
| Submodule branch cleanup in `branch-cleanup.md` | `--recursive` submodule operations |
| Restore submodule closure routing (~Step 8.5) | Submodule cleanup during `for_analysis` |
| Verify submodule SHAs reachable via tags | |

## Success Criteria

**SC-1:** When cleanup runs in the parent repo after a merged PR, and PR body references an issue number targeting a submodule repo, closure API calls MUST route to the submodule's correct `owner`/`repo`. Routing MUST use session-init sub-folder repo mappings (`.gitmodules`-derived, covering both GitHub and GitBucket platforms) — NOT hardcoded values.

- RED: Send cleanup prompt with a PR that references `.opencode` issue. Assert API call uses parent `owner`/`repo`.
- GREEN: Same scenario. Assert API call uses submodule `owner`/`repo` from session-init mapping.

**SC-2:** When cleanup runs in the parent repo, and the submodule has merged branches (`git branch --merged dev` inside submodule), those branches MUST be deleted (local + remote).

**SC-3:** All submodule GitHub/GitBucket API calls MUST use the submodule's `owner`/`repo` — never the parent repo's.

**SC-4:** Cleanup sub-agent dispatch (from `assemble-work`) MUST include submodule routing context (`submodule_paths`, submodule `owner`/`repo`).

**SC-5:** Submodule pointer (`.opencode`) MUST NOT be committed or modified during cleanup. After submodule branch cleanup, a dirty pointer is expected and acknowledged per `branch-cleanup.md` Step 1.7 dirty submodule pointer rules.

**SC-6:** After ALL cleanup steps complete (verify-merge → issue-closure → branch-cleanup → submodule iteration), verify every repo (parent + all submodules) is on `dev` at origin/dev tip. Report any repo that is not at dev tip.

## Affected Files

All files in `michael-conrad/.opencode` (submodule):
- `skills/git-workflow/tasks/cleanup.md` — add Step 4: final dev-tip verification across all repos
- `skills/git-workflow/tasks/cleanup/issue-closure.md` — add submodule-aware API routing
- `skills/git-workflow/tasks/cleanup/verify-merge.md` — add submodule repo awareness
- `skills/git-workflow/tasks/cleanup/branch-cleanup.md` — add submodule branch cleanup descent
- `skills/divide-and-conquer/tasks/assemble-work.md` — add `submodule_paths` to dispatch audit table

## Phases

### Phase 1: Submodule Detection and Routing Context
Add submodule routing context (`submodule_paths`, submodule `owner`/`repo`) to `cleanup.md` and `assemble-work.md` dispatch audit.

### Phase 2: Submodule Issue Closure
Add submodule-aware closure to `issue-closure.md`. Detect issue references targeting submodule content, route closure calls to correct repo.

### Phase 3: Submodule Branch Cleanup
Add submodule branch cleanup descent to `branch-cleanup.md`: sync submodule dev, delete merged branches, verify SHA reachable via tags, acknowledge dirty pointer.

### Phase 4: Dev-Tip Verification
Add Step 4 to `cleanup.md`: after all sub-tasks and submodule iterations complete, verify parent + all submodules are on `dev` at origin/dev tip.

## Documentation Sources

The following resources were consulted during root cause analysis. Auditor sub-agents should verify findings against these live sources.

### Skill Task Files (submodule: `michael-conrad/.opencode`, branch: `dev`)

| File | Purpose |
|------|---------|
| `skills/git-workflow/tasks/cleanup.md` | Top-level cleanup task — routes verify-merge → issue-closure → branch-cleanup. Contains the three sub-task route table and the hierarchical closure rules. |
| `skills/git-workflow/tasks/cleanup/verify-merge.md` | Step 1 of cleanup. Verifies PR merge status via GitHub API, runs SC-verification gate, phase-completion gate, and rebase-pending PRs. |
| `skills/git-workflow/tasks/cleanup/issue-closure.md` | Step 2 of cleanup. Hierarchical issue closure. Contains keyword classification (`Fixes`, `Implements`, `Related`, `Spec:`, `Plan:`), phase-completion verification (Step 4a), plan reference check (Step 4b), and transitive graph reconciliation (Step 6). **Step 8.5 (Submodule Issue Closure Routing) was removed by the rollback and never restored.** |
| `skills/git-workflow/tasks/cleanup/branch-cleanup.md` | Step 3 of cleanup. Dev sync, worktree removal, branch deletion, content verification gate, and Step 1.7 (parent repo dev parking with dirty submodule pointer rules). |
| `skills/divide-and-conquer/tasks/assemble-work.md` | Orchestrator task that dispatches cleanup sub-agents. Lines 395-410 contain Mandatory Rule 12 (cleanup dispatch MUST use `skill()`) and the Dispatch Audit table. |

### Version History

| Reference | Description |
|-----------|-------------|
| Commit `6db0610d` | Rollback: revert to `1860c0d` (Apr 27) for config compression. Removed 71 commits including the original Step 8.5. |
| PR `michael-conrad/.opencode#519` | Strengthened submodule pointer commit prohibition in cleanup task. Added the dirty-pointer-is-expected language. |
| PR `michael-conrad/.opencode#522` | Combined spec: project-local tools (#440), cleanup dispatch gate (#519), texted MCP (#521). Added Mandatory Rule 12 to assemble-work.md. |

### Repository Configuration

| Reference | Description |
|-----------|-------------|
| `opencode-config/AGENTS.md` §Tag-Based Hash Permanence | Tag layers table, idempotent tag-if-untagged rule. Defines how submodule SHAs are preserved. |
| `opencode-config/AGENTS.md` §Submodule Discipline | Dirty submodule pointer handling: expected at cleanup time, committed at pre-work on feature branches. |
| `.gitmodules` | Defines `.opencode` submodule path. Maps to `git@github.com:michael-conrad/.opencode.git`. |
| Session-init `submodule_path: owner/repo (platform)` mapping | Emitted on every session start when `.gitmodules` exists. Covers GitHub and GitBucket platforms. |

### Guidelines

| Guideline | Relevant Rules |
|-----------|---------------|
| `000-critical-rules.md` §critical-rules-048 | Skill pre-read + inline execution prohibition — cleanup must dispatch via `skill()`. |
| `000-critical-rules.md` §critical-rules-049 | Standalone submodule-only PR creation during cleanup is prohibited. |
| `000-critical-rules.md` §Wrong API Routing | Submodule/folder repos require resolved remote for API calls. |
| `060-tool-usage.md` §Workdir-Aware Path Composition | Path resolution rules inside `.opencode/` submodule context. |

### Confirmed Open Issues (as of spec creation)

| Repo | Issue | Status |
|------|-------|--------|
| `michael-conrad/.opencode` | #527 (Auth Scope Overhaul) | FIXED by PR #536 (merged), issue still open |
| `michael-conrad/.opencode` | #537 (Universal Skill Dispatch) | FIXED by PR #539 (merged), issue still open |