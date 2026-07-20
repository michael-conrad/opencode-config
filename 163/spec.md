## [SPEC-FIX] Update Auditor Agent Card Temperature Values

**Status:** DRAFT

### Problem

All four adversarial auditor agent cards (`auditor-deepseek-flash.md`, `auditor-gemma4.md`, `auditor-mistral-large.md`, `auditor-qwen3.5.md`) uniformly use `temperature: 0.1`. Research across official model cards and inference guides shows that three of the four models should use higher temperatures due to their built-in thinking/reasoning modes, while Mistral Large 3 should use a lower temperature per its official production guidance.

### Proposed Changes

| File | Current | Recommended | Rationale |
|------|---------|-------------|-----------|
| `auditor-deepseek-flash.md` | 0.1 | **0.3** | Has Think High reasoning mode; low temp suppresses reasoning. Official: 1.0 general, 0.3–0.5 for reasoning |
| `auditor-gemma4.md` | 0.1 | **0.3** | Google: "standardized across all use cases: temp=1.0". Built-in thinking provides precision at higher temps |
| `auditor-mistral-large.md` | 0.1 | **0.05** | Official HF card: "temp below 0.1 for production environments". No thinking mode — precision from low temp |
| `auditor-qwen3.5.md` | 0.1 | **0.6** | Official thinking-mode recommendation is 0.6 (top_p=0.95, top_k=20) |

### Modifications

Single-line `temperature:` value change in each file's YAML frontmatter (line 5). No other changes.

### Files Affected

1. `.opencode/agents/auditor-deepseek-flash.md` — line 5: `temperature: 0.1` → `temperature: 0.3`
2. `.opencode/agents/auditor-gemma4.md` — line 5: `temperature: 0.1` → `temperature: 0.3`
3. `.opencode/agents/auditor-mistral-large.md` — line 5: `temperature: 0.1` → `temperature: 0.05`
4. `.opencode/agents/auditor-qwen3.5.md` — line 5: `temperature: 0.1` → `temperature: 0.6`

### Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `auditor-deepseek-flash.md` YAML has `temperature: 0.3` | `string` | grep line 5 |
| SC-2 | `auditor-gemma4.md` YAML has `temperature: 0.3` | `string` | grep line 5 |
| SC-3 | `auditor-mistral-large.md` YAML has `temperature: 0.05` | `string` | grep line 5 |
| SC-4 | `auditor-qwen3.5.md` YAML has `temperature: 0.6` | `string` | grep line 5 |
| SC-5 | No other file modifications beyond the 4 agent card files | `structural` | git diff --stat |
| SC-6 | YAML frontmatter remains valid after edit on all 4 files | `string` | `grep -c '^---$'` per file (expect exactly 2) |

### Research Sources

- DeepSeek V4: https://docs.sglang.io/cookbook/autoregressive/DeepSeek/DeepSeek-V4
- Gemma 4: https://build.nvidia.com/google/gemma-4-31b-it/modelcard
- Mistral Large 3: https://huggingface.co/mistralai/Mistral-Large-3-675B-Instruct-2512
- Mistral Docs: https://docs.mistral.ai/models/best-practices/sampling
- Qwen 3.5: https://github.com/kenotron-ms/llm-guides/blob/main/models/qwen3.5.md

### Risk

Low risk — temperature changes affect output determinism but within documented recommended ranges. Mistral Large 3's decrease from 0.1 to 0.05 may produce slightly more conservative audits. The other three models' increases should produce fuller reasoning output without sacrificing analytical precision.
🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)