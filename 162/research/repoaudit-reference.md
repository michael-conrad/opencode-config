# RepoAudit Reference — Issue #162

**Paper:** Guo et al., "RepoAudit: An Autonomous LLM-Agent for Repository-Level Code Auditing" (arXiv:2501.18160, ICML 2025)

## Core Thesis

Multi-agent LLM framework for code auditing. Uses a three-role chain: initiator → explorer → validator. Validator module mitigates hallucinations by verifying data-flow facts and checking path condition satisfiability.

## Three-Role Architecture

| Role | Function | DiMo Parallel |
|------|----------|---------------|
| Initiator | Identifies starting points based on properties under investigation | Generator |
| Explorer | Traverses relevant functions on demand, reasons about relevant paths | Path Provider |
| Validator | Checks explorer output, verifies data-flow facts, reduces false positives | Evaluator + Judger |

## Key Results

- 40 true bugs across 15 real-world benchmark projects, 78.43% precision
- 185 new bugs in high-profile projects, 174 confirmed or fixed
- Average 0.44 hours and $2.54 per project
- Powered by Claude 3.5 Sonnet, DeepSeek R1, Claude 3.7 Sonnet, OpenAI o3-mini
- Outperforms industrial static analyzers (Amazon CodeGuru: 0 TP, Meta Infer: 7 TP)

## Relevance

- Validates multi-role chain approach for code audit specifically (not just reasoning benchmarks)
- Validator module maps to Evaluator + Judger roles in DiMo
- Demand-driven traversal (explore only relevant paths) maps to Path Provider's reasoning chain construction
- Demonstrates that structured role chains outperform monolithic prompting for code audit
