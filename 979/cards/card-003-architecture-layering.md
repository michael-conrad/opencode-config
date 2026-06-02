# Card 003: Architectural Layering — Orchestrator → Dispatcher → Sub-Skill → CLI

**Date:** 2026-06-01
**Status:** DECIDED
**Origin:** Current architecture leaks infrastructure details into agent task files

## The Problem

Currently, agent-facing task files contain inline commands like `local-issues setup`, `local-issues push`, `git add .issues/`, and `git commit`. This means the orchestrating agent must:

- Know about the `issues-data` worktree
- Handle stale worktree detection and remediation
- Know when to push
- Understand the difference between `sync`, `sync-push`, `sync-pull`, and `push`
- Handle exit code 2 (stale worktree) explicitly

This is a leaky abstraction. Every pre-work and review-prep execution requires the agent to understand infrastructure it should not need to know about.

## The Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Orchestrating Agent                     │
│  Calls skill tasks only. Never inline API or git calls.  │
└──────────────┬──────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────┐
│              issue-operations dispatcher                  │
│  Routes to platform sub-skill based on github.platform   │
│  github → github-mcp / gitbucket → gitbucket-api /       │
│  local → local platform sub-skill                        │
└──────────────┬──────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────┐
│              Platform Sub-Skill (e.g., local)             │
│  Defines task files: creation.md, read.md, comment.md... │
│  Each task calls CLI commands and checks results.         │
│  Owns sequencing: create local → promote to remote.       │
└──────────────┬──────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────┐
│              CLI Tool (e.g., local-issues)                │
│  Owns infrastructure: worktree, filesystem, git, pushes. │
│  Pure domain API: create, read, update, close...          │
│  Agent never calls setup, push, or git commands.          │
└──────────────┬──────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────┐
│              Filesystem + Git                             │
│  .issues/ worktree, issues-data branch, markdown files.  │
└─────────────────────────────────────────────────────────┘
```

## Rules

1. **The orchestrator never calls `github_issue_write`, `github_add_issue_comment`, `git push`, `local-issues setup`, or any other inline API or git command.** It calls `issue-operations --task create`, and the dispatcher handles routing.

2. **The dispatcher resolves platform automatically.** No deliberation. `github.platform` determines the route. The orchestrator never decides "should I use local or remote."

3. **Each platform sub-skill owns its task files.** The local platform's `creation.md` knows about `local-issues create`. The GitHub platform's `creation.md` knows about `github_issue_write`. The dispatcher routes to the correct one.

4. **The CLI is the only thing that touches the filesystem or runs git commands.** The sub-skill calls `local-issues create` and checks the exit code and stdout/stderr.

## References

- 060-tool-usage.md §Platform Routing Mandate (Tier 1)
- 000-critical-rules.md §Platform Routing Bypass
- issue-operations/SKILL.md (task routing table)
- Current violations: pre-work.md line 284 (local-issues setup), review-prep.md line 48 (local-issues push), push-and-cleanup.md line 149 (issues-data verification)