# LLMs-as-Judges Survey Reference — Issue #162

**Paper:** Li et al., "LLMs-as-Judges: A Comprehensive Survey on LLM-based Evaluation Methods" (arXiv:2412.05579, Dec 2024)

## Scope

Comprehensive survey of the LLMs-as-judges paradigm from five perspectives: Functionality, Methodology, Applications, Meta-evaluation, and Limitations.

## Key Points

- LLMs-as-judges framework has attracted growing attention due to effectiveness, generalization across tasks, and interpretability via natural language
- Systematic definition of LLM judges and their functionality
- Methodology for constructing evaluation systems with LLMs
- Applications across multiple domains
- Meta-evaluation methods for evaluating LLM judges themselves
- Detailed analysis of limitations

## Relevance

- Provides background context for the "LLM as evaluator" paradigm that the adversarial-audit system implements
- The survey's limitation analysis (position bias, verbosity bias, self-enhancement bias) informs the clean-room isolation requirements
- Meta-evaluation section is relevant for validating that DiMo role-differentiated auditors produce higher-quality judgments than single-model baselines
