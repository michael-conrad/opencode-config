---
number: 5
title: "Fix: Local .issues/ drafts invisible for developer review/approval"
status: open
labels: [SPEC-FIX, needs-approval]
created: "2026-04-25T14:35:00Z"
updated: "2026-04-25T14:35:00Z"
github_issue: 62
author: michael-conrad
---

## Objective

When the agent creates a spec in the local `.issues/` directory (because `github.platform` is unset, no remote is configured, or the agent chooses local drafting), the developer has **no discoverable path** to review, comment on, or approve it. The spec exists in `.issues/open/NNN-slug/spec.md`, but:

- It is invisible to `issue-review` skill (which only reads GitHub/GitBucket)
- It is invisible to GitHub search and deduplication
- No human-facing notification signals "a spec needs your review"
- The developer cannot use standard collaboration tools (comments, labels, reactions)

This breaks the spec-first workflow silently.

## Root Cause

### Design Gap: Review/Approval as a Local-First Activity

The existing skills treat `github.platform == local` as a **fallback** — "we have no remote, so we file things locally." But review and approval **must happen regardless of remote**.

The gap is a missing layer in the local platform architecture:

```
Skill layer:
  issue-operations → creation → comment → close
  issue-review     → gather → triage → audit/QA

Platform layer:
  github-mcp       ✅ full API (create, read, search, review)
  gitbucket-api    ✅ partial API + fallbacks
  local            🚨 create, read, close — but NO review, NO comment, NO search
```

### Concrete Skill Deficiencies

1. **`local` platform: no review/read path for humans.**
   The `.opencode/tools/local-issues` CLI has `read` and `comment` subcommands, but they are **not invoked by any skill**. An agent calling `issue-review` triggers `gather` → GitHub API. A developer wanting to see a spec must `cat .issues/open/NNN-slug/spec.md` manually.

2. **`issue-review` skill: hard-coded to remote APIs.**
   Every task in `issue-review` (`gather`, `triage`, `audit`, `QA`) uses `github_issue_read` or `gitbucket-api`. There is no `local` equivalent.

3. **`issue-operations` creation task: no promotion signal.**
   Creation produces the spec file and stops. No message goes to chat explaining where the spec is, what its number is, and how the developer can review it.

4. **`issue-operations` deduplication: local specs invisible.**
   When a creator searches for duplicate specs (`Step 0.5` in `creation.md`), the search queries GitHub API. Local specs are never found, leading to duplicate local drafts.

## Platform Agnostic Scope

This fix is **not GitHub-specific**. It must work for:

| Platform | Review/Approval Problem |
|----------|------------------------|
| `github` | No issues on GitHub to review; local `.issues/` is parallel hidden state |
| `gitbucket` | No issues on GitBucket to review; local `.issues/` is parallel hidden state |
| `local` | Even more critical — `.issues/` is the ONLY reviewable artifact |

## Fix Approach: Reviewability Layer for Local Platform

### Phase 1: Add Review/Comment Tasks to Local Platform Skill

**In `.opencode/skills/issue-operations/platforms/local/SKILL.md`,** add `review` and `comment` sections:

```
review  NNN       — Pretty-print spec to stdout (markdown renderable)
comment NNN --body TEXT  — Append comment to comments.md with timestamp
```

### Phase 2: Upgrade `issue-operations` Creation Task

**After `local-issues create`,** the creation task must always produce a **human-visible signal**:

```
"Created local issue #<N>: <title>
  Path: .issues/open/NNN-slug/spec.md
  Review: cat .issues/open/NNN-slug/spec.md
  Comment: local-issues comment <N> --body 'approved'
  Approve: local-issues update <N> --status approved"
```

This goes to **chat** (not the issue) so the developer sees it immediately.

### Phase 3: Upgrade `issue-review` Gather Task for Local

Modify `issue-review` `gather` task to detect `github.platform` and, if `local`, use `local-issues read` instead of `github_issue_read`.

### Phase 4: Deduplication Covers Local Specs

Modify `issue-operations` `pre-creation` dedup table to search `.issues/open/` via `local-issues search` in addition to the remote API.

## Success Criteria

| SC | Criterion | Verification |
|----|-----------|------------|
| SC-1 | Creating a local spec prints review instructions to chat | Read chat output after `issue-operations --task creation` on local platform |
| SC-2 | `issue-review --issue N` reads local spec when `github.platform == local` | `gather` task reads `.issues/open/NNN-slug/spec.md` without error |
| SC-3 | Developer can add comment to local spec via `local-issues comment` | `comments.md` is appended with the comment text and timestamp |
| SC-4 | Pre-creation dedup finds existing local specs | `pre-creation` search includes `local-issues search` output |
| SC-5 | No duplicate local specs for the same objective | Creating same-title spec twice is rejected by dedup |

## Risk

| Risk | Mitigation |
|------|------------|
| Breaking existing remote-only workflow | Changes are additive; remote paths unchanged |
| Local spec numbering conflicts | Continue using `.counter` file with locking |
| Manual `cat`/`local-issues` commands feel low-tech | Better than invisible specs; future UI can wrap CLI |

## Related

- Root cause in `issue-operations` `creation.md` and `local/SKILL.md`
- Affects `issue-review` `gather` task
- Affects `approval-gate` discovery: local specs need review before authorization

## Verification Log

| Date | Action | Result |
|------|--------|--------|
| 2026-04-25 | Read `.issues/` structure | Found 4 open local specs in `.opencode/.issues/` |
| 2026-04-25 | Read `local-issues` CLI source | Confirmed `read` and `comment` commands exist but unused by skills |
| 2026-04-25 | Read `issue-review/SKILL.md` | Confirmed all paths call `github_issue_read` only |
| 2026-04-25 | Read `issue-operations/creation.md` | Confirmed no local promotion/instruction signal after creation |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)