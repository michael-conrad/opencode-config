# Card 010: Skill Card Architecture — Task Decomposition for Local Platform

**Date:** 2026-06-01
**Status:** RESERVED — to be developed during Phase 2
**Origin:** Need to define what skill task cards are needed and what checklists each should follow

## Purpose

This card will be populated during Phase 2 (Platform Sub-Skill Cards) with the complete task decomposition for the local platform sub-skill. It is reserved now to mark the container.

## Anticipated Task Files

| Task File | Wraps CLI Commands | Notes |
|-----------|-------------------|-------|
| `creation.md` | `local-issues create` | Dedup check via `search` first, write body, verify via `read` |
| `read.md` | `local-issues read` | Return issue body + frontmatter |
| `read-comments.md` | `local-issues read-comments` | Return comment text |
| `read-labels.md` | `local-issues read-labels` | Return label array |
| `read-sub-issues.md` | `local-issues read-sub-issues` | Parse `#` refs from comments |
| `update.md` | `local-issues update` | Metadata and/or body updates |
| `comment.md` | `local-issues comment` | Append comment, classification gate |
| `close.md` | `local-issues close` | Move from open/ to closed/ |
| `delete.md` | `local-issues delete` | Permanently remove issue |
| `search.md` | `local-issues search` | Filter by status/label/query |
| `list.md` | `local-issues list` | Status-filtered listing |
| `body-edit.md` | edit remote.md → `local-issues push-body` | Sub-agent pipeline: fetch → transform → verify → post |
| `promote.md` | `local-issues promote` + remote API | Create remote issue from local spec |

## References

- Issue #979 Phase 2
- Card-003: architectural layering
- Existing `local/SKILL.md` capability table