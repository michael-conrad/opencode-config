## Summary

This spec addresses three concerns: (1) document the opencode agent card parameter passthrough mechanism (options field) discovered from source code analysis at anomalyco/opencode, (2) create a template auditor agent card with placeholders for model-specific parameters, and (3) research and apply optimal model-specific parameters for the four auditor agents based on official provider documentation.

## Background

Research into opencode agent configuration discovered that the opencode.ai docs at opencode.ai/docs/agents/ are **partially incorrect**: the docs show `reasoningEffort` and `textVerbosity` as top-level agent fields, but the opencode source code (`packages/opencode/src/agent/agent.ts`) only reads known fields and silently drops unknowns. The correct passthrough mechanism is the `options` field: `"options": { "reasoningEffort": "high" }`.

Source code trace:
- `agent.ts`: `item.options = mergeDeep(item.options, value.options ?? {})`
- `llm/request.ts`: `mergeOptions(base, input.model.options, input.agent.options, variant)`
- `provider/transform.ts`: `providerOptions(model, options)` wraps under provider's AI SDK key

## Deliverables

### Phase 1: Create/Revise `AGENTS.md` in `.opencode/agents/`

Create a file `.opencode/agents/AGENTS.md` documenting:

1. All supported agent card frontmatter fields with their routing paths
2. The correct passthrough mechanism via `options` field
3. Provider-specific parameters that can be set via `options`
4. Model-specific recommended parameter values from official docs (with citations)

### Phase 2: Auditor Template Agent Card

Create a template `.opencode/agents/auditor-template.md` with:
- Common frontmatter skeleton (mode, steps, permissions)
- Placeholders for `model`, `temperature`, `top_p`, `options`
- Comments explaining which parameters to fill and what values are recommended per model family

### Phase 3: Parameter Optimization for Auditor Cards

Based on online research:

| Card | Current Temp | Recommended Temp | Recommended options | Source |
|------|-------------|-----------------|---------------------|--------|
| auditor-deepseek-flash | 0.3 | 0.3 (no change) | No `temperature`/`top_p` needed - DeepSeek thinking mode ignores them. `reasoning_effort: "high"` is already handled by opencode's variant system per `transform.ts`. | DeepSeek API docs: thinking mode disables temperature/top_p/frequency_penalty |
| auditor-mistral-large | 0.05 | 0.05 (no change) | `top_p: 0.8` (reduce from default 1.0 for more deterministic sampling). Mistral docs recommend 0.0-0.7 temperature range. Consider `safe_prompt: true`. | Mistral sampling docs; Mistral API reference |
| auditor-gemma4 | 0.3 | 0.3 (no change) | `top_p: 0.85` (standard deterministic setting). Gemma 4 uses Google/AI SDK format. | Google AI docs for Gemma |
| auditor-qwen3.5 | 0.6 | **0.3** (reduce for audit determinism) | `top_p: 0.85`. Current 0.6 is too creative for adversarial auditing - PASS/FAIL binary verdicts require focused, deterministic output. | Qwen API docs (Alibaba Cloud) |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `.opencode/agents/AGENTS.md` exists and documents all frontmatter fields with routing paths | `structural` | File existence + content verification |
| SC-2 | AGENTS.md includes the `options` passthrough mechanism with source code citations | `string` | grep for "options" and "passthrough" |
| SC-3 | AGENTS.md documents provider-specific parameters by model family | `string` | grep for model family names + parameter names |
| SC-4 | `.opencode/agents/auditor-template.md` exists with placeholders for model-specific values | `structural` | File existence check |
| SC-5 | Template card includes comments explaining recommended parameter ranges per model family | `string` | grep for "REPLACE", "recommended", or comment markers |
| SC-6 | auditor-qwen3.5 temperature changed from 0.6 to 0.3 | `string` | grep for `temperature: 0.3` in auditor-qwen3.5.md |
| SC-7 | auditor-deepseek-flash card has `options` with reasoning_effort comment | `string` | grep for `reasoningEffort` in auditor-deepseek-flash.md |
| SC-8 | auditor-mistral-large card has `options` with top_p set | `string` | grep for `top_p` in auditor-mistral-large.md |
| SC-9 | Behavioral test verifies all 4 auditor cards have correct frontmatter fields | `behavioral` | `opencode-cli run` with clean-room semantic inspection |
| SC-10 | All source code claims in AGENTS.md include verified URLs to anomalyco/opencode source | `semantic` | Sub-agent reads AGENTS.md and verifies each URL via webfetch |

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| DeepSeek reasoning_effort conflicts with opencode variant system | Low | Low | opencode's `ProviderTransform.variants()` already handles deepseek reasoning via openai-compatible provider; setting in `options` would merge correctly |
| Qwen 3.5 temperature reduction makes audits too rigid | Medium | Low | 0.3 is standard for deterministic tasks; auditor protocol already requires PASS/FAIL binary verdicts - less creativity is better |
| Mistral top_p=0.8 may interact poorly with temperature=0.05 | Low | Low | Both parameters control sampling diversity; at temperature=0.05, top_p has minimal effect - safe to set |
| Gemma 4 parameter support via Ollama differs from Google AI | Medium | Low | Ollama may not pass all options through; parameters set via `options` are silently dropped by Ollama, not by opencode |