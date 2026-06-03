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
**Last Updated:** 2026-06-01T00:00:00Z
**Status:** designing

## Current State

Spec being designed interactively. Card catalogue contains 11 cards covering:

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
11. (reserved for next topic)

## Recently Completed

- Designed `creation.md` dispatcher with three scenarios
- Designed `create-local` (draft), `promote-to-remote` (promotion), `pre-creation` (dedup), and `import-remote` (remote-first) tasks
- Established gate pattern: internal gates in task, cross-context gates as separate sub-agents

## Blockers

None.