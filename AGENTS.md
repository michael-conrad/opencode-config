# AGENTS.md — .issues/ Workspace Guide (opencode-config store)

## Identity

`.issues/` is the parent repo's issue store: a standalone git repository on the `issues-data` orphan branch, stored as a git worktree at `.git/worktrees/-issues/`. It uses the same remote as the parent repo. **This is NOT a submodule** and not part of the parent repo's tracked tree.

## Tool

Always use `.opencode/tools/local-issues` for issue-tracking operations in this store, with qualified names: `opencode-config#N`.

## Doctrine — single source

All issue-store doctrine is defined once in the canonical guide:
[`.opencode/.issues/AGENTS.md`](../../.opencode/.issues/AGENTS.md) — remote-first issue-number reservation (MANDATORY when a remote tracker exists; every issue type), local-counter fallback (remoteless stores only), mirror precedence (the local `{N}/` folder holds the full spec and all artifacts; the remote body is a detailed exec summary — clear intent on the why and on the final what), the remote-body URL convention, directory layout, the hygiene mandate, and the exclusions boundary.

This guide deliberately carries no doctrine copy. It was a full mirror, drifted from the canonical guide (it still taught counter-first reservation after the canonical guide mandated remote-first), and was collapsed to a pointer on 2026-10-05.

## Session start

```
.opencode/tools/local-issues init     # bootstrap + pull
.opencode/tools/local-issues sync     # commit + pull-rebase + push
```

Details, workflow tables, and the lessons-learned registry: canonical guide, as above.
