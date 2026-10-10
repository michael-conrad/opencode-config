---
title: GLM-5.3-Flash inference settings for opencode agent cards
created: 2026-10-09
confidence: 0.85
tags: research, glm-5.3-flash, agent-cards, sampling, reasoning-effort, multimodal
sources:
  - url: https://docs.z.ai/openapi.json
    verified: true
    finding: ChatCompletionVisionRequest (glm-5.3-flash/-flashx) — temperature default 1.0 range [0.0,1.0]; top_p default 0.95 range [0.01,1.0]; reasoning_effort enum [max,high,low] default max; thinking.type enabled-only; NO presence_penalty/frequency_penalty/repetition_penalty/top_k anywhere in schema
  - url: https://docs.z.ai/guides/vlm/glm-5.3-flash
    verified: true
    finding: Recommended Settings — temperature 1, top_p 0.95, reasoning_effort max; thinking.clear_thinking false recommended; input Video/Image/Text/File; 1M context, 128K output; image via image_url content blocks
  - url: https://docs.z.ai/guides/llm/glm-5.3
    verified: true
    finding: Effort semantics — low Lightweight, high Enhanced, max Deep; "for complex tasks such as coding, we recommend using max"; reasoning always enabled (disabling unsupported)
  - url: https://huggingface.co/zai-org/GLM-5.3-Flash
    verified: true
    finding: generation_config.json temp 1.0 top_p 0.95; chat_template.jinja — effective reasoning_effort falls back to max unless low/high passed; clear_thinking template default false; card Note recommends clear_thinking true for chat scenarios
  - url: https://models.dev/api.json
    verified: true
    finding: huggingface/zai-org/GLM-5.3-Flash — reasoning_options effort [low,high,max]; attachment true; input text+image; context 1,048,576 / output 131,072
  - url: https://github.com/anomalyco/opencode (packages/core/src/v1/config/provider-options.ts)
    verified: true
    finding: opencode normalizes agent-card reasoningEffort (camelCase) to wire param reasoning_effort; accepted effort literals include max
---

# GLM-5.3-Flash inference settings for opencode agent cards

## Core settings (high confidence)

| Parameter | Schema truth (Z.ai OpenAPI) | Vendor recommendation | Agent-card pin |
|---|---|---|---|
| temperature | default 1.0, range [0.0, 1.0] | 1.0 | `temperature: 1.0` |
| top_p | default 0.95, range [0.01, 1.0] | 0.95 | `top_p: 0.95` |
| reasoning_effort | enum [max, high, low], default max | max for complex/coding work | `reasoningEffort: max|high|low` (camelCase; opencode normalizes) |
| thinking.type | enabled only | enabled | not pin-able (always enabled) |
| penalties + top_k | **absent from schema** | — | **never pin** |

## Key insights

1. **The model runs hot.** Vendor default and all published eval configs use
   temperature 1.0 / top_p 0.95 (or 1.0). GLM-5.3-Flash is trained for this
   regime; qwen-era low-temperature profiles (0.3–0.8) are not transferable.
2. **Intent differentiation happens via reasoning_effort, not temperature.**
   Vendor guidance differentiates tasks by effort level only (low Lightweight /
   high Enhanced / max Deep). Temperature is capped at 1.0 — there is no
   "more creative = hotter" headroom. Intent-matched cards should vary
   `reasoningEffort` and the prompt rubric, not sampling temperature.
3. **Penalty parameters and top_k do not exist in the Z.ai schema.** Any card
   carrying them (e.g. the old qwen-tuned `presence_penalty: 1.5/2.0`,
   `top_k: 20/40`) must drop them — they are unsupported, at best silently
   ignored, at worst rejected by stricter providers.

## clear_thinking — unresolved vendor conflict (medium confidence)

- Z.ai OpenAPI (`thinking.clear_thinking`): "Default value is True"
- Z.ai guide: "we recommend setting thinking.clear_thinking: false"
- HF open-weights chat_template.jinja: defaults to false when not passed
- HF model card: "defaults to false… For chat scenarios, explicitly pass true"

Semantics: true clears `reasoning_content` from previous turns (context
economy); false keeps it. Treat as **not pin-able** in opencode agent cards:
no verified pass-through path for the huggingface/ollama-cloud providers, and
vendor sources disagree on the default.

## Gaps (not verified)

1. Whether the HF Inference Providers router accepts/forwards
   `reasoning_effort` for this model end-to-end through opencode (models.dev
   declares it; a live one-shot call would confirm).
2. Whether `thinking.clear_thinking` can be passed at all via opencode agent
   cards on either provider.
3. DeepInfra/third-party serving defaults may differ from Z.ai (not checked —
   Z.ai + HF are the authoritative paths for this deck).
