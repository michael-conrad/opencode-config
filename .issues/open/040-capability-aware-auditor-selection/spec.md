---
issue_number: 40
title: "[SPEC] Capability-Aware Auditor Selection & Dispatch — Thinking Levels and Multimodal Awareness"
status: open
needs_approval: true
created: 2026-05-04
---

STATUS: 1.0 (DRAFT)

## Summary

The adversarial-audit skill currently selects two cross-family auditors based solely on model family diversity — no consideration is given to whether a model supports thinking (chain-of-thought reasoning) or multimodal (vision) capabilities. This spec adds capability-aware selection: auditors are partitioned into thinking and non-thinking buckets, one is selected from each (when available) using randomized selection via `shuf`, and thinking-capable auditors receive `thinking: max` (the model's highest supported level) in their dispatch context. Model capabilities are declared in agent frontmatter as the single source of truth.

## Motivation

Nine auditor models are qualified and available. Several support thinking with different level sets (e.g., DeepSeek V4 Pro supports `["low", "medium", "high", "max"]`, GLM 5.1 supports its own set, others support none). Several support vision in addition to text. Currently:

1. The `resolve-models` selection algorithm ignores these capabilities entirely
2. Thinking-capable auditors are dispatched without thinking enabled — a wasted capability
3. Selection is deterministic (always picks the same family-priority model), removing diversity
4. Agent frontmatter has no mechanism to declare model capabilities

Accuracy and correctness ALWAYS trump cost/speed/context usage. When a model supports thinking, it MUST be dispatched with the maximum thinking level available. Randomized selection across compatible models ensures perspective diversity across audit runs.

## Fix Approach

### 1. Agent Frontmatter — Capability Declaration (9 files)

Add two new frontmatter fields to each `.opencode/agents/auditor-*.md`:

```yaml
thinking: ["low", "medium", "high", "max"]   # actual levels per-model — null/[] if unsupported
multimodal: ["text", "vision"]                # or ["text"]
```

Capability values are discovered by probing each model via `opencode-cli run`, not assumed from training data. This frontmatter is the single source of truth.

### 2. resolve-models.md — Capability-Aware Selection

Replace Steps 5-6 with:

**Step 5 — Partition into thinking/non-thinking buckets:**
- Read each candidate agent's frontmatter via `read` tool
- `thinking` field non-null and non-empty → thinking bucket
- `thinking` field null or `[]` → non-thinking bucket

**Step 6 — Random selection via `shuf`:**

| Scenario | Action |
|----------|--------|
| ≥1 thinking + ≥1 non-thinking, different families | Select 1 from thinking bucket (random via `shuf`), select 1 from non-thinking bucket (random via `shuf`) — MUST be from a DIFFERENT family than the thinking auditor |
| Only thinking models, ≥2 families | Select 2 from thinking bucket, different families (random via `shuf` for each) |
| Only non-thinking models, ≥2 families | Select 2 from non-thinking bucket, different families (random via `shuf` for each) |
| 1 family total | Return `{ auditor_1: null, auditor_2: null, error: "SINGLE_FAMILY", available_family: "<family>" }` |

**Step 7 — Return result contract:** Add `auditor_1_thinking: bool` and `auditor_2_thinking: bool` fields.

**Selection priority within a bucket is always random via `shuf`** — no deterministic priority ordering. This ensures different audit runs cycle through available models for perspective diversity.

### 3. cross-validate.md — Thinking Passthrough and Single-Family Proxy

**Steps 3-4 (auditor dispatch):** After `resolve-models` returns auditor types, read the corresponding agent `.md` frontmatter. If `thinking` is non-null:
- Extract the last element of the thinking levels array (the model's maximum)
- Include `thinking: <max_level>` in the dispatch context
- If `thinking` is null/empty, dispatch normally without thinking

**Step 2 (single-family proxy fallback):** When `resolve-models` returns `SINGLE_FAMILY`:
- Use the same model for both auditors but with **different proxy prompts**:
  - Auditor 1: standard adversarial prompt
  - Auditor 2: standard prompt + "Approach this from a completely different angle. If you find yourself agreeing with what you'd normally conclude, try to find counter-evidence instead."
- Both dispatched with `task(subagent_type="<same-auditor-type>")`

### 4. adversarial-audit/SKILL.md Updates

- Update overview to mention capability-aware selection and thinking passthrough
- Operating protocol: add rule 8 (thinking max), rule 9 (random selection), rule 10 (single-family proxy prompt)
- Dispatch audit table: add `thinking_capable: bool` to auditor row
- yaml rules: add thinking passthrough rule, random-selection invariant, single-family proxy fallback rule

## Success Criteria

| SC# | Criterion | Verification |
|-----|-----------|-------------|
| SC-1 | All 9 `auditor-*.md` files have `thinking` and `multimodal` frontmatter fields with discovered (not assumed) values | Content verification — grep for `thinking:` and `multimodal:` in each file |
| SC-2 | `resolve-models.md` partitions candidates into thinking/non-thinking buckets and selects randomly via `shuf` | Content verification — bucket partition logic and `shuf` usage documented in task file |
| SC-3 | `resolve-models.md` returns one thinking + one non-thinking auditor from different families (when both buckets populated) | Behavioral test — run resolve-models and verify result types |
| SC-4 | `resolve-models.md` falls back to cross-family-same-bucket when one bucket empty | Behavioral test — simulate one-bucket-depleted scenario |
| SC-5 | `resolve-models.md` returns `SINGLE_FAMILY` error when only one family available | Behavioral test — simulate single-family scenario |
| SC-6 | `cross-validate.md` passes `thinking: <max>` to thinking-capable auditors | Content verification — dispatch context construction includes conditional thinking field |
| SC-7 | `cross-validate.md` handles `SINGLE_FAMILY` with proxy-prompt fallback | Content verification — proxy prompt logic in task file |
| SC-8 | `adversarial-audit/SKILL.md` reflects capability-aware protocol | Content verification — overview, protocol, rules updated |
| SC-9 | Random selection produces different auditor pairings across runs (non-deterministic) | Behavioral test — run twice, verify different pairings |
| SC-10 | Thinking passthrough never uses assumed/fixed level names — always reads model's actual levels array | Content verification — code/logic uses `levels[-1]` not hardcoded string |

## Files Affected

| File | Change |
|------|--------|
| `.opencode/agents/auditor-deepseek-v4.md` | Add `thinking`, `multimodal` frontmatter |
| `.opencode/agents/auditor-deepseek-flash.md` | Add `thinking`, `multimodal` frontmatter |
| `.opencode/agents/auditor-deepseek-v3.md` | Add `thinking`, `multimodal` frontmatter |
| `.opencode/agents/auditor-glm-5.1.md` | Add `thinking`, `multimodal` frontmatter |
| `.opencode/agents/auditor-glm-5.md` | Add `thinking`, `multimodal` frontmatter |
| `.opencode/agents/auditor-mistral-large.md` | Add `thinking`, `multimodal` frontmatter |
| `.opencode/agents/auditor-kimi-k2.md` | Add `thinking`, `multimodal` frontmatter |
| `.opencode/agents/auditor-qwen3.5.md` | Add `thinking`, `multimodal` frontmatter |
| `.opencode/agents/auditor-devstral-2.md` | Add `thinking`, `multimodal` frontmatter |
| `.opencode/skills/adversarial-audit/tasks/resolve-models.md` | Steps 5-7: bucket partition + random selection |
| `.opencode/skills/adversarial-audit/tasks/cross-validate.md` | Steps 2-4: thinking passthrough, single-family proxy |
| `.opencode/skills/adversarial-audit/SKILL.md` | Overview, protocol, dispatch audit, rules |

## Revision Notes

- 1.0: Initial spec — 2026-05-04
