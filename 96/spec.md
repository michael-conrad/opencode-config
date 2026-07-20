## Problem

Behavioral testing infrastructure has two parallel model discovery paths that are inconsistent:

1. **`seed_model_config()` in `with-test-home`** discovers models via `ollama list` and hardcoded fallbacks (`phi4-mini:3.8b`, `llama3.2:3b`, `qwen3.5:27b`) — generating a test `opencode.jsonc` that may not match what `opencode-cli` actually sees.
2. **`behavior_resolve_model()` in `helpers.sh`** uses `ollama-model-resolve` (which calls `ollama-probe list`) for model selection — also bypassing `opencode-cli`.
3. **`BEHAVIORAL_MODEL_POOL` in `helpers.sh`** sources `ollama_models()` from `with-test-home` — yet another call through `ollama list`.

All three paths bypass the authoritative source: **`opencode-cli models`** — which is what the agent actually sees at runtime. Additionally, `seed_model_config()` contains dead fallback paths to hardcoded models and `ollama list` that serve no purpose: if `opencode-cli` is unavailable, tests mechanically fail anyway.

## Success Criteria

**SC-1:** `seed_model_config()` in `with-test-home` uses `opencode-cli models` → filter `ollama/*` entries as **sole** discovery path for the test `opencode.jsonc` `ollama` provider model list. No fallback to `ollama list` or hardcoded model list. If `opencode-cli` is unavailable and returns no models, the existing `HARNESS_FAILURE: no models available` exit 2 fires naturally.

**SC-2:** `behavior_resolve_model()` in `helpers.sh` uses `opencode-cli models` → filter `ollama/*` → cross-reference with `ollama list` (detect cloud models via size `"-"`) → picks **first cloud model** as `BEHAVIOR_CLOUD_MODEL`. Also populate `BEHAVIOR_LOCAL_MODEL` from the first non-cloud (size != `"-"`) model in the intersection; if intersection is empty, `BEHAVIOR_LOCAL_MODEL` falls back to `ollama/glm-5.1:cloud`. Both fallback: `ollama/glm-5.1:cloud`.

**SC-3:** `BEHAVIORAL_MODEL_POOL` in `helpers.sh` populated from `opencode-cli models` → filter `ollama/*`. Remove `source "$_HELPERS_DIR/../with-test-home"` and `ollama_models()` call.

**SC-4:** `ollama_models()` function in `with-test-home` is **removed entirely** — no callers remain after SC-1 through SC-3 are complete.

**SC-5:** Update content-verification test `632-resolve-models-tool-command-content.sh` — remove or update SC-12a/b/c which assert presence of `ollama_models()`, `source with-test-home`, and `mapfile BEHAVIORAL_MODEL_POOL` in `helpers.sh`. Replace with assertions for the new `opencode-cli models`-based logic.

## Removed Code

| Code | Location | Reason |
|---|---|---|
| `ollama_models()` function | `with-test-home` | Dead code — no callers remain |
| `ollama list` + fallback models in `seed_model_config()` | `with-test-home` | Dead fallback path; replaced by `opencode-cli models` |
| `source "$_HELPERS_DIR/../with-test-home"` | `helpers.sh:377-384` | No longer needed; replaced by `opencode-cli models` |
| Hardcoded fallback `models=("phi4-mini:3.8b" ...)` | `with-test-home` | Not authoritative; no purpose |
| Content-verification assertions referencing removed code | `632-resolve-models-tool-command-content.sh` SC-12a/b/c | Must be updated to match new logic |

## What Stays

| Code | Location | Reason |
|---|---|---|
| `ollama list` usage in `helpers.sh` for cloud detection | `helpers.sh` | Needed to distinguish cloud (size `"-"`) from local models |
| `ollama-model-resolve` tool | `.opencode/tools/ollama-model-resolve` | Unchanged; kept for non-test contexts |

## Risk Analysis

| Risk | Mitigation |
|---|---|
| `opencode-cli models` unavailable | Config gen naturally produces empty model list → `HARNESS_FAILURE` exit 2 on first test run — clear signal |
| `ollama list` format change | Cloud detection via size `"-"` is stable across ollama versions |
| Cloud model unreachable | Default cloud model selection may mean first test run requires network — acceptable for behavioral testing |
| No `ollama/*` models in `opencode-cli models` | `BEHAVIOR_CLOUD_MODEL` and `BEHAVIOR_LOCAL_MODEL` both fall back to `ollama/glm-5.1:cloud` |

## Non-Goals

- No changes to individual behavioral test scripts (except content-verification test SC-12a/b/c which must be updated to match the new logic)
- No changes to `ollama-model-resolve` or `ollama-probe` tools
- No explicit `opencode-cli` presence gate (mechanical failure is sufficient)
