## Summary

`session-init` outputs 2 error lines about hooks every session, even though hooks are correctly installed everywhere that matters. This triggers unnecessary investigation and confusion.

## Symptoms

```
Could not resolve hooks dir for linked repo: .issues
Could not resolve hooks dir for linked repo: .opencode/.issues
Failed to install 2 hook(s)
```

Exit code is 0, but the error messages are alarming and prompt user investigation.

## Root Cause

`session-init`'s `install_hooks()` function (line 370) iterates all linked repos. `.issues/` and `.opencode/.issues/` are `issues-data` orphan-branch worktrees whose `.git` files reference paths under `.git/worktrees/` and `.git/modules/.opencode/worktrees/` respectively. These directories have no `hooks/` subdirectory, so `os.path.isdir(hooks_target)` fails on line 398, incrementing `failed_count` on line 403.

## Fix Options

1. **Skip worktrees** — detect that the `.git` reference points to a `worktrees/` directory and skip hook installation (they never need hooks — they're data-only branches)
2. **Create hooks dir** — if missing, create it and install hooks (wasteful but silent)
3. **Downgrade to warning/debug** — don't count these as failures

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)