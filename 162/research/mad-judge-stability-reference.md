# Multi-Agent Debate for LLM Judges Reference — Issue #162

**Paper:** Hu et al., "Multi-Agent Debate for LLM Judges with Adaptive Stability Detection" (arXiv:2510.12697, Oct 2025)

## Core Thesis

Multi-agent debate judge framework where agents collaboratively reason and iteratively refine their responses. Formalizes debate mathematically, proving debate amplifies correctness compared to static ensembles.

## Key Contributions

- **Debate amplifies correctness** compared to static ensembles (majority voting)
- **Adaptive stability detection** using time-varying Beta-Binomial mixture with Kolmogorov-Smirnov test for adaptive stopping
- Models judges' collective correct rate dynamics to determine when consensus is reached
- Improves judgment accuracy over majority voting while maintaining computational efficiency

## Relevance

- Supports DiMo's structured debate protocol over simple voting/ensembling
- Adaptive stability detection concept could inform Judger role's holistic assessment — the Judger doesn't just count PASS/FAIL votes but evaluates whether the chain has reached stable consensus
- The Beta-Binomial mixture approach is more complex than needed for the audit domain (binary PASS/FAIL per SC), but the principle of detecting when additional rounds stop producing new information is relevant
