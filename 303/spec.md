> **Full spec and artifacts: [`.issues/303/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/303)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/303/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Fix .issues/ worktree vs remote API confusion in AGENTS.md files

## Objective

Correct the four AGENTS.md files (root, `.opencode/`, `.issues/`, `.opencode/.issues/`) to accurately describe the `.issues/` worktree model — distinguishing between filesystem reads (permitted) and parent-repo git operations (forbidden) — and remove incorrect "silently operates on wrong repo" prose that conflates OS-level file operations with git operations.

## Background

The `.issues/` directory is a git worktree (orphan branch `issues-data`), gitignored in the parent repo. AGENTS.md files across the repository contain incorrect guidance that:

1. Lists `read()`, `write()`, `edit()`, `glob()`, `grep()` as FORBIDDEN on `.issues/` paths — but these are OS-level filesystem operations that work correctly on any directory, including worktrees
2. Claims these tools "silently operate on the wrong repository" — but the CLI tool resolves paths against the parent repo's working tree, not the worktree's git dir
3. Fails to distinguish between filesystem reads (permitted) and parent-repo git operations (`git add .issues/`, `git commit`) which are actually forbidden

The root cause is conflating "the worktree is a separate git repo" with "the worktree's files are inaccessible to OS-level tools." The worktree's files are regular files on disk — any tool that reads/writes files by absolute path works correctly.

## Not Included

- Changes to the worktree implementation or `local-issues` tool
- Changes to git hooks or session-enforcement.ts
- Changes to any non-AGENTS.md files
- Adding new enforcement mechanisms

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Root `AGENTS.md` corrected/forbidden table distinguishes filesystem ops (permitted) from parent-repo git ops (forbidden) | `string` | grep for corrected table in root AGENTS.md |
| SC-2 | Root `AGENTS.md` removes "silently operates on wrong repo" prose | `string` | grep confirms prose removed |
| SC-3 | `.opencode/AGENTS.md` corrected/forbidden table distinguishes filesystem ops (permitted) from parent-repo git ops (forbidden) | `string` | grep for corrected table in `.opencode/AGENTS.md` |
| SC-4 | `.opencode/AGENTS.md` removes "silently targets wrong repo" prose | `string` | grep confirms prose removed |
| SC-5 | `.opencode/AGENTS.md` adds primacy statement and three-system model (CLI tool, git, filesystem) | `string` | grep for primacy statement |
| SC-6 | `.issues/AGENTS.md` (root worktree) line 13 clarifies "MUST NOT read/write through **parent repo git operations**" | `string` | grep for clarified language |
| SC-7 | `.opencode/.issues/AGENTS.md` (submodule worktree) verified consistent with root worktree AGENTS.md | `string` | diff check between the two worktree AGENTS.md files |
| SC-8 | All four files pass markdown lint (`pymarkdownlnt`) without new errors | `string` | `pymarkdownlnt` scan passes |

## Requirements

1. The root `AGENTS.md` SHALL contain a corrected forbidden table that lists `git add .issues/`, `git commit` on parent repo, and `git -C .issues/` bypass as FORBIDDEN, while listing `read()`, `write()`, `edit()`, `glob()`, `grep()` as PERMITTED.
2. The root `AGENTS.md` SHALL remove all instances of "silently operates on the wrong repository" or equivalent prose.
3. The `.opencode/AGENTS.md` SHALL contain a corrected forbidden table matching the root file's structure.
4. The `.opencode/AGENTS.md` SHALL remove all instances of "silently targets wrong repo" or equivalent prose.
5. The `.opencode/AGENTS.md` SHALL add a primacy statement describing the three-system model: CLI tool (path resolution), git (repository operations), filesystem (OS-level reads/writes).
6. The `.issues/AGENTS.md` SHALL clarify line 13 to specify "MUST NOT read/write through **parent repo git operations**" rather than a blanket prohibition.
7. The `.opencode/.issues/AGENTS.md` SHALL be verified consistent with the root worktree `.issues/AGENTS.md`.
8. All four files SHALL pass `pymarkdownlnt` without new errors after changes.

## Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1 | Fix root AGENTS.md forbidden table |
| 2 | SC-2 | Remove "silently operates on wrong repo" from root AGENTS.md |
| 3 | SC-3 | Fix `.opencode/AGENTS.md` forbidden table |
| 4 | SC-4 | Remove "silently targets wrong repo" from `.opencode/AGENTS.md` |
| 5 | SC-5 | Add primacy statement and three-system model to `.opencode/AGENTS.md` |
| 6 | SC-6 | Clarify `.issues/AGENTS.md` line 13 |
| 7 | SC-7 | Verify `.opencode/.issues/AGENTS.md` consistency |
| 8 | SC-8 | Markdown lint all four files |

## Phases

| Phase | SCs | Description |
|-------|-----|-------------|
| 1 | SC-1, SC-2 | Fix root `AGENTS.md` — correct forbidden table to distinguish filesystem ops (permitted) from parent-repo git ops (forbidden); remove "silently operates on wrong repo" prose |
| 2 | SC-3, SC-4, SC-5 | Fix `.opencode/AGENTS.md` — correct forbidden table; remove "silently targets wrong repo" prose; add primacy statement and three-system model (CLI tool, git, filesystem) |
| 3 | SC-6 | Fix `.issues/AGENTS.md` (root worktree) — clarify line 13 to specify "MUST NOT read/write through **parent repo git operations**" |
| 4 | SC-7, SC-8 | Verify consistency and lint — diff check between worktree AGENTS.md files; run `pymarkdownlnt` on all four files |

## Dependencies

- None. All changes are to AGENTS.md files within this repository.

## Traceability

| Requirement | SCs | Phase |
|-------------|-----|-------|
| 1 | SC-1 | 1 |
| 2 | SC-2 | 1 |
| 3 | SC-3 | 2 |
| 4 | SC-4 | 2 |
| 5 | SC-5 | 2 |
| 6 | SC-6 | 3 |
| 7 | SC-7 | 4 |
| 8 | SC-8 | 4 |

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-28 | Added Phases section between Items and Dependencies | Spec was missing Phases section; Traceability table referenced Phase 1-4 but no section defined what each phase covers | AI agent (deepseek-v4-flash) |
