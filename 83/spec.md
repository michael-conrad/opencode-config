### Bug: resolve-models returns raw model strings instead of subagent_type strings

**Source:** `adversarial-audit/tasks/resolve-models.md`

**Expected behavior (per spec):**
The `resolve-models` task must return `subagent_type` strings (e.g., `auditor-qwen3.5`, `auditor-kimi-k2`) so the orchestrator can dispatch via `task(subagent_type="auditor-qwen3.5")`. This is explicitly required in:
- Step 6: Return contract shows `auditor_1: "auditor-<family>-<variant>"`
- Red Flag line 113: "Never return raw model strings (e.g., `ollama/glm-5.1:cloud`) — always return `subagent_type` strings (e.g., `auditor-glm-5.1`)"

**Actual behavior:**
The task returns raw model strings directly from `qualified-auditor-pool.sh` (e.g., `qwen3.5:397b-cloud`, `kimi-k2.6:cloud`) instead of the mapped `subagent_type` strings (e.g., `auditor-qwen3.5`, `auditor-kimi-k2`).

**Impact:**
The orchestrator cannot dispatch `task(subagent_type="qwen3.5:397b-cloud")` — `subagent_type` values must match named agent types (e.g., `auditor-qwen3.5`). Raw model strings are not valid `subagent_type` values, so dual-auditor dispatch is broken.

**Root cause candidates:**
1. The mapping step (Step 2: derive `subagent_type` from raw model name) may be skipped or incorrectly implemented
2. Step 4/5 may propagate raw pool strings instead of mapped agent names
3. The result contract at Step 6 may need enforcement that `auditor_1`/`auditor_2` do not contain raw model strings

**Relevant files:**
- `.opencode/skills/adversarial-audit/tasks/resolve-models.md` — the task definition (spec)
- `.opencode/tests/qualification/qualified-auditor-pool.sh` — raw model pool
- `.opencode/agents/auditor-*.md` — agent files whose names match the expected subagent_type format

**Labels:** bug, resolve-models, adversarial-audit