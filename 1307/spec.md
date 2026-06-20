## Problem

The behavioral test harness has structural flaws that allow bypass. When a test author (an AI agent) calls `with-test-home opencode-cli run` directly instead of using `behavior_run`, the test project is never created — there is no `.opencode/` in the CWD, no `session-init`, no `AGENTS.md`, causing the agent to immediately CRITICAL VIOLATION and burn the timeout without producing useful output.

This happened in practice: two test scripts (prompt-1.sh, prompt-2.sh) were written without `behavior_run`, ran from the XDG temp home (no `.opencode/`), and failed silently for the full 600s timeout.

**Root cause triad:**
1. No structural enforcement prevents raw `with-test-home opencode-cli run`
2. Test project and test home are siblings, not nested (test home in `tmp/test-home-*/`, test project in `tmp/behavior-isolated-*/`)
3. No per-test fixture hooks — tests that need custom fixtures have no supported path

## Target Architecture

```
tmp/test-home-/           XDG home (all XDG_* vars point here)
  test-project/               Project root (opencode-cli CWD)
    .opencode/                Cloned submodule at specified branch/commit
    .issues/                  Fixture issue data
    fixtures/                 Per-test fixture files
    tmp/                      Behavioral evidence artifacts
    .git/                     Git repo
    opencode.jsonc             (optional, project-level config)
```

`behavior_run` is the **single entry point** for all behavioral tests. `with-test-home` is an internal component. No test script ever calls `with-test-home directly`.

## Architectural Changes

### 1. Nest test project inside test home

**Current:**
```
tmp/test-home-/           (behavior_run calls with-test-home --setup)
tmp/behavior-isolated-XXXX/   (behavior_run creates separately — sibling)
```

**Target:**
```
tmp/test-home-/ 
  test-project/               (behavior_run creates inside test home)
    .opencode/
```

`behavior_run` calls `with-test-home --setup` FIRST to get `TEST_HOME`, then creates the test project at `$TEST_HOME/test-project/`.

### 2. Single entry point enforcement

`behavior_run` is the ONLY way to run a behavioral test. No test script calls `with-test-home` or `opencode-cli run` directly.

Enforcement layers:
- `with-test-home` refuses to run if `$(pwd)/.opencode` does not exist (requires CWD to be an initialized test project)
- `test-enforcement.sh` gains a grep lint for `with-test-home opencode-cli run` in `tests/behaviors/*.sh` — flags as FAIL
- `template.sh` includes a prominent WARNING block

### 3. Per-test setup hooks

`behavior_run` accepts a `BEHAVIOR_SETUP_SCRIPT` env var. If set, sources this script after cloning `.opencode` and seeding global fixtures, but before running the model.

The script receives `$WORKDIR` (path to test project root). It can:
- Create additional `.issues/` entries
- Modify the git state
- Add fixture files
- Check out a specific branch
- Any other repo alteration

If `BEHAVIOR_SETUP_SCRIPT` is not set, `behavior_run` looks for a script at `fixtures/${SCENARIO_NAME}.setup.sh` as fallback.

### 4. Submodule branch/commit control

| Variable | Purpose | Default |
|----------|---------|---------|
| `BEHAVIOR_SUBMODULE_BRANCH` | Check out specific `.opencode` branch | (none — use HEAD) |
| `BEHAVIOR_SUBMODULE_COMMIT` | Check out specific `.opencode` commit | (none — use HEAD) |

If both are set, `BEHAVIOR_SUBMODULE_COMMIT` wins.

### 5. Documentation updates

| File | What changes |
|------|-------------|
| `.opencode/tests/AGENTS.md` | Spec paradigm: single-entry-point, artifact-only generators. Document architecture, directory structure, hook mechanism. |
| `.opencode/tests/behaviors/template.sh` | Add WARNING: "DO NOT call with-test-home directly. DO NOT call opencode-cli run directly. Use behavior_run." |
| `helpers.sh` (function-level doc) | Document `behavior_run` as sole entry point |
| `.opencode/tests/AGENTS.md` §Infrastructure Details | Document `with-test-home` as internal component, not for direct test use |

## Implementation Items

### Phase 1: Core architecture

- [ ] Modify `behavior_run` to create test project inside test home (call `--setup` first, then create project at `$TEST_HOME/test-project/`)
- [ ] Update `with-test-home` to validate CWD has `.opencode/`
- [ ] Update artifact paths to resolve relative to test project
- [ ] Verify all existing 330 behavioral tests still work with new nesting

### Phase 2: Hooks and enforcement

- [ ] Add `BEHAVIOR_SETUP_SCRIPT` support to `behavior_run`
- [ ] Add `BEHAVIOR_SUBMODULE_BRANCH` support to `behavior_run`
- [ ] Add lint to `test-enforcement.sh` for raw `with-test-home opencode-cli run`
- [ ] Update `template.sh` with WARNING block

### Phase 3: Documentation

- [ ] Update `.opencode/tests/AGENTS.md`
- [ ] Update `helpers.sh` function-level docs
- [ ] Verify all doc layers are consistent (AGENTS.md → template.sh → helpers.sh → with-test-home)

## Open Questions

- Test scenario naming convention for per-test hooks (e.g., `scenario.setup.sh` alongside `scenario.sh`)?
- Migration: all 330 existing tests update automatically (behavior_run changed) or manual?
- Should `with-test-home --setup` accept a `--project-dir` flag for non-default project directory names?

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `behavior_run` creates test project inside test home, not as sibling | Behavioral | Test execution: run scenario; ls $TEST_HOME shows test-project/ with .opencode/ inside |
| SC-2 | Calling `with-test-home opencode-cli run` from non-.opencode directory FAILS | Behavioral | Test execution: direct call from tmp dir exits with error 2 |
| SC-3 | `behavior_run` sources per-test setup script when `BEHAVIOR_SETUP_SCRIPT` is set | Behavioral | Test execution: setup script creates marker file; verify it exists |
| SC-4 | `behavior_run` checks out specified submodule branch | Behavioral | Test execution: set BEHAVIOR_SUBMODULE_BRANCH, verify git status in .opencode/ |
| SC-5 | `test-enforcement.sh` flags raw `with-test-home opencode-cli run` | String | Content-verification: grep for pattern in test-enforcement.sh |
| SC-6 | `template.sh` contains DO NOT call warning | String | Content-verification: grep for warning text |
| SC-7 | All 330 existing tests produce identical artifacts (same dir structure, same files) | Structural | Pre/post change diff artifact manifest |
