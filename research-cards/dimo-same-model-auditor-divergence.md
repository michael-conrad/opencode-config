---
question: Can same-model role-differentiated agents produce divergent evaluations sufficient for adversarial audit?
confidence: 0.9
tags: [dimo, adversarial-audit, same-model, role-differentiation, clean-room]
source: He & Feng, arXiv:2510.16645 (Oct 2025) — full paper read via arxiv.org
date: 2026-07-04
---

## Finding

Yes. DiMo (Diverse Multi-Agent Collaboration) demonstrates that same-model role-differentiated agents outperform cross-model debate baselines on 5/6 benchmarks. The divergence mechanism is architectural (role persona + clean-room isolation + structured protocol), not model-family diversity.

### Key Results

| Benchmark | DiMo (LLaMA-3-8B) | Best Cross-Model Baseline | Improvement |
|-----------|-------------------|---------------------------|-------------|
| CSQA | 80.02% | 76.1% (single LLaMA) | +3.9% |
| ARC-Challenge | 84.1% | 79.1% (single LLaMA) | +5.0% |
| StrategyQA | 92.7% | 84.4% (LLM MAD) | +8.3% |
| OpenBookQA | 84.5% | 79.2% (single LLaMA) | +5.3% |
| GSM8K | 90.7% | 84.0% (CoT) | +6.7% |
| GSM-hard | 71.4% | 44.7% (CoT) | +26.7% |

### DiMo Architecture

- **4 roles**: Generator (initial answer), Evaluator (assess correctness), Knowledge Supporter (retrieve evidence), Path Provider (construct reasoning chains)
- **2 protocols**: Divergent mode (parallel proposals → synthesis → discussion) for open-ended tasks; Logical mode (Evaluate → Refine → Judge loop) for structured tasks
- **Same backbone model** across all roles — only system prompts and decoding temperatures differ
- **Clean-room isolation**: each role operates independently, writes structured output for downstream roles

### Relevance to opencode-config

- Maps directly to existing clean-room `task()` dispatch pattern
- Eliminates need for `resolve-models` cross-family selection
- Eliminates `INSUFFICIENT_FAMILIES` error state
- Single model family sufficient for adversarial audit

### Limitations

- Tested on reasoning benchmarks (CSQA, GSM8K), not software audit tasks
- Protocol-task affinity (Divergent vs Logical) needs validation for audit domain
- Same-family blind spot per Calboreanu — both auditors using same model may share blind spots
