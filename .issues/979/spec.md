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

# Synced from GitHub Issue #979 at 2026-06-01T00:00:00Z

## Intent

The local-issues CLI tool and its surrounding skill card architecture have accumulated significant gaps, inconsistencies, and non-functional paths over successive iterations. Rather than patching each defect, a coherent redesign is needed to establish a clean architectural layering: the tool owns infrastructure (worktree management, auto-commit, push-at-gates), the platform sub-skill cards own platform operations (local, GitHub MCP, GitBucket API), and the issue-operations dispatcher owns workflow sequencing. The orchestrating agent never calls API endpoints, git commands, or infrastructure setup directly — it invokes skill tasks that route through the proper sub-skill and tooling.

## Executive Summary

The existing `local-issues` tool (1761 lines) and its `.issues/` worktree system have 11+ identified defects: 3 missing CLI commands that break local-platform dispatch (`read-comments`, `read-labels`, `read-sub-issues`), a non-functional `sync` command umbrella, silent GitBucket body-sync failure, directory naming inconsistencies across 5 task files, 3 fixture directories invisible to `_find_issue`, and zero behavioral RED-GREEN tests. The tool attempts to expose infrastructure details (worktree setup, push, migration) to agent-facing task files, creating a leaky abstraction where agents must know about `issues-data` branches, worktree stale detection, and push mechanics.

The redesign encapsulates all infrastructure complexity inside the tool. The agent's interface is pure domain operations: `local-issues create`, `read`, `update`, `comment`, `close`, `search`, `list`, `push-body`, `pull-body`. Under the hood, the tool transparently manages the `issues-data` worktree (setup, stale remediation, auto-commit after every mutation, push-at-gates via tags). If the worktree cannot be established, the tool gracefully falls back to writing `.issues/` as plain files on the current feature branch, migrating into the worktree when it becomes available.

The worktree model uses a single orphan `issues-data` branch — not per-issue branches, which were considered but rejected as unwieldy and error-prone. Tags at each gate (pre-work, GREEN VbC, audit pass, code review) provide durable checkpoints that survive branch deletion and force-push. Push happens at those same gates, not on every mutation.

The skill card architecture follows: orchestrator → `issue-operations` dispatcher → platform sub-skill → CLI tool → filesystem + git. The orchestrator never makes inline API calls or git commands. The dispatcher routes to the correct platform sub-skill based on `github.platform`. Each platform sub-skill wraps a CLI (local-issues, gh, gitbucket-api). The CLI is the only thing that touches the filesystem.

## Design Decisions (Recorded)

A full card catalogue of all design decisions, research findings, and ruminations from the redesign discussion is stored in the `.issues/979/cards/` sub-directory.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/tools/local-issues` | Full rewrite: add `read-comments`, `read-labels`, `read-sub-issues`, `push-body`, `pull-body`, `delete`; remove `setup`, `sync` umbrella; add transparent worktree management; add auto-commit; add push-at-gates; add graceful fallback; add tag creation; add conflict resolution sub-agent trigger |
| `.opencode/skills/issue-operations/platforms/local/SKILL.md` | Update capability table and task routing |
| `.opencode/skills/issue-operations/tasks/creation.md` | Remove inline local-issues command calls; route through platform dispatcher |
| `.opencode/skills/issue-operations/tasks/read-issue.md` | Same |
| `.opencode/skills/issue-operations/tasks/read-comments.md` | Same |
| `.opencode/skills/issue-operations/tasks/read-labels.md` | Same |
| `.opencode/skills/issue-operations/tasks/read-sub-issues.md` | Same |
| `.opencode/skills/issue-operations/tasks/update-issue.md` | Same |
| `.opencode/skills/issue-operations/tasks/comment.md` | Remove `local-issues sync push` references |
| `.opencode/skills/issue-operations/tasks/body-edit.md` | Remove manual push/setup steps |
| `.opencode/skills/issue-operations/tasks/close.md` | Route through platform dispatcher |
| `.opencode/skills/issue-operations/tasks/search-issues.md` | Same |
| `.opencode/skills/issue-operations/tasks/list-issues.md` | Same |
| `.opencode/skills/issue-operations/tasks/sync-pull-to-local.md` | Simplify — no manual setup |
| `.opencode/skills/issue-operations/tasks/import-remote.md` | Same |
| `.opencode/skills/git-workflow/tasks/pre-work.md` | Remove `local-issues setup` and `local-issues push` substeps — encapsulated |
| `.opencode/skills/git-workflow/tasks/review-prep.md` | Remove `local-issues push` step — encapsulated |
| `.opencode/skills/git-workflow/tasks/review-prep/push-and-cleanup.md` | Remove issues-data verification row — encapsulated |
| `.opencode/tests/test_local_issues.py` | Rewrite for new command surface |
| `.opencode/tests/test_local_issues_setup.py` | Rewrite or remove (setup is now internal) |
| `.opencode/tests/behaviors/` | Add behavioral RED-GREEN tests |

## Phases

### Phase 1: Tool Rewrite

Full rewrite of `local-issues` with the new architecture. RED-before-GREEN for the full command surface. Transparent worktree management, auto-commit, tag creation, push-at-gates, graceful fallback.

### Phase 2: Platform Sub-Skill Cards

Update `local/SKILL.md` and each local-platform task file to wrap the new CLI commands cleanly. Remove inline infrastructure calls.

### Phase 3: Dispatcher + Workflow Integration

Update `issue-operations` dispatcher and remove infrastructure references from `git-workflow` tasks (pre-work, review-prep, push-and-cleanup).

### Phase 4: Behavioral Tests

Add behavioral RED-GREEN tests for the full local-platform command surface.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `local-issues create` works without `.issues/` worktree (creates plain files on feature branch) | behavioral |
| SC-2 | `local-issues create` transparently creates worktree if possible, falls back gracefully if not | behavioral |
| SC-3 | `local-issues read N`, `read-comments N`, `read-labels N`, `read-sub-issues N` all work | behavioral |
| SC-4 | `local-issues update N --body "..."` updates spec.md body | behavioral |
| SC-5 | `local-issues close N` moves issue from open/ to closed/ | behavioral |
| SC-6 | `local-issues push-body N` pushes local remote.md to remote (GitHub + GitBucket) | behavioral |
| SC-7 | `local-issues pull-body N` pulls remote body to local remote.md | behavioral |
| SC-8 | `local-issues delete N` removes issue directory | behavioral |
| SC-9 | Every mutation auto-commits on issues-data (when worktree active) | string |
| SC-10 | Tag created at each gate: `<parent-repo>/<issue>/<phase>` | behavioral |
| SC-11 | Push-at-gates: pre-work, VbC GREEN, audit pass, code review | string |
| SC-12 | Orphan issues-data worktree survives re-setup (idempotent) | behavioral |
| SC-13 | Stale worktree detected and auto-remediated | behavioral |
| SC-14 | Plain-file fallback migrates into worktree when it becomes available | behavioral |
| SC-15 | Skill cards call no inline local-issues setup or push commands | string |
| SC-16 | `local-issues search`, `list` work correctly | behavioral |
| SC-17 | Directory naming follows consistent `{number:03d}-{slug}` everywhere | string |

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created