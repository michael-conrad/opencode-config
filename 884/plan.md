# Plan: #884 — Orphaned opencode-cli run processes from sub-agent dispatch

**Spec:** https://github.com/michael-conrad/.opencode/issues/884
**Constraint:** No `timeout` binary, no nested timeout layers, no process group management, bash tool sole timeout authority

## Mandate (Non-Negotiable)

**`timeout(1)` from coreutils is the root cause of orphan processes and MUST NOT be used.** When `timeout(1)` fires SIGTERM, it only reaches its direct child (the intermediate `bash` wrapper). The grandchildren (`env -i`, `opencode-cli`) inherit no signal — they become orphans. The bash tool's timeout parameter kills the **entire PGID** via process group signal, which terminates all processes including `opencode-cli`. Additionally, `flock(1)` is a file-descriptor-based lock — when the PGID is killed, the kernel closes all fds atomically, releasing the lock. `timeout(1)` would have killed only the bash wrapper, leaving opencode-cli alive WITH the lock held. Therefore: **no `timeout` binary. No nested timeout layers. No process group management. The bash tool's built-in timeout parameter is the sole timeout authority.**

## Z3-Verified Ordering

All REDs run first (no shared resource conflicts — all are read-only greps/behaviors).
Then all GREENS (Pair 0 modifies files shared by Pairs 2 and 4, but REDs already ran).

State:
```
RED phase:   [Pair 0][Pair 1][Pair 2][Pair 3][Pair 4][Pair 5]  (all parallel-compatible)
GREEN phase: [Pair 0][Pair 1][Pair 2][Pair 3][Pair 4][Pair 5]  (Pair 0 first, removes timeout/wrapper)
```

## RED Phase (run all, confirm all)

| Pair | Description | Evidence Type | Verification |
|------|-------------|---------------|-------------|
| 0 | Orphans survive timeout/interrupt | behavioral | Dispatch test, interrupt, `ps` shows orphan cluster |
| 1 | `--setup` flag does not exist in `with-test-home` | structural | `grep --setup with-test-home` returns 0 |
| 2 | `timeout` binary used in `helpers.sh` | structural | `grep '\btimeout\b' helpers.sh` returns >= 1 (line 262) |
| 3 | Process group patterns absent | structural | grep for `set -m`, `CHILD_PID`, `PGID`, `pkill`, `kill -- -$PID` returns 0 |
| 4 | `bash with-test-home` wrapper in dispatch chain | structural | grep for `with-test-home` inside `behavior_run` retry loop returns >= 1 |
| 5 | Flock is the lock mechanism | structural | `flock` in helpers.sh >= 1, `mkdir.*lock` returns 0 |

Z3 verified: [phase-contract.yaml](https://github.com/michael-conrad/.opencode/blob/issues-data/884/phase-contract.yaml) — all REDs SAT simultaneously.

## GREEN Phase (implement all in order)

### Pair 0: Remove orphan-supporting patterns (timeout + bash wrapper)

**Files:** `tests/behaviors/helpers.sh`

Replace:
```bash
timeout "$BEHAVIOR_TIMEOUT" bash "$PARENT_REPO_DIR/$BEHAVIOR_TEST_HOME" \
    opencode-cli run ... \
    > "$output_file" 2> "$err_file" \
    || true
```

With synchronous `env -i /bin/sh -c "exec opencode-cli run"`:
```bash
# --setup creates test home once before the loop (outside retry loop)
setup_output=$(bash "$PARENT_REPO_DIR/$BEHAVIOR_TEST_HOME" --setup "$workdir")
test_home=$(echo "$setup_output" | grep '^TEST_HOME=' | cut -d= -f2-)
# Guard: if --setup produced no TEST_HOME, fail fast — don't dispatch with empty $env_file
if [ -z "$test_home" ]; then
    echo "HARNESS_FAILURE: --setup failed to produce TEST_HOME" >&2
    continue
fi

# Inside retry loop — synchronous, no intermediate bash, no timeout binary
cd "$workdir"
env -i /bin/sh -c ". $env_file && exec opencode-cli run ..."
cd "$PARENT_REPO_DIR"
```

### Pair 1: Add `--setup` mode to `with-test-home`

**Files:** `tests/with-test-home`, `tests/behaviors/helpers.sh`

Add `--setup` mode to `with-test-home`:
```
--setup [workdir]  — creates test home, seeds config, prints TEST_HOME=<path>, exits 0
```

### Pair 2: No `timeout` binary verification (GREEN: already done by Pair 0)

Structural post-check: grep for `\btimeout\b` in `helpers.sh` returns 0.

### Pair 3: No process group management (GREEN: already absent)

Structural post-check: grep for `set -m`, `CHILD_PID`, `PGID`, `pkill`, `kill -- -$PID` returns 0.

### Pair 4: No `bash with-test-home` wrapper (GREEN: already done by Pair 0)

Structural post-check: grep for `with-test-home` inside `behavior_run` retry loop returns 0.

### Pair 5: Flock lock mechanism (GREEN: already correct)

Ensure `tests/AGENTS.md` documents the lock behavior. No code change needed.

## Implementation Pipeline Checklist

| Step | Pairs | Status |
|------|-------|--------|
| sc-coherence-gate | — | ⬜ |
| pre-red-baseline | — | ⬜ |
| red-phase | All 6 | ⬜ |
| red-doublecheck | All 6 | ⬜ |
| green-phase | Pair 0, 1 | ⬜ |
| checkpoint-commit | — | ⬜ |
| structural-checks | Pair 2-5 post-check | ⬜ |
| green-doublecheck | Pair 0 GREEN verify | ⬜ |
| green-vbc | — | ⬜ |
| adversarial-audit | — | ⬜ |
| cross-validate | — | ⬜ |
| regression-check | — | ⬜ |
| review-prep | — | ⬜ |
| exec-summary | — | ⬜ |

---