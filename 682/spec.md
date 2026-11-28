# [SPEC] Re-architect git-workflow skill — from procedural runbooks to MCP dispatch contracts

**Status:** open (needs approval)
**Canonical source:** local `.issues/682/spec.md`

## Problem

The `git-workflow` skill task files are Junie-converted procedural runbooks containing pseudo-code blocks and manual bash commands. They were designed for a text-based AI that processes steps sequentially with inline tool calls. In an MCP-dispatch environment, every task file read invites a `critical-rules-048` violation (Skill Pre-Read + Inline Execution).

Seven open issues track individual symptoms — each proposing a patch to a broken architecture rather than the architectural fix itself:

| # | Symptom |
|---|---------|
| #232 | check-pr has no submodule awareness |
| #269 | Parent closes while children open |
| #591 | conflict-resolution trigger undefined |
| #597 | SKILL.md references parent AGENTS.md |
| #598 | 5 skill files have dangling AGENTS.md refs |
| #604 | Cleanup asks permission for destructive ops |
| #606 (Gap B) | No-PR cleanup path missing |

This spec supersedes all seven. The architectural fix renders each patch unnecessary.

## Root Cause

Every task file follows this structure: Procedure with numbered steps → pseudo-Python MCP call blocks → bash command blocks → YAML output templates. This forces the agent to read the file into context (violating critical-rules-048), translate pseudo-code to real calls, and reconstruct output from templates. A task file should be a dispatch contract, not a runbook.

## Solution

### Core principle: Task files are dispatch contracts

A task file defines only: **Purpose** (what), **Entry Criteria** (when), **Exit Criteria** (done), **Context Requirements** (must_receive / must_not_receive). It must NOT contain pseudo-code, bash blocks, step-by-step procedures, MCP tool call templates, or structured output templates. The implementing sub-agent autonomously determines HOW by reading governing guidelines, skill cards, and reference documentation.

### Entry-point tasks (10 total)

| Task | Former Name | Function |
|------|-------------|----------|
| `setup-feature` | pre-work | Create branch, sync submodules, init .issues/ |
| `sync-branch` | NEW | Mid-feature dev sync (rebase/merge) |
| `stage-pr` | review-prep | Push, verify readiness, generate URL |
| `create-pr` | pr-creation | Create PR in GitHub |
| `amend-pr` | NEW | Respond to review feedback, re-push |
| `check-pull-requests` | check-pr | Query PR state, trigger cleanup |
| `post-merge-cleanup` | cleanup | Verify merge → clean branches → close issues |
| `release` | release-promotion | Promote dev → main |
| `investigate` | NEW | Investigate/ branch lifecycle |
| `completion` | — | Terminal — every skill exit |

### Internal subtask chains (NOT individually dispatchable)

| Parent | Chain |
|--------|-------|
| `post-merge-cleanup` | `verify-merge` → `branch-cleanup` → `issue-closure` |
| `create-pr` | `squash-push` → `enforcement-gate` → `create-pr` |
| `stage-pr` | `push-and-cleanup` → `report-url` |
| `setup-feature` | (conditional) `provenance` when tag/version tracking needed |

### Standard chains

```
Feature:  setup-feature → [divide-and-conquer: develop] → stage-pr → create-pr
Sync:     sync-branch  (standalone, during develop when dev diverges)
Review:   amend-pr     (standalone — make changes, re-push existing PR branch)
Post-merge: check-pull-requests → post-merge-cleanup
Release:  release
Investigate: investigate
```

### What is removed

- **`implementation` removed from git-workflow** — code edits are not git ops. The chain routes through `divide-and-conquer` for development.
- **Pair branches eliminated entirely** — 5 pair task files deleted. No `pair_mode` context flag. No pair-mode detection. Branch prefix served no enforcement purpose that conversation context didn't already provide.
- **`pre-merge-verification` orphan removed** (67 words, subsumed by verify-merge).
- **`commit-prep` removed** — read-only validation; commit discipline belongs inline in implementation.
- **Word counts removed from SKILL.md card** — an authoring constraint, not a dispatch metric.

### What is kept

