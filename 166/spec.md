[SPEC-FIX] Mandatory pre-flight: use behavior_run before custom test env construction

## Problem

Repeated pattern: agent hand-crafts bespoke test environments (mkdir, opencode.jsonc with one model, git init, manual opencode-cli run) when the existing `behavior_run` helper in `.opencode/tests/behaviors/helpers.sh` already does this correctly:

1. Creates isolated git repo (line 144-148)
2. Clones .opencode submodule (line 161-167)
3. Runs via `with-test-home` with `TEST_WORKDIR` (line 213-218)
4. Exports SQLite DB to `session.yaml` (line 299)
5. Writes manifest.yaml, stdout.log, stderr.log, exit_code (lines 278-296)

No agent reads the test AGENTS.md carefully enough to discover this before building their own infrastructure.

## Fix

1. Add a **Mandatory Pre-Flight Check** section to `.opencode/tests/AGENTS.md` — before ANY test env construction, agent MUST check if `behavior_run` meets the need
2. Add cross-reference comments to `helpers.sh` key functions documenting the artifact pipeline
3. Add comments to `with-test-home` noting its role in the artifact pipeline and the `TEST_WORKDIR` contract

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | AGENTS.md has Mandatory Pre-Flight Check section before the Paradigm section | `string` |
| SC-2 | AGENTS.md specifies: "Before constructing any test environment, verify whether behavior_run (or behavior_run_pool) already meets the need. If it does, DO NOT hand-craft." | `string` |
| SC-3 | helpers.sh has docstring on behavior_run stating it is THE canonical test runner, not an option | `string` |
| SC-4 | with-test-home has comment about TEST_WORKDIR contract for isolated test repos | `string` |
| SC-5 | All existing behavioral test scripts in tests/behaviors/ use behavior_run (grep returns 0 hits for hand-crafted opencode-cli run patterns) | `structural` |

🤖 Co-authored with AI: DeepSeek V4 Flash (ollama-cloud/deepseek-v4-flash)