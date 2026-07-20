## Problem

`read-link-pattern-clean-room.sh` constructs its own test home manually, runs `opencode run` directly without `with-test-home`, and leaks the parent environment. It has 11 isolation violations:

- Manual test home construction (lines 27-29)
- Direct `opencode run` without `with-test-home` (line 178)
- Manual XDG var setup without `env -i` (lines 172-177)
- Calls `opencode models` directly to seed config (line 53) — reads production DB
- No `SNAP_USER_DATA` override
- No `USER=opencode-test-user`
- No `GIT_CONFIG_NOSYSTEM=1`
- No `env -i` isolation — all parent env leaks through
- No smoke tests
- No isolation verification
- No concurrency lock

## Fix

Rewrite to use `with-test-home --setup` for environment creation, then inject the test guideline and target files into the test project, then use `with-test-home opencode run` for the actual test execution.

## Affected Files

- `.opencode/tests-v2/behaviors/read-link-pattern-clean-room.sh`

---

**Closed:** Filed in wrong repo. The file lives in the `.opencode` submodule. Correct issue: michael-conrad/.opencode#1985
