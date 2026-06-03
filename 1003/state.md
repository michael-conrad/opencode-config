---
number: 1003
title: "[SPEC] Resolve session-start context conflicts causing agent pre-read cascade and dispatch bypass"
status: promoted
remote_url: https://github.com/michael-conrad/.opencode/issues/1003
labels: [SPEC, needs-design]
created: "2026-06-03T00:00:00Z"
updated: "2026-06-03T00:00:00Z"
github_issue: 1003
author: Michael Conrad
---

# State: Issue #1003

**Branch:** (none yet — spec stage)
**Workflow Phase:** spec-design
**Created:** 2026-06-03
**Last Updated:** 2026-06-03
**Status:** designing

## Current State

Research and brainstorming completed. Card catalogue contains 8 cards covering root cause analysis. Full per-file relocation maps produced for all 14 files in the instructions array via 8 sub-agent analyses.

The spec draft documents:
- Semantic placement principle (not word count)
- Per-file relocation maps (what stays in session start, what moves to which skill)
- Full Tier 2 rule relocation table from 000-critical-rules.md
- Three key changes: delete line 146 contradiction, add startup mode identity, auth as mode switch
- 7 success criteria including preservation of enforcement language

## Open Design Decisions

None at this stage. Ready to promote to full SPEC issue when authorized.

## Blockers

None.