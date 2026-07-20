## [SPEC-FIX] Change default BEHAVIOR_MODEL from glm-5.1:cloud to deepseek-v4-flash:cloud

### Problem
The `glm-5.1:cloud` model times out on behavioral tests. The SC-22 test (verification gate enforcement) consistently fails at the default 420s (7 minute) timeout when using the `ollama/glm-5.1:cloud` model as `BEHAVIOR_MODEL`.

### Root Cause
The default behavioral test model (`ollama/glm-5.1:cloud`) is too slow for complex scenarios requiring semantic inspection via `assert_semantic`. The model consistently exceeds the 420s timeout on SC-22, causing false FAIL results that mask real defects or block CI.

### Fix
Change the default `BEHAVIOR_MODEL` in `.opencode/tests/behaviors/helpers.sh` line 16 from `ollama/glm-5.1:cloud` to `ollama/deepseek-v4-flash:cloud`.

### Scope
- **IN SCOPE**: `.opencode/tests/behaviors/helpers.sh` line 16 — single-line default model change
- **NOT IN SCOPE** (MUST NOT be changed):
  - Historical byline references in test files (e.g., `Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)`) — these are historical attribution
  - `auditor-glm-5.1.md` and `auditor-glm-5.md` agent configs — auditor dispatch, not behavioral test default
  - `cross-validate.md` references to `auditor-glm-5.1` as auditor type — auditor family dispatching
  - Any other file in the repository

### Affected File
- `.opencode/tests/behaviors/helpers.sh` — line 16

### Proposed Change
```bash
# Before (line 16):
BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/glm-5.1:cloud}"

# After:
BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/deepseek-v4-flash:cloud}"
```

### Success Criterion
- Single-line change in `helpers.sh` line 16: `BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/deepseek-v4-flash:cloud}"`
- All behavioral tests pass with the new default model
- No other files modified

Note: Verification-enforcement gate is skipped — this is a trivial single-line default value change with no prose claims requiring live-source verification.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)