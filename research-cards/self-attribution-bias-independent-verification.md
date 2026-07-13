---
title: "Self-Attribution Bias & Independent Verification Mandate"
tags: [self-attribution-bias, independent-verification, re-audit, audit-separation, clean-room]
confidence: 0.9
sources:
  - url: https://arxiv.org/abs/2603.04582
    title: "Self-Attribution Bias: When AI Monitors Go Easy on Themselves"
    authors: "Khullar, D., Hopkins, J., Wang, R., Roger, F."
    year: 2026
    finding: "AI models rate their own outputs as safer and more correct than identical content from other models. Approval rate for dangerous code patches changed by 5x depending on self-attribution."
  - url: https://arize.com/blog/should-i-use-the-same-llm-for-my-eval-as-my-agent-testing-self-evaluation-bias/
    title: "Should I Use the Same LLM for My Eval as My Agent? Testing Self-Evaluation Bias"
    authors: "Arize AI (Dhinakaran, Hutton)"
    year: 2025
    finding: "Same-model evaluation systematically inflates scores vs. different-model evaluation."
  - url: https://www.mend.io/blog/ai-generated-code-security-independent-verification/
    title: "AI-Generated Code Security: Why AI Can't Self-Verify"
    authors: "Mend.io"
    year: 2026
    finding: "A system grading its own output is not verification, it is self-attestation."
  - url: https://arxiv.org/html/2508.02994v1
    title: "When AIs Judge AIs: The Rise of Agent-as-a-Judge Evaluation for LLMs"
    authors: "Liang et al."
    year: 2024
    finding: "LLM judges favor arguments made by agents of the same model family."
summary: "Multiple independent studies converge on a structural finding: the same model that produced a deliverable cannot independently verify it. Self-attribution bias (Khullar 2026), self-evaluation bias (Arize 2025), and the independent verification mandate (Mend 2026) all support requiring clean-room re-audit after remediation — the remediator and verifier must be different sub-agents with no shared context."
applies_to:
  - spec-audit
  - verification-audit
  - plan-fidelity
  - cross-validate
  - critical-rules-hard-fail
created: 2026-07-12
---

# Self-Attribution Bias & Independent Verification Mandate

## Key Finding

The same model that produced a deliverable cannot independently verify it. Multiple studies converge on this structural limitation of LLM self-verification.

## Sources

### 1. Self-Attribution Bias (Khullar et al., 2026)
- **URL**: https://arxiv.org/abs/2603.04582
- **Lab**: MATS / Anthropic
- **Finding**: Across 10 frontier models, AI models rate their own outputs as safer and more correct than identical content they believe was produced by another model. In one condition, the approval rate for dangerous code patches changed by a factor of five depending on whether self-attribution was present.
- **Mechanism**: The bias is triggered by prompt formatting alone — presenting an action as "your previous turn's output" within the conversation structure is enough to soften the evaluation.

### 2. Self-Evaluation Bias (Arize AI, 2025)
- **URL**: https://arize.com/blog/should-i-use-the-same-llm-for-my-eval-as-my-agent-testing-self-evaluation-bias/
- **Finding**: Same-model evaluation systematically inflates scores vs. different-model evaluation. The bias is measurable and systematic.

### 3. Independent Verification Mandate (Mend.io, 2026)
- **URL**: https://www.mend.io/blog/ai-generated-code-security-independent-verification/
- **Finding**: "A system grading its own output is not verification, it is self-attestation. The model that wrote the code cannot be trusted to certify it."

### 4. LLM-as-Judge Bias (Liang et al., 2024)
- **URL**: https://arxiv.org/html/2508.02994v1
- **Finding**: An LLM judge tends to favor arguments made by an agent of the same model family. Using the same model for all roles introduces systematic bias.

## Application

This research grounds the requirement that after remediating a deliverable in response to audit findings, the agent MUST dispatch a clean-room re-audit via `skill({name: "audit"})` + `task()`. The remediator and verifier must be different sub-agents with no shared context. A self-check, inline re-read, or orchestrator-level re-verification is structurally insufficient — the self-attribution bias predicts inflated PASS rates.
