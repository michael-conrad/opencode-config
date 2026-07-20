## Problem

`.issues/` is in `.gitignore` and is supposed to be worktree-only (managed via `.opencode/tools/local-issues` or `git -C <tree>/.issues/`). Agents are ignoring `.gitignore` and tracking `.issues/` files in git, which corrupts git state and trashes git branches.

## Current Behavior

- `.gitignore` line 40: `.issues/` is listed
- `git check-ignore -v .issues/` confirms it IS ignored
- BUT agents are still reading/writing `.issues/` files directly via git operations
- This causes `.issues/` content to be committed to the repo
- Git branches get corrupted because `.issues/` files are worktree metadata, not repo files

## Required Behavior

1. **`.issues/` are worktree-only** — can ONLY be managed via:
   - `.opencode/tools/local-issues` CLI tool
   - `git -C <tree>/.issues/` (explicit worktree path)
2. **Agents MUST NOT** read/write `.issues/` files directly through git operations
3. **Update documentation** to make this clear in:
   - `.issues/AGENTS.md` — local issues workspace guide
   - `.opencode/AGENTS.md` — canonical agent rules
   - `AGENTS.md` — root repo guide

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `.issues/` files are never committed to git (verified by `git ls-files .issues/` returning empty) | `behavioral` |
| SC-2 | Agents use `.opencode/tools/local-issues` for all `.issues/` operations | `behavioral` |
| SC-3 | `.issues/AGENTS.md` clearly states worktree-only constraint | `string` |
| SC-4 | `.opencode/AGENTS.md` clearly states worktree-only constraint | `string` |
| SC-5 | `AGENTS.md` clearly states worktree-only constraint | `string` |

## Files to Update

- `.issues/AGENTS.md`
- `.opencode/AGENTS.md`
- `AGENTS.md`

## Behavioral Tests

- `tests/behaviors/1796-sc1.sh` — verify `.issues/` not in git
- `tests/behaviors/1796-sc2.sh` — verify local-issues usage
- `tests/behaviors/1796-sc3.sh` — verify .issues/AGENTS.md content
- `tests/behaviors/1796-sc4.sh` — verify .opencode/AGENTS.md content
- `tests/behaviors/1796-sc5.sh` — verify AGENTS.md content

🤖 Co-authored with AI: OpenCode (ollama/ornith:35b-256k)