# [SPEC] Submodule merged-commit verification gate for implementation and PR-creation workflows

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2313/

## Problem

The git-workflow pipeline creates and commits submodule pointer changes without verifying that the pointed-to commit exists on the submodule's remote default branch. When a parent-repo PR references a submodule commit that only exists locally (its own PR hasn't been merged yet), deploy breaks because the build system resolves the submodule pointer to a commit that doesn't exist on the remote. Manual debugging is required to trace the dependency chain — wasting developer time and breaking release cadence.

## Scope

**In scope:**
- Add merged-commit verification to trunk-tip-verification (pre-work) — verify all committed submodule pointer SHAs exist on submodule's remote `$DEFAULT_BRANCH`
- Add merged-commit verification to pre-commit section of implementation task — verify staged submodule pointer SHAs are reachable from submodule's remote trunk before allowing commit
- Add merged-commit verification to enforcement-gate (PR creation Step 0) — block PR creation when any submodule pointer references a local-only commit
- Add behavioral enforcement tests for all three gates

**Out of scope:**
- Automatic submodule PR creation or cleanup
- Changes to the submodule pointer scanning mechanism (existing `git submodule status` pattern stays)
- Changes to any submodule's own git workflow
- Verification gate at deploy time (only pre-work, commit, and PR-creation gates)
- Merge-commit verification for non-submodule dependencies

## Approach

Three independent verification gates, one per workflow phase, each using `git merge-base --is-ancestor` to test submodule commit reachability against `origin/$DEFAULT_BRANCH`. The trunk-tip-verification gate runs during pre-work to catch stale pointers before development begins. The pre-commit gate catches freshly-staged pointers before they are committed. The enforcement-gate at PR time is the last line of defense — it rejects PRs whose committed submodule SHAs are not found on the submodule's remote trunk. Each gate is enforced by a behavioral test that sends a real-domain prompt through `opencode run` and asserts stderr evidence of the verification action or block.

## Impact

| Risk | Mitigation |
|------|-----------|
| False positives during active submodule development (submodule pointers legitimately point to local commits mid-feature) | Pre-work gate only runs at branch creation, not during development. Pre-commit gate checks staged pointers — developer blocks themselves, not an external block. Enforcement-gate only fires at PR time, when all submodule work should be merged anyway. |
| Behavioral tests are expensive to run (require real `opencode run` with AI models) | Each SC produces exactly one behavioral test; test suite is scoped-limited (not full-suite); model speed assessment gates full runs. |
| Submodule remote may be temporarily unreachable | Gate fails open (warns, does not block) on network error — network flakiness should never block development. |

**Dependencies:** No external dependencies. Three task files to modify: `trunk-tip-verification.md`, `implementation.md`, `enforcement-gate.md`.

**Call to action:** Review and approve this spec to add submodule merged-commit verification gates across the git-workflow pipeline.

## Success Criteria

| ID | Description | Evidence Type |
|----|-------------|---------------|
| SC-1 | trunk-tip-verification (pre-work) SHALL verify each submodule's committed pointer SHA is an ancestor of the submodule's remote `origin/$DEFAULT_BRANCH` using `git merge-base --is-ancestor` and report BLOCKED with `SUBMODULE_UNMERGED_COMMIT` when a commit is local-only | Behavioral |
| SC-2 | implementation (pre-commit) SHALL verify each newly-staged submodule pointer SHA is reachable from the submodule's remote `origin/$DEFAULT_BRANCH` and block commit with a clear error when a pointer references a local-only commit | Behavioral |
| SC-3 | enforcement-gate (PR creation Step 0) SHALL verify every committed submodule gitlink SHA exists on the submodule's remote `origin/$DEFAULT_BRANCH` and block PR creation with `SUBMODULE_PR_MISSING` when any pointer references an unmerged commit | Behavioral |

SC-1 cost frame: A pre-work gate that accepts stale submodule pointers means every trunk-tip-verification pass is a lie — the developer starts work from an already-broken base.

SC-2 cost frame: A pre-commit gate that accepts local-only submodule SHAs means every commit is a ticking time bomb — the commit looks clean but will break the deploy pipeline the moment someone tries to use it.

SC-3 cost frame: An enforcement gate that passes submodule PRs with unmerged references means the deploy engineer discovers the break at deployment time, not at PR time — the most expensive point in the pipeline.

### Documentation Sources

| SC ID | Source |
|-------|--------|
| SC-1 | `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` (step 6-7 existing checks) |
| SC-2 | `.opencode/skills/git-workflow-commit/tasks/implementation.md` (pre-commit pointer check lines 34-42) |
| SC-3 | `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` (Step 0 Submodule PR Dependency Check) |

## Affected Files

- `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` — Add 8th check after step 7 (pointer-match)
- `.opencode/skills/git-workflow-commit/tasks/implementation.md` — Add merged-commit check in pre-commit section
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` — Add merged-commit check alongside existing liveness check
- `.opencode/tests-v2/behaviors/git-workflow/` — Add behavioral enforcement tests per SC
