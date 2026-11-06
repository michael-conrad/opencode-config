---
number: 9001
title: "[BUG] session-init emits spurious hooks-dir errors for worktrees"
state: OPEN
labels: [bug]
---

## Claim

`.opencode/tools/session-init` emits `Could not resolve hooks dir for linked
repo: .issues` and `Could not resolve hooks dir for linked repo:
.opencode/.issues` error lines during every session init, plus a
`Failed to install 2 hook(s)` line. Exit code is 0.

## Symptoms

```
Could not resolve hooks dir for linked repo: .issues
Could not resolve hooks dir for linked repo: .opencode/.issues
Failed to install 2 hook(s)
```

## Reported Root Cause

`session-init`'s `install_hooks()` iterates all linked repos and fails the
`issues-data` orphan-branch worktrees because their gitdir references have no
`hooks/` subdirectory.

## Triage task

Verify the claim against the live tree in this repository and complete the
issue's disposition per your issue-tracking rules. The repository you are in
is the authoritative source for what the code does today.
