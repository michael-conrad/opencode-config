# AGENTS.md — opencode-config Repository

This repository holds the agent configuration submodule. All agent rules and
skills are in the submodule — not here. This file is a slim pointer only;
per-root facts arrive from session-init.

## Agent Deck

The deck lives at `.opencode/` (submodule, upstream
`michael-conrad/.opencode`). The agent instruction floor is
[`.opencode/floor.md`](.opencode/floor.md); routing is
[`.opencode/routing.md`](.opencode/routing.md). Deck changes go through the
deck's own governance card and its repository's PR process.

## Trunk-Based Development

Main is the single trunk. Dev branch has been removed.

## Submodule Pointer Discipline

Submodule pointer updates ride with real parent-repo changes in the same
commit — never pointer-only commits. This file's slimming is that pattern
in practice: pointer to the new deck rides with this rewrite.

## `.issues/` Is a Worktree — NOT a Regular Directory

`.issues/` is an orphan-branch git worktree (branch `issues-data`), gitignored
in this repo. File tools may read/write files inside it, but every git
operation on it goes through `.opencode/tools/local-issues` or explicit
`git -C .issues/` commands — parent-repo git operations on `.issues/` paths
corrupt branches.

## Reference Files

| File | Purpose |
|------|---------|
| `.opencode/floor.md` | agent instruction floor (always-injected) |
| `.opencode/routing.md` | intent-phrased routing index |
| `.opencode/.issues/AGENTS.md` | submodule issue-store workspace guide |
| `.issues/AGENTS.md` | local issue-store workspace guide |

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)