- **Direct-branch is universal default.** Worktrees remain as opt-in special case via `WORKTREE_REQUIRED`, handled internally by `setup-feature` dispatching `using-git-worktrees` when set. No worktree-specific tasks.
- **Internal subtasks** (verify-merge, branch-cleanup, issue-closure, squash-push, enforcement-gate, push-and-cleanup, report-url, platform-detection, provenance) remain as files — they are just NOT exposed as independent dispatchable tasks on the SKILL.md card. They are reachable only through their parent task's chain.

### SKILL.md card redesign

The card contains only: Overview (dark-prose-001 confirmshaming identity-frame), Task Card with call patterns + chains, Dispatch Enforcement (dark-prose-003 goal-hijacking consequence-assertion), Sub-Agent Routing table, Cross-References. No Operating Protocol, no word counts, no manual routing rules, no bash/pseudo-code.

### Dark prose

**Overview (dark-prose-001):** "A git operation without a workflow task is an unverified change entering the branch. Dispatch IS the gate — every inline git command that has a corresponding task carries the defect that the task was designed to catch."

**Dispatch Enforcement (dark-prose-003):** "Pre-reading a task file and executing its steps inline bypasses every enforcement gate in that task's contract. A bypassed gate produces unverified output. Unverified output carries the defect the gate was built to catch. A `skill()` call with a `task()` dispatch is the only valid entry path — no valid git workflow completion exists without task dispatch."

## Success Criteria

| SC-ID | Criterion | Verification |
|-------|-----------|-------------|
| SC-1 | SKILL.md card contains only: Overview, Task Card with chains, Dispatch Enforcement, Sub-Agent Routing, Cross-References | Read card, assert no Procedure, Operating Protocol, bash/pseudo-code sections |
| SC-2 | Every task file on disk has removed all pseudo-executable code blocks and procedural step numbering | grep for python/bash code fences and "### Step" returns zero in task files |
| SC-3 | Every task file defines only: Purpose, Entry Criteria, Exit Criteria, Context Requirements | Read 3 sample task files — each has only these sections |
| SC-4 | SKILL.md Task Card has a Chain column for every entry-point task | Read Task Card — chains present for all 10 entry-point tasks |
| SC-5 | Internal subtasks are NOT listed as independent dispatchable tasks on the SKILL.md card | SKILL.md Task Card shows only 10 entry-point tasks |
| SC-6 | Pre-reading task file and inline execution produces agent behavior — sub-agent dispatches independently to fulfill contract | Behavioral test: prompt agent to "check prs" → assert skill() called, task() dispatched, no inline PR query |
| SC-7 | Cleanup pipeline dispatches verify-merge → branch-cleanup → issue-closure as sequential tasks, not inline | Behavioral test: prompt agent through cleanup → assert sequential task dispatches |
| SC-8 | Submodule PR state discovered natively within task dispatch (not bolted-on /command) | Behavioral test: assert agent queries submodule PR state when submodule changes exist |
| SC-9 | SC-against-codebase verification is a dispatchable git-workflow task (callable from cleanup or from approval-gate verify-closed-issue.md) | Behavioral test: prompt agent to verify closed issue SCs → assert git-workflow task dispatched, not inline verify_sc_against_codebase() |
| SC-10 | All superseded issues have `superseded-by` comment referencing this spec | Verify via GitHub API each issue has the comment |

## Files Changed

| File | Change |
|------|--------|
| `skills/git-workflow/SKILL.md` | Full rewrite — dark prose, chains, no protocol/word counts |
| `skills/git-workflow/tasks/*.md` (all except pair-*) | Strip procedure to dispatch contract |
| `skills/git-workflow/tasks/pair-*.md` (5 files) | Deleted |
| `skills/git-workflow/tasks/cleanup/pre-merge-verification.md` | Deleted (orphan) |
| `skills/git-workflow/tasks/commit-prep.md` | Deleted (read-only, no dispatch) |
| `skills/git-workflow/tasks/implementation.md` | Deleted (not git ops) |
| `skills/pr-creation-workflow/SKILL.md` | Routing update to reference git-workflow chains |

## Out of Scope

- Rewriting task files in skills other than git-workflow
- Changes to session-enforcement.ts or git hooks
- Changes to 000-critical-rules.md (reclassified in #624)
- Implementation of adversarial-audit closure-verification (already exists)

## Supersedes

This spec supersedes: #232, #269, #591, #597, #598, #604, #606.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
