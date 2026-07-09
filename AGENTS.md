# AGENTS.md — opencode-config Repository

This repository holds the agent configuration submodule. All agent rules, guidelines, and skills are in the submodule — not here.

## Trunk-Based Development

Main is the single trunk. Dev branch has been removed.

## Reference Files

| File | Purpose |
|------|---------|
| `.opencode/AGENTS.md` | Canonical agent rules: build/lint/test commands, workflow, boundaries, pair mode, submodule discipline |
| `.opencode/.issues/AGENTS.md` | `.issues/` workspace guide: tool, workflow, directory layout, GitHub URL convention |
| `.issues/AGENTS.md` | Local `.issues/` workspace guide for the parent repo (mirrors `.opencode/.issues/AGENTS.md` pattern)

## Trunk-Based Development
Main is the single trunk. Dev branch has been removed.

## `.issues/` Is a Worktree — NOT a Regular Directory

**`.issues/` is a git worktree (orphan branch worktree), NOT a regular directory.** It lives at `.git/worktrees/-issues/` and is a completely separate git repository with its own `issues-data` branch. It is gitignored in the parent repo (`.gitignore` line 40: `.issues/`).

**Any agent that tracks `.issues/` files in the parent repo's git is corrupting git state and breaking branches.**

| ✅ CORRECT | 🚫 FORBIDDEN |
|------------|---------------|
| `.opencode/tools/local-issues <command>` | `read(filePath='.issues/46/spec.md')` |
| `git -C <tree>/.issues/ <command>` | `write(filePath='.issues/46/spec.md')` |
| | `git add .issues/` in parent repo |
| | `edit(filePath='.issues/46/spec.md')` |
| | `glob(pattern='.issues/**/*.md')` in parent repo |

**The CLI tool handles git operations internally.** File operation tools (`read`, `write`, `edit`, `glob`, `grep`) target the parent repo — they do NOT reach into the worktree. Using them on `.issues/` paths silently operates on the wrong repository.

**See `.opencode/AGENTS.md` for the canonical `.issues/` workspace guide. See `.issues/AGENTS.md` for the local `.issues/` workspace guide.**
