---
title: "[SPEC-FIX] Pre-push hook false positive on tag pushes"
labels:
  - spec-fix
status: open
url: https://github.com/michael-conrad/.opencode/issues/821
created_at: "2026-05-22T20:10:39Z"
updated_at: "2026-05-22T20:10:39Z"
---

# [SPEC-FIX] Pre-push hook false positive on tag pushes

## Problem

The `.opencode/hooks/pre-push` hook applies branch-protective gates (branch topology check, commit count check) to tag push refspecs, causing false positive blocks when pushing annotated tags like `git push origin v0.1.1`.

Both hooks in both the parent repo and the submodule are **identical** — the same pre-push hook is installed from `.opencode/hooks/pre-push` into:

1. `.git/hooks/pre-push` (parent repo)
2. `.git/modules/.opencode/hooks/pre-push` (submodule)

## Defect Analysis

The `pre-push` hook reads stdin lines in the format `<LOCAL_REF> <LOCAL_SHA> <REMOTE_REF> <REMOTE_SHA>`. When pushing a **tag**, git sends:

- `LOCAL_REF` = `refs/tags/v0.1.1` (tag ref, NOT `refs/heads/...`)
- `LOCAL_SHA` = the tagged commit SHA
- `REMOTE_REF` = `refs/tags/v0.1.1`
- `REMOTE_SHA` = `0000000000000000000000000000000000000000` (new tag)

The hook has three gates that all produce false positives on tag pushes:

### Gate 0: Branch protection (lines 32-48)

- Extracts `REMOTE_BRANCH="${REMOTE_REF#refs/heads/}"` — for tags, this becomes `refs/tags/v0.1.1` (NOT stripped to `v0.1.1` because it's `refs/tags/` not `refs/heads/`)
- The `case "$REMOTE_BRANCH"` match against `main|master|dev` does NOT match tag refspecs, so **Gate 0 is unaffected** — it correctly does not block tag pushes.

### Gate 1: Merged branch topology check (lines 56-103)

- Extracts `LOCAL_BRANCH="${LOCAL_REF#refs/heads/}"` — for tags, this becomes `refs/tags/v0.1.1`
- The condition `[ "$LOCAL_BRANCH" = "$REMOTE_BRANCH" ]` compares two `refs/tags/...` values, which ARE equal
- Then `git branch -r --merged origin/dev` is run, which returns branch names — but `grep -q "origin/$LOCAL_BRANCH"` searches for `origin/refs/tags/v0.1.1` which won't match any branch
- **Gate 1 is currently harmless for tags** because the grep pattern won't match branches, but it's still incorrect to run topology checks on tags

### Gate 2: Commit count check (lines 107-159)

- Same branch extraction: `LOCAL_BRANCH="${LOCAL_REF#refs/heads/}"` results in `refs/tags/v0.1.1`
- The condition `[ "$LOCAL_BRANCH" = "$REMOTE_BRANCH" ]` is true for tags
- `SKIP_COMMIT_COUNT_CHECK` is not set, and `pair-*/rollback/*` case doesn't match tags
- `WORK_STATE_DIR` check runs — `ls tmp/work-*.md` likely finds nothing
- `COMMIT_COUNT` is computed as `git rev-list --count origin/dev..$LOCAL_SHA` — this counts ALL commits between `origin/dev` and the tagged SHA, which could be large
- **Gate 2 IS the blocking defect** — it reports "3 commits but no work state file" and blocks the push

### Root Cause Summary

The hook does not distinguish between **branch pushes** (`refs/heads/...`) and **tag pushes** (`refs/tags/...`). All three gates assume the pushed refspec is a branch. When a tag is pushed:

1. `LOCAL_REF` is `refs/tags/v0.1.1` instead of `refs/heads/feature/X`
2. The `refs/heads/` prefix stripping produces malformed branch names
3. Gate 2 computes a commit count against `origin/dev` for a tag SHA, producing false positives

### Other Hooks Checked

| Hook | Tag-Safe? | Defect? |
|------|----------|---------|
| `pre-push` | NO | YES — blocks tag pushes with false positive commit count |
| `pre-commit` | N/A | NO — only fires on commits, not tag operations |
| `post-commit` | N/A | NO — only fires on commits |
| `pre-merge-commit` | N/A | NO — only fires on merges |
| `prepare-commit-msg` | N/A | NO — only fires on commit message preparation |

Only `pre-push` is affected. The other hooks don't run during tag operations.

## Fix Specification

### Proposed Fix

Add a **tag detection early return** at the top of the `while read` loop in `pre-push`, before any gates run:

```bash
# Skip all gates for tag pushes — tags are not branch pushes
if [[ "$LOCAL_REF" == refs/tags/* ]]; then
    continue
fi
```

This single `continue` statement causes the loop to skip all three gates for tag refspecs. Tags are immutable pointers to existing commits — they don't introduce new code, and all existing gates are designed for branch pushes only.

### Affected Files

- `.opencode/hooks/pre-push` (source file — same content installed to both repos)

### Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Tag push (`git push origin v0.1.1`) completes without `--no-verify` | `behavioral` |
| SC-2 | Branch push gates still fire correctly for feature branches | `behavioral` |
| SC-3 | Branch push gates still fire correctly for protected branches (main/dev) | `behavioral` |
| SC-4 | Hook source file in `.opencode/hooks/pre-push` contains tag detection early return | `string` |
| SC-5 | Both installed hook copies (parent + submodule) match the source | `string` |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

---

## Comments

No comments on this issue.