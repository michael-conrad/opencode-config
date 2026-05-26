# Synced from GitHub Issue #101 at 2026-05-22T21:55:51Z

## Problem

Behavioral tests fail for cloud model dispatches due to three independent issues in the test infrastructure:

1. **`env -i` strips `XDG_RUNTIME_DIR`** — opencode-cli cannot create/find sessions in clean test homes, causing "Session not found" on all cloud model dispatches
2. **`with-test-home` has no sourcing guard** — `helpers.sh` sources it to populate the model pool, but the sourcing guard is missing, causing `exit 2` when sourced
3. **Model pool population bypasses `opencode-cli models`** — `helpers.sh` sources `ollama_models()` from `with-test-home` (which uses `ollama list`) instead of `opencode-cli models`, the authoritative source
4. **Missing mandatory env vars in `env -i`** — `SHELL`, `LOGNAME`, `LANG` are stripped, which can cause subprocess and locale issues

Additionally, **deepseek-v3.2:cloud** fails SC-6 behavioral assertion "Agent does NOT reference the direct tool path" — it outputs `.opencode/tools/resolve-models` literally in agent output. The task file `resolve-models.md` exposes the literal path, and deepseek-v3.2 echoes it directly rather than abstracting the reference.

## Root Cause

| Issue | Root Cause |
|-------|-----------|
| Session not found | `env -i` in `with-test-home` strips `XDG_RUNTIME_DIR` — opencode-cli needs this for SQLite session management |
| Sourcing failure | `with-test-home` had no `BASH_SOURCE` guard — sourcing the file ran its main body which called `exit` |
| Wrong model pool | `BEHAVIORAL_MODEL_POOL` sourced `ollama_models()` via `ollama list` — not authoritative; can contain models unknown to opencode-cli |
| Tool path in output | `resolve-models.md` task file uses literal `bash .opencode/tools/resolve-models` — deepseek-v3.2 quotes this directly in its output |

## Fix Approach

### Already Implemented (uncommitted on remediate/695-audit-verification)

| Fix | File | Status |
|-----|------|--------|
| Sourcing guard (`BASH_SOURCE` check) | `tests/with-test-home` | Done |
| `XDG_RUNTIME_DIR` in `env -i` | `tests/with-test-home` | Done |
| `SHELL`, `LOGNAME`, `LANG` in `env -i` | `tests/with-test-home` | Done |
| `$TEST_HOME/.runtime/` directory creation | `tests/with-test-home` | Done |
| Model pool from `opencode-cli models` with `shuf` + cloud filter | `tests/behaviors/helpers.sh` | Done |
| Model display name strip (remove `ollama/` prefix) | `tests/behaviors/helpers.sh` | Done |

### Needs Implementation

**SC-5: deepseek-v3.2:cloud no longer references direct tool path.**

Add explicit instruction to `adversarial-audit/SKILL.md` prohibiting the literal tool path from appearing in agent output. The current language at line 41 ("The resolve-models tool path is encapsulated by the task file") is advisory — deepseek-v3.2 ignores it. Need a stronger directive: "The literal path `.opencode/tools/resolve-models` MUST NOT appear in agent output. Always describe the procedure abstractly (e.g., 'Invoke the resolve-models task' or 'dispatch a resolve-models sub-agent')."

## Success Criteria

| ID | Criterion | Current Status |
|----|-----------|---------------|
| SC-1 | `with-test-home` has sourcing guard preventing main body execution when sourced | DONE (uncommitted) |
| SC-2 | `env -i` includes `XDG_RUNTIME_DIR`, `SHELL`, `LOGNAME`, `LANG` | DONE (uncommitted) |
| SC-3 | `BEHAVIORAL_MODEL_POOL` populated from `opencode-cli models` → `ollama/*:cloud` → `shuf` → `head -2` | DONE (uncommitted) |
| SC-4 | Model display strips `ollama/` prefix in output | DONE (uncommitted) |
| SC-5 | `adversarial-audit/SKILL.md` prohibits literal tool path in agent output; deepseek-v3.2:cloud no longer references `.opencode/tools/resolve-models` | NEEDS IMPLEMENTATION |
| SC-6 | Behavioral test `632-sc6-behavioral-resolve-models-task-entry-point.sh` PASS for ALL models in `BEHAVIORAL_MODEL_POOL` | deepseek-v4-pro:cloud PASSES, deepseek-v3.2:cloud FAILS on direct tool path |

## Affected Files

| File | Change |
|------|--------|
| `.opencode/tests/with-test-home` | Sourcing guard, XDG_RUNTIME_DIR, SHELL/LOGNAME/LANG, .runtime dir |
| `.opencode/tests/behaviors/helpers.sh` | Model pool from opencode-cli models, display name strip |
| `.opencode/skills/adversarial-audit/SKILL.md` | Add explicit prohibition of literal tool path in agent output |

## Non-Goals

- No changes to `resolve-models.md` task file
- No changes to `ollama-model-resolve` or `ollama-probe` tools
- No changes to individual behavioral test scripts (except infrastructure files listed above)
- No changes to submodule pointer or release branch
- Issue #96 already covers further model pool refactoring (removing `ollama_models()` entirely, using `opencode-cli models` for config generation) — this spec does not overlap with #96 SCs

## Risk Analysis

| Risk | Mitigation |
|------|------------|
| deepseek-v3.2:cloud still references tool path after SKILL.md change | If SKILL.md language is insufficient, fall back to changing `resolve-models.md` to use placeholder instead of literal path |
| XDG_RUNTIME_DIR path in test home may have different semantics from real runtime dir | `$TEST_HOME/.runtime` is a standard directory with 0700 permissions — opencode-cli only needs a writable path for session files |
| `opencode-cli models` may fail if CLI not installed | Model pool falls back to empty → test prints warning and SKIP |

## Relationship to Existing Issues

- **#96** — `[SPEC-FIX] Use opencode-cli models for behavioral testing model discovery` — covers further refactoring of model pool; this spec covers the immediate fixes needed to make tests PASS
- **#706** — Existing infrastructure issue documenting root causes; this spec formalizes the remediation

## Revision Notes

- **v1.0** — Initial creation from infrastructure fixes discovered during remediate/695-audit-verification work

Co-authored with AI: OpenCode (deepseek-v4-flash)