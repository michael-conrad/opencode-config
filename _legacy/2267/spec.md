> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2267/

## Problem

The `git-workflow-pr` skill's PR-creation procedure (`.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` Step 7.2.4) instructs posting a **no-op comment** on a new PR (with an empty-push fallback) to "trigger GitBucket's mergeability computation" whenever the PR API reports `mergeable: null`. This is useless noise: mergeability is authoritatively determined locally via `git merge-base --is-ancestor origin/<target> HEAD`. The no-op comment adds no information, leaves clutter for humans to clean up, and the `--allow-empty` push creates a pointless empty commit. Repeated useless comments were observed on NewsRxUI PR #18, Patents PR #22, and Patents PR #23.

## Scope

- Remove the no-op comment trigger (`github_add_issue_comment` with no-op message) from `create-pr.md` Step 7.2.4.
- Remove the empty-push fallback (`git commit --allow-empty -m "trigger mergeability" && git push`) from `create-pr.md` Step 7.2.4.
- Replace Step 7.2.4's trigger mechanism with the authoritative local check `git merge-base --is-ancestor origin/<target> HEAD` (exit 0 = mergeable).
- Re-route `mergeable: null` (Step 7.2.2) and the diagnosis output (Step 7.2.5) to report **verified-locally** instead of the removed trigger.
- Align `enforcement-gate.md` Step 1.5d/e so the pre-creation `None/unknown` path explicitly names the local merge-base check and the Step 1.5e cross-reference to the post-creation check remains valid.

**Out of scope:**

- Changing the `mergeable: false` conflict-reporting path (Step 7.2.2 false branch).
- Modifying `git-workflow-pr/SKILL.md` routing (Trigger Dispatch Table) — only the two task files change.
- Reusing the different-semantics merge-base check in `review-prep/push-and-cleanup.md:178` (that is a base-SHA equality check, not the ancestry test).
- Fixing the pre-existing latent reference drift in `enforcement-gate.md` Step 1.5e ("create-pr.md Step 3" vs actual Step 7.2) — flagged to developer, corrected only if within SC-4 consistency scope.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The no-op comment trigger (`github_add_issue_comment` with a no-op message) SHALL be removed from `create-pr.md` Step 7.2.4. | string | grep create-pr.md Step 7.2.4 for `github_add_issue_comment` → absent | `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` (code) |
| SC-2 | The empty-push fallback (`git commit --allow-empty -m "trigger mergeability" && git push`) SHALL be removed from `create-pr.md` Step 7.2.4. | string | grep create-pr.md Step 7.2.4 for `--allow-empty` → absent | `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` (code) |
| SC-3 | Step 7.2.4 SHALL use the authoritative local check `git merge-base --is-ancestor origin/<target> HEAD` (exit 0 = mergeable) as the mergeability determination, and the `mergeable: null` path (Step 7.2.2) and diagnosis output (Step 7.2.5) SHALL report **verified-locally** instead of the removed trigger, with the `7.2.x` step numbers kept stable. | string | grep create-pr.md for `merge-base --is-ancestor` → present in Step 7.2.4; grep for `verified-locally` → present in Step 7.2.2/7.2.5; grep for `Computation triggered` → absent | `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` (code) |
| SC-4 | `enforcement-gate.md` Step 1.5d/e SHALL be aligned so the pre-creation `None/unknown` path explicitly names the local merge-base check and the Step 1.5e cross-reference to the post-creation check remains valid. | string | grep enforcement-gate.md Step 1.5d for `merge-base` → present; grep Step 1.5e for the post-creation check reference → present and valid | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` (code) |

## Approach

Replace the no-op-comment/empty-push "trigger mergeability" mechanism (Step 7.2.4) with the local ancestry test as the authoritative mergeability determination. When `mergeable` is `null`, after the stale-base check (Step 7.2.3) is excluded, run `git merge-base --is-ancestor origin/<target> HEAD`; exit 0 indicates the target tip is an ancestor of the PR head (mergeable), non-zero indicates divergence (report conflict). The diagnosis (Step 7.2.5) reports **verified-locally** and drops the "Computation triggered: yes|no" line. This is a purely local, read-only determination — no API mutation replaces the removed comment, consistent with API-mutation discipline. The `mergeable` field becomes advisory; the local ancestry check is authoritative.

## Impact

- **Risk:** Mergeability misreported when local refs are stale. **Mitigation:** the check runs after a `git fetch origin <target>` is implied by the stale-base step; instruction text will require a current base.
- **Risk:** Agents interpret "verified-locally" as permission to skip conflict detection. **Mitigation:** the non-zero exit path explicitly reports a conflict with `git diff origin/<target>...HEAD --name-only --diff-filter=U`, preserving current false-path behavior.
- **Risk:** Cross-reference drift if step numbers shift. **Mitigation:** SC-3/SC-4 keep `7.2.x` step numbers stable and verify the Step 1.5e reference.
- **Dependencies:** None beyond existing git tooling in the skill deck.
- **Call to action:** Approve this spec to implement the two task-file edits and add behavioral enforcement tests asserting the agent no longer posts a trigger comment and instead reports verified-locally.

## Change Control

- 2026-08-12: Added the Success Criteria table defining SC-1 through SC-4. The spec referenced SC-3/SC-4 in its Impact and Out-of-scope sections but defined no success criteria table; the analyze task returned NO_SUCCESS_CRITERIA. SC-1 removes the no-op comment trigger, SC-2 removes the empty-push fallback, SC-3 replaces the trigger with the local merge-base check and re-routes `mergeable: null`/diagnosis to verified-locally, SC-4 aligns `enforcement-gate.md` Step 1.5d/e. Problem, Scope, Approach, and Impact sections preserved unchanged. Authorized by: revision request for issue 2267.
