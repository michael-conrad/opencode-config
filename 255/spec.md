> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Full spec and artifacts:** https://github.com/michael-conrad/opencode-config/tree/issues-data/

## Exec Summary

The pre-work task (`git-workflow/tasks/pre-work.md`) creates the main repo feature branch before submodules are synced to trunk tip, causing the feature branch to carry a stale submodule pointer. When submodule feature branches are later created against the updated submodule tip, the main repo still references the old SHA — producing the "stale commit" problem where the main repo's feature branch points to a submodule commit that doesn't match what the submodule feature branch is working against.

### Cards (dependency order)
1. **Reorder pre-work steps** — Move submodule sync (current Step 3.5) to run BEFORE feature branch creation (current Step 3)
2. **Add submodule feature branch creation** — After the main repo feature branch is created from the updated submodule pointer, create feature branches in each submodule from the tagged commit
3. **Update step numbering** — Renumber all affected steps in pre-work.md to reflect the new ordering
4. **Behavioral enforcement test** — Write a test that verifies the agent syncs submodules before creating the main repo feature branch

### Key Decisions
- **Submodule feature branch from tagged commit, not trunk tip**: The submodule is tagged at trunk tip during sync. The submodule feature branch MUST be created from that tag (not a fresh pull) to guarantee the main repo's submodule pointer and the submodule's working branch reference the same SHA.
- **Single-file change**: Only `skills/git-workflow/tasks/pre-work.md` is modified. No other files need changes.

### Risk Callouts
- **RISK-1: Existing pre-work task files reference step numbers** — Any external references to Step 3 or Step 3.5 in other task files or guidelines will become stale. A grep for cross-references is required before renumbering.
- **RISK-2: Submodule feature branch creation adds new git operations** — The sub-agent must handle the case where a submodule feature branch already exists (e.g., from a prior interrupted session). The branch creation step MUST check for existence before creating.

## Scope

- Reorder steps in `skills/git-workflow/tasks/pre-work.md` so submodule sync precedes feature branch creation
- Add submodule feature branch creation step after main repo feature branch creation
- Update all step numbers and cross-references within the file
- Write a behavioral enforcement test verifying the new ordering

**Out of scope:**
- Changes to submodule sync logic itself (the `--ff-only` divergence handling, tagging format, and result contract are unchanged)
- Changes to other task files or guidelines (cross-reference updates are limited to pre-work.md)
- Changes to worktree mode behavior (the reorder applies equally to direct-branch and worktree modes)

## Approach

The fix reorders three steps in pre-work.md and adds one new step:

1. **Step 2** (unchanged): Sync default branch in main repo
2. **Step 3** (was Step 3.5, moved up): Submodule init/sync to trunk tip, tag each submodule
3. **Step 4** (was Step 3, moved down): Create feature branch in main repo — now from a state with up-to-date submodule pointers
4. **Step 5** (new): Create feature branches in submodules from the tagged commit

The submodule feature branch is created from the tag (not trunk tip) because the main repo's feature branch now references that exact tagged SHA. Creating the submodule branch from trunk tip would re-introduce the stale pointer problem if trunk advanced between the tag and branch creation.

## Affected Files

| File | Change |
|------|--------|
| `skills/git-workflow/tasks/pre-work.md` | Reorder steps: move submodule sync before feature branch creation; add submodule feature branch creation step; renumber all steps |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Submodule sync (current Step 3.5) appears BEFORE feature branch creation (current Step 3) in pre-work.md | `string` | `grep -n "Step 3\|Step 3.5\|Step 4\|submodule" skills/git-workflow/tasks/pre-work.md` — confirm submodule steps precede branch creation in the procedure section |
| SC-2 | Submodule feature branch creation step references the tagged commit, not trunk tip | `string` | `grep -n "tag\|tagged\|checkout.*tag" skills/git-workflow/tasks/pre-work.md` — confirm submodule branch creation uses the tag |
| SC-3 | Behavioral test verifies agent syncs submodules before creating main repo feature branch | `behavioral` | `opencode-cli run` with pre-work scenario; verify stderr shows submodule operations (init, checkout, pull) before `git checkout -b feature/` |
| SC-4 | All step numbers in pre-work.md are internally consistent (no orphan references to old Step 3 or Step 3.5) | `string` | `grep -n "Step 3\|Step 3.5" skills/git-workflow/tasks/pre-work.md` — confirm no remaining references to old step numbers in the procedure section |
| SC-5 | Submodule feature branch creation handles the "already exists" edge case | `string` | `grep -n "branch.*exist\|already exist\|git branch --list" skills/git-workflow/tasks/pre-work.md` — confirm existence check before branch creation |

## Risk Callouts

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | External cross-references to old step numbers (Step 3, Step 3.5) in other files become stale | Medium | Medium | Grep all `.opencode/` files for `Step 3` and `Step 3.5` references before renumbering; update any found | SC-4 |
| RISK-2 | Submodule feature branch already exists from a prior interrupted session | Low | Medium | Add `git branch --list` check before branch creation; skip if exists | SC-5 |
| RISK-3 | Submodule tag push fails (network error, permission) | Low | High | Tag push is already handled by the sub-agent in Step 3; the new submodule branch creation step must verify the tag exists locally before creating the branch | SC-2 |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at the issues-data branch.
After creation, `local-issues sync` MUST be run and the result committed to create the local `.issues/{N}/` entry.
The implementation plan will be created in `.issues/{N}/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

After this spec is approved, invoke `writing-plans` to create `.issues/{N}/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created