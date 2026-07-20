## Problem

The test framework has several defects and missing mandates:

1. **`BEHAVIOR_TIMEOUT` unbound variable** in `helpers.sh` line 341 — referenced but never set/exported, causes `HARNESS_FAILURE` on empty output
2. **`snap run` references in comments** in `with-test-home` — the only acceptable reference is as a forbidden pattern example
3. **`/snap/bin/opencode` hardcoded** in `test-enforcement.sh` and `test-verification-honesty.sh` — must use PATH resolution like `helpers.sh` and `with-test-home`
4. **No `USER=opencode-test-user`** in test environments — tests must use a non-production user identity
5. **No isolation verification** — must verify that test home only contains opencode config/db/log files and production DB is untouched
6. **No mandate against `timeout` command** in bash scripts — nested timeouts create orphaned processes

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `BEHAVIOR_TIMEOUT` variable removed from `helpers.sh` — no unbound variable references | `string` | grep for BEHAVIOR_TIMEOUT in helpers.sh returns 0 matches |
| SC-2 | `snap run` only appears in `with-test-home` as a forbidden pattern example (comment showing what NOT to do) | `string` | grep for 'snap run' in tests-v2/ returns only the forbidden pattern reference |
| SC-3 | `/snap/bin/opencode` removed from all test scripts — PATH resolution used instead | `string` | grep for '/snap/bin/opencode' in tests-v2/ returns 0 matches |
| SC-4 | `USER=opencode-test-user` set in test environment in `with-test-home` | `string` | grep for 'opencode-test-user' in with-test-home returns match |
| SC-5 | `with-test-home` verifies after warmup that test home only contains opencode files and production DB is untouched | `behavioral` | Run with-test-home --setup, verify output includes isolation check |
| SC-6 | `AGENTS.md` documents all mandates: no snap run, no bash timeout command, USER env, isolation verification | `string` | grep for each mandate keyword in AGENTS.md |
| SC-7 | `timeout` command (GNU timeout) is banned inside test scripts — only bash tool timeout parameter is allowed | `string` | grep for '^timeout ' in tests-v2/behaviors/*.sh returns 0 matches |

## Affected Files

- `.opencode/tests-v2/behaviors/helpers.sh`
- `.opencode/tests-v2/with-test-home`
- `.opencode/tests-v2/test-enforcement.sh`
- `.opencode/tests-v2/test-verification-honesty.sh`
- `.opencode/tests-v2/AGENTS.md`
