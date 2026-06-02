# Card 004: Commit vs Push — Per-Mutation Commit, Push-at-Gates

**Date:** 2026-06-01
**Status:** DECIDED
**Origin:** Balancing data durability vs network overhead

## The Problem

Every mutation (create, update, comment, close) changes files in the `.issues/` worktree. These changes must be durable (survive local crashes, feature branch resets) but don't need to be visible on the remote `issues-data` branch immediately. Pushing after every mutation adds latency and network dependency.

## Decision

**Commit every mutation locally on `issues-data`; push only at pipeline gates.**

| Operation | Commit | Push |
|-----------|--------|------|
| `create` | ✅ | ❌ |
| `update` | ✅ | ❌ |
| `comment` | ✅ | ❌ |
| `close` | ✅ | ❌ |
| `delete` | ✅ | ❌ |
| Pre-work setup | ✅ | ✅ (establish remote) |
| VbC GREEN pass | — | ✅ |
| Audit pass | — | ✅ |
| Code review / review-prep | — | ✅ |

## Rationale

1. **Commit = data durability.** Once committed on `issues-data`, the data survives feature branch deletion, reset, and local crashes. Only catastrophic `.opencode` submodule re-clone before push can lose it.

2. **Push at gates = remote checkpoint.** Each gate represents a meaningful milestone. The remote `issues-data` branch reflects validated work, not WIP.

3. **Between gates, local commits are sufficient** because the agent is the only writer to `issues-data` during a given session. No collaboration conflict exists.

## Edge Case: Submodule Re-Clone

If the `.opencode` submodule is re-cloned between gates (losing the local `issues-data` branch), committed-but-unpushed data is lost. Mitigation: tags are pushed at the same gates, so tag-specified checkpoints survive. The unbounded loss is only WIP commits since the last gate — which is bounded by the gate interval and by the corresponding feature branch holding a copy of `.issues/` in its own working tree state.

## References

- git-workflow pipeline: pre-work → implementation → VbC → audit → review-prep
- Tag convention: card-007-tags.md