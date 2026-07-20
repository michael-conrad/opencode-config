> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Full spec and artifacts: [`.issues/{N}/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/{N})** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.

## Exec Summary

The agent repeatedly develops against a stale commit because the pre-work sync is a one-time event at branch creation. When other PRs merge to the default branch during the implementation window, the feature branch becomes behind. The push has no "rebase before push" gate, so the branch reaches the remote already stale — producing merge conflicts at PR time.

### Cards (dependency order)
1. **Add rebase-before-push gate to `commit-prep.md`** — Insert a mandatory rebase step that fetches default branch HEAD, checks if feature branch is behind, rebases if needed, and verifies no conflicts
2. **Add rebase-before-push gate to `create-pr.md`** — Ensure the existing Step 4.8 rebase is mandatory and gated (it already exists but needs enforcement hardening)
3. **Update `SKILL.md` dispatch table** — If a new `rebase-before-push` task is created, add it to the dispatch table; otherwise update the `implementation` task description
4. **Behavioral enforcement test** — Write a behavioral test that verifies the agent rebases before push when behind default branch

### Key Decisions
- **Gate placement in commit-prep, not a new task**: The rebase-before-push gate belongs in the existing commit-prep task (which is the read-only analysis phase before any commit/push) rather than creating a standalone task. This minimizes dispatch table changes and keeps the gate where the push decision is made.
- **Stderr-based behavioral evidence**: The behavioral test uses `assert_stderr_pattern_present` on stderr for `git fetch origin`, `git rebase`, and `git rebase --abort` patterns — not prose-recall prompts.

### Risk Callouts
- **Risk: Rebase on pushed branch** — If the feature branch has already been pushed, rebasing creates divergence. Mitigation: The gate checks if the branch is behind BEFORE rebasing, and only rebases if needed. If already pushed, use `--force-with-lease` (requires authorization per `000-critical-rules.md` §critical-rules-026).
- **Risk: Conflict resolution stalls the workflow** — If rebase produces conflicts, the gate must HALT and report, not auto-resolve. Mitigation: The gate verifies no conflicts after rebase and blocks push if conflicts exist.

## Problem

The agent repeatedly develops against a stale commit. The workflow is:

1. Pre-work syncs the default branch and creates a feature branch from it
2. The agent implements changes on the feature branch
3. Meanwhile, other PRs merge to the default branch
4. The agent pushes the feature branch — which is now behind the default branch
5. The PR shows merge conflicts

The pre-work step (`git-workflow/tasks/pre-work.md` Step 2) syncs the default branch before branch creation. But there is no mandatory re-sync step before push. The branch is created from a point-in-time snapshot, and if other PRs merge in the meantime, the branch becomes stale.

## Root Cause Analysis

The commit/push workflow has no "rebase before push" gate. Specifically:

- `git-workflow/tasks/commit-prep.md` — Read-only analysis phase. Discovers changes and creates a commit script. Has no rebase step.
- `git-workflow/tasks/pr-creation/create-pr.md` — Has a Step 4.8 "Rebase Before PR Creation" and Step 6.1 "Rebase After Push", but these fire only during PR creation, not during intermediate pushes. The `implementation` task (which handles commits/pushes during development) has no rebase gate.
- `git-workflow/SKILL.md` — The `implementation` task dispatch has no rebase-before-push context.

The pre-work sync is a one-time event at branch creation — it does not protect against default branch advancement during the implementation window.

## Scope

**In scope:**
- Add a mandatory rebase-before-push gate to `commit-prep.md` that fetches default branch HEAD, checks if behind, rebases if needed, and verifies no conflicts
- Harden the existing rebase step in `create-pr.md` (Step 4.8) to be a mandatory gate with conflict verification
- Update `SKILL.md` dispatch table if a new task is needed
- Write a behavioral enforcement test

**Out of scope:**
- Auto-resolving rebase conflicts — the gate MUST HALT on conflicts
- Changing the pre-work sync behavior — pre-work syncs at creation time; this spec adds a delivery-time gate
- Adding a standalone `rebase-before-push` task — the gate lives in existing tasks

## Approach

Add a mandatory rebase-before-push gate to the commit-prep task that:

1. Fetches the latest default branch HEAD: `git fetch origin $DEFAULT_BRANCH`
2. Checks if the feature branch is behind: `git rev-list --count $DEFAULT_BRANCH..HEAD` — if count > 0, the branch is ahead (no rebase needed); if `HEAD..$DEFAULT_BRANCH` count > 0, the branch is behind
3. Rebases if behind: `git rebase origin/$DEFAULT_BRANCH`
4. Verifies no conflicts after rebase: `git diff --name-only --diff-filter=U` — if non-empty, HALT with conflict report
5. Only then proceeds to push

In `create-pr.md`, the existing Step 4.8 rebase is already present but needs:
- A conflict verification step after rebase (currently missing)
- A gate that blocks PR creation if conflicts exist

## Impact

- **Positive**: Eliminates stale-branch merge conflicts at PR time
- **Positive**: Catches integration issues early (during development, not at PR review)
- **Risk**: Rebasing a pushed branch creates divergence — mitigated by checking if branch was already pushed before rebase, and using `--force-with-lease` with authorization
- **Risk**: Rebasing mid-feature can be disruptive — mitigated by the gate being in commit-prep (which runs before every commit/push), not mid-implementation

## Files to Modify

| File | Change | Type |
|------|--------|------|
| `skills/git-workflow/tasks/commit-prep.md` | Add rebase-before-push gate after Step 1 (Discovery) and before Step 2 (Summarize Changes) | Add gate |
| `skills/git-workflow/tasks/pr-creation/create-pr.md` | Harden Step 4.8 with conflict verification gate; add conflict-HALT after rebase | Harden gate |
| `skills/git-workflow/SKILL.md` | Update `implementation` task description if needed; no new task entry required | Minor update |
| `.opencode/tests/behaviors/rebase-before-push.sh` | New behavioral enforcement test | New file |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `commit-prep.md` includes a rebase-before-push gate that fetches default branch and rebases if behind | `string` | `grep` for `git fetch origin` and `git rebase` in `commit-prep.md` |
| SC-2 | Push is blocked if rebase produces conflicts — conflict check present after rebase | `string` | `grep` for `diff-filter=U` or equivalent conflict check in `commit-prep.md` |
| SC-3 | `create-pr.md` Step 4.8 includes conflict verification after rebase | `string` | `grep` for conflict check after rebase in `create-pr.md` |
| SC-4 | Behavioral test verifies agent rebases before push when behind default branch | `behavioral` | `opencode-cli run` with scenario: agent on stale branch, push command, verify stderr shows `git fetch origin` and `git rebase` via `assert_stderr_pattern_present` |
| SC-5 | Behavioral test verifies agent HALTS (does not push) when rebase produces conflicts | `behavioral` | `opencode-cli run` with scenario: agent on branch with simulated conflict, verify stderr shows HALT/blocker pattern, no push attempted |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.issues/{N}/plan.md` before implementation begins.

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Gate in commit-prep, not standalone task | Minimizes dispatch table changes; keeps gate where push decision is made | MUST | SC-1, SC-2 |
| DEC-2 | Conflict check uses `git diff --name-only --diff-filter=U` | Standard git porcelain for detecting unmerged paths | MUST | SC-2, SC-3 |
| DEC-3 | Behavioral test uses stderr assertions, not prose-recall | Per `080-code-standards.md` §Rule 5 — stderr is behavioral evidence; stdout prose is not | MUST | SC-4, SC-5 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Rebasing a pushed branch creates divergence | Medium | High | Check if branch was pushed before rebase; use `--force-with-lease` with authorization | SC-1 |
| RISK-2 | Conflict resolution stalls the workflow | Medium | Medium | Gate HALTS on conflict — does not auto-resolve; developer must resolve manually | SC-2, SC-5 |
| RISK-3 | Behavioral test flakes due to git state | Low | Medium | Test creates isolated git repo with controlled state; no dependency on remote | SC-4, SC-5 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Regression Invariants

1. Existing pre-work sync behavior MUST remain unchanged — pre-work still syncs at creation time
2. Existing PR creation rebase steps (Step 4.8, Step 6.1) MUST remain in `create-pr.md`
3. The `implementation` task MUST NOT be removed or renamed

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read skills/git-workflow/tasks/commit-prep.md` | Understand existing commit-prep flow |
| Direct source search | `read skills/git-workflow/tasks/pr-creation/create-pr.md` | Understand existing rebase steps |
| Direct source search | `read skills/git-workflow/SKILL.md` | Understand dispatch table and task structure |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.issues/{N}/`.
After creation, `local-issues sync {N}` MUST be run and the result committed to create the local `.issues/{N}/` entry.
The implementation plan will be created in `.issues/{N}/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)