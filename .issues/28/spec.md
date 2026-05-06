# Synced from GitHub Issue #28 at 2026-05-02T00:00:00Z

**Status: SPEC-FIX — awaiting approval**

## Problem

~49 scripts across `.opencode/` use the walk-up-to-`.opencode` pattern for root detection, but none of the canonical implementations include a guard against reaching the filesystem root. If `.opencode/` is ever unreachable, the loop hangs. Additionally, 5 files in `tools/impl/` walk up looking for `.git/` instead of `.opencode/`, which is explicitly prohibited by `210-scripting.md`.

## Acceptance Criteria

### Phase 1: Root-Guard Addition
1. All 31 shell scripts with canonical walk-up pattern have root-guard
2. All 20 Python scripts without root-guards have explicit root-guard
3. Consistent guard pattern: `if dirname result == current → fatal error`

### Phase 2: .git-Walking Migration
4. All 5 `.git`-walking files migrated to `.opencode` walk-up pattern
5. Root-guards included in migrated implementations

### Phase 3: Guideline Update
6. `210-scripting.md` updated: canonical pattern includes root-guard
7. Enforcement test updated to verify root-guard presence
