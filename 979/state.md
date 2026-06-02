---
number: 979
title: "[SPEC] Redesign local-issues tool: worktree encapsulation, implicit commit/push, skill-driven issue management"
status: open
labels: [SPEC, needs-approval]
created: "2026-06-01T00:00:00Z"
updated: "2026-06-01T00:00:00Z"
github_issue: 979
author: Michael Conrad
---

# State: Issue #979

**Branch:** (none yet — spec stage)
**Workflow Phase:** spec-design
**Created:** 2026-06-01T00:00:00Z
**Last Updated:** 2026-06-01T23:45:00Z
**Status:** designing

## Current State

Card catalogue contains 11 cards covering:

1. Data model (files + markdown + YAML)
2. Worktree model (single orphan issues-data branch)
3. Architectural layering (orchestrator → dispatcher → sub-skill → CLI)
4. Commit vs push model (per-mutation commit, push-at-gates)
5. Tag convention (format + rules + gate mapping)
6. Graceful fallback (plain files when worktree unavailable)
7. Command surface (pure domain operations)
8. Sync redesign (three disjoint operations unified)
9. Directory naming normalization
10. Creation skill card — three-scenario dispatch (create-local, promote-to-remote, import-remote)
11. Stale worktree remediation — real-world validation

## Recently Completed

- Creation skill card with three-scenario dispatch: create-local (draft), promote-to-remote (promotion), pre-creation (cross-context dedup), import-remote (remote-first mirror)
- Real-world stale worktree remediation: discovered `.issues/` worktree was stale (`.git` link missing). All commits had landed on `dev` instead of `issues-data`. Zero data loss after recovery.
- Worktree now active on `issues-data` with all 979 content migrated.
- Tag `opencode-config/979/spec-created` re-created on correct `issues-data` commit.

## Blockers

None.