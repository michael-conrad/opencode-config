---
number: 979
title: "[SPEC] Redesign local-issues tool: worktree encapsulation, implicit commit/push, skill-driven issue management"
status: open
labels: [SPEC, needs-approval]
created: "2026-06-01T00:00:00Z"
updated: "2026-06-02T00:15:00Z"
github_issue: 979
author: Michael Conrad
---

# State: Issue #979

**Branch:** (none yet — spec stage)
**Workflow Phase:** spec-design
**Created:** 2026-06-01T00:00:00Z
**Last Updated:** 2026-06-02T00:15:00Z
**Status:** designing

## Current State

Full design scope covered across 21 cards. All layers from tool internals through skill cards to pipeline integration are specified. The remaining work is Phase 1 (tool rewrite) — implementation of the CLI tool based on these design decisions.

## Card Catalogue (21 cards)

| # | Card | Area |
|---|------|------|
| 1 | Data model | Tool — files + markdown + YAML |
| 2 | Worktree model | Tool — single orphan issues-data branch |
| 3 | Architectural layering | Architecture — orchestrator → dispatcher → sub-skill → CLI |
| 4 | Commit vs push model | Tool — per-mutation commit, push-at-gates |
| 5 | Tag convention | Tool — format + rules + gate mapping |
| 6 | Graceful fallback | Tool — plain files when worktree unavailable |
| 7 | Command surface | Tool — pure domain operations |
| 8 | Sync redesign | Tool — push-body / pull-body replaces dead sync umbrella |
| 9 | Directory naming normalization | Task files — consistent {number:03d}-{slug} |
| 10 | Creation skill card | Skill — three-scenario dispatch |
| 11 | Stale worktree remediation | Tool — real-world validation of remediation logic |
| 12 | links.yaml + YAML reads | Tool + Skill — YAML output format for all read operations |
| 13 | Update separate from push-body | Skill — spec.md vs remote.md separation |
| 14 | Comment type flag | Tool + Skill — default internal, explicit stakeholder |
| 15 | Close task | Skill — local mutation, separate remote sync |
| 16 | Delete tool-only | Tool — safety guard for linked issues |
| 17 | Search/list YAML output | Tool — YAML output, minimal changes |
| 18 | Body-edit pipeline | Skill — four-phase sub-agent sequence |
| 19 | Pipeline integration removal | Integration — setup/push removed from pre-work/review-prep |
| 20 | Local SKILL.md capability contract | Architecture — routing contract between dispatcher and platform |
| 21 | Tag-gate reusable task | Skill — shared gate checkpoint task |

## Blockers

None.