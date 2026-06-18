# [SPEC-FIX] check-pr: fix phase ordering

**Spec URL:** https://github.com/michael-conrad/.opencode/issues/1266

## Bug

The 6-phase serial chain in `check-pr.md` has a workflow ordering defect. Phase 3 (clean up branches) operates on the parent repo before Phase 5 (submodule reconciliation). Submodule cleanup should precede parent cleanup to avoid dangling references and ensure submodule branches are removed before the parent's own branch sweep. Additionally, Phase 6 (final state) does not iterate across all discovered repos depth-first, and lacks the explicit admonishment that dirty submodule pointers post-cleanup are expected — they prep the workspace for the next development cycle.

### Root Cause

The phase ordering was validated by Z3 contract for correct serial dependency (Phase N requires Phase N-1), but the relative ordering of concerns was not validated against the workflow requirement "clean submodules before parent."

## Fix

Reorder phases and expand iteration scope:

### Phase Structure (Revised)

Phase 1: Scan for Merged PRs (all repos — parent + submodules)
    ↓
Phase 2: Verify Each Merge (per-repo iteration)
    ↓
Phase 3: Close Linked Issues (depth-first: sub-repos first, then parent)
    ↓
Phase 4: Submodule Branch Cleanup (iterate submodules: switch to dev, delete branches, delete checkpoint tags, prune)
    ↓
Phase 5: Parent Branch Cleanup (switch parent to dev, delete branches, delete checkpoint tags, prune)
    ↓
Phase 6: Depth-First Final State (iterate ALL discovered repos depth-first: submodule tips, then parent tip)
    → Each repo: branch-aware parking based on current branch type
    → Parent repo: dirty submodule pointers are EXPECTED — they resolve on next pre-work cycle. Do NOT attempt to fix them. This is the prepped state for the next development cycle.

### Key Design Changes

1. Phase 3 (issue closure) moves before branch cleanup — issues cross-reference PRs and branches. Close them while branch references still exist, then delete branches.
2. Phase 4 (submodule cleanup) runs before Phase 5 (parent cleanup) — submodule branches deleted before parent branch deletion.
3. Phase 6 iterates depth-first — submodules first, then parent. Each repo gets branch-aware parking per its current branch type at that point in the iteration.
4. Phase 6 includes the dirty-pointer admonishment — "Submodule pointers in the parent repo are dirty by design. They are restored during the next pre-work cycle (submodule-tag-prework). Do NOT commit, reset, or otherwise correct them."

## SCs

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Phase 3 (close issues) precedes branch cleanup phases | string |
| SC-2 | Phase 4 (submodule cleanup) precedes Phase 5 (parent cleanup) | string |
| SC-3 | Phase 4 iterates all submodule repos: dev switch, branch delete, tag delete, prune | string |
| SC-4 | Phase 5 handles parent repo only: dev switch, branch delete, checkpoint-tag delete, prune | string |
| SC-5 | Phase 6 iterates depth-first: submodules first, then parent | string |
| SC-6 | Phase 6 includes explicit admonishment that dirty submodule pointers are expected and must NOT be corrected | string |
| SC-7 | Phase 3 issues are closed cross-repo depth-first | string |
| SC-8 | Sub-agent executing the revised card produces correct depth-first cleanup ordering | behavioral |
