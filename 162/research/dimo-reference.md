# DiMo Reference — Issue #162

**Paper:** He & Feng, "Unleashing Diverse Thinking Modes in LLMs through Multi-Agent Collaboration" (arXiv:2510.16645, Oct 2025)

## Core Thesis

Same-model role-differentiated agents can outperform cross-model debate baselines. The divergence mechanism is architectural (role persona + clean-room isolation + structured protocol), not model-family diversity.

## Four Roles

| Role | Function | Audit Mapping |
|------|----------|---------------|
| Generator | Produces initial answer/verdict | Initial audit verdict per SC |
| Evaluator | Assesses correctness, identifies gaps/errors | Critiques Generator's verdict against evidence |
| Knowledge Supporter | Retrieves domain knowledge, validates accuracy | Retrieves and validates evidence from codebase/docs/specs |
| Path Provider | Constructs reasoning paths, ensures traceability | Constructs evidence-to-verdict reasoning chain |

## Two Interaction Protocols

| Mode | Protocol | Best For | Audit Application |
|------|----------|----------|-------------------|
| Divergent | Parallel proposals → synthesis → discussion | Open-ended exploration | spec-audit, content-audit, drift-detection |
| Logical | Evaluate → Refine → Judge loop | Step-wise verification | verification-audit, plan-fidelity, closure-verification |

## Key Results

- DiMo with LLaMA-3-8B outperformed cross-model MAD baselines on 5/6 benchmarks
- Largest gains on math (GSM-hard: +26.7% over CoT)
- Protocol-task affinity: Divergent mode better for commonsense, Logical mode better for math
- Same backbone model across all roles — only system prompts and temperatures differ

## Relevance

- Maps to existing clean-room `task()` dispatch in adversarial-audit skill
- Eliminates need for `resolve-models`, 4 auditor cards, qualified pool
- Single model family sufficient — eliminates `INSUFFICIENT_FAMILIES` error state
- Judger role (from Logical mode) maps to cross-validate function
