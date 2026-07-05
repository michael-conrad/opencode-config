# Current System Analysis — Issue #162

## Adversarial-Audit Skill Architecture

### Components

| Component | Path | Lines | Purpose |
|-----------|------|-------|---------|
| SKILL.md | `.opencode/skills/adversarial-audit/SKILL.md` | ~100 | Skill definition, dispatch routing |
| resolve-models tool | `.opencode/tools/resolve-models` | 221 | Random cross-family auditor selection |
| qualified pool | `.opencode/tests/qualification/qualified-auditor-pool.sh` | 19 | Lists 4 qualified models |
| auditor-deepseek-flash | `.opencode/agents/auditor-deepseek-flash.md` | 415 | Model-specific auditor card |
| auditor-gemma4 | `.opencode/agents/auditor-gemma4.md` | 415 | Model-specific auditor card |
| auditor-mistral-large | `.opencode/agents/auditor-mistral-large.md` | 415 | Model-specific auditor card |
| auditor-qwen3.5 | `.opencode/agents/auditor-qwen3.5.md` | 415 | Model-specific auditor card |
| Task files (15) | `.opencode/skills/adversarial-audit/tasks/*.md` | 220-632 each | Audit phase procedures |

### Dispatch Flow

1. `resolve-models` selects 2 auditors from different families (random draw)
2. auditor-1 dispatched via `task()` → if FAIL, remediate + restart from step 1
3. auditor-2 dispatched via `task()` → if FAIL, remediate + restart from step 1
4. cross-validate dispatched via `task()` → reads both verdict artifacts

### Pain Points

- **INSUFFICIENT_FAMILIES**: Blocks all audits when <2 model families available
- **Cloud dependency**: All 4 qualified models are cloud-hosted
- **Card maintenance**: 4 identical cards must be kept in sync
- **Conditional logic**: 15 task files branch on `audit_phase`
- **Sequential dispatch**: auditor-2 waits for auditor-1, no parallelism
- **~1,900 lines** of model-selection infrastructure
