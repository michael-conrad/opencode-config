## Problem

The test framework is supposed to isolate opencode's SQLite database into a temporary test home. It does not. Three independent isolation failures cause all test runs to write to the production DB at `~/.local/share/opencode/opencode.db` (9.4 GB, 14,668 sessions, 8 test-contaminated projects).

## Root Causes

### 1. `with-test-home` doesn't use `env -i` — the comment is a lie

Line 25 claims `"uses env -i with ONLY these vars"` but the execution block (lines 319-331) just exports variables in a subshell. No `env -i` anywhere in the execution path. The parent environment leaks through, and `HOME` is never set to the test home in the execution block.

### 2. `helpers.sh` runs `opencode models` against production DB at source time

Line 397 executes `opencode models` unconditionally at source time — no isolation, no `with-test-home`, no XDG redirect. Every test script that sources `helpers.sh` (16 scripts) triggers this against the production DB.

### 3. The standalone binary is never copied to `$TEST_HOME/bin`

The AGENTS.md mandates:
1. Cache at `.tools/opencode/opencode` ✅ (exists, 178 MB)
2. Copy to `$TEST_HOME/bin/opencode` ❌ **never happens**
3. Prepend `$TEST_HOME/bin` to PATH ❌ **never happens**

`with-test-home` uses `command -v opencode` which resolves to `/snap/bin/opencode` — the snap binary that the framework explicitly forbids.

### 4. Both `with-test-home` and `helpers.sh` resolve opencode to an absolute path

Even when the standalone binary was available, both scripts stored `OPENCODE_CMD` as an absolute path (e.g., `/snap/bin/opencode` or `.tools/opencode/opencode`). The `env -i` block then ran that absolute path directly — PATH was never consulted, so `$TEST_HOME/bin/opencode` was dead code.

### 5. Two scripts bypass `with-test-home` entirely

- `.opencode/tests-v2/behaviors/secret-redaction/SC-2.sh` — direct `opencode run` with no isolation
- `.opencode/tests-v2/behaviors/test-verb-variant.sh` — uses `snap run opencode`

## Changes

### `with-test-home`

- Resolves opencode as bare `"opencode"` (not absolute path) so `env -i` PATH resolution finds `$TEST_HOME/bin/opencode`
- Copies `.tools/opencode/opencode` to `$TEST_HOME/bin/opencode` before execution
- Execution block now uses `env -i -C "$TEST_PROJECT"` with explicit allowlist of 16 variables
- Sets `HOME="$TEST_HOME"` and prepends `$TEST_HOME/bin` to PATH
- Prints diagnostic `[test-env]` lines before running the command (HOME, PATH, USER, XDG_*, SNAP_USER_DATA, opencode binary path)

### `helpers.sh`

- `opencode models` call moved from source-time (line 397) into lazy-init function `__init_model_pool()`, called only on first `behavior_run_pool()` invocation
- Resolves opencode as bare `"opencode"` (not absolute path) so `with-test-home`'s `env -i` PATH resolution finds `$TEST_HOME/bin/opencode`

### `secret-redaction/SC-2.sh`

- Rewritten to use `behavior_run()` from helpers.sh (which uses `with-test-home`), instead of direct `opencode run`

### `test-verb-variant.sh`

- Rewritten to use `with-test-home` wrapper instead of `snap run opencode`

## Verification

```
[test-env] HOME=/home/.../tmp/test-home-20260717-220027
[test-env] PATH=/home/.../tmp/test-home-20260717-220027/bin:...
[test-env] USER=opencode-test-user
[test-env] XDG_DATA_HOME=/home/.../tmp/test-home-20260717-220027/.local/share
[test-env] XDG_CONFIG_HOME=/home/.../tmp/test-home-20260717-220027/.config
[test-env] XDG_STATE_HOME=/home/.../tmp/test-home-20260717-220027/.local/state
[test-env] XDG_CACHE_HOME=/home/.../tmp/test-home-20260717-220027/.cache
[test-env] SNAP_USER_DATA=/home/.../tmp/test-home-20260717-220027/snap/opencode
[test-env] opencode=/home/.../tmp/test-home-20260717-220027/bin/opencode
```

| Check | Result |
|-------|--------|
| `opencode` resolves to `$TEST_HOME/bin/opencode` | ✅ |
| Production DB session count unchanged | ✅ |
| Test DB has session with correct project worktree | ✅ |
| Test session ID not found in production DB | ✅ |
| All XDG vars point to test home | ✅ |
| `USER` is `opencode-test-user` | ✅ |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `with-test-home` execution block uses `env -i` with explicit allowlist | `string` | grep for `env -i` in execution path |
| SC-2 | `with-test-home` sets `HOME` to test home in execution block | `string` | grep for `HOME=.*TEST_HOME` in execution block |
| SC-3 | `with-test-home` copies `.tools/opencode/opencode` to `$TEST_HOME/bin/opencode` | `string` | grep for `cp.*STANDALONE` in with-test-home |
| SC-4 | `with-test-home` prepends `$TEST_HOME/bin` to PATH | `string` | grep for `PATH=.*TEST_HOME/bin` in with-test-home |
| SC-5 | `helpers.sh` does NOT run `opencode models` at source time | `string` | grep for `opencode models` outside function body in helpers.sh |
| SC-6 | `with-test-home` and `helpers.sh` use bare `"opencode"` not absolute path | `string` | grep for `OPENCODE_CMD=.*opencode"` (bare, no path) |
| SC-7 | `secret-redaction/SC-2.sh` uses `behavior_run()` from helpers.sh | `string` | grep for `behavior_run` in SC-2.sh |
| SC-8 | `test-verb-variant.sh` does NOT use `snap run` | `string` | grep for `snap run` returns 0 matches |
| SC-9 | `test-verb-variant.sh` uses `with-test-home` wrapper | `string` | grep for `with-test-home` in test-verb-variant.sh |
| SC-10 | Running a behavioral test produces DB at `$TEST_HOME/.local/share/opencode/opencode.db`, NOT production DB | `behavioral` | Run test, check `opencode db path` output in test env |
| SC-11 | Running a behavioral test does NOT create new sessions in production DB | `behavioral` | Run test, check production DB session count unchanged |
| SC-12 | `with-test-home` prints diagnostic `[test-env]` lines before running command | `string` | grep for `[test-env]` in with-test-home |

## Affected Files

- `.opencode/tests-v2/with-test-home`
- `.opencode/tests-v2/behaviors/helpers.sh`
- `.opencode/tests-v2/behaviors/secret-redaction/SC-2.sh`
- `.opencode/tests-v2/behaviors/test-verb-variant.sh`
