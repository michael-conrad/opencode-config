> Full spec and plan artifacts: https://github.com/michael-conrad/opencode-config/tree/issues-data/.issues/366/

## Problem

The `.opencode` submodule pointer in the parent repo is stale (pointing to pre-PR #2377 `aa2426f3`) while the working tree has the post-merge pointer (`babf358e`), and AGENTS.md on `main` still references the old default test model `qwen3.6:35b-256k`. This admin sync commits both pending changes together in the same parent-repo commit.

## Root Cause / Motivation

PR #2377 (merged into `.opencode` submodule) updated the default test model to `ollama/qwen3.8:27b-256k`. The submodule pointer was updated in the working tree but never committed to the parent repo's `main` branch. AGENTS.md was updated on `feature/2376-update-default-test-model` (commit `f1295eef`) to reference the new model, but that change also has not reached `main`. Both are necessary before the next feature branch works against aligned state.

## Approach Chosen

Single commit on `main` that updates the `.opencode` submodule pointer to `babf358e` and the AGENTS.md model reference on line 86. The pointer update and the doc change share one commit because submodule-only pushes are blocked by pre-push hooks.

## Alternatives Considered & Why Discarded

- **Separate commits for pointer and doc:** Rejected — pre-push hooks block submodule-only pushes, so the pointer cannot be committed in a standalone commit/PR. The two changes must ride together.
- **Cherry-pick f1295eef onto main then update pointer separately:** Rejected — needlessly complex for a two-line change that the branch already has correct.

## Key Design Decisions

- **Single commit for both changes:** Submodule pointer updates must ride alongside parent-repo changes per the AGENTS.md convention. Pre-push hooks enforce this — a pointer-only commit is rejected.
- **No separate PR for this change:** The branch already contains the necessary changes. The deliverable is a squash-merge to `main`.

## User Intent / Original Prompt

Sync the parent repo's submodule pointer and AGENTS.md after PR #2377 merged in the `.opencode` submodule, so that subsequent feature branches start from aligned state.

## Not Included

- **No behavioral test changes** — Existing behavioral tests (test-2376-sc1-red.sh, test-2376-sc2-red.sh, test-2376-sc3-red.sh, default-model.sh) already exist in the submodule. No new tests needed.
- **No submodule content changes** — The submodule content is already correct (PR #2377 merged). Only the parent-repo pointer needs updating.
- **No other doc file updates** — Only AGENTS.md line 86; no other documentation files are touched.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|--------------|-------------------|
| SC-1 | The `.opencode` submodule pointer in the parent repo is updated to SHA `babf358e2c4b0e3019ad8f55c30dc20e7457163f` | structural | Inspect `git submodule status` output — no `+` prefix, SHA matches `babf358e` |
| SC-2 | AGENTS.md references `qwen3.8:27b-256k` as the verified test model | string | `grep -q 'qwen3.8:27b-256k' AGENTS.md` |
| SC-3 | AGENTS.md no longer references `qwen3.6:35b-256k` as a current model | string | `grep -q 'qwen3.6:35b-256k' AGENTS.md` returns exit code 1 |

## Requirements

R-1. The `.opencode` submodule pointer SHALL be updated to `babf358e2c4b0e3019ad8f55c30dc20e7457163f`.
R-2. AGENTS.md SHALL contain `qwen3.8:27b-256k` as the verified test model reference.
R-3. AGENTS.md SHALL NOT contain `qwen3.6:35b-256k` as a current model reference.

## Items

### Item 1 (SC-1): Update submodule pointer

- RED: Verify `.opencode` not at `babf358e` — `git submodule status | grep -q ' babf358e'` should fail
- GREEN: `git add .opencode`
- Verify: `git submodule status | grep -v '^+' | grep -q 'babf358e'`
- Commit: Submodule pointer update included in the same commit as the AGENTS.md change

### Item 2 (SC-2): Update AGENTS.md model reference

- RED: `grep -q 'qwen3.8:27b-256k' AGENTS.md` fails (on main)
- GREEN: The branch already has this change in `f1295eef` — ensure AGENTS.md contains the new reference
- Verify: `grep -q 'qwen3.8:27b-256k' AGENTS.md`
- Commit: Shared commit with Item 1

### Item 3 (SC-3): Verify stale reference removed

- RED: `grep -q 'qwen3.6:35b-256k' AGENTS.md` succeeds (stale present on main)
- GREEN: The branch already has this change — ensure reference is removed
- Verify: `grep -v 'qwen3.6:35b-256k' AGENTS.md | grep -q 'qwen3.8:27b-256k'`
- Commit: No separate commit — verified as part of the shared commit

## Dependencies

- **PR #2377** (`.opencode` submodule): Must be merged (it is — `babf358e` is reachable from `origin/main`). Satisfied.
- **branch `feature/2376-update-default-test-model`:** Contains both changes. This is the working branch. Satisfied.

## Traceability

| Requirement | SC(s) | Phase(s) |
|------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3 | Phase 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Submodule PR #2377 | PR | `.opencode` repo, `.opencode/.issues/2377/` | Live `gh` check: merged to submodule main |
| `.opencode` submodule pointer | code | `.opencode` gitlink | `git submodule status` |
| AGENTS.md line 86 | doc | `AGENTS.md` | `grep -n 'qwen3' AGENTS.md` |

## Impact

- **Risk 1: Stale submodule pointer left dirty after skip** — If the pointer update is skipped, the `+` prefix in `git submodule status` persists and the build system resolves the wrong SHA. Mitigation: run `git submodule status` after the commit to verify no `+` prefix.
- **Risk 2: AGENTS.md has multiple inconsistent model references** — The old model string may appear in sections other than line 86. Mitigation: verify `grep` for the old string before merge.
- **Risk 3: Submodule SHA becomes unreachable before merge** — If the submodule main branch is force-pushed, `babf358e` may no longer be an ancestor. Mitigation: verify reachability at commit time.
- **Key dependency:** PR #2377 must be merged in `.opencode` (already merged).
- **Call to action:** Merge this PR to `main` to align parent-repo state with the submodule.

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the submodule SHA matches `babf358e` costs one `git submodule status` call. Skipping means a stale pointer is deployed and the build system resolves pre-#2377 submodule state, breaking every downstream feature branch.
- **SC-2:** Verifying AGENTS.md has `qwen3.8:27b-256k` costs one grep call. Skipping means a developer reads the wrong model reference and investigates why their test model isn't available.
- **SC-3:** Verifying `qwen3.6:35b-256k` is absent costs one grep call. Skipping means a stale reference persists alongside the new one, causing confusion about which model is canonical.

## Edge Cases

- **Condition:** Submodule SHA `babf358e` is no longer reachable from `origin/main`
  **Expected behavior:** The pointer update MUST NOT proceed. `git merge-base --is-ancestor babf358e origin/main` must pass.
  **Resolution:** If unreachable, do not update pointer. Investigate whether `babf358e` was force-pushed away.

- **Condition:** AGENTS.md has both `qwen3.6:35b-256k` and `qwen3.8:27b-256k` in different sections
  **Expected behavior:** All occurrences of the old model reference SHALL be removed or updated.
  **Resolution:** grep for all occurrences and verify each one.
