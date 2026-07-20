# Fix Spec: Blacklist deepseek-v4-pro and devstral-2 from Auditor Pool

## Root Cause

Two auditor models have become unsuitable for production use in the adversarial audit pipeline:

1. **deepseek-v4-pro** — prohibitively expensive for auditor dispatch. The adversarial-audit skill dispatches auditors frequently (every `cross-validate` call uses two). At DeepSeek V4 Pro pricing, routine cross-validation audit runs incur unacceptably high cost with no quality gain over `deepseek-v4-flash` or `deepseek-v3`.

2. **devstral-2** — consistently poor performance as an adversarial auditor. The Devstral 2 model produces unreliable verdicts, fails to follow structured JSON output format, and has shown quality issues in qualification testing that make it unsuitable for the adversarial cross-validation role where a false PASS is strictly worse than a false FAIL.

Both models currently appear in the qualified auditor pool (`qualified-auditor-pool.sh`) and have corresponding agent definition files (`.opencode/agents/auditor-deepseek-v4.md`, `.opencode/agents/auditor-devstral-2.md`). The `resolve-models` task includes both in its family mapping table and selection logic.

## Fix Approach

Remove both models from the active auditor pool AND delete their agent definition files. Deletion (not deprecation comments) is the correct approach because:

- The pool script is the single source of truth — absent models are never selected
- Agent definition files for missing pool entries are dead code
- The `resolve-models` task glob-verifies agent files before inclusion; deleted files are auto-excluded
- Comments in pool scripts get ignored by automated consumers

### Changes Required

| File | Change | Reason |
|------|--------|--------|
| `.opencode/tests/qualification/qualified-auditor-pool.sh` | Remove lines `deepseek-v4-pro:cloud` and `devstral-2:123b-cloud` from MODELS heredoc | Pool is the canonical source — removal prevents selection |
| `.opencode/agents/auditor-deepseek-v4.md` | **Delete** | Agent file for removed model is dead code |
| `.opencode/agents/auditor-devstral-2.md` | **Delete** | Agent file for removed model is dead code |
| `.opencode/skills/adversarial-audit/tasks/resolve-models.md` | Remove both models from Step 2 mapping table, Step 3 mapping table, and Step 5 family priority list; remove `devstral` family entirely; update DeepSeek family priority to `auditor-deepseek-flash > auditor-deepseek-v3` | Mapping table must reflect actual pool; `devstral` family has no remaining members |

### Files NOT Changed

| File | Reason No Change Needed |
|------|------------------------|
| `.opencode/skills/adversarial-audit/SKILL.md` | SKILL.md rules are model-agnostic (cross-family, dual dispatch, consensus gate). No model-specific references. |
| `.opencode/skills/adversarial-audit/tasks/cross-validate.md` | Consumes resolved agent types; does not reference specific models. |
| `.opencode/tests/enforcement/agents-content/test-all-auditor-agents.sh` | Test references agent names; deleted agents will simply not be found by glob — no test failure. |

## Success Criteria

| ID | Criterion | Verification Method |
|----|-----------|-------------------|
| SC-1 | `qualified-auditor-pool.sh` contains exactly 7 models (was 9) — neither `deepseek-v4-pro:cloud` nor `devstral-2:123b-cloud` appear | `bash -c '.opencode/tests/qualification/qualified-auditor-pool.sh \| grep -c ""'` returns 7; grep for removed models returns nothing |
| SC-2 | Files `auditor-deepseek-v4.md` and `auditor-devstral-2.md` do not exist in `.opencode/agents/` | `ls .opencode/agents/auditor-deepseek-v4.md .opencode/agents/auditor-devstral-2.md` fails with "not found" |
| SC-3 | `resolve-models.md` Step 2 mapping table has 7 rows (no deepseek-v4-pro, no devstral-2) | `grep -c 'auditor-' resolve-models.md §Step 2 table` counts 7 unique agents |
| SC-4 | `resolve-models.md` no longer contains `devstral` family references or DeepSeek V4 Pro references | `grep -i 'devstral\|deepseek-v4-pro' resolve-models.md` returns 0 matches |
| SC-5 | Remaining 7 agent files exist and are unchanged | `ls .opencode/agents/auditor-*.md \| wc -l` returns 7 |
| SC-6 | DeepSeek family priority updated to `auditor-deepseek-flash > auditor-deepseek-v3` | Read `resolve-models.md` Step 5 shows updated priority |

## Impact

- **Pool size**: 9 → 7 qualified auditor models
- **Families**: 6 → 5 (deepseek, glm, mistral, kimi, qwen — `devstral` removed entirely)
- **DeepSeek family**: 3 → 2 agents (flash + v3.2 remain; v4-pro removed)
- **Cost**: Routine adversarial audits no longer consume DeepSeek V4 Pro credits
- **Quality**: Cross-validation no longer risks unreliable verdicts from Devstral 2
- **Minimum families**: 5 ≥ 2 (cross-family requirement still satisfied)

## PR Merge Boundaries

None — this is a self-contained removal with no dependencies on other specs or PRs.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5)