> **Full spec and artifacts: [`.issues/1450/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/1450)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1450/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent

Replace the current `<feature → dev → main>` three-branch model with a single-path workflow where all branches are equal and PRs target any branch (defaulting to `main`). Remove mandatory `dev` auto-creation, collapse dual PR workflows into one unified path, standardize commit messaging at squash time, and update the PR body template.

## Problem

The current skill deck enforces a three-branch model where:
1. `dev` is **mandatory** — always auto-created at pre-work if it doesn't exist (~20 lines of conditional creation logic in `pre-work.md`)
2. PRs have two separate paths: feature→dev via `pr-creation-workflow`, release-promotion (dev→main) via `git-workflow --task release-promotion` — each with different rules and squash behavior
3. Dev has special treatment across 15+ files: protection gates, submodule lifecycle management (`submodule-dev-restore`), cleanup logic that switches to dev
4. Squash is conditional: single-issue squashes to one commit; multi-issue work branches keep multiple commits — creating inconsistent history depending on PR scope
5. Commit messages during development can be messy (WIP, fixup) with no standardization at squash time

## Solution Summary

1. **Remove mandatory `dev` bootstrap** — pre-work no longer auto-creates dev; developer explicitly creates it if needed
2. **Unified PR path** — one PR creation path: "branch X to target Y" (e.g., `feature/42-topic → main` or `dev → main`)
3. **Mandatory squash at PR time for all branches** — each squashed commit maps to exactly one GitHub Issue (`#42` → `.issues/42/spec.md`)
4. **Standardized commit messages** — agent generates fresh messages: `#<issue> <title> — <summary>` format from combined diffs
5. **Unified PR body template** — intent, overview, VbC results table, auditor results, spec-card-mapped commits, AI byline
6. **Rebase timing** — before branch creation, before PR creation, double-check remote after push
7. **Branch naming** — existing conventions adapted (no new convention needed)

## Success Criteria

| SC | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Pre-work no longer auto-creates `dev` if it doesn't exist | behavioral | Run pre-work on repo without remote dev; verify no dev created |
| SC-2 | PR creation accepts any target branch (not just `dev`) for feature PRs | semantic + structural | Verify pr-workflow-002 rule removed/updated to allow non-dev targets |
| SC-3 | Squash is mandatory at PR time for ALL branches regardless of issue count | behavioral | Create multi-issue stacked PR; verify all commits squash into one-per-issue |
| SC-4 | Each squashed commit follows `#<issue> <title> — <summary>` format | string + semantic | Grep commit messages in created PR; verify format matches pattern |
| SC-5 | PR body includes intent, overview, VbC results table, auditor results, spec-card-mapped commits, AI byline | structural | Verify all required sections present in generated PR body |
| SC-6 | `dev` has no special treatment — same rules as any other branch | semantic + string | Verify removal of dev-specific rules across git-workflow and pr-creation-workflow skills |
| SC-7 | Release-promotion task removed or unified with standard PR creation | structural | Verify release-promotion.md is either removed or delegates to create-pr |
| SC-8 | Rebase timing: before branch, before PR, double-check remote after push | behavioral | Run full workflow end-to-end; verify rebase at all three points |

## Change Impact (5 Files Modified)

1. **`git-workflow/SKILL.md`** — Remove "three-branch model" definition, remove mandatory dev bootstrap rule, update PR routing table to support any target branch
2. **`pr-creation-workflow/SKILL.md`** — Update Overview line 15 (remove "dev only"), remove pr-workflow-002 enforcement gate (base_branch must be dev), allow any branch as feature PR target
3. **`pre-work.md`** (~lines 93-105) — Remove unconditional `dev` creation logic
4. **`squash-push.md`** — Collapse work-branch/squash-detection into one mandatory squash-at-PR rule for all branches (remove conditional path at lines 41, 60)
5. **`create-pr.md`** — Update PR body template to include intent, overview, VbC results table, auditor results, commit-to-spec-card mapping, AI byline

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Loss of staging buffer without mandatory dev | No automatic staging between feature work and main | Developer explicitly creates `dev` when they want a staging buffer |
| Submodule handling on optional dev | If dev is just another branch, submodule lifecycle applies uniformly rather than being tied to dev-specific logic | Submodule handling remains in existing tasks but applies to whichever branch is active |
| Commit history granularity loss via squash | Intermediate development commits (WIP, fixup) are discarded at squash time | By design — intermediate commits aren't meant for mainline; squashed commit represents one complete change per issue |

## Non-Goals

- Does NOT introduce new submodule synchronization strategies (existing tag-based system remains unchanged)
- Does NOT add parallel branch management complexity (dev is optional, not automatic)
- Does NOT change CI/CD gating logic (already handled by `pre-pr-checklist`)
- Does NOT create new naming conventions for branches beyond adapting existing ones

Co-authored with AI: OpenCode (qwen3.6)