## Problem

The testing framework currently uses two different default models for CLI `opencode-cli run` invocations:

- **Behavioral tests**: `ollama/deepseek-v4-flash:cloud`
- **Content-verification tests**: `ollama-cloud/glm-5.1`

These defaults need to be updated to `ollama/qwen3.6:35b-256k` as the new standard model for all test runs.

## Affected Files

| File | Line(s) | Current Value | Change |
|------|---------|---------------|--------|
| `.opencode/tests/behaviors/helpers.sh` | 40 | `BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/deepseek-v4-flash:cloud}"` | Update default to `ollama/qwen3.6:35b-256k` |
| `.opencode/tests/test-enforcement.sh` | 69 | `MODEL="${ENFORCEMENT_TEST_MODEL:-ollama-cloud/glm-5.1}"` | Update default to `ollama/qwen3.6:35b-256k` |
| `.opencode/tests/test-verification-honesty.sh` | 43 | `MODEL="${ENFORCEMENT_TEST_MODEL:-ollama-cloud/glm-5.1}"` | Update default to `ollama/qwen3.6:35b-256k` |
| `.opencode/tests/AGENTS.md` | 180, 187, 190, 219 | Documents `ollama/deepseek-v4-flash:cloud` | Update documentation references |
| `.opencode/tests/behaviors/1165-yaml-quoting.sh` | 19 | `echo "Model: ${BEHAVIOR_MODEL:-ollama/deepseek-v4-flash:cloud}"` | Update fallback in echo (cosmetic) |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `BEHAVIOR_MODEL` default in `helpers.sh` is `ollama/qwen3.6:35b-256k` | `string` | grep for the default value |
| SC-2 | `MODEL` default in `test-enforcement.sh` is `ollama/qwen3.6:35b-256k` | `string` | grep for the default value |
| SC-3 | `MODEL` default in `test-verification-honesty.sh` is `ollama/qwen3.6:35b-256k` | `string` | grep for the default value |
| SC-4 | `AGENTS.md` documentation references updated to `ollama/qwen3.6:35b-256k` | `string` | grep for stale model references |
| SC-5 | Behavioral test `1165-yaml-quoting.sh` fallback echo updated | `string` | grep for the fallback value |
| SC-6 | Env var override still works: `BEHAVIOR_MODEL=custom-model` overrides default | `behavioral` | Run a behavioral test with `BEHAVIOR_MODEL=custom-model` and verify it uses that model |
| SC-7 | Env var override still works: `ENFORCEMENT_TEST_MODEL=custom-model` overrides default | `behavioral` | Run a content-verification test with `ENFORCEMENT_TEST_MODEL=custom-model` and verify it uses that model |

## Implementation Notes

- This is a straightforward string replacement — no logic changes
- The env var override pattern (`${VAR:-default}`) must be preserved
- The `with-test-home` wrapper's fallback models (line 85: `phi4-mini:3.8b`, `llama3.2:3b`, `qwen3.5:27b`) are only used when `ollama list` returns no models — these are a secondary concern and do NOT need to change as part of this fix
- All changes are in `.opencode/` (the submodule), so the submodule pointer will need updating in the parent repo

## Risk Assessment

- **Low risk**: String-only changes to default values
- **No behavioral impact**: The env var override pattern is preserved, so existing CI/CD pipelines that set `BEHAVIOR_MODEL` or `ENFORCEMENT_TEST_MODEL` will continue to work unchanged
- **Test risk**: Behavioral tests (SC-6, SC-7) verify the override pattern still works — these are the only tests that require actual `opencode-cli run` execution

## Change Control

- **Status**: DRAFT
- **Author**: AI agent
- **Date**: 2026-06-26

---

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*