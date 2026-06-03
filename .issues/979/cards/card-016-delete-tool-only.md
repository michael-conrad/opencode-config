# Card 016: Delete — Tool-Only, Safety Guard for Linked Issues

**Date:** 2026-06-01
**Status:** DESIGNED
**Origin:** Delete is a tool-level CLI command for cleanup, not a normal agent workflow operation. No skill card needed.

## Tool Interface

```
local-issues delete N [--force]
```

## Tool Operations

1. Verify issue exists. If not → exit 1.
2. If `github_issue` frontmatter field is set and `--force` is NOT provided:
   - Print warning: "Remote issue <R> exists at <url>. Use --force to remove local mirror only."
   - Exit 2 (blocked — needs explicit force).
3. If `--force` or no remote link:
   - `rm -rf .issues/open/NNN-slug/` or `.issues/closed/NNN-slug/`
   - Auto-commit on issues-data.
   - Exit 0.

## Safety Design

- Without `--force`, delete refuses if the issue has a remote link. This prevents accidental destruction of a local mirror that has stakeholder data on the remote.
- With `--force`, delete removes only the local mirror. The remote issue is untouched.
- No skill card for delete. It's a tool-only operation for manual cleanup, not part of normal agent workflow.

## References

- Card-010: creation skill card (delete is the inverse of creation — only needed for cleanup)