---
number: 162
title: "[SPEC] LaTeX Paper: Same-Model Adversarial Auditor Divergence via Role-Differentiated Agent Chains"
status: DRAFT
labels: [SPEC, needs-approval]
created: 2026-05-30
updated: 2026-07-04
---

## [SPEC] LaTeX Paper: Same-Model Adversarial Auditor Divergence via Role-Differentiated Agent Chains

**Status:** DRAFT
**Primary Reference:** DiMo (He & Feng, arXiv:2510.16645, Oct 2025)

## Problem

Adversarial auditing of AI agent output currently requires cross-model auditor dispatch — two different model families evaluate the same artifact independently. This works but is costly: it requires multiple inference endpoints, model availability across families, and orchestrator overhead for managing heterogeneous dispatch.

The opencode-config adversarial-audit skill relies on `resolve-models` to select from a pool of auditor sub-agent types (deepseek-flash, gemma4, etc.). When cross-model auditor cards are unavailable — or when the orchestrator model is the only available model — the question becomes: **can the same model produce divergent enough evaluations to function as a valid adversarial auditor?**

## Proposed Solution

A LaTeX paper formalizing **Role-Differentiated Agent Chaining** — a technique where the same LLM, dispatched through structurally distinct role personas in clean-room task() calls, produces divergent evaluations sufficient for adversarial audit. The paper uses DiMo (He & Feng, 2025) as the primary reference and contrastive point.

## Key Contributions

1. **Formal definition of Role-Differentiated Agent Chaining** — mapping DiMo's four roles (Generator, Evaluator, Knowledge Supporter, Path Provider) onto sequential clean-room task() calls rather than synchronous debate
2. **Validation that same-model divergence IS achievable** — DiMo outperformed cross-model debate baselines with all agents using the same backbone model
3. **Evidence that the divergence mechanism is architectural, not prompting** — structurally different personas + clean-room isolation + structured output schema produce divergent distributions without temperature variation
4. **Cost model comparison** — single-model sequential dispatch vs. cross-model heterogeneous dispatch (inference cost, orchestrator context cost, availability)
5. **Empirical evaluation** — testing the same-model auditor against known defect injection scenarios

## Related Implementation

The practical implementation of the DiMo-aligned architecture — replacing the cross-model auditor dispatch with role-differentiated agent chaining in the `.opencode` submodule — is specified in:

- **https://github.com/michael-conrad/.opencode/issues/1672** — [SPEC] DiMo-Aligned Adversarial Audit: Replace Cross-Model Auditor Dispatch with Role-Differentiated Agent Chaining

That spec covers the concrete changes to auditor cards, task files, dispatch contracts, and behavioral tests. This paper spec (opencode-config#162) provides the theoretical foundation and empirical validation that the implementation spec builds upon.

## Paper Structure (Draft)

1. Introduction
2. Related Work
   2.1 Multi-Agent Debate (MAD, DiMo, PETITE)
   2.2 Self-Correction and Self-Consistency
   2.3 Software Inspection Methodology
3. The Problem: Same-Model Convergence
   3.1 Degeneration-of-Thought
   3.2 The Self-Consistency Failure Mode
   3.3 Self-Correction Error Dynamics (EIR/ECR model)
4. DiMo: The Primary Reference
   4.1 Four-Role Architecture
   4.2 Interaction Protocols (Divergent vs. Logical)
   4.3 Same-Model Results Outperform Cross-Model Baselines
5. Role-Differentiated Agent Chaining
   5.1 Sequential Task Dispatch vs. Synchronous Debate
   5.2 Clean-Room Isolation per Role
   5.3 Structured Output Schema Divergence
   5.4 Mapping DiMo Roles to Pipeline Stages
6. Empirical Evaluation
   6.1 Defect Injection Methodology
   6.2 Cross-Model vs. Same-Model Detection Rates
   6.3 Protocol-Task Affinity for Audit
7. Comparison with Existing Approaches
8. Limitations and Future Work
   8.1 Same-Family Blind Spot (Calboreanu)
   8.2 Model-Capability Dependency
   8.3 Temperature Control Gap
9. Conclusion

## Verification

The paper will follow the academic peer review pipeline from [#125](https://github.com/michael-conrad/opencode-config/issues/125): editor desk review → dual independent reviews → editor decision → revision → audit → final.
