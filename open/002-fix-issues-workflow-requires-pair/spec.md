---
number: 2
title: "Fix: .issues/ workflow requires pair branch without pair-mode semantics"
status: "open"
labels: [SPEC, needs-approval]
created: "2026-04-25T17:15:17Z"
updated: "2026-04-25T17:51:14Z"
github_issue: 60
author: "Michael Conrad"
---

## Objective

Establish a `track/` branch model that keeps `.issues/` files visible in the main working directory, auto-committed, and robust against rejected PRs and abandoned feature branches — while code implementation continues in worktrees on `feature/` branches.

## Problem

### Current State

- `.issues/` is worktree-exempt (correct — developer needs to see specs/plans)
- `.issues/` still requires a feature branch (correct — no direct commits to `dev`/`main`)
- But there is no mechanism for a feature branch in the main directory without full pair-mode
- When a `feature/` branch is checked out in a worktree, the main directory is on `dev` — `.issues/` edits would land on `dev`, violating the branching rule
- Pair mode (`pair-` prefix) exists but implies synchronous collaboration, not issue-tracking lifecycle

### Root Cause

Git worktrees cannot have the same branch checked out in two locations. The current model has one branch per concern, but `.issues/` files and code files have different visibility requirements:

| Need | Mechanism | Conflict |
|------|-----------|----------|
| Developer reviews `.issues/` drafts | Files in working directory | Worktree hides them |
| Code implementation isolation | Worktree on `feature/` branch | `.issues/` can't be on same branch in main dir |
| Auto-commit `.issues/` history | No mechanism | Stashes, lost changes on branch switches |

### Impact

