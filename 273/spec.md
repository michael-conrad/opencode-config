## Problem

`.issues/` is a git worktree (orphan branch worktree at `.git/worktrees/-issues/`) and is gitignored in the parent repo (`.gitignore` line 40). Agents are ignoring `.gitignore` and tracking `.issues/` files in the parent repo, which corrupts git state and breaks branches.

## Current Behavior

- `.gitignore` line 40: `.issues/` is listed
- `git check-ignore -v .issues/` confirms it IS ignored
- BUT agents still read/write `.issues/` files directly via git operations
- This causes `.issues/` content to be committed to the parent repo
- Git branches get corrupted because `.issues/` files are worktree metadata, not repo files

## Required Behavior

`.issues/` can ONLY be managed via:
1. `.opencode/tools/local-issues` CLI tool
2. `git -C <tree>/.issues/` (explicit worktree path)

Agents MUST NOT read/write `.issues/` files directly through normal git operations. The `.gitignore` and all three AGENTS.md files must make this constraint unmistakable.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `.issues/` files are never committed to git (verified by `git ls-files .issues/` returning empty) | `behavioral` |
| SC-2 | Agents use `.opencode/tools/local-issues` for all `.issues/` operations | `behavioral` |
| SC-3 | `.issues/AGENTS.md` clearly states worktree-only constraint | `string` |
| SC-4 | `.opencode/AGENTS.md` clearly states worktree-only constraint | `string` |
| SC-5 | `AGENTS.md` clearly states worktree-only constraint | `string` |

## Files to Update

- `.issues/AGENTS.md` — add CRITICAL section at top
- `.opencode/AGENTS.md` — add CRITICAL section under Issues Path Resolution
- `AGENTS.md` — add CRITICAL section under Reference Files

## Behavioral Tests

- `tests/behaviors/1796-sc1.sh` — verify `.issues/` not in git
- `tests/behaviors/1796-sc2.sh` — verify local-issues usage
- `tests/behaviors/1796-sc3.sh` — verify .issues/AGENTS.md content
- `tests/behaviors/1796-sc4.sh` — verify .opencode/AGENTS.md content
- `tests/behaviors/1796-sc5.sh` — verify AGENTS.md content

🤖 Co-authored with AI: OpenCode (ollama/ornith:35b-256k)