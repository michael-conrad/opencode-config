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
**Workflow Phase:** spec-created
**Created:** 2026-06-01T00:00:00Z
**Last Updated:** 2026-06-01T00:00:00Z
**Status:** initialized

## Current State

Spec created with full card catalogue of design decisions. Contains 10 cards covering:

1. Data model (files + markdown + YAML)
2. Worktree model (single orphan issues-data branch)
3. Architectural layering (orchestrator → dispatcher → sub-skill → CLI)
4. Commit vs push model (per-mutation commit, push-at-gates)
5. Tag convention (format + rules + gate mapping)
6. Graceful fallback (plain files when worktree unavailable)
7. Command surface (pure domain operations)
8. Sync redesign (three disjoint operations unified)
9. Directory naming normalization
10. Skill card architecture (reserved for Phase 2)

## Blockers

None.