## Problem

~49 scripts across `.opencode/` use the walk-up-to-`.opencode` pattern for root detection, but **none of the canonical implementations include a guard against reaching the filesystem root**. If `.opencode/` is ever unreachable from a script's location (wrong CWD, symlink anomaly, corrupted clone, script run outside the project tree), the loop walks up to `/`, where `dirname "/"` = `"/"`, and hangs in an infinite loop.

Additionally, 5 files in `tools/impl/` walk up looking for `.git/` instead of `.opencode/`, which is explicitly prohibited by `210-scripting.md`. Some of these lack root-guards as well.

### Affected Categories

| Category | Count | Has Root-Guard? |
|---|---|---|
| Canonical Shell (`while basename != .opencode`) | 31 files | NO — all 31 hang at `/` |
| Canonical Python (`while _path.name != ".opencode"`) | 17 files | NO — raises `AttributeError` on empty string (better, but not explicit) |
| Python `is_dir()` check, no guard | 3 files | NO |
| Dual `IMPL_DIR` + walk-up | 13 files | NO |
| `.git`-walking violations | 5 files | Mixed (1 lacks any guard) |

## Root Cause

The `210-scripting.md` guideline defines the canonical pattern but did not specify failure behavior when `.opencode/` is unreachable. The pattern assumes `.opencode/` is always reachable from the script's location, which is true in normal operation but not a safe assumption.

Defensive scripts must detect the "hit filesystem root" condition and fail explicitly rather than looping forever. The fix is trivial (3-4 additional lines per script) but needs to be applied consistently across all implementations.

## Acceptance Criteria

### Phase 1: Root-Guard Addition
1. All 31 shell scripts with the canonical walk-up pattern have a root-guard that detects hitting `/` and fails with an explicit error message
2. All 20 Python scripts without root-guards have an explicit root-guard
3. The root-guard is consistent: `if dirname result == current → fatal error with descriptive message`
4. Behavioral enforcement test: verifying that a script run outside the project tree fails with an error rather than hanging

### Phase 2: `.git`-Walking Migration
5. All 5 `.git`-walking files migrated to the `.opencode` walk-up pattern
6. Root-guards included in the migrated implementations

### Phase 3: Guideline Update
7. `210-scripting.md` updated: canonical pattern examples include the root-guard
8. Enforcement test updated (`test-pep723-tools.sh` line 196-215) to also verify root-guard presence

## Canonical Pattern (with root-guard)

### Shell
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PARENT="$(dirname "$PROJECT_DIR")"
    if [ "$PARENT" = "$PROJECT_DIR" ]; then
        echo "FATAL: Could not find .opencode/ directory" >&2
        exit 1
    fi
    PROJECT_DIR="$PARENT"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"
```

### Python
```python
from pathlib import Path
_path = Path(__file__).resolve().parent
while _path.name != ".opencode":
    parent = _path.parent
    if parent == _path:
        raise RuntimeError("Could not find .opencode/ directory")
    _path = parent
PROJECT_ROOT = _path.parent
```

## `.git`-Walking Files to Migrate

| File | Current Pattern | Root-Guard? |
|---|---|---|
| `tools/impl/sym-states` | `parents` chain looking for `.git/` | NO (breaks on `.parents` exhaustion) |
| `tools/impl/sym-conflicts` | `parents` chain looking for `.git/` | NO (breaks on `.parents` exhaustion) |
| `tools/impl/sym-analyze` | `while` loop looking for `.git/` | YES (`_candidate != _candidate.parent`) |
| `tools/impl/sym-extract-dot` | `while` loop looking for `.git/` | YES (`_candidate.parent != _candidate`) |
| `tools/impl/sym-report` | `while` loop looking for `.git/` | NO (will hang at `/`) |

## Non-Goal

- Do NOT change the hook root detection pattern (covered by separate spec fix)
- Do NOT introduce shared/imported root detection functions
- Do NOT use `git rev-parse --show-toplevel` as a fallback

---

## Regression Reference

This was discovered during analysis of the hook hang issue. The hook hang is the canary — it proves the defense-in-depth gap: any script that reaches `/` will loop forever, which is always a latent bug even if normal operation avoids triggering it.

🤖 Co-authored with AI: OpenCode (deepseek-v4-pro)