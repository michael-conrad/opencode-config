# Card 019: Pipeline Integration — Removal of Infrastructure References

**Date:** 2026-06-01
**Status:** DESIGNED
**Origin:** Tool encapsulates all worktree management. Pre-work and review-prep no longer need explicit setup/push steps.

## Removed From Pre-Work

Currently at pre-work.md Step 3.7:
- `local-issues setup` (substep 1) — removed. Tool auto-creates worktree on first mutation.
- `local-issues push` (substep 6) — removed. Push-at-gates replaces explicit push steps.
- Stale worktree exit code 2 remediation — removed. Tool auto-remediates internally.

## Removed From Review-Prep

Currently at review-prep.md:
- `local-issues push` (Step 0, line 46-50) — removed. Push-at-gates handles this.
- `push-and-cleanup.md` enforcement checklist row "issues-data branch pushed" — removed. Encapsulated.

## Rationale

First mutation triggers `_ensure_worktree()`. If the worktree is stale, the tool auto-remediates. If it doesn't exist, the tool creates it. If creation fails, the tool falls back to plain files. No agent-facing step needed.

Push-at-gates happen when the skill card calls `local-issues push-body` or the tag mechanism triggers a push. The agent never calls `local-issues push` or `local-issues setup` directly.

## References

- Card-002: worktree model
- Card-004: commit vs push model
- Card-006: graceful fallback