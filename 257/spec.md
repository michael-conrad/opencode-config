## Problem

Gate 4 in the pre-commit hook blocks submodule-pointer-only commits. This is the wrong layer — the pre-work workflow legitimately requires committing the submodule pointer as the first commit on the feature branch. The actual policy violation is pushing a branch whose only changes are submodule pointer updates (creating wasted PRs with no functional code).

## Current State

| Hook | Submodule check | Purpose |
|------|----------------|---------|
| pre-commit (Gate 4) | Blocks submodule-pointer-only commits | Wrong layer — blocks legitimate pre-work commits |
| pre-push | No submodule check | Missing — should catch submodule-only pushes |

## Proposed Change

### 1. Remove Gate 4 from `.git/hooks/pre-commit`

Delete lines 83-155 (Gate 4: Submodule-pointer-only commit blocker) and the corresponding `GATE_EXIT_CODES` entry. Update gate names array and count.

### 2. Add submodule-pointer-only push gate to `.git/hooks/pre-push`

Add a new gate inside the existing `while read` loop that:

1. After the existing Gate 1 check, computes the diff between remote SHA and local SHA:
   ```bash
   CHANGED_FILES=$(git diff --name-only "$REMOTE_SHA".."$LOCAL_SHA" 2>/dev/null)
   ```

2. Gets submodule paths:
   ```bash
   SUBMODULE_PATHS=$(git submodule status | awk '{print $2}')
   ```

3. Checks if ALL changed files are submodule pointers (gitlinks):
   - For each file in `CHANGED_FILES`, check if it matches a submodule path
   - If all files match → submodule-only push

4. If submodule-only, checks for existing tag on the submodule:
   ```bash
   # For each submodule, look for a tag matching <parent-repo>/<issue-number>
   git tag -l "*/$ISSUE_NUMBER" --sort=-version:refname | head -1
   ```
   (Issue number extracted from branch name: `feature/<N>-<slug>` → `N`)

5. If tag exists: reference it in the error message
6. If tag is missing: instruct the agent to create one:
   ```bash
   git tag -a "<parent-repo>/<issue-number>" -m "Track submodule SHA for issue <N>"
   git push origin "<parent-repo>/<issue-number>"
   ```

7. Block the push with error message

### 3. Error Message

```
BLOCKED: Submodule-pointer-only push prevented.

The branch '<branch>' contains only submodule pointer changes with no
parent-repo source code modifications. Submodule-only bump PRs are
against policy — they create review overhead with no functional change.

Local submodule pointer commits are fine — keep them.

<IF TAG EXISTS>
The submodule SHA is already tracked via tag '<tag>' on the submodule
remote. Nothing is lost.
<ELSE>
⚠ Submodule tag missing. Create one before continuing:
  cd <submodule-path>
  git tag -a "<parent-repo>/<issue-number>" -m "Track submodule SHA for issue <number>"
  git push origin "<parent-repo>/<issue-number>"
</IF>

To proceed:
  1. Continue implementation on this branch (edit source files)
  2. Commit your code changes
  3. Push again — the submodule pointer will accompany your code

The submodule pointer update will be included in your PR alongside the
real implementation. No need to redo the pointer commit or tag.
```

### 4. Branch Exemptions

**None.** The check applies to all branches. If a branch diff is entirely submodule pointer updates, it should be blocked regardless of branch name. Legitimate feature branches will have non-submodule implementation commits alongside the pointer commit, so the check won't fire.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Gate 4 no longer exists in pre-commit hook | `string` | grep for "Submodule-pointer-only commit" in pre-commit — must return empty |
| SC-2 | Submodule-pointer-only push is blocked by pre-push hook | `behavioral` | `opencode-cli run` on branch with submodule-only commit → push blocked with error message |
| SC-3 | Submodule-pointer push with accompanying code changes is allowed | `behavioral` | `opencode-cli run` on branch with submodule + code commits → push succeeds |
| SC-4 | Error message references tag when tag exists | `string` | Error output contains "tag" reference when tag is present |
| SC-5 | Error message instructs tag creation when tag is missing | `string` | Error output contains tag creation instructions when tag is absent |
| SC-6 | No branch exemptions — check applies universally | `string` | grep for branch case statement in push gate — must not exempt feature/*, hotfix/*, pair-* |

## Files Affected

| File | Change |
|------|--------|
| `.git/hooks/pre-commit` | Remove Gate 4 (lines 83-155) |
| `.git/hooks/pre-push` | Add submodule-pointer-only push gate |

## Out of Scope

- Modifying Gate 3 (submodule code changes in `.opencode/`) — separate concern
- Changing the pre-work task workflow — it's correct as-is
- PR creation time checks — pre-push is the right layer for this

🤖 Co-authored with AI: opencode (opencode/mimo-v2.5-free)