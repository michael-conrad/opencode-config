# Plan: Fix adversarial-audit dispatch path in implementation-pipeline SKILL.md

**Spec:** #1246
**File:** `.opencode/skills/implementation-pipeline/SKILL.md`
**Phase:** 1 (single file, single concern)
**Authorization scope:** `for_pr`
**PR strategy:** stacked

## Phase 1: Fix adversarial-audit dispatch routing table

**Concern:** The Dispatch Routing Table documents a single `adversarial-audit --task verification-audit` call via `general` subagent_type, but the correct workflow requires resolve-models + dual-dispatch + cross-validate with auditor_artifact_paths.

### Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1 | Update adversarial-audit row to document resolve-models + dual-dispatch sequence |
| 2 | SC-2 | Update cross-validate row to document receiving auditor_artifact_paths |
| 3 | SC-6 | Update Step Labels section to include resolve-models or multi-dispatch pattern |
| 4 | SC-3,4,5 | Add resolve-models pre-flight note to Dispatch Routing Table |

### TDD Steps

- [ ] 1 (RED): Write behavioral enforcement tests

  **Files to create:**
  - `.opencode/tests/behaviors/1246-sc1-adversarial-audit-dispatch-row.sh` — SC-1: verifies dispatch routing table row documents resolve-models + dual-dispatch
  - `.opencode/tests/behaviors/1246-sc2-cross-validate-artifact-paths.sh` — SC-2: verifies cross-validate row documents auditor_artifact_paths
  - `.opencode/tests/behaviors/1246-sc3-resolve-models-preflight.sh` — SC-3,4,5: verifies orchestrator runs resolve-models before auditor dispatch, dispatches two auditors with cross-family types, and step labels include multi-dispatch pattern

  **Behavioral test approach (SC-3,4,5):** Send a prompt asking the orchestrator to execute the adversarial-audit pipeline step. Verify stderr shows:
  - `resolve-models` tool call before auditor dispatch
  - `subagent_type=auditor_1` / `subagent_type=auditor_2` (not `general`)
  - Two distinct auditor task() calls

  **Content-verification tests (SC-1,2,6):** grep for updated row text in SKILL.md.

- [ ] 2 (GREEN): Apply changes to SKILL.md

  **File:** `.opencode/skills/implementation-pipeline/SKILL.md`

  **Change 1 — Update adversarial-audit dispatch row (line 60):**

  Current:
  ```
  | `adversarial-audit` | `adversarial-audit --task verification-audit` | dual-auditor YAML verdicts |
  ```

  New:
  ```
  | `adversarial-audit` | Resolve models → dispatch auditor_1 → dispatch auditor_2 | dual-auditor YAML verdicts per auditor |
  ```

  **Change 2 — Update cross-validate row (line 61):**

  Current:
  ```
  | `cross-validate` | `adversarial-audit --task cross-validate` | cross-validate findings YAML |
  ```

  New:
  ```
  | `cross-validate` | `adversarial-audit --task cross-validate` (receives `auditor_artifact_paths` from adversarial-audit step) | cross-validate findings YAML |
  ```

  **Change 3 — Update Step Labels (line 78):**

  Current:
  ```
  `sc-coherence-gate`, `pre-red-baseline`, `red-phase`, `red-doublecheck`, `post-red-enforcement`, `green-phase`, `post-green-enforcement`, `checkpoint-commit`, `structural-checks`, `green-doublecheck`, `green-vbc`, `adversarial-audit`, `cross-validate`, `regression-check`, `review-prep`, `exec-summary`
  ```

  New: No change needed — the step label `adversarial-audit` remains the same. The multi-dispatch pattern is documented in the Dispatch Routing Table note (Change 4).

  **Change 4 — Add resolve-models pre-flight note to Dispatch Routing Table:**

  Add after the routing table (after line 64):

  ```markdown
  **Note:** The `adversarial-audit` step is a multi-dispatch sequence, not a single task() call:
  1. Run `.opencode/tools/resolve-models` to select cross-family auditors
  2. Dispatch `verification-audit` with `subagent_type` from `auditor_1`
  3. Dispatch `verification-audit` with `subagent_type` from `auditor_2`
  4. Collect both `artifact_path` values and pass as `auditor_artifact_paths` context to `cross-validate`
  ```

- [ ] 3 (REFACTOR): Verify

  - Run content-verification tests: `bash .opencode/tests/test-enforcement.sh --tag 1246`
  - Run behavioral tests: `bash .opencode/tests/behaviors/1246-sc1-adversarial-audit-dispatch-row.sh`, etc.
  - Verify lint: `uvx ruff check .opencode/skills/implementation-pipeline/SKILL.md` (advisory)
  - Verify all SCs from spec #1246 are met

### SC-to-Step Mapping

| SC | Evidence Type | Step | Verification |
|----|---------------|------|-------------|
| SC-1 | `string` | Step 2 (Change 1) | grep for updated row text |
| SC-2 | `string` | Step 2 (Change 2) | grep for `auditor_artifact_paths` in cross-validate row |
| SC-3 | `behavioral` | Step 1 (RED) + Step 2 | `opencode-cli run` → stderr shows `resolve-models` before auditor dispatch |
| SC-4 | `behavioral` | Step 1 (RED) + Step 2 | `opencode-cli run` → stderr shows `subagent_type=auditor_1`/`auditor_2` |
| SC-5 | `behavioral` | Step 1 (RED) + Step 2 | `opencode-cli run` → stderr shows two distinct auditor task() calls |
| SC-6 | `string` | Step 2 (Change 4) | grep/ls pattern match for multi-dispatch note |
