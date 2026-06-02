# Card 005: Tag Convention — Durable Checkpoints at Pipeline Gates

**Date:** 2026-06-01
**Status:** DECIDED
**Origin:** Need for recoverable named checkpoints that survive branch deletion

## Convention

Tags follow the format:

```
<parent-repo>/<issue>/<phase>-<stage>
```

### Examples

| Gate | Tag | Tagged On |
|------|-----|-----------|
| Pre-work setup complete | `opencode-config/979/pre-work` | issues-data commit after setup |
| VbC GREEN passed | `opencode-config/979/vbc-green` | issues-data commit after VbC |
| Dual audit passed | `opencode-config/979/audit-passed` | issues-data commit after audit |
| Code review ready | `opencode-config/979/review-ready` | issues-data commit after review-prep |

### Rules

1. **Tags are created on the `issues-data` branch**, not on feature branches. Tags are pushed to the `issues-data` remote at the same gates as push.
2. **Tags are permanent.** Once created, they are never moved, deleted, or overwritten. Each gate produces a new tag with a unique name.
3. **Tags are visible from the parent repo** because they reference SHAs on the `issues-data` branch that exist in the worktree. The parent repo sees them via `git tag -l "opencode-config/979/*"`.
4. **Retroactive tags:** If a gate was already passed before the tag system was in place, the tag can be created retroactively pointing to the merge commit or the relevant issues-data HEAD at that time.

## Why Tags, Not Branch Names

- Tags survive `git branch -D` and `git push --force`
- Tags are immutable — they always point to the same SHA
- Tags are discoverable via `git tag -l "<pattern>"`
- Tags don't create stale refs in remote listing

## Why Not Annotations

Lightweight tags are sufficient. Annotated tags (with messages) could be used for audit gates to include the audit verdict in the tag message, but the minimum viable approach is lightweight tags.

## References

- Card-002: worktree model (tags as durability mechanism)
- Card-004: commit vs push model (tags pushed at same gates)