- Developer cannot review spec/plan drafts during implementation (they're in a worktree)
- `.issues/` changes made in the main directory risk landing on `dev`/`main`
- No auto-commit safety net — lost edits if branch switch happens without manual commit
- Post-merge cleanup (#1 metadata update) required a worktree, defeating the purpose of `.issues/` visibility

## Constraints and Scope

**In Scope:**

- `track/` branch naming convention and lifecycle
- Auto-commit mechanism for `.issues/` changes
- Path-isolation guarantee: `track/` branches only touch `.issues/`, `feature/` branches only touch code
- Merge gates: `pre-work` and `review-prep` stack track → feature
- Robustness against rejected PRs and abandoned features
- Cleanup: track branch merged to `dev` alongside or after feature PR
- `session-enforcement.ts` plugin changes for auto-commit and track-branch detection

**Out of Scope:**

- Changes to pair-mode semantics (pair mode remains for synchronous collaboration)
- Changes to worktree model for code implementation
- `.issues/` sync across machines (already handled by git tracking)
- Offline-first or conflict resolution for parallel `.issues/` edits

**Key Constraints:**

- No merge conflicts possible between `track/` and `feature/` branches (path isolation)
- Track branch persists across PR iterations — it is NOT deleted when a feature PR is rejected
- Auto-commit must be triggered before any branch switch to prevent data loss
- Track branch checkout in main directory MUST NOT interfere with worktree operations
- Developer must be able to edit `.issues/` files directly without agent involvement

## Affected Files

| File | Change Type | Anchor |
|------|-------------|--------|
| `.opencode/tools/session-init` | Modify | Track branch detection, emit `track.branch` |
| `.opencode/plugins/session-enforcement.ts` | Modify | Auto-commit `.issues/` changes, pre-switch guard |
| `.opencode/skills/git-workflow/SKILL.md` | Modify | `pre-work` and `review-prep` merge gates |
| `.opencode/skills/git-workflow/tasks/pre-work.md` | Modify | Add `track → feature` merge step |
| `.opencode/skills/git-workflow/tasks/review-prep.md` | Modify | Add `track → feature` merge step |
| `.opencode/skills/git-workflow/tasks/cleanup.md` | Modify | Track branch merge to dev during cleanup |
| `.opencode/guidelines/060-tool-usage.md` | Modify | Document track branch model |
| `.opencode/guidelines/115-branch-naming.md` | Modify | Add `track/` naming convention |

## Fix Approach

### Phase 1: Track Branch Model

#### Branch Naming

| Pattern | Purpose | Location | Contents |
|---------|---------|----------|----------|
| `track/<N>-<slug>` | Issue tracking branch | Main directory | `.issues/` only |
| `feature/<N>-<slug>` | Code implementation branch | Worktree | Code only |
| `pair-<prefix>/<N>-<slug>` | Pair mode branch | Main directory | Everything (existing) |

Track branch name derives from the issue number and slug: `track/2-issues-workflow-pair-branch` for issue #2.

#### Path Isolation Guarantee

Track branches ONLY touch files under `.issues/`. Feature branches ONLY touch files outside `.issues/`. This guarantee means:

- `track/` → `feature/` merges are always clean (no path overlap)
- `feature/` → `track/` merges are always clean (reverse direction, same reason)
- A `track/` branch can be merged into ANY `feature/` branch without conflict

#### Lifecycle

```
Issue created → track/<N>-<slug> branch created in main directory
                      │
Spec/plan phase:      .issues/ edits auto-committed to track branch
                      │
Implementation:       pre-work → track merged into feature base
                      feature/<N>-<slug> in worktree (code only)
                      .issues/ edits continue on track branch
                      │
                      review-prep → track merged into feature (latest .issues/ in PR)
                      │
PR created:           feature PR includes .issues/ changes from track
                      │
                      ┌─── PR merged → cleanup: track merged to dev, both branches deleted
                      │
                      └─── PR rejected → spec revised on track branch
                              new feature branch created → track merged into new base
                              track branch survives PR rejection
```

#### Robustness Scenarios

**Rejected PR, spec revision needed:**

```
track/58-issues-workflow:  v1 → v2 → v3 (spec evolves throughout)
                                  ↕ merges at gates
feature/58-v1:             [PR #59, code rejected]

Result: PR rejected. Developer revises spec on track branch.
        Creates feature/58-v2 → merges track → new PR
        Track branch continuity: zero data loss
```

**Abandoned feature entirely:**

```
track/58-issues-workflow:  v1 → v2 (valuable thinking preserved)
feature/58-issues-workflow: abandoned, deleted

Result: Track branch merged to dev as spec/draft history
        OR simply deleted if truly unwanted
        Either way — .issues/ history was in git the entire time
```

**Multiple PR iterations from same spec:**

```
track/58-issues-workflow:  v1 → v2 → v3 (evolves across iterations)
                              ↕       ↕       ↕
feature/58-v1:             [PR rejected]
feature/58-v2:                      [PR merged!]

Each feature branch merges track at its pre-work gate.
Track branch persists across PR iterations.
No path overlap = no merge conflicts ever.
```

**Developer edits `.issues/` without agent:**

Developer opens `.issues/open/002-.../spec.md` in editor, makes changes.
Session plugin detects dirty `.issues/` on next prompt, auto-commits to track branch.
No manual commit needed. No data loss.

### Phase 2: Auto-Commit Mechanism

#### Session Plugin Guard

`session-enforcement.ts` gains two `pre-switch` guards:

1. **Pre-switch auto-commit**: Before any `git checkout` that changes branches, check if `.issues/` has uncommitted changes. If yes, auto-commit to the current track branch with message `docs(issues): auto-commit before branch switch`.

2. **Session-start auto-commit**: On session start, if the main directory is on a `track/` branch and `.issues/` has uncommitted changes, auto-commit with `docs(issues): session start sync`.

#### Track Branch Detection

`session-init` emits a new variable:

```
track.branch: track/2-issues-workflow-pair-branch   (or empty if no track branch)
```

Detection logic:
1. Check if the current directory (main, not worktree) is on a `track/` branch
2. Check if `.issues/` directory exists
3. If `.issues/` exists but no `track/` branch is checked out, suggest creating one

### Phase 3: Workflow Gate Integration

#### Pre-Work Gate

`git-workflow --task pre-work` gains a step after worktree creation:

1. Worktree created on `feature/<N>-<slug>` (existing behavior)
2. NEW: Merge `track/<N>-<slug>` into `feature/<N>-<slug>` (brings `.issues/` into feature base)
3. Result: Feature branch has both code AND `.issues/` content for PR

#### Review-Prep Gate

`git-workflow --task review-prep` gains a step before push:

1. Merge `track/<N>-<slug>` into `feature/<N>-<slug>` (brings latest `.issues/` into PR)
2. Push feature branch (existing behavior)
3. Result: PR diff includes `.issues/` changes — reviewers see spec evolution

#### Cleanup Gate

`git-workflow --task cleanup` gains a step after feature branch deletion:

1. Feature branch deleted (existing behavior)
2. NEW: Merge `track/<N>-<slug>` into `dev` (preserves `.issues/` history)
3. NEW: Delete `track/<N>-<slug>` branch
4. Result: `.issues/` changes survive in `dev` even after feature branch is gone

### Phase 4: Track Branch Creation

Track branches are created automatically when a local issue is created via `local-issues create`:

1. `local-issues create --title "TITLE" --labels SPEC` runs
2. Tool checks if a `track/<N>-<slug>` branch exists for issue #N
3. If not, tool creates the branch from `dev` in the main directory (not a worktree)
4. `.issues/` changes are committed on the track branch
5. `session-init` picks up the track branch name and emits `track.branch`

The `local-issues` tool gains a `--track` flag (default: true) that controls whether track branch creation is attempted.

## Success Criteria

| ID | Criterion | Semantic Intent | Verification |
|----|-----------|-----------------|--------------|
| SC-1 | `local-issues create` auto-creates `track/<N>-<slug>` branch when no track branch exists | Issue creation bootstraps the track branch lifecycle | Create issue; verify `track/2-...` branch exists in main directory |
| SC-2 | `.issues/` edits in main directory are auto-committed to track branch before branch switches | No data loss from branch switches | Edit spec.md; switch branches; switch back; edit preserved |
| SC-3 | `.issues/` edits in main directory are auto-committed on session start | No data loss from session boundaries | Edit spec.md; start new session; verify auto-commit occurred |
| SC-4 | `pre-work` merges track branch into feature branch base | Feature branch carries `.issues/` content for PR | Create feature branch via pre-work; verify `.issues/` files exist in worktree |
| SC-5 | `review-prep` merges latest track branch into feature branch before push | PR includes latest `.issues/` changes | Revise spec after implementation; run review-prep; verify PR diff includes `.issues/` |
| SC-6 | Rejected PR does not lose `.issues/` history | Track branch survives PR rejection across multiple iterations | Reject PR; verify track branch still exists with all edits; create new feature branch; verify track merges cleanly |
| SC-7 | Abandoned feature preserves `.issues/` history in git | Even abandoned work leaves a trace | Delete feature branch; merge track to dev; verify `.issues/` content in dev |
| SC-8 | Path isolation: track and feature branches never produce merge conflicts | `.issues/` only (track) vs code only (feature) have zero path overlap | Merge track into feature; verify zero conflicts across 10+ merge scenarios |
| SC-9 | `session-init` emits `track.branch` when track branch is active | Downstream skills can discover track branch name | Run session-init; verify `track.branch: track/N-slug` in output |
| SC-10 | Developer can edit `.issues/` files directly without agent involvement | Track branch model doesn't gate keep developer access | Edit spec.md in editor; verify auto-commit on next session or branch switch |

## Risk and Edge Cases

| Risk | Impact | Mitigation |
|------|--------|------------|
| Developer creates `.issues/` changes while on `dev` (no track branch) | Changes land on protected branch | `session-enforcement.ts` detects `.issues/` dirty state on `dev`, suggests `track/` branch creation |
| Two track branches for same issue (e.g., `track/2-a` and `track/2-b`) | Confusion about which is canonical | `local-issues` tool enforces one track branch per issue number |
| Track branch merge into feature fails (shouldn't per path isolation, but...) | PR missing `.issues/` content | Path isolation guarantee prevents this; if it happens, HALT and report |
| Multiple agents editing same track branch | Race condition on auto-commit | File locking via `fcntl.flock()` on `.issues/` files (same as `.counter` locking) |
| Developer switches main dir to unrelated branch mid-session | `.issues/` visibility lost | Pre-switch guard auto-commits before switch; track branch still exists |
| Track branch accumulates stale closed issues | Directory bloat | `cleanup` gate merges track to dev; closed issues archived naturally |

## Dependencies

- Phase 1 (Track branch model + naming) MUST be completed before Phase 2 (auto-commit) and Phase 3 (workflow gates)
- Phase 2 (auto-commit) MUST be completed before Phase 3 (workflow gates depend on auto-commit for safety)
- Phase 4 (track branch creation in `local-issues`) depends on Phase 1 (naming convention)
- Phases 2 and 3 are independent of Phase 4 and MAY be developed in parallel

## Coexistence with Pair Mode

Track branches and pair-mode branches serve different purposes:

| Aspect | Track Branch | Pair Branch |
|---------|-------------|-------------|
| Purpose | `.issues/` lifecycle across PR iterations | Synchronous developer-agent collaboration |
| Location | Main directory, checked out automatically | Main directory, developer switches to it |
| Contents | `.issues/` only | Everything (code + `.issues/`) |
| Auto-commit | Yes (`.issues/` only) | Yes (all files with `[pair-mode]` tag) |
| Workflow gates | Merged into feature at pre-work/review-prep | No merge gates (pair branch IS the feature) |
| Survival | Persists across PR rejections | Deleted after PR merge (same as feature) |

When pair mode is active, the `pair-` branch handles `.issues/` directly — track branch creation is skipped (pair mode already provides main-directory visibility).

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